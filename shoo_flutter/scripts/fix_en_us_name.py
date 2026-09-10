#!/usr/bin/env python3
"""Fix en-US app name - get detailed error and try alternative approach."""
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

# 找到 en-US 的 loc_id
r = requests.get(f'https://api.appstoreconnect.apple.com/v1/apps/{APP_ID}/appInfos', headers=H, timeout=30)
app_infos = r.json().get('data', [])

for info in app_infos:
    info_id = info['id']
    r2 = requests.get(f'https://api.appstoreconnect.apple.com/v1/appInfos/{info_id}/appInfoLocalizations', headers=H, timeout=30)
    for loc in r2.json().get('data', []):
        locale = loc['attributes']['locale']
        if locale == 'en-US':
            loc_id = loc['id']
            print(f"找到 en-US localization: {loc_id} (App Info: {info_id})")
            
            # 尝试 PATCH
            payload = {
                "data": {
                    "type": "appInfoLocalizations",
                    "id": loc_id,
                    "attributes": {"name": "Animal Repellent"}
                }
            }
            r3 = requests.patch(
                f'https://api.appstoreconnect.apple.com/v1/appInfoLocalizations/{loc_id}',
                headers=H, json=payload, timeout=30
            )
            print(f"Status: {r3.status_code}")
            print(f"Response: {r3.text}")
            break
