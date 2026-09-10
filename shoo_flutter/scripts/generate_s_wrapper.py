#!/usr/bin/env python3
"""
从解析好的 JSON 生成兼容层 app_localizations.dart。
提供 S.of(context).xxx 接口，委托给 Flutter 生成的 AppLocalizations。
"""
import json
import os

def load_parsed():
    with open('scripts/_localizations_parsed.json', 'r', encoding='utf-8') as f:
        return json.load(f)

def generate_wrapper(data, output_path='lib/l10n/app_localizations.dart'):
    translations = data['translations']
    keys = list(translations.keys())
    
    lines = []
    lines.append("import 'dart:async' show Future;")
    lines.append("import 'package:flutter/widgets.dart';")
    lines.append("import 'generated/app_localizations.dart';")
    lines.append("")
    lines.append("/// 兼容层：委托给 Flutter 生成的 AppLocalizations")
    lines.append("class S {")
    lines.append("  final AppLocalizations _l10n;")
    lines.append("  S(this._l10n);")
    lines.append("")
    lines.append("  static S of(BuildContext context) {")
    lines.append("    return S(AppLocalizations.of(context)!);")
    lines.append("  }")
    lines.append("")
    lines.append("  static const LocalizationsDelegate<S> delegate = _SDelegate();")
    lines.append("")
    lines.append("  static const List<Locale> supportedLocales = [")
    
    # 收集所有 locale（从 en 的 @@locale 中获取更简单，这里从 lang_codes 构建）
    locale_data = _build_locale_list(data['lang_codes'])
    for locale_str in locale_data:
        lines.append(f"    {locale_str},")
    
    lines.append("  ];")
    lines.append("")
    lines.append("  static const List<String> supportedLanguageCodes = [")
    for lang in data['lang_codes']:
        lines.append(f"    '{lang}',")
    lines.append("  ];")
    lines.append("")
    
    # nativeLanguageNames - 从原始文件导入
    lines.append("  /// 语言名称（委托给 Flutter 生成）")
    lines.append("  static String nativeLanguageName(String code) =>")
    lines.append("      AppLocalizations.supportedLocales")
    lines.append("          .firstWhere((l) => l.languageCode == code,")
    lines.append("              orElse: () => const Locale('en'))")
    lines.append("          .toLanguageTag();")
    lines.append("")
    
    # 生成所有 getter
    for key in keys:
        lines.append(f"  String get {key} => _l10n.{key};")
    
    lines.append("}")
    lines.append("")
    lines.append("/// Delegate：加载 AppLocalizations 并包装为 S")
    lines.append("class _SDelegate extends LocalizationsDelegate<S> {")
    lines.append("  const _SDelegate();")
    lines.append("")
    lines.append("  @override")
    lines.append("  Future<S> load(Locale locale) async {")
    lines.append("    final l10n = await AppLocalizations.delegate.load(locale);")
    lines.append("    return S(l10n);")
    lines.append("  }")
    lines.append("")
    lines.append("  @override")
    lines.append("  bool isSupported(Locale locale) => AppLocalizations.delegate.isSupported(locale);")
    lines.append("")
    lines.append("  @override")
    lines.append("  bool shouldReload(_SDelegate old) => false;")
    lines.append("}")
    
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write('\n'.join(lines) + '\n')
    
    print(f"✓ 已生成 {output_path}")
    print(f"  包含 {len(keys)} 个 getter")

def _build_locale_list(lang_codes):
    """从语言代码列表构建 Locale() 调用列表"""
    locales = []
    for code in lang_codes:
        if '_' in code and len(code) == 5:  # zh_TW, en_US 等
            parts = code.split('_')
            locales.append(f"Locale('{parts[0]}', '{parts[1]}')")
        else:
            locales.append(f"Locale('{code}')")
    return locales

def main():
    data = load_parsed()
    generate_wrapper(data)

if __name__ == '__main__':
    main()
