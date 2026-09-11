#!/bin/bash
# record_watch_video.sh - Watch App 批量录制预览视频（≤15秒）
# 录制 6 秒原始视频，用 ffmpeg 插值到 30fps
# 
# 用法:
#   scripts/record_watch_video.sh all            # 录制所有语言
#   scripts/record_watch_video.sh zh-Hans        # 录制单个语言
#   scripts/record_watch_video.sh en-US zh-Hant  # 录制指定语言

set -e

WATCH_NAME="Apple Watch Series 11 (46mm)"
WATCH_BUNDLE="com.yangshiqin.shoo.watch"
PROJECT_DIR="/Users/jiangzheng/Project/iOS/Shoo/shoo_flutter/ios/ShooWatch"
OUTPUT_BASE="/Users/jiangzheng/Project/iOS/Shoo/shoo_flutter/fastlane/screenshots_watch"
DURATION=6  # 录制时长（秒），最终视频 ≤ 15 秒

# 所有语言
ALL_LANGS=(
  "en-US" "en-AU" "en-CA" "en-GB" "ar-SA" "bn" "bn-BD" "ca" "cs" "da" "de-DE" "el"
  "es-ES" "es-MX" "fi" "fr-CA" "fr-FR" "gu" "gu-IN" "he" "hi" "hr" "hu" "id" "it"
  "ja" "kn" "kn-IN" "ko" "ml" "ml-IN" "mr" "mr-IN" "ms" "nl-NL" "no" "or" "or-IN"
  "pa" "pa-IN" "pl" "pt-BR" "ro" "ru" "sk" "sl" "sl-SI" "sv" "ta" "ta-IN" "te" "te-IN"
  "th" "tr" "uk" "ur" "ur-PK" "vi" "zh-Hans" "zh-Hant"
)

# 确定要录制的语言
if [ "$1" == "all" ]; then
    LANGS=("${ALL_LANGS[@]}")
else
    LANGS=("$@")
fi

# 确保模拟器已启动
echo "=== Booting Watch Simulator ==="
xcrun simctl boot "$WATCH_NAME" 2>/dev/null || true
sleep 2

TOTAL=${#LANGS[@]}
SUCCESS=0
FAILED=0

for i in "${!LANGS[@]}"; do
    LANG="${LANGS[$i]}"
    NUM=$((i + 1))
    echo ""
    echo "[$NUM/$TOTAL] Recording: $LANG"
    
    LANG_DIR="$OUTPUT_BASE/$LANG"
    mkdir -p "$LANG_DIR"
    
    RAW_VIDEO="$LANG_DIR/raw_video.mp4"
    FINAL_VIDEO="$LANG_DIR/WATCH.mp4"
    
    # 终止旧进程
    xcrun simctl terminate "$WATCH_NAME" "$WATCH_BUNDLE" 2>/dev/null || true
    
    # 启动 App（指定语言，激活自动滚动）
    xcrun simctl launch "$WATCH_NAME" "$WATCH_BUNDLE" -WatchLang "$LANG" &
    sleep 3
    
    # 开始录制（后台）
    rm -f "$RAW_VIDEO"
    xcrun simctl io "$WATCH_NAME" recordVideo --codec=h264 --force "$RAW_VIDEO" &
    REC_PID=$!
    
    # 等待录制开始
    sleep 1
    
    # 录制指定时长
    sleep "$DURATION"
    
    # 用 SIGINT 停止录制
    kill -INT $REC_PID 2>/dev/null || true
    wait $REC_PID 2>/dev/null || true
    
    # 等待文件写入
    sleep 1
    
    # 检查录制结果并转码
    if [ -f "$RAW_VIDEO" ] && [ "$(stat -f%z "$RAW_VIDEO")" -gt 1000 ]; then
        # 用 ffmpeg 插值到 30fps
        ffmpeg -y -i "$RAW_VIDEO" \
            -vf "fps=30,scale=416:496" \
            -c:v libx264 -pix_fmt yuv420p \
            -an \
            "$FINAL_VIDEO" 2>/dev/null
        
        if [ -f "$FINAL_VIDEO" ]; then
            DUR=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$FINAL_VIDEO" 2>/dev/null || echo 0)
            SIZE=$(stat -f%z "$FINAL_VIDEO" | awk '{printf "%.0f", $1/1024}')
            FRAMES=$(ffprobe -v error -select_streams v:0 -show_entries stream=nb_frames -of csv=p=0 "$FINAL_VIDEO" 2>/dev/null || echo 0)
            echo "  ✓ OK (${DUR}s, ${FRAMES} frames, ${SIZE} KB)"
            SUCCESS=$((SUCCESS + 1))
        else
            echo "  ✗ ffmpeg failed"
            FAILED=$((FAILED + 1))
        fi
    else
        echo "  ✗ recording failed"
        FAILED=$((FAILED + 1))
    fi
done

echo ""
echo "========================================="
echo "=== Done: $SUCCESS success, $FAILED failed / $TOTAL ==="
echo "========================================="
echo "Output: $OUTPUT_BASE/<lang>/WATCH.mp4"
