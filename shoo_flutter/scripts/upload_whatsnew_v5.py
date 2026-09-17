#!/usr/bin/env python3
"""Upload v5.0.0 whatsNew to all 50 App Store Connect localizations.

Changes in v5.0.0:
- 新增葡萄牙语（葡萄牙）语言支持
- 移除 watchOS 平台支持
- 修复已知问题，提升稳定性
"""
import json, time, sys, requests, jwt
from deep_translator import GoogleTranslator

# API Config
KEY_ID = '29HD53FFYV'
ISSUER_ID = '4b86ecb0-5c72-4d3a-81b8-e6d62a056467'
KEY_PATH = './fastlane/AuthKey_29HD53FFYV.p8'
API_BASE = 'https://api.appstoreconnect.apple.com/v1'
VERSION_ID = 'f69f0fc0-7006-47e4-af84-cbe15e6ec75d'

def get_token():
    pk = open(KEY_PATH).read()
    t = int(time.time())
    tok = jwt.encode(
        {'iss': ISSUER_ID, 'iat': t, 'exp': t + 1200, 'aud': 'appstoreconnect-v1'},
        pk, algorithm='ES256', headers={'kid': KEY_ID, 'typ': 'JWT'}
    )
    return {'Authorization': f'Bearer {tok}', 'Content-Type': 'application/json'}

# Source text (Chinese)
SOURCE_TEXT = "新增葡萄牙语（葡萄牙）语言支持；移除 watchOS 平台支持；修复已知问题，提升稳定性。"

# Target language mapping for deep-translator (source -> target)
# Google Translate language codes
LANG_MAP = {
    'zh-Hans': ('zh-CN', 'zh-CN'),  # source
    'zh-Hant': ('zh-CN', 'zh-TW'),
    'en-US': ('zh-CN', 'en'),
    'en-CA': ('zh-CN', 'en'),
    'en-GB': ('zh-CN', 'en'),
    'en-AU': ('zh-CN', 'en'),
    'ja': ('zh-CN', 'ja'),
    'ko': ('zh-CN', 'ko'),
    'fr-FR': ('zh-CN', 'fr'),
    'fr-CA': ('zh-CN', 'fr'),
    'de-DE': ('zh-CN', 'de'),
    'es-ES': ('zh-CN', 'es'),
    'es-MX': ('zh-CN', 'es'),
    'it': ('zh-CN', 'it'),
    'pt-BR': ('zh-CN', 'pt'),
    'pt-PT': ('zh-CN', 'pt'),
    'ru': ('zh-CN', 'ru'),
    'ar-SA': ('zh-CN', 'ar'),
    'th': ('zh-CN', 'th'),
    'vi': ('zh-CN', 'vi'),
    'id': ('zh-CN', 'id'),
    'ms': ('zh-CN', 'ms'),
    'nl-NL': ('zh-CN', 'nl'),
    'pl': ('zh-CN', 'pl'),
    'tr': ('zh-CN', 'tr'),
    'cs': ('zh-CN', 'cs'),
    'sk': ('zh-CN', 'sk'),
    'hu': ('zh-CN', 'hu'),
    'ro': ('zh-CN', 'ro'),
    'hr': ('zh-CN', 'hr'),
    'ca': ('zh-CN', 'ca'),
    'fi': ('zh-CN', 'fi'),
    'sv': ('zh-CN', 'sv'),
    'da': ('zh-CN', 'da'),
    'no': ('zh-CN', 'no'),
    'el': ('zh-CN', 'el'),
    'he': ('zh-CN', 'he'),
    'uk': ('zh-CN', 'uk'),
    'hi': ('zh-CN', 'hi'),
    'bn-BD': ('zh-CN', 'bn'),
    'ta-IN': ('zh-CN', 'ta'),
    'te-IN': ('zh-CN', 'te'),
    'ml-IN': ('zh-CN', 'ml'),
    'kn-IN': ('zh-CN', 'kn'),
    'mr-IN': ('zh-CN', 'mr'),
    'gu-IN': ('zh-CN', 'gu'),
    'pa-IN': ('zh-CN', 'pa'),
    'ur-PK': ('zh-CN', 'ur'),
    'or-IN': ('zh-CN', 'or'),
    'sl-SI': ('zh-CN', 'sl'),
}

# Manual override for better quality (pre-translated)
MANUAL_TRANSLATIONS = {
    'zh-Hans': '新增葡萄牙语（葡萄牙）语言支持；移除 watchOS 平台支持；修复已知问题，提升稳定性。',
    'zh-Hant': '新增葡萄牙語（葡萄牙）語言支援；移除 watchOS 平台支援；修復已知問題，提升穩定性。',
    'en-US': 'Added Portuguese (Portugal) language support; removed watchOS platform support; fixed known issues for better stability.',
    'en-CA': 'Added Portuguese (Portugal) language support; removed watchOS platform support; fixed known issues for better stability.',
    'en-GB': 'Added Portuguese (Portugal) language support; removed watchOS platform support; fixed known issues for better stability.',
    'en-AU': 'Added Portuguese (Portugal) language support; removed watchOS platform support; fixed known issues for better stability.',
    'ja': 'ポルトガル語（ポルトガル）の言語サポートを追加；watchOSプラットフォームサポートを削除；既知の問題を修正し、安定性を向上させました。',
    'ko': '포르투갈어(포르투갈) 언어 지원 추가; watchOS 플랫폼 지원 제거; 알려진 문제를 수정하여 안정성을 향상시켰습니다。',
    'fr-FR': 'Ajout de la prise en charge du portugais (Portugal) ; suppression de la prise en charge de la plateforme watchOS ; correction de problèmes connus pour une meilleure stabilité.',
    'fr-CA': 'Ajout de la prise en charge du portugais (Portugal) ; suppression de la prise en charge de la plateforme watchOS ; correction de problèmes connus pour une meilleure stabilité.',
    'de-DE': 'Unterstützung für Portugiesisch (Portugal) hinzugefügt; watchOS-Plattformunterstützung entfernt; bekannte Probleme für bessere Stabilität behoben.',
    'es-ES': 'Se añadió soporte para portugués (Portugal); se eliminó el soporte para la plataforma watchOS; se corrigieron problemas conocidos para mejorar la estabilidad.',
    'es-MX': 'Se agregó soporte para portugués (Portugal); se eliminó el soporte para la plataforma watchOS; se corrigieron problemas conocidos para mejorar la estabilidad.',
    'it': 'Aggiunto il supporto per il portoghese (Portogallo); rimosso il supporto per la piattaforma watchOS; risolti problemi noti per una migliore stabilità.',
    'pt-BR': 'Adicionado suporte ao idioma português (Portugal); removido suporte à plataforma watchOS; correção de problemas conhecidos para melhor estabilidade.',
    'pt-PT': 'Adicionado suporte ao idioma português (Portugal); removido suporte à plataforma watchOS; correção de problemas conhecidos para melhor estabilidade.',
    'ru': 'Добавлена поддержка португальского языка (Португалия); удалена поддержка платформы watchOS; исправлены известные проблемы для повышения стабильности.',
    'ar-SA': 'تمت إضافة دعم اللغة البرتغالية (البرتغال)؛ تمت إزالة دعم نظام watchOS؛ إصلاح المشكلات المعروفة لتحسين الاستقرار.',
    'th': 'เพิ่มการรองรับภาษาโปรตุเกส (โปรตุเกส) ลบการรองรับแพลตฟอร์ม watchOS แก้ไขปัญหาที่ทราบแล้วเพื่อเสถียรภาพที่ดีขึ้น',
    'vi': 'Đã thêm hỗ trợ tiếng Bồ Đào Nha (Bồ Đào Nha); đã xóa hỗ trợ nền tảng watchOS; đã sửa các lỗi đã biết để cải thiện độ ổn định.',
    'id': 'Menambahkan dukungan bahasa Portugis (Portugal); menghapus dukungan platform watchOS; memperbaiki masalah yang diketahui untuk stabilitas yang lebih baik.',
    'ms': 'Menambah sokongan bahasa Portugis (Portugal); mengalih keluar sokongan platform watchOS; membaiki masalah yang diketuhkan untuk kestabilan yang lebih baik.',
    'nl-NL': 'Ondersteuning voor Portugees (Portugal) toegevoegd; ondersteuning voor het watchOS-platform verwijderd; bekende problemen opgelost voor betere stabiliteit.',
    'pl': 'Dodano obsługę języka portugalskiego (Portugal); usunięto obsługę platformy watchOS; naprawiono znane problemy w celu poprawy stabilności.',
    'tr': 'Portekizce (Portekiz) dil desteği eklendi; watchOS platform desteği kaldırıldı; daha iyi kararlılık için bilinen sorunlar düzeltildi.',
    'cs': 'Přidána podpora jazyka portugalština (Portugalsko); odstraněna podpora platformy watchOS; opraveny známé problemy pro lepší stabilitu.',
    'sk': 'Pridaná podpora jazyka portugalčina (Portugalsko); odstránená podpora platformy watchOS; opravené známe problemy pre lepšiu stabilitu.',
    'hu': 'Portugál (Portugália) nyelvi támogatás hozzáadva; watchOS platform támogatása eltávolítva; ismert problémák javítva a jobb stabilitás érdekében.',
    'ro': 'A fost adăugat suportul pentru limba portugheză (Portugalia); a fost eliminat suportul pentru platforma watchOS; probleme cunoscute rezolvate pentru o stabilitate mai bună.',
    'hr': 'Dodana podrška za portugalski jezik (Portugal); uklonjena podrška za watchOS platformu; popravljeni poznati problemi za bolju stabilnost.',
    'ca': 'S\'ha afegit suport per al portuguès (Portugal); s\'ha eliminat el suport per a la plataforma watchOS; s\'ha corregit problemes coneguts per millorar l\'estabilitat.',
    'fi': 'Lisätty portugalin (Portugali) kielituki; watchOS-alustan tuki poistettu; korjattu tunnetut ongelmat paremman vakauden vuoksi.',
    'sv': 'Lagt till stöd för portugisiska (Portugal); tagit bort stöd för watchOS-plattformen; åtgärdade kända problem för bättre stabilitet.',
    'da': 'Tilføjet understøttelse af portugisisk (Portugal); fjernet understøttelse af watchOS-platform; rettede kendte problemer for bedre stabilitet.',
    'no': 'Lagt til støtte for portugisisk (Portugal); fjernet støtte for watchOS-plattformen; rettet kjente problemer for bedre stabilitet.',
    'el': 'Προστέθηκε υποστήριξη γλώσσας Πορτογαλικά (Πορτογαλία); αφαιρέθηκε η υποστήριξη της πλατφόρμας watchOS; διορθώθηκαν γνωστά προβλήματα για καλύτερη σταθερότητα.',
    'he': 'נוסף תמיכה בשפה הפורטוגזית (פורטוגל); הוסרה תמיכה בפלטפורמת watchOS; תוקנו בעיות ידועות ליציבות משופרת.',
    'uk': 'Додано підтримку португальської мови (Португалія); видалено підтримку платформи watchOS; виправлені відомі проблеми для підвищення стабільності.',
    'hi': 'पुर्तगाली (पुर्तगाल) भाषा समर्थन जोड़ा गया; watchOS प्लेटफ़ॉर्म समर्थन हटाया गया; बेहतर स्थिरता के लिए ज्ञात समस्याओं को ठीक किया गया।',
    'bn-BD': 'পর্তুগিজ (পর্তুগাল) ভাষা সমর্থন যোগ করা হয়েছে; watchOS প্ল্যাটফর্ম সমর্থন সরানো হয়েছে; আরও ভালো স্থিতিশীলতার জন্য পরিচিত সমস্যাগুলি সমাধান করা হয়েছে।',
    'ta-IN': 'போர்த்துகீசிய (போர்த்துகல்) மொழி ஆதரவு சேர்க்கப்பட்டது; watchOS தள ஆதரவு அகற்றப்பட்டது; சிறந்த நிலைத்தன்மைக்கு அறியப்பட்ட சிக்கல்கள் தீர்க்கப்பட்டன.',
    'te-IN': 'పోర్చుగీస్ (పోర్చుగల్) భాష మద్దతు జోడించబడింది; watchOS ప్లాట్‌ఫారమ్ మద్దతు తొలగించబడింది; మెరుగైన స్థిరత్వం కోసం తెలిసిన సమస్యలు పరిష్కరించబడ్డాయి.',
    'ml-IN': 'പോർച്ചുഗീസ് (പോർച്ചുഗൽ) ഭാഷാ പിന്തുണ ചേർത്തു; watchOS പ്ലാറ്റ്‌ഫോം പിന്തുണ നീക്കം ചെയ്തു; മികച്ച സ്ഥിരതയ്ക്കായി അറിയപ്പെട്ട പ്രശ്നങ്ങൾ പരിഹരിച്ചു.',
    'kn-IN': 'ಪೋರ್ಚುಗೀಸ್ (ಪೋರ್ಚುಗಲ್) ಭಾಷೆ ಬೆಂಬಲ ಸೇರಿಸಲಾಗಿದೆ; watchOS ವೇದಿಕೆ ಬೆಂಬಲ ತೆಗೆದುಹಾಕಲಾಗಿದೆ; ಉತ್ತಮ ಸ್ಥಿರತೆಗಾಗಿ ತಿಳಿದ ಸಮಸ್ಯೆಗಳನ್ನು ಸರಿಪಡಿಸಲಾಗಿದೆ.',
    'mr-IN': 'पोर्तुगीज (पोर्तुगाल) भाषा समर्थन जोडले; watchOS प्लॅटफॉर्म समर्थन काढले; चांगल्या स्थिरतेसाठी ज्ञात समस्या दूर केल्या.',
    'gu-IN': 'પોર્ટુગીઝ (પોર્ટુગલ) ભાષા સપોર્ટ ઉમેર્યો; watchOS પ્લેટફોર્મ સપોર્ટ દૂર કર્યો; વધુ સારા સ્થિરતા માટે જાણીતી સમસ્યાઓ ઠીક કરી.',
    'pa-IN': 'ਪੁਰਤਗਾਲੀ (ਪੁਰਤਗਾਲ) ਭਾਸ਼ਾ ਸਮਰਥਨ ਸ਼ਾਮਲ ਕੀਤਾ; watchOS ਪਲੇਟਫਾਰਮ ਸਮਰਥਨ ਹਟਾ ਦਿੱਤਾ; ਬਿਹਤਰ ਸਥਿਰਤਾ ਲਈ ਜਾਣੀਆਂ ਸਮਸਿਆਵਾਂ ਠੀਕ ਕੀਤੀਆਂ।',
    'ur-PK': 'پرتگالی (پرتگال) زبان کا سپورٹ شامل کیا گیا؛ watchOS پلیٹ فارم کا سپورٹ ہٹا دیا گیا؛ بہتر استحار کے لیے معلوم ہوئے مسائل کو درست کر دیا گیا۔',
    'or-IN': 'ପର୍ତ୍ତୁଗୀଜ୍ (ପର୍ତ୍ତୁଗାଲ୍) ଭାଷା ସମର୍ଥନ ଯୋଡ଼ା ହୋଇଛି; watchOS ପ୍ଲାଟଫର୍ମ ସମର୍ଥନ ଅପସାରଣ କରାଯାଇଛି; ଉନ୍ନତ ସ୍ଥିରତା ପାଇଁ ଜଣାଶୁଣା ସମସ୍ୟାଗୁଡ଼ିକୁ ସମାଧାନ କରାଯାଇଛି।',
    'sl-SI': 'Dodana podpora za portugalščino (Portugalska); odstranjena podpora za platformo watchOS; odpravljane znane težave za boljšo stabilnost.',
}

def translate_text(text, target_lang):
    """Translate text using deep-translator as fallback."""
    try:
        translator = GoogleTranslator(source='zh-CN', target=target_lang)
        result = translator.translate(text)
        return result
    except Exception as e:
        print(f"    Translation error: {e}")
        return None

def main():
    # Step 1: Get all localizations
    print("=== Step 1: 获取所有 localization ===")
    H = get_token()
    r = requests.get(f'{API_BASE}/appStoreVersions/{VERSION_ID}/appStoreVersionLocalizations', headers=H)
    locs = r.json().get('data', [])
    print(f"  Found {len(locs)} locales")

    # Step 2: Upload whatsNew for each locale
    print("\n=== Step 2: 上传 whatsNew ===")
    success = 0
    skip = 0
    fail = 0

    for loc in locs:
        locale = loc['attributes']['locale']
        loc_id = loc['id']

        # Get translated text (use manual translation first)
        if locale in MANUAL_TRANSLATIONS:
            whats_new = MANUAL_TRANSLATIONS[locale]
        elif locale in LANG_MAP:
            _, target_code = LANG_MAP[locale]
            whats_new = translate_text(SOURCE_TEXT, target_code)
            if not whats_new:
                print(f"  {locale}: SKIP (translation failed)")
                skip += 1
                continue
        else:
            print(f"  {locale}: SKIP (no mapping)")
            skip += 1
            continue

        # Upload via API
        H = get_token()
        body = {
            'data': {
                'type': 'appStoreVersionLocalizations',
                'id': loc_id,
                'attributes': {
                    'whatsNew': whats_new
                }
            }
        }
        r = requests.patch(f'{API_BASE}/appStoreVersionLocalizations/{loc_id}', headers=H, json=body)

        if r.status_code == 200:
            success += 1
            print(f"  {locale}: OK")
        else:
            fail += 1
            print(f"  {locale}: FAIL {r.status_code} - {r.text[:100]}")

    print(f"\n=== 结果 ===")
    print(f"  成功: {success}/{len(locs)}")
    print(f"  跳过: {skip}")
    print(f"  失败: {fail}")

if __name__ == '__main__':
    main()
