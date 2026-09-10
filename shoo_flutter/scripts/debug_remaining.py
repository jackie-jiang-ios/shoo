#!/usr/bin/env python3
import json, os, re

DEEPSEEK_DIR = '/Users/jiangzheng/Project/iOS/Shoo/翻译结果deepseek'

# Load all deepseek translations
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

# Check what deepseek has for the problematic English texts
problematic = ['Stop', 'Pause', 'Timer', 'Start', 'Feedback', 'Metal', 'Output', 'Pro']
langs = ['hi', 'da', 'fi', 'hr', 'mr', 'ml', 'pa', 'sv', 'sk', 'sl', 'te', 'ta', 'ur', 'el', 'hu']

for en_text in problematic:
    print(f'\nEnglish: "{en_text}"')
    for lang in langs:
        if lang in translations and en_text in translations[lang]:
            trans = translations[lang][en_text]
            same = "SAME" if trans == en_text else ""
            print(f'  {lang}: "{trans}" {same}')
        else:
            print(f'  {lang}: NOT IN DEEPSEEK')
