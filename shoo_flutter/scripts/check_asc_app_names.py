#!/usr/bin/env python3
"""Check ALL app names in App Store Connect - both app-level and version-level."""
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
print("� App Store Connect 详细名称检查")
print("=" * 70)

# 1. 获取 App 信息
r = requests.get(f'https://api.appstoreconnect.apple.com/v1/apps/{APP_ID}', headers=H)
app_data = r.json()
print(f"\n� App 基本信息:")
print(f"   name: {app_data.get('data', {}).get('attributes', {}).get('name', 'N/A')}")
print(f"   bundleId: {app_data.get('data', {}).get('attributes', {}).get('bundleId', 'N/A')}")

# 2. 获取所有 App Store 版本
r = requests.get(f'https://api.appstoreconnect.apple.com/v1/apps/{APP_ID}/appStoreVersions', headers=H)
versions = r.json().get('data', [])
print(f"\n📦 共有 {len(versions)} 个 App Store 版本:")

for ver in versions:
    ver_id = ver['id']
    ver_string = ver['attributes']['versionString']
    platform = ver['attributes']['platform']
    state = ver['attributes'].get('appStoreState', 'N/A')
    
    print(f"\n{'='*70}")
    print(f"   版本: {ver_string} ({platform}) - 状态: {state}")
    print(f"   ID: {ver_id}")
    print(f"{'='*70}")
    
    # 获取该版本的本地化信息
    r2 = requests.get(f'https://api.appstoreconnect.apple.com/v1/appStoreVersions/{ver_id}/appStoreVersionLocalizations', headers=H)
    locs = r2.json().get('data', [])
    
    for loc in sorted(locs, key=lambda x: x['attributes']['locale']):
        loc_id = loc['id']
        locale = loc['attributes']['locale']
        # 获取详细本地化信息
        r3 = requests.get(f'https://api.appstoreconnect.apple.com/v1/appStoreVersionLocalizations/{loc_id}', headers=H)
        loc_detail = r3.json().get('data', {}).get('attributes', {})
        app_name = loc_detail.get('appName', '未设置')
        print(f"   {locale:<12} → {app_name}")
    
    # 只检查前几个版本
    if ver_string != '4.0.0':
        print(f"   ... (跳过其他版本详细检查)")

print("\n" + "=" * 70)
print("� 检查是否有 'Shoo!' 残留")
print("=" * 70)

# 4.0.0 版本详细检查
print("\n� 当前版本 4.0.0 的详细信息:")
r = requests.get(f"https://api.appstoreconnect.apple.com/v1/appStoreVersions/72ab6e5c-5665-4b2c-9d34-2e3a778625b6", headers=H)
ver_detail = r.json().get('data', {}).get('attributes', {})
print(f"   状态: {ver_detail.get('appStoreState', 'N/A')}")

# 5. 检查 Ready for Sale / Pending 版本
print("\n📌 Ready for Sale 版本:")
r = requests.get(f'https://api.appstoreconnect.apple.com/v1/apps/{APP_ID}/appStoreVersions?filter[appStoreState]=READY_FOR_SALE', headers=H)
rfs_versions = r.json().get('data', [])
print(f"   数量: {len(rfs_versions)}")
for v in rfs_versions:
    print(f"   - {v['attributes']['versionString']}")

r = requests.get(f'https://api.appstoreconnect.apple.com/v1/apps/{APP_ID}/appStoreVersions?filter[appStoreState]=PREPARE_FOR_SUBMISSION', headers=H)
pfs_versions = r.json().get('data', [])
print(f"📌 Prepare for Submission 版本:")
print(f"   数量: {len(pfs_versions)}")
for v in pfs_versions:
    print(f"   - {v['attributes']['versionString']}")
