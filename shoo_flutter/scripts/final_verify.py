#!/usr/bin/env python3
"""Final verification - classify remaining issues."""
import json, os, re

DEEPSEEK_DIR = '/Users/jiangzheng/Project/iOS/Shoo/翻译结果deepseek'
DART_FILE = '/Users/jiangzheng/Project/iOS/Shoo/shoo_flutter/lib/l10n/app_localizations.dart'

# Load deepseek
translations = {}
for fname in sorted(os.listdir(DEEPSEEK_DIR)):
    if not fname.endswith('.txt'):
        continue
    with open(os.path.join(DEEPSEEK_DIR, fname), 'r') as f:
        content = f.read().strip().lstrip('\ufeff')
    try:
        data = json.loads(content)
    except:
        continue
    for lang, trans in data.items():
        if lang not in translations:
            translations[lang] = {}
        translations[lang].update(trans)

LANGUAGES = ['hi', 'da', 'fi', 'hr', 'mr', 'ml', 'pa', 'sv', 'sk', 'sl', 'te', 'ta', 'ur', 'el', 'hu']

with open(DART_FILE, 'r') as f:
    dart = f.read()

pattern = r"String get (\w+) => _t\(const \{(.*?)\n\s*\}\);"

pro_issues = 0  # Pro brand name (intentional)
no_translation = 0  # deepseek didn't translate this
real_issues = 0

for match in re.finditer(pattern, dart, flags=re.DOTALL):
    body = match.group(2)
    name = match.group(1)
    en = re.search(r"'en': '((?:[^'\\]|\\.)*)'", body)
    if not en:
        continue
    en_val = en.group(1)

    for lang in LANGUAGES:
        lang_match = re.search(rf"'{lang}': '((?:[^'\\]|\\.)*)'", body)
        if lang_match and lang_match.group(1) == en_val:
            # Still English - check why
            if en_val == "Pro" or name in ("shooPro", "pro"):
                pro_issues += 1
            elif lang in translations and en_val in translations[lang] and translations[lang][en_val] == en_val:
                no_translation += 1  # Deepseek didn't translate this either
            else:
                real_issues += 1
                if real_issues <= 10:
                    print(f'REAL ISSUE: {name}.{lang} = "{en_val[:50]}"')

print(f'\nSummary:')
print(f'  Pro/brand (intentional): {pro_issues}')
print(f'  Deepseek also kept English: {no_translation}')
print(f'  Real missing translations: {real_issues}')
