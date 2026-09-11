#!/usr/bin/env python3
"""删除 App Store Connect 上所有 Watch 截图"""
import json, time, os, sys, pathlib, requests, jwt

KEY_ID = '29HD53FFYV'
ISSUER_ID = '4b86ecb0-5c72-4d3a-81b8-e6d62a056467'
KEY_PATH = './fastlane/AuthKey_29HD53FFYV.p8'
API_BASE = 'https://api.appstoreconnect.apple.com/v1'
VERSION_ID = '72ab6e5c-5665-4b2c-9d34-2e3a778625b6'
WATCH_DISPLAY = 'APP_WATCH_SERIES_4'


def get_token():
    private_key = pathlib.Path(KEY_PATH).read_text()
    now = int(time.time())
    token = jwt.encode(
        {'iss': ISSUER_ID, 'iat': now, 'exp': now+1200, 'aud': 'appstoreconnect-v1'},
        private_key, algorithm='ES256', headers={'kid': KEY_ID, 'typ': 'JWT'}
    )
    return {'Authorization': f'Bearer {token}', 'Content-Type': 'application/json'}


def get_localizations(H):
    r = requests.get(f'{API_BASE}/appStoreVersions/{VERSION_ID}/appStoreVersionLocalizations', headers=H)
    return r.json().get('data', [])


def get_watch_set(H, loc_id):
    r = requests.get(f'{API_BASE}/appStoreVersionLocalizations/{loc_id}/appScreenshotSets', headers=H)
    for s in r.json().get('data', []):
        if s['attributes']['screenshotDisplayType'] == WATCH_DISPLAY:
            return s['id']
    return None


def delete_screenshots(H, set_id):
    r = requests.get(f'{API_BASE}/appScreenshotSets/{set_id}/appScreenshots', headers=H)
    screenshots = r.json().get('data', [])
    deleted = 0
    for s in screenshots:
        sid = s['id']
        r2 = requests.delete(f'{API_BASE}/appScreenshots/{sid}', headers=H)
        if r2.status_code in [204, 200]:
            deleted += 1
    return deleted


if __name__ == '__main__':
    H = get_token()
    localizations = get_localizations(H)
    print(f'Found {len(localizations)} localizations')

    total_deleted = 0
    count = 0
    for loc in localizations:
        locale = loc['attributes']['locale']
        loc_id = loc['id']
        count += 1

        # Token refresh if needed
        if count % 10 == 0:
            H = get_token()

        set_id = get_watch_set(H, loc_id)
        if set_id:
            deleted = delete_screenshots(H, set_id)
            total_deleted += deleted
            print(f'[{count}/{len(localizations)}] {locale}: deleted {deleted} screenshots')
        else:
            print(f'[{count}/{len(localizations)}] {locale}: no watch screenshot set')

    print(f'\nDone! Deleted {total_deleted} watch screenshots total')
