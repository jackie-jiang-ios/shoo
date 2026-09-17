#!/usr/bin/env python3
"""Add shareApp translation to all arb files."""

import os

translations = {
    'ar': '"shareApp": "مشاركة",',
    'bn': '"shareApp": "শেয়ার করুন",',
    'ca': '"shareApp": "Compartir",',
    'cs': '"shareApp": "Sdílet",',
    'da': '"shareApp": "Del",',
    'de': '"shareApp": "Teilen",',
    'el': '"shareApp": "Κοινοποίηση",',
    'en_AU': '"shareApp": "Share",',
    'en_CA': '"shareApp": "Share",',
    'en_GB': '"shareApp": "Share",',
    'es': '"shareApp": "Compartir",',
    'es_MX': '"shareApp": "Compartir",',
    'fi': '"shareApp": "Jaa",',
    'fr': '"shareApp": "Partager",',
    'fr_CA': '"shareApp": "Partager",',
    'gu': '"shareApp": "શેર કરો",',
    'he': '"shareApp": "שתף",',
    'hi': '"shareApp": "शेयर करें",',
    'hr': '"shareApp": "Podijeli",',
    'hu': '"shareApp": "Megosztás",',
    'id': '"shareApp": "Bagikan",',
    'it': '"shareApp": "Condividi",',
    'ja': '"shareApp": "共有",',
    'kn': '"shareApp": "ಹಂಚಿಕೊಳ್ಳಿ",',
    'ko': '"shareApp": "공유",',
    'ml': '"shareApp": "പങ്കിടുക",',
    'mr': '"shareApp": "शेअर करा",',
    'ms': '"shareApp": "Kongsi",',
    'nl': '"shareApp": "Delen",',
    'no': '"shareApp": "Del",',
    'or': '"shareApp": "ଶେୟାର କରନ୍ତୁ",',
    'pa': '"shareApp": "ਸ਼ੇਅਰ ਕਰੋ",',
    'pl': '"shareApp": "Udostępnij",',
    'pt': '"shareApp": "Partilhar",',
    'ro': '"shareApp": "Distribuie",',
    'ru': '"shareApp": "Поделиться",',
    'sk': '"shareApp": "Zdieľať",',
    'sl': '"shareApp": "Deli",',
    'sv': '"shareApp": "Dela",',
    'ta': '"shareApp": "பகிர்",',
    'te': '"shareApp": "షేర్ చేయండి",',
    'th': '"shareApp": "แชร์",',
    'tr': '"shareApp": "Paylaş",',
    'uk': '"shareApp": "Поділитися",',
    'ur': '"shareApp": "شیئر کریں",',
    'vi': '"shareApp": "Chia sẻ",',
    'zh_TW': '"shareApp": "分享",',
}

L10N_DIR = os.path.join(os.path.dirname(__file__), '..', 'lib', 'l10n')

for locale, line in translations.items():
    filename = os.path.join(L10N_DIR, f'app_{locale}.arb')
    if not os.path.exists(filename):
        print(f'NOT FOUND: {filename}')
        continue

    with open(filename, 'r') as f:
        content = f.read()

    # Skip if already has shareApp
    if '"shareApp"' in content:
        print(f'SKIP {locale}: already has shareApp')
        continue

    # Add before "rateUs" line
    if '"rateUs"' in content:
        content = content.replace('  "rateUs"', f'  {line}\n  "rateUs"')
    else:
        # For incomplete files, add before last closing brace
        content = content.rstrip()
        if content.endswith('}'):
            content = content[:-1].rstrip() + f'\n  {line}\n}}'

    with open(filename, 'w') as f:
        f.write(content)
    print(f'OK {locale}: added shareApp')

print('\nDone!')
