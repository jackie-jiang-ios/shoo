#!/bin/bash
# screenshot_all_langs.sh - 批量生成多语言 App Store 截图
# 用法: bash scripts/screenshot_all_langs.sh
set -e
cd "$(dirname "$0")/.."

# 支持的 App Store 语言
LANGS="zh-Hans zh-Hant en-US ja ko fr-FR de-DE es-ES ru pt-BR th"

# 模拟器设备名称
DEVICE="iPhone 16 Pro Max"

echo "========================================"
echo "Shoo 多语言截图生成"
echo "========================================"

for LANG in $LANGS; do
  echo ""
  echo ">>> [$LANG] 开始截图..."

  flutter test integration_test/screenshot_test.dart \
    --dart-define=LANG=$LANG \
    --dart-define=OUTPUT_DIR=fastlane/screenshots \
    -d "$DEVICE" 2>&1 | tail -5

  # 检查截图
  DIR="fastlane/screenshots/$LANG"
  if [ -d "$DIR" ]; then
    COUNT=$(ls "$DIR"/*.png 2>/dev/null | wc -l)
    echo "  ✅ [$LANG] 生成 $COUNT 张截图"
  else
    echo "  ❌ [$LANG] 截图失败"
  fi
done

echo ""
echo "========================================"
echo "全部截图完成!"
echo "========================================"

