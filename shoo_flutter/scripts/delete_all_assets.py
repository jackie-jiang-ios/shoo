#!/usr/bin/env python3
"""
Delete all screenshots and preview videos from App Store Connect.
Retry logic included for network resilience.

Usage:
  python3 scripts/delete_all_assets.py
"""
import json, time, os, sys, pathlib, requests, jwt
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry

# Config
KEY_ID = '29HD53FFYV'
ISSUER_ID = '4b86ecb0-5c72-4d3a-81b8-e6d62a056467'
KEY_PATH = './fastlane/AuthKey_29HD53FFYV.p8'

API_BASE = 'https://api.appstoreconnect.apple.com/v1'
VERSION_ID = '72ab6e5c-5665-4b2c-9d34-2e3a778625b6'  # 4.0.0

IPHONE_DISPLAY = 'APP_IPHONE_65'
IPAD_DISPLAY = 'APP_IPAD_PRO_3GEN_129'


def get_session():
    """Create a requests session with retry logic."""
    session = requests.Session()
    retries = Retry(total=5, backoff_factor=1, status_forcelist=[500, 502, 503, 504, 429])
    session.mount('https://', HTTPAdapter(max_retries=retries))
    return session


def get_token():
    private_key = pathlib.Path(KEY_PATH).read_text()
    now = int(time.time())
    token = jwt.encode(
        {'iss': ISSUER_ID, 'iat': now, 'exp': now+1200, 'aud': 'appstoreconnect-v1'},
        private_key, algorithm='ES256', headers={'kid': KEY_ID, 'typ': 'JWT'}
    )
    return {'Authorization': f'Bearer {token}', 'Content-Type': 'application/json'}


def api_get(session, url, headers):
    """GET request with error handling."""
    for attempt in range(3):
        try:
            r = session.get(url, headers=headers, timeout=30)
            return r
        except requests.exceptions.RequestException as e:
            if attempt < 2:
                print(f"    Retry GET ({attempt+1}/3): {e}")
                time.sleep(5)
            else:
                raise


def api_delete(session, url, headers):
    """DELETE request with error handling."""
    for attempt in range(3):
        try:
            r = session.delete(url, headers=headers, timeout=30)
            return r
        except requests.exceptions.RequestException as e:
            if attempt < 2:
                print(f"    Retry DELETE ({attempt+1}/3): {e}")
                time.sleep(5)
            else:
                raise


def main():
    H = get_token()
    session = get_session()
    
    # Get all localizations
    r = api_get(session, f'{API_BASE}/appStoreVersions/{VERSION_ID}/appStoreVersionLocalizations', H)
    locales = r.json().get('data', [])
    print(f"Found {len(locales)} localizations\n")
    
    total_ss = 0
    total_pv = 0
    errors = 0
    
    for loc in locales:
        loc_id = loc['id']
        locale = loc['attributes']['locale']
        print(f"[{locale}]")
        
        try:
            # Get screenshot sets
            r = api_get(session, f'{API_BASE}/appStoreVersionLocalizations/{loc_id}/appScreenshotSets', H)
            ss_sets = r.json().get('data', [])
            
            for s in ss_sets:
                display_type = s['attributes']['screenshotDisplayType']
                if display_type not in [IPHONE_DISPLAY, IPAD_DISPLAY]:
                    continue
                set_id = s['id']
                
                # Get screenshots in this set
                r2 = api_get(session, f'{API_BASE}/appScreenshotSets/{set_id}/appScreenshots', H)
                screenshots = r2.json().get('data', [])
                
                for ss in screenshots:
                    ss_id = ss['id']
                    r3 = api_delete(session, f'{API_BASE}/appScreenshots/{ss_id}', H)
                    if r3.status_code in [204, 200]:
                        total_ss += 1
                        platform = "iPhone" if display_type == IPHONE_DISPLAY else "iPad"
                        print(f"  ✓ {platform} screenshot: {ss['attributes']['fileName']}")
                    else:
                        errors += 1
                        print(f"  ✗ Failed: {r3.status_code}")
            
            # Get preview sets
            r = api_get(session, f'{API_BASE}/appStoreVersionLocalizations/{loc_id}/appPreviewSets', H)
            pv_sets = r.json().get('data', [])
            
            for s in pv_sets:
                set_id = s['id']
                # Get previews in this set
                r2 = api_get(session, f'{API_BASE}/appPreviewSets/{set_id}/appPreviews', H)
                previews = r2.json().get('data', [])
                
                for pv in previews:
                    pv_id = pv['id']
                    r3 = api_delete(session, f'{API_BASE}/appPreviews/{pv_id}', H)
                    if r3.status_code in [204, 200]:
                        total_pv += 1
                        print(f"  ✓ Preview: {pv.get('attributes', {}).get('fileName', pv_id)}")
                    else:
                        errors += 1
                        print(f"  ✗ Failed: {r3.status_code}")
                        
        except Exception as e:
            errors += 1
            print(f"  ✗ ERROR: {e}")
            time.sleep(3)
    
    print(f"\n=== DONE ===")
    print(f"Total screenshots deleted: {total_ss}")
    print(f"Total preview videos deleted: {total_pv}")
    if errors:
        print(f"Errors encountered: {errors}")


if __name__ == '__main__':
    main()
