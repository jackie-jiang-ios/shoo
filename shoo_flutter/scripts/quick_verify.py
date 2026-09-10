#!/usr/bin/env python3
import jwt, time, requests, json
KEY_ID='29HD53FFYV'
ISSUER_ID='4b86ecb0-5c72-4d3a-81b8-e6d62a056467'
KEY_FILEPATH='/Users/jiangzheng/Project/mac/FlipPrinter/fastlane/AuthKey_29HD53FFYV.p8'
API_BASE='https://api.appstoreconnect.apple.com/v1'
with open(KEY_FILEPATH,'rb') as f: key=f.read()
now=int(time.time())
token=jwt.encode({'iss':ISSUER_ID,'iat':now,'exp':now+20*60,'aud':'appstoreconnect-v1'},key,algorithm='ES256',headers={'alg':'ES256','kid':KEY_ID,'typ':'JWT'})
H={'Authorization':f'Bearer {token}','Content-Type':'application/json'}
r=requests.get(f'{API_BASE}/appScreenshotSets/25a0dcc9-8dd2-4f81-bafb-2163ca4b2f1a/appScreenshots',headers=H)
for s in r.json().get('data',[]):
    sa = s.get('attributes', {})
    ads = sa.get('assetDeliveryState', {})
    print(f"{sa.get('fileName','?')}: checksum={sa.get('sourceFileChecksum','MISSING')}, delivery={ads.get('state','?')}, errors={ads.get('errors',[])}")
