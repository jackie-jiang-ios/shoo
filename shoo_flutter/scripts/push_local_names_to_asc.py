#!/usr/bin/env python3
"""
将本地的名称推送到 App Store Connect 的 App Info Localization。
从本地 InfoPlist.strings (CFBundleDisplayName) 读取，更新到 ASC。
"""
import json, time, requests, pathlib, jwt, os, re

KEY_ID = '29HD53FFYV'
ISSUER_ID = '4b86ecb0-5c72-4d3a-81b8-e6d62a056467'
KEY_PATH = './fastlane/AuthKey_29HD53FFYV.p8'
APP_ID = '6779087767'

# ===== 1. 从本地 InfoPlist.strings 读取正确的名称 =====
local_names = {}
plists_dir = './ios/Runner'

for lang_dir in os.listdir(plists_dir):
    plist_path = os.path.join(plists_dir, lang_dir, 'InfoPlist.strings')
    if os.path.isfile(plist_path) and lang_dir.endswith('.lproj'):
        lang = lang_dir.replace('.lproj', '')
        with open(plist_path, 'r', encoding='utf-8') as f:
            content = f.read()
        # 提取 CFBundleDisplayName
        m = re.search(r'"CFBundleDisplayName"\s*=\s*"([^"]+)"', content)
        if m:
            local_names[lang] = m.group(1)

print(f"从本地 InfoPlist.strings 读取了 {len(local_names)} 个语言名称")

# ===== 2. 从 ASC 读取当前名称 =====
private_key = pathlib.Path(KEY_PATH).read_text()
now = int(time.time())
token = jwt.encode(
    {'iss': ISSUER_ID, 'iat': now, 'exp': now+1200, 'aud': 'appstoreconnect-v1'},
    private_key, algorithm='ES256', headers={'kid': KEY_ID, 'typ': 'JWT'}
)
H = {'Authorization': f'Bearer {token}', 'Content-Type': 'application/json'}

r = requests.get(f'https://api.appstoreconnect.apple.com/v1/apps/{APP_ID}/appInfos', headers=H, timeout=30)
app_infos = r.json().get('data', [])

# 收集所有远程名称
remote_locs = {}  # locale -> (current_name, loc_id)
for info in app_infos:
    info_id = info['id']
    r2 = requests.get(f'https://api.appstoreconnect.apple.com/v1/appInfos/{info_id}/appInfoLocalizations', headers=H, timeout=30)
    for loc in r2.json().get('data', []):
        locale = loc['attributes']['locale']
        loc_id = loc['id']
        r3 = requests.get(f'https://api.appstoreconnect.apple.com/v1/appInfoLocalizations/{loc_id}', headers=H, timeout=30)
        name = r3.json().get('data', {}).get('attributes', {}).get('name', '')
        remote_locs[locale] = (name, loc_id)

# ===== 3. 对比并更新 =====
print(f"\n{'Locale':<12} {'本地名称':<25} {'远程名称':<25} {'操作'}")
print("-" * 85)

fixed = []
skipped = []
errors = []

def normalize_lang(lang):
    """统一语言代码：zh-Hans -> zh-Hans, en -> en"""
    # ASC 用的格式如 zh-Hans, en-US
    return lang

# 建立本地语言到 ASC 语言的映射
lang_map = {}
for local_lang in local_names:
    # 直接匹配
    if local_lang in remote_locs:
        lang_map[local_lang] = local_lang
        continue
    # 尝试匹配语言前缀
    base = local_lang.split('-')[0]
    for remote_lang in remote_locs:
        if remote_lang.startswith(base) or base == remote_lang.split('-')[0]:
            lang_map[local_lang] = remote_lang
            break

for local_lang, local_name in sorted(local_names.items()):
    remote_lang = lang_map.get(local_lang)
    if not remote_lang:
        skipped.append((local_lang, local_name, '远程无对应语言'))
        continue
    
    remote_name, loc_id = remote_locs[remote_lang]
    if remote_name == local_name:
        skipped.append((local_lang, local_name, '一致'))
        print(f"{local_lang:<12} {local_name:<25} {remote_name:<25} ✅ 一致")
        continue
    
    # 更新
    print(f"{local_lang:<12} {local_name:<25} {remote_name:<25} 🔄 更新中...")
    payload = {
        "data": {
            "type": "appInfoLocalizations",
            "id": loc_id,
            "attributes": {"name": local_name}
        }
    }
    r4 = requests.patch(
        f'https://api.appstoreconnect.apple.com/v1/appInfoLocalizations/{loc_id}',
        headers=H, json=payload, timeout=30
    )
    if r4.status_code in [200, 201]:
        fixed.append((local_lang, remote_name, local_name))
    else:
        errors.append((local_lang, r4.status_code, r4.text[:100]))
        print(f"     ❌ 错误: {r4.status_code}")

print(f"\n{'='*70}")
print(f"✅ 完成! 已更新: {len(fixed)}, 跳过: {len(skipped)}, 错误: {len(errors)}")
if errors:
    print("错误:")
    for lang, code, msg in errors:
        print(f"  {lang}: {code}")
