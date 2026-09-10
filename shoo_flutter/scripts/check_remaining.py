#!/usr/bin/env python3
import pathlib, requests, jwt, time
KEY_ID='29HD53FFYV'
ISSUER_ID='4b86ecb0-5c72-4d3a-81b8-e6d62a056467'
KEY_PATH='./fastlane/AuthKey_29HD53FFYV.p8'
API_BASE='https://api.appstoreconnect.apple.com/v1'
VERSION_ID='72ab6e5c-5665-4b2c-9d34-2e3a778625b6'
private_key = pathlib.Path(KEY_PATH).read_text()
now = int(time.time())
token = jwt.encode({'iss':ISSUER_ID,'iat':now,'exp':now+1200,'aud':'appstoreconnect-v1'}, private_key, algorithm='ES256', headers={'kid':KEY_ID,'typ':'JWT'})
H = {'Authorization':f'Bearer {token}','Content-Type':'application/json'}
r = requests.get(f'{API_BASE}/appStoreVersions/{VERSION_ID}/appStoreVersionLocalizations', headers=H)
locales = r.json().get('data',[])
total_ss=0; total_pv=0
for loc in locales:
    lid=loc['id']
    locale=loc['attributes']['locale']
    r2=requests.get(f'{API_BASE}/appStoreVersionLocalizations/{lid}/appScreenshotSets',headers=H)
    ss_count=0; pv_count=0
    for s in r2.json().get('data',[]):
        sid=s['id']
        r3=requests.get(f'{API_BASE}/appScreenshotSets/{sid}/appScreenshots',headers=H)
        c=len(r3.json().get('data',[]))
        ss_count+=c; total_ss+=c
    r4=requests.get(f'{API_BASE}/appStoreVersionLocalizations/{lid}/appPreviewSets',headers=H)
    for s in r4.json().get('data',[]):
        sid=s['id']
        r5=requests.get(f'{API_BASE}/appPreviewSets/{sid}/appPreviews',headers=H)
        c=len(r5.json().get('data',[]))
        pv_count+=c; total_pv+=c
    if ss_count or pv_count:
        print(f"[{locale}] screenshots={ss_count}, previews={pv_count}")
print(f"\n=== 剩余总数 ===")
print(f"Screenshots: {total_ss}")
print(f"Preview videos: {total_pv}")
