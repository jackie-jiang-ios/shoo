#!/usr/bin/env python3
"""Check pt-PT status."""
import json, time, requests, jwt

KEY_ID = '29HD53FFYV'
ISSUER_ID = '4b86ecb0-5c72-4d3a-81b8-e6d62a056467'
KEY_PATH = './fastlane/AuthKey_29HD53FFYV.p8'
API_BASE = 'https://api.appstoreconnect.apple.com/v1'

private_key = open(KEY_PATH).read()
now = int(time.time())
token = jwt.encode(
    {'iss': ISSUER_ID, 'iat': now, 'exp': now+1200, 'aud': 'appstoreconnect-v1'},
    private_key, algorithm='ES256', headers={'kid': KEY_ID, 'typ': 'JWT'}
)
H = {'Authorization': f'Bearer {token}', 'Content-Type': 'application/json'}

r = requests.get(f'{API_BASE}/appStoreVersions/72ab6e5c-5665-4b2c-9d34-2e3a778625b6/appStoreVersionLocalizations', headers=H)
loc_id = None
for loc in r.json().get('data', []):
    if loc['attributes']['locale'] == 'pt-PT':
        loc_id = loc['id']
        break

if not loc_id:
    print("pt-PT not found!")
    exit(1)

print(f"Localization: {loc_id}")

r = requests.get(f'{API_BASE}/appStoreVersionLocalizations/{loc_id}/appScreenshotSets', headers=H)
print('\nScreenshot sets:')
for s in r.json().get('data', []):
    dt = s['attributes']['screenshotDisplayType']
    r2 = requests.get(f'{API_BASE}/appScreenshotSets/{s["id"]}/appScreenshots', headers=H)
    count = len(r2.json().get('data', []))
    print(f'  {dt}: {count} screenshots')

r = requests.get(f'{API_BASE}/appStoreVersionLocalizations/{loc_id}/appPreviewSets', headers=H)
print('\nPreview sets:')
for s in r.json().get('data', []):
    dt = s['attributes']['previewType']
    r2 = requests.get(f'{API_BASE}/appPreviewSets/{s["id"]}/appPreviews', headers=H)
    previews = r2.json().get('data', [])
    print(f'  {dt}: {len(previews)} previews')
    for p in previews:
        print(f'    - {p["attributes"]["fileName"]}: {p["attributes"].get("previewFrameTimeCode", "?")}')
