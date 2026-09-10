#!/usr/bin/env python3
import time, requests, jwt

KEY_ID = '29HD53FFYV'
ISSUER_ID = '4b86ecb0-5c72-4d3a-81b8-e6d62a056467'
KEY_PATH = '/Users/jiangzheng/Project/iOS/Shoo/shoo_flutter/fastlane/AuthKey_29HD53FFYV.p8'
API_BASE = 'https://api.appstoreconnect.apple.com/v1'

private_key = open(KEY_PATH).read()
now = int(time.time())
token = jwt.encode({'iss': ISSUER_ID, 'iat': now, 'exp': now+1200, 'aud': 'appstoreconnect-v1'}, private_key, algorithm='ES256', headers={'kid': KEY_ID, 'typ': 'JWT'})
H = {'Authorization': f'Bearer {token}', 'Content-Type': 'application/json'}

preview_id = '0689653d-24dc-4ec7-a5f5-19dbbe407b08'
r = requests.get(f'{API_BASE}/appPreviews/{preview_id}', headers=H)
attrs = r.json()['data']['attributes']
print(f"fileName: {attrs.get('fileName')}")
print(f"fileSize: {attrs.get('fileSize')}")
print(f"videoState: {attrs.get('videoDeliveryState', {}).get('state')}")
print(f"assetState: {attrs.get('assetDeliveryState', {}).get('state')}")
print(f"previewId: {r.json()['data']['id']}")
