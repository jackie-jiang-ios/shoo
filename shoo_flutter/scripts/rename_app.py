#!/usr/bin/env python3
"""Rename app to 'Animal Deterrent' - update remote ASC and all local files."""
import json, time, requests, pathlib, jwt, os, re

OLD_NAME = "Animal Repellent"
NEW_NAME = "Animal Deterrent"
APP_ID = '6779087767'

# ========== PART 1: Update remote ASC ==========
print("=" * 70)
print("PART 1: 更新 App Store Connect")
print("=" * 70)

KEY_ID = '29HD53FFYV'
ISSUER_ID = '4b86ecb0-5c72-4d3a-81b8-e6d62a056467'
KEY_PATH = './fastlane/AuthKey_29HD53FFYV.p8'

private_key = pathlib.Path(KEY_PATH).read_text()
now = int(time.time())
token = jwt.encode(
    {'iss': ISSUER_ID, 'iat': now, 'exp': now+1200, 'aud': 'appstoreconnect-v1'},
    private_key, algorithm='ES256', headers={'kid': KEY_ID, 'typ': 'JWT'}
)
H = {'Authorization': f'Bearer {token}', 'Content-Type': 'application/json'}

r = requests.get(f'https://api.appstoreconnect.apple.com/v1/apps/{APP_ID}/appInfos', headers=H, timeout=30)
app_infos = r.json().get('data', [])

for info in app_infos:
    info_id = info['id']
    r2 = requests.get(f'https://api.appstoreconnect.apple.com/v1/appInfos/{info_id}/appInfoLocalizations', headers=H, timeout=30)
    for loc in r2.json().get('data', []):
        locale = loc['attributes']['locale']
        loc_id = loc['id']
        # 获取当前名称
        r3 = requests.get(f'https://api.appstoreconnect.apple.com/v1/appInfoLocalizations/{loc_id}', headers=H, timeout=30)
        current = r3.json().get('data', {}).get('attributes', {}).get('name', '')
        
        if current == OLD_NAME or current.startswith('Shoo'):
            payload = {"data": {"type": "appInfoLocalizations", "id": loc_id, "attributes": {"name": NEW_NAME}}}
            r4 = requests.patch(
                f'https://api.appstoreconnect.apple.com/v1/appInfoLocalizations/{loc_id}',
                headers=H, json=payload, timeout=30
            )
            status = "OK" if r4.status_code in [200,201] else f"FAIL({r4.status_code})"
            print(f"  {locale}: '{current}' -> '{NEW_NAME}' [{status}]")

# ========== PART 2: Update local files ==========
print(f"\n{'='*70}")
print("PART 2: 更新本地文件")
print("=" * 70)

def replace_in_file(filepath, old, new, is_info_plist=False):
    """Replace old name with new in a file."""
    if not os.path.exists(filepath):
        return 'miss'
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    if is_info_plist:
        # InfoPlist.strings: replace in CFBundleDisplayName and CFBundleName
        new_content = content.replace(f'"{old}"', f'"{new}"')
    else:
        new_content = content.replace(old, new)
    
    if new_content != content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
        return 'ok'
    return 'skip'

# 2.1 Update InfoPlist.strings (en, en-AU, en-CA, en-GB)
langs = ['en', 'en-AU', 'en-CA', 'en-GB']
for lang in langs:
    path = f'./ios/Runner/{lang}.lproj/InfoPlist.strings'
    result = replace_in_file(path, OLD_NAME, NEW_NAME, is_info_plist=True)
    print(f"  InfoPlist {lang}: {result}")

# 2.2 Update fastlane metadata
for lang in ['en-US', 'en-AU', 'en-CA', 'en-GB']:
    path = f'./fastlane/metadata/{lang}/name.txt'
    result = replace_in_file(path, OLD_NAME, NEW_NAME)
    print(f"  fastlane {lang}: {result}")

# 2.3 Update ShooWatchApp Localizable.strings (app_name)
print("\n  ShooWatchApp Localizable.strings:")
watch_base = '/Users/jiangzheng/Project/iOS/Shoo/ShooWatchApp'
for lang in os.listdir(watch_base):
    l10n_path = os.path.join(watch_base, lang, 'Localizable.strings')
    if os.path.isfile(l10n_path):
        with open(l10n_path, 'r', encoding='utf-8') as f:
            content = f.read()
        if 'Shoo!' in content or OLD_NAME in content:
            new_content = content.replace('"app_name" = "Shoo!"', f'"app_name" = "{NEW_NAME}"')
            new_content = new_content.replace(f'"app_name" = "{OLD_NAME}"', f'"app_name" = "{NEW_NAME}"')
            with open(l10n_path, 'w', encoding='utf-8') as f:
                f.write(new_content)
            print(f"    {lang}: ok")

print("\n✅ Done! All updated to 'Animal Deterrent'")
