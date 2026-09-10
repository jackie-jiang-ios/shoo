#!/usr/bin/env python3
import json, time, requests, pathlib, jwt

KEY_ID = '29HD53FFYV'
ISSUER_ID = '4b86ecb0-5c72-4d3a-81b8-e6d62a056467'
KEY_PATH = './fastlane/AuthKey_29HD53FFYV.p8'
APP_ID = '6779087767'

private_key = pathlib.Path(KEY_PATH).read_text()
now = int(time.time())
token = jwt.encode({'iss': ISSUER_ID, 'iat': now, 'exp': now+1200, 'aud': 'appstoreconnect-v1'}, private_key, algorithm='ES256', headers={'kid': KEY_ID, 'typ': 'JWT'})
H = {'Authorization': f'Bearer {token}', 'Content-Type': 'application/json'}

# Check version 4.0.0 - get en-US screenshot sets
version_id = '72ab6e5c-5665-4b2c-9d34-2e3a778625b6'
r = requests.get(f'https://api.appstoreconnect.apple.com/v1/appStoreVersions/{version_id}/appStoreVersionLocalizations', headers=H)
locs = r.json().get('data', [])

# Find en-US
for loc in locs:
    if loc['attributes']['locale'] == 'en-US':
        print(f"en-US localization ID: {loc['id']}")
        r2 = requests.get(f"https://api.appstoreconnect.apple.com/v1/appStoreVersionLocalizations/{loc['id']}/appScreenshotSets", headers=H)
        sets = r2.json()
        print(f"Screenshot sets for en-US: {json.dumps(sets, indent=2)}")
        break

# Check zh-Hant
for loc in locs:
    if loc['attributes']['locale'] == 'zh-Hant':
        print(f"\nzh-Hant localization ID: {loc['id']}")
        r2 = requests.get(f"https://api.appstoreconnect.apple.com/v1/appStoreVersionLocalizations/{loc['id']}/appScreenshotSets", headers=H)
        sets = r2.json().get('data', [])
        for s in sets:
            print(f"  Set: {s['id']} - {s['attributes']['screenshotDisplayType']}")
            r3 = requests.get(f"https://api.appstoreconnect.apple.com/v1/appScreenshotSets/{s['id']}/appScreenshots", headers=H)
            for ss in r3.json().get('data', []):
                print(f"    Screenshot: {ss['id']} - {ss['attributes']['fileName']} state={ss['attributes']['state']}")
        break
