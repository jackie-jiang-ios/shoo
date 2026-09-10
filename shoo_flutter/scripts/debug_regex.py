#!/usr/bin/env python3
"""调试正则匹配问题"""

import re

dart_file = "/Users/jiangzheng/Project/iOS/Shoo/shoo_flutter/lib/l10n/app_localizations.dart"
with open(dart_file, 'r', encoding='utf-8') as f:
    content = f.read()

# 测试 intervalTime 的匹配
getter_pattern = re.compile(r"String\s+get\s+(\w+)\s*=>\s*_t\(const\s+\{(.*?)\}\)", re.DOTALL)

matches = list(getter_pattern.finditer(content))
print(f"匹配到 {len(matches)} 个 getter")

# 找到 intervalTime
for i, match in enumerate(matches):
    if match.group(1) == 'intervalTime':
        print(f"\n=== intervalTime (第 {i} 个匹配) ===")
        map_content = match.group(2)
        print(f"Map 内容:\n{map_content}")
        
        # 检查 fr_CA 是否在匹配到的内容中
        if 'fr_CA' in map_content:
            print("\n✓ fr_CA 在匹配内容中")
        else:
            print("\n✗ fr_CA 不在匹配内容中")
        
        # 找到 fr_CA 在原始内容中的位置
        fr_ca_pos = content.find("'fr_CA':")
        if fr_ca_pos == -1:
            fr_ca_pos = content.find("'fr_CA':")
        print(f"'fr_CA' 在文件中的位置: {fr_ca_pos}")
        print(f"intervalTime 匹配的起始位置: {match.start()}")
        print(f"intervalTime 匹配的结束位置: {match.end()}")
        
        # 检查之前的 getter 的结束位置是否正确
        if i > 0:
            prev = matches[i-1]
            print(f"\n前一个 getter: {prev.group(1)}, 结束位置: {prev.end()}")
            print(f"中间内容: [{content[prev.end():match.start()][:100]}]")
        break

# 检查是否有嵌套的 } 导致提前匹配
print("\n\n=== 检查 intervalTime 附近的 } 情况 ===")
# 找 intervalTime 附近的第一个 }
it_start = content.find("String get intervalTime")
if it_start != -1:
    # 从后往前找到 _t(const {
    const_start = content.rfind("_t(const {", it_start - 200, it_start + 100)
    print(f"_t(const {{ 位置: {const_start}")
    
    # 找匹配的 }
    depth = 0
    for i in range(const_start, len(content)):
        if content[i] == '{':
            depth += 1
        elif content[i] == '}':
            depth -= 1
            if depth == 0:
                print(f"匹配的 }} 位置: {i}")
                print(f"中间内容:\n{content[const_start:i+1]}")
                break
