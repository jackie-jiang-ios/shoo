#!/usr/bin/env python3
"""Upload 44mm Watch screenshots (368x448) to App Store Connect"""
import json, time, os, sys, pathlib, requests, jwt
from PIL import Image

KEY_ID = '29HD53FFYV'
ISSUER_ID = '4b86ecb0-5c72-4d3a-81b8-e6d62a056467'
KEY_PATH = './fastlane/AuthKey_29HD53FFYV.p8'
API_BASE = 'https://api.appstoreconnect.apple.com/v1'
VERSION_ID = '72ab6e5c-5665-4b2c-9d34-2e3a778625b6'

SCREENSHOT_DIR = './fastlane/screenshots_watch_44mm'
DISPLAY_TYPE = 'APP_WATCH_SERIES_4'  # 44mm, supports Series 4/5/6/SE/7 44-45mm

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
    for s in r.json().get('data', []):
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

def upload_screenshot(H, set_id, filepath):
    file_size = os.path.getsize(filepath)
    file_name = os.path.basename(filepath)
    # Verify dimensions
    img = Image.open(filepath)
    w, h = img.size
    if (w, h) != (368, 448):
        print(f"  WARNING: {file_name} is {w}x{h}, expected 368x448")
        return False
    
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
                print(f"  ERROR upload: {r2.status_code}")
                requests.delete(f'{API_BASE}/appScreenshots/{ss_id}', headers=H)
                return False
    
    r3 = requests.patch(f'{API_BASE}/appScreenshots/{ss_id}', headers=H,
                         json={'data': {'type': 'appScreenshots', 'id': ss_id, 'attributes': {'uploaded': True}}})
    if r3.status_code == 200:
        print(f"  OK: {file_name} ({w}x{h})")
        return True
    else:
        print(f"  ERROR commit: {r3.status_code}")
        return False

def create_screenshot_set(H, loc_id, display_type):
    body = {
        'data': {
            'type': 'appScreenshotSets',
            'attributes': {'screenshotDisplayType': display_type},
            'relationships': {'appStoreVersionLocalization': {'data': {'type': 'appStoreVersionLocalizations', 'id': loc_id}}}
        }
    }
    r = requests.post(f'{API_BASE}/appScreenshotSets', headers=H, json=body)
    if r.status_code == 201:
        return r.json()['data']['id']
    print(f"  ERROR creating set: {r.status_code} {r.text[:200]}")
    return None

results = {}
for d in sorted(pathlib.Path(SCREENSHOT_DIR).iterdir()):
    if not d.is_dir():
        continue
    lang = d.name
    pngs = sorted(d.glob('*.png'))
    if not pngs:
        continue
    
    H = get_token()
    asc_locale = LOCALE_MAP.get(lang, lang)
    print(f"\n[{lang}] {len(pngs)} png @ {DISPLAY_TYPE} (ASC: {asc_locale})")
    
    loc_id = get_localization_id(H, asc_locale)
    if not loc_id:
        print(f"  SKIP: no localization for {asc_locale}")
        continue
    
    set_id = get_screenshot_set(H, loc_id, DISPLAY_TYPE)
    if set_id:
        print(f"  Deleting old screenshots...")
        delete_existing_screenshots(H, set_id)
    else:
        print(f"  Creating new set...")
        set_id = create_screenshot_set(H, loc_id, DISPLAY_TYPE)
        if not set_id:
            continue
    
    ok = sum(1 for png in pngs if upload_screenshot(H, set_id, str(png)))
    results[lang] = f"{ok}/{len(pngs)}"

print("\n=== SUMMARY ===")
for lang, status in results.items():
    print(f"  {lang}: {status}")
print(f"\nTotal: {sum(int(s.split('/')[0]) for s in results.values())} uploaded")
