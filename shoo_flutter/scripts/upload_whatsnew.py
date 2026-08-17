#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
上传所有语言的 release_notes (whatsNew) 到 App Store Connect
通过 API 直接 PATCH appStoreVersionLocalizations
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

# App Store Connect locale -> fastlane metadata dir mapping
LOCALE_MAP = {
    "zh-Hans": "zh-Hans",
    "zh-Hant": "zh-Hant",
    "en-US": "en-US",
    "ja": "ja",
    "ko": "ko",
    "fr-FR": "fr-FR",
    "de-DE": "de-DE",
    "es-ES": "es-ES",
    "pt-BR": "pt-BR",
    "pt-PT": "pt-BR",  # pt-PT uses same content as pt-BR
    "ru": "ru",
    "th": "th",
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
    print("  Shoo - 上传 whatsNew (release_notes) 到 App Store Connect")
    print("=" * 60)

    # 检查 API Key
    if not os.path.exists(KEY_FILEPATH):
        print(f"❌ API Key 文件不存在: {KEY_FILEPATH}")
        sys.exit(1)

    # 生成 Token
    token = generate_jwt()
    print(f"✅ Token 生成成功")

    # 查找 App ID
    url = f"{API_BASE}/apps"
    params = {"filter[bundleId]": BUNDLE_ID, "fields[apps]": "name,bundleId"}
    resp = api_request("GET", url, token, params=params)
    if resp.status_code != 200:
        print(f"❌ 查找 App 失败: {resp.status_code}")
        print(json.dumps(resp.json(), indent=2, ensure_ascii=False))
        sys.exit(1)

    app_id = resp.json()["data"][0]["id"]
    app_name = resp.json()["data"][0]["attributes"]["name"]
    print(f"✅ 找到 App: {app_name} (ID: {app_id})")

    # 查找 PREPARE_FOR_SUBMISSION 状态的版本
    url = f"{API_BASE}/apps/{app_id}/appStoreVersions"
    params = {
        "filter[appStoreState]": "PREPARE_FOR_SUBMISSION,REJECTED,DEVELOPER_REJECTED",
        "fields[appStoreVersions]": "versionString,appStoreState,platform",
    }
    resp = api_request("GET", url, token, params=params)
    if resp.status_code != 200:
        print(f"❌ 查找版本失败: {resp.status_code}")
        sys.exit(1)

    versions = resp.json()["data"]
    if not versions:
        print("❌ 未找到 PREPARE_FOR_SUBMISSION 状态的版本")
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
    print(f"✅ 选中版本: {version_string} (ID: {version_id})")

    # 查询版本本地化
    url = f"{API_BASE}/appStoreVersions/{version_id}/appStoreVersionLocalizations"
    resp = api_request("GET", url, token)
    if resp.status_code != 200:
        print(f"❌ 查询本地化失败: {resp.status_code}")
        sys.exit(1)

    locs = resp.json()["data"]
    print(f"\n该版本有 {len(locs)} 个本地化:")
    for loc in locs:
        loc_locale = loc["attributes"]["locale"]
        current_whats_new = loc["attributes"].get("whatsNew", "")
        has_content = "有" if current_whats_new and current_whats_new.strip() else "空"
        print(f"  - {loc_locale:10s} (ID: {loc['id']}) whatsNew: {has_content}")

    # 上传 whatsNew
    print(f"\n{'='*60}")
    print("开始上传 whatsNew...")
    print(f"{'='*60}")

    success_count = 0
    fail_count = 0

    for loc in locs:
        loc_locale = loc["attributes"]["locale"]
        loc_id = loc["id"]

        # 获取对应 metadata 目录
        metadata_dir = LOCALE_MAP.get(loc_locale, loc_locale)
        whats_new = read_metadata(metadata_dir, "release_notes")

        if not whats_new:
            print(f"\n  ⚠️  {loc_locale}: 没有 release_notes.txt，跳过")
            continue

        print(f"\n  📝 {loc_locale}:")
        print(f"     whatsNew: {whats_new[:80]}...")

        # PATCH appStoreVersionLocalizations
        body = {
            "data": {
                "type": "appStoreVersionLocalizations",
                "id": loc_id,
                "attributes": {
                    "whatsNew": whats_new,
                }
            }
        }

        url = f"{API_BASE}/appStoreVersionLocalizations/{loc_id}"
        resp = api_request("PATCH", url, token, json_body=body)

        if resp.status_code == 200:
            print(f"     ✅ 上传成功!")
            success_count += 1
        else:
            print(f"     ❌ 上传失败: {resp.status_code}")
            try:
                errors = resp.json().get("errors", [])
                for err in errors:
                    print(f"        错误: {err.get('detail', 'Unknown')}")
            except:
                print(f"        响应: {resp.text[:500]}")
            fail_count += 1

    print(f"\n{'='*60}")
    print(f"  上传完成! 成功: {success_count}, 失败: {fail_count}")
    print(f"{'='*60}")


if __name__ == "__main__":
    main()
