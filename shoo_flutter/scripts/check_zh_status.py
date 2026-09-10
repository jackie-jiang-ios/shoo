#!/usr/bin/env python3
"""检查中文截图集和截图的详细状态"""
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

r=requests.get(f'{API_BASE}/apps/{app_id}/appStoreVersions?filter[appStoreState]=PREPARE_FOR_SUBMISSION',headers=H)
versions=[v for v in r.json()['data'] if v['attributes'].get('platform')=='IOS']
vid=versions[0]['id']

r=requests.get(f'{API_BASE}/appStoreVersions/{vid}/appStoreVersionLocalizations',headers=H)
locs={l['attributes']['locale']:l['id'] for l in r.json()['data']}

for lang in ['zh-Hans', 'zh-Hant']:
    lid=locs.get(lang)
    if not lid:
        print(f"[{lang}] 无本地化")
        continue
    
    print(f"\n{'='*60}")
    print(f"  {lang} (lid: {lid})")
    print(f"{'='*60}")
    
    r=requests.get(f'{API_BASE}/appStoreVersionLocalizations/{lid}/appScreenshotSets',headers=H)
    ss_list = r.json().get('data',[])
    print(f"\n截图集数量: {len(ss_list)}")
    
    for ss in ss_list:
        ss_id = ss['id']
        dt = ss['attributes'].get('screenshotDisplayType','?')
        print(f"\n  截图集: {dt}")
        print(f"  ID: {ss_id}")
        
        r2=requests.get(f'{API_BASE}/appScreenshotSets/{ss_id}/appScreenshots',headers=H)
        shots = r2.json().get('data',[])
        print(f"  截图数量: {len(shots)}")
        
        for s in shots:
            sa = s.get('attributes', {})
            print(f"\n    截图 ID: {s['id']}")
            print(f"    文件名: {sa.get('fileName','?')}")
            print(f"    文件大小: {sa.get('fileSize','?')}")
            print(f"    uploaded: {sa.get('uploaded','?')}")
            print(f"    sourceFileChecksum: {sa.get('sourceFileChecksum','?')}")
            # Check for validation errors
            ve = sa.get('validationErrors', [])
            if ve:
                print(f"    ❌ 验证错误: {json.dumps(ve, ensure_ascii=False)}")
            else:
                print(f"    validationErrors: (无)")
