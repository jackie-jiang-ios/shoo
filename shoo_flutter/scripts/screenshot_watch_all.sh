#!/bin/bash
# screenshot_watch_all.sh - Watch App 批量截图（所有语言）
# 为每种语言编译+安装+截图，输出到 fastlane/screenshots_watch/<lang>/

set -e

WATCH_NAME="Apple Watch Series 11 (46mm)"
WATCH_BUNDLE="com.yangshiqin.shoo.watch"
PROJECT_DIR="/Users/jiangzheng/Project/iOS/Shoo/shoo_flutter/ios/ShooWatch"
OUTPUT_BASE="/Users/jiangzheng/Project/iOS/Shoo/shoo_flutter/fastlane/screenshots_watch"
APP_PATH="$PROJECT_DIR/build/Build/Products/Debug-watchsimulator/ShooWatch.app"

# 所有截图语言
LANGS=(
  "en-US" "en-AU" "en-CA" "en-GB" "ar-SA" "bn" "bn-BD" "ca" "cs" "da" "de-DE" "el"
  "es-ES" "es-MX" "fi" "fr-CA" "fr-FR" "gu" "gu-IN" "he" "hi" "hr" "hu" "id" "it"
  "ja" "kn" "kn-IN" "ko" "ml" "ml-IN" "mr" "mr-IN" "ms" "nl-NL" "no" "or" "or-IN"
  "pa" "pa-IN" "pl" "pt-BR" "ro" "ru" "sk" "sl" "sl-SI" "sv" "ta" "ta-IN" "te" "te-IN"
  "th" "tr" "uk" "ur" "ur-PK" "vi" "zh-Hans" "zh-Hant"
)

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
    echo "[$NUM/$TOTAL] Lang: $LANG"
    
    LANG_DIR="$OUTPUT_BASE/$LANG"
    mkdir -p "$LANG_DIR"
    
    # 终止旧进程
    xcrun simctl terminate "$WATCH_NAME" "$WATCH_BUNDLE" 2>/dev/null || true
    
    # 启动（指定语言）
    xcrun simctl launch "$WATCH_NAME" "$WATCH_BUNDLE" -WatchLang "$LANG"
    
    # 等待加载
    sleep 3
    
    # 截图
    OUTPUT_FILE="$LANG_DIR/01_Home.png"
    if xcrun simctl io "$WATCH_NAME" screenshot "$OUTPUT_FILE" 2>/dev/null; then
        SIZE=$(stat -f%z "$OUTPUT_FILE" 2>/dev/null || echo 0)
        if [ "$SIZE" -gt 1000 ]; then
            echo "  ✓ OK ($(echo $SIZE | awk '{printf "%.1f KB", $1/1024}'))"
            SUCCESS=$((SUCCESS + 1))
        else
            echo "  ✗ File too small"
            FAILED=$((FAILED + 1))
        fi
    else
        echo "  ✗ Failed"
        FAILED=$((FAILED + 1))
    fi
done

echo ""
echo "========================================="
echo "=== Done: $SUCCESS success, $FAILED failed / $TOTAL ==="
echo "========================================="
echo "Output dir: $OUTPUT_BASE"

# 列出结果
echo ""
echo "=== Results ==="
for LANG in "${LANGS[@]}"; do
    FILE="$OUTPUT_BASE/$LANG/01_Home.png"
    if [ -f "$FILE" ]; then
        SIZE=$(stat -f%z "$FILE" | awk '{printf "%.0f", $1/1024}')
        echo "  $LANG: ${SIZE} KB"
    else
        echo "  $LANG: MISSING"
    fi
done
