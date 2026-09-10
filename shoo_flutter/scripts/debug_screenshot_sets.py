#!/usr/bin/env python3
import jwt, time, requests, json
KEY_ID='29HD53FFYV'
ISSUER_ID='4b86ecb0-5c72-4d3a-81b8-e6d62a056467'
KEY_FILEPATH='/Users/jiangzheng/Project/mac/FlipPrinter/fastlane/AuthKey_29HD53FFYV.p8'
BUNDLE_ID='com.yangshiqin.shoo'
API_BASE='https://api.appstoreconnect.apple.com/v1'
with open(KEY_FILEPATH,'rb') as f: key=f.read()
now=int(time.time())
token=jwt.encode({'iss':ISSUER_ID,'iat':now,'exp':now+20*60,'aud':'appstoreconnect-v1'},key,algorithm='ES256',headers={'alg':'ES256','kid':KEY_ID,'typ':'JWT'})
H={'Authorization':f'Bearer {token}','Content-Type':'application/json'}

r=requests.get(f'{API_BASE}/apps?filter[bundleId]={BUNDLE_ID}&fields[apps]=name',headers=H)
app_id=r.json()['data'][0]['id']

r=requests.get(f'{API_BASE}/apps/{app_id}/appStoreVersions?filter[appStoreState]=PREPARE_FOR_SUBMISSION&fields[appStoreVersions]=versionString,platform',headers=H)
versions=[v for v in r.json()['data'] if v['attributes'].get('platform')=='IOS']
vid=versions[0]['id']

r=requests.get(f'{API_BASE}/appStoreVersions/{vid}/appStoreVersionLocalizations',headers=H)
locs={l['attributes']['locale']:l['id'] for l in r.json()['data']}

for lang in ['zh-Hans', 'zh-Hant']:
    lid=locs.get(lang)
    if not lid:
        print(f"[{lang}] 无本地化")
        continue
    
    print(f"\n=== {lang} ===")
    r=requests.get(f'{API_BASE}/appStoreVersionLocalizations/{lid}/appScreenshotSets?include=appScreenshots',headers=H)
    data = r.json()
    print(f"完整响应:")
    print(json.dumps(data, indent=2, ensure_ascii=False))
