#!/usr/bin/env python3
"""Try various submission methods."""
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

# 1. Make sure review detail exists and update it
print("=== 1. 创建/更新 appStoreReviewDetail ===")
H = get_token()
r = requests.get(f'{API_BASE}/appStoreVersions/{VERSION_ID}/appStoreReviewDetail', headers=H)
print(f"  GET reviewDetail HTTP {r.status_code}")

existing_id = None
if r.status_code == 200:
    data = r.json().get('data')
    if isinstance(data, list) and data:
        existing_id = data[0].get('id')
    elif isinstance(data, dict) and data:
        existing_id = data.get('id')
    print(f"  Existing ID: {existing_id}")

# Fields that might work
attrs = {
    'contactFirstName': 'Jiang',
    'contactLastName': 'Zheng',
    'contactPhone': '+86-138-0000-0000',
    'contactEmail:': 'developer@example.com',
    'demoAccountName': '',
    'demoAccountPassword': '',
    'demoAccountRequired': False,
    'notes': 'For review',
}

if existing_id:
    body = {'data': {'type': 'appStoreReviewDetails', 'id': existing_id, 'attributes': attrs}}
    r = requests.patch(f'{API_BASE}/appStoreReviewDetails/{existing_id}', headers=get_token(), json=body)
    print(f"  PATCH HTTP {r.status_code}")
    print(f"  {r.text[:300]}")
else:
    body = {'data': {'type': 'appStoreReviewDetails', 'attributes': attrs,
                     'relationships': {'appStoreVersion': {'data': {'type': 'appStoreVersions', 'id': VERSION_ID}}}}}
    r = requests.post(f'{API_BASE}/appStoreReviewDetails', headers=get_token(), json=body)
    print(f"  POST HTTP {r.status_code}")
    print(f"  {r.text[:300]}")
    if r.status_code in (200, 201):
        existing_id = r.json()['data']['id']

# 2. Try the older submission API (DELETE + recreate flow)
print("\n=== 2. 尝试 reviewItems 提交 ===")
H = get_token()
# Maybe there's a relationship submission  
r = requests.post(f'{API_BASE}/appStoreVersionSubmissions', headers=get_token(),
                 json={'data': {'type': 'appStoreVersionSubmissions',
                               'relationships': {'appStoreVersion': {'data': {'type': 'appStoreVersions', 'id': VERSION_ID}}}}})
print(f"  POST submissions HTTP {r.status_code}")
print(f"  {r.text[:300]}")

# 3. Check for alternative endpoints
print("\n=== 3. 尝试 release请求 ===")
for endpoint in [
    f'{API_BASE}/appStoreReleaseRequests',
    f'{API_BASE}/api/v1/appStoreReleaseRequests',  # potential alternative
]:
    r = requests.post(endpoint, headers=get_token(),
                     json={'data': {'type': 'appStoreReleaseRequests',
                                   'relationships': {'appStoreVersion': {'data': {'type': 'appStoreVersions', 'id': VERSION_ID}}}}})
    print(f"  {endpoint}: HTTP {r.status_code}")
    print(f"    {r.text[:200]}")

# 4. Also try DELETE on the old endpoint (say DELETE works)
print("\n=== 4. 验证可以 DELETE ===")
fake_id = "fake-sub-id"
r = requests.delete(f'{API_BASE}/appStoreVersionSubmissions/{fake_id}', headers=get_token())
print(f"  DELETE random ID: HTTP {r.status_code}")
