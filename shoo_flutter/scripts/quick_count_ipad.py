#!/usr/bin/env python3
import pathlib, requests, jwt, time

KEY_ID = '29HD53FFYV'
ISSUER_ID = '4b86ecb0-5c72-4d3a-81b8-e6d62a056467'
KEY_PATH = './fastlane/AuthKey_29HD53FFYV.p8'
private_key = pathlib.Path(KEY_PATH).read_text()
now = int(time.time())
token = jwt.encode({'iss': ISSUER_ID, 'iat': now, 'exp': now+1200, 'aud': 'appstoreconnect-v1'}, private_key, algorithm='ES256', headers={'kid': KEY_ID, 'typ': 'JWT'})
H = {'Authorization': f'Bearer {token}', 'Content-Type': 'application/json'}
API_BASE = 'https://api.appstoreconnect.apple.com/v1'
VERSION_ID = '72ab6e5c-5665-4b2c-9d34-2e3a778625b6'

r = requests.get(f'{API_BASE}/appStoreVersions/{VERSION_ID}/appStoreVersionLocalizations', headers=H)
locs = r.json().get('data', [])
ipad_total = 0
ipad_langs = {}
for loc in locs:
    locale = loc['attributes']['locale']
    r2 = requests.get(f"{API_BASE}/appStoreVersionLocalizations/{loc['id']}/appScreenshotSets", headers=H)
    for s in r2.json().get('data', []):
        if 'IPAD' in s['attributes']['screenshotDisplayType']:
            r3 = requests.get(f"{API_BASE}/appScreenshotSets/{s['id']}/appScreenshots", headers=H)
            cnt = len(r3.json().get('data', []))
            ipad_langs[locale] = cnt
            ipad_total += cnt

print(f"iPad screenshots: {ipad_total}")
for lang in sorted(ipad_langs.keys()):
    if ipad_langs[lang] > 0:
        print(f"  {lang}: {ipad_langs[lang]}")
