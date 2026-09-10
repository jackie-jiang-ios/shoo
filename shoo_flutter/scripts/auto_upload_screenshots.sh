#!/bin/bash
# auto_upload_screenshots.sh - 自动检测新完成的截图并上传
# 用法: bash scripts/auto_upload_screenshots.sh
cd "$(dirname "$0")/../fastlane"

UPLOADED_LOG="/tmp/uploaded_langs.log"
touch "$UPLOADED_LOG"

VALID_LANGS="ar-SA bn-BD ca cs da de-DE el en-AU en-CA en-GB en-US es-ES es-MX fi fr-CA fr-FR gu-IN he hi hr hu id it ja kn-IN ko ml-IN mr-IN ms nl-NL no or-IN pa-IN pl pt-BR ro ru sk sl-SI sv ta-IN te-IN th tr uk ur-PK vi zh-Hans zh-Hant"

echo "=== 自动上传监控启动 ==="

while true; do
  for lang in $VALID_LANGS; do
    # 跳过已上传的
    grep -q "^${lang}$" "$UPLOADED_LOG" 2>/dev/null && continue
    
    DIR="screenshots/$lang"
    [ ! -d "$DIR" ] && continue
    
    PNG_COUNT=$(ls "$DIR"/*.png 2>/dev/null | wc -l | tr -d ' ')
    if [ "$PNG_COUNT" -ge 3 ]; then
      echo "[$(date +%H:%M:%S)] 检测到 $lang ($PNG_COUNT 张)，开始上传..."
      if FASTLANE_SKIP_UPDATE_CHECK=1 /usr/local/bin/fastlane upload_lang_screenshots lang:"$lang" 2>&1 | grep -q "Done:"; then
        echo "$lang" >> "$UPLOADED_LOG"
        echo "[$(date +%H:%M:%S)] ✅ $lang 上传成功"
      else
        echo "[$(date +%H:%M:%S)] ❌ $lang 上传失败，稍后重试"
      fi
    fi
  done
  
  # 检查截图脚本是否还在运行
  if ! pgrep -f "screenshot_all_langs.sh" >/dev/null 2>&1 && ! pgrep -f "screenshot_test.dart" >/dev/null 2>&1; then
    echo "[$(date +%H:%M:%S)] 截图脚本已结束，再做最后一轮上传..."
    for lang in $VALID_LANGS; do
      grep -q "^${lang}$" "$UPLOADED_LOG" 2>/dev/null && continue
      DIR="screenshots/$lang"
      PNG_COUNT=$(ls "$DIR"/*.png 2>/dev/null | wc -l | tr -d ' ')
      if [ "$PNG_COUNT" -ge 3 ]; then
        echo "[$(date +%H:%M:%S)] 最后一轮: 上传 $lang..."
        if FASTLANE_SKIP_UPDATE_CHECK=1 /usr/local/bin/fastlane upload_lang_screenshots lang:"$lang" 2>&1 | grep -q "Done:"; then
          echo "$lang" >> "$UPLOADED_LOG"
          echo "[$(date +%H:%M:%S)] ✅ $lang 上传成功"
        fi
      fi
    done
    break
  fi
  
  sleep 30
done

echo ""
echo "=== 上传监控结束 ==="
echo "已上传语言（$(wc -l < "$UPLOADED_LOG" | tr -d ' ') 个）："
cat "$UPLOADED_LOG"
