#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
App Store Connect API - 上传 iPad 预览视频测试
用于验证 iPad 视频尺寸是否被 App Store Connect 接受
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
KEY_FILEPATH = "/Users/jiangzheng/Project/iOS/Shoo/shoo_flutter/fastlane/AuthKey_29HD53FFYV.p8"
BUNDLE_ID = "com.yangshiqin.shoo"

# iPad 视频文件
VIDEO_PATH = "/Users/jiangzheng/Project/iOS/Shoo/shoo_flutter/fastlane/screenshots_ipad/en-US/IPAD_PRO_13-0.mp4"

# 上传参数
LOCALE = "en-US"
PREVIEW_TYPE = "IPAD_PRO_3GEN_129"  # iPad Pro 12.9" 3rd gen+ / 13-inch (M5)

API_BASE = "https://api.appstoreconnect.apple.com/v1"


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


def main():
    print("=" * 60)
    print("  App Store Connect API - iPad 预览视频上传测试")
    print("=" * 60)
    print(f"  视频文件: {VIDEO_PATH}")
    print(f"  Bundle ID: {BUNDLE_ID}")
    print(f"  语言: {LOCALE}")
    print(f"  预览类型: {PREVIEW_TYPE}")

    if not os.path.exists(VIDEO_PATH):
        print(f"\n❌ 视频文件不存在: {VIDEO_PATH}")
        sys.exit(1)

    file_size = os.path.getsize(VIDEO_PATH)
    print(f"  文件大小: {file_size} bytes ({file_size/1024/1024:.2f} MB)")

    # Step 1: Token
    print("\n[Step 1] 生成 JWT Token...")
    token = generate_jwt()
    print(f"  ✅ Token 生成成功")

    # Step 2: 查找 App ID
    print("\n[Step 2] 查找 App ID...")
    resp = api_request("GET", f"{API_BASE}/apps", token, params={"filter[bundleId]": BUNDLE_ID})
    if resp.status_code != 200 or not resp.json().get("data"):
        print(f"  ❌ 查找 App 失败: {resp.status_code}")
        sys.exit(1)
    app_id = resp.json()["data"][0]["id"]
    print(f"  ✅ App ID: {app_id}")

    # Step 3: 查找版本和本地化
    print("\n[Step 3] 查找 App Store Version...")
    resp = api_request("GET", f"{API_BASE}/apps/{app_id}/appStoreVersions", token,
                       params={"filter[appStoreState]": "PREPARE_FOR_SUBMISSION,REJECTED,DEVELOPER_REJECTED,READY_FOR_SALE"})
    versions = resp.json().get("data", [])
    version = None
    for v in versions:
        if v["attributes"]["appStoreState"] == "PREPARE_FOR_SUBMISSION" and v["attributes"].get("platform") == "IOS":
            version = v
            break
    if not version:
        for v in versions:
            if v["attributes"]["appStoreState"] == "PREPARE_FOR_SUBMISSION":
                version = v
                break
    if not version:
        version = versions[0]
    version_id = version["id"]
    print(f"  ✅ 版本: {version['attributes']['versionString']} ({version['attributes']['appStoreState']})")

    # 查找本地化
    print("\n[Step 3b] 查找本地化...")
    resp = api_request("GET", f"{API_BASE}/appStoreVersions/{version_id}/appStoreVersionLocalizations", token)
    locs = resp.json().get("data", [])
    localization_id = None
    for loc in locs:
        if loc["attributes"]["locale"] == LOCALE:
            localization_id = loc["id"]
            break
    if not localization_id:
        print(f"  ❌ 未找到 {LOCALE} 的本地化")
        print(f"     可用: {[l['attributes']['locale'] for l in locs]}")
        sys.exit(1)
    print(f"  ✅ 本地化 ID: {localization_id}")

    # Step 4: 查找 Preview Set
    print(f"\n[Step 4] 查找 Preview Set (previewType={PREVIEW_TYPE})...")
    resp = api_request("GET", f"{API_BASE}/appStoreVersionLocalizations/{localization_id}/appPreviewSets", token)
    sets = resp.json().get("data", [])
    print(f"  找到 {len(sets)} 个 Preview Set:")
    target_set = None
    for s in sets:
        pt = s["attributes"]["previewType"]
        sid = s["id"]
        print(f"    - previewType: {pt}, ID: {sid}")
        if pt == PREVIEW_TYPE:
            target_set = s

    if not target_set:
        print(f"\n  ⚠️  未找到 previewType={PREVIEW_TYPE} 的 Preview Set")
        print(f"     尝试创建新的 Preview Set...")
        create_body = {
            "data": {
                "type": "appPreviewSets",
                "attributes": {"previewType": PREVIEW_TYPE},
                "relationships": {
                    "appStoreVersionLocalization": {
                        "data": {"type": "appStoreVersionLocalizations", "id": localization_id}
                    }
                }
            }
        }
        resp = api_request("POST", f"{API_BASE}/appPreviewSets", token, json_body=create_body)
        if resp.status_code == 201:
            target_set = resp.json()["data"]
            print(f"     ✅ 创建成功: {target_set['id']}")
        else:
            print(f"     ❌ 创建失败: {resp.status_code}")
            print(f"     {resp.json()}")
            sys.exit(1)

    preview_set_id = target_set["id"]
    print(f"  ✅ Preview Set ID: {preview_set_id}")

    # 检查并删除已有预览
    resp = api_request("GET", f"{API_BASE}/appPreviewSets/{preview_set_id}/appPreviews", token)
    existing = resp.json().get("data", [])
    if existing:
        print(f"\n  ⚠️  已有 {len(existing)} 个预览视频，删除中...")
        for old in existing:
            del_resp = api_request("DELETE", f"{API_BASE}/appPreviews/{old['id']}", token)
            if del_resp.status_code == 204:
                print(f"     ✅ 已删除: {old['id']}")
            else:
                print(f"     ❌ 删除失败: {del_resp.status_code}")
        time.sleep(3)

    # Step 5: 创建 App Preview
    print(f"\n[Step 5] 创建 App Preview...")
    body = {
        "data": {
            "type": "appPreviews",
            "attributes": {"fileSize": file_size, "fileName": os.path.basename(VIDEO_PATH)},
            "relationships": {
                "appPreviewSet": {"data": {"type": "appPreviewSets", "id": preview_set_id}}
            }
        }
    }
    resp = api_request("POST", f"{API_BASE}/appPreviews", token, json_body=body)
    if resp.status_code != 201:
        print(f"  ❌ 创建 App Preview 失败: {resp.status_code}")
        print(f"  {json.dumps(resp.json(), indent=2, ensure_ascii=False)}")
        sys.exit(1)

    result = resp.json()
    preview_id = result["data"]["id"]
    upload_operations = result["data"]["attributes"].get("uploadOperations", [])
    print(f"  ✅ Preview ID: {preview_id}")
    print(f"  上传分片数: {len(upload_operations)}")

    # Step 6: 上传分片
    print(f"\n[Step 6] 上传视频分片...")
    with open(VIDEO_PATH, "rb") as f:
        file_data = f.read()

    for i, op in enumerate(upload_operations):
        upload_url = op["url"]
        offset = op["offset"]
        length = op["length"]
        upload_headers = {h["name"]: h["value"] for h in op.get("requestHeaders", [])}
        chunk = file_data[offset:offset + length]
        upload_resp = requests.request(op["method"], upload_url, headers=upload_headers, data=chunk)
        if upload_resp.status_code in (200, 201, 204):
            print(f"  ✅ 分片 {i+1}/{len(upload_operations)} 上传成功")
        else:
            print(f"  ❌ 分片 {i+1} 上传失败: {upload_resp.status_code}")
            sys.exit(1)

    # Step 7: 提交
    print(f"\n[Step 7] 提交上传...")
    body = {
        "data": {"type": "appPreviews", "id": preview_id, "attributes": {"uploaded": True}}
    }
    resp = api_request("PATCH", f"{API_BASE}/appPreviews/{preview_id}", token, json_body=body)
    if resp.status_code != 200:
        print(f"  ❌ 提交失败: {resp.status_code}")
        print(f"  {json.dumps(resp.json(), indent=2, ensure_ascii=False)}")
        sys.exit(1)
    print(f"  ✅ 提交成功")

    # Step 8: 轮询状态
    print(f"\n[Step 8] 等待 Apple 处理...")
    start_time = time.time()
    while time.time() - start_time < 300:
        resp = api_request("GET", f"{API_BASE}/appPreviews/{preview_id}", token)
        if resp.status_code != 200:
            print(f"  ❌ 查询失败: {resp.status_code}")
            return
        attrs = resp.json()["data"]["attributes"]
        asset_state = attrs.get("assetDeliveryState", {}).get("state", "UNKNOWN")
        video_state = attrs.get("videoDeliveryState", {}).get("state", "UNKNOWN")
        elapsed = int(time.time() - start_time)
        print(f"  [{elapsed}s] 文件: {asset_state} | 视频: {video_state}")

        if video_state == "COMPLETE":
            print(f"\n  🎉 视频处理成功! Preview ID: {preview_id}")
            print(f"  iPad 视频尺寸 (886×1920) 被 App Store Connect 接受!")
            return
        elif video_state == "FAIL":
            print(f"\n  ❌ 视频处理失败!")
            errors = attrs.get("videoDeliveryState", {}).get("errors", [])
            if errors:
                print(f"  错误: {json.dumps(errors, indent=2, ensure_ascii=False)}")
            return
        time.sleep(5)

    print(f"\n  ⏰ 等待超时，请稍后手动查询状态")


if __name__ == "__main__":
    main()
