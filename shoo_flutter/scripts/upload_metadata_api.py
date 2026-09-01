#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
上传所有语言的完整 metadata 到 App Store Connect
- name, subtitle -> appInfoLocalizations (PATCH)
- description, keywords, promotionalText, whatsNew, supportUrl, marketingUrl -> appStoreVersionLocalizations (PATCH)
"""

import json
import time
import os
import sys
import requests
import jwt

# ══════════════════════════════════════
# 配置
# ══════════════════════════════════════
KEY_ID = "29HD53FFYV"
ISSUER_ID = "4b86ecb0-5c72-4d3a-81b8-e6d62a056467"
KEY_FILEPATH = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
                            "fastlane", "AuthKey_29HD53FFYV.p8")
BUNDLE_ID = "com.yangshiqin.shoo"

METADATA_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
                            "fastlane", "metadata")

SUPPORT_URL = "https://www.yeloving.com/shoo/support"
MARKETING_URL = "https://www.yeloving.com/shoo"

# App Store Connect locale -> fastlane metadata dir mapping
# App Store Connect 的 locale 和 fastlane 目录名的映射
LOCALE_MAP = {
    "zh-Hans": "zh-Hans",
    "zh-Hant": "zh-Hant",
    "en-US": "en-US",
    "en-AU": "en-AU",
    "en-CA": "en-CA",
    "en-GB": "en-GB",
    "ja": "ja",
    "ko": "ko",
    "fr-FR": "fr-FR",
    "fr-CA": "fr-CA",
    "de-DE": "de-DE",
    "es-ES": "es-ES",
    "es-MX": "es-MX",
    "pt-BR": "pt-BR",
    "ru": "ru",
    "th": "th",
    "ar-SA": "ar-SA",
    "id": "id",
    "it": "it",
    "ms": "ms",
    "nl-NL": "nl-NL",
    "pl": "pl",
    "tr": "tr",
    "vi": "vi",
    "hi": "hi",
    "da": "da",
    "fi": "fi",
    "gu": "gu",
    "ca": "ca",
    "cs": "cs",
    "kn": "kn",
    "hr": "hr",
    "ro": "ro",
    "mr": "mr",
    "ml": "ml",
    "bn": "bn",
    "no": "no",
    "pa": "pa",
    "sv": "sv",
    "sk": "sk",
    "sl": "sl",
    "te": "te",
    "ta": "ta",
    "ur": "ur",
    "uk": "uk",
    "he": "he",
    "el": "el",
    "hu": "hu",
}

API_BASE = "https://api.appstoreconnect.apple.com/v1"

# ══════════════════════════════════════
# 工具函数
# ══════════════════════════════════════

def generate_jwt():
    with open(KEY_FILEPATH, "rb") as f:
        key = f.read()
    now = int(time.time())
    payload = {
        "iss": ISSUER_ID,
        "iat": now,
        "exp": now + 20 * 60,
        "aud": "appstoreconnect-v1",
    }
    headers = {
        "alg": "ES256",
        "kid": KEY_ID,
        "typ": "JWT",
    }
    token = jwt.encode(payload, key, algorithm="ES256", headers=headers)
    return token


def api_request(method, url, token, json_body=None, params=None):
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json",
    }
    return requests.request(method, url, headers=headers, json=json_body, params=params)


def read_metadata(locale_dir, field):
    """读取 metadata 文件"""
    filepath = os.path.join(METADATA_DIR, locale_dir, f"{field}.txt")
    if not os.path.exists(filepath):
        return None
    with open(filepath, "r", encoding="utf-8") as f:
        return f.read().strip()


# ══════════════════════════════════════
# 主流程
# ══════════════════════════════════════

def main():
    print("=" * 60)
    print("  Shoo - 上传完整 metadata 到 App Store Connect")
    print("=" * 60)

    # 检查 API Key
    if not os.path.exists(KEY_FILEPATH):
        print(f"ERROR: API Key not found: {KEY_FILEPATH}")
        sys.exit(1)

    # 生成 Token
    token = generate_jwt()
    print(f"Token generated")

    # 查找 App ID
    url = f"{API_BASE}/apps"
    params = {"filter[bundleId]": BUNDLE_ID, "fields[apps]": "name,bundleId"}
    resp = api_request("GET", url, token, params=params)
    if resp.status_code != 200:
        print(f"ERROR: Find app failed: {resp.status_code}")
        print(json.dumps(resp.json(), indent=2, ensure_ascii=False))
        sys.exit(1)

    app_id = resp.json()["data"][0]["id"]
    app_name = resp.json()["data"][0]["attributes"]["name"]
    print(f"App: {app_name} (ID: {app_id})")

    # === 1. 上传 name + subtitle (appInfoLocalizations) ===
    print(f"\n{'='*60}")
    print("Step 1: Upload name + subtitle (appInfoLocalizations)")
    print(f"{'='*60}")

    # 查找 appInfo
    url = f"{API_BASE}/apps/{app_id}/appInfos"
    params = {"fields[appInfos]": "appStoreState"}
    resp = api_request("GET", url, token, params=params)
    if resp.status_code != 200:
        print(f"ERROR: Find appInfo failed: {resp.status_code}")
    else:
        app_info_id = resp.json()["data"][0]["id"]

        # 查询 appInfoLocalizations
        url = f"{API_BASE}/appInfos/{app_info_id}/appInfoLocalizations"
        resp = api_request("GET", url, token)
        if resp.status_code != 200:
            print(f"ERROR: Find appInfoLocalizations failed: {resp.status_code}")
        else:
            info_locs = resp.json()["data"]
            print(f"Found {len(info_locs)} appInfoLocalizations")

            success = 0
            fail = 0
            for loc in info_locs:
                loc_locale = loc["attributes"]["locale"]
                loc_id = loc["id"]
                metadata_dir = LOCALE_MAP.get(loc_locale, loc_locale)

                name = read_metadata(metadata_dir, "name")
                subtitle = read_metadata(metadata_dir, "subtitle")

                if not name and not subtitle:
                    print(f"  SKIP {loc_locale}: no name/subtitle")
                    continue

                # Truncate subtitle to 30 chars
                if subtitle and len(subtitle) > 30:
                    subtitle = subtitle[:30]
                    print(f"  WARNING: {loc_locale} subtitle truncated to 30 chars")

                attrs = {}
                if name:
                    attrs["name"] = name
                if subtitle:
                    attrs["subtitle"] = subtitle

                body = {
                    "data": {
                        "type": "appInfoLocalizations",
                        "id": loc_id,
                        "attributes": attrs
                    }
                }

                url = f"{API_BASE}/appInfoLocalizations/{loc_id}"
                resp = api_request("PATCH", url, token, json_body=body)

                if resp.status_code == 200:
                    print(f"  OK {loc_locale}: name={name[:20] if name else 'N/A'}, subtitle={subtitle[:20] if subtitle else 'N/A'}")
                    success += 1
                else:
                    print(f"  FAIL {loc_locale}: {resp.status_code}")
                    try:
                        errors = resp.json().get("errors", [])
                        for err in errors:
                            print(f"    Error: {err.get('detail', 'Unknown')}")
                    except:
                        print(f"    Response: {resp.text[:300]}")
                    fail += 1

            print(f"\n  name/subtitle: {success} ok, {fail} fail")

    # === 2. 上传 description + keywords + promotionalText + whatsNew + URLs (appStoreVersionLocalizations) ===
    print(f"\n{'='*60}")
    print("Step 2: Upload description/keywords/promotionalText/whatsNew/URLs")
    print(f"{'='*60}")

    # 查找 PREPARE_FOR_SUBMISSION 状态的版本
    url = f"{API_BASE}/apps/{app_id}/appStoreVersions"
    params = {
        "filter[appStoreState]": "PREPARE_FOR_SUBMISSION,REJECTED,DEVELOPER_REJECTED",
        "fields[appStoreVersions]": "versionString,appStoreState,platform",
    }
    resp = api_request("GET", url, token, params=params)
    if resp.status_code != 200:
        print(f"ERROR: Find version failed: {resp.status_code}")
        sys.exit(1)

    versions = resp.json()["data"]
    if not versions:
        print("ERROR: No PREPARE_FOR_SUBMISSION version found")
        sys.exit(1)

    version = None
    for v in versions:
        if v["attributes"].get("platform") == "IOS":
            version = v
            break
    if not version:
        version = versions[0]

    version_id = version["id"]
    version_string = version["attributes"]["versionString"]
    print(f"Version: {version_string} (ID: {version_id})")

    # 查询版本本地化
    url = f"{API_BASE}/appStoreVersions/{version_id}/appStoreVersionLocalizations"
    resp = api_request("GET", url, token)
    if resp.status_code != 200:
        print(f"ERROR: Find localizations failed: {resp.status_code}")
        sys.exit(1)

    locs = resp.json()["data"]
    print(f"Found {len(locs)} version localizations")

    success = 0
    fail = 0
    for loc in locs:
        loc_locale = loc["attributes"]["locale"]
        loc_id = loc["id"]
        metadata_dir = LOCALE_MAP.get(loc_locale, loc_locale)

        description = read_metadata(metadata_dir, "description")
        keywords = read_metadata(metadata_dir, "keywords")
        promotional_text = read_metadata(metadata_dir, "promotional_text")
        whats_new = read_metadata(metadata_dir, "release_notes")

        if not description and not keywords and not promotional_text and not whats_new:
            print(f"  SKIP {loc_locale}: no metadata")
            continue

        # Truncate keywords to 100 chars
        if keywords and len(keywords) > 100:
            keywords = keywords[:100]
            print(f"  WARNING: {loc_locale} keywords truncated to 100 chars")

        attrs = {}
        if description:
            attrs["description"] = description
        if keywords:
            attrs["keywords"] = keywords
        if promotional_text:
            attrs["promotionalText"] = promotional_text
        if whats_new:
            attrs["whatsNew"] = whats_new
        attrs["supportUrl"] = SUPPORT_URL
        attrs["marketingUrl"] = MARKETING_URL

        body = {
            "data": {
                "type": "appStoreVersionLocalizations",
                "id": loc_id,
                "attributes": attrs
            }
        }

        url = f"{API_BASE}/appStoreVersionLocalizations/{loc_id}"
        resp = api_request("PATCH", url, token, json_body=body)

        if resp.status_code == 200:
            desc_preview = description[:40] if description else "N/A"
            print(f"  OK {loc_locale}: desc={desc_preview}...")
            success += 1
        else:
            print(f"  FAIL {loc_locale}: {resp.status_code}")
            try:
                errors = resp.json().get("errors", [])
                for err in errors:
                    print(f"    Error: {err.get('detail', 'Unknown')}")
            except:
                print(f"    Response: {resp.text[:300]}")
            fail += 1

    print(f"\n{'='*60}")
    print(f"  Done! name/subtitle+metadata: {success} ok, {fail} fail")
    print(f"{'='*60}")


if __name__ == "__main__":
    main()
