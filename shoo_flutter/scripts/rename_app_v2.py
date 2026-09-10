#!/usr/bin/env python3
"""Rename app to 'Animal Deterrent' - fast version."""
import json, time, requests, pathlib, jwt, os, re

OLD_NAME = "Animal Repellent"
NEW_NAME = "Animal Deterrent"
APP_ID = '6779087767'

# Quick auth
KID = '29HD53FFYV'
ISSUER = '4b86ecb0-5c72-4d3a-81b8-e6d62a056467'
kp = pathlib.Path('./fastlane/AuthKey_29HD53FFYV.p8').read_text()
now = int(time.time())
tok = jwt.encode({'iss':ISSUER,'iat':now,'exp':now+1200,'aud':'appstoreconnect-v1'}, kp, algorithm='ES256', headers={'kid':KID,'typ':'JWT'})
H = {'Authorization':f'Bearer {tok}','Content-Type':'application/json'}

# ===== 1. Update remote ASC =====
print("=== Updating ASC ===")
# Get all app infos and their localizations in one shot using includes
r = requests.get(f'https://api.appstoreconnect.apple.com/v1/apps/{APP_ID}/appInfos?include=appInfoLocalizations', headers=H, timeout=60)
data = r.json()

locs_to_update = []
included = {x['id']: x for x in data.get('included', [])}

for info in data.get('data', []):
    locs = info.get('relationships', {}).get('appInfoLocalizations', {}).get('data', [])
    for ref in locs:
        loc_id = ref['id']
        loc_data = included.get(loc_id, {})
        attrs = loc_data.get('attributes', {})
        locale = attrs.get('locale', '')
        name = attrs.get('name', '')
        if name == OLD_NAME or name.startswith('Shoo'):
            locs_to_update.append((locale, name, loc_id))

print(f"Found {len(locs_to_update)} to update")

for locale, cur, lid in locs_to_update:
    payload = {"data":{"type":"appInfoLocalizations","id":lid,"attributes":{"name":NEW_NAME}}}
    r = requests.patch(f'https://api.appstoreconnect.apple.com/v1/appInfoLocalizations/{lid}', headers=H, json=payload, timeout=30)
    st = "OK" if r.status_code in [200,201] else f"FAIL({r.status_code})"
    print(f"  {locale}: '{cur}' -> '{NEW_NAME}' [{st}]")

# ===== 2. Update local files =====
print("\n=== Updating local files ===")

def rp(fp, old, new, ip=False):
    if not os.path.exists(fp): return 'miss'
    c = pathlib.Path(fp).read_text(encoding='utf-8')
    nc = c.replace(f'"{old}"', f'"{new}"') if ip else c.replace(old, new)
    if nc != c:
        pathlib.Path(fp).write_text(nc, encoding='utf-8')
        return 'ok'
    return 'skip'

for lg in ['en','en-AU','en-CA','en-GB']:
    p = f'./ios/Runner/{lg}.lproj/InfoPlist.strings'
    print(f"  InfoPlist {lg}: {rp(p, OLD_NAME, NEW_NAME, ip=True)}")

for lg in ['en-US','en-AU','en-CA','en-GB']:
    p = f'./fastlane/metadata/{lg}/name.txt'
    print(f"  fastlane {lg}: {rp(p, OLD_NAME, NEW_NAME)}")

# Watch app
wb = '/Users/jiangzheng/Project/iOS/Shoo/ShooWatchApp'
for lg in os.listdir(wb):
    p = os.path.join(wb, lg, 'Localizable.strings')
    if os.path.exists(p):
        c = pathlib.Path(p).read_text(encoding='utf-8')
        if 'Shoo!' in c or OLD_NAME in c:
            nc = c.replace('"app_name" = "Shoo!"', f'"app_name" = "{NEW_NAME}"').replace(f'"app_name" = "{OLD_NAME}"', f'"app_name" = "{NEW_NAME}"')
            pathlib.Path(p).write_text(nc, encoding='utf-8')
            print(f"  Watch App {lg}: ok")

print("\nDONE! All -> 'Animal Deterrent'")
