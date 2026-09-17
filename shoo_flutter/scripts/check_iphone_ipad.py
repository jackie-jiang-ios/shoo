#!/usr/bin/env python3
"""Check iPhone/iPad screenshot status on App Store Connect"""
import json, time, requests, jwt

KEY_ID = '29HD53FFYV'
ISSUER_ID = '4b86ecb0-5c72-4d3a-81b8-e6d62a056467'
KEY_PATH = './fastlane/AuthKey_29HD53FFYV.p8'
API_BASE = 'https://api.appstoreconnect.apple.com/v1'
VERSION_ID = '72ab6e5c-5665-4b2c-9d34-2e3a778625b6'

def get_token():
    private_key = open(KEY_PATH).read()
    now = int(time.time())
    token = jwt.encode(
        {'iss': ISSUER_ID, 'iat': now, 'exp': now+1200, 'aud': 'appstoreconnect-v1'},
        private_key, algorithm='ES256', headers={'kid': KEY_ID, 'typ': 'JWT'}
    )
    return {'Authorization': f'Bearer {token}', 'Content-Type': 'application/json'}

H = get_token()

r = requests.get(f'{API_BASE}/appStoreVersions/{VERSION_ID}/appStoreVersionLocalizations', headers=H)
locs = r.json().get('data', [])

# Stats
iphone_65 = {'total': 0, 'complete': 0, 'empty': 0, 'errors': 0}
ipad_pro = {'total': 0, 'complete': 0, 'empty': 0, 'errors': 0}

missing_iphone = []
missing_ipad = []

for loc_data in locs:
    locale = loc_data['attributes']['locale']
    loc_id = loc_data['id']
    
    r2 = requests.get(f'{API_BASE}/appStoreVersionLocalizations/{loc_id}/appScreenshotSets', headers=H)
    sets = r2.json().get('data', [])
    
    for s in sets:
        st = s['attributes']['screenshotDisplayType']
        sid = s['id']
        
        r3 = requests.get(f'{API_BASE}/appScreenshotSets/{sid}/appScreenshots', headers=H)
        shots = r3.json().get('data', [])
        
        if st == 'APP_IPHONE_65':
            iphone_65['total'] += len(shots)
            if not shots:
                iphone_65['empty'] += 1
                missing_iphone.append(locale)
            else:
                for shot in shots:
                    ads = shot['attributes'].get('assetDeliveryState', {})
                    state = ads.get('state', 'N/A')
                    errors = ads.get('errors', [])
                    if state == 'COMPLETE' and not errors:
                        iphone_65['complete'] += 1
                    else:
                        iphone_65['errors'] += 1
        
        elif st == 'APP_IPAD_PRO_3GEN_129':
            ipad_pro['total'] += len(shots)
            if not shots:
                ipad_pro['empty'] += 1
                missing_ipad.append(locale)
            else:
                for shot in shots:
                    ads = shot['attributes'].get('assetDeliveryState', {})
                    state = ads.get('state', 'N/A')
                    errors = ads.get('errors', [])
                    if state == 'COMPLETE' and not errors:
                        ipad_pro['complete'] += 1
                    else:
                        ipad_pro['errors'] += 1

print("=== iPhone 6.5\" (APP_IPHONE_65) ===")
print(f"  Total screenshots: {iphone_65['total']}")
print(f"  Complete: {iphone_65['complete']}")
print(f"  Empty sets: {iphone_65['empty']}")
print(f"  Errors: {iphone_65['errors']}")

print("\n=== iPad Pro 12.9\"/13\" (APP_IPAD_PRO_3GEN_129) ===")
print(f"  Total screenshots: {ipad_pro['total']}")
print(f"  Complete: {ipad_pro['complete']}")
print(f"  Empty sets: {ipad_pro['empty']}")
print(f"  Errors: {ipad_pro['errors']}")

if missing_iphone:
    print(f"\nMissing iPhone screenshots ({len(missing_iphone)} locales):")
    for l in missing_iphone[:5]:
        print(f"  {l}")
    if len(missing_iphone) > 5:
        print(f"  ... and {len(missing_iphone)-5} more")

if missing_ipad:
    print(f"\nMissing iPad screenshots ({len(missing_ipad)} locales):")
    for l in missing_ipad[:5]:
        print(f"  {l}")
    if len(missing_ipad) > 5:
        print(f"  ... and {len(missing_ipad)-5} more")
