#!/usr/bin/env python3
"""Update ONLY c09b App Info's en-* localizations to 'Animal Deterrent'."""
import json, time, requests, pathlib, jwt

KID='29HD53FFYV'; ISSUER='4b86ecb0-5c72-4d3a-81b8-e6d62a056467'
kp=pathlib.Path('./fastlane/AuthKey_29HD53FFYV.p8').read_text()
now=int(time.time())
tok=jwt.encode({'iss':ISSUER,'iat':now,'exp':now+1200,'aud':'appstoreconnect-v1'},kp,algorithm='ES256',headers={'kid':KID,'typ':'JWT'})
H={'Authorization':f'Bearer {tok}','Content-Type':'application/json'}

INFO_ID = 'c09b2188-986a-49c4-b5ee-53e91e64309e'
NEW_NAME = 'Animal Deterrent'

r = requests.get(f'https://api.appstoreconnect.apple.com/v1/appInfos/{INFO_ID}/appInfoLocalizations', headers=H, timeout=30)
locs = r.json().get('data', [])

for loc in locs:
    locale = loc['attributes']['locale']
    if locale in ['en-US', 'en-AU', 'en-CA', 'en-GB']:
        lid = loc['id']
        # Get current name
        r2 = requests.get(f'https://api.appstoreconnect.apple.com/v1/appInfoLocalizations/{lid}', headers=H, timeout=30)
        cur = r2.json()['data']['attributes'].get('name','')
        
        payload = {"data":{"type":"appInfoLocalizations","id":lid,"attributes":{"name":NEW_NAME}}}
        r3 = requests.patch(f'https://api.appstoreconnect.apple.com/v1/appInfoLocalizations/{lid}', headers=H, json=payload, timeout=30)
        st = "OK" if r3.status_code in [200,201] else f"FAIL({r3.status_code})"
        if r3.status_code not in [200,201]:
            err = r3.json().get('errors',[{}])[0].get('detail','')[:80]
            st += f" - {err}"
        print(f"{locale}: '{cur}' -> '{NEW_NAME}' [{st}]")
