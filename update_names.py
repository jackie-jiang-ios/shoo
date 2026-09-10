#!/usr/bin/env python3
import os

names = {
    'en': 'Animal Repellent', 'en-AU': 'Animal Repellent', 'en-CA': 'Animal Repellent', 'en-GB': 'Animal Repellent',
    'ja': '動物撃退', 'ko': '동물퇴치',
    'fr': 'Répulsif Animaux', 'fr-CA': 'Répulsif Animaux',
    'de': 'Tiervertreibung',
    'es': 'Ahuyentador', 'es-MX': 'Ahuyentador',
    'pt': 'Repelente',
    'it': 'Respingi Animali', 'ru': 'Отпугиватель',
    'th': 'ไล่สัตว์', 'ar': 'طارد الحيوانات',
    'id': 'Usir Hewan', 'ms': 'Usir Haiwan',
    'nl': 'Dierenverjaging', 'pl': 'Odstraszanie Zwierząt',
    'tr': 'Hayvan Kovucu', 'vi': 'Đuổi Động Vật',
    'hi': 'जानवर भगाने वाला', 'da': 'Driv Væk',
    'fi': 'Eläinkarkoitus', 'gu': 'પ્રાણીઓ ભગાવો',
    'ca': 'Espanta Animals', 'cs': 'Odehnat Zvířata',
    'kn': 'ಪ್ರಾಣಿಗಳನ್ನು ಓಡಿಸಿ', 'hr': 'Tjeranje Životinja',
    'ro': 'Alungit Animale', 'mr': 'प्राणी भागवा',
    'ml': 'മൃഗങ്ങളെ ഓടിക്കുക', 'bn': 'প্রাণি নিরোধক',
    'no': 'Dyrefordrivelse', 'pa': 'ਜਾਨਵਰ ਭਗਾਓ',
    'sv': 'Djurbortdrivande', 'sk': 'Odplašenie Zvierat',
    'sl': 'Odganjanje Živali', 'te': 'జంతువులను తరిమికొట్టు',
    'ta': 'விலங்குகளை ஓட்டுங்கள்', 'ur': 'جانوروں کو بھگائیں',
    'uk': 'Відштовхувач', 'he': 'מהדהד בעלי חיים',
    'el': 'Απομάκρυνση Ζώων', 'hu': 'Állatűző',
    'zh-Hans': '防兽神器', 'zh-Hant': '防獸神器',
}

os.chdir('/Users/jiangzheng/Project/iOS/Shoo/ShooWatchApp')

for lang, name in names.items():
    path = os.path.join(lang + '.lproj', 'Localizable.strings')
    if os.path.exists(path):
        with open(path, 'r') as f:
            content = f.read()
        new_content = content.replace('"app_name" = "Shoo!"', f'"app_name" = "{name}"')
        if new_content != content:
            with open(path, 'w') as f:
                f.write(new_content)
            print(f'OK  {lang}: {name}')
        else:
            print(f'SKIP {lang}: already different or not found')
    else:
        print(f'MISS {lang}: {path} not found')
