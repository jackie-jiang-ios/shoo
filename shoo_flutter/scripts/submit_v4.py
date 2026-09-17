#!/usr/bin/env python3
"""Try v2 and v3 API for appStoreReleaseRequests."""
import json, time, requests, jwt

KEY_ID = '29HD53FFYV'
ISSUER_ID = '4b86ecb0-5c72-4d3a-81b8-e6d62a056467'
KEY_PATH = './fastlane/AuthKey_29HD53FFYV.p8'
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

# Try different API versions
for ver in ['v1', 'v2']:
    base = f'https://api.appstoreconnect.apple.com/{ver}'
    print(f"\n=== Trying {base} ===")
    
    r = requests.post(f'{base}/appStoreReleaseRequests', headers=get_token(),
                     json={'data': {'type': 'appStoreReleaseRequests',
                                   'relationships': {'appStoreVersion': {'data': {'type': 'appStoreVersions', 'id': VERSION_ID}}}}})
    print(f"  HTTP {r.status_code}")
    print(f"  {r.text[:300]}")

# Also try the newer "release" endpoint
print("\n=== 尝试 releases ===")
base = f'https://api.appstoreconnect.apple.com/v1'
r = requests.post(f'{base}/appStoreVersions/{VERSION_ID}/releaseRequests', headers=get_token(),
                 json={'data': {'id': VERSION_ID, 'type': 'releaseRequests'}})
print(f"  HTTP {r.status_code}")
print(f"  {r.text[:300]}")
