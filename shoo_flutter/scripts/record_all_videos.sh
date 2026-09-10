#!/bin/bash
# record_all_videos.sh - iPhone 单次编译批量视频录制
# 只编译一次，test 内部 for 循环遍历所有语言，shell 控制录屏时机
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

# Find or boot iPhone 14 Plus
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

# Kill any stale app process
xcrun simctl terminate "$DEVICE_ID" "$APP_ID" >/dev/null 2>&1 || true
sleep 1

# Clean up signal files
rm -f /tmp/shoo_video_ready /tmp/shoo_video_start /tmp/shoo_video_stop

# Start flutter test ONCE (compiles once, then loops through all languages)
GLOBAL_LOG="fastlane/screenshots/video_batch.log"
echo "=== Starting single-compile batch recording ==="
flutter test integration_test/video_test.dart \
  -d "$DEVICE_ID" >"$GLOBAL_LOG" 2>&1 &
TEST_PID=$!

# Loop: wait for ready signal → start recording → wait for stop → merge
RECORD_COUNT=0
MAX_RECORDS=50
FINAL_LANGS=""

while [ "$RECORD_COUNT" -lt "$MAX_RECORDS" ]; do
  # Wait for ready signal
  READY=0
  CURRENT_LANG=""
  for i in $(seq 1 "$READY_TIMEOUT"); do
    if [ -f "/tmp/shoo_video_ready" ]; then
      CURRENT_LANG=$(cat /tmp/shoo_video_ready)
      READY=1
      break
    fi
    if ! kill -0 "$TEST_PID" 2>/dev/null; then
      echo "测试进程已退出，停止循环"
      break
    fi
    sleep 0.5
  done

  if [ "$READY" -ne 1 ]; then
    if ! kill -0 "$TEST_PID" 2>/dev/null; then
      echo "测试进程已退出"
    else
      echo "等待 ready 超时（${READY_TIMEOUT}s）"
    fi
    break
  fi

  OUTPUT_DIR="fastlane/screenshots/$CURRENT_LANG"
  VIDEO_FILE="$OUTPUT_DIR/raw_video.mp4"
  FINAL_VIDEO="$OUTPUT_DIR/IPHONE_65-0.mp4"
  RECORD_LOG="$OUTPUT_DIR/record_video.log"
  mkdir -p "$OUTPUT_DIR"
  echo "=== Recording: $CURRENT_LANG ==="
  rm -f "$VIDEO_FILE" "$FINAL_VIDEO" "$RECORD_LOG"

  # Signal start
  touch "/tmp/shoo_video_start"

  # Start recording
  xcrun simctl io "$DEVICE_ID" recordVideo --codec=h264 --mask=ignored -f "$VIDEO_FILE" >"$RECORD_LOG" 2>&1 &
  RECORD_PID=$!

  # Wait for stop signal
  STOPPED=0
  for i in $(seq 1 "$STOP_TIMEOUT"); do
    if [ -f "/tmp/shoo_video_stop" ]; then
      STOPPED=1
      break
    fi
    if ! kill -0 "$TEST_PID" 2>/dev/null; then
      echo "测试进程在录屏中退出"
      break
    fi
    sleep 0.5
  done

  # Stop recording
  kill -INT "$RECORD_PID" 2>/dev/null || true
  wait "$RECORD_PID" 2>/dev/null || true
  sleep 1

  if [ "$STOPPED" -ne 1 ]; then
    echo "等待 stop 超时（${STOP_TIMEOUT}s）：$CURRENT_LANG"
    continue
  fi

  # Merge with narration audio
  if [ -s "$VIDEO_FILE" ]; then
    NARRATION="$OUTPUT_DIR/narration.mp3"
    if [ -s "$NARRATION" ] && "$FFPROBE" -v error -show_entries format=duration -of csv=p=0 "$NARRATION" 2>/dev/null | awk 'NF==0 || $1<=0 {exit 1}'; then
      VIDEO_DUR=$("$FFPROBE" -v error -show_entries format=duration -of csv=p=0 "$VIDEO_FILE" 2>/dev/null | cut -d. -f1)
      AUDIO_DUR=$("$FFPROBE" -v error -show_entries format=duration -of csv=p=0 "$NARRATION" 2>/dev/null | cut -d. -f1)
      OUT_DUR=$AUDIO_DUR
      [ -z "$OUT_DUR" ] && OUT_DUR=15
      [ "$OUT_DUR" -lt 15 ] && OUT_DUR=15
      [ "$OUT_DUR" -gt 30 ] && OUT_DUR=30
      if [ -z "$VIDEO_DUR" ] || [ "$VIDEO_DUR" -eq 0 ]; then PTS_FACTOR="1.0";
      else PTS_FACTOR=$(echo "scale=2; $AUDIO_DUR / $VIDEO_DUR" | bc 2>/dev/null || echo "1.0"); fi
      "$FFMPEG" -y -fflags +genpts -i "$VIDEO_FILE" -i "$NARRATION" \
        -vf "scale=886:1920:force_original_aspect_ratio=decrease,pad=886:1920:(ow-iw)/2:(oh-ih)/2:black,setpts=PTS*${PTS_FACTOR},fps=30" \
        -c:v libx264 -profile:v high -level 4.0 -b:v 10M -maxrate 8M -bufsize 8M -pix_fmt yuv420p \
        -c:a aac -b:a 256k -ar 44100 -ac 2 -t "$OUT_DUR" -movflags +faststart "$FINAL_VIDEO" 2>/dev/null
    else
      # No valid narration, just scale the video
      "$FFMPEG" -y -i "$VIDEO_FILE" \
        -vf "scale=886:1920:force_original_aspect_ratio=decrease,pad=886:1920:(ow-iw)/2:(oh-ih)/2:black,fps=30" \
        -c:v libx264 -profile:v high -level 4.0 -b:v 10M -pix_fmt yuv420p \
        -t 15 -movflags +faststart "$FINAL_VIDEO" 2>/dev/null
    fi
  fi

  if [ -f "$FINAL_VIDEO" ]; then
    FINAL_DUR=$("$FFPROBE" -v error -show_entries format=duration -of csv=p=0 "$FINAL_VIDEO" 2>/dev/null | cut -d. -f1)
    FINAL_SIZE=$(du -h "$FINAL_VIDEO" | cut -f1)
    echo "  OK $CURRENT_LANG: ${FINAL_DUR}s, $FINAL_SIZE"
    FINAL_LANGS="$FINAL_LANGS $CURRENT_LANG"
    RECORD_COUNT=$((RECORD_COUNT + 1))
  else
    echo "  FAIL $CURRENT_LANG"
  fi

  # Clean signal for next iteration
  rm -f /tmp/shoo_video_ready /tmp/shoo_video_start /tmp/shoo_video_stop
done

# Cleanup
if kill -0 "$TEST_PID" 2>/dev/null; then
  echo "等待测试进程退出..."
  wait "$TEST_PID" 2>/dev/null || true
fi

echo "=== Batch complete: $RECORD_COUNT languages ==="
echo "Done: $FINAL_LANGS"
