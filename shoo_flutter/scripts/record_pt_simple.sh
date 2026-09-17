#!/bin/bash
# record_pt_simple.sh - Simple video recorder for pt-PT
cd "$(dirname "$0")/.."

DEVICE="AFDC591F-F2B4-4BE2-8ED6-1A9CAF5CDFE0"
LANG="pt-PT"
DURATION=12
OUT="fastlane/screenshots/pt-PT/raw_video_final.mp4"

# Clean up
rm -f "$OUT"
xcrun simctl terminate "$DEVICE" com.yangshiqin.shoo 2>/dev/null
sleep 2

# Launch app with locale and screenshot mode
xcrun simctl launch "$DEVICE" com.yangshiqin.shoo \
  -AppleLanguages "($LANG)" -AppleLocale "$LANG" \
  -ScreenshotMode 1 -ScreenshotPage home 2>/dev/null

echo "App launched, waiting 4s..."
sleep 4

# Start recording in background
xcrun simctl io "$DEVICE" recordVideo --codec=h264 --mask=black -f "$OUT" &
REC_PID=$!
echo "Recording PID: $REC_PID"

# Wait
echo "Recording for ${DURATION}s..."
sleep $DURATION

# Stop with SIGINT
kill -INT $REC_PID 2>/dev/null
echo "Sent SIGINT, waiting for finalize..."
wait $REC_PID 2>/dev/null
sleep 2

# Verify
ls -la "$OUT" 2>/dev/null
echo "Done"
