#!/usr/bin/env python3
"""Create pt-PT localization and upload screenshots (Watch + iPhone + iPad)."""
import json, time, os, requests, jwt

KEY_ID = '29HD53FFYV'
ISSUER_ID = '4b86ecb0-5c72-4d3a-81b8-e6d62a056467'
KEY_PATH = './fastlane/AuthKey_29HD53FFYV.p8'
API_BASE = 'https://api.appstoreconnect.apple.com/v1'
VERSION_ID = '72ab6e5c-5665-4b2c-9d34-2e3a778625b6'
LOCALE = 'pt-PT'

def get_token():
    private_key = open(KEY_PATH).read()
    now = int(time.time())
    token = jwt.encode(
        {'iss': ISSUER_ID, 'iat': now, 'exp': now+1200, 'aud': 'appstoreconnect-v1'},
        private_key, algorithm='ES256', headers={'kid': KEY_ID, 'typ': 'JWT'}
    )
    return {'Authorization': f'Bearer {token}', 'Content-Type': 'application/json'}

# 1. Check if pt-PT localization exists
print("=== 1. 检查 pt-PT localization ===")
H = get_token()
r = requests.get(f'{API_BASE}/appStoreVersions/{VERSION_ID}/appStoreVersionLocalizations', headers=H)
locs = r.json().get('data', [])
loc_id = None
for loc in locs:
    if loc['attributes']['locale'] == LOCALE:
        loc_id = loc['id']
        break

if loc_id:
    print(f"  pt-PT EXISTS: {loc_id}")
else:
    print("  pt-PT 不存在，创建中...")
    H = get_token()
    body = {
        'data': {
            'type': 'appStoreVersionLocalizations',
            'attributes': {'locale': LOCALE, 'description': 'A aplicação de sons de animais para manter animais selvagens afastados.', 'keywords': 'animais,som,wildlife,kids,pets', 'marketingUrl': None, 'promotionalText': '', 'supportUrl': None, 'whatsNew': ''},
            'relationships': {'appStoreVersion': {'data': {'type': 'appStoreVersions', 'id': VERSION_ID}}}
        }
    }
    # 实际上 localization 应该已经存在；如果不存在说明已删除。重新 POST。
    r = requests.post(f'{API_BASE}/appStoreVersionLocalizations', headers=H, json=body)
    print(f"  POST HTTP {r.status_code}")
    print(json.dumps(r.json(), indent=2, ensure_ascii=False))
    if r.status_code == 201:
        loc_id = r.json()['data']['id']

if not loc_id:
    print("  ❌ 无法创建 localization")
    exit(1)

# 2. Upload screenshots - all 3 display types
print("\n=== 2. 上传截图 ===")

upload_configs = [
    ('./fastlane/screenshots_watch_44mm', 'APP_WATCH_SERIES_4'),
    ('./fastlane/screenshots', 'APP_IPHONE_65'),
    ('./fastlane/screenshots_ipad', 'APP_IPAD_PRO_3GEN_129'),
]

for img_dir, display_type in upload_configs:
    img_path = f"{img_dir}/{LOCALE}/01_Home.png"
    img_path2 = f"{img_dir}/{LOCALE}/02_Detail.png"
    img_path3 = f"{img_dir}/{LOCALE}/03_Settings.png"

    imgs = [p for p in [img_path, img_path2, img_path3] if os.path.exists(p)]

    if not imgs:
        print(f"  SKIP {display_type}: no images found in {img_dir}/{LOCALE}")
        continue

    print(f"\n  [{display_type}] {len(imgs)} 张图 to upload...")

    # 找到 screenshot set
    H = get_token()
    r = requests.get(f'{API_BASE}/appStoreVersionLocalizations/{loc_id}/appScreenshotSets', headers=H)
    ssets = r.json().get('data', [])
    set_id = None
    for s in ssets:
        if s['attributes']['screenshotDisplayType'] == display_type:
            set_id = s['id']
            break

    if set_id:
        # Delete existing
        H = get_token()
        r = requests.get(f'{API_BASE}/appScreenshotSets/{set_id}/appScreenshots', headers=H)
        for s in r.json().get('data', []):
            H = get_token()
            requests.delete(f'{API_BASE}/appScreenshots/{s["id"]}', headers=H)
        print(f"    Cleared old screenshots from set {set_id}")
    else:
        # Create set
        print(f"    Creating new screenshot set...")
        H = get_token()
        body = {
            'data': {
                'type': 'appScreenshotSets',
                'attributes': {'screenshotDisplayType': display_type},
                'relationships': {'appStoreVersionLocalization': {'data': {'type': 'appStoreVersionLocalizations', 'id': loc_id}}}
            }
        }
        r = requests.post(f'{API_BASE}/appScreenshotSets', headers=H, json=body)
        if r.status_code != 201:
            print(f"    ERROR creating set: {r.status_code} {r.text[:200]}")
            continue
        set_id = r.json()['data']['id']

    # Upload each screenshot
    ok = 0
    for img_file in imgs:
        fname = os.path.basename(img_file)
        fsize = os.path.getsize(img_file)

        # Create reservation
        H = get_token()
        body = {
            'data': {
                'type': 'appScreenshots',
                'attributes': {'fileName': fname, 'fileSize': fsize},
                'relationships': {'appScreenshotSet': {'data': {'type': 'appScreenshotSets', 'id': set_id}}}
            }
        }
        r = requests.post(f'{API_BASE}/appScreenshots', headers=H, json=body)
        if r.status_code != 201:
            print(f"    ERROR reservation {fname}: {r.status_code} {r.text[:200]}")
            continue

        ss_id = r.json()['data']['id']
        upload_ops = r.json()['data']['attributes']['uploadOperations']

        # Upload chunks
        with open(img_file, 'rb') as f:
            for op in upload_ops:
                url = op['url']
                method = op['method']
                offset = op['offset']
                length = op['length']
                headers = {h['name']: h['value'] for h in op['requestHeaders']}
                f.seek(offset)
                chunk = f.read(length)
                r2 = requests.request(method, url, headers=headers, data=chunk)
                if r2.status_code not in [200, 201, 204]:
                    print(f"    ERROR upload {fname}: {r2.status_code}")
                    break
            else:
                # All chunks uploaded, commit
                H = get_token()
                r3 = requests.patch(f'{API_BASE}/appScreenshots/{ss_id}', headers=H,
                                     json={'data': {'type': 'appScreenshots', 'id': ss_id, 'attributes': {'uploaded': True}}})
                if r3.status_code == 200:
                    print(f"    ✓ {fname}")
                    ok += 1
                else:
                    print(f"    ERROR commit {fname}: {r3.status_code}")

    print(f"  [{display_type}] {ok}/{len(imgs)} done")

print("\n=== 完成 ===")
