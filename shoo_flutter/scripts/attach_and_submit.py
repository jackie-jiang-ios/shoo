#!/usr/bin/env python3
"""Attach build 13 and submit for review."""
import json, time, requests, jwt

KEY_ID = '29HD53FFYV'
ISSUER_ID = '4b86ecb0-5c72-4d3a-81b8-e6d62a056467'
KEY_PATH = './fastlane/AuthKey_29HD53FFYV.p8'
API_BASE = 'https://api.appstoreconnect.apple.com/v1'
VERSION_ID = '72ab6e5c-5665-4b2c-9d34-2e3a778625b6'
BUILD_ID = '73d59482-3972-47c5-a5a0-ef909d7999d1'  # Build 13

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

# Step 1: Attach build to version
print("=== 1. Attaching build 13 to version 4.0.0 ===")
body = {
    'data': {
        'type': 'appStoreVersions',
        'id': VERSION_ID,
        'relationships': {
            'build': {
                'data': {'type': 'builds', 'id': BUILD_ID}
            }
        }
    }
}
r = requests.patch(f'{API_BASE}/appStoreVersions/{VERSION_ID}', headers=H, json=body)
print(f"  HTTP {r.status_code}")
if r.status_code != 200:
    print(json.dumps(r.json(), indent=2, ensure_ascii=False))
    exit(1)
print(json.dumps(r.json(), indent=2, ensure_ascii=False))

# Step 2: Submit for review
print("\n=== 2. Submitting for review ===")
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
try:
    print(json.dumps(r.json(), indent=2, ensure_ascii=False))
except Exception:
    print(r.text)
