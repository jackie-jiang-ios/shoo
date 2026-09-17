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
    tok = jwt.encode(
        {'iss': ISSUER_ID, 'iat': t, 'exp': t + 1200, 'aud': 'appstoreconnect-v1'},
        pk, algorithm='ES256',
        headers={'kid': KEY_ID, 'typ': 'JWT'},
    )
    return {'Authorization': f'Bearer {tok}', 'Content-Type': 'application/json'}

# 1. 修 reviewDetail typo
print("=== 1. 修复 reviewDetail ===")
H = get_token()
attrs = {
    'contactFirstName': 'Jiang',
    'contactLastName': 'Zheng',
    'contactPhone': '+86 138 0000 0000',
    'contactEmail': 'dev@liteapps.cn',
    'demoAccountName': '',
    'demoAccountPassword': '',
    'demoAccountRequired': False,
    'notes': 'Test version 4.0.0',
}
body = {'data': {'type': 'appStoreReviewDetails', 'id': '5aa9a4f9-35d1-4932-b281-ca9bda1ba256', 'attributes': attrs}}
r = requests.patch(f'{API_BASE}/appStoreReviewDetails/5aa9a4f9-35d1-4932-b281-ca9bda1ba256', headers=get_token(), json=body)
print(f"  HTTP {r.status_code}")
print(r.text[:300])

# 2. PATCH version to READY_FOR_REVIEW state (may not work but try)
print("\n=== 2. 尝试 PATCH 版本状态 ===")
for attempt in [{'appStoreState': 'WAITING_FOR_REVIEW'}, {'appStoreState': 'READY_FOR_REVIEW'}]:
    r = requests.patch(f'{API_BASE}/appStoreVersions/{VERSION_ID}', headers=get_token(),
                      json={'data': {'type': 'appStoreVersions', 'id': VERSION_ID, 'attributes': attempt}})
    print(f"  PATCH {attempt}: HTTP {r.status_code}")
    print(f"    {r.text[:200]}")

# 3. Try MAS-style endpoints
print("\n=== 3. 尝试其他路径 ===")
endpoints = [
    f'{API_BASE}/appStoreVersions/{VERSION_ID}/submitForReview',
    f'{API_BASE}/appStoreVersions/{VERSION_ID}/release',
]
for ep in endpoints:
    r = requests.post(ep, headers=get_token(),
                     json={'data': {'type': 'appStoreVersions', 'id': VERSION_ID}})
    print(f"  {ep}: HTTP {r.status_code}")
    print(f"    {r.text[:150]}")
