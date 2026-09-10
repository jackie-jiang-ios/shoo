#!/usr/bin/env python3
"""
Fix App Store Connect app names to match local configuration.
Update App Info Localization names from "Shoo!" / "Shoo! Animal Repellent" to proper names.
"""
import json, time, requests, pathlib, jwt, os

KEY_ID = '29HD53FFYV'
ISSUER_ID = '4b86ecb0-5c72-4d3a-81b8-e6d62a056467'
KEY_PATH = './fastlane/AuthKey_29HD53FFYV.p8'
APP_ID = '6779087767'

# 从本地 fastlane/metadata 读取正确的名称
CORRECT_NAMES = {}
metadata_dir = './fastlane/metadata'
for lang_dir in os.listdir(metadata_dir):
    name_file = os.path.join(metadata_dir, lang_dir, 'name.txt')
    if os.path.exists(name_file):
        with open(name_file, 'r', encoding='utf-8') as f:
            name = f.read().strip()
        CORRECT_NAMES[lang_dir] = name

private_key = pathlib.Path(KEY_PATH).read_text()
now = int(time.time())
token = jwt.encode({'iss': ISSUER_ID, 'iat': now, 'exp': now+1200, 'aud': 'appstoreconnect-v1'}, private_key, algorithm='ES256', headers={'kid': KEY_ID, 'typ': 'JWT'})
H = {'Authorization': f'Bearer {token}', 'Content-Type': 'application/json'}

print("=" * 70)
print("修复 App Store Connect 中的应用名称")
print("=" * 70)
print(f"从本地加载了 {len(CORRECT_NAMES)} 个语言名称")

# 获取所有 App Info
r = requests.get(f'https://api.appstoreconnect.apple.com/v1/apps/{APP_ID}/appInfos', headers=H, timeout=30)
app_infos = r.json().get('data', [])

fixed = []
skipped = []
errors = []

for info in app_infos:
    info_id = info['id']
    
    # 获取本地化
    r2 = requests.get(f'https://api.appstoreconnect.apple.com/v1/appInfos/{info_id}/appInfoLocalizations', headers=H, timeout=30)
    locs = r2.json().get('data', [])
    
    for loc in locs:
        locale = loc['attributes']['locale']
        loc_id = loc['id']
        
        # 获取当前名称
        r3 = requests.get(f'https://api.appstoreconnect.apple.com/v1/appInfoLocalizations/{loc_id}', headers=H, timeout=30)
        current_name = r3.json().get('data', {}).get('attributes', {}).get('name', '')
        
        # 尝试找对应的本地名称
        correct_name = CORRECT_NAMES.get(locale)
        
        if not correct_name:
            # 尝试去掉区域后缀匹配
            base_lang = locale.split('-')[0] if '-' in locale else locale
            for k, v in CORRECT_NAMES.items():
                if k.startswith(base_lang):
                    correct_name = v
                    break
        
        if not correct_name:
            skipped.append((locale, current_name, '无对应翻译'))
            continue
        
        if current_name == correct_name:
            skipped.append((locale, current_name, '一致'))
            continue
        
        # 需要更新
        print(f"  [{info_id[:8]}] {locale}: '{current_name}' → '{correct_name}'")
        
        # 调用 PATCH 更新
        payload = {
            "data": {
                "type": "appInfoLocalizations",
                "id": loc_id,
                "attributes": {
                    "name": correct_name
                }
            }
        }
        r4 = requests.patch(
            f'https://api.appstoreconnect.apple.com/v1/appInfoLocalizations/{loc_id}',
            headers=H,
            json=payload,
            timeout=30
        )
        
        if r4.status_code in [200, 201]:
            fixed.append((locale, current_name, correct_name))
        else:
            errors.append((locale, r4.status_code, r4.text))
            print(f"    错误: {r4.status_code}")

print(f"\n{'='*70}")
print(f"✅ 修复完成!")
print(f"   已修复: {len(fixed)} 个")
print(f"   错误: {len(errors)} 个")
print(f"   跳过: {len(skipped)} 个")
print(f"{'='*70}")

if errors:
    print("\n❌ 错误详情:")
    for locale, code, msg in errors:
        print(f"  {locale}: {code}")

print("\n已修复的项目:")
for locale, old, new in fixed:
    print(f"  {locale}: '{old}' → '{new}'")
