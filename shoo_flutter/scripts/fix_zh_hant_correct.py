#!/usr/bin/env python3
"""修复 zh-Hant 截图：删除错误的 APP_IPHONE_67，上传到正确的 APP_IPHONE_65"""
import jwt, time, requests, json, os, hashlib

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

# 获取所有截图集
r=requests.get(f'{API_BASE}/appStoreVersionLocalizations/{lid}/appScreenshotSets',headers=H)
ss_list = r.json().get('data',[])

# 1. 找到并删除错误的 APP_IPHONE_67 集
print("\n1. 删除错误的 APP_IPHONE_67 截图集...")
for ss in ss_list:
    if ss['attributes'].get('screenshotDisplayType') == 'APP_IPHONE_67':
        ss_id = ss['id']
        # 删除其中的截图
        r2=requests.get(f'{API_BASE}/appScreenshotSets/{ss_id}/appScreenshots',headers=H)
        for s in r2.json().get('data',[]):
            print(f"  删除截图: {s['id'][:8]}...")
            requests.delete(f'{API_BASE}/appScreenshots/{s["id"]}', headers=H)
        # 删除截图集
        r_del = requests.delete(f'{API_BASE}/appScreenshotSets/{ss_id}', headers=H)
        print(f"  删除 APP_IPHONE_67 集: {r_del.status_code}")

# 2. 找到正确的 APP_IPHONE_65 集
print("\n2. 查找 APP_IPHONE_65 截图集...")
r=requests.get(f'{API_BASE}/appStoreVersionLocalizations/{lid}/appScreenshotSets',headers=H)
ss_list = r.json().get('data',[])
target_ss = None
for ss in ss_list:
    if ss['attributes'].get('screenshotDisplayType') == 'APP_IPHONE_65':
        target_ss = ss
        break

if not target_ss:
    # 创建截图集
    print("  创建 APP_IPHONE_65 截图集...")
    body = {
        "data": {
            "type": "appScreenshotSets",
            "attributes": {"screenshotDisplayType": "APP_IPHONE_65"},
            "relationships": {
                "appStoreVersionLocalization": {
                    "data": {"type": "appStoreVersionLocalizations", "id": lid}
                }
            }
        }
    }
    r = requests.post(f'{API_BASE}/appScreenshotSets', headers=H, json=body)
    target_ss = r.json()['data']

ss_id = target_ss['id']
print(f"  APP_IPHONE_65 集 ID: {ss_id}")

# 3. 上传到正确的截图集
locale_dir = os.path.join(SCREENSHOTS_PATH, 'zh-Hant')
png_files = sorted([f for f in os.listdir(locale_dir) if f.endswith('.png')])
print(f"\n3. 上传 {len(png_files)} 张截图到 APP_IPHONE_65...")

for png_file in png_files:
    file_path = os.path.join(locale_dir, png_file)
    file_size = os.path.getsize(file_path)
    
    # 计算 MD5
    md5 = hashlib.md5()
    with open(file_path, 'rb') as f:
        for chunk in iter(lambda: f.read(8192), b''):
            md5.update(chunk)
    file_md5 = md5.hexdigest()
    
    print(f"\n  上传: {png_file} ({file_size/1024:.0f} KB, MD5: {file_md5})")

    # 创建 App Screenshot
    body = {
        "data": {
            "type": "appScreenshots",
            "attributes": {"fileName": png_file, "fileSize": file_size},
            "relationships": {
                "appScreenshotSet": {"data": {"type": "appScreenshotSets", "id": ss_id}}
            }
        }
    }
    r = requests.post(f'{API_BASE}/appScreenshots', headers=H, json=body)
    if r.status_code not in [200, 201]:
        print(f"    ❌ 创建失败: {r.status_code} {r.text}")
        continue
    
    screenshot_id = r.json()['data']['id']
    uploadoperations = r.json()['data']['attributes'].get('uploadOperations', [])
    if not uploadoperations:
        print(f"    ❌ 没有上传操作")
        continue

    # 分片上传
    with open(file_path, 'rb') as f:
        all_ok = True
        for op in uploadoperations:
            url = op['url']
            method = op['method']
            length = op['length']
            offset = op['offset']
            f.seek(offset)
            chunk = f.read(length)
            upload_headers = {h['name']: h['value'] for h in op['requestHeaders']}
            r2 = requests.request(method, url, headers=upload_headers, data=chunk)
            if r2.status_code not in [200, 201, 204]:
                print(f"    ❌ 分片上传失败: {r2.status_code}")
                all_ok = False
                break
        if not all_ok:
            continue

    # 提交截图
    body = {
        "data": {
            "type": "appScreenshots",
            "id": screenshot_id,
            "attributes": {"uploaded": True, "sourceFileChecksum": file_md5}
        }
    }
    r3 = requests.patch(f'{API_BASE}/appScreenshots/{screenshot_id}', headers=H, json=body)
    if r3.status_code in [200, 201, 204]:
        print(f"    ✅ 上传成功")
    else:
        print(f"    ❌ 提交失败: {r3.status_code} {r3.text}")

# 4. 验证
print("\n" + "=" * 50)
print("验证结果:")
r=requests.get(f'{API_BASE}/appScreenshotSets/{ss_id}/appScreenshots',headers=H)
for s in r.json().get('data',[]):
    sa = s.get('attributes', {})
    print(f"  {sa.get('fileName','?')}: uploaded={sa.get('uploaded')}, checksum={sa.get('sourceFileChecksum','MISSING')}")
print(f"  总计: {len(r.json().get('data',[]))} 张")
