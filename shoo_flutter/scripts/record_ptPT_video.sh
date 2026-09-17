#!/bin/bash
# record_ptPT_video.sh - Record video for pt-PT with proper interaction
cd "$(dirname "$0")/.."

# Clean up signal files
rm -f /tmp/shoo_video_lang /tmp/shoo_video_start /tmp/shoo_video_done /tmp/shoo_video_stopped
rm -f /tmp/ptPT_iphone_raw.mp4 /tmp/ptPT_ipad_raw.mp4

# iPhone recording function
record_iphone() {
  DEVICE="AFDC591F-F2B4-4BE2-8ED6-1A9CAF5CDFE0"
  OUTPUT="fastlane/screenshots/pt-PT/raw_video.mp4"
  echo "[iPhone] Waiting for signal..."
  while true; do
    if [ -f /tmp/shoo_video_lang ]; then
      LANG=$(cat /tmp/shoo_video_lang)
      echo "[iPhone] Got lang: $LANG"
      # Start recording
      touch /tmp/shoo_video_start
      xcrun simctl io "$DEVICE" recordVideo --codec=h264 --mask=ignored -f "$OUTPUT" 2>&1 &
      REC_PID=$!
      # Wait for done signal
      while [ ! -f /tmp/shoo_video_done ]; do sleep 0.5; done
      # Stop recording
      kill -INT $REC_PID 2>/dev/null
      wait $REC_PID 2>/dev/null
      touch /tmp/shoo_video_stopped
      echo "[iPhone] Done"
      break
    fi
    sleep 0.5
  done
}

# iPad recording function
record_ipad() {
  DEVICE="C42EE006-A924-450C-B9C9-6E22E58AC23E"
  OUTPUT="fastlane/screenshots_ipad/pt-PT/raw_video.mp4"
  echo "[iPad] Waiting for signal..."
  while true; do
    if [ -f /tmp/shoo_video_lang ]; then
      LANG=$(cat /tmp/shoo_video_lang)
      echo "[iPad] Got lang: $LANG"
      touch /tmp/shoo_video_start
      xcrun simctl io "$DEVICE" recordVideo --codec=h264 --mask=ignored -f "$OUTPUT" 2>&1 &
      REC_PID=$!
      while [ ! -f /tmp/shoo_video_done ]; do sleep 0.5; done
      kill -INT $REC_PID 2>/dev/null
      wait $REC_PID 2>/dev/null
      touch /tmp/shoo_video_stopped
      echo "[iPad] Done"
      break
    fi
    sleep 0.5
  done
}

# Start both recorders in background
record_iphone &
IPHONE_PID=$!
record_ipad &
IPAD_PID=$!

# Wait for recorders to be ready
sleep 2

# Run the integration test
echo "Starting integration test..."
flutter test integration_test/video_test.dart \
  --dart-define=LANGS="pt-PT" \
  -d AFDC591F-F2B4-4BE2-8ED6-1A9CAF5CDFE0 > /tmp/ptPT_test.log 2>&1
TEST_EXIT=$?

wait $IPHONE_PID 2>/dev/null
wait $IPAD_PID 2>/dev/null

# Cleanup signals
rm -f /tmp/shoo_video_lang /tmp/shoo_video_start /tmp/shoo_video_done /tmp/shoo_video_stopped

echo "=== Result ==="
echo "iPhone video:"
ls -la fastlane/screenshots/pt-PT/raw_video.mp4 2>/dev/null
echo "iPad video:"
ls -la fastlane/screenshots_ipad/pt-PT/raw_video.mp4 2>/dev/null
