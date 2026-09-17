#!/usr/bin/env python3
"""Fix pt-PT localization: add supportUrl and whatsNew."""
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

# Find pt-PT localization
print("=== Finding pt-PT localization ===")
H = get_token()
r = requests.get(f'{API_BASE}/appStoreVersions/{VERSION_ID}/appStoreVersionLocalizations', headers=H)
loc_id = None
for loc in r.json().get('data', []):
    if loc['attributes']['locale'] == 'pt-PT':
        loc_id = loc['id']
        print(f"  Found: {loc_id}")
        print(f"  Current attributes: supportUrl={loc['attributes'].get('supportUrl')}, whatsNew={'SET' if loc['attributes'].get('whatsNew') else 'EMPTY'}")
        break

if not loc_id:
    print("  NOT FOUND!")
    exit(1)

# Update with required fields
print("\n=== Updating pt-PT localization ===")
H = get_token()
body = {
    'data': {
        'type': 'appStoreVersionLocalizations',
        'id': loc_id,
        'attributes': {
            'supportUrl': 'https://shoo-app.com/support',
            'whatsNew': 'Esta versão inclui melhorias de estabilidade e novos sons de animais para o seu repelente de bolso.'
        }
    }
}
r = requests.patch(f'{API_BASE}/appStoreVersionLocalizations/{loc_id}', headers=H, json=body)
print(f"  HTTP {r.status_code}")
if r.status_code == 200:
    print("  ✓ Fixed!")
else:
    print(json.dumps(r.json(), indent=2, ensure_ascii=False))

# Also check screenshot status
print("\n=== Checking screenshot sets ===")
r = requests.get(f'{API_BASE}/appStoreVersionLocalizations/{loc_id}/appScreenshotSets', headers=H)
for s in r.json().get('data', []):
    dt = s['attributes']['screenshotDisplayType']
    sc = requests.get(f'{API_BASE}/appScreenshotSets/{s["id"]}/appScreenshots', headers=H)
    print(f"  {dt}:")
    for ss in sc.json().get('data', []):
        state = ss['attributes'].get('state', 'UNKNOWN')
        print(f"    {ss['attributes']['fileName']}: {state}")
