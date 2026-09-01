#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
并行上传所有语言的预览视频到 App Store Connect
- 使用多线程同时上传多个语言
- 每个语言内部也并行上传分片
"""

import json
import time
import os
import sys
import requests
import jwt
from concurrent.futures import ThreadPoolExecutor, as_completed

KEY_ID = "29HD53FFYV"
ISSUER_ID = "4b86ecb0-5c72-4d3a-81b8-e6d62a056467"
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_DIR = os.path.dirname(SCRIPT_DIR)
KEY_FILEPATH = os.path.join(PROJECT_DIR, "fastlane", "AuthKey_29HD53FFYV.p8")
BUNDLE_ID = "com.yangshiqin.shoo"
SCREENSHOTS_DIR = os.path.join(PROJECT_DIR, "fastlane", "screenshots")
API_BASE = "https://api.appstoreconnect.apple.com/v1"

# All languages to upload
ALL_LANGS = [
    "ar-SA", "id", "it", "ms", "nl-NL", "pl", "tr", "vi",
    "hi", "da", "fr-CA", "fi", "ca", "cs", "hr", "ro",
    "no", "sv", "sk", "uk", "es-MX", "he", "el", "hu",
    "en-AU", "en-CA", "en-GB",
]

MAX_PARALLEL = 5  # 同时上传5个语言

def generate_jwt():
    with open(KEY_FILEPATH, "rb") as f:
        key = f.read()
    now = int(time.time())
    payload = {"iss": ISSUER_ID, "iat": now, "exp": now + 20 * 60, "aud": "appstoreconnect-v1"}
    headers = {"alg": "ES256", "kid": KEY_ID, "typ": "JWT"}
    return jwt.encode(payload, key, algorithm="ES256", headers=headers)

def api_request(method, url, token, json_body=None, params=None):
    headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}
    return requests.request(method, url, headers=headers, json=json_body, params=params)

def upload_single_lang(lang, token, version_id, app_id):
    """Upload video for a single language"""
    video_path = os.path.join(SCREENSHOTS_DIR, lang, "IPHONE_65-0.mp4")
    if not os.path.exists(video_path):
        return lang, False, "no video file"

    try:
        H = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}

        # Get version localizations for this locale
        resp = requests.get(f"{API_BASE}/appStoreVersions/{version_id}/appStoreVersionLocalizations",
                           headers=H, params={"filter[locale]": lang})
        if resp.status_code != 200:
            return lang, False, f"get locs failed: {resp.status_code}"

        locs = resp.json()["data"]
        if not locs:
            return lang, False, "no version localization for this locale"

        loc_id = locs[0]["id"]

        # Get app preview sets (not appScreenshotsSets!)
        resp = requests.get(f"{API_BASE}/appStoreVersionLocalizations/{loc_id}/appPreviewSets",
                           headers=H, params={"fields[appPreviewSets]": "previewType,appPreviews"})
        if resp.status_code != 200:
            return lang, False, f"get preview sets failed: {resp.status_code}"

        sets = resp.json()["data"]
        # Find the IPHONE_65 preview set
        preview_set_id = None
        for s in sets:
            if s["attributes"].get("previewType") == "IPHONE_65":
                preview_set_id = s["id"]
                break

        if not preview_set_id:
            # Create a new preview set
            body = {
                "data": {
                    "type": "appPreviewSets",
                    "attributes": {"previewType": "IPHONE_65"},
                    "relationships": {
                        "appStoreVersionLocalization": {
                            "data": {"type": "appStoreVersionLocalizations", "id": loc_id}
                        }
                    }
                }
            }
            resp = requests.post(f"{API_BASE}/appPreviewSets", headers=H, json=body)
            if resp.status_code != 201:
                return lang, False, f"create preview set failed: {resp.status_code} - {resp.text[:200]}"
            preview_set_id = resp.json()["data"]["id"]

        # Check if existing preview exists, delete it
        resp = requests.get(f"{API_BASE}/appPreviewSets/{preview_set_id}/appPreviews", headers=H)
        if resp.status_code == 200:
            existing = resp.json().get("data", [])
            for prev in existing:
                requests.delete(f"{API_BASE}/appPreviews/{prev['id']}", headers=H)
                time.sleep(1)

        # Create new preview
        file_size = os.path.getsize(video_path)
        body = {
            "data": {
                "type": "appPreviews",
                "attributes": {
                    "fileSize": file_size,
                    "fileName": f"{lang}_preview.mp4",
                },
                "relationships": {
                    "appPreviewSet": {
                        "data": {"type": "appPreviewSets", "id": preview_set_id}
                    }
                }
            }
        }
        resp = requests.post(f"{API_BASE}/appPreviews", headers=H, json=body)
        if resp.status_code != 201:
            return lang, False, f"create preview failed: {resp.status_code} - {resp.text[:200]}"

        result = resp.json()
        preview_id = result["data"]["id"]
        upload_operations = result["data"]["attributes"].get("uploadOperations", []) or []

        if not upload_operations:
            # No upload needed, might already be uploaded
            requests.patch(f"{API_BASE}/appPreviews/{preview_id}", headers=H,
                          json={"data": {"type": "appPreviews", "id": preview_id,
                                  "attributes": {"uploaded": True}}})
            return lang, True, "no chunks needed"

        # Read file
        with open(video_path, "rb") as f:
            file_data = f.read()

        # Upload chunks in parallel
        def upload_chunk(op):
            method = op["method"]
            url = op["url"]
            offset = op["offset"]
            length = op["length"]
            chunk_headers = {h["name"]: h["value"] for h in op.get("requestHeaders", [])}
            chunk = file_data[offset:offset + length]
            r = requests.request(method, url, headers=chunk_headers, data=chunk)
            return r.status_code in (200, 201, 204)

        with ThreadPoolExecutor(max_workers=min(len(upload_operations), 3)) as executor:
            futures = [executor.submit(upload_chunk, op) for op in upload_operations]
            results = [f.result() for f in as_completed(futures)]

        if not all(results):
            return lang, False, f"chunk upload failed: {sum(1 for r in results if not r)}/{len(results)} chunks failed"

        # Mark as uploaded
        resp = requests.patch(f"{API_BASE}/appPreviews/{preview_id}", headers=H,
                             json={"data": {"type": "appPreviews", "id": preview_id,
                                     "attributes": {"uploaded": True}}})
        if resp.status_code != 200:
            return lang, False, f"mark uploaded failed: {resp.status_code}"

        return lang, True, "OK"

    except Exception as e:
        return lang, False, str(e)[:200]

def main():
    print("=" * 60)
    print("  Parallel Video Upload to App Store Connect")
    print(f"  {len(ALL_LANGS)} languages, {MAX_PARALLEL} parallel")
    print("=" * 60)

    token = generate_jwt()
    # PyJWT 2.x returns str, 1.x returns bytes
    if isinstance(token, bytes):
        token = token.decode('utf-8')
    print(f"Token generated: {token[:40]}...")
    H = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}

    # Get app
    resp = requests.get(f"{API_BASE}/apps", headers=H, params={"filter[bundleId]": BUNDLE_ID, "fields[apps]": "name,bundleId"})
    if resp.status_code != 200:
        print(f"ERROR: get app failed: {resp.status_code} {resp.text[:300]}")
        sys.exit(1)
    app_data = resp.json().get("data", [])
    if not app_data:
        print(f"ERROR: no app found for bundleId {BUNDLE_ID}")
        sys.exit(1)
    app_id = app_data[0]["id"]
    print(f"App ID: {app_id}")

    # Get version
    resp = requests.get(f"{API_BASE}/apps/{app_id}/appStoreVersions", headers=H,
                       params={"filter[appStoreState]": "PREPARE_FOR_SUBMISSION,REJECTED,DEVELOPER_REJECTED",
                               "fields[appStoreVersions]": "versionString,platform"})
    versions = resp.json()["data"]
    version_id = None
    for v in versions:
        if v["attributes"].get("platform") == "IOS":
            version_id = v["id"]
            break
    if not version_id:
        version_id = versions[0]["id"]
    print(f"Version ID: {version_id}")

    # Parallel upload
    success = 0
    fail = 0
    start = time.time()

    with ThreadPoolExecutor(max_workers=MAX_PARALLEL) as executor:
        futures = {executor.submit(upload_single_lang, lang, token, version_id, app_id): lang
                   for lang in ALL_LANGS}
        for future in as_completed(futures):
            lang = futures[future]
            try:
                lang_name, ok, msg = future.result()
                if ok:
                    success += 1
                    print(f"  OK {lang_name}: {msg}")
                else:
                    fail += 1
                    print(f"  FAIL {lang_name}: {msg}")
            except Exception as e:
                fail += 1
                print(f"  FAIL {lang}: {e}")

    elapsed = time.time() - start
    print(f"\n{'='*60}")
    print(f"  Done in {elapsed:.0f}s - {success} ok, {fail} fail")
    print(f"{'='*60}")

if __name__ == "__main__":
    main()
