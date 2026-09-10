#!/usr/bin/env python3
"""Quick check app names in App Store Connect."""
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
print("App Store Connect 名称检查")
print("=" * 70)

# 1. App 信息
r = requests.get(f'https://api.appstoreconnect.apple.com/v1/apps/{APP_ID}', headers=H, timeout=30)
app_data = r.json()
print(f"\n[App 基本信息]")
print(f"   name: {app_data.get('data', {}).get('attributes', {}).get('name', 'N/A')}")

# 2. 所有版本
r = requests.get(f'https://api.appstoreconnect.apple.com/v1/apps/{APP_ID}/appStoreVersions', headers=H, timeout=30)
versions = r.json().get('data', [])
print(f"\n[所有 App Store 版本] ({len(versions)} 个)")

for ver in versions:
    ver_id = ver['id']
    ver_string = ver['attributes']['versionString']
    state = ver['attributes'].get('appStoreState', 'N/A')
    print(f"\n--- {ver_string} (状态: {state}) ---")
    
    # 获取本地化
    r2 = requests.get(f'https://api.appstoreconnect.apple.com/v1/appStoreVersions/{ver_id}/appStoreVersionLocalizations', headers=H, timeout=30)
    locs = r2.json().get('data', [])
    
    # 只检查 en-US 和 zh-Hans
    for loc in locs:
        locale = loc['attributes']['locale']
        if locale in ['en-US', 'zh-Hans', 'zh-Hant']:
            loc_id = loc['id']
            r3 = requests.get(f'https://api.appstoreconnect.apple.com/v1/appStoreVersionLocalizations/{loc_id}', headers=H, timeout=30)
            loc_detail = r3.json().get('data', {}).get('attributes', {})
            app_name = loc_detail.get('appName', '未设置')
            print(f"   {locale:<10} → {app_name}")
