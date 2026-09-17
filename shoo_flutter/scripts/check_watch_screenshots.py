#!/usr/bin/env python3
"""Check Watch screenshot status on App Store Connect"""
import json, time, requests, jwt

KEY_ID = '29HD53FFYV'
ISSUER_ID = '4b86ecb0-5c72-4d3a-81b8-e6d62a056467'
KEY_PATH = './fastlane/AuthKey_29HD53FFYV.p8'
API_BASE = 'https://api.appstoreconnect.apple.com/v1'
VERSION_ID = '72ab6e5c-5665-4b2c-9d34-2e3a778625b6'

def get_token():
    private_key = open(KEY_PATH).read()
    now = int(time.time())
    token = jwt.encode(
        {'iss': ISSUER_ID, 'iat': now, 'exp': now+1200, 'aud': 'appstoreconnect-v1'},
        private_key, algorithm='ES256', headers={'kid': KEY_ID, 'typ': 'JWT'}
    )
    return {'Authorization': f'Bearer {token}', 'Content-Type': 'application/json'}

H = get_token()

# Get all localizations
r = requests.get(f'{API_BASE}/appStoreVersions/{VERSION_ID}/appStoreVersionLocalizations', headers=H)
locs = r.json().get('data', [])

# All expected languages
expected_langs = [
    'ar-SA', 'bn-BD', 'ca', 'cs', 'da', 'de-DE', 'el', 'en-AU', 'en-CA', 'en-GB', 'en-US',
    'es-ES', 'es-MX', 'fi', 'fr-CA', 'fr-FR', 'gu-IN', 'he', 'hi', 'hr', 'hu', 'id', 'it',
    'ja', 'kn-IN', 'ko', 'ml-IN', 'mr-IN', 'ms', 'nl-NL', 'no', 'or-IN', 'pa-IN', 'pl', 'pt-BR',
    'ro', 'ru', 'sk', 'sl-SI', 'sv', 'ta-IN', 'te-IN', 'th', 'tr', 'uk', 'ur-PK', 'vi', 'zh-Hans', 'zh-Hant'
]

asc_locales = { loc['attributes']['locale']: loc['id'] for loc in locs }
print(f"Total localizations: {len(asc_locales)}")
print(f"Expected: {len(expected_langs)}")
print()

# Check each locale for Watch screenshots
missing = []
empty = []

for lang in sorted(expected_langs):
    loc_id = asc_locales.get(lang)
    if not loc_id:
        print(f"  MISSING LOCALE: {lang}")
        missing.append(lang)
        continue
    
    r2 = requests.get(f'{API_BASE}/appStoreVersionLocalizations/{loc_id}/appScreenshotSets', headers=H)
    sets = r2.json().get('data', [])
    
    # Find watch sets
    watch_sets = [s for s in sets if 'WATCH' in s['attributes'].get('screenshotDisplayType', '')]
    
    if not watch_sets:
        print(f"  NO WATCH SET: {lang}")
        empty.append(lang)
        continue
    
    for ws in watch_sets:
        ws_id = ws['id']
        ws_type = ws['attributes']['screenshotDisplayType']
        
        r3 = requests.get(f'{API_BASE}/appScreenshotSets/{ws_id}/appScreenshots', headers=H)
        shots = r3.json().get('data', [])
        
        shot_info = []
        for s in shots:
            state = s['attributes'].get('state', 'UNKNOWN')
            fname = s['attributes'].get('fileName', '')
            shot_info.append(f"{fname}({state})")
        
        shots_str = ', '.join(shot_info) if shot_info else "EMPTY"
        ok = all(s['attributes'].get('state') == 'APP_STORE' for s in shots)
        status = "✓" if ok else "✗"
        print(f"  {status} {lang} [{ws_type}]: {shots_str}")

print(f"\n=== SUMMARY ===")
print(f"Total expected: {len(expected_langs)}")
print(f"Locale missing: {len(missing)}")
print(f"Watch set missing: {len(empty)}")
if missing:
    print(f"\nMissing locales: {', '.join(missing)}")
if empty:
    print(f"\nMissing watch sets: {', '.join(empty)}")
