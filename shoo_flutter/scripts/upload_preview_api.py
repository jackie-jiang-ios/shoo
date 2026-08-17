#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
通过 App Store Connect API 直接上传 App 预览视频
参考 FlipPrinter 项目的 upload_preview_api.py，适配 Shoo 防兽神器 App

用法:
  python3 scripts/upload_preview_api.py                              # 上传默认视频
  python3 scripts/upload_preview_api.py --video path/to/video.mp4    # 指定视频
  python3 scripts/upload_preview_api.py --locale en-US               # 指定语言
  python3 scripts/upload_preview_api.py --preview-type IPHONE_67     # 指定设备类型
  python3 scripts/upload_preview_api.py --check-only                 # 仅检查状态

完整流程:
  1. 生成 JWT Token
  2. 通过 Bundle ID 查找 App ID
  3. 查找处于可编辑状态的 App Store Version
  4. 查找对应设备和语言的 App Preview Set
  5. 如果已有旧预览视频，先删除
  6. POST /v1/appPreviews 创建预览（获取上传分片信息）
  7. 按分片 PUT 上传视频文件
  8. PATCH /v1/appPreviews/{id} 标记上传完成
  9. 轮询处理状态直到 SUCCESS
"""

import json
import time
import os
import sys
import argparse
import requests
import jwt

# ══════════════════════════════════════
# 配置 - Shoo 防兽神器
# ══════════════════════════════════════
KEY_ID = "29HD53FFYV"
ISSUER_ID = "4b86ecb0-5c72-4d3a-81b8-e6d62a056467"
KEY_FILEPATH = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
                            "fastlane", "AuthKey_29HD53FFYV.p8")
BUNDLE_ID = "com.yangshiqin.shoo"

# 默认视频文件路径
DEFAULT_VIDEO_PATH = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
                                  "fastlane", "screenshots", "zh-Hans", "IPHONE_67-0.mp4")

# 默认上传参数
DEFAULT_LOCALE = "zh-Hans"
DEFAULT_PREVIEW_TYPE = "IPHONE_67"  # iPhone 6.7" (iPhone 16 Pro Max 等)

# API 基础 URL
API_BASE = "https://api.appstoreconnect.apple.com/v1"

# ══════════════════════════════════════
# 工具函数
# ══════════════════════════════════════

def generate_jwt():
    """生成 App Store Connect API JWT Token"""
    with open(KEY_FILEPATH, "rb") as f:
        key = f.read()

    now = int(time.time())
    payload = {
        "iss": ISSUER_ID,
        "iat": now,
        "exp": now + 20 * 60,  # 20 分钟有效期
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
    """发送 App Store Connect API 请求"""
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json",
    }
    resp = requests.request(method, url, headers=headers, json=json_body, params=params)
    return resp


def print_json(label, data):
    """格式化打印 JSON"""
    print(f"\n{'='*60}")
    print(f"📋 {label}")
    print(f"{'='*60}")
    if isinstance(data, (dict, list)):
        print(json.dumps(data, indent=2, ensure_ascii=False))
    else:
        print(data)


# ══════════════════════════════════════
# 步骤函数
# ══════════════════════════════════════

def step1_generate_token():
    """步骤 1: 生成 JWT Token"""
    print("\n" + "🔥" * 30)
    print("步骤 1: 生成 JWT Token")
    print("🔥" * 30)
    token = generate_jwt()
    print(f"✅ Token 生成成功 (前50字符): {token[:50]}...")
    return token


def step2_find_app_id(token):
    """步骤 2: 通过 Bundle ID 查找 App ID"""
    print("\n" + "🔍" * 30)
    print("步骤 2: 查找 App ID")
    print("🔍" * 30)

    url = f"{API_BASE}/apps"
    params = {
        "filter[bundleId]": BUNDLE_ID,
        "fields[apps]": "name,bundleId",
    }
    resp = api_request("GET", url, token, params=params)

    if resp.status_code != 200:
        print(f"❌ 查找 App 失败: {resp.status_code}")
        print_json("错误详情", resp.json())
        sys.exit(1)

    data = resp.json()["data"]
    if not data:
        print(f"❌ 未找到 Bundle ID 为 {BUNDLE_ID} 的 App")
        sys.exit(1)

    app = data[0]
    app_id = app["id"]
    app_name = app["attributes"]["name"]
    print(f"✅ 找到 App: {app_name}")
    print(f"   App ID: {app_id}")
    return app_id


def step3_find_app_store_version(token, app_id, locale):
    """步骤 3: 查找处于可编辑状态的 App Store Version"""
    print("\n" + "📦" * 30)
    print("步骤 3: 查找 App Store Version")
    print("📦" * 30)

    url = f"{API_BASE}/apps/{app_id}/appStoreVersions"
    params = {
        "filter[appStoreState]": "PREPARE_FOR_SUBMISSION,REJECTED,DEVELOPER_REJECTED,READY_FOR_SALE",
        "fields[appStoreVersions]": "versionString,appStoreState,platform,appStoreVersionLocalizations",
        "include": "appStoreVersionLocalizations",
    }
    resp = api_request("GET", url, token, params=params)

    if resp.status_code != 200:
        print(f"❌ 查找版本失败: {resp.status_code}")
        print_json("错误详情", resp.json())
        sys.exit(1)

    versions = resp.json()["data"]

    if not versions:
        print("❌ 未找到任何 App Store Version")
        print("   请先在 App Store Connect 创建一个新版本")
        sys.exit(1)

    print(f"找到 {len(versions)} 个版本:")
    for v in versions:
        state = v["attributes"]["appStoreState"]
        ver = v["attributes"]["versionString"]
        platform = v["attributes"].get("platform", "?")
        print(f"  - 版本 {ver} (状态: {state}, 平台: {platform})")

    # 优先选择 PREPARE_FOR_SUBMISSION 状态 + iOS 平台的版本
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
    version_string = version["attributes"]["versionString"]
    version_state = version["attributes"]["appStoreState"]
    print(f"\n✅ 选中版本: {version_string} (状态: {version_state})")
    print(f"   Version ID: {version_id}")

    # 查询本地化
    print(f"\n   查询版本本地化...")
    url2 = f"{API_BASE}/appStoreVersions/{version_id}/appStoreVersionLocalizations"
    resp2 = api_request("GET", url2, token)
    if resp2.status_code != 200:
        print(f"❌ 查询本地化失败: {resp2.status_code}")
        print_json("错误", resp2.json())
        sys.exit(1)

    locs = resp2.json()["data"]
    localization_id = None
    print(f"   该版本有 {len(locs)} 个本地化:")
    for loc in locs:
        loc_locale = loc["attributes"]["locale"]
        print(f"     - {loc_locale} (ID: {loc['id']})")
        if loc_locale == locale:
            localization_id = loc["id"]

    if not localization_id:
        print(f"\n❌ 未找到 {locale} 的本地化")
        print(f"   可用语言: {[loc['attributes']['locale'] for loc in locs]}")
        sys.exit(1)

    print(f"\n   ✅ 使用 {locale} 本地化 ID: {localization_id}")
    return version_id, localization_id


def step4_find_preview_set(token, localization_id, preview_type):
    """步骤 4: 查找对应设备的 App Preview Set"""
    print("\n" + "🎬" * 30)
    print("步骤 4: 查找 App Preview Set")
    print("🎬" * 30)

    url = f"{API_BASE}/appStoreVersionLocalizations/{localization_id}/appPreviewSets"
    params = {
        "fields[appPreviewSets]": "previewType,appPreviews",
    }
    resp = api_request("GET", url, token, params=params)

    if resp.status_code != 200:
        print(f"❌ 查找 Preview Set 失败: {resp.status_code}")
        print_json("错误详情", resp.json())
        sys.exit(1)

    sets = resp.json()["data"]
    print(f"找到 {len(sets)} 个 Preview Set:")

    target_set = None
    for s in sets:
        pt = s["attributes"]["previewType"]
        sid = s["id"]
        existing_previews = s.get("relationships", {}).get("appPreviews", {}).get("data", [])
        print(f"  - previewType: {pt}, ID: {sid}, 已有预览数: {len(existing_previews)}")

        if pt == preview_type:
            target_set = s

    if not target_set:
        print(f"\n⚠️  未找到 previewType={preview_type} 的 Preview Set")
        print("   尝试创建新的 Preview Set...")

        create_url = f"{API_BASE}/appPreviewSets"
        create_body = {
            "data": {
                "type": "appPreviewSets",
                "attributes": {
                    "previewType": preview_type,
                },
                "relationships": {
                    "appStoreVersionLocalization": {
                        "data": {
                            "type": "appStoreVersionLocalizations",
                            "id": localization_id,
                        }
                    }
                }
            }
        }
        resp = api_request("POST", create_url, token, json_body=create_body)
        if resp.status_code == 201:
            target_set = resp.json()["data"]
            print(f"✅ 创建新 Preview Set: {target_set['id']}")
        else:
            print(f"❌ 创建 Preview Set 失败: {resp.status_code}")
            print_json("错误", resp.json())
            sys.exit(1)

    preview_set_id = target_set["id"]
    print(f"\n✅ 选中 Preview Set: {preview_set_id} (previewType: {target_set['attributes']['previewType']})")

    # 查询已有预览
    check_url = f"{API_BASE}/appPreviewSets/{preview_set_id}/appPreviews"
    check_resp = api_request("GET", check_url, token)
    if check_resp.status_code == 200:
        existing = check_resp.json().get("data", [])
    else:
        existing = []

    if existing:
        print(f"⚠️  该 Set 中已有 {len(existing)} 个预览视频，需要先删除")
        for old_preview in existing:
            old_id = old_preview["id"]
            old_state = old_preview.get("attributes", {}).get("videoDeliveryState", {}).get("state", "?")
            print(f"   删除旧预览: {old_id} (视频状态: {old_state})...")
            del_resp = api_request("DELETE", f"{API_BASE}/appPreviews/{old_id}", token)
            if del_resp.status_code == 204:
                print(f"   ✅ 已删除")
            else:
                print(f"   ❌ 删除失败: {del_resp.status_code}")
        print("   等待删除完成...")
        time.sleep(3)

    return preview_set_id


def step5_create_preview(token, preview_set_id, video_path):
    """步骤 5: 创建 App Preview（获取上传分片信息）"""
    print("\n" + "📤" * 30)
    print("步骤 5: 创建 App Preview")
    print("📤" * 30)

    file_size = os.path.getsize(video_path)
    file_name = os.path.basename(video_path)

    print(f"   文件名: {file_name}")
    print(f"   文件大小: {file_size} bytes ({file_size / 1024 / 1024:.2f} MB)")

    url = f"{API_BASE}/appPreviews"
    body = {
        "data": {
            "type": "appPreviews",
            "attributes": {
                "fileSize": file_size,
                "fileName": file_name,
            },
            "relationships": {
                "appPreviewSet": {
                    "data": {
                        "type": "appPreviewSets",
                        "id": preview_set_id,
                    }
                }
            }
        }
    }

    resp = api_request("POST", url, token, json_body=body)

    if resp.status_code != 201:
        print(f"❌ 创建 App Preview 失败: {resp.status_code}")
        print_json("错误详情", resp.json())
        sys.exit(1)

    result = resp.json()
    preview_id = result["data"]["id"]
    upload_operations = result["data"]["attributes"].get("uploadOperations", []) or []

    print(f"✅ App Preview 创建成功!")
    print(f"   Preview ID: {preview_id}")
    print(f"   上传分片数: {len(upload_operations)}")

    if len(upload_operations) == 0:
        print("\n⚠️  未获取到上传分片! 打印完整响应:")
        print_json("完整响应", result)
        sys.exit(1)

    total = 0
    for i, op in enumerate(upload_operations):
        offset = op["offset"]
        length = op["length"]
        total += length
        print(f"   分片 {i+1}: offset={offset}, length={length} ({length/1024:.1f} KB)")

    print(f"   分片总字节: {total} (应等于文件大小 {file_size})")

    return preview_id, upload_operations


def step6_upload_chunks(token, preview_id, upload_operations, video_path):
    """步骤 6: 按分片上传视频文件"""
    print("\n" + "⬆️" * 30)
    print("步骤 6: 上传视频分片")
    print("⬆️" * 30)

    with open(video_path, "rb") as f:
        file_data = f.read()

    file_size = len(file_data)
    total_uploaded = 0

    for i, op in enumerate(upload_operations):
        method = op["method"]
        upload_url = op["url"]
        offset = op["offset"]
        length = op["length"]

        upload_headers = {}
        for h in op.get("requestHeaders", []):
            upload_headers[h["name"]] = h["value"]

        chunk = file_data[offset:offset + length]

        print(f"\n  分片 {i+1}/{len(upload_operations)}:")
        print(f"    方法: {method}")
        print(f"    偏移: {offset}, 长度: {length} ({length/1024:.1f} KB)")
        print(f"    URL: {upload_url[:80]}...")

        upload_resp = requests.request(method, upload_url, headers=upload_headers, data=chunk)

        total_uploaded += length
        progress = total_uploaded / file_size * 100

        if upload_resp.status_code in (200, 201, 204):
            print(f"    ✅ 上传成功 ({upload_resp.status_code}) - 总进度: {progress:.1f}%")
        else:
            print(f"    ❌ 上传失败: {upload_resp.status_code}")
            print(f"    响应: {upload_resp.text[:500]}")
            sys.exit(1)

    print(f"\n✅ 所有分片上传完成! 总计 {total_uploaded} bytes")


def step7_commit_upload(token, preview_id):
    """步骤 7: 提交上传完成"""
    print("\n" + "✅" * 30)
    print("步骤 7: 提交上传完成")
    print("✅" * 30)

    url = f"{API_BASE}/appPreviews/{preview_id}"
    body = {
        "data": {
            "type": "appPreviews",
            "id": preview_id,
            "attributes": {
                "uploaded": True,
            }
        }
    }

    resp = api_request("PATCH", url, token, json_body=body)

    if resp.status_code != 200:
        print(f"❌ 提交失败: {resp.status_code}")
        print_json("错误详情", resp.json())
        sys.exit(1)

    result = resp.json()
    state = result["data"]["attributes"].get("sourceFileValidationState", "UNKNOWN")
    print(f"✅ 提交成功!")
    print(f"   当前状态: {state}")
    return state


def step8_poll_status(token, preview_id, max_wait=300):
    """步骤 8: 轮询处理状态"""
    print("\n" + "⏳" * 30)
    print("步骤 8: 等待 Apple 处理视频...")
    print("⏳" * 30)

    url = f"{API_BASE}/appPreviews/{preview_id}"
    start_time = time.time()

    while time.time() - start_time < max_wait:
        resp = api_request("GET", url, token)

        if resp.status_code != 200:
            print(f"❌ 查询失败: {resp.status_code}")
            return False

        attrs = resp.json()["data"]["attributes"]
        asset_state = attrs.get("assetDeliveryState", {}).get("state", "UNKNOWN")
        video_state = attrs.get("videoDeliveryState", {}).get("state", "UNKNOWN")
        frame_state = attrs.get("previewFrameImage", {}).get("state", {}).get("state", "UNKNOWN") if attrs.get("previewFrameImage") else "UNKNOWN"

        elapsed = int(time.time() - start_time)
        print(f"  [{elapsed}s] 文件传输: {asset_state} | 视频处理: {video_state} | 封面帧: {frame_state}")

        if video_state == "COMPLETE":
            print("\n🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉")
            print(f"✅ 视频处理成功! Preview ID: {preview_id}")
            print("🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉")
            return True
        elif video_state == "FAIL":
            print(f"\n❌ 视频处理失败!")
            errors = attrs.get("videoDeliveryState", {}).get("errors", [])
            if errors:
                print(f"   错误: {json.dumps(errors, indent=2, ensure_ascii=False)}")
            return False

        time.sleep(5)

    print(f"\n⏰ 等待超时 ({max_wait}s)")
    return False


def check_status_only(token, app_id, locale):
    """仅检查 App Store Connect 上的预览视频状态"""
    print("\n" + "📊" * 30)
    print(f"检查 Shoo ({BUNDLE_ID}) 的 App Store Connect 状态")
    print("📊" * 30)

    # 查找版本
    url = f"{API_BASE}/apps/{app_id}/appStoreVersions"
    params = {
        "filter[appStoreState]": "PREPARE_FOR_SUBMISSION,REJECTED,DEVELOPER_REJECTED,READY_FOR_SALE",
        "fields[appStoreVersions]": "versionString,appStoreState,platform",
    }
    resp = api_request("GET", url, token, params=params)
    if resp.status_code != 200:
        print(f"❌ 查找版本失败: {resp.status_code}")
        return

    versions = resp.json()["data"]
    if not versions:
        print("❌ 未找到任何 App Store Version")
        return

    for v in versions:
        state = v["attributes"]["appStoreState"]
        ver = v["attributes"]["versionString"]
        platform = v["attributes"].get("platform", "?")
        print(f"\n  版本 {ver} (状态: {state}, 平台: {platform})")

        # 查询本地化
        vid = v["id"]
        url2 = f"{API_BASE}/appStoreVersions/{vid}/appStoreVersionLocalizations"
        resp2 = api_request("GET", url2, token)
        if resp2.status_code != 200:
            continue
        locs = resp2.json()["data"]
        for loc in locs:
            loc_locale = loc["attributes"]["locale"]
            loc_id = loc["id"]

            # 查询预览集
            url3 = f"{API_BASE}/appStoreVersionLocalizations/{loc_id}/appPreviewSets"
            resp3 = api_request("GET", url3, token)
            if resp3.status_code != 200:
                continue
            sets = resp3.json().get("data", [])

            preview_info = "无"
            for s in sets:
                pt = s["attributes"]["previewType"]
                # 查询预览
                check_url = f"{API_BASE}/appPreviewSets/{s['id']}/appPreviews"
                check_resp = api_request("GET", check_url, token)
                if check_resp.status_code == 200:
                    previews = check_resp.json().get("data", [])
                    for p in previews:
                        vstate = p.get("attributes", {}).get("videoDeliveryState", {}).get("state", "?")
                        preview_info = f"{pt}: {vstate}"

            # 查询截图数
            url4 = f"{API_BASE}/appStoreVersionLocalizations/{loc_id}/appScreenshots"
            resp4 = api_request("GET", url4, token)
            screenshot_count = 0
            if resp4.status_code == 200:
                screenshot_count = len(resp4.json().get("data", []))

            marker = " ◀◀" if loc_locale == locale else ""
            print(f"    {loc_locale:10s}  截图: {screenshot_count}  预览视频: {preview_info}{marker}")


# ══════════════════════════════════════
# 主函数
# ══════════════════════════════════════

def main():
    parser = argparse.ArgumentParser(description="Shoo App Store Connect 预览视频上传工具")
    parser.add_argument("--video", default=DEFAULT_VIDEO_PATH, help=f"视频文件路径 (默认: {DEFAULT_VIDEO_PATH})")
    parser.add_argument("--locale", default=DEFAULT_LOCALE, help=f"语言代码 (默认: {DEFAULT_LOCALE})")
    parser.add_argument("--preview-type", default=DEFAULT_PREVIEW_TYPE,
                        help=f"预览类型: IPHONE_65 或 IPHONE_67 (默认: {DEFAULT_PREVIEW_TYPE})")
    parser.add_argument("--check-only", action="store_true", help="仅检查 App Store Connect 状态，不上传")
    args = parser.parse_args()

    print("=" * 60)
    print("  Shoo 防兽神器 - App Store Connect 预览视频上传")
    print("=" * 60)
    print(f"  Bundle ID: {BUNDLE_ID}")
    print(f"  语言: {args.locale}")
    print(f"  预览类型: {args.preview_type}")

    if not args.check_only:
        print(f"  视频文件: {args.video}")

    # 检查 API Key 文件
    if not os.path.exists(KEY_FILEPATH):
        print(f"\n❌ API Key 文件不存在: {KEY_FILEPATH}")
        print("   请将 AuthKey .p8 文件放到 fastlane/ 目录")
        sys.exit(1)

    # 检查视频文件
    if not args.check_only:
        if not os.path.exists(args.video):
            print(f"\n❌ 视频文件不存在: {args.video}")
            print("\n   💡 你可以先录制视频:")
            print("   1. 使用 integration_test/video_test.dart + record_all_videos.sh 录制")
            print("   2. 或手动录制 App 操作视频并用 ffmpeg 处理")
            print(f"\n   预期视频路径: {DEFAULT_VIDEO_PATH}")
            print(f"   视频要求: 886x1920 分辨率, H.264, 15-30秒, 带音频")
            sys.exit(1)

        file_size = os.path.getsize(args.video)
        print(f"  文件大小: {file_size} bytes ({file_size/1024/1024:.2f} MB)")

    # 步骤 1: 生成 Token
    token = step1_generate_token()

    # 步骤 2: 查找 App ID
    app_id = step2_find_app_id(token)

    # 仅检查模式
    if args.check_only:
        check_status_only(token, app_id, args.locale)
        print("\n" + "=" * 60)
        print("  状态检查完成!")
        print("=" * 60)
        return

    # 步骤 3: 查找 App Store Version 和 Localization
    version_id, localization_id = step3_find_app_store_version(token, app_id, args.locale)

    # 步骤 4: 查找 Preview Set
    preview_set_id = step4_find_preview_set(token, localization_id, args.preview_type)

    # 步骤 5: 创建 App Preview
    preview_id, upload_operations = step5_create_preview(token, preview_set_id, args.video)

    # 步骤 6: 上传分片
    step6_upload_chunks(token, preview_id, upload_operations, args.video)

    # 步骤 7: 提交上传完成
    step7_commit_upload(token, preview_id)

    # 步骤 8: 轮询处理状态
    step8_poll_status(token, preview_id)

    print("\n" + "=" * 60)
    print("  全部完成! 视频已上传到 App Store Connect")
    print("  👉 请前往 https://appstoreconnect.apple.com 确认")
    print("=" * 60)


if __name__ == "__main__":
    main()
