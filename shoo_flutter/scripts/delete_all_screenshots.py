#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
删除 App Store Connect 上所有语种的截图
========================================
流程:
  1. 生成 JWT Token
  2. 通过 Bundle ID 查找 App ID
  3. 查找处于可编辑状态的 App Store Version
  4. 获取所有本地化版本
  5. 遍历每个本地化版本，获取截图集，删除所有截图
"""

import json
import time
import requests
import jwt

# ══════════════════════════════════════
# 配置
# ══════════════════════════════════════
KEY_ID = "29HD53FFYV"
ISSUER_ID = "4b86ecb0-5c72-4d3a-81b8-e6d62a056467"
KEY_FILEPATH = "/Users/jiangzheng/Project/mac/FlipPrinter/fastlane/AuthKey_29HD53FFYV.p8"
BUNDLE_ID = "com.yangshiqin.shoo"
API_BASE = "https://api.appstoreconnect.apple.com/v1"

# ══════════════════════════════════════
# 生成 Token
# ══════════════════════════════════════
with open(KEY_FILEPATH, 'rb') as f:
    key = f.read()
now = int(time.time())
token = jwt.encode(
    {'iss': ISSUER_ID, 'iat': now, 'exp': now + 20 * 60, 'aud': 'appstoreconnect-v1'},
    key, algorithm='ES256', headers={'alg': 'ES256', 'kid': KEY_ID, 'typ': 'JWT'}
)
H = {'Authorization': f'Bearer {token}', 'Content-Type': 'application/json'}

# ══════════════════════════════════════
# 1. 获取 App ID
# ══════════════════════════════════════
print(f"查找 App: {BUNDLE_ID} ...")
r = requests.get(f'{API_BASE}/apps?filter[bundleId]={BUNDLE_ID}&fields[apps]=name', headers=H)
if r.status_code != 200 or not r.json().get('data'):
    print(f"❌ 找不到 App: {r.json()}")
    exit(1)
app_id = r.json()['data'][0]['id']
app_name = r.json()['data'][0]['attributes']['name']
print(f"  App: {app_name} (ID: {app_id})")

# ══════════════════════════════════════
# 2. 获取 PREPARE_FOR_SUBMISSION 的版本
# ══════════════════════════════════════
print("查找可编辑的 App Store Version ...")
r = requests.get(
    f'{API_BASE}/apps/{app_id}/appStoreVersions?filter[appStoreState]=PREPARE_FOR_SUBMISSION&fields[appStoreVersions]=versionString,platform',
    headers=H
)
versions = [v for v in r.json()['data'] if v['attributes'].get('platform') == 'IOS']
if not versions:
    print("❌ 找不到 PREPARE_FOR_SUBMISSION 状态的 iOS 版本")
    exit(1)
vid = versions[0]['id']
version_string = versions[0]['attributes']['versionString']
print(f"  版本: {version_string} (ID: {vid})")

# ══════════════════════════════════════
# 3. 获取所有本地化
# ══════════════════════════════════════
print("获取所有本地化版本 ...")
r = requests.get(f'{API_BASE}/appStoreVersions/{vid}/appStoreVersionLocalizations', headers=H)
locs = {l['attributes']['locale']: l['id'] for l in r.json()['data']}
print(f"  共 {len(locs)} 个语种: {', '.join(sorted(locs.keys()))}")

# ══════════════════════════════════════
# 4. 遍历每个语种，删除截图
# ══════════════════════════════════════
print()
print("=" * 60)
print("开始删除截图...")
print("=" * 60)

total_deleted = 0
total_failed = 0

for locale, lid in sorted(locs.items()):
    print(f"\n[{locale}] ", end="", flush=True)

    # 获取截图集
    r = requests.get(
        f'{API_BASE}/appStoreVersionLocalizations/{lid}/appScreenshotSets?fields[appScreenshotSets]=screenshotDisplayType',
        headers=H
    )
    screenshot_sets = r.json().get('data', [])
    
    if not screenshot_sets:
        print("无截图集，跳过")
        continue

    locale_deleted = 0
    for ss in screenshot_sets:
        ss_id = ss['id']
        display_type = ss['attributes'].get('screenshotDisplayType', '?')
        
        # 获取截图集中的截图
        r2 = requests.get(
            f'{API_BASE}/appScreenshotSets/{ss_id}/appScreenshots?fields[appScreenshots]=fileName,fileSize',
            headers=H
        )
        screenshots = r2.json().get('data', [])
        
        if not screenshots:
            continue
        
        for screenshot in screenshots:
            screenshot_id = screenshot['id']
            file_name = screenshot['attributes'].get('fileName', '?')
            
            # 删除截图
            r3 = requests.delete(f'{API_BASE}/appScreenshots/{screenshot_id}', headers=H)
            if r3.status_code == 204:
                locale_deleted += 1
                total_deleted += 1
                print(f"✓", end="", flush=True)
            else:
                total_failed += 1
                print(f"✗({r3.status_code})", end="", flush=True)

    print(f"  — 删除了 {locale_deleted} 张截图")

print()
print("=" * 60)
print(f"完成！共删除 {total_deleted} 张截图，失败 {total_failed} 张")
print("=" * 60)
