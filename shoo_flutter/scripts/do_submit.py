#!/usr/bin/env python3
import json, time, requests, jwt

KEY_ID = '29HD53FFYV'
ISSUER_ID = '4b86ecb0-5c72-4d3a-81b8-e6d62a056467'
KEY_PATH = './fastlane/AuthKey_29HD53FFYV.p8'
API_BASE = 'https://api.appstoreconnect.apple.com/v1'
VERSION_ID = '72ab6e5c-5665-4b2c-9d34-2e3a778625b6'

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

# 1. 尝试直接 POST 提交审核
print("=== 1. POST /appStoreVersionSubmissions ===")
body = {
    'data': {
        'type': 'appStoreVersionSubmissions',
        'relationships': {
            'appStoreVersion': {
                'data': {'type': 'appStoreVersions', 'id': VERSION_ID}
            }
        }
    }
}
r = requests.post(f'{API_BASE}/appStoreVersionSubmissions', headers=H, json=body)
print(f"  HTTP {r.status_code}")
print(json.dumps(r.json(), indent=2, ensure_ascii=False))

# 如果 return 201  -> success
if r.status_code == 201:
    print("  ✅ SUBMITTED!")
    exit(0)
print("  � 继续尝试其他方式...")

# 2. 查看现有 submission
print("\n=== 2. GET existing submission ===")
H = get_token()
r = requests.get(f'{API_BASE}/appStoreVersions/{VERSION_ID}/appStoreVersionSubmission',
                 headers=H)
print(f"  HTTP {r.status_code}")
if r.status_code == 200:
    data = r.json().get('data', [])
    print(json.dumps(r.json(), indent=2, ensure_ascii=False)[:500])
    if isinstance(data, list) and data:
        sid = data[0]['id']
        
        # 2a. DELETE existing to clear bad state
        print(f"\n=== 2a. DELETE old submission ({sid}) ===")
        H = get_token()
        r = requests.delete(f'{API_BASE}/appStoreVersionSubmissions/{sid}',
                            headers=H)
        print(f"  HTTP {r.status_code}")
        print(json.dumps(r.json(), indent=2, ensure_ascii=False)[:300])
        
        # 2b. 重新 POST
        print("\n=== 2b. POST new submission after DELETE ===")
        H = get_token()
        r = requests.post(f'{API_BASE}/appStoreVersionSubmissions', headers=H,
                          json=body)
        print(f"  HTTP {r.status_code}")
        print(json.dumps(r.json(), indent=2, ensure_ascii=False))
else:
    print(json.dumps(r.json(), indent=2, ensure_ascii=False))
