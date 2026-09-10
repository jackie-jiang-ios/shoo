#!/usr/bin/env python3
"""Verify that translations are properly fixed."""
import re

DART_FILE = '/Users/jiangzheng/Project/iOS/Shoo/shoo_flutter/lib/l10n/app_localizations.dart'

with open(DART_FILE, 'r') as f:
    content = f.read()

LANGUAGES = ['hi', 'da', 'fi', 'hr', 'mr', 'ml', 'pa', 'sv', 'sk', 'sl', 'te', 'ta', 'ur', 'el', 'hu']

total_getters = 0
issues = []

pattern = r"String get (\w+) => _t\(const \{(.*?)\n\s*\}\);"
for match in re.finditer(pattern, content, flags=re.DOTALL):
    getter = match.group(1)
    body = match.group(2)
    total_getters += 1

    en_match = re.search(r"'en': '((?:[^'\\]|\\.)*)'", body)
    if not en_match:
        en_match = re.search(r"'en_AU': '((?:[^'\\]|\\.)*)'", body)
    if not en_match:
        continue
    en_val = en_match.group(1)

    for lang in LANGUAGES:
        lang_match = re.search(rf"'{lang}': '((?:[^'\\]|\\.)*)'", body)
        if lang_match:
            lang_val = lang_match.group(1)
            if lang_val == en_val:
                issues.append(f'{getter}.{lang}: still English ({en_val[:50]})')
        else:
            issues.append(f'{getter}.{lang}: MISSING')

print(f'Total getters: {total_getters}')
print(f'Remaining issues: {len(issues)}')
for i in issues[:30]:
    print(f'  {i}')
if len(issues) > 30:
    print(f'  ... and {len(issues)-30} more')
