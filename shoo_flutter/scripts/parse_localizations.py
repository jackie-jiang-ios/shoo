#!/usr/bin/env python3
"""
从 app_localizations.dart 解析所有 getter 和翻译，输出为 JSON。
为后续生成 .arb 文件做准备。
"""
import re
import json
import sys

def parse_translations(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # 找到所有 getter 定义
    # 格式: String get xxx => _t(const { ... });
    pattern = r'String get (\w+) => _t\(const \{(.*?)\}\);'
    matches = re.findall(pattern, content, re.DOTALL)
    
    translations = {}  # key -> {lang: value}
    lang_codes = []
    
    for getter_name, map_content in matches:
        translations[getter_name] = {}
        
        # 解析 map 条目: 'lang': 'value',
        entry_pattern = r"'([^']+)':\s*'((?:[^'\\]|\\.)*)'"
        entries = re.findall(entry_pattern, map_content)
        
        for lang, value in entries:
            #反转义
            value = value.replace("\\'", "'")
            translations[getter_name][lang] = value
            if lang not in lang_codes:
                lang_codes.append(lang)
    
    return translations, lang_codes

def main():
    filepath = sys.argv[1] if len(sys.argv) > 1 else 'lib/l10n/app_localizations.dart'
    translations, lang_codes = parse_translations(filepath)
    
    print(f"共找到 {len(translations)} 个翻译键, {len(lang_codes)} 种语言")
    print(f"语言代码: {lang_codes}")
    print()
    
    # 输出为 JSON
    output = {
        'lang_codes': lang_codes,
        'translations': translations
    }
    
    output_path = 'scripts/_localizations_parsed.json'
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(output, f, ensure_ascii=False, indent=2)
    
    print(f"已保存到 {output_path}")
    
    # 打印前几个作为示例
    print("\n示例 - 前5个 key:")
    for key in list(translations.keys())[:5]:
        print(f"  {key}: {translations[key].get('en', 'N/A')[:50]}")

if __name__ == '__main__':
    main()
