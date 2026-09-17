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

# 1. Patch build attachment
print("=== 1. 附加 Build ===")
body = {'data':{'type':'appStoreVersions','id':VERSION_ID,
  'relationships':{'build':{'data':{'type':'builds','id':BUILD_ID}}}}}
r = requests.patch(f'{API_BASE}/appStoreVersions/{VERSION_ID}', headers=H, json=body)
print(f"  PATCH HTTP {r.status_code}")

# 2. Re-fetch to confirm
print("\n=== 2. 确认 Build ===")
H = get_token()
r = requests.get(f'{API_BASE}/appStoreVersions/{VERSION_ID}', headers=H)
v = r.json()['data']
print(f"  State: {v['attributes']['appStoreState']}")
build = v.get('relationships',{}).get('build',{}).get('data')
print(f"  Build: {build}")

# 3. Get the version again with included build
print("\n=== 3. 尝试 included 参数 ===")
H = get_token()
r = requests.get(f'{API_BASE}/appStoreVersions/{VERSION_ID}?include=build', headers=H)
print(f"  HTTP {r.status_code}")
print(json.dumps(r.json(), indent=2, ensure_ascii=False)[:500])

# 4. Try the /builds relationship link
print("\n=== 4. GET /builds relationship ===")
H = get_token()
r = requests.get(f'{API_BASE}/appStoreVersions/{VERSION_ID}/build', headers=H)
print(f"  HTTP {r.status_code}")
print(json.dumps(r.json(), indent=2, ensure_ascii=False)[:500])
