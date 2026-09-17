#!/usr/bin/env python3
"""Quick check all locales for incomplete assets. Write to file."""
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

out = open('/tmp/shoo_assets_check.txt', 'w')
out.write("Checking all locales...\n")

H = get_token()
r = requests.get(f'{API_BASE}/appStoreVersions/{VERSION_ID}/appStoreVersionLocalizations', headers=H)
locs = r.json().get('data', [])
out.write(f"Total locales: {len(locs)}\n\n")

for loc in locs:
    locale = loc['attributes']['locale']
    loc_id = loc['id']
    issues = []
    
    # Screenshot sets
    r = requests.get(f'{API_BASE}/appStoreVersionLocalizations/{loc_id}/appScreenshotSets', headers=get_token())
    for sset in r.json().get('data', []):
        dt = sset['attributes']['screenshotDisplayType']
        r = requests.get(f'{API_BASE}/appScreenshotSets/{sset["id"]}/appScreenshots', headers=get_token())
        for ss in r.json().get('data', []):
            state = ss['attributes'].get('assetDeliveryState', {}).get('state', '?')
            if state != 'COMPLETE':
                issues.append(f"  SCREENSHOT {dt}/{ss['attributes']['fileName']}: {state}")
    
    # Preview sets (videos)
    r = requests.get(f'{API_BASE}/appStoreVersionLocalizations/{loc_id}/appPreviewSets', headers=get_token())
    for pset in r.json().get('data', []):
        pt = pset['attributes']['previewType']
        r = requests.get(f'{API_BASE}/appPreviewSets/{pset["id"]}/appPreviews', headers=get_token())
        for pv in r.json().get('data', []):
            delivery = pv['attributes'].get('assetDeliveryState', {})
            state = delivery.get('state', '?') if delivery else 'no-delivery-info'
            if state != 'COMPLETE' and state != 'no-delivery-info':
                issues.append(f"  VIDEO {pt}/{pv['attributes']['fileName']}: {state}")
    
    if issues:
        out.write(f"❌ [{locale}]\n")
        for i in issues:
            out.write(f"{i}\n")

out.write("\n=== DONE ===\n")
out.close()
print("Done! Output in /tmp/shoo_assets_check.txt")
