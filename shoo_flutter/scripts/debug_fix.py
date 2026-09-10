#!/usr/bin/env python3
"""Check what the fix actually did."""
import re

DART_FILE = '/Users/jiangzheng/Project/iOS/Shoo/shoo_flutter/lib/l10n/app_localizations.dart'

with open(DART_FILE, 'r') as f:
    content = f.read()

# Count how many 'hi' entries have translated values vs English
pattern = r"String get (\w+) => _t\(const \{(.*?)\n\s*\}\);"
translated = 0
still_english = 0
missing = 0

for match in re.finditer(pattern, content, flags=re.DOTALL):
    body = match.group(2)
    en = re.search(r"'en': '((?:[^'\\]|\\.)*)'", body)
    if not en:
        continue
    en_val = en.group(1)

    hi = re.search(r"'hi': '((?:[^'\\]|\\.)*)'", body)
    if hi:
        if hi.group(1) == en_val:
            still_english += 1
        else:
            translated += 1
    else:
        missing += 1

print(f'hi: translated={translated}, still_english={still_english}, missing={missing}')
print(f'Total getters: {translated + still_english + missing}')

# Show a few examples of translated ones
count = 0
for match in re.finditer(pattern, content, flags=re.DOTALL):
    body = match.group(2)
    name = match.group(1)
    en = re.search(r"'en': '((?:[^'\\]|\\.)*)'", body)
    if not en:
        continue
    en_val = en.group(1)
    hi = re.search(r"'hi': '((?:[^'\\]|\\.)*)'", body)
    if hi and hi.group(1) != en_val:
        print(f'  {name}: en="{en_val[:40]}" hi="{hi.group(1)[:40]}"')
        count += 1
        if count >= 5:
            break
