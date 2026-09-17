#!/usr/bin/env python3
"""Check ALL screenshot sets status on App Store Connect"""
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

# Get all localizations
r = requests.get(f'{API_BASE}/appStoreVersions/{VERSION_ID}/appStoreVersionLocalizations', headers=H)
locs = r.json().get('data', [])

# Check a few important ones
check_locales = ['en-US', 'zh-Hans', 'ja', 'ar-SA']

for loc_data in locs:
    locale = loc_data['attributes']['locale']
    if locale not in check_locales:
        continue
    loc_id = loc_data['id']
    
    r2 = requests.get(f'{API_BASE}/appStoreVersionLocalizations/{loc_id}/appScreenshotSets', headers=H)
    sets = r2.json().get('data', [])
    
    print(f"\n=== {locale} ===")
    for s in sets:
        st = s['attributes']['screenshotDisplayType']
        sid = s['id']
        
        r3 = requests.get(f'{API_BASE}/appScreenshotSets/{sid}/appScreenshots', headers=H)
        shots = r3.json().get('data', [])
        
        if not shots:
            print(f"  {st}: EMPTY")
            continue
        
        states = []
        for shot in shots:
            attrs = shot['attributes']
            ads = attrs.get('assetDeliveryState', {})
            state = ads.get('state', 'N/A')
            errors = ads.get('errors', [])
            states.append(f"{state}" + (f"(errors!)" if errors else ""))
        
        print(f"  {st}: {len(shots)} shots - {', '.join(states)}")
