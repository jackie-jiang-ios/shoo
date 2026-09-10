#!/usr/bin/env python3
"""Fix missing translations in app_localizations.dart using deepseek translation results.
Replaces English fallback values with proper translations for languages that were not fully translated.
"""
import json
import re
import os
import shutil

DART_FILE = '/Users/jiangzheng/Project/iOS/Shoo/shoo_flutter/lib/l10n/app_localizations.dart'
DEEPSEEK_DIR = '/Users/jiangzheng/Project/iOS/Shoo/翻译结果deepseek'
BACKUP_FILE = DART_FILE + '.bak'

# Languages that need fixing (identified as having English fallbacks)
LANGUAGES_TO_FIX = ['hi', 'da', 'fi', 'hr', 'mr', 'ml', 'pa', 'sv', 'sk', 'sl', 'te', 'ta', 'ur', 'el', 'hu']


def load_deepseek_translations():
    """Load all deepseek translation files and return {lang_code: {en_text: translated_text}}"""
    translations = {}

    for fname in sorted(os.listdir(DEEPSEEK_DIR)):
        if not fname.endswith('.txt'):
            continue
        fpath = os.path.join(DEEPSEEK_DIR, fname)
        with open(fpath, 'r', encoding='utf-8') as f:
            content = f.read()

        content = content.strip().lstrip('\ufeff')

        try:
            data = json.loads(content)
        except json.JSONDecodeError:
            fixed = re.sub(r',\s*}', '}', content)
            fixed = re.sub(r',\s*]', ']', fixed)
            try:
                data = json.loads(fixed)
            except json.JSONDecodeError as e:
                print(f"  Warning: Skipping {fname}: {e}")
                continue

        for lang_code, trans_map in data.items():
            if lang_code not in translations:
                translations[lang_code] = {}
            translations[lang_code].update(trans_map)

    return translations


def parse_dart_getters(content):
    """Parse dart file and return list of (getter_name, body, start_pos, end_pos, full_match)"""
    pattern = r"String get (\w+) => _t\(const \{(.*?)\n\s*\}\);"
    results = []
    for match in re.finditer(pattern, content, flags=re.DOTALL):
        getter_name = match.group(1)
        body = match.group(2)
        results.append((getter_name, body, match.start(), match.end(), match.group(0)))
    return results


def get_english_value(body):
    """Extract the English translation value from a getter body."""
    for key in ['en', 'en_AU', 'en_CA', 'en_GB']:
        match = re.search(rf"'{key}': '((?:[^'\\]|\\.)*)'", body)
        if match:
            return match.group(1)
    return None


def get_current_value(body, lang_code):
    """Get the current value for a language code from the body."""
    match = re.search(rf"'{lang_code}': '((?:[^'\\]|\\.)*)'", body)
    if match:
        return match.group(1)
    return None


def fix_getter_body(body, lang_code, en_to_trans):
    """Fix a single getter body by replacing English fallbacks with deepseek translations."""
    en_text = get_english_value(body)
    if not en_text:
        return body, 0

    current_value = get_current_value(body, lang_code)
    deepseek_value = en_to_trans.get(en_text)

    if not deepseek_value:
        return body, 0

    # If already has proper translation (not English fallback), skip
    if current_value is not None and current_value != en_text:
        return body, 0

    # If the deepseek "translation" is same as English, skip
    if deepseek_value == en_text:
        return body, 0

    # This entry needs fixing
    escaped_value = deepseek_value.replace("'", r"\'")

    if current_value is not None:
        # Replace existing English fallback value
        pattern = rf"('{lang_code}': ')(?:[^'\\]|\\.)*(')"
        new_body = re.sub(pattern, rf"\g<1>{escaped_value}\2", body, count=1)
    else:
        # Add new entry - find the last entry and add after it
        lines = body.split('\n')
        last_entry_idx = -1
        for i in range(len(lines) - 1, -1, -1):
            line_stripped = lines[i].strip()
            if "'" in lines[i] and ':' in lines[i] and not line_stripped.startswith('//'):
                last_entry_idx = i
                break

        if last_entry_idx >= 0:
            indent = '    '
            lines.insert(last_entry_idx + 1, f"{indent}'{lang_code}': '{escaped_value}',")
            new_body = '\n'.join(lines)
        else:
            return body, 0

    return new_body, 1


def main():
    print("Loading deepseek translations...")
    deepseek = load_deepseek_translations()
    print(f"  Loaded translations for {len(deepseek)} languages: {sorted(deepseek.keys())}")

    for lang in LANGUAGES_TO_FIX:
        if lang in deepseek:
            print(f"  ✓ {lang}: {len(deepseek[lang])} translations available")
        else:
            print(f"  ✗ {lang}: NOT FOUND in deepseek translations")

    with open(DART_FILE, 'r', encoding='utf-8') as f:
        content = f.read()

    # Backup
    shutil.copy2(DART_FILE, BACKUP_FILE)
    print(f"\nBackup saved to {BACKUP_FILE}")

    getters = parse_dart_getters(content)
    print(f"Found {len(getters)} getters in dart file")

    total_fixes = 0
    fixes_per_lang = {}

    # Process from end to start to preserve positions
    new_content = content
    for getter_name, body, start, end, full_match in reversed(getters):
        for lang_code in LANGUAGES_TO_FIX:
            if lang_code not in deepseek:
                continue

            en_to_trans = deepseek[lang_code]
            new_body, fixes = fix_getter_body(body, lang_code, en_to_trans)

            if fixes > 0:
                new_full = full_match.replace(body, new_body, 1)
                new_content = new_content[:start] + new_full + new_content[end:]

                total_fixes += fixes
                fixes_per_lang[lang_code] = fixes_per_lang.get(lang_code, 0) + fixes
                body = new_body  # update for next language
                full_match = new_full  # update full_match too

    print(f"\nTotal fixes applied: {total_fixes}")
    print("\nFixes per language:")
    for lang, count in sorted(fixes_per_lang.items()):
        print(f"  {lang}: {count} translations fixed")

    with open(DART_FILE, 'w', encoding='utf-8') as f:
        f.write(new_content)

    print(f"\nDone! Updated {DART_FILE}")


if __name__ == '__main__':
    main()
