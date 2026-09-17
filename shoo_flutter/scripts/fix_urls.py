#!/usr/bin/env python3
import json, time, requests, jwt, sys

def get_token():
    pk=open('./fastlane/AuthKey_29HD53FFYV.p8').read()
    t=int(time.time())
    tok=jwt.encode({'iss':'4b86ecb0-5c72-4d3a-81b8-e6d62a056467','iat':t,'exp':t+1200,'aud':'appstoreconnect-v1'},pk,algorithm='ES256',headers={'kid':'29HD53FFYV','typ':'JWT'})
    return {'Authorization':f'Bearer {tok}','Content-Type':'application/json'}

# 1. Fix version localization (pt-PT)
print("=== Fix pt-PT AppStoreVersionLocalization ===")
H=get_token()
LOC='293ed3b1-de9c-4f2a-ba7f-d8c817b0b3bf'
body = {
    'data': {
        'type': 'appStoreVersionLocalizations',
        'id': LOC,
        'attributes': {
            'supportUrl': 'https://liteapps.cn/shoo',
            'marketingUrl': 'https://liteapps.cn/shoo'
        }
    }
}
r=requests.patch(f'https://api.appstoreconnect.apple.com/v1/appStoreVersionLocalizations/{LOC}',headers=H,json=body)
print(f"  HTTP {r.status_code}")
if r.status_code==200: print("  OK")
else: print(json.dumps(r.json(),indent=2,ensure_ascii=False))

# 2. Also fix other locales that were written by the buggy scripts (just in case)
print("\n=== Checking all locales for wrong URLs...")
H=get_token()
r=requests.get('https://api.appstoreconnect.apple.com/v1/appStoreVersions/72ab6e5c-5665-4b2c-9d34-2e3a778625b6/appStoreVersionLocalizations',headers=H)
for loc in r.json().get('data',[]):
    attrs=loc['attributes']
    su=attrs.get('supportUrl') or ''
    mu=attrs.get('marketingUrl') or ''
    if 'shoo-app.com' in su or 'shoo-app.com' in mu:
        print(f"  !!! {attrs['locale']}: support={su}, marketing={mu}")
        body2={'data':{'type':'appStoreVersionLocalizations','id':loc['id'],'attributes':{
            'supportUrl':'https://liteapps.cn/shoo',
            'marketingUrl':'https://liteapps.cn/shoo'
        }}}
        r2=requests.patch(f'https://api.appstoreconnect.apple.com/v1/appStoreVersionLocalizations/{loc["id"]}',headers=get_token(),json=body2)
        print(f"         -> HTTP {r2.status_code}")
    elif su or mu:
        print(f"  OK {attrs['locale']}: {su}")
