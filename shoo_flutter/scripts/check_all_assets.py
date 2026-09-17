#!/usr/bin/env python3
"""Check ALL locales for incomplete screenshots/videos."""
import json, time, requests, jwt

KEY_ID = '29HD53FFYV'
ISSUER_ID = '4b86ecb0-5c72-4d3a-81b8-e6d62a056467'
KEY_PATH = './fastlane/AuthKey_29HD53FFYV.p8'
API_BASE = 'https://api.appstoreconnect.apple.com/v1'
VERSION_ID = '72ab6e5c-5665-4b2c-9d34-2e3a778625b6'

def get_token():
    pk = open(KEY_PATH).read()
    t = int(time.time())
    tok = jwt.encode(
        {'iss': ISSUER_ID, 'iat': t, 'exp': t + 1200, 'aud': 'appstoreconnect-v1'},
        pk, algorithm='ES256',
        headers={'kid': KEY_ID, 'typ': 'JWT'},
    )
    return {'Authorization': f'Bearer {tok}', 'Content-Type': 'application/json'}

# Get all localizations
H = get_token()
r = requests.get(f'{API_BASE}/appStoreVersions/{VERSION_ID}/appStoreVersionLocalizations', headers=H)
locs = r.json().get('data', [])
print(f"Total locales: {locs}\n")

incomplete = []

for loc in locs:
    locale = loc['attributes']['locale']
    loc_id = loc['id']
    
    # Check screenshots
    H = get_token()
    r = requests.get(f'{API_BASE}/appStoreVersionLocalizations/{loc_id}/appScreenshotSets', headers=H)
    ssets = r.json().get('data', [])
    
    for sset in ssets:
        dt = sset['attributes']['screenshotDisplayType']
        r = requests.get(f'{API_BASE}/appScreenshotSets/{sset["id"]}/appScreenshots', headers=get_token())
        for ss in r.json().get('data', []):
            state = ss['attributes'].get('assetDeliveryState', {}).get('state', '?')
            if state != 'COMPLETE':
                print(f"  ❌ [{locale}] {dt}/{ss['attributes']['fileName']}: {state}")
                incomplete.append(f"{locale}/{dt}/{ss['attributes']['fileName']}")
    
    # Check videos
    H = get_token()
    r = requests.get(f'{API_BASE}/appStoreVersionLocalizations/{loc_id}/appPreviewSets', headers=H)
    psets = r.json().get('data', [])
    
    for pset in psets:
        pt = pset['attributes']['previewType']
        r = requests.get(f'{API_BASE}/appPreviewSets/{pset["id"]}/appPreviews', headers=get_token())
        for pv in r.json().get('data', []):
            state = pv['attributes'].get('previewFrameTimeCode', None)
            # Check delivery state if available
            delivery = pv['attributes'].get('assetDeliveryState', {})
            ds = delivery.get('state', None) if delivery else None
            if ds and ds != 'COMPLETE':
                print(f"  ❌ [{locale}] VIDEO {pt}/{pv['attributes']['fileName']}: {ds}")
                incomplete.append(f"{locale}/video/{pt}")

if incomplete:
    print(f"\n===== {len(incomplete)} incomplete assets =====")
else:
    print("\n===== 全部 COMPLETE =====")
