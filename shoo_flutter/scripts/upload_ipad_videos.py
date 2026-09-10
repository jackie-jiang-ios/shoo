#!/usr/bin/env python3
"""
Batch upload iPad preview videos to App Store Connect.
All videos are 1200x1600, previewType=IPAD_PRO_3GEN_129.

Strategy: Upload ALL videos first, then poll statuses together.

Usage:
  python3 scripts/upload_ipad_videos.py all
  python3 scripts/upload_ipad_videos.py en-GB
  python3 scripts/upload_ipad_videos.py ar-SA bn ca
"""
import json, time, os, sys, pathlib, requests, jwt

# Config
KEY_ID = '29HD53FFYV'
ISSUER_ID = '4b86ecb0-5c72-4d3a-81b8-e6d62a056467'
KEY_PATH = './fastlane/AuthKey_29HD53FFYV.p8'
API_BASE = 'https://api.appstoreconnect.apple.com/v1'
VERSION_ID = '72ab6e5c-5665-4b2c-9d34-2e3a778625b6'  # 4.0.0

VIDEO_DIR = './fastlane/screenshots_ipad'
PREVIEW_TYPE = 'IPAD_PRO_3GEN_129'

LOCALE_MAP = {
    'bn': 'bn-BD', 'gu': 'gu-IN', 'kn': 'kn-IN', 'ml': 'ml-IN',
    'mr': 'mr-IN', 'or': 'or-IN', 'pa': 'pa-IN', 'sl': 'sl-SI',
    'ta': 'ta-IN', 'te': 'te-IN', 'ur': 'ur-PK',
}


def get_token():
    private_key = pathlib.Path(KEY_PATH).read_text()
    now = int(time.time())
    token = jwt.encode(
        {'iss': ISSUER_ID, 'iat': now, 'exp': now+1200, 'aud': 'appstoreconnect-v1'},
        private_key, algorithm='ES256', headers={'kid': KEY_ID, 'typ': 'JWT'}
    )
    return {'Authorization': f'Bearer {token}', 'Content-Type': 'application/json'}


def get_localization_id(H, locale):
    r = requests.get(f'{API_BASE}/appStoreVersions/{VERSION_ID}/appStoreVersionLocalizations', headers=H)
    for loc in r.json().get('data', []):
        if loc['attributes']['locale'] == locale:
            return loc['id']
    return None


def get_preview_set(H, loc_id, preview_type):
    r = requests.get(f'{API_BASE}/appStoreVersionLocalizations/{loc_id}/appPreviewSets', headers=H)
    for s in r.json().get('data', []):
        if s['attributes']['previewType'] == preview_type:
            return s['id']
    return None


def create_preview_set(H, loc_id, preview_type):
    body = {
        'data': {
            'type': 'appPreviewSets',
            'attributes': {'previewType': preview_type},
            'relationships': {
                'appStoreVersionLocalization': {
                    'data': {'type': 'appStoreVersionLocalizations', 'id': loc_id}
                }
            }
        }
    }
    r = requests.post(f'{API_BASE}/appPreviewSets', headers=H, json=body)
    if r.status_code == 201:
        return r.json()['data']['id']
    print(f"  ERROR creating preview set: {r.status_code} {r.text[:200]}")
    return None


def delete_existing_previews(H, set_id):
    r = requests.get(f'{API_BASE}/appPreviewSets/{set_id}/appPreviews', headers=H)
    for p in r.json().get('data', []):
        pid = p['id']
        r2 = requests.delete(f'{API_BASE}/appPreviews/{pid}', headers=H)
        if r2.status_code == 204:
            print(f"    Deleted old preview")
        else:
            print(f"    WARNING delete {pid}: {r2.status_code}")
    time.sleep(1)


def upload_video(H, set_id, video_path):
    file_size = os.path.getsize(video_path)
    file_name = os.path.basename(video_path)

    # 1. Create preview reservation
    body = {
        'data': {
            'type': 'appPreviews',
            'attributes': {'fileSize': file_size, 'fileName': file_name},
            'relationships': {
                'appPreviewSet': {'data': {'type': 'appPreviewSets', 'id': set_id}}
            }
        }
    }
    r = requests.post(f'{API_BASE}/appPreviews', headers=H, json=body)
    if r.status_code != 201:
        print(f"  ERROR reservation: {r.status_code} {r.text[:200]}")
        return None

    preview_id = r.json()['data']['id']
    upload_ops = r.json()['data']['attributes']['uploadOperations']

    # 2. Upload chunks
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
                print(f"  ERROR upload chunk: {r2.status_code}")
                requests.delete(f'{API_BASE}/appPreviews/{preview_id}', headers=H)
                return None

    # 3. Commit
    r3 = requests.patch(f'{API_BASE}/appPreviews/{preview_id}', headers=H,
                         json={'data': {'type': 'appPreviews', 'id': preview_id, 'attributes': {'uploaded': True}}})
    if r3.status_code == 200:
        print(f"  ✅ Uploaded & committed: {file_name}")
        return preview_id
    else:
        print(f"  ERROR commit: {r3.status_code} {r3.text[:200]}")
        return None


def poll_all_statuses(preview_ids, max_wait=600):
    """Poll all preview IDs until all complete or timeout."""
    print(f"\n{'='*60}")
    print(f"Polling {len(preview_ids)} videos for processing status...")
    print(f"{'='*60}")
    
    results = {pid: 'PENDING' for pid in preview_ids}
    start = time.time()
    
    while time.time() - start < max_wait:
        H = get_token()
        all_done = True
        for lang, pid in preview_ids.items():
            if results[lang] in ('COMPLETE', 'FAIL'):
                continue
            r = requests.get(f'{API_BASE}/appPreviews/{pid}', headers=H)
            if r.status_code == 200:
                attrs = r.json()['data']['attributes']
                state = attrs.get('videoDeliveryState', {}).get('state', 'UNKNOWN')
                results[lang] = state
                if state not in ('COMPLETE', 'FAIL'):
                    all_done = False
            else:
                all_done = False
        
        elapsed = int(time.time() - start)
        status_str = ' | '.join(f"{l}:{s}" for l, s in results.items())
        print(f"  [{elapsed}s] {status_str}")
        
        if all_done:
            print(f"\n✅ All videos processed! ({elapsed}s)")
            return results
        
        time.sleep(10)
    
    print(f"\n⏰ Timeout ({max_wait}s)")
    return results


def upload_lang(lang):
    """Upload a single language video, return (lang, preview_id) or (lang, None)."""
    H = get_token()
    video_path = pathlib.Path(VIDEO_DIR) / lang / 'IPAD_PRO_13-0.mp4'
    if not video_path.exists():
        print(f"SKIP {lang}: no video file")
        return lang, None

    asc_locale = LOCALE_MAP.get(lang, lang)
    print(f"\n[{lang}] Uploading {video_path.name} (ASC: {asc_locale})")

    loc_id = get_localization_id(H, asc_locale)
    if not loc_id:
        print(f"  ERROR: No localization for {asc_locale}")
        return lang, None

    set_id = get_preview_set(H, loc_id, PREVIEW_TYPE)
    if set_id:
        print(f"  Deleting old previews...")
        delete_existing_previews(H, set_id)
    else:
        print(f"  Creating new preview set...")
        set_id = create_preview_set(H, loc_id, PREVIEW_TYPE)
        if not set_id:
            return lang, None

    preview_id = upload_video(H, set_id, str(video_path))
    return lang, preview_id


if __name__ == '__main__':
    args = sys.argv[1:]
    if not args:
        print("Usage: python3 scripts/upload_ipad_videos.py <lang> [lang...]")
        print("       python3 scripts/upload_ipad_videos.py all")
        sys.exit(1)

    if args[0] == 'all':
        langs = []
        for d in sorted(pathlib.Path(VIDEO_DIR).iterdir()):
            if d.is_dir() and (d / 'IPAD_PRO_13-0.mp4').exists():
                if d.name != 'en-US':  # Skip already uploaded
                    langs.append(d.name)
    else:
        langs = args

    # Phase 1: Upload all videos rapidly
    print(f"{'='*60}")
    print(f"Phase 1: Uploading {len(langs)} videos...")
    print(f"{'='*60}")
    
    preview_ids = {}
    for lang in langs:
        l, pid = upload_lang(lang)
        if pid:
            preview_ids[l] = pid

    # Phase 2: Poll all statuses
    if preview_ids:
        results = poll_all_statuses(preview_ids)
        
        print(f"\n{'='*60}")
        print("SUMMARY")
        print(f"{'='*60}")
        for lang, state in results.items():
            icon = '✅' if state == 'COMPLETE' else '❌'
            print(f"  {icon} {lang}: {state}")
    else:
        print("\nNo videos were uploaded.")
