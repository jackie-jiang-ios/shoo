#!/usr/bin/env python3
"""Check app info names in App Store Connect."""
import json, time, requests, pathlib, jwt

KEY_ID = '29HD53FFYV'
ISSUER_ID = '4b86ecb0-5c72-4d3a-81b8-e6d62a056467'
KEY_PATH = './fastlane/AuthKey_29HD53FFYV.p8'
APP_ID = '6779087767'

private_key = pathlib.Path(KEY_PATH).read_text()
now = int(time.time())
token = jwt.encode({'iss': ISSUER_ID, 'iat': now, 'exp': now+1200, 'aud': 'appstoreconnect-v1'}, private_key, algorithm='ES256', headers={'kid': KEY_ID, 'typ': 'JWT'})
H = {'Authorization': f'Bearer {token}', 'Content-Type': 'application/json'}

print("=" * 70)
print("App Store Connect - App Info 名称检查")
print("=" * 70)

# 获取 App Info
r = requests.get(f'https://api.appstoreconnect.apple.com/v1/apps/{APP_ID}/appInfos', headers=H, timeout=30)
app_infos = r.json().get('data', [])
print(f"\n[App Info] ({len(app_infos)} 个)")

for info in app_infos:
    info_id = info['id']
    info_type = info['attributes'].get('appInfoCategory', 'N/A')
    print(f"\n  App Info: {info_type} (ID: {info_id})")
    
    # 获取本地化
    r2 = requests.get(f'https://api.appstoreconnect.apple.com/v1/appInfos/{info_id}/appInfoLocalizations', headers=H, timeout=30)
    locs = r2.json().get('data', [])
    
    for loc in locs:
        locale = loc['attributes']['locale']
        loc_id = loc['id']
        r3 = requests.get(f'https://api.appstoreconnect.apple.com/v1/appInfoLocalizations/{loc_id}', headers=H, timeout=30)
        loc_detail = r3.json().get('data', {}).get('attributes', {})
        name = loc_detail.get('name', 'N/A')
        subtitle = loc_detail.get('subtitle', 'N/A')
        print(f"    {locale:<10} → name: {name}, subtitle: {subtitle}")

# 也直接获取 App Store 版本的完整 JSON 看看有哪些字段
print("\n" + "=" * 70)
print("App Store Version Localization 完整字段")
print("=" * 70)
version_id = '72ab6e5c-5665-4b2c-9d34-2e3a778625b6'
r = requests.get(f'https://api.appstoreconnect.apple.com/v1/appStoreVersions/{version_id}/appStoreVersionLocalizations', headers=H, timeout=30)
locs = r.json().get('data', [])

for loc in locs:
    if loc['attributes']['locale'] == 'en-US':
        loc_id = loc['id']
        r2 = requests.get(f'https://api.appstoreconnect.apple.com/v1/appStoreVersionLocalizations/{loc_id}', headers=H, timeout=30)
        print(f"\n  en-US 完整属性:")
        attrs = r2.json().get('data', {}).get('attributes', {})
        for k, v in attrs.items():
            print(f"    {k}: {v}")
        break
