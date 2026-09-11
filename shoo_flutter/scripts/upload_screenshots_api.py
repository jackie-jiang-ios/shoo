#!/usr/bin/env python3
"""
Upload screenshots using App Store Connect API directly.
More reliable than fastlane deliver for screenshots.

Usage:
  python3 scripts/upload_screenshots_api.py en-US
  python3 scripts/upload_screenshots_api.py all
  python3 scripts/upload_screenshots_api.py all --platform ipad
  python3 scripts/upload_screenshots_api.py all --platform watch
  python3 scripts/upload_screenshots_api.py en-US --platform ipad
"""
import json, time, os, sys, pathlib, requests, jwt

# Config
KEY_ID = '29HD53FFYV'
ISSUER_ID = '4b86ecb0-5c72-4d3a-81b8-e6d62a056467'
KEY_PATH = './fastlane/AuthKey_29HD53FFYV.p8'

API_BASE = 'https://api.appstoreconnect.apple.com/v1'
VERSION_ID = '72ab6e5c-5665-4b2c-9d34-2e3a778625b6'  # 4.0.0

# Display types
IPHONE_DIR = './fastlane/screenshots'
IPAD_DIR = './fastlane/screenshots_ipad'
WATCH_DIR = './fastlane/screenshots_watch'
IPHONE_DISPLAY = 'APP_IPHONE_65'          # iPhone 14 Plus 6.5" 1284x2778
IPAD_DISPLAY = 'APP_IPAD_PRO_3GEN_129'    # iPad Pro 12.9" 3rd gen+ / 13" (M5) 2064x2752
WATCH_DISPLAY = 'APP_WATCH_SERIES_4'      # Apple Watch Series 4+ 44mm 312x390

# Map screenshot directory names to ASC locale codes
LOCALE_MAP = {
    'bn': 'bn-BD', 'gu': 'gu-IN', 'kn': 'kn-IN', 'ml': 'ml-IN',
    'mr': 'mr-IN', 'or': 'or-IN', 'pa': 'pa-IN', 'sl': 'sl-SI',
    'ta': 'ta-IN', 'te': 'te-IN', 'ur': 'ur-PK',
}


def get_token():
    private_key = pathlib.Path(KEY_PATH).read_text()
    now = int(time.time())
    token = jwt.encode(
        {'iss': ISSUER_ID, 'iat': now, 'exp': now+1200, 'aud': 'appstoreconnect-v1'},
        private_key, algorithm='ES256', headers={'kid': KEY_ID, 'typ': 'JWT'}
    )
    return {'Authorization': f'Bearer {token}', 'Content-Type': 'application/json'}


def get_localization_id(H, locale):
    r = requests.get(f'{API_BASE}/appStoreVersions/{VERSION_ID}/appStoreVersionLocalizations', headers=H)
    for loc in r.json().get('data', []):
        if loc['attributes']['locale'] == locale:
            return loc['id']
    return None


def get_screenshot_set(H, loc_id, display_type):
    r = requests.get(f'{API_BASE}/appStoreVersionLocalizations/{loc_id}/appScreenshotSets', headers=H)
    sets = r.json().get('data', [])
    for s in sets:
        if s['attributes']['screenshotDisplayType'] == display_type:
            return s['id']
    return None


def delete_existing_screenshots(H, set_id):
    r = requests.get(f'{API_BASE}/appScreenshotSets/{set_id}/appScreenshots', headers=H)
    for s in r.json().get('data', []):
        sid = s['id']
        r2 = requests.delete(f'{API_BASE}/appScreenshots/{sid}', headers=H)
        if r2.status_code in [204, 200]:
            print(f"    Deleted: {s['attributes']['fileName']}")
        else:
            print(f"    WARNING delete {sid}: {r2.status_code}")


def upload_screenshot(H, set_id, filepath):
    file_size = os.path.getsize(filepath)
    file_name = os.path.basename(filepath)

    # 1. Create reservation
    body = {
        'data': {
            'type': 'appScreenshots',
            'attributes': {'fileName': file_name, 'fileSize': file_size},
            'relationships': {'appScreenshotSet': {'data': {'type': 'appScreenshotSets', 'id': set_id}}}
        }
    }
    r = requests.post(f'{API_BASE}/appScreenshots', headers=H, json=body)
    if r.status_code != 201:
        print(f"  ERROR reservation: {r.status_code} {r.text[:200]}")
        return False

    ss_id = r.json()['data']['id']
    upload_ops = r.json()['data']['attributes']['uploadOperations']

    # 2. Upload to S3
    with open(filepath, 'rb') as f:
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
                print(f"  ERROR upload part: {r2.status_code}")
                requests.delete(f'{API_BASE}/appScreenshots/{ss_id}', headers=H)
                return False

    # 3. Commit
    r3 = requests.patch(f'{API_BASE}/appScreenshots/{ss_id}', headers=H,
                         json={'data': {'type': 'appScreenshots', 'id': ss_id, 'attributes': {'uploaded': True}}})
    if r3.status_code == 200:
        print(f"  OK: {file_name}")
        return True
    else:
        print(f"  ERROR commit: {r3.status_code} {r3.text[:200]}")
        return False


def create_screenshot_set(H, loc_id, display_type):
    body = {
        'data': {
            'type': 'appScreenshotSets',
            'attributes': {'screenshotDisplayType': display_type},
            'relationships': {
                'appStoreVersionLocalization': {
                    'data': {'type': 'appStoreVersionLocalizations', 'id': loc_id}
                }
            }
        }
    }
    r = requests.post(f'{API_BASE}/appScreenshotSets', headers=H, json=body)
    if r.status_code == 201:
        return r.json()['data']['id']
    print(f"  ERROR creating set ({display_type}): {r.status_code} {r.text[:200]}")
    return None


def upload_lang(lang, screenshot_dir, display_type, skip_existing=False, min_required=3):
    H = get_token()
    dir_path = pathlib.Path(screenshot_dir) / lang
    pngs = sorted(dir_path.glob('*.png'))
    if len(pngs) < min_required:
        print(f"  SKIP {lang}: only {len(pngs)} pngs (<{min_required})")
        return False

    asc_locale = LOCALE_MAP.get(lang, lang)
    print(f"\n[{lang}] {len(pngs)} pngs @ {display_type} (ASC: {asc_locale})")
    loc_id = get_localization_id(H, asc_locale)
    if not loc_id:
        print(f"  ERROR: No localization for {lang}")
        return False

    set_id = get_screenshot_set(H, loc_id, display_type)
    if set_id:
        if skip_existing:
            print(f"  SKIP: already has screenshot set")
            return True
        print(f"  Set exists, deleting old screenshots...")
        delete_existing_screenshots(H, set_id)
    else:
        print(f"  Creating new screenshot set...")
        set_id = create_screenshot_set(H, loc_id, display_type)
        if not set_id:
            return False

    ok = 0
    for png in pngs:
        if upload_screenshot(H, set_id, str(png)):
            ok += 1
    print(f"[{lang}] Done: {ok}/{len(pngs)}")
    return ok == len(pngs)


if __name__ == '__main__':
    platform = 'iphone'
    args = []
    for a in sys.argv[1:]:
        if a == '--platform' and sys.argv[sys.argv.index(a)+1:]:
            platform = sys.argv[sys.argv.index(a)+1]
        elif not a.startswith('--'):
            args.append(a)

    lang = args[0] if args else 'all'

    if platform == 'ipad':
        screenshot_dir, display_type = IPAD_DIR, IPAD_DISPLAY
    elif platform == 'watch':
        screenshot_dir, display_type = WATCH_DIR, WATCH_DISPLAY
    else:
        screenshot_dir, display_type = IPHONE_DIR, IPHONE_DISPLAY

    print(f"=== Platform: {platform} | Display: {display_type} ===")

    skip_existing = '--skip-existing' in sys.argv

    min_screenshots = 1 if platform == 'watch' else 3
    if lang == 'all':
        results = {}
        for d in sorted(pathlib.Path(screenshot_dir).iterdir()):
            if d.is_dir():
                l = d.name
                pngs = list(d.glob('*.png'))
                if len(pngs) >= min_screenshots:
                    results[l] = upload_lang(l, screenshot_dir, display_type, skip_existing=skip_existing, min_required=min_screenshots)
        print("\n=== SUMMARY ===")
        for l, ok in results.items():
            print(f"  {l}: {'OK' if ok else 'FAIL'}")
    else:
        upload_lang(lang, screenshot_dir, display_type, skip_existing=skip_existing)
