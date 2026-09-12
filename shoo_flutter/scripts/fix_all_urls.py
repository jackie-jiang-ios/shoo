#!/usr/bin/env python3
import json, time, requests, jwt

def get_token():
    pk=open('./fastlane/AuthKey_29HD53FFYV.p8').read()
    t=int(time.time())
    tok=jwt.encode({'iss':'4b86ecb0-5c72-4d3a-81b8-e6d62a056467','iat':t,'exp':t+1200,'aud':'appstoreconnect-v1'},pk,algorithm='ES256',headers={'kid':'29HD53FFYV','typ':'JWT'})
    return {'Authorization':f'Bearer {tok}','Content-Type':'application/json'}

VERSION_ID='72ab6e5c-5665-4b2c-9d34-2e3a778625b6'
H=get_token()
r=requests.get(f'https://api.appstoreconnect.apple.com/v1/appStoreVersions/{VERSION_ID}/appStoreVersionLocalizations',headers=H)
locs=r.json().get('data',[])
print(f"Total: {len(locs)} locales")

count=0
for loc in locs:
    H=get_token()
    body={'data':{'type':'appStoreVersionLocalizations','id':loc['id'],'attributes':{
        'supportUrl':'https://liteapps.cn/shoo',
        'marketingUrl':'https://liteapps.cn/shoo'
    }}}
    r=requests.patch(f'https://api.appstoreconnect.apple.com/v1/appStoreVersionLocalizations/{loc["id"]}',headers=H,json=body)
    status='OK' if r.status_code==200 else f'FAIL {r.status_code}'
    print(f"  {loc['attributes']['locale']}: {status}")
    if r.status_code==200: count+=1

print(f"\nUpdated: {count}/{len(locs)}")
