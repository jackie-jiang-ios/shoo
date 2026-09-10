#!/usr/bin/env python3
"""检查 app_localizations.dart 中哪些语言有未翻译的字符串（值与英文相同）"""

import re

with open('../lib/l10n/app_localizations.dart', 'r') as f:
    content = f.read()

# All language codes
lang_codes = ['zh', 'zh_TW', 'en', 'ja', 'ko', 'fr', 'de', 'es', 'ru', 'pt', 'th',
    'ar', 'id', 'it', 'ms', 'nl', 'pl', 'tr', 'vi',
    'hi', 'da', 'fr_CA', 'fi', 'gu', 'ca', 'cs', 'kn', 'hr', 'ro',
    'mr', 'ml', 'bn', 'no', 'pa', 'sv', 'sk', 'sl', 'te', 'ta',
    'ur', 'uk', 'es_MX', 'he', 'el', 'hu', 'en_AU', 'en_CA', 'en_GB']

non_en = [l for l in lang_codes if l not in ('en', 'en_AU', 'en_CA', 'en_GB')]

# Find all getters and their translation maps
pattern = r"String get (\w+) => _t\(const \{([^}]+)\}\)"
matches = re.findall(pattern, content)

results = []
for getter_name, map_body in matches:
    entry_pattern = r"'([^']+)':\s*'((?:[^'\\]|\\.)*)'"
    entries = re.findall(entry_pattern, map_body)
    trans = {k: v for k, v in entries}
    
    en_val = trans.get('en', '')
    if not en_val:
        continue
    
    # Find non-English langs that have same value as English (likely untranslated)
    untranslated = []
    for lang in non_en:
        val = trans.get(lang, '')
        if val == en_val and val != '':
            untranslated.append(lang)
    
    if untranslated:
        results.append((getter_name, en_val, untranslated))

results.sort(key=lambda x: x[0])

# Summary by language
lang_issues = {}
for getter_name, en_val, langs in results:
    for lang in langs:
        if lang not in lang_issues:
            lang_issues[lang] = []
        lang_issues[lang].append((getter_name, en_val))

print(f"=== 共发现 {len(results)} 个字符串有遗漏 ===\n")
for getter_name, en_val, langs in results:
    print(f'  {getter_name:30s} "{en_val:25s}" -> {", ".join(langs)}')

print(f"\n=== 按语言汇总（共 {len(lang_issues)} 种语言有遗漏） ===\n")
for lang in sorted(lang_issues.keys()):
    items = lang_issues[lang]
    print(f'{lang}: {len(items)} 个未翻译')
    for gname, en_val in items[:5]:
        print(f'    {gname} = "{en_val}"')
    if len(items) > 5:
        print(f'    ... 还有 {len(items)-5} 个')
