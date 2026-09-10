#!/usr/bin/env python3
"""Debug: 检查 en-US 下所有 preview set 和 app preview"""
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

# 获取 en-US 的 localization ID
r = requests.get(f'{API_BASE}/appStoreVersions/{VERSION_ID}/appStoreVersionLocalizations', headers=H)
locs = r.json().get('data', [])
en_us_id = None
for loc in locs:
    if loc['attributes']['locale'] == 'en-US':
        en_us_id = loc['id']
        break

print(f'en-US localization ID: {en_us_id}')

# 获取所有 preview sets
r = requests.get(f'{API_BASE}/appStoreVersionLocalizations/{en_us_id}/appPreviewSets', headers=H)
sets = r.json().get('data', [])
print(f'\nen-US Preview Sets ({len(sets)}):')
for s in sets:
    pt = s['attributes']['previewType']
    sid = s['id']
    print(f'\n  [{pt}] ID: {sid}')
    
    # 获取 preview 详情
    r2 = requests.get(f'{API_BASE}/appPreviewSets/{sid}/appPreviews', headers=H)
    previews = r2.json().get('data', [])
    print(f'  视频数量: {len(previews)}')
    for p in previews:
        attrs = p['attributes']
        print(f'    - fileName: {attrs.get("fileName")}')
        print(f'      fileSize: {attrs.get("fileSize")}')
        print(f'      videoState: {attrs.get("videoDeliveryState", {}).get("state")}')
        print(f'      assetState: {attrs.get("assetDeliveryState", {}).get("state")}')
        print(f'      previewId: {p["id"]}')

# 也检查一下所有可用的 preview set (包括其他 localization 的)
print('\n\n=== 检查所有 localization 的 Preview Sets ===')
for loc in locs[:5]:  # 只检查前5个
    locale = loc['attributes']['locale']
    loc_id = loc['id']
    r = requests.get(f'{API_BASE}/appStoreVersionLocalizations/{loc_id}/appPreviewSets', headers=H)
    sets = r.json().get('data', [])
    if sets:
        types = [s['attributes']['previewType'] for s in sets]
        print(f'  {locale}: {types}')
