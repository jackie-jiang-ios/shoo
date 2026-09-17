#!/usr/bin/env python3
import json, time, requests, jwt

KEY_ID = '29HD53FFYV'
ISSUER_ID = '4b86ecb0-5c72-4d3a-81b8-e6d62a056467'
KEY_PATH = './fastlane/AuthKey_29HD53FFYV.p8'
API_BASE = 'https://api.appstoreconnect.apple.com/v1'
VERSION_ID = '72ab6e5c-5665-4b2c-9d34-2e3a778625b6'

def get_token():
    pk = open(KEY_PATH).read()
    t = int(time.time())
    tok = jwt.encode({'iss': ISSUER_ID, 'iat': t, 'exp': t + 1200, 'aud': 'appstoreconnect-v1'},
        pk, algorithm='ES256', headers={'kid': KEY_ID, 'typ': 'JWT'})
    return {'Authorization': f'Bearer {tok}', 'Content-Type': 'application/json'}

r = requests.get(f'{API_BASE}/appStoreVersions/{VERSION_ID}/appStoreVersionLocalizations', headers=get_token())
for loc in r.json().get('data', []):
    if loc['attributes']['locale'] == 'en-CA':
        loc_id = loc['id']
        break

# Check ALL screenshots for en-CA
r = requests.get(f'{API_BASE}/appStoreVersionLocalizations/{loc_id}/appScreenshotSets', headers=get_token())
sets = r.json().get('data', [])
print(f"en-CA screenshot sets: {len(sets)}")
for s in sets:
    dt = s['attributes']['screenshotDisplayType']
    r = requests.get(f'{API_BASE}/appScreenshotSets/{s["id"]}/appScreenshots', headers=get_token())
    for ss in r.json().get('data', []):
        ad = ss['attributes'].get('assetDeliveryState', {})
        print(f"  {dt}/{ss['attributes']['fileName']}: state={ad.get('state')}, errors={ad.get('errors')}")

# Check videos for en-CA
r = requests.get(f'{API_BASE}/appStoreVersionLocalizations/{loc_id}/appPreviewSets', headers=get_token())
psets = r.json().get('data', [])
print(f"\nen-CA preview sets: {len(psets)}")
for p in psets:
    pt = p['attributes']['previewType']
    r = requests.get(f'{API_BASE}/appPreviewSets/{p["id"]}/appPreviews', headers=get_token())
    for pv in r.json().get('data', []):
        ad = pv['attributes'].get('assetDeliveryState', {})
        print(f"  {pt}/{pv['attributes']['fileName']}: state={ad.get('state')}, errors={ad.get('errors')}")
