#!/usr/bin/env python3
import json, time, requests, jwt

def get_token():
    pk=open('./fastlane/AuthKey_29HD53FFYV.p8').read()
    t=int(time.time())
    tok=jwt.encode({'iss':'4b86ecb0-5c72-4d3a-81b8-e6d62a056467','iat':t,'exp':t+1200,'aud':'appstoreconnect-v1'},pk,algorithm='ES256',headers={'kid':'29HD53FFYV','typ':'JWT'})
    return {'Authorization':f'Bearer {tok}','Content-Type':'application/json'}

H=get_token()

# Check one set in detail
for set_id in ['007bc6b3-f114-4eca-8017-44b3b7dc59e4', '0db96ced-6a74-494f-af34-41442478bbbf', 'e1d6d3f9-f723-4913-880d-5283efa5c6a1']:
    r=requests.get(f'https://api.appstoreconnect.apple.com/v1/appScreenshotSets/{set_id}/appScreenshots',headers=H)
    print(f'\n=== Set {set_id[:8]}... ===')
    data = r.json().get('data', [])
    if not data:
        print('  (empty)')
    for ss in data:
        print(json.dumps(ss, indent=2, ensure_ascii=False))
