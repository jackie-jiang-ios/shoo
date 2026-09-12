#!/bin/bash
# 批量截图 Watch 首页（Home）
# 用法: scripts/capture_watch_home.sh
# 
# 通过 -WatchPage home 强制显示首页（动物声音列表页）

# 不使用 set -e，防止单个语言失败中断全部

UDID="FDDC541B-5F2D-4940-ABC2-37F6D6B7E59A"
BUNDLE_ID="com.yangshiqin.shoo.watchkitapp"
OUTPUT_BASE="fastlane/screenshots_watch"

languages=(
    "en:en-US"
    "en-AU:en-AU"
    "en-CA:en-CA"
    "en-GB:en-GB"
    "zh-Hans:zh-Hans"
    "zh-Hant:zh-Hant"
    "ja:ja"
    "ko:ko"
    "fr:fr-FR"
    "fr-CA:fr-CA"
    "de:de-DE"
    "es:es-ES"
    "es-MX:es-MX"
    "ru:ru"
    "pt:pt-BR"
    "th:th"
    "ar:ar-SA"
    "id:id"
    "it:it"
    "ms:ms"
    "nl:nl-NL"
    "pl:pl"
    "tr:tr"
    "vi:vi"
    "hi:hi"
    "da:da"
    "fi:fi"
    "gu:gu-IN"
    "ca:ca"
    "cs:cs"
    "kn:kn-IN"
    "hr:hr"
    "ro:ro"
    "mr:mr-IN"
    "ml:ml-IN"
    "bn:bn-BD"
    "no:no"
    "pa:pa-IN"
    "sv:sv"
    "sk:sk"
    "sl:sl-SI"
    "te:te-IN"
    "ta:ta-IN"
    "uk:uk"
    "ur:ur-PK"
    "or:or-IN"
    "el:el"
    "he:he"
    "hu:hu"
)

echo "开始截图 Watch 首页..."
echo "总共 ${#languages[@]} 个语言"
echo ""

count=0
for lang_pair in "${languages[@]}"; do
    IFS=':' read -r lang_code dir_name <<< "$lang_pair"
    count=$((count + 1))
    
    echo "[$count/${#languages[@]}] $dir_name ($lang_code)"
    
    # 先终止旧进程
    xcrun simctl terminate "$UDID" "$BUNDLE_ID" 2>/dev/null || true
    
    # 启动 app（传 -WatchPage home 强制显示首页）
    xcrun simctl launch "$UDID" "$BUNDLE_ID" -AppleLanguages "($lang_code)" -AppleLocale "$lang_code" -WatchPage home 2>/dev/null
    
    # 等待渲染
    sleep 3
    
    # 截图
    mkdir -p "$OUTPUT_BASE/$dir_name"
    xcrun simctl io "$UDID" screenshot "$OUTPUT_BASE/$dir_name/01_Home.png" 2>/dev/null
    
    sleep 1
done

echo ""
echo "完成！已截图 ${#languages[@]} 个语言的首页"
echo "输出目录: $OUTPUT_BASE"
