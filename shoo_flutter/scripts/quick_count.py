#!/usr/bin/env python3
import sys, os, pathlib, requests, jwt, time

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
total_all = 0
count_by_lang = {}
for loc in locs:
    locale = loc['attributes']['locale']
    r2 = requests.get(f"{API_BASE}/appStoreVersionLocalizations/{loc['id']}/appScreenshotSets", headers=H)
    total = 0
    for s in r2.json().get('data', []):
        r3 = requests.get(f"{API_BASE}/appScreenshotSets/{s['id']}/appScreenshots", headers=H)
        total += len(r3.json().get('data', []))
    count_by_lang[locale] = total
    total_all += total

print(f"4.0.0 TOTAL SCREENSHOTS: {total_all}")
print("Languages with screenshots:")
for lang in sorted(count_by_lang.keys()):
    if count_by_lang[lang] > 0:
        print(f"  {lang}: {count_by_lang[lang]}")
