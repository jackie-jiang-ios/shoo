#!/bin/bash
# screenshot_ipad.sh - iPad 批量截图（用于 App Store 13" iPad Pro M5, 2064×2752）
set -e
cd "$(dirname "$0")/.."

FLUTTER="flutter"
ALL_LANGS="ar-SA bn ca cs da de-DE el en-AU en-CA en-GB en-US es-ES es-MX fi fr-CA fr-FR gu he hi hr hu id it ja kn ko ml mr ms nl-NL no or pa pl pt-BR ro ru sk sl sv ta te th tr uk ur vi zh-Hans zh-Hant"
LANGS="${1:-$ALL_LANGS}"

if [ -n "${1:-}" ] && ! [[ " $ALL_LANGS " == *" $1 "* ]]; then
  echo "不支持的语言：$1"
  exit 1
fi

echo "========================================"
echo "Shoo iPad 多语言截图生成"
echo "========================================"

DEVICE_ID=$(xcrun simctl list devices | grep "Booted" | grep "iPad Pro 13-inch" | sed -E 's/.*\(([A-F0-9-]+)\).*/\1/')
if [ -z "$DEVICE_ID" ]; then
  DEVICE_ID="C42EE006-A924-450C-B9C9-6E22E58AC23E"
  echo "启动 iPad Pro 13-inch (M5) 模拟器..."
  xcrun simctl boot "$DEVICE_ID"
  xcrun simctl bootstatus "$DEVICE_ID" -b
fi
echo "使用模拟器：$DEVICE_ID (iPad Pro 13-inch M5, 2064×2752)"

SUCCESS=0
FAIL=0

for LANG in $LANGS; do
  echo ""
  echo ">>> [$LANG] iPad 截图..."
  HOST_DIR="fastlane/screenshots_ipad/$LANG"
  mkdir -p "$HOST_DIR"
  rm -f "$HOST_DIR"/*.png

  TEST_LOG="/tmp/roaroff_screenshot_ipad_${LANG}.log"
  rm -f "$TEST_LOG"
  
  TEMP_DIR="fastlane/screenshots_temp_ipad/$LANG"
  mkdir -p "$TEMP_DIR"
  
  if ! $FLUTTER test integration_test/screenshot_test.dart \
    --dart-define=LANG="$LANG" \
    --dart-define=PLATFORM=ipad \
    --dart-define=OUTPUT_DIR="$(pwd)/fastlane/screenshots_temp_ipad" \
    -d "$DEVICE_ID" >"$TEST_LOG" 2>&1; then
    echo "[$LANG] 测试失败，日志：$TEST_LOG"
    FAIL=$((FAIL + 1))
    continue
  fi

  # 无需 resize，pixelRatio 2.0 直接生成 2064×2752
  PNG_COUNT=$(ls "$TEMP_DIR"/*.png 2>/dev/null | wc -l | tr -d ' ')
  if [ "$PNG_COUNT" -ge 3 ]; then
    for f in "$TEMP_DIR"/*.png; do
      [ -f "$f" ] || continue
      filename=$(basename "$f")
      cp "$f" "$HOST_DIR/$filename"
    done
    # Verify
    FINAL_COUNT=$(ls "$HOST_DIR"/*.png 2>/dev/null | wc -l | tr -d ' ')
    echo "[$LANG] 已生成 $FINAL_COUNT 张 iPad 截图"
    SUCCESS=$((SUCCESS + 1))
  else
    echo "[$LANG] 只生成 $PNG_COUNT 张截图"
    FAIL=$((FAIL + 1))
  fi
done

rm -rf "fastlane/screenshots_temp_ipad"

echo ""
echo "========================================"
echo "完成：成功 $SUCCESS，失败 $FAIL"
echo "========================================"

[ "$FAIL" -eq 0 ]
