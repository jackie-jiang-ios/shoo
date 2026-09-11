#!/usr/bin/env python3
"""检查 App Store Connect 上 Watch 截图集的 display type"""
import json, time, os, sys, pathlib, requests, jwt

KEY_ID = '29HD53FFYV'
ISSUER_ID = '4b86ecb0-5c72-4d3a-81b8-e6d62a056467'
KEY_PATH = './fastlane/AuthKey_29HD53FFYV.p8'
API_BASE = 'https://api.appstoreconnect.apple.com/v1'
VERSION_ID = '72ab6e5c-5665-4b2c-9d34-2e3a778625b6'


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


def get_all_sets(H, loc_id):
    r = requests.get(f'{API_BASE}/appStoreVersionLocalizations/{loc_id}/appScreenshotSets', headers=H)
    return r.json().get('data', [])


if __name__ == '__main__':
    H = get_token()
    localizations = get_localizations(H)

    # Check first few localizations to see what display types exist
    for loc in localizations[:5]:
        locale = loc['attributes']['locale']
        loc_id = loc['id']
        sets = get_all_sets(H, loc_id)
        print(f'{locale}:')
        for s in sets:
            dt = s['attributes']['screenshotDisplayType']
            set_id = s['id']
            # Get screenshot count
            r = requests.get(f'{API_BASE}/appScreenshotSets/{set_id}/appScreenshots', headers=H)
            count = len(r.json().get('data', []))
            print(f'  {dt}: {count} screenshots')
