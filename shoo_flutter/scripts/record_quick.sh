#!/bin/bash
# record_quick.sh - Fast video recording without recompilation (uses integration_test)
set -e
cd "$(dirname "$0")/.."

DEVICE="${DEVICE:-AFDC591F-F2B4-4BE2-8ED6-1A9CAF5CDFE0}"
FFMPEG="${FFMPEG:-$(command -v ffmpeg || true)}"
FFPROBE="${FFPROBE:-$(command -v ffprobe || true)}"

ALL_LANGS="ar-SA bn ca cs da de-DE el en-AU en-CA en-GB en-US es-ES es-MX fi fr-CA fr-FR gu he hi hr hu id it ja kn ko ml mr ms nl-NL no or pa pl pt-BR ro ru sk sl sv ta te th tr uk ur vi zh-Hans zh-Hant"

# Handle build mode: `build_and_install` + record specified/all languages
if [ "${1:-}" = "build" ]; then
  echo "=== Build and install ==="
  flutter build ios --debug --simulator -d "$DEVICE" 2>&1 | tail -20
  APP_PATH="build/ios/iphonesimulator/Runner.app"
  if [ -d "$APP_PATH" ]; then
    xcrun simctl install "$DEVICE" "$APP_PATH"
    echo "=== Install complete ==="
  else
    echo "Build failed: $APP_PATH not found"
    exit 1
  fi
  shift
fi

if [ -n "${1:-}" ]; then
  LANGS="$1"
else
  LANGS="$ALL_LANGS"
fi

if [ -z "$FFMPEG" ] && [ -x /usr/local/bin/ffmpeg ]; then
  FFMPEG=/usr/local/bin/ffmpeg
fi
if [ -z "$FFPROBE" ] && [ -x /usr/local/bin/ffprobe ]; then
  FFPROBE=/usr/local/bin/ffprobe
fi

echo "=== Recording videos ==="
echo "Languages: $LANGS"
echo ""

for LANG in $LANGS; do
  OUTPUT_DIR="fastlane/screenshots/$LANG"
  VIDEO_FILE="$OUTPUT_DIR/raw_video.mp4"
  FINAL_VIDEO="$OUTPUT_DIR/IPHONE_65-0.mp4"
  mkdir -p "$OUTPUT_DIR"

  echo "--- Recording: $LANG ---"

  # Launch app with recording mode args
  xcrun simctl terminate "$DEVICE" com.yangshiqin.shoo 2>/dev/null || true
  sleep 1
  xcrun simctl launch "$DEVICE" com.yangshiqin.shoo \
    -RecordMode 1 \
    -Lang "$LANG" 2>/dev/null || true
  echo "  App launched, waiting 5s..."
  sleep 5

  # Start screen recording
  rm -f "$VIDEO_FILE"
  xcrun simctl io "$DEVICE" recordVideo --codec=h264 --mask=ignored -f "$VIDEO_FILE" >/dev/null 2>&1 &
  REC_PID=$!

  # Record for ~15 seconds
  echo "  Recording..."
  sleep 15

  # Stop recording
  kill -INT "$REC_PID" 2>/dev/null || true
  wait "$REC_PID" 2>/dev/null || true
  sleep 1

  # Merge with narration audio
  NARRATION="$OUTPUT_DIR/narration.mp3"
  if [ -s "$VIDEO_FILE" ] && [ -s "$NARRATION" ] && [ -n "$FFMPEG" ]; then
    VIDEO_DUR=$("$FFPROBE" -v error -show_entries format=duration -of csv=p=0 "$VIDEO_FILE" 2>/dev/null | cut -d. -f1)
    AUDIO_DUR=$("$FFPROBE" -v error -show_entries format=duration -of csv=p=0 "$NARRATION" 2>/dev/null | cut -d. -f1)
    OUT_DUR=$AUDIO_DUR
    [ -z "$OUT_DUR" ] && OUT_DUR=15
    [ "$OUT_DUR" -lt 15 ] && OUT_DUR=15
    [ "$OUT_DUR" -gt 30 ] && OUT_DUR=30
    if [ -z "$VIDEO_DUR" ] || [ "$VIDEO_DUR" -eq 0 ]; then
      PTS_FACTOR="1.0"
    else
      PTS_FACTOR=$(echo "scale=2; $AUDIO_DUR / $VIDEO_DUR" | bc 2>/dev/null || echo "1.0")
    fi
    "$FFMPEG" -y -fflags +genpts -i "$VIDEO_FILE" -i "$NARRATION" \
      -vf "scale=886:1920:force_original_aspect_ratio=decrease,pad=886:1920:(ow-iw)/2:(oh-ih)/2:black,setpts=PTS*$PTS_FACTOR,fps=30" \
      -c:v libx264 -profile:v high -level 4.0 -b:v 10M -maxrate 8M -bufsize 8M -pix_fmt yuv420p \
      -c:a aac -b:a 256k -ar 44100 -ac 2 -t "$OUT_DUR" -movflags +faststart \
      "$FINAL_VIDEO" 2>/dev/null
    if [ -f "$FINAL_VIDEO" ]; then
      FINAL_DUR=$("$FFPROBE" -v error -show_entries format=duration -of csv=p=0 "$FINAL_VIDEO" | cut -d. -f1)
      FINAL_SIZE=$(du -h "$FINAL_VIDEO" | cut -f1)
      echo "  OK $LANG: $FINAL_DUR"'s, '"$FINAL_SIZE"
    else
      echo "  FAIL $LANG: merge failed"
    fi
  else
    if [ ! -s "$VIDEO_FILE" ]; then echo "  FAIL $LANG: no video"; fi
    if [ ! -s "$NARRATION" ]; then echo "  FAIL $LANG: no audio"; fi
  fi
  echo ""
done

echo "=== All done ==="
