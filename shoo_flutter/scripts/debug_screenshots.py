#!/usr/bin/env python3
import jwt, time, requests, json
KEY_ID='29HD53FFYV'
ISSUER_ID='4b86ecb0-5c72-4d3a-81b8-e6d62a056467'
KEY_FILEPATH='/Users/jiangzheng/Project/mac/FlipPrinter/fastlane/AuthKey_29HD53FFYV.p8'
BUNDLE_ID='com.yangshiqin.shoo'
API_BASE='https://api.appstoreconnect.apple.com/v1'
with open(KEY_FILEPATH,'rb') as f: key=f.read()
now=int(time.time())
token=jwt.encode({'iss':ISSUER_ID,'iat':now,'exp':now+20*60,'aud':'appstoreconnect-v1'},key,algorithm='ES256',headers={'alg':'ES256','kid':KEY_ID,'typ':'JWT'})
H={'Authorization':f'Bearer {token}','Content-Type':'application/json'}

r=requests.get(f'{API_BASE}/apps?filter[bundleId]={BUNDLE_ID}&fields[apps]=name',headers=H)
app_id=r.json()['data'][0]['id']

# Check all IOS versions for screenshots
r=requests.get(f'{API_BASE}/apps/{app_id}/appStoreVersions?fields[appStoreVersions]=versionString,platform,appStoreState',headers=H)
ios_versions = [v for v in r.json()['data'] if v['attributes'].get('platform')=='IOS']

for v in ios_versions:
    vid = v['id']
    vs = v['attributes']['versionString']
    state = v['attributes']['appStoreState']
    print(f"\n=== Version {vs} ({state}) ===")
    
    # Get localizations
    r=requests.get(f'{API_BASE}/appStoreVersions/{vid}/appStoreVersionLocalizations',headers=H)
    locs={l['attributes']['locale']:l['id'] for l in r.json()['data']}
    
    # Check first 3 localizations with most likely screenshots
    for locale in ['zh-Hans', 'en-US', 'ja']:
        lid = locs.get(locale)
        if not lid:
            continue
        print(f"\n  [{locale}]")
        
        # Get screenshot sets
        r=requests.get(f'{API_BASE}/appStoreVersionLocalizations/{lid}/appScreenshotSets?fields[appScreenshotSets]=screenshotDisplayType',headers=H)
        ss_data = r.json()
        print(f"    Screenshot sets: {json.dumps(ss_data, indent=2)[:500]}")
        
        for ss in ss_data.get('data',[]):
            ss_id = ss['id']
            r2=requests.get(f'{API_BASE}/appScreenshotSets/{ss_id}/appScreenshots',headers=H)
            ss_json = r2.json()
            print(f"    Set {ss_id}: {len(ss_json.get('data',[]))} screenshots")
            if ss_json.get('data'):
                for s in ss_json['data']:
                    print(f"      - {s['id']}: {s['attributes'].get('fileName','?')}")
