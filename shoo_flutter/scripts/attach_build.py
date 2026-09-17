#!/usr/bin/env python3
"""Attach a build to the app store version and attempt review submission."""
import json, time, requests, jwt

KEY_ID = '29HD53FFYV'
ISSUER_ID = '4b86ecb0-5c72-4d3a-81b8-e6d62a056467'
KEY_PATH = './fastlane/AuthKey_29HD53FFYV.p8'
API_BASE = 'https://api.appstoreconnect.apple.com/v1'
APP_ID = '6779087767'
VERSION_ID = '72ab6e5c-5665-4b2c-9d34-2e3a778625b6'

def get_token():
    private_key = open(KEY_PATH).read()
    now = int(time.time())
    token = jwt.encode(
        {'iss': ISSUER_ID, 'iat': now, 'exp': now + 1200, 'aud': 'appstoreconnect-v1'},
        private_key, algorithm='ES256',
        headers={'kid': KEY_ID, 'typ': 'JWT'},
    )
    return {
        'Authorization': f'Bearer {token}',
        'Content-Type': 'application/json',
    }

H = get_token()

# 1. Find latest build
print("=== 1. Searching builds for Shoo (iOS) ===")
r = requests.get(f'{API_BASE}/apps/{APP_ID}/builds', headers=H)
builds = r.json().get('data', [])
print(f"  Total builds listed: {len(builds)}")

for b in builds[:5]:
    attr = b['attributes']
    bid = b['id']
    print(f"    build {attr.get('version')!r:8s} "
          f"platform={attr.get('platform')!r:6s} "
          f"state={attr.get('processingState')!r:12s} "
          f"expired={attr.get('expired')}  id={bid}")

# 2. Find a good usable build
good = next(
    (b for b in builds
     if b['attributes'].get('platform') == 'IOS'
     and not b['attributes'].get('expired')
     and b['attributes'].get('processingState') == 'VALID'),
    None,
)
if not good:
    print("\n  � No usable iOS build found")
    exit(1)

good_id = good['id']
good_version = good['attributes']['version']
print(f"\n  ✓ Selected build: {good_version} (id={good_id})")

# 3. Try to attach
print("\n=== 2. Try attaching build ===")
body = {
    'data': {
        'type': 'appStoreVersions',
        'id': VERSION_ID,
        'relationships': {
            'build': {
                'data': {
                    'type': 'builds',
                    'id': good_id,
                },
            },
        },
    },
}
r = requests.patch(f'{API_BASE}/appStoreVersions/{VERSION_ID}', headers=H, json=body)
print(f"  HTTP {r.status_code}")
if r.status_code != 200:
    print(json.dumps(r.json(), indent=2, ensure_ascii=False))
    exit(1)

print(json.dumps(r.json(), indent=2, ensure_ascii=False))

# 4. Try submitting the version for review
print("\n=== 3. Submit for review attempt ===")
body = {
    'data': {
        'type': 'appStoreVersionSubmissions',
        'relationships': {
            'appStoreVersion': {
                'data': {
                    'type': 'appStoreVersions',
                    'id': VERSION_ID,
                },
            },
        },
    },
}
r = requests.post(f'{API_BASE}/appStoreVersionSubmissions', headers=H, json=body)
print(f"  HTTP {r.status_code}")
print(json.dumps(r.json(), indent=2, ensure_ascii=False))
