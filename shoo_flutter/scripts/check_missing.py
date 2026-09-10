#!/usr/bin/env python3
"""检查翻译文件中是否包含特定 key"""

import json
import os

# 读取翻译文件
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

# 检查 fr_CA 和 it 的缺失 keys
check_keys = [
    'Interval Time', 'No interval', 'No auto stop', 'Keep Screen On',
    'Terms of Service', 'Icon Style', 'Generating waveform', 'Waveform Preview',
    'Wave motion stays active during playback so the output feels easier to read.',
    'The preview stays static when idle and animates during playback.',
    'Remote Play description', 'Haptic feedback description', 'Watch disconnected hint',
    'Upgrade to Pro', 'Unlock Pro'
]

print("=== fr_CA 在翻译文件中的 key 数:", len(all_translations.get('fr_CA', {})))
print("=== it 在翻译文件中的 key 数:", len(all_translations.get('it', {})))
print("=== tr 在翻译文件中的 key 数:", len(all_translations.get('tr', {})))
print()

# 检查英文中有哪些 key
en_keys = set(all_translations['en'].keys())
print("=== 英文 key 列表 (162个) ===")
for k in en_keys:
    print(f"  {k}")

print()

# 检查缺失的 getter 对应什么 key
# 看看 fr_CA 有哪些 key 是英文文件中有的
print("=== fr_CA 缺失的 key (en中有) ===")
fr_ca_keys = set(all_translations.get('fr_CA', {}).keys())
for k in en_keys:
    if k not in fr_ca_keys:
        print(f"  {k}")

print()
print("=== it 缺失的 key (en中有) ===")
it_keys = set(all_translations.get('it', {}).keys())
for k in en_keys:
    if k not in it_keys:
        print(f"  {k}")

print()
print("=== tr 缺失的 key (en中有) ===")
tr_keys = set(all_translations.get('tr', {}).keys())
for k in en_keys:
    if k not in tr_keys:
        print(f"  {k}")
