#!/usr/bin/env python3
"""Upload pt-PT videos (iPhone + iPad) to App Store Connect."""
import json, time, os, requests, jwt

KEY_ID = '29HD53FFYV'
ISSUER_ID = '4b86ecb0-5c72-4d3a-81b8-e6d62a056467'
KEY_PATH = './fastlane/AuthKey_29HD53FFYV.p8'
API_BASE = 'https://api.appstoreconnect.apple.com/v1'
LOCALE = 'pt-PT'

def get_token():
    private_key = open(KEY_PATH).read()
    now = int(time.time())
    token = jwt.encode(
        {'iss': ISSUER_ID, 'iat': now, 'exp': now+1200, 'aud': 'appstoreconnect-v1'},
        private_key, algorithm='ES256', headers={'kid': KEY_ID, 'typ': 'JWT'}
    )
    return {'Authorization': f'Bearer {token}', 'Content-Type': 'application/json'}

# 1. Get localization ID
print("=== 1. 获取 localization ===")
H = get_token()
r = requests.get(f'{API_BASE}/appStoreVersions/72ab6e5c-5665-4b2c-9d34-2e3a778625b6/appStoreVersionLocalizations', headers=H)
locs = r.json().get('data', [])
loc_id = None
for loc in locs:
    if loc['attributes']['locale'] == LOCALE:
        loc_id = loc['id']
        break
if not loc_id:
    print("  ❌ pt-PT localization not found")
    exit(1)
print(f"  Localization: {loc_id}")

# 2. Upload videos for iPhone and iPad
videos = [
    ('./fastlane/screenshots/pt-PT/IPHONE_65-0.mp4', 'IPHONE_65'),
    ('./fastlane/screenshots_ipad/pt-PT/IPAD_PRO_3GEN_129-0.mp4', 'IPAD_PRO_3GEN_129'),
]

for video_path, display_type in videos:
    if not os.path.exists(video_path):
        print(f"  SKIP {display_type}: {video_path} not found")
        continue

    print(f"\n=== 2. Upload {display_type} ===")

    # Find or create preview set
    H = get_token()
    r = requests.get(f'{API_BASE}/appStoreVersionLocalizations/{loc_id}/appPreviewSets', headers=H)
    psets = r.json().get('data', [])
    pset_id = None
    for ps in psets:
        if ps['attributes']['previewType'] == display_type:
            pset_id = ps['id']
            break

    if pset_id:
        # Delete existing previews
        H = get_token()
        r = requests.get(f'{API_BASE}/appPreviewSets/{pset_id}/appPreviews', headers=H)
        for p in r.json().get('data', []):
            H = get_token()
            requests.delete(f'{API_BASE}/appPreviews/{p["id"]}', headers=H)
        print(f"  Cleared old previews from {pset_id}")
    else:
        # Create preview set
        H = get_token()
        body = {
            'data': {
                'type': 'appPreviewSets',
                'attributes': {'previewType': display_type},
                'relationships': {'appStoreVersionLocalization': {'data': {'type': 'appStoreVersionLocalizations', 'id': loc_id}}}
            }
        }
        r = requests.post(f'{API_BASE}/appPreviewSets', headers=H, json=body)
        if r.status_code != 201:
            print(f"  ERROR creating preview set: {r.status_code} {r.text}")
            continue
        pset_id = r.json()['data']['id']
        print(f"  Created preview set: {pset_id}")

    # Upload video
    fsize = os.path.getsize(video_path)
    fname = os.path.basename(video_path)

    H = get_token()
    body = {
        'data': {
            'type': 'appPreviews',
            'attributes': {'fileName': fname, 'fileSize': fsize},
            'relationships': {'appPreviewSet': {'data': {'type': 'appPreviewSets', 'id': pset_id}}}
        }
    }
    r = requests.post(f'{API_BASE}/appPreviews', headers=H, json=body)
    if r.status_code != 201:
        print(f"  ERROR reservation: {r.status_code} {r.text[:300]}")
        continue

    pv_id = r.json()['data']['id']
    upload_ops = r.json()['data']['attributes']['uploadOperations']

    # Upload chunks
    with open(video_path, 'rb') as f:
        for op in upload_ops:
            url = op['url']
            method = op['method']
            offset = op['offset']
            length = op['length']
            headers = {h['name']: h['value'] for h in op['requestHeaders']}
            f.seek(offset)
            chunk = f.read(length)
            r2 = requests.request(method, url, headers=headers, data=chunk)
            if r2.status_code not in [200, 201, 204]:
                print(f"  ERROR upload: {r2.status_code}")
                break
        else:
            # Commit
            H = get_token()
            r3 = requests.patch(f'{API_BASE}/appPreviews/{pv_id}', headers=H,
                                json={'data': {'type': 'appPreviews', 'id': pv_id, 'attributes': {'uploaded': True}}})
            if r3.status_code == 200:
                print(f"  ✓ Uploaded {fname}")
            else:
                print(f"  ERROR commit: {r3.status_code} {r3.text[:200]}")

print("\n=== 完成 ===")
