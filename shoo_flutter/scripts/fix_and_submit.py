#!/usr/bin/env python3
"""1. 重新附加 build 13; 2. 删除不需要的 pt-PT 语言"""
import json, time, requests, jwt

KEY_ID = '29HD53FFYV'
ISSUER_ID = '4b86ecb0-5c72-4d3a-81b8-e6d62a056467'
KEY_PATH = './fastlane/AuthKey_29HD53FFYV.p8'
API_BASE = 'https://api.appstoreconnect.apple.com/v1'
VERSION_ID = '72ab6e5c-5665-4b2c-9d34-2e3a778625b6'
BUILD_ID = '73d59482-3972-47c5-a5a0-ef909d7999d1'

def get_token():
    private_key = open(KEY_PATH).read()
    now = int(time.time())
    token = jwt.encode(
        {'iss': ISSUER_ID, 'iat': now, 'exp': now+1200, 'aud': 'appstoreconnect-v1'},
        private_key, algorithm='ES256', headers={'kid': KEY_ID, 'typ': 'JWT'}
    )
    return {'Authorization': f'Bearer {token}', 'Content-Type': 'application/json'}

# 1. 重新附加 build
print("=== 1. 重新附加 Build 13 ===")
H = get_token()
body = {'data':{'type':'appStoreVersions','id':VERSION_ID,
  'relationships':{'build':{'data':{'type':'builds','id':BUILD_ID}}}}}
r = requests.patch(f'{API_BASE}/appStoreVersions/{VERSION_ID}', headers=H, json=body)
print(f"  HTTP {r.status_code}")

# 确认 build 已附加
H = get_token()
r = requests.get(f'{API_BASE}/appStoreVersions/{VERSION_ID}/build', headers=H)
print(f"  GET /build: HTTP {r.status_code}")
if r.status_code == 200:
    bdata = r.json()['data']
    print(f"  Build version: {bdata['attributes']['version']}")
    print(f"  Build expired: {bdata['attributes']['expired']}")

# 2. 列出所有 localizations，找到 pt-PT
print("\n=== 2. 查看 localizations ===")
H = get_token()
r = requests.get(f'{API_BASE}/appStoreVersions/{VERSION_ID}/appStoreVersionLocalizations',
                 headers=H)
locs = r.json().get('data', [])
print(f"  Total: {len(locs)}")

# 找到我们不需要的语言（不在 49 种语言列表中的）
our_langs = {'en-US','en-AU','en-CA','en-GB','zh-Hans','zh-Hant','ja','ko','fr-FR','fr-CA',
             'de-DE','es-ES','es-MX','ru','pt-BR','th','ar-SA','id','it','ms','nl-NL','pl','tr',
             'vi','hi','da','fi','gu-IN','ca','cs','kn-IN','hr','ro','mr-IN','ml-IN','bn-BD',
             'no','pa-IN','sv','sk','sl-SI','te-IN','ta-IN','uk','ur-PK','or-IN','el','he','hu'}

for loc in locs:
    locale = loc['attributes']['locale']
    loc_id = loc['id']
    if locale in our_langs:
        continue
    print(f"  额外语言: {locale} (id={loc_id}) -> 准备删除")
    
    # 删除该 localization（级联删除其截图集等）
    H = get_token()
    r = requests.delete(
        f'{API_BASE}/appStoreVersionLocalizations/{loc_id}', headers=H)
    print(f"    DELETE {locale}: HTTP {r.status_code}")
    if r.status_code != 204:
        print(f"    {r.json()}")

# 3. 验证删除后状态
print("\n=== 3. 验证 ===")
H = get_token()
r = requests.get(f'{API_BASE}/appStoreVersions/{VERSION_ID}/appStoreVersionLocalizations',
                 headers=H)
locs = r.json().get('data', [])
print(f"  Localizations left: {len(locs)}")
locales = sorted([l['attributes']['locale'] for l in locs])
print(f"  {locales}")
