#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Create appInfoLocalizations with name attribute for new languages.
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
METADATA_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
                            "fastlane", "metadata")
API_BASE = "https://api.appstoreconnect.apple.com/v1"

# Only languages that were successfully created in version localizations
NEW_LANGS = [
    "ar-SA", "id", "it", "ms", "nl-NL", "pl", "tr", "vi",
    "hi", "da", "fr-CA", "fi", "ca", "cs",
    "hr", "ro", "no", "sv", "sk", "uk",
    "es-MX", "he", "el", "hu", "en-AU", "en-CA",
]

# Locale -> metadata dir mapping
LOCALE_MAP = {
    "ar-SA": "ar-SA", "id": "id", "it": "it", "ms": "ms", "nl-NL": "nl-NL",
    "pl": "pl", "tr": "tr", "vi": "vi", "hi": "hi", "da": "da",
    "fr-CA": "fr-CA", "fi": "fi", "ca": "ca", "cs": "cs", "hr": "hr",
    "ro": "ro", "no": "no", "sv": "sv", "sk": "sk", "uk": "uk",
    "es-MX": "es-MX", "he": "he", "el": "el", "hu": "hu",
    "en-AU": "en-AU", "en-CA": "en-CA",
}

def generate_jwt():
    with open(KEY_FILEPATH, "rb") as f:
        key = f.read()
    now = int(time.time())
    payload = {"iss": ISSUER_ID, "iat": now, "exp": now + 20 * 60, "aud": "appstoreconnect-v1"}
    headers = {"alg": "ES256", "kid": KEY_ID, "typ": "JWT"}
    return jwt.encode(payload, key, algorithm="ES256", headers=headers)

def read_metadata(locale_dir, field):
    filepath = os.path.join(METADATA_DIR, locale_dir, f"{field}.txt")
    if not os.path.exists(filepath):
        return None
    with open(filepath, "r", encoding="utf-8") as f:
        return f.read().strip()

def main():
    token = generate_jwt()
    H = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}

    # Get app
    resp = requests.get(f"{API_BASE}/apps", headers=H, params={"filter[bundleId]": BUNDLE_ID})
    app_id = resp.json()["data"][0]["id"]
    print(f"App ID: {app_id}")

    # Get appInfo
    resp = requests.get(f"{API_BASE}/apps/{app_id}/appInfos", headers=H, params={"fields[appInfos]": "appStoreState"})
    app_info_id = resp.json()["data"][0]["id"]
    print(f"AppInfo ID: {app_info_id}")

    # Get existing appInfo localizations
    resp = requests.get(f"{API_BASE}/appInfos/{app_info_id}/appInfoLocalizations", headers=H)
    existing = set(loc["attributes"]["locale"] for loc in resp.json()["data"])
    print(f"Existing: {len(existing)} localizations")

    # Create missing appInfo localizations with name
    print(f"\nCreating appInfoLocalizations with name...")
    created = 0
    failed = 0
    for lang in NEW_LANGS:
        if lang in existing:
            print(f"  SKIP {lang}: already exists")
            continue

        metadata_dir = LOCALE_MAP.get(lang, lang)
        name = read_metadata(metadata_dir, "name")
        subtitle = read_metadata(metadata_dir, "subtitle") or "Shoo"

        if not name:
            print(f"  SKIP {lang}: no name in metadata")
            continue

        # Truncate subtitle to 30 chars
        if subtitle and len(subtitle) > 30:
            subtitle = subtitle[:30]

        body = {
            "data": {
                "type": "appInfoLocalizations",
                "attributes": {
                    "locale": lang,
                    "name": name,
                    "subtitle": subtitle,
                },
                "relationships": {
                    "appInfo": {
                        "data": {"type": "appInfos", "id": app_info_id}
                    }
                }
            }
        }
        resp = requests.post(f"{API_BASE}/appInfoLocalizations", headers=H, json=body)
        if resp.status_code == 201:
            print(f"  OK {lang}: name={name[:30]}")
            created += 1
        else:
            print(f"  FAIL {lang}: {resp.status_code}")
            try:
                errs = resp.json().get("errors", [])
                for e in errs:
                    print(f"    {e.get('detail','')[:200]}")
            except:
                print(f"    {resp.text[:300]}")
            failed += 1

    print(f"\nDone! {created} created, {failed} failed")

if __name__ == "__main__":
    main()
