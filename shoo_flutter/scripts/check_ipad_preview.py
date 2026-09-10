#!/usr/bin/env python3
import time, requests, jwt

KEY_ID = '29HD53FFYV'
ISSUER_ID = '4b86ecb0-5c72-4d3a-81b8-e6d62a056467'
KEY_PATH = '/Users/jiangzheng/Project/iOS/Shoo/shoo_flutter/fastlane/AuthKey_29HD53FFYV.p8'
API_BASE = 'https://api.appstoreconnect.apple.com/v1'
VERSION_ID = '72ab6e5c-5665-4b2c-9d34-2e3a778625b6'

private_key = open(KEY_PATH).read()
now = int(time.time())
token = jwt.encode({'iss': ISSUER_ID, 'iat': now, 'exp': now+1200, 'aud': 'appstoreconnect-v1'}, private_key, algorithm='ES256', headers={'kid': KEY_ID, 'typ': 'JWT'})
H = {'Authorization': f'Bearer {token}', 'Content-Type': 'application/json'}

# 获取版本下所有本地化
r = requests.get(f'{API_BASE}/appStoreVersions/{VERSION_ID}/appStoreVersionLocalizations', headers=H)
locs = r.json().get('data', [])
print(f'版本 4.0.0 的本地化数量: {len(locs)}')

# 找 en-US
for loc in locs:
    locale = loc['attributes']['locale']
    loc_id = loc['id']
    if locale == 'en-US':
        print(f'\n=== en-US (ID: {loc_id}) ===')
        r2 = requests.get(f'{API_BASE}/appStoreVersionLocalizations/{loc_id}/appPreviewSets', headers=H)
        sets = r2.json().get('data', [])
        print(f'  Preview Sets: {len(sets)}')
        for s in sets:
            pt = s['attributes']['previewType']
            sid = s['id']
            print(f'    - {pt} (ID: {sid})')
            r3 = requests.get(f'{API_BASE}/appPreviewSets/{sid}/appPreviews', headers=H)
            previews = r3.json().get('data', [])
            print(f'      视频数: {len(previews)}')
            for p in previews:
                attrs = p['attributes']
                print(f'        * {attrs.get("fileName", "?")} | 视频状态: {attrs.get("videoDeliveryState", {}).get("state", "?")}')
