#!/bin/bash
# record_all_videos.sh
set -e
cd "$(dirname "$0")/.."

LANGS="zh-Hans zh-Hant en-US ja ko fr-FR de-DE es-ES ru pt-BR th"
APP_ID="com.yangshiqin.shoo"

DEVICE_ID=$(xcrun simctl list devices available | grep "iPhone 16 Pro Max" | head -1 | grep -o "[A-F0-9-]\{36\}" | head -1)
if [ -z "$DEVICE_ID" ]; then
  DEVICE_ID=$(xcrun simctl list devices available | grep "iPhone" | head -1 | grep -o "[A-F0-9-]\{36\}" | head -1)
fi
if [ -z "$DEVICE_ID" ]; then echo "No simulator"; exit 1; fi
echo "Device: $DEVICE_ID"

for LANG in $LANGS; do
  OUTPUT_DIR="fastlane/screenshots/$LANG"
  VIDEO_FILE="$OUTPUT_DIR/raw_video.mp4"
  FINAL_VIDEO="$OUTPUT_DIR/IPHONE_67-0.mp4"
  mkdir -p "$OUTPUT_DIR"
  if [ -f "$FINAL_VIDEO" ]; then echo "$LANG: skip"; continue; fi
  echo "=== Recording: $LANG ==="
  rm -f /tmp/shoo_video_ready_$LANG /tmp/shoo_video_start_$LANG /tmp/shoo_video_stop_$LANG "$VIDEO_FILE"
  xcrun simctl terminate "$DEVICE_ID" "$APP_ID" >/dev/null 2>&1 || true
  sleep 1
  flutter test integration_test/video_test.dart --dart-define=LANG=$LANG --dart-define=OUTPUT_DIR=fastlane/screenshots -d "$DEVICE_ID" >/dev/null 2>&1 &
  TEST_PID=$!
  for i in $(seq 1 60); do [ -f "/tmp/shoo_video_ready_$LANG" ] && break; sleep 1; done
  if [ ! -f "/tmp/shoo_video_ready_$LANG" ]; then echo "  Timeout"; kill $TEST_PID 2>/dev/null || true; continue; fi
  touch /tmp/shoo_video_start_$LANG
  xcrun simctl io "$DEVICE_ID" recordVideo --codec=h264 --mask=ignored -f "$VIDEO_FILE" &
  RECORD_PID=$!
  for i in $(seq 1 60); do [ -f "/tmp/shoo_video_stop_$LANG" ] && break; sleep 1; done
  kill -INT $RECORD_PID 2>/dev/null || true
  sleep 2
  kill $TEST_PID 2>/dev/null || true
  [ ! -f "$VIDEO_FILE" ] && echo "  No video" && continue
  NARRATION="$OUTPUT_DIR/narration.mp3"
if [ -f "$NARRATION" ]; then
  VIDEO_DUR=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$VIDEO_FILE" 2>/dev/null | cut -d. -f1)
  AUDIO_DUR=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$NARRATION" 2>/dev/null | cut -d. -f1)
  OUT_DUR=$AUDIO_DUR
  [ "$OUT_DUR" -gt 30 ] && OUT_DUR=30
  if [ -z "$VIDEO_DUR" ] || [ "$VIDEO_DUR" -eq 0 ]; then PTS_FACTOR="1.0"; else PTS_FACTOR=$(echo "scale=2; $AUDIO_DUR / $VIDEO_DUR" | bc 2>/dev/null || echo "1.0"); fi
  ffmpeg -y -fflags +genpts -i "$VIDEO_FILE" -i "$NARRATION" -vf "scale=886:1920:force_original_aspect_ratio=decrease,pad=886:1920:(ow-iw)/2:(oh-ih)/2:black,setpts=PTS*${PTS_FACTOR},fps=30" -c:v libx264 -profile:v high -level 4.0 -b:v 10M -maxrate 8M -bufsize 8M -pix_fmt yuv420p -c:a aac -b:a 256k -ar 44100 -ac 2 -t $OUT_DUR -movflags +faststart "$FINAL_VIDEO" 2>/dev/null
else
  ffmpeg -y -i "$VIDEO_FILE" -vf "scale=886:1920:force_original_aspect_ratio=decrease,pad=886:1920:(ow-iw)/2:(oh-ih)/2:black,fps=30" -c:v libx264 -profile:v high -level 4.0 -b:v 10M -maxrate 8M -bufsize 8M -pix_fmt yuv420p -movflags +faststart -t 30 "$FINAL_VIDEO" 2>/dev/null
fi
if [ -f "$FINAL_VIDEO" ]; then
  FINAL_DUR=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$FINAL_VIDEO" | cut -d. -f1)
  FINAL_SIZE=$(du -h "$FINAL_VIDEO" | cut -f1)
  echo "  OK $LANG: ${FINAL_DUR}s, $FINAL_SIZE"
else
  echo "  FAIL $LANG"
fi
done
echo "=== All done ==="
