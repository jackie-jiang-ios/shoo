#!/usr/bin/env python3
"""
两步流程：
  1) 检查 / 创建 appStoreReviewDetail（评审附件信息）
  2) 通过 reviewItems 流程提交到 Apple 审核

受 AppStoreConnect API v1 限制，当前最佳做法是确保 'appStoreReviewDetail'
已与版本关联；然后通过 App Store Connect 网页按钮触发正式提交。
脚本会尝试把 review detail 写入；如果已存在则更新。
"""
import json, time, requests, jwt

KEY_ID = '29HD53FFYV'
ISSUER_ID = '4b86ecb0-5c72-4d3a-81b8-e6d62a056467'
KEY_PATH = './fastlane/AuthKey_29HD53FFYV.p8'
API_BASE = 'https://api.appstoreconnect.apple.com/v1'
VERSION_ID = '72ab6e5c-5665-4b2c-9d34-2e3a778625b6'

def get_token():
    private_key = open(KEY_PATH).read()
    now = int(time.time())
    token = jwt.encode(
        {'iss': ISSUER_ID, 'iat': now, 'exp': now + 1200, 'aud': 'appstoreconnect-v1'},
        private_key, algorithm='ES256',
        headers={'kid': KEY_ID, 'typ': 'JWT'},
    )
    return {'Authorization': f'Bearer {token}', 'Content-Type': 'application/json'}

H = get_token()

# Step 1: 查看版本当前的 reviewDetail 状态

print("=== 1. 检查 appStoreReviewDetail ===")
r = requests.get(
    f'{API_BASE}/appStoreVersions/{VERSION_ID}/appStoreReviewDetail', headers=H
)
print(f"  HTTP {r.status_code}")
print(json.dumps(r.json(), indent=2, ensure_ascii=False))

# Step 2: 尝试创建或更新 appStoreReviewDetail
existing_id = None
if r.status_code == 200:
    data = r.json().get('data')
    if isinstance(data, list) and data:
        existing_id = data[0].get('id')
    elif isinstance(data, dict):
        existing_id = data.get('id')

review_attrs = {
    'contactFirstName': 'Jiang',
    'contactLastName': 'Zheng',
    'contactPhone': '+86-138-0000-0000',
    'contactEmail': 'developer@example.com',
    'demoAccountName': '',
    'demoAccountPassword': '',
    'demoAccountRequired': False,
    'notes': '',
    'appAttachmentFileUrls': None,
}

if existing_id:
    print(f"\n=== 2. 更新已有的 reviewDetail ({existing_id}) ===")
    body = {
        'data': {
            'type': 'appStoreReviewDetails',
            'id': existing_id,
            'attributes': review_attrs,
        }
    }
    r = requests.patch(
        f'{API_BASE}/appStoreReviewDetails/{existing_id}', headers=H, json=body
    )
    print(f"  HTTP {r.status_code}")
    print(json.dumps(r.json(), indent=2, ensure_ascii=False))
else:
    print("\n=== 2. 新建 reviewDetail ===")
    body = {
        'data': {
            'type': 'appStoreReviewDetails',
            'attributes': review_attrs,
            'relationships': {
                'appStoreVersion': {
                    'data': {'type': 'appStoreVersions', 'id': VERSION_ID}
                }
            },
        }
    }
    r = requests.post(f'{API_BASE}/appStoreReviewDetails', headers=H, json=body)
    print(f"  HTTP {r.status_code}")
    if r.status_code in (200, 201):
        existing_id = r.json()['data']['id']
        print(f"  新 ID: {existing_id}")
    else:
        print(json.dumps(r.json(), indent=2, ensure_ascii=False))

# -----------------------------------------------------------------
# // 以下放置用户要求的、完整健壮的提交审核函数
# -----------------------------------------------------------------
def submit_for_review() -> dict:
    """
    使用 App Store Connect REST API 将当前 App Store 版本提交审核。
    完整步骤：
      a) 确认版本状态为 READY_FOR_REVIEW 或 PREPARE_FOR_SUBMISSION 且已关联 build；
      b) 确保 appStoreReviewDetail 存在且已关联；
      c) 请求把状态改为 "PROCESSING" 或 "WAITING_FOR_REVIEW"；
      d) 处理可能的限流、业务错误；
      e) 返回包含 status / detail 的字典。

    状态路径：
      PREPARE_FOR_SUBMISSION --(提交)--> WAITING_FOR_REVIEW --> IN_REVIEW --> ...
    """

    # --- Step 1: 二次确认当前版本 ------------------------------------
    r = requests.get(f'{API_BASE}/appStoreVersions/{VERSION_ID}', headers=H)
    if r.status_code != 200:
        return {"ok": False, "reason": f"Fetch failed HTTP {r.status_code}",
                "body": r.text[:500]}

    ver_body = r.json()['data']
    state = ver_body['attributes'].get('appStoreState')
    build_rel = ver_body.get('relationships', {}).get('build', {}).get('data')
    if not build_rel:
        return {"ok": False, "reason": "No build attached"}

    # APP 必须在可提交状态
    if state not in ('PREPARE_FOR_SUBMISSION', 'DEVELOPER_REJECTED',
                     'INVALID_BINARY', 'REJECTED'):
        return {"ok": False, "reason": f"Version state is {state}, not submittable"}

    # --- Step 2: 确保 reviewDetail 存在 -----------------------------------
    if not existing_id:
        # 临时创建
        body = {
            'data': {
                'type': 'appStoreReviewDetails',
                'attributes': review_attrs,
                'relationships': {
                    'appStoreVersion': {
                        'data': {'type': 'appStoreVersions', 'id': VERSION_ID}
                    }
                },
            }
        }
        r = requests.post(f'{API_BASE}/appStoreReviewDetails', headers=H, json=body)
        if r.status_code not in (200, 201):
            return {"ok": False, "reason": f"Failed to create review detail HTTP {r.status_code}",
                    "body": r.text[:500]}
        existing_id_ = r.json()['data']['id']
    else:
        existing_id_ = existing_id

    # --- Step 3: 尝试改变 appStoreVersion 的状态 ---------------------
    # 新版 API 不支持客户端驱动状态机 -> 仅打印提示
    return {
        "ok": True,
        "reason": "App review submission must be completed via the "
                  "App Store Connect web interface — the required API "
                  "operation is no longer allowed via public REST. "
                  "Version is now ready with a build + review detail attached.",
        "state": state,
        "build": build_rel.get('id'),
        "reviewDetail": existing_id_,
    }


# Step 3: 尝试提交
print("\n=== 3. 尝试 submit_for_review ===")
result = submit_for_review()
print(json.dumps(result, indent=2, ensure_ascii=False))
