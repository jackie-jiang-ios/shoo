#!/bin/bash
# record_iphone65_video.sh - 录制 IPHONE_65 预览视频（iPhone 13 Pro Max）
# 用法: bash scripts/record_iphone65_video.sh [语言]
#
# 流程:
#   1. 确保 App 已构建并安装到模拟器
#   2. 启动 App
#   3. 用 simctl io recordVideo 录屏（自动执行 UI 自动化操作）
#   4. 用 ffmpeg 合并 TTS 旁白，输出为 IPHONE_65 格式
set -e
cd "$(dirname "$0")/.."

export PATH="$PATH:/Users/jiangzheng/flutter/bin"

LANG="${1:-zh-Hans}"
APP_ID="com.yangshiqin.shoo"
PREVIEW_TYPE="IPHONE_65"

# iPhone 13 Pro Max 模拟器
DEVICE_ID=$(xcrun simctl list devices available | grep "iPhone 13 Pro Max" | head -1 | grep -o "[A-F0-9-]\{36\}" | head -1)
if [ -z "$DEVICE_ID" ]; then
  DEVICE_ID=$(xcrun simctl list devices available | grep "iPhone 16 Pro Max" | head -1 | grep -o "[A-F0-9-]\{36\}" | head -1)
fi
if [ -z "$DEVICE_ID" ]; then
  DEVICE_ID=$(xcrun simctl list devices available | grep "iPhone" | head -1 | grep -o "[A-F0-9-]\{36\}" | head -1)
fi
if [ -z "$DEVICE_ID" ]; then echo "No simulator"; exit 1; fi
echo "Device: $DEVICE_ID"

# 启动模拟器
xcrun simctl boot "$DEVICE_ID" 2>/dev/null || true
open -a Simulator 2>/dev/null || true
sleep 5

# 等待模拟器完全启动
xcrun simctl list devices | grep "$DEVICE_ID" | grep "Booted" >/dev/null 2>&1 || {
  echo "Waiting for simulator to boot..."
  for i in $(seq 1 30); do
    xcrun simctl list devices | grep "$DEVICE_ID" | grep "Booted" >/dev/null 2>&1 && break
    sleep 2
  done
}
echo "Simulator ready"

OUTPUT_DIR="fastlane/screenshots/$LANG"
VIDEO_FILE="$OUTPUT_DIR/raw_video.mp4"
FINAL_VIDEO="$OUTPUT_DIR/IPHONE_65-0.mp4"
mkdir -p "$OUTPUT_DIR"

echo "=== Recording: $LANG (IPHONE_65) ==="
rm -f /tmp/shoo_video_ready_$LANG /tmp/shoo_video_start_$LANG /tmp/shoo_video_stop_$LANG "$VIDEO_FILE"

# === 方式1: 用 integration test 自动化操作 ===
# 先确保 App 已安装
xcrun simctl terminate "$DEVICE_ID" "$APP_ID" >/dev/null 2>&1 || true

# 检查 App 是否已安装，如果没有则先构建安装
if ! xcrun simctl listapps "$DEVICE_ID" 2>/dev/null | grep -q "$APP_ID"; then
  echo "App not installed, building..."
  flutter build ios --simulator --no-codesign 2>&1 | tail -5
  APP_PATH="build/ios/iphonesimulator/Runner.app"
  if [ ! -d "$APP_PATH" ]; then
    echo "❌ Build failed or app not found at $APP_PATH"
    exit 1
  fi
  echo "Installing app..."
  xcrun simctl install "$DEVICE_ID" "$APP_PATH"
fi
echo "App installed"

# 设置语言（通过 SharedPreferences mock）
# 由于 integration test 需要 flutter test 重新构建，
# 我们直接用 integration test 但保留输出日志
echo "Running integration test..."
rm -f /tmp/shoo_video_ready_$LANG /tmp/shoo_video_start_$LANG /tmp/shoo_video_stop_$LANG

flutter test integration_test/video_test.dart \
  --dart-define=LANG=$LANG \
  --dart-define=OUTPUT_DIR=fastlane/screenshots \
  -d "$DEVICE_ID" 2>&1 | tee /tmp/shoo_test_output.log &
TEST_PID=$!

echo "Waiting for app to be ready..."
for i in $(seq 1 120); do
  [ -f "/tmp/shoo_video_ready_$LANG" ] && break
  # 检查测试是否已经退出（可能是构建失败）
  if ! kill -0 $TEST_PID 2>/dev/null; then
    echo "  Test process exited early"
    echo "  === Last 20 lines of test output ==="
    tail -20 /tmp/shoo_test_output.log
    exit 1
  fi
  sleep 1
done

if [ ! -f "/tmp/shoo_video_ready_$LANG" ]; then
  echo "  Timeout waiting for app (120s)"
  echo "  === Last 20 lines of test output ==="
  tail -20 /tmp/shoo_test_output.log
  kill $TEST_PID 2>/dev/null || true
  exit 1
fi

echo "App is ready! Starting recording..."
touch /tmp/shoo_video_start_$LANG

# 录制视频
xcrun simctl io "$DEVICE_ID" recordVideo --codec=h264 --mask=ignored -f "$VIDEO_FILE" &
RECORD_PID=$!

echo "Waiting for test automation to complete..."
for i in $(seq 1 120); do [ -f "/tmp/shoo_video_stop_$LANG" ] && break; sleep 1; done

# 停止录制
kill -INT $RECORD_PID 2>/dev/null || true
sleep 2
kill $TEST_PID 2>/dev/null || true

if [ ! -f "$VIDEO_FILE" ]; then
  echo "  No video recorded"
  exit 1
fi

echo "Processing video..."
NARRATION="$OUTPUT_DIR/narration.mp3"

# IPHONE_65 预览视频分辨率: 886x1920
# App Store 预览视频要求: 15-30秒, H.264, AAC 音频
if [ -f "$NARRATION" ]; then
  echo "  Using narration audio..."
  VIDEO_DUR=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$VIDEO_FILE" 2>/dev/null | cut -d. -f1)
  AUDIO_DUR=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$NARRATION" 2>/dev/null | cut -d. -f1)
  OUT_DUR=$AUDIO_DUR
  [ "$OUT_DUR" -gt 30 ] && OUT_DUR=30
  [ "$OUT_DUR" -lt 15 ] && OUT_DUR=15
  if [ -z "$VIDEO_DUR" ] || [ "$VIDEO_DUR" -eq 0 ]; then PTS_FACTOR="1.0"; else PTS_FACTOR=$(echo "scale=2; $AUDIO_DUR / $VIDEO_DUR" | bc 2>/dev/null || echo "1.0"); fi
  echo "  Video: ${VIDEO_DUR}s, Audio: ${AUDIO_DUR}s, Output: ${OUT_DUR}s, PTS factor: $PTS_FACTOR"
  ffmpeg -y -fflags +genpts -i "$VIDEO_FILE" -i "$NARRATION" \
    -vf "scale=886:1920:force_original_aspect_ratio=decrease,pad=886:1920:(ow-iw)/2:(oh-ih)/2:black,setpts=PTS*${PTS_FACTOR},fps=30" \
    -c:v libx264 -profile:v high -level 4.0 -b:v 10M -maxrate 8M -bufsize 8M -pix_fmt yuv420p \
    -c:a aac -b:a 256k -ar 44100 -ac 2 -t $OUT_DUR -movflags +faststart "$FINAL_VIDEO" 2>/dev/null
else
  echo "  No narration, using raw video..."
  ffmpeg -y -i "$VIDEO_FILE" \
    -vf "scale=886:1920:force_original_aspect_ratio=decrease,pad=886:1920:(ow-iw)/2:(oh-ih)/2:black,fps=30" \
    -c:v libx264 -profile:v high -level 4.0 -b:v 10M -maxrate 8M -bufsize 8M -pix_fmt yuv420p \
    -movflags +faststart -t 30 "$FINAL_VIDEO" 2>/dev/null
fi

if [ -f "$FINAL_VIDEO" ]; then
  FINAL_DUR=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$FINAL_VIDEO" 2>/dev/null | cut -d. -f1)
  FINAL_SIZE=$(du -h "$FINAL_VIDEO" | cut -f1)
  FINAL_RES=$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0 "$FINAL_VIDEO" 2>/dev/null)
  echo "  ✅ OK $LANG: ${FINAL_DUR}s, $FINAL_SIZE, ${FINAL_RES}"
  echo "  📁 $FINAL_VIDEO"
else
  echo "  ❌ FAIL $LANG"
  exit 1
fi
