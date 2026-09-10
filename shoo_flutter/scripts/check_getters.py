#!/usr/bin/env python3
"""检查 app_localizations.dart 中 fr_CA、it、tr 缺失的 getter 对应什么内容"""

import re
import os

# 读取 app_localizations.dart
dart_file = "/Users/jiangzheng/Project/iOS/Shoo/shoo_flutter/lib/l10n/app_localizations.dart"
with open(dart_file, 'r', encoding='utf-8') as f:
    content = f.read()

# 提取所有 getter 方法
getter_pattern = re.compile(r"String\s+get\s+(\w+)\s*=>\s*_t\(const\s+\{([^}]+)\}\)", re.DOTALL)
lang_pattern = re.compile(r"'([a-zA-Z_]{2,7})':")

# 缺失的 getter
missing_getters = {
    'fr_CA': ['intervalTime', 'noInterval', 'noAutoStop', 'keepScreenOn', 'termsOfService', 'iconStyle', 'generatingWaveform', 'waveformPreview', 'waveformPlayingDesc', 'waveformStaticDesc'],
    'it': ['generatingWaveform', 'waveformPreview', 'waveformPlayingDesc', 'waveformStaticDesc', 'remotePlayDesc', 'hapticFeedbackDesc', 'watchDisconnectedHint'],
    'tr': ['upgradeToPro', 'unlockPro']
}

# 所有 getter
getters = list(getter_pattern.finditer(content))

# 找到缺失 getter 的完整定义
for lang, names in missing_getters.items():
    print(f"=== {lang} 缺失的 getter ===")
    for name in names:
        for match in getters:
            if match.group(1) == name:
                map_content = match.group(2)
                langs_in_map = set(lang_pattern.findall(map_content))
                if lang not in langs_in_map:
                    print(f"\n--- {name} ---")
                    # 显示内容片段
                    for line in map_content.split('\n')[:5]:
                        print(f"  {line.strip()}")
                    if len(map_content.split('\n')) > 5:
                        print(f"  ...")
                break
    print()
