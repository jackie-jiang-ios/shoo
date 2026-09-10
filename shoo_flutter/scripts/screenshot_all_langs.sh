#!/bin/bash
# screenshot_all_langs.sh - 批量生成多语言 App Store 截图
# 用法: bash scripts/screenshot_all_langs.sh [lang]
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
echo "Shoo 多语言截图生成"
echo "========================================"

DEVICE_ID=$(xcrun simctl list devices | grep "Booted" | grep "iPhone 14 Plus" | sed -E 's/.*\(([A-F0-9-]+)\).*/\1/')
if [ -z "$DEVICE_ID" ]; then
  DEVICE_ID="5345813A-B391-4EF4-A1C4-1C0787D948B4"
  echo "启动 iPhone 14 Plus (6.5\") 模拟器..."
  xcrun simctl boot "$DEVICE_ID"
  xcrun simctl bootstatus "$DEVICE_ID" -b
fi
echo "使用模拟器：$DEVICE_ID (iPhone 14 Plus, 1284×2778)"

SUCCESS=0
FAIL=0

for LANG in $LANGS; do
  echo ""
  echo ">>> [$LANG] 开始截图..."
  HOST_DIR="fastlane/screenshots/$LANG"
  mkdir -p "$HOST_DIR"
  rm -f "$HOST_DIR"/*.png

  TEST_LOG="/tmp/roaroff_screenshot_${LANG}.log"
  rm -f "$TEST_LOG"
  if ! $FLUTTER test integration_test/screenshot_test.dart \
    --dart-define=LANG="$LANG" \
    --dart-define=OUTPUT_DIR="$(pwd)/fastlane/screenshots" \
    -d "$DEVICE_ID" >"$TEST_LOG" 2>&1; then
    echo "[$LANG] 测试失败，日志：$TEST_LOG"
    FAIL=$((FAIL + 1))
    continue
  fi

  PNG_COUNT=$(ls "$HOST_DIR"/*.png 2>/dev/null | wc -l | tr -d ' ')
  if [ "$PNG_COUNT" -ge 3 ]; then
    echo "[$LANG] 已生成 $PNG_COUNT 张截图"
    SUCCESS=$((SUCCESS + 1))
  else
    echo "[$LANG] 只生成 $PNG_COUNT 张截图，日志：$TEST_LOG"
    FAIL=$((FAIL + 1))
  fi
done

echo ""
echo "========================================"
echo "完成：成功 $SUCCESS，失败 $FAIL"
echo "========================================"

[ "$FAIL" -eq 0 ]
