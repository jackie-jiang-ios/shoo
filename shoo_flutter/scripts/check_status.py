import jwt, time, requests, json

KEY_ID='29HD53FFYV'
ISSUER_ID='4b86ecb0-5c72-4d3a-81b8-e6d62a056467'
KEY_FILEPATH='/Users/jiangzheng/Project/mac/FlipPrinter/fastlane/AuthKey_29HD53FFYV.p8'
BUNDLE_ID='com.yangshiqin.FlipPrinter'
API_BASE='https://api.appstoreconnect.apple.com/v1'

with open(KEY_FILEPATH,'rb') as f:
    key=f.read()
now=int(time.time())
token=jwt.encode({'iss':ISSUER_ID,'iat':now,'exp':now+20*60,'aud':'appstoreconnect-v1'},key,algorithm='ES256',headers={'alg':'ES256','kid':KEY_ID,'typ':'JWT'})
H={'Authorization':f'Bearer {token}','Content-Type':'application/json'}

r=requests.get(f'{API_BASE}/apps?filter[bundleId]={BUNDLE_ID}&fields[apps]=name',headers=H)
app_id=r.json()['data'][0]['id']

r=requests.get(f'{API_BASE}/apps/{app_id}/appStoreVersions?filter[appStoreState]=PREPARE_FOR_SUBMISSION&fields[appStoreVersions]=versionString,platform',headers=H)
versions=[v for v in r.json()['data'] if v['attributes'].get('platform')=='IOS']
vid=versions[0]['id']

r=requests.get(f'{API_BASE}/appStoreVersions/{vid}/appStoreVersionLocalizations',headers=H)
locs={l['attributes']['locale']:l['id'] for l in r.json()['data']}

LANGS=['ar-SA','de-DE','es-ES','fr-FR','id','it','ko','ms','nl-NL','pl','pt-BR','ru','th','tr','vi','zh-Hans','en-US','ja']

print(f"{'语言':<10} {'截图数':<8} {'预览视频':<10} {'视频状态'}")
print("-"*50)
for lang in LANGS:
    lid=locs.get(lang)
    if not lid:
        print(f"{lang:<10} 无本地化")
        continue
    
    # Check screenshots
    r=requests.get(f'{API_BASE}/appStoreVersionLocalizations/{lid}/appScreenshotSets?fields[appScreenshotSets]=screenshotDisplayType',headers=H)
    ss_count=0
    for ss in r.json().get('data',[]):
        r2=requests.get(f'{API_BASE}/appScreenshotSets/{ss["id"]}/appScreenshots',headers=H)
        ss_count+=len(r2.json().get('data',[]))
    
    # Check previews
    r=requests.get(f'{API_BASE}/appStoreVersionLocalizations/{lid}/appPreviewSets?fields[appPreviewSets]=previewType',headers=H)
    preview_status="无"
    for ps in r.json().get('data',[]):
        r2=requests.get(f'{API_BASE}/appPreviewSets/{ps["id"]}/appPreviews',headers=H)
        for p in r2.json().get('data',[]):
            st=p.get('attributes',{}).get('videoDeliveryState',{}).get('state','?')
            preview_status=st
    
    print(f"{lang:<10} {ss_count:<8} {'有' if preview_status!='无' else '无':<10} {preview_status}")
