#!/usr/bin/env python3
"""Check App Store video status on App Store Connect"""
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

# Check app Preview Sets (videos)
r = requests.get(f'{API_BASE}/appStoreVersions/{VERSION_ID}/appStoreVersionLocalizations', headers=H)
locs = r.json().get('data', [])

has_video = 0
no_video = 0
empty = 0

check_locales = ['en-US', 'zh-Hans', 'ja', 'ko', 'fr-FR', 'de-DE', 'es-ES', 'ar-SA', 'ru', 'pt-BR', 'zh-Hant', 'it', 'hi', 'th', 'id']

for loc_data in locs:
    locale = loc_data['attributes']['locale']
    if locale not in check_locales:
        continue
    loc_id = loc_data['id']
    
    # Check app preview sets (videos)
    r2 = requests.get(f'{API_BASE}/appStoreVersionLocalizations/{loc_id}/appPreviewSets', headers=H)
    sets = r2.json().get('data', [])
    
    if not sets:
        print(f"{locale}: NO preview sets (no videos)")
        no_video += 1
        continue
    
    for s in sets:
        st = s['attributes']['previewType']
        sid = s['id']
        r3 = requests.get(f'{API_BASE}/appPreviewSets/{sid}/appPreviews', headers=H)
        previews = r3.json().get('data', [])
        
        if not previews:
            print(f"{locale} [{st}]: EMPTY")
            empty += 1
        else:
            states = []
            for p in previews:
                ads = p['attributes'].get('assetDeliveryState', {})
                state = ads.get('state', 'N/A')
                states.append(state)
            print(f"{locale} [{st}]: {len(previews)} videos - {states}")
            has_video += 1
