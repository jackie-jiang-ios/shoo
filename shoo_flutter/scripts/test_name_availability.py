#!/usr/bin/env python3
"""Test if app names are available in App Store Connect."""
import json, time, requests, pathlib, jwt

KEY_ID = '29HD53FFYV'
ISSUER_ID = '4b86ecb0-5c72-4d3a-81b8-e6d62a056467'
KEY_PATH = './fastlane/AuthKey_29HD53FFYV.p8'
APP_ID = '6779087767'

private_key = pathlib.Path(KEY_PATH).read_text()
now = int(time.time())
token = jwt.encode(
    {'iss': ISSUER_ID, 'iat': now, 'exp': now+1200, 'aud': 'appstoreconnect-v1'},
    private_key, algorithm='ES256', headers={'kid': KEY_ID, 'typ': 'JWT'}
)
H = {'Authorization': f'Bearer {token}', 'Content-Type': 'application/json'}

# 获取可修改的 App Info Localization (c09b2188...)
r = requests.get(f'https://api.appstoreconnect.apple.com/v1/apps/{APP_ID}/appInfos', headers=H, timeout=30)
app_infos = r.json().get('data', [])

loc_id = None
for info in app_infos:
    info_id = info['id']
    r2 = requests.get(f'https://api.appstoreconnect.apple.com/v1/appInfos/{info_id}/appInfoLocalizations', headers=H, timeout=30)
    for loc in r2.json().get('data', []):
        if loc['attributes']['locale'] == 'en-US':
            if info_id.startswith('c09b'):
                loc_id = loc['id']
                break

if not loc_id:
    print("未找到可修改的 en-US localization")
    exit(1)

print(f"测试名称 (使用 loc_id: {loc_id})")
print("-" * 50)

# 测试的名称列表
test_names = [
    "Shoo Repellent",
    "Animal Repellent Sound",
    "Animal Deterrent",
    "Sound Repellent",
    "Wild Animal Repellent",
    "Animal Scare",
    "Repel Animals",
]

for name in test_names:
    payload = {
        "data": {
            "type": "appInfoLocalizations",
            "id": loc_id,
            "attributes": {"name": name}
        }
    }
    r3 = requests.patch(
        f'https://api.appstoreconnect.apple.com/v1/appInfoLocalizations/{loc_id}',
        headers=H, json=payload, timeout=30
    )
    
    if r3.status_code in [200, 201]:
        print(f"  ✅ '{name}' — 可用!")
    else:
        error = r3.json().get('errors', [{}])[0]
        detail = error.get('detail', '')[:60]
        print(f"  ❌ '{name}' — {detail}")
