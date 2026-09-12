#!/usr/bin/env python3
"""Re-upload en-CA iPhone Home screenshot."""
import json, time, os, requests, jwt

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

# Find en-CA localization
r = requests.get(f'{API_BASE}/appStoreVersions/{VERSION_ID}/appStoreVersionLocalizations', headers=get_token())
loc_id = None
for loc in r.json().get('data', []):
    if loc['attributes']['locale'] == 'en-CA':
        loc_id = loc['id']
        break

print(f"en-CA loc: {loc_id}")

# Find the screenshot set for APP_IPHONE_65
r = requests.get(f'{API_BASE}/appStoreVersionLocalizations/{loc_id}/appScreenshotSets', headers=get_token())
iphone_set = None
for s in r.json().get('data', []):
    if s['attributes']['screenshotDisplayType'] == 'APP_IPHONE_65':
        iphone_set = s['id']
        break

print(f"iPhone set: {iphone_set}")

# Find and delete the stuck screenshot
r = requests.get(f'{API_BASE}/appScreenshotSets/{iphone_set}/appScreenshots', headers=get_token())
for ss in r.json().get('data', []):
    if ss['attributes']['fileName'] == '01_Home.png':
        sid = ss['id']
        print(f"Found 01_Home.png: {sid}")
        r = requests.delete(f'{API_BASE}/appScreenshots/{sid}', headers=get_token())
        print(f"DELETE: HTTP {r.status_code}")
        break

# Re-upload
img_path = './fastlane/screenshots/en-CA/01_Home.png'
if not os.path.exists(img_path):
    print(f"File not found: {img_path}")
    exit(1)

fsize = os.path.getsize(img_path)
body = {'data': {'type': 'appScreenshots',
                 'attributes': {'fileName': '01_Home.png', 'fileSize': fsize},
                 'relationships': {'appScreenshotSet': {'data': {'type': 'appScreenshotSets', 'id': iphone_set}}}}}
r = requests.post(f'{API_BASE}/appScreenshots', headers=get_token(), json=body)
print(f"POST: HTTP {r.status_code}")
if r.status_code != 201:
    print(r.text[:300])
    exit(1)

pv_id = r.json()['data']['id']
ops = r.json()['data']['attributes']['uploadOperations']
with open(img_path, 'rb') as f:
    for op in ops:
        url, method = op['url'], op['method']
        headers = {h['name']: h['value'] for h in op['requestHeaders']}
        f.seek(op['offset'])
        chunk = f.read(op['length'])
        r2 = requests.request(method, url, headers=headers, data=chunk)
        if r2.status_code not in [200, 201, 204]:
            print(f"Upload failed: HTTP {r2.status_code}")
            exit(1)
    r = requests.patch(f'{API_BASE}/appScreenshots/{pv_id}', headers=get_token(),
                      json={'data': {'type': 'appScreenshots', 'id': pv_id, 'attributes': {'uploaded': True}}})
    print(f"Commit: HTTP {r.status_code}")
    print("Done!")
