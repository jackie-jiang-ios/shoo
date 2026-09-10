#!/usr/bin/env python3
"""更精确的验证：仅匹配翻译 Map 的 key（每行第一个 'xx': 模式）"""

import re
import os
import json

# 读取翻译参考文件
translation_dir = "/Users/jiangzheng/Project/iOS/Shoo/翻译结果deepseek"
files = ['8结果.txt', '8-2结果.txt', '8-3.txt', '8-4.txt', '8-5.txt', '8-6.txt']

all_translations = {}
for f in files:
    filepath = os.path.join(translation_dir, f)
    with open(filepath, 'r', encoding='utf-8') as fp:
        data = json.loads(fp.read())
        for lang, translations in data.items():
            if lang not in all_translations:
                all_translations[lang] = translations

# 读取 app_localizations.dart
dart_file = "/Users/jiangzheng/Project/iOS/Shoo/shoo_flutter/lib/l10n/app_localizations.dart"
with open(dart_file, 'r', encoding='utf-8') as f:
    content = f.read()

# 更精确地匹配 getter 中的语言 key
# 每个 getter 的结构是：
#   'xx': 'value', 'yy': 'value', ...
# 我们只匹配行首的 'xx': 模式，且是作为 key 出现的

supported_langs = [
    'zh', 'zh_TW', 'en', 'en_AU', 'en_CA', 'en_GB',
    'ja', 'ko', 'fr', 'fr_CA', 'de', 'es', 'es_MX',
    'ru', 'pt', 'th', 'ar', 'id', 'it', 'ms', 'nl', 'pl', 'tr', 'vi',
    'hi', 'da', 'fi', 'gu', 'ca', 'cs', 'kn', 'hr', 'ro',
    'mr', 'ml', 'bn', 'no', 'pa', 'sv', 'sk', 'sl', 'te', 'ta',
    'ur', 'uk', 'he', 'el', 'hu'
]

# 找到每个 getter 的 Map 块
# 按 _t(const { ... }) 分割
getter_pattern = re.compile(r"String\s+get\s+(\w+)\s*=>\s*_t\(const\s+\{(.*?)\}\)", re.DOTALL)
lang_key_pattern = re.compile(r"""['"]([a-zA-Z_]{2,7})['"]:""")

missing_count = {lang: 0 for lang in supported_langs}
missing_details = {lang: [] for lang in supported_langs}

for match in getter_pattern.finditer(content):
    getter_name = match.group(1)
    map_content = match.group(2)
    
    # 只匹配作为 key 的语言代码（'xx': 格式）
    langs_in_map = set(lang_key_pattern.findall(map_content))
    
    # 验证：只保留支持的语言
    langs_in_map = langs_in_map & set(supported_langs)
    
    for lang in supported_langs:
        if lang not in langs_in_map:
            missing_count[lang] += 1
            missing_details[lang].append(getter_name)

total_getters = len(list(getter_pattern.finditer(content)))
print(f"总共 {total_getters} 个 getter 方法")
print()

print("=== 各语言缺失的 getter 数量 ===")
print()
has_missing = False
for lang in supported_langs:
    count = missing_count[lang]
    if count > 0:
        has_missing = True
        print(f"  {lang}: 缺失 {count} 个 getter")
        details = missing_details[lang]
        if len(details) <= 10:
            print(f"    {details}")
        else:
            print(f"    {details[:5]} ... 还有 {len(details)-5} 个")

if not has_missing:
    print("  所有语言全部完整！")

# 额外验证：比较翻译文件中的 key 种类 vs 代码中的 getter 数量
print()
print("=== 额外信息 ===")
print(f"翻译文件每语言key数: {len(all_translations['en'])}")
print(f"代码getter数: {total_getters}")
print(f"差值: {total_getters - len(all_translations['en'])} (代码比翻译文件多 {total_getters - len(all_translations['en'])} 个getter)")

# 看看哪些 getter 在翻译文件中没有对应的 key
print()
print("=== 翻译文件中缺少对应 key 的 getter ===")
en_keys = set(all_translations['en'].keys())
missing_key_getters = []
for match in getter_pattern.finditer(content):
    getter_name = match.group(1)
    map_content = match.group(2)
    en_match = re.search(r"'en':\s*'([^']*)'", map_content)
    if en_match:
        en_value = en_match.group(1)
        if en_value not in en_keys:
            missing_key_getters.append((getter_name, en_value))
    else:
        missing_key_getters.append((getter_name, 'NO EN VALUE'))

if missing_key_getters:
    for name, val in missing_key_getters:
        print(f"  {name}: '{val}' -> 翻译文件中没有这个key")
else:
    print("  所有 getter 的英文值在翻译文件中都有对应 key")
