#!/bin/bash
# record_all_videos.sh - iPhone 批量视频录制
set -e
cd "$(dirname "$0")/.."

FFMPEG="${FFMPEG:-$(command -v ffmpeg || true)}"
FFPROBE="${FFPROBE:-$(command -v ffprobe || true)}"
[ -z "$FFMPEG" ] && [ -x /usr/local/bin/ffmpeg ] && FFMPEG=/usr/local/bin/ffmpeg
[ -z "$FFPROBE" ] && [ -x /usr/local/bin/ffprobe ] && FFPROBE=/usr/local/bin/ffprobe
if [ -z "$FFMPEG" ] || [ -z "$FFPROBE" ]; then
  echo "未找到 ffmpeg 或 ffprobe；可通过 FFMPEG/FFPROBE 环境变量指定路径"
  exit 1
fi

ALL_LANGS="ar-SA bn ca cs da de-DE el en-AU en-CA en-GB en-US es-ES es-MX fi fr-CA fr-FR gu he hi hr hu id it ja kn ko ml mr ms nl-NL no or pa pl pt-BR ro ru sk sl sv ta te th tr uk ur vi zh-Hans zh-Hant"
LANGS="${1:-$ALL_LANGS}"
if [ -n "${1:-}" ] && ! [[ " $ALL_LANGS " == *" $1 "* ]]; then
  echo "不支持的语言：$1"
  echo "可用语言：$ALL_LANGS"
  exit 1
fi
APP_ID="com.yangshiqin.shoo"
READY_TIMEOUT=120
STOP_TIMEOUT=120

print_log_tail() {
  local log_file="$1"
  echo "  === 最近 20 行日志：$log_file ==="
  if [ -f "$log_file" ]; then
    tail -20 "$log_file"
  else
    echo "  日志文件不存在"
  fi
}

# Find or boot iPhone 14 Plus (6.5" display for APP_IPHONE_65)
DEVICE_ID=$(xcrun simctl list devices available | grep "iPhone 14 Plus" | head -1 | grep -oE "[A-F0-9-]{36}" | head -1)
if [ -z "$DEVICE_ID" ]; then
  echo "未找到 iPhone 14 Plus 模拟器"
  exit 1
fi
echo "Device: $DEVICE_ID (iPhone 14 Plus)"

# Ensure device is booted
if ! xcrun simctl list devices | grep "$DEVICE_ID" | grep -q "Booted"; then
  echo "引导 iPhone 14 Plus..."
  xcrun simctl boot "$DEVICE_ID"
  for i in $(seq 1 30); do
    xcrun simctl list devices | grep "$DEVICE_ID" | grep -q "Booted" && break
    sleep 2
  done
fi
# Extra wait for simulator to fully start
sleep 5
echo "设备已启动: $DEVICE_ID"

for LANG in $LANGS; do
  OUTPUT_DIR="fastlane/screenshots/$LANG"
  VIDEO_FILE="$OUTPUT_DIR/raw_video.mp4"
  FINAL_VIDEO="$OUTPUT_DIR/IPHONE_65-0.mp4"
  TEST_LOG="$OUTPUT_DIR/video_test.log"
  RECORD_LOG="$OUTPUT_DIR/record_video.log"
  mkdir -p "$OUTPUT_DIR"
  echo "=== Recording: $LANG ==="
  rm -f "$VIDEO_FILE" "$FINAL_VIDEO"
  
  if [ ! -f "$VIDEO_FILE" ]; then
    rm -f "/tmp/shoo_video_ready_$LANG" "/tmp/shoo_video_start_$LANG" "/tmp/shoo_video_stop_$LANG"
    xcrun simctl terminate "$DEVICE_ID" "$APP_ID" >/dev/null 2>&1 || true
    sleep 1
    
    # Use -d to specify device explicitly
    flutter test integration_test/video_test.dart \
      --dart-define=LANG="$LANG" \
      --dart-define=OUTPUT_DIR=fastlane/screenshots \
      -d "$DEVICE_ID" >"$TEST_LOG" 2>&1 &
    TEST_PID=$!

    READY=0
    for i in $(seq 1 "$READY_TIMEOUT"); do
      if [ -f "/tmp/shoo_video_ready_$LANG" ]; then READY=1; break; fi
      if ! kill -0 "$TEST_PID" 2>/dev/null; then
        echo "  测试进程在 ready 前退出：$LANG"
        print_log_tail "$TEST_LOG"
        break
      fi
      sleep 1
    done
    if [ "$READY" -ne 1 ]; then
      echo "  等待 ready 超时（${READY_TIMEOUT}s）：$LANG"
      print_log_tail "$TEST_LOG"
      kill "$TEST_PID" 2>/dev/null || true
      wait "$TEST_PID" 2>/dev/null || true
      continue
    fi

    touch "/tmp/shoo_video_start_$LANG"
    xcrun simctl io "$DEVICE_ID" recordVideo --codec=h264 --mask=ignored -f "$VIDEO_FILE" >"$RECORD_LOG" 2>&1 &
    RECORD_PID=$!

    STOPPED=0
    for i in $(seq 1 "$STOP_TIMEOUT"); do
      if [ -f "/tmp/shoo_video_stop_$LANG" ]; then STOPPED=1; break; fi
      if ! kill -0 "$TEST_PID" 2>/dev/null; then
        echo "  测试进程在录制完成前退出：$LANG"
        print_log_tail "$TEST_LOG"
        break
      fi
      sleep 1
    done
    kill -INT "$RECORD_PID" 2>/dev/null || true
    wait "$RECORD_PID" 2>/dev/null || true

    if [ "$STOPPED" -ne 1 ]; then
      echo "  等待 stop 超时或测试失败（${STOP_TIMEOUT}s）：$LANG"
      print_log_tail "$TEST_LOG"
      kill "$TEST_PID" 2>/dev/null || true
      wait "$TEST_PID" 2>/dev/null || true
      continue
    fi
    if ! wait "$TEST_PID"; then
      echo "  测试执行失败：$LANG"
      print_log_tail "$TEST_LOG"
      continue
    fi
  else
    echo "  Reusing raw video: $VIDEO_FILE"
  fi
  
  if [ ! -s "$VIDEO_FILE" ]; then echo "  No usable raw video: $LANG"; print_log_tail "$RECORD_LOG"; continue; fi
  NARRATION="$OUTPUT_DIR/narration.mp3"
  if [ ! -s "$NARRATION" ] || ! "$FFPROBE" -v error -show_entries format=duration -of csv=p=0 "$NARRATION" 2>/dev/null | awk 'NF == 0 || $1 <= 0 { exit 1 }'; then
    echo "  Invalid or missing MP3: $NARRATION"; continue
  fi
  VIDEO_DUR=$("$FFPROBE" -v error -show_entries format=duration -of csv=p=0 "$VIDEO_FILE" 2>/dev/null | cut -d. -f1)
  AUDIO_DUR=$("$FFPROBE" -v error -show_entries format=duration -of csv=p=0 "$NARRATION" 2>/dev/null | cut -d. -f1)
  OUT_DUR=$AUDIO_DUR
  [ "$OUT_DUR" -lt 15 ] && OUT_DUR=15
  [ "$OUT_DUR" -gt 30 ] && OUT_DUR=30
  if [ -z "$VIDEO_DUR" ] || [ "$VIDEO_DUR" -eq 0 ]; then PTS_FACTOR="1.0"; else PTS_FACTOR=$(echo "scale=2; $AUDIO_DUR / $VIDEO_DUR" | bc 2>/dev/null || echo "1.0"); fi
  "$FFMPEG" -y -fflags +genpts -i "$VIDEO_FILE" -i "$NARRATION" -vf "scale=886:1920:force_original_aspect_ratio=decrease,pad=886:1920:(ow-iw)/2:(oh-ih)/2:black,setpts=PTS*${PTS_FACTOR},fps=30" -c:v libx264 -profile:v high -level 4.0 -b:v 10M -maxrate 8M -bufsize 8M -pix_fmt yuv420p -c:a aac -b:a 256k -ar 44100 -ac 2 -t "$OUT_DUR" -movflags +faststart "$FINAL_VIDEO" 2>/dev/null
  if [ -f "$FINAL_VIDEO" ]; then
    FINAL_DUR=$("$FFPROBE" -v error -show_entries format=duration -of csv=p=0 "$FINAL_VIDEO" | cut -d. -f1)
    FINAL_SIZE=$(du -h "$FINAL_VIDEO" | cut -f1)
    echo "  OK $LANG: ${FINAL_DUR}s, $FINAL_SIZE"
  else
    echo "  FAIL $LANG"
  fi
done
echo "=== All done ==="
