#!/usr/bin/env python3
import requests, jwt, time, json

KEY_ID = '29HD53FFYV'
ISSUER_ID = '4b86ecb0-5c72-4d3a-81b8-e6d62a056467'
KEY_PATH = './fastlane/AuthKey_29HD53FFYV.p8'
API_BASE = 'https://api.appstoreconnect.apple.com/v1'
VERSION_ID = '72ab6e5c-5665-4b2c-9d34-2e3a778625b6'

private_key = open(KEY_PATH).read()
now = int(time.time())
token = jwt.encode(
    {'iss': ISSUER_ID, 'iat': now, 'exp': now+1200, 'aud': 'appstoreconnect-v1'},
    private_key, algorithm='ES256', headers={'kid': KEY_ID, 'typ': 'JWT'}
)
H = {'Authorization': f'Bearer {token}', 'Content-Type': 'application/json'}

r = requests.get(f'{API_BASE}/appStoreVersions/{VERSION_ID}/appStoreVersionLocalizations', headers=H)
locs = r.json().get('data', [])

print(f"{'Locale':<15} {'Preview Type':<25} {'Video State'}")
print('-'*65)
for loc in sorted(locs, key=lambda x: x['attributes']['locale']):
    locale = loc['attributes']['locale']
    loc_id = loc['id']
    r2 = requests.get(f'{API_BASE}/appStoreVersionLocalizations/{loc_id}/appPreviewSets', headers=H)
    sets = r2.json().get('data', [])
    for s in sets:
        pt = s['attributes']['previewType']
        if 'IPAD' in pt:
            r3 = requests.get(f'{API_BASE}/appPreviewSets/{s["id"]}/appPreviews', headers=H)
            previews = r3.json().get('data', [])
            if previews:
                state = previews[0]['attributes'].get('videoDeliveryState', {}).get('state', '?')
                print(f"{locale:<15} {pt:<25} {state}")
            else:
                print(f"{locale:<15} {pt:<25} (no video)")
