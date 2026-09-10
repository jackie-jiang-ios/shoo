#!/usr/bin/env python3
import json, os

DEEPSEEK_DIR = '/Users/jiangzheng/Project/iOS/Shoo/翻译结果deepseek'

# Print first 10 keys from deepseek 'hi'
for fname in sorted(os.listdir(DEEPSEEK_DIR)):
    if not fname.endswith('.txt'):
        continue
    with open(os.path.join(DEEPSEEK_DIR, fname), 'r') as f:
        content = f.read().strip().lstrip('\ufeff')
    try:
        data = json.loads(content)
    except:
        continue
    if 'hi' in data:
        keys = list(data['hi'].keys())[:10]
        print(f'File: {fname}')
        print(f'hi keys (first 10):')
        for k in keys:
            print(f'  "{k}" -> "{data["hi"][k]}"')
        break

# Also check what English values look like in the dart file
DART_FILE = '/Users/jiangzheng/Project/iOS/Shoo/shoo_flutter/lib/l10n/app_localizations.dart'
import re
with open(DART_FILE, 'r') as f:
    dart = f.read()

# Get 'confirm' getter
match = re.search(r"String get confirm => _t\(const \{(.*?)\n\s*\}\);", dart, re.DOTALL)
if match:
    body = match.group(1)
    en = re.search(r"'en': '((?:[^'\\]|\\.)*)'", body)
    hi = re.search(r"'hi': '((?:[^'\\]|\\.)*)'", body)
    print(f'\nDart "confirm" getter:')
    if en: print(f'  en: "{en.group(1)}"')
    if hi: print(f'  hi: "{hi.group(1)}"')
