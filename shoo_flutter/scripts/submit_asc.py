#!/usr/bin/env python3
"""Submit for review using appStoreReleaseRequests API."""
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

# Check current version status first
print("=== 1. 检查版本状态 ===")
H = get_token()
r = requests.get(f'{API_BASE}/appStoreVersions/{VERSION_ID}', headers=H)
print(f"  HTTP {r.status_code}")
state = r.json().get('data', {}).get('attributes', {}).get('appStoreState', '?')
print(f"  State: {state}")

# Try appStoreReleaseRequests (new API)
print("\n=== 2. POST /appStoreReleaseRequests ===")
H = get_token()
body = {
    'data': {
        'type': 'appStoreReleaseRequests',
        'relationships': {
            'appStoreVersion': {
                'data': {'type': 'appStoreVersions', 'id': VERSION_ID}
            }
        }
    }
}
r = requests.post(f'{API_BASE}/appStoreReleaseRequests', headers=H, json=body)
print(f"  HTTP {r.status_code}")
try:
    print(json.dumps(r.json(), indent=2, ensure_ascii=False))
except Exception:
    print(r.text[:500])

if r.status_code == 201:
    print("\n========== 提交成功！==========")
else:
    print(f"\n尝试其他方式...")
