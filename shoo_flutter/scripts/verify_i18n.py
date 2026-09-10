#!/usr/bin/env python3
"""验证 app_localizations.dart 中每种语言的翻译完整性"""

import re
import os

# 读取翻译参考文件
translation_dir = "/Users/jiangzheng/Project/iOS/Shoo/翻译结果deepseek"
files = ['8结果.txt', '8-2结果.txt', '8-3.txt', '8-4.txt', '8-5.txt', '8-6.txt']
import json

all_translations = {}
for f in files:
    filepath = os.path.join(translation_dir, f)
    with open(filepath, 'r', encoding='utf-8') as fp:
        data = json.loads(fp.read())
        for lang, translations in data.items():
            if lang not in all_translations:
                all_translations[lang] = translations
            else:
                all_translations[lang].update(translations)

# 读取 app_localizations.dart
dart_file = "/Users/jiangzheng/Project/iOS/Shoo/shoo_flutter/lib/l10n/app_localizations.dart"
with open(dart_file, 'r', encoding='utf-8') as f:
    content = f.read()

# 提取所有 getter 方法及其中的翻译 Map
# 匹配模式：String get xxx => _t(const { ... });
getter_pattern = re.compile(r"String\s+get\s+(\w+)\s*=>\s*_t\(const\s+\{([^}]+)\}\)", re.DOTALL)

# 语言代码正则
lang_pattern = re.compile(r"'([a-zA-Z_]{2,7})':")

# 支持的语言列表
supported_langs = [
    'zh', 'zh_TW', 'en', 'en_AU', 'en_CA', 'en_GB',
    'ja', 'ko', 'fr', 'fr_CA', 'de', 'es', 'es_MX',
    'ru', 'pt', 'th', 'ar', 'id', 'it', 'ms', 'nl', 'pl', 'tr', 'vi',
    'hi', 'da', 'fi', 'gu', 'ca', 'cs', 'kn', 'hr', 'ro',
    'mr', 'ml', 'bn', 'no', 'pa', 'sv', 'sk', 'sl', 'te', 'ta',
    'ur', 'uk', 'he', 'el', 'hu'
]

# 分析每个 getter
getters = list(getter_pattern.finditer(content))
print(f"总共 {len(getters)} 个 getter 方法")
print()

# 统计每个语言在多少个 getter 中缺失
missing_count = {lang: 0 for lang in supported_langs}
missing_details = {lang: [] for lang in supported_langs}

for match in getters:
    getter_name = match.group(1)
    map_content = match.group(2)
    langs_in_map = set(lang_pattern.findall(map_content))
    
    for lang in supported_langs:
        if lang not in langs_in_map:
            missing_count[lang] += 1
            missing_details[lang].append(getter_name)

print("=== 各语言缺失的 getter 数量 ===")
print()
has_missing = False
for lang in supported_langs:
    count = missing_count[lang]
    if count > 0:
        has_missing = True
        print(f"  {lang}: 缺失 {count} 个 getter 的翻译")
        # 只显示前5个缺失的getter名称
        if count <= 10:
            for g in missing_details[lang][:10]:
                print(f"    - {g}")
        else:
            for g in missing_details[lang][:5]:
                print(f"    - {g}")
            print(f"    ... 还有 {count-5} 个")

if not has_missing:
    print("  ✅ 所有语言在所有 getter 中都有翻译！")

print()

# 检查是否所有48种语言都存在
print("=== 48种语言是否都覆盖 ===")
for lang in supported_langs:
    if missing_count[lang] == len(getters):
        print(f"  ❌ {lang}: 完全缺失（没有任何翻译）")
    elif missing_count[lang] > 0:
        print(f"  ⚠️  {lang}: 部分缺失（{missing_count[lang]}/{len(getters)}）")
    else:
        print(f"  ✅ {lang}: 完整")

print()
print(f"翻译参考文件语言数: {len(all_translations)}")
print(f"  - 参考文件包含: {sorted(all_translations.keys())}")
