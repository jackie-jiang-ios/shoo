#!/usr/bin/env python3
"""修复 zh-Hant 截图上传确认失败的问题"""
import jwt, time, requests, json, os

KEY_ID='29HD53FFYV'
ISSUER_ID='4b86ecb0-5c72-4d3a-81b8-e6d62a056467'
KEY_FILEPATH='/Users/jiangzheng/Project/mac/FlipPrinter/fastlane/AuthKey_29HD53FFYV.p8'
BUNDLE_ID='com.yangshiqin.shoo'
API_BASE='https://api.appstoreconnect.apple.com/v1'
SCREENSHOTS_PATH = "/Users/jiangzheng/Project/iOS/Shoo/shoo_flutter/fastlane/screenshots"

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

lid = locs['zh-Hant']
print(f"zh-Hant localization ID: {lid}")

# 获取 APP_IPHONE_67 截图集
r=requests.get(f'{API_BASE}/appStoreVersionLocalizations/{lid}/appScreenshotSets',headers=H)
ss_list = r.json().get('data',[])
target_ss = None
for ss in ss_list:
    if ss['attributes'].get('screenshotDisplayType') == 'APP_IPHONE_67':
        target_ss = ss
        break

if not target_ss:
    print("❌ 找不到 APP_IPHONE_67 截图集")
    exit(1)

ss_id = target_ss['id']
print(f"截图集 ID: {ss_id}")

# 获取现有截图
r=requests.get(f'{API_BASE}/appScreenshotSets/{ss_id}/appScreenshots',headers=H)
shots = r.json().get('data',[])
print(f"现有截图: {len(shots)}")

# 尝试重新 PATCH 每个截图
for s in shots:
    s_id = s['id']
    sa = s.get('attributes', {})
    checksum = sa.get('sourceFileChecksum')
    filename = sa.get('fileName', '?')
    
    print(f"\n  截图: {filename} (id: {s_id[:8]}...)")
    print(f"    当前 checksum: {checksum}")
    
    if checksum:
        print(f"    ✅ 已有 checksum，跳过")
        continue
    
    # 重新 PATCH 确认上传
    body = {
        "data": {
            "type": "appScreenshots",
            "id": s_id,
            "attributes": {"uploaded": True}
        }
    }
    r3 = requests.patch(f'{API_BASE}/appScreenshots/{s_id}', headers=H, json=body)
    print(f"    PATCH status: {r3.status_code}")
    if r3.status_code in [200, 201, 204]:
        print(f"    ✅ PATCH 成功")
        if r3.text:
            resp_data = r3.json()
            new_checksum = resp_data.get('data',{}).get('attributes',{}).get('sourceFileChecksum')
            print(f"    新 checksum: {new_checksum}")
    else:
        print(f"    ❌ 失败: {r3.text}")
