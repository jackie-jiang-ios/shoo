#!/usr/bin/env python3
"""Delete all APP_WATCH_SERIES_3 screenshot sets to allow switching to APP_WATCH_SERIES_4."""
import time, pathlib, requests, jwt

KEY_ID = '29HD53FFYV'
ISSUER_ID = '4b86ecb0-5c72-4d3a-81b8-e6d62a056467'
KEY_PATH = './fastlane/AuthKey_29HD53FFYV.p8'
API_BASE = 'https://api.appstoreconnect.apple.com/v1'
VERSION_ID = '72ab6e5c-5665-4b2c-9d34-2e3a778625b6'

pk = pathlib.Path(KEY_PATH).read_text()
t = int(time.time())
token = jwt.encode(
    {'iss': ISSUER_ID, 'iat': t, 'exp': t+1200, 'aud': 'appstoreconnect-v1'},
    pk, algorithm='ES256', headers={'kid': KEY_ID, 'typ': 'JWT'}
)
H = {'Authorization': f'Bearer {token}', 'Content-Type': 'application/json'}

# Get all localizations
r = requests.get(f'{API_BASE}/appStoreVersions/{VERSION_ID}/appStoreVersionLocalizations', headers=H)
localizations = r.json().get('data', [])

deleted = 0
for loc in localizations:
    locale = loc['attributes']['locale']
    loc_id = loc['id']
    # Get screenshot sets for this localization
    r2 = requests.get(f'{API_BASE}/appStoreVersionLocalizations/{loc_id}/appScreenshotSets', headers=H)
    for s in r2.json().get('data', []):
        if s['attributes']['screenshotDisplayType'] == 'APP_WATCH_SERIES_3':
            sid = s['id']
            r3 = requests.delete(f'{API_BASE}/appScreenshotSets/{sid}', headers=H)
            if r3.status_code == 204:
                deleted += 1
                print(f"Deleted {locale} series3 set")
            else:
                print(f"ERROR deleting {locale}: {r3.status_code}")

print(f"\nDone: deleted {deleted} APP_WATCH_SERIES_3 screenshot sets")
