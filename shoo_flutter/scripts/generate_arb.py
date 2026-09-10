#!/usr/bin/env python3
"""
从解析好的 JSON 生成 .arb 文件（Flutter 标准格式）。
一个语言一个文件，放在 lib/l10n/ 目录下。
"""
import json
import os
import sys

def load_parsed():
    with open('scripts/_localizations_parsed.json', 'r', encoding='utf-8') as f:
        return json.load(f)

def generate_arb_files(data, output_dir='lib/l10n'):
    lang_codes = data['lang_codes']
    translations = data['translations']
    
    # 确保输出目录存在
    os.makedirs(output_dir, exist_ok=True)
    
    # Flutter ARB locale 名称映射（有些语言代码需要转换）
    # Flutter 用下划线: zh_TW, en_AU 等，保持原样即可
    locale_map = {
        'zh_TW': 'zh_TW',
        'fr_CA': 'fr_CA',
        'es_MX': 'es_MX',
        'en_AU': 'en_AU',
        'en_CA': 'en_CA',
        'en_GB': 'en_GB',
    }
    
    # 生成的文件列表
    generated = []
    
    for lang in lang_codes:
        locale = locale_map.get(lang, lang)
        
        arb_data = {
            "@@locale": locale
        }
        
        # 添加所有翻译
        for key, langs in translations.items():
            if lang in langs:
                arb_data[key] = langs[lang]
        
        # 写入文件
        filename = f'app_{locale}.arb'
        filepath = os.path.join(output_dir, filename)
        
        with open(filepath, 'w', encoding='utf-8') as f:
            json.dump(arb_data, f, ensure_ascii=False, indent=2)
        
        generated.append(filename)
        print(f"  ✓ {filename} ({len(translations)} keys)")
    
    # 同时生成一个 locale_list.txt 方便查看
    list_path = os.path.join(output_dir, '_locales.txt')
    with open(list_path, 'w', encoding='utf-8') as f:
        for g in generated:
            f.write(g + '\n')
    
    print(f"\n共生成 {len(generated)} 个 .arb 文件到 {output_dir}/")

def main():
    data = load_parsed()
    generate_arb_files(data)

if __name__ == '__main__':
    main()
