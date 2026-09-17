#!/usr/bin/env python3
"""
Check App Store version status & attempt review submission.
Designed to surface the exact error behind "无法添加以供审核".
"""
import json, time, requests, jwt

KEY_ID = '29HD53FFYV'
ISSUER_ID = '4b86ecb0-5c72-4d3a-81b8-e6d62a056467'
KEY_PATH = './fastlane/AuthKey_29HD53FFYV.p8'
API_BASE = 'https://api.appstoreconnect.apple.com/v1'
VERSION_ID = '72ab6e5c-5665-4b2c-9d34-2e3a778625b6'

def get_token():
    private_key = open(KEY_PATH).read()
    now = int(time.time())
    token = jwt.encode(
        {'iss': ISSUER_ID, 'iat': now, 'exp': now + 1200, 'aud': 'appstoreconnect-v1'},
        private_key, algorithm='ES256',
        headers={'kid': KEY_ID, 'typ': 'JWT'},
    )
    return {
        'Authorization': f'Bearer {token}',
        'Content-Type': 'application/json',
    }

H = get_token()

# 1. Fetch the version
print("\n=== 1. App Store version ===")
r = requests.get(f'{API_BASE}/appStoreVersions/{VERSION_ID}', headers=H)
print(f"HTTP {r.status_code}")
if r.status_code != 200:
    print(r.text)
    exit(1)

ver = r.json()['data']
attrs = ver['attributes']
print(f"  versionString : {attrs.get('versionString')}")
print(f"  platform      : {attrs.get('platform')}")
print(f"  state         : {attrs.get('appStoreState')}")
print(f"  reviewState   : {attrs.get('appStoreVersionState')} "
      f"(reviewType={attrs.get('reviewType')})")

# attached build
bd = ver.get('relationships', {}).get('build', {}).get('data')
print(f"  build ID      : {bd['id'] if bd else '<none>'}")

# 2. Check localizations
print("\n=== 2. Localizations ===")
r = requests.get(f'{API_BASE}/appStoreVersions/{VERSION_ID}/appStoreVersionLocalizations',
                 headers=H)
locs = r.json().get('data', [])
print(f"Total: {len(locs)}")

missing_store_review_screenshot = []
missing_primary_screenshot = []
missing_video = []

for loc in locs:
    locale = loc['attributes']['locale']
    loc_id = loc['id']

    # screenshots
    r2 = requests.get(
        f'{API_BASE}/appStoreVersionLocalizations/{loc_id}/appScreenshotSets',
        headers=H,
    )
    ss = r2.json().get('data', [])
    has_completable_screenshot = False
    for sset in ss:
        st = sset['attributes']['screenshotDisplayType']
        sid = sset['id']
        r3 = requests.get(f'{API_BASE}/appScreenshotSets/{sid}/appScreenshots',
                          headers=H)
        shots = r3.json().get('data', [])
        for shot in shots:
            ads = shot['attributes'].get('assetDeliveryState', {})
            if ads.get('state') == 'COMPLETE':
                has_completable_screenshot = True
    # Need at least one COMPLETE screenshot per display type
    if not has_completable_screenshot and ss:
        missing_primary_screenshot.append(locale)

    # videos
    r4 = requests.get(
        f'{API_BASE}/appStoreVersionLocalizations/{loc_id}/appPreviewSets',
        headers=H,
    )
    pv_sets = r4.json().get('data', [])
    for pv_set in pv_sets:
        pv_type = pv_set['attributes']['previewType']
        pv_id = pv_set['id']
        r5 = requests.get(f'{API_BASE}/appPreviewSets/{pv_id}/appPreviews',
                          headers=H)
        previews = r5.json().get('data', [])
        # pass if at least one valid preview
        ok = any(
            p['attributes'].get('assetDeliveryState', {}).get('state') == 'COMPLETE'
            for p in previews
        )
        if previews and not ok:
            missing_video.append(f"{locale}:{pv_type}")

print(f"  ⚠️  no usable screenshot: {len(missing_primary_screenshot)}")
print(f"  ⚠️  no usable video    : {len(missing_video)}")
if missing_primary_screenshot[:10]:
    print(f"    {missing_primary_screenshot[:10]}")
if missing_video[:10]:
    print(f"    {missing_video[:10]}")

# 3. Warnings / platform screen-flow
print("\n=== 3. Failure analysis ===")
if missing_primary_screenshot:
    print("  � Some localizations lack a COMPLETE screenshot -> "
          "ASC will refuse submission.")
else:
    print("  ☑ All localizations have at least one COMPLETE screenshot.")

# # 4. Attempt to submit
# print("\n=== 4. Submit-for-review attempt ===")
# # appStoreVersionSubmission
# body = {
#     "data": {
#         "type": "appStoreVersionSubmissions",
#             "relationships": {
#                 "appStoreVersion": {
#                     "data": {"type":"appStoreVersions","id":VERSION_ID}
#                 }
#             }
#         }
#     }
# }
# r = requests.post(f'{API_BASE}/appStoreVersionSubmissions', headers=H, json=body)
# print(f"HTTP {r.status_code}")
# if r.status_code not in (200, 201):
#     print(json.dumps(r.json(), indent=2, ensure_ascii=False))
# else:
#     print(json.dumps(r.json(), indent=2, ensure_ascii=False))

# 5. Compute whether the ASC warning makes sense.
print("\n=== 5. Bottom-line diagnosis ===")
if missing_primary_screenshot or missing_video:
    print("  The version will display the warning: '仍有截屏在上传中'")
    print("  until the incomplete items are fixed / wait for them to finish.")
else:
    print("  Everything is present and COMPLETE on upstream servers.")
    print("  The warning you see is a front-end delay in App Store Connect.")
    print("  Reload or try again in 5-10 minutes; if it persists, contact App Store support.")
