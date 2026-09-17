#!/usr/bin/env python3
"""全面诊断提交审核的前置条件。"""
import json, time, requests, jwt

KEY_ID = '29HD53FFYV'
ISSUER_ID = '4b86ecb0-5c72-4d3a-81b8-e6d62a056467'
KEY_PATH = './fastlane/AuthKey_29HD53FFYV.p8'
API_BASE = 'https://api.appstoreconnect.apple.com/v1'
VERSION_ID = '72ab6e5c-5665-4b2c-9d34-2e3a778625b6'

# 最低要求（Apple 文档）
# APP_IPHONE_65: >= 1 (建议 3)
# APP_IPAD_PRO_3GEN_129: >= 1 (建议 3)
# APP_WATCH_SERIES_4: >= 1

DISPLAY_REQUIREMENTS = {
    'APP_IPHONE_65': 1,
    'APP_IPAD_PRO_3GEN_129': 1,
    'APP_WATCH_SERIES_4': 1,
}

def get_token():
    private_key = open(KEY_PATH).read()
    now = int(time.time())
    token = jwt.encode(
        {'iss': ISSUER_ID, 'iat': now, 'exp': now+1200, 'aud': 'appstoreconnect-v1'},
        private_key, algorithm='ES256', headers={'kid': KEY_ID, 'typ': 'JWT'}
    )
    return {'Authorization': f'Bearer {token}', 'Content-Type': 'application/json'}

H = get_token()

# 1. 版本状态
print("=== 1. 版本信息 ===")
H = get_token()
r = requests.get(f'{API_BASE}/appStoreVersions/{VERSION_ID}', headers=H)
v = r.json()['data']
print(f"  appStoreState: {v['attributes']['appStoreState']}")
build = v.get('relationships',{}).get('build',{}).get('data')
print(f"  build: {build['id'] if build else 'NONE'}")

# 2. 每种 display type 在每个 locale 下的状态
print("\n=== 2. 每种 Display Type 在每个 Locale 的截图状态 ===")
H = get_token()
r = requests.get(f'{API_BASE}/appStoreVersions/{VERSION_ID}/appStoreVersionLocalizations', headers=H)
locs = r.json().get('data', [])

missing = []  # (locale, display_type, reason)

for loc in locs:
    locale = loc['attributes']['locale']
    loc_id = loc['id']
    
    H = get_token()
    r2 = requests.get(f'{API_BASE}/appStoreVersionLocalizations/{loc_id}/appScreenshotSets', headers=H)
    sets = r2.json().get('data', [])
    
    found_types = {}
    for s in sets:
        st = s['attributes']['screenshotDisplayType']
        sid = s['id']
        
        H = get_token()
        r3 = requests.get(f'{API_BASE}/appScreenshotSets/{sid}/appScreenshots', headers=H)
        shots = r3.json().get('data', [])
        
        # 只计算 COMPLETE 的
        complete = [s for s in shots if s['attributes'].get('assetDeliveryState',{}).get('state') == 'COMPLETE']
        
        if st not in found_types:
            found_types[st] = 0
        found_types[st] += len(complete)
    
    # 检查每种必需的 display type
    for dt, min_count in DISPLAY_REQUIREMENTS.items():
        actual = found_types.get(dt, 0)
        if actual < min_count:
            missing.append((locale, dt, f"只有 {actual} 张 (需要至少 {min_count})"))
    
    # 也检查视频
    H = get_token()
    r4 = requests.get(f'{API_BASE}/appStoreVersionLocalizations/{loc_id}/appPreviewSets', headers=H)
    pv_sets = r4.json().get('data', [])

# 输出
if missing:
    print(f"\n⚠️ 发现 {len(missing)} 个问题:")
    prev_loc = None
    for loc, dt, reason in sorted(missing):
        if loc != prev_loc:
            print(f"\n  [{loc}]")
            prev_loc = loc
        print(f"    {dt}: {reason}")
else:
    print("\n✅ 所有 locale 的所有 display type 都有足够截图")

# 3. 汇总每种 display type 的总截图数
print("\n=== 3. 汇总 ===")
H = get_token()
r = requests.get(f'{API_BASE}/appStoreVersions/{VERSION_ID}/appStoreVersionLocalizations', headers=H)
locs = r.json().get('data', [])

dt_counts = {}
for loc in locs:
    loc_id = loc['id']
    locale = loc['attributes']['locale']
    
    H = get_token()
    r2 = requests.get(f'{API_BASE}/appStoreVersionLocalizations/{loc_id}/appScreenshotSets', headers=H)
    sets = r2.json().get('data', [])
    
    for s in sets:
        st = s['attributes']['screenshotDisplayType']
        sid = s['id']
        if st not in dt_counts:
            dt_counts[st] = {}
        
        H = get_token()
        r3 = requests.get(f'{API_BASE}/appScreenshotSets/{sid}/appScreenshots', headers=H)
        shots = r3.json().get('data', [])
        
        complete = [s2 for s2 in shots if s2['attributes'].get('assetDeliveryState',{}).get('state') == 'COMPLETE']
        dt_counts[st][locale] = len(complete)

for dt, counts in dt_counts.items():
    total_locs = len(counts)
    full = sum(1 for n in counts.values() if n >= 3)
    partial = sum(1 for n in counts.values() if 0 < n < 3)
    zero = sum(1 for n in counts.values() if n == 0)
    print(f"  {dt}: {total_locs} locales | ≥3: {full} | 1-2: {partial} | 0: {zero}")

print("\n=== 诊断完成 ===")
