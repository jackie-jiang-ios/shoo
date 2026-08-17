#!/bin/bash
# record_and_upload_all.sh - 批量录制并上传所有语言的 IPHONE_65 预览视频
# 用法: bash scripts/record_and_upload_all.sh
set -e
cd "$(dirname "$0")/.."

export PATH="$PATH:/Users/jiangzheng/flutter/bin"

LANGS="zh-Hans zh-Hant en-US ja ko fr-FR de-DE es-ES ru pt-BR th"
# zh-Hans 已上传，可跳过
SKIP_LANGS="zh-Hans"

APP_ID="com.yangshiqin.shoo"
DEVICE_ID=$(xcrun simctl list devices available | grep "iPhone 13 Pro Max" | head -1 | grep -o "[A-F0-9-]\{36\}" | head -1)
if [ -z "$DEVICE_ID" ]; then
  DEVICE_ID=$(xcrun simctl list devices available | grep "iPhone 16 Pro Max" | head -1 | grep -o "[A-F0-9-]\{36\}" | head -1)
fi
if [ -z "$DEVICE_ID" ]; then echo "No simulator"; exit 1; fi

echo "Device: $DEVICE_ID"
xcrun simctl boot "$DEVICE_ID" 2>/dev/null || true
open -a Simulator 2>/dev/null || true
sleep 5

# 确保模拟器启动
xcrun simctl list devices | grep "$DEVICE_ID" | grep "Booted" >/dev/null 2>&1 || {
  echo "Waiting for simulator to boot..."
  for i in $(seq 1 30); do
    xcrun simctl list devices | grep "$DEVICE_ID" | grep "Booted" >/dev/null 2>&1 && break
    sleep 2
  done
}
echo "Simulator ready"

# 确保 App 已安装
if ! xcrun simctl listapps "$DEVICE_ID" 2>/dev/null | grep -q "$APP_ID"; then
  echo "App not installed, building..."
  flutter build ios --simulator --no-codesign 2>&1 | tail -5
  xcrun simctl install "$DEVICE_ID" build/ios/iphonesimulator/Runner.app
fi
echo "App installed"

for LANG in $LANGS; do
  echo ""
  echo "========================================"
  echo "  Processing: $LANG"
  echo "========================================"

  # 跳过已处理的
  if echo "$SKIP_LANGS" | grep -qw "$LANG"; then
    echo "  Skipping $LANG (already done)"
    continue
  fi

  OUTPUT_DIR="fastlane/screenshots/$LANG"
  VIDEO_FILE="$OUTPUT_DIR/raw_video.mp4"
  FINAL_VIDEO="$OUTPUT_DIR/IPHONE_65-0.mp4"
  mkdir -p "$OUTPUT_DIR"

  # 如果最终视频已存在，跳过录制
  if [ -f "$FINAL_VIDEO" ]; then
    echo "  $LANG: video already exists, skipping recording"
  else
    echo "=== Recording: $LANG ==="
    rm -f /tmp/shoo_video_ready_$LANG /tmp/shoo_video_start_$LANG /tmp/shoo_video_stop_$LANG "$VIDEO_FILE"

    xcrun simctl terminate "$DEVICE_ID" "$APP_ID" >/dev/null 2>&1 || true
    sleep 1

    flutter test integration_test/video_test.dart \
      --dart-define=LANG=$LANG \
      --dart-define=OUTPUT_DIR=fastlane/screenshots \
      -d "$DEVICE_ID" 2>&1 | tee /tmp/shoo_test_output_$LANG.log &
    TEST_PID=$!

    echo "Waiting for app to be ready..."
    READY=0
    for i in $(seq 1 120); do
      [ -f "/tmp/shoo_video_ready_$LANG" ] && READY=1 && break
      if ! kill -0 $TEST_PID 2>/dev/null; then
        echo "  Test process exited early"
        tail -10 /tmp/shoo_test_output_$LANG.log
        break
      fi
      sleep 1
    done

    if [ "$READY" -ne 1 ]; then
      echo "  ❌ Timeout or failure for $LANG"
      kill $TEST_PID 2>/dev/null || true
      continue
    fi

    echo "App ready! Starting recording..."
    touch /tmp/shoo_video_start_$LANG

    xcrun simctl io "$DEVICE_ID" recordVideo --codec=h264 --mask=ignored -f "$VIDEO_FILE" &
    RECORD_PID=$!

    echo "Waiting for test automation..."
    for i in $(seq 1 120); do [ -f "/tmp/shoo_video_stop_$LANG" ] && break; sleep 1; done

    kill -INT $RECORD_PID 2>/dev/null || true
    sleep 2
    kill $TEST_PID 2>/dev/null || true

    if [ ! -f "$VIDEO_FILE" ]; then
      echo "  ❌ No video for $LANG"
      continue
    fi

    # 处理视频
    NARRATION="$OUTPUT_DIR/narration.mp3"
    echo "Processing video..."
    if [ -f "$NARRATION" ]; then
      VIDEO_DUR=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$VIDEO_FILE" 2>/dev/null | cut -d. -f1)
      AUDIO_DUR=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$NARRATION" 2>/dev/null | cut -d. -f1)
      OUT_DUR=$AUDIO_DUR
      [ "$OUT_DUR" -gt 30 ] && OUT_DUR=30
      [ "$OUT_DUR" -lt 15 ] && OUT_DUR=15
      if [ -z "$VIDEO_DUR" ] || [ "$VIDEO_DUR" -eq 0 ]; then PTS_FACTOR="1.0"; else PTS_FACTOR=$(echo "scale=2; $AUDIO_DUR / $VIDEO_DUR" | bc 2>/dev/null || echo "1.0"); fi
      echo "  Video: ${VIDEO_DUR}s, Audio: ${AUDIO_DUR}s, Output: ${OUT_DUR}s"
      ffmpeg -y -fflags +genpts -i "$VIDEO_FILE" -i "$NARRATION" \
        -vf "scale=886:1920:force_original_aspect_ratio=decrease,pad=886:1920:(ow-iw)/2:(oh-ih)/2:black,setpts=PTS*${PTS_FACTOR},fps=30" \
        -c:v libx264 -profile:v high -level 4.0 -b:v 10M -maxrate 8M -bufsize 8M -pix_fmt yuv420p \
        -c:a aac -b:a 256k -ar 44100 -ac 2 -t $OUT_DUR -movflags +faststart "$FINAL_VIDEO" 2>/dev/null
    else
      ffmpeg -y -i "$VIDEO_FILE" \
        -vf "scale=886:1920:force_original_aspect_ratio=decrease,pad=886:1920:(ow-iw)/2:(oh-ih)/2:black,fps=30" \
        -c:v libx264 -profile:v high -level 4.0 -b:v 10M -maxrate 8M -bufsize 8M -pix_fmt yuv420p \
        -movflags +faststart -t 30 "$FINAL_VIDEO" 2>/dev/null
    fi

    if [ -f "$FINAL_VIDEO" ]; then
      FINAL_DUR=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$FINAL_VIDEO" 2>/dev/null | cut -d. -f1)
      FINAL_SIZE=$(du -h "$FINAL_VIDEO" | cut -f1)
      echo "  ✅ $LANG: ${FINAL_DUR}s, $FINAL_SIZE"
    else
      echo "  ❌ FAIL $LANG"
      continue
    fi
  fi

  # 上传到 App Store Connect
  echo "=== Uploading: $LANG ==="
  PYTHONUNBUFFERED=1 python3 scripts/upload_preview_api.py \
    --video "$FINAL_VIDEO" \
    --locale "$LANG" \
    --preview-type IPHONE_65 2>&1 | tail -5

  echo "=== Done: $LANG ==="
  # 清理原始视频节省空间
  rm -f "$VIDEO_FILE"
done

echo ""
echo "========================================"
echo "  All languages processed!"
echo "========================================"
