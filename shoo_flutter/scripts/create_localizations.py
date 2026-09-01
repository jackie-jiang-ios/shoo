#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Create appStoreVersionLocalizations and appInfoLocalizations for new languages.
"""

import json
import time
import os
import sys
import requests
import jwt

KEY_ID = "29HD53FFYV"
ISSUER_ID = "4b86ecb0-5c72-4d3a-81b8-e6d62a056467"
KEY_FILEPATH = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
                            "fastlane", "AuthKey_29HD53FFYV.p8")
BUNDLE_ID = "com.yangshiqin.shoo"
API_BASE = "https://api.appstoreconnect.apple.com/v1"

# New languages to create (not in existing 12)
NEW_LANGS = [
    "ar-SA", "id", "it", "ms", "nl-NL", "pl", "tr", "vi",
    "hi", "da", "fr-CA", "fi", "gu", "ca", "cs", "kn",
    "hr", "ro", "mr", "ml", "bn", "no", "pa", "sv",
    "sk", "sl", "te", "ta", "ur", "uk", "es-MX", "he",
    "el", "hu", "en-AU", "en-CA", "en-GB",
]

def generate_jwt():
    with open(KEY_FILEPATH, "rb") as f:
        key = f.read()
    now = int(time.time())
    payload = {"iss": ISSUER_ID, "iat": now, "exp": now + 20 * 60, "aud": "appstoreconnect-v1"}
    headers = {"alg": "ES256", "kid": KEY_ID, "typ": "JWT"}
    return jwt.encode(payload, key, algorithm="ES256", headers=headers)

def main():
    token = generate_jwt()
    H = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}

    # Get app
    resp = requests.get(f"{API_BASE}/apps", headers=H, params={"filter[bundleId]": BUNDLE_ID})
    app_id = resp.json()["data"][0]["id"]
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

    # Get existing version localizations
    resp = requests.get(f"{API_BASE}/appStoreVersions/{version_id}/appStoreVersionLocalizations", headers=H)
    existing = set(loc["attributes"]["locale"] for loc in resp.json()["data"])
    print(f"Existing: {len(existing)} localizations: {sorted(existing)}")

    # Create missing version localizations
    print(f"\nCreating appStoreVersionLocalizations...")
    created = 0
    failed = 0
    for lang in NEW_LANGS:
        if lang in existing:
            print(f"  SKIP {lang}: already exists")
            continue
        body = {
            "data": {
                "type": "appStoreVersionLocalizations",
                "relationships": {
                    "appStoreVersion": {
                        "data": {"type": "appStoreVersions", "id": version_id}
                    },
                    "locale": {
                        "data": {"type": "appStoreVersionLocalizations", "id": lang}
                    }
                }
            }
        }
        # Try POST
        resp = requests.post(f"{API_BASE}/appStoreVersionLocalizations", headers=H, json=body)
        if resp.status_code == 201:
            print(f"  OK {lang}")
            created += 1
        else:
            # Try alternative approach - directly on version endpoint
            body2 = {
                "data": {
                    "type": "appStoreVersionLocalizations",
                    "attributes": {"locale": lang},
                    "relationships": {
                        "appStoreVersion": {
                            "data": {"type": "appStoreVersions", "id": version_id}
                        }
                    }
                }
            }
            resp2 = requests.post(f"{API_BASE}/appStoreVersionLocalizations", headers=H, json=body2)
            if resp2.status_code == 201:
                print(f"  OK {lang} (alt)")
                created += 1
            else:
                print(f"  FAIL {lang}: {resp2.status_code}")
                try:
                    errs = resp2.json().get("errors", [])
                    for e in errs:
                        print(f"    {e.get('detail','')[:200]}")
                except:
                    print(f"    {resp2.text[:300]}")
                failed += 1

    print(f"\nVersion localizations: {created} created, {failed} failed")

    # Get appInfo
    resp = requests.get(f"{API_BASE}/apps/{app_id}/appInfos", headers=H, params={"fields[appInfos]": "appStoreState"})
    app_info_id = resp.json()["data"][0]["id"]

    # Get existing appInfo localizations
    resp = requests.get(f"{API_BASE}/appInfos/{app_info_id}/appInfoLocalizations", headers=H)
    existing_info = set(loc["attributes"]["locale"] for loc in resp.json()["data"])
    print(f"\nAppInfo existing: {len(existing_info)} localizations: {sorted(existing_info)}")

    # Create missing appInfo localizations
    print(f"\nCreating appInfoLocalizations...")
    created2 = 0
    failed2 = 0
    for lang in NEW_LANGS:
        if lang in existing_info:
            print(f"  SKIP {lang}: already exists")
            continue
        body = {
            "data": {
                "type": "appInfoLocalizations",
                "attributes": {"locale": lang},
                "relationships": {
                    "appInfo": {
                        "data": {"type": "appInfos", "id": app_info_id}
                    }
                }
            }
        }
        resp = requests.post(f"{API_BASE}/appInfoLocalizations", headers=H, json=body)
        if resp.status_code == 201:
            print(f"  OK {lang}")
            created2 += 1
        else:
            print(f"  FAIL {lang}: {resp.status_code}")
            try:
                errs = resp.json().get("errors", [])
                for e in errs:
                    print(f"    {e.get('detail','')[:200]}")
            except:
                print(f"    {resp.text[:300]}")
            failed2 += 1

    print(f"\nAppInfo localizations: {created2} created, {failed2} failed")
    print(f"\nDone!")

if __name__ == "__main__":
    main()
