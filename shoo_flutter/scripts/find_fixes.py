#!/usr/bin/env python3
"""找出 fr_CA、it、tr 缺失的翻译，从翻译文件中提取"""

import json
import os
import re

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

# 缺失的 getter 对应的英文 key
missing_keys = {
    'fr_CA': {
        'intervalTime': 'Interval Time',
        'noInterval': 'No interval',
        'noAutoStop': 'No auto stop',
        'keepScreenOn': 'Keep Screen On',
        'termsOfService': 'Terms of Service',
        'iconStyle': 'Icon Style',
        'generatingWaveform': 'Generating waveform',
        'waveformPreview': 'Waveform Preview',
        'waveformPlayingDesc': 'Wave motion stays active during playback so the output feels easier to read.',
        'waveformStaticDesc': 'The preview stays static when idle and animates during playback.',
    },
    'it': {
        'generatingWaveform': 'Generating waveform',
        'waveformPreview': 'Waveform Preview',
        'waveformPlayingDesc': 'Wave motion stays active during playback so the output feels easier to read.',
        'waveformStaticDesc': 'The preview stays static when idle and animates during playback.',
        'remotePlayDesc': 'Select and play sounds on watch',
        'hapticFeedbackDesc': 'Watch vibrates during playback',
        'watchDisconnectedHint': 'Make sure watch is paired and near phone',
    },
    'tr': {
        'upgradeToPro': 'Upgrade to Pro',
        'unlockPro': 'Unlock Pro',
    }
}

# 从翻译文件中提取对应的翻译
for lang, getters in missing_keys.items():
    print(f"=== {lang} 需要补充的翻译 ===")
    lang_trans = all_translations.get(lang, {})
    for getter_name, en_key in getters.items():
        value = lang_trans.get(en_key, 'NOT FOUND')
        print(f"  {getter_name}: {value}")
    print()
