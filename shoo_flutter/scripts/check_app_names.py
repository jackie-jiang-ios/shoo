#!/usr/bin/env python3
"""Check app names in App Store Connect vs local configuration."""
import json, time, requests, pathlib, jwt

KEY_ID = '29HD53FFYV'
ISSUER_ID = '4b86ecb0-5c72-4d3a-81b8-e6d62a056467'
KEY_PATH = './fastlane/AuthKey_29HD53FFYV.p8'
APP_ID = '6779087767'

private_key = pathlib.Path(KEY_PATH).read_text()
now = int(time.time())
token = jwt.encode({'iss': ISSUER_ID, 'iat': now, 'exp': now+1200, 'aud': 'appstoreconnect-v1'}, private_key, algorithm='ES256', headers={'kid': KEY_ID, 'typ': 'JWT'})
H = {'Authorization': f'Bearer {token}', 'Content-Type': 'application/json'}

print("=" * 60)
print("App Store Connect 中的名称")
print("=" * 60)

# 1. 获取 App 级别名称
r = requests.get(f'https://api.appstoreconnect.apple.com/v1/apps/{APP_ID}', headers=H)
app_data = r.json().get('data', {}).get('attributes', {})
print(f"\n� App 级别名称:")
print(f"   name: {app_data.get('name', 'N/A')}")
print(f"   bundleId: {app_data.get('bundleId', 'N/A')}")

# 2. 获取 App Store 版本本地化信息
print(f"\n� App Store 版本 4.0.0 的本地化名称:")
print(f"   (Version ID: 72ab6e5c-5665-4b2c-9d34-2e3a778625b6)")

version_id = '72ab6e5c-5665-4b2c-9d34-2e3a778625b6'
r = requests.get(f'https://api.appstoreconnect.apple.com/v1/appStoreVersions/{version_id}/appStoreVersionLocalizations', headers=H)
locs = r.json().get('data', [])

print(f"\n{'Locale':<12} {'App Name':<30} {'ID'}")
print("-" * 70)
for loc in sorted(locs, key=lambda x: x['attributes']['locale']):
    locale = loc['attributes']['locale']
    app_name = loc['attributes'].get('appName', 'N/A')
    loc_id = loc['id']
    print(f"{locale:<12} {app_name:<30} {loc_id}")

print("\n" + "=" * 60)
print("本地代码中的名称配置")
print("=" * 60)

# 本地 fastlane metadata name.txt
print("\n� fastlane/metadata/ 中的 name.txt:")
import os
metadata_dir = './fastlane/metadata'
for lang_dir in sorted(os.listdir(metadata_dir)):
    name_file = os.path.join(metadata_dir, lang_dir, 'name.txt')
    if os.path.exists(name_file):
        with open(name_file, 'r') as f:
            name = f.read().strip()
        print(f"   {lang_dir:<12} → {name}")

# 本地 Info.plist
print("\n� InfoPlist.strings 中的 CFBundleDisplayName:")
import glob
for plist_file in sorted(glob.glob('./ios/Runner/*/InfoPlist.strings')):
    lang = plist_file.split('/')[-2]
    with open(plist_file, 'r') as f:
        content = f.read()
    # 提取 CFBundleDisplayName
    for line in content.split('\n'):
        if 'CFBundleDisplayName' in line and '"' in line:
            name = line.split('"')[3] if '"' in line else 'N/A'
            print(f"   {lang:<12} → {name}")
            break

print("\n" + "=" * 60)
print("� 对比总结")
print("=" * 60)
