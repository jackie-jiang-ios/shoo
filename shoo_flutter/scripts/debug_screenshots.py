#!/usr/bin/env python3
import json, time, requests, jwt

def get_token():
    pk=open('./fastlane/AuthKey_29HD53FFYV.p8').read()
    t=int(time.time())
    tok=jwt.encode({'iss':'4b86ecb0-5c72-4d3a-81b8-e6d62a056467','iat':t,'exp':t+1200,'aud':'appstoreconnect-v1'},pk,algorithm='ES256',headers={'kid':'29HD53FFYV','typ':'JWT'})
    return {'Authorization':f'Bearer {tok}','Content-Type':'application/json'}

H=get_token()
LOC='293ed3b1-de9c-4f2a-ba7f-d8c817b0b3bf'
r=requests.get(f'https://api.appstoreconnect.apple.com/v1/appStoreVersionLocalizations/{LOC}/appScreenshotSets',headers=H)
print(json.dumps(r.json(), indent=2, ensure_ascii=False))
