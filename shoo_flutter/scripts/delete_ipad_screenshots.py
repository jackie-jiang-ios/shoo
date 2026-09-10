#!/usr/bin/env python3
"""
Delete ALL iPad screenshots from App Store Connect (all languages).
"""
import json, time, sys, requests, jwt

# Config
KEY_ID = '29HD53FFYV'
ISSUER_ID = '4b86ecb0-5c72-4d3a-81b8-e6d62a056467'
KEY_PATH = './fastlane/AuthKey_29HD53FFYV.p8'

API_BASE = 'https://api.appstoreconnect.apple.com/v1'
VERSION_ID = '72ab6e5c-5665-4b2c-9d34-2e3a778625b6'  # 4.0.0

IPAD_DISPLAY = 'APP_IPAD_PRO_129'


def get_token():
    private_key = open(KEY_PATH).read()
    now = int(time.time())
    token = jwt.encode(
        {'iss': ISSUER_ID, 'iat': now, 'exp': now+1200, 'aud': 'appstoreconnect-v1'},
        private_key, algorithm='ES256', headers={'kid': KEY_ID, 'typ': 'JWT'}
    )
    return {'Authorization': f'Bearer {token}', 'Content-Type': 'application/json'}


def get_screenshot_set(H, loc_id, display_type):
    r = requests.get(f'{API_BASE}/appStoreVersionLocalizations/{loc_id}/appScreenshotSets', headers=H)
    for s in r.json().get('data', []):
        if s['attributes']['screenshotDisplayType'] == display_type:
            return s['id']
    return None


def delete_screenshots_in_set(H, set_id, locale):
    r = requests.get(f'{API_BASE}/appScreenshotSets/{set_id}/appScreenshots', headers=H)
    screenshots = r.json().get('data', [])
    if not screenshots:
        print(f"    [{locale}] No screenshots in this set.")
        return 0
    count = 0
    for s in screenshots:
        sid = s['id']
        r2 = requests.delete(f'{API_BASE}/appScreenshots/{sid}', headers=H)
        if r2.status_code in [204, 200]:
            print(f"    [{locale}] Deleted: {s['attributes']['fileName']}")
            count += 1
        else:
            print(f"    [{locale}] WARNING delete {sid}: {r2.status_code}")
    return count


def main():
    H = get_token()

    r = requests.get(f'{API_BASE}/appStoreVersions/{VERSION_ID}/appStoreVersionLocalizations', headers=H)
    localizations = r.json().get('data', [])

    total_deleted = 0
    total_sets = 0

    for loc in localizations:
        locale = loc['attributes']['locale']
        loc_id = loc['id']

        set_id = get_screenshot_set(H, loc_id, IPAD_DISPLAY)
        if set_id:
            total_sets += 1
            print(f"[{locale}] Found iPad screenshot set, deleting contents...")
            deleted = delete_screenshots_in_set(H, set_id, locale)
            total_deleted += deleted
        # else: no iPad set for this locale, skip

    print(f"\n=== DONE: {total_deleted} screenshots deleted across {total_sets} sets ===")


if __name__ == '__main__':
    main()
