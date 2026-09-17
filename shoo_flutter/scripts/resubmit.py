#!/usr/bin/env python3
import json, time, requests, jwt

KEY_ID = '29HD53FFYV'
ISSUER_ID = '4b86ecb0-5c72-4d3a-81b8-e6d62a056467'
KEY_PATH = './fastlane/AuthKey_29HD53FFYV.p8'
API_BASE = 'https://api.appstoreconnect.apple.com/v1'
VERSION_ID = '72ab6e5c-5665-4b2c-9d34-2e3a778625b6'
BUILD_ID = '73d59482-3972-47c5-a5a0-ef909d7999d1'

def get_token():
    private_key = open(KEY_PATH).read()
    now = int(time.time())
    token = jwt.encode(
        {'iss': ISSUER_ID, 'iat': now, 'exp': now + 1200, 'aud': 'appstoreconnect-v1'},
        private_key, algorithm='ES256',
        headers={'kid': KEY_ID, 'typ': 'JWT'},
    )
    return {'Authorization': f'Bearer {token}', 'Content-Type': 'application/json'}

H = get_token()

# 1. Get version (new token)
print("=== 1. 重新获取版本信息 ===")
r = requests.get(f'{API_BASE}/appStoreVersions/{VERSION_ID}', headers=H)
print(f"  HTTP {r.status_code}")
v = r.json()['data']
print(f"  State: {v['attributes']['appStoreState']}")
print(f"  Build in relationships: {v.get('relationships',{}).get('build',{}).get('data')}")

# 1b. Try re-attaching build (idempotent)
print("\n=== 1b. 重新确认附加 Build ===")
body = {'data':{'type':'appStoreVersions','id':VERSION_ID,
  'relationships':{'build':{'data':{'type':'builds','id':BUILD_ID}}}}}
r = requests.patch(f'{API_BASE}/appStoreVersions/{VERSION_ID}', headers=H, json=body)
print(f"  HTTP {r.status_code}")

# 2. Update review detail (no appAttachmentFileUrls)
print("\n=== 2. 更新 reviewDetail ===")
RD_ID = '5aa9a4f9-35d1-4932-b281-ca9bda1ba256'
attrs = {
    'contactFirstName': 'Jiang',
    'contactLastName': 'Zheng',
    'contactPhone': '13036101641',
    'contactEmail': '13036101641@163.com',
    'demoAccountName': '',
    'demoAccountPassword': '',
    'demoAccountRequired': False,
    'notes': '',
}
body = {'data':{'type':'appStoreReviewDetails','id':RD_ID,'attributes':attrs}}
r = requests.patch(f'{API_BASE}/appStoreReviewDetails/{RD_ID}', headers=H, json=body)
print(f"  HTTP {r.status_code}")
if r.status_code != 200:
    print(json.dumps(r.json(), indent=2, ensure_ascii=False))
else:
    print(json.dumps(r.json()['data']['attributes'], indent=2, ensure_ascii=False))

# 3. Try the new state-based submit (via state parameter)
print("\n=== 3. 直接改变 appStoreVersion 状态到 PROCESSING ===")
body = {
    'data': {
        'type': 'appStoreVersions',
        'id': VERSION_ID,
        'attributes': {
            'appStoreState': 'PROCESSING'
        }
    }
}
r = requests.patch(f'{API_BASE}/appStoreVersions/{VERSION_ID}', headers=H, json=body)
print(f"  HTTP {r.status_code}")
if r.status_code != 200:
    resp = r.json()
    errors = resp.get('errors', [])
    for err in errors:
        print(f"  Error: {err.get('code')} - {err.get('detail')}")
    print(json.dumps(resp, indent=2, ensure_ascii=False))
