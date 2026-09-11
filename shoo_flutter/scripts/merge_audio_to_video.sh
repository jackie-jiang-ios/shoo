#!/bin/bash
# merge_audio_to_video.sh - 批量将旁白 MP3 合并到无声视频中
# 用法: bash scripts/merge_audio_to_video.sh [iphone|ipad|all]

TARGET="${1:-all}"
FFMPEG="$(command -v ffmpeg || echo /usr/local/bin/ffmpeg)"

if [ ! -x "$FFMPEG" ]; then
  echo "ERROR: ffmpeg not found"
  exit 1
fi

MERGED=0

merge_one() {
  local VIDEO="$1"
  local AUDIO="$2"
  local OUTPUT="$3"
  local TMP="${OUTPUT}.tmp.mp4"

  if [ ! -f "$VIDEO" ] || [ ! -f "$AUDIO" ]; then
    return
  fi

  # Merge to temp file first, then replace
  if "$FFMPEG" -y -i "$VIDEO" -i "$AUDIO" \
    -map 0:v -map 1:a \
    -c:v copy -c:a aac -b:a 256k -ar 44100 -ac 2 \
    -shortest -movflags +faststart \
    "$TMP" 2>/dev/null; then
    mv "$TMP" "$OUTPUT"
    MERGED=$((MERGED + 1))
    echo "OK: $(basename $(dirname $OUTPUT))"
  else
    rm -f "$TMP"
    echo "FAIL: $(basename $(dirname $OUTPUT))"
  fi
}

echo "=== Merge Narration to Video ==="

# iPhone
if [ "$TARGET" = "iphone" ] || [ "$TARGET" = "all" ]; then
  echo ""
  echo "--- iPhone ---"
  for lang_dir in fastlane/screenshots/*/; do
    merge_one "${lang_dir}IPHONE_65-0.mp4" "${lang_dir}narration.mp3" "${lang_dir}IPHONE_65-0.mp4"
  done
fi

# iPad
if [ "$TARGET" = "ipad" ] || [ "$TARGET" = "all" ]; then
  echo ""
  echo "--- iPad ---"
  for lang_dir in fastlane/screenshots_ipad/*/; do
    merge_one "${lang_dir}IPAD_PRO_3GEN_129-0.mp4" "${lang_dir}narration.mp3" "${lang_dir}IPAD_PRO_3GEN_129-0.mp4"
  done
fi

echo ""
echo "=== Done: $MERGED videos merged ==="
