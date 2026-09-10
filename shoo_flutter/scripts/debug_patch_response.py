#!/usr/bin/env python3
"""检查 PATCH 上传确认的完整响应，以及重新查询截图状态"""
import jwt, time, requests, json, os, hashlib

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

# 查看 zh-Hans（正常的）和 zh-Hant（异常的）
for lang in ['zh-Hans', 'zh-Hant']:
    lid = locs[lang]
    print(f"\n{'='*60}")
    print(f"  {lang}")
    print(f"{'='*60}")
    
    r=requests.get(f'{API_BASE}/appStoreVersionLocalizations/{lid}/appScreenshotSets',headers=H)
    for ss in r.json().get('data',[]):
        if ss['attributes'].get('screenshotDisplayType') != 'APP_IPHONE_67':
            continue
        ss_id = ss['id']
        r2=requests.get(f'{API_BASE}/appScreenshotSets/{ss_id}/appScreenshots?fields[appScreenshots]=fileName,fileSize,uploaded,sourceFileChecksum,previewState,screenshotState',headers=H)
        
        for s in r2.json().get('data',[]):
            sa = s.get('attributes', {})
            print(f"\n  截图: {sa.get('fileName','?')}")
            print(f"    完整属性: {json.dumps(sa, indent=4, ensure_ascii=False)}")
    
    # 也直接查询单张截图
    r2=requests.get(f'{API_BASE}/appScreenshotSets/{ss_id}/appScreenshots',headers=H)
    for s in r2.json().get('data',[]):
        s_id = s['id']
        r3=requests.get(f'{API_BASE}/appScreenshots/{s_id}',headers=H)
        if r3.json().get('data',{}).get('attributes',{}).get('fileName'):
            sa = r3.json()['data']['attributes']
            print(f"  [单查] {sa.get('fileName','?')}: uploaded={sa.get('uploaded')}, checksum={sa.get('sourceFileChecksum')}")
            # 检查所有字段
            for k,v in sa.items():
                print(f"         {k}: {v}")
