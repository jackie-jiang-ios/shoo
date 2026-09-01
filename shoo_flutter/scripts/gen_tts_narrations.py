#!/usr/bin/env python3
# gen_tts_narrations.py - 为每种语言生成 TTS 旁白音频
# 用法: python3 scripts/gen_tts_narrations.py
import subprocess, os, sys

BASE = os.path.join(os.path.dirname(__file__), "..", "fastlane", "screenshots")
TTS_SCRIPT = os.path.expanduser("~/.catpaw/skills/ttsapi/scripts/tts.mjs")

LANGS = [
  ("zh-Hans", "zh-CN-XiaoxiaoNeural", "遇到野兽不要慌。Shoo防兽神器，你的口袋驱兽专家。内置虎啸、狮吼、鹰啸、枪声等十余种驱赶声音，覆盖六大动物分类。智能推荐最有效声音，支持多声音混合播放，还可连接手表远程控制。户外出行，野外露营，一键驱兽，守护安全。"),
  ("zh-Hant", "zh-CN-XiaoxiaoNeural", "遇到野獸不要慌。Shoo防獸神器，你的口袋驅獸專家。內建虎虎嘯、獅吼、鷹嘯、槍聲等十餘種驅趕聲音，覆蓋六大動物分類。智能推薦最有效聲音，支持多聲音混合播放，還可連接手錶遠程控制。戶外出行，野外露營，一鍵驅獸，守護安全。"),
  ("en-US", "en-US-AriaNeural", "Wild dogs? Snakes? Monkeys? Shoo is your pocket deterrent. Tiger roar, lion growl, eagle cry, gunshot and more. Over ten sounds across six animal categories. Smart recommendations, sound mixing, watch remote control. One tap to scare them away. Stay safe outdoors!"),
  ("ja", "ja-JP-NanamiNeural", "野生動物に出ても大丈夫。Shooは虎の咆哮、ライオンの唸り声、鷹の鳴き声、銃声など10種類以上の忌避音を内蔵。6つの動物カテゴリーに対応。スマート推薦、サウンドミックス、スマートウォッチ連携。ワンタップで追い払おう。アウトドアで安全を守ろう。"),
  ("ko", "ko-KR-SunHiNeural", "야생동물을 만나도 걱정 없습니다. Shoo는 호랑이 포효, 사자 울음, 독수리 울음, 총소리 등 10여 종의 퇴치 소리를 내장했습니다. 6대 동물 분류 지원. 스마트 추천, 소리 믹스, 스마트워치 원격 제어. 원터치로 쫓아내세요. 아웃도어에서 안전을 지키세요!"),
  ("fr-FR", "fr-FR-DeniseNeural", "Chiens sauvages? Serpents? Singes? Shoo est votre répulsif de poche. Rugissement de tigre, grognement de lion, cri d'aigle, coup de feu et plus encore. Plus de dix sons dans six catégories. Recommandations intelligentes, mixage sonore, télécommande montre. Un touch pour les effrayer. Restez en sécurité!"),
  ("de-DE", "de-DE-KatjaNeural", "Wilde Hunde? Schlangen? Affen? Shoo ist Ihr Taschen-Abwehrgerät. Tigerbrüllen, Löwengeknurr, Adlerschrei, Schüsse und mehr. Über zehn Klänge in sechs Kategorien. Intelligente Empfehlungen, Sound-Mixing, Uhr-Fernbedienung. Ein Tipp zum Vertreiben. Bleiben Sie sicher!"),
  ("es-ES", "es-ES-ElviraNeural", "Perros salvajes? Serpientes? Monos? Shoo es tu repelente de bolsillo. Rugido de tigre, gruñido de león, grito de águila, disparo y más. Más de diez sonidos en seis categorías. Recomendaciones inteligentes, mezcla de sonidos, control remoto del reloj. Un toque para ahuyentarlos. Mantente seguro!"),
  ("ru", "ru-RU-SvetlanaNeural", "Дикие собаки? Змеи? Обезьяны? Shoo — ваш карманный отпугиватель. Рык тигра, рычание льва, крик орла, выстрел и более десяти звуков. Шесть категорий животных. Умные рекомендации, микширование, управление с часов. Одно касание — и они убегут. Будьте в безопасности!"),
  ("pt-BR", "pt-BR-FranciscaNeural", "Cães selvagens? Cobras? Macacos? Shoo é seu repelente de bolso. Rugido de tigre, rosnado de leão, grito de águia, tiro e mais. Mais de dez sons em seis categorias. Recomendações inteligentes, mixagem de som, controle remoto do relógio. Um toque para espantar. Mantenha-se seguro!"),
  ("th", "th-TH-PremwadeeNeural", "หมาป่า? งู? ลิง? Shoo คือเครื่องไล่สัตว์ในกระเป๋าของคุณ เสียงเสือคำราม เสียงสิงห์คำราม เสียงเหยี่ยว เสียงปืน และอีกกว่า 10 เสียง 6 หมวดสัตว์ แนะนำอัจฉริยะ ผสมเสียง ควบคุมจากนาฬิกา แตะเดียวไล่ทันที ปลอดภัยทุกที่!"),
  # v3.0 新增8种语言
  ("ar-SA", "ar-SA-MagedNeural", "كلاب برية؟ أفاعٍ؟ قرود؟ Shoo هو طاردك الجيبي. زئير النمر، زمجرة الأسد، صراخ النسر، طلقات نارية والمزيد. أكثر من عشرة أصوات في ست فئات حيوانية. توصيات ذكية، مزج الأصوات، تحكم بالساعة. لمسة واحدة لإخافتها. ابقَ آمناً في الخارج!"),
  ("id", "id-ID-GadisNeural", "Anjing liar? Ular? Monyet? Shoo adalah pengusir saku Anda. Auman harimau, geraman singa, jeritan elang, tembakan dan lainnya. Lebih dari sepuluh suara dalam enam kategori. Rekomendasi cerdas, mix suara, kontrol jam. Satu ketuk untuk menakuti. Tetap aman di luar!"),
  ("it", "it-IT-ElsaNeural", "Cani selvatici? Serpenti? Scimmie? Shoo è il tuo repellente tascabile. Ruggito di tigre, ringhio di leone, strida di aquila, spari e altro. Più di dieci suoni in sei categorie. Suggerimenti intelligenti, mix suoni, controllo orologio. Un tocco per spaventarli. Resta al sicuro!"),
  ("ms", "ms-MY-YasminNeural", "Anjing liar? Ular? Monyet? Shoo ialah pengusir saku anda. Auman harimau, geraman singa, jeritan helang, tembakan dan lain-lain. Lebih dari sepuluh bunyi dalam enam kategori. Cadangan pintar, campur bunyi, kawalan jam. Satu ketik untuk menakutkan. Kekal selamat di luar!"),
  ("nl-NL", "nl-NL-ColetteNeural", "Wilde honden? Slangen? Apen? Shoo is jouw zakelijke verjager. Tijgergebrul, leeuwgegrom, arendsschreeuw, geweerschoten en meer. Meer dan tien geluiden in zes categorieën. Slimme aanbevelingen, geluid mixen, horloge bediening. One tap om ze te verjagen. Blijf veilig buiten!"),
  ("pl", "pl-PL-ZofiaNeural", "Dzikie psy? Węże? Małpy? Shoo to Twój kieszonkowy odstraszacz. Ryk tygrysa, warczenie lwa, krzyk orła, strzały i więcej. Ponad dziesięć dźwięków w sześciu kategoriach. Inteligentne rekomendacje, miks dźwięków, sterowanie zegarkiem. Jedno dotknięcie, by je odstraszyć. Bądź bezpieczny na zewnątrz!"),
  ("tr", "tr-TR-EmelNeural", "Vahşi köpekler? Yılanlar? Maymunlar? Shoo cepteki kovucunuz. Kaplan kükremesi, aslan homurtusu, kartal çığlığı, silah sesleri ve daha fazlası. Altı kategoride ondan fazla ses. Akıllı öneriler, ses karıştırma, saat kontrolü. Tek dokunuşla korkutun. Dışarıda güvende kalın!"),
  ("vi", "vi-VN-HoaiMyNeural", "Chó hoang? Rắn? Khỉ? Shoo là thiết bị xua đuổi bỏ túi của bạn. Tiếng hổ gầm, sư tử gầm, đại bàng kêu, súng nổ và hơn thế nữa. Hơn mười âm thanh trong sáu danh mục. Gợi ý thông minh, trộn âm thanh, điều khiển đồng hồ. Một chạm để dọa chúng. An toàn ngoài trời!"),
  # v3.1 新增30种语言
  ("hi", "hi-IN-SwaraNeural", "जंगली कुत्ते? सांप? बंदर? Shoo आपकी जेब का उपकरण है। बाघ की दहाड़, शेर की गरजन, चील की चीख, गोली की आवाज़ और भी। छह श्रेणियों में दस से अधिक ध्वनि। स्मार्ट सुझाव, ध्वनि मिश्रण, घड़ी नियंत्रण। एक स्पर्श से भगाएं। बाहर सुरक्षित रहें!"),
  ("da", "da-DK-ChristelNeural", "Vilde hunde? Slanger? Aber? Shoo er din lommeforjager. Tigerbrøl, løveknurren, ørneskrig, skud og mere. Over ti lyde i seks kategorier. Smarte anbefalinger, lydmix, ur-kontrol. Et tryk for at skræmme dem. Bliv sikker udendørs!"),
  ("fr-CA", "fr-CA-SylvieNeural", "Chiens sauvages? Serpents? Singes? Shoo est votre répulsif de poche. Rugissement de tigre, grognement de lion, cri d'aigle, coup de feu et plus. Plus de dix sons dans six catégories. Recommandations intelligentes, mixage sonore, télécommande montre. Un toucher pour les effrayer. Restez en sécurité!"),
  ("fi", "fi-FI-NooraNeural", "Villiä koiria? Käärmeitä? Apinoita? Shoo on taskukarkottimesi. Tiikerin karjunta, leijonan murina, kotkan huuto, laukaus ja enemmän. Yli kymmenen ääntä kuudessa kategoriassa. Älykkäät suositukset, äänimixaus, kello-kauko-ohjaus. Yksi kosketus karkottamaan. Pysy turvassa ulkona!"),
  ("gu", "gu-IN-DhwaniNeural", "જંગલી કૂતરાઓ? સાપ? વાંદર? Shoo તમારું પોકેટ ઉપકરણ છે. વાઘની ગર્જના, સિંહની ગર્જના, ઈગલની ચીસ, ગોળીનો અવાજ અને વધુ. છ કેટેગરીમાં દસથી વધુ અવાજ. સ્માર્ટ સૂચન, અવાજ મિક્સ, ઘડિયાળ નિયંત્રણ. એક સ્પર્શથી ભગાડો. બહાર સુરક્ષિત રહો!"),
  ("ca", "ca-ES-JoanaNeural", "Gossos salvatges? Serps? Micos? Shoo és el teu repel·lent de butxaca. Rugit de tigre, grunyit de lleó, xiscle d'àliga, tret i més. Més de deu sons en sis categories. Recomanacions intel·ligents, mixat de so, control del rellotge. Un toc per espantar-los. Estigues segur a l'exterior!"),
  ("cs", "cs-CZ-VlastaNeural", "Divokí psi? Had? Opice? Shoo je vaše kapesní odstrašovač. Tygří řev, lví vrčení, výskrek orla, výstřel a více. Více než deset zvuků v šesti kategoriích. Chytrá doporučení, mix zvuků, ovládání hodinek. Jedno dotynutí pro odstrašení. Buďte v bezpečí venku!"),
  ("kn", "kn-IN-SapnaNeural", "ಕಾಡು ನಾಯಿಗಳು? ಹಾವುಗಳು? ಕೋತಿಗಳು? Shoo ನಿಮ್ಮ ಖುಟ್ಟಿನ ಉಪಕರಣ. ಹುಲಿ ಗರ್ಜನೆ, ಸಿಂಹ ಗರ್ಜನೆ, ಗರುಡ ಕೂಗು, ಗುಂಡಿನ ಸದ್ದು ಮತ್ತು ಹೆಚ್ಚು. ಆರು ವರ್ಗಗಳಲ್ಲಿ ಹತ್ತಕ್ಕಿಂತ ಹೆಚ್ಚು ಧ್ವನಿಗಳು. ಸ್ಮಾರ್ಟ್ ಸಲಹೆ, ಧ್ವನಿ ಮಿಕ್ಸ್, ಕೈಗಡಿಯಾಳ ನಿಯಂತ್ರಣ. ಒಂದು ಸ್ಪರ್ಶದಿಂದ ಓಡಿಸಿ. ಹೊರಗೆ ಸುರಕ್ಷಿತವಾಗಿರಿ!"),
  ("hr", "hr-HR-GabrijelaNeural", "Divlji psi? Zmije? Majmuni? Shoo je vaš džepni odvraćivač. Tigrov url, lavovo režanje, krik orla, pucanj i više. Više od deset zvukova u šest kategorija. Pametne preporuke, mix zvukova, kontrola sata. Jedan dodir za zastrašivanje. Budite sigurni vani!"),
  ("ro", "ro-RO-AlinaNeural", "Câini sălbatici? Șerpi? Maimuțe? Shoo este repelentul tău de buzunar. Răget de tigru, mârâit de leu, țipăt de vultur, împușcături și mai mult. Peste zece sunete în șase categorii. Recomandări inteligente, mixare sunet, control ceas. O atingere pentru a speria. Rămâi în siguranță!"),
  ("mr", "mr-IN-AarohiNeural", "जंगली कुत्री? साप? वानर? Shoo तुमचे खिशातले उपकरण आहे. वाघाची गर्जना, सिंहाची गर्जना, गरुडाची चीत्कार, गोळीचा आवाज आणि अधिक. सहा वर्गांमध्ये दहापेक्षा जास्त आवाज. स्मार्ट सुजाव, आवाज मिक्स, घड्याळ नियंत्रण. एक स्पर्शाने घालवा. बाहेर सुरक्षित रहा!"),
  ("ml", "ml-IN-MidhunaNeural", "കാട്ടുനായ്കൾ? പാമ്പുകൾ? കുരങ്ങുകൾ? Shoo നിങ്ങളുടെ പോക്കറ്റ് ഉപകരണം. കടുവ കർഷണം, സിംഹ ഗർജ്ജനം, പരുന്ത് ചിലയ്ക്കൽ, വെടിയും കൂടുതൽ. ആറ് വിഭാഗങ്ങളിൽ പത്തിലധികം ശബ്ദങ്ങൾ. സ്മാർട്ട് നിർദ്ദേശം, ശബ്ദ മിക്സ്, ഘടിയാൽ നിയന്ത്രണം. ഒരു സ്പർശന മാറ്റി. പുറത്ത് സുരക്ഷിതം!"),
  ("bn", "bn-IN-TanishaaNeural", "বন্য কুকুর? সাপ? বানর? Shoo আপনার পকেট ডিভাইস। বাঘের গর্জন, সিংহের গর্জন, ঈগলের চিৎকার, বন্দুকের শব্দ এবং আরও। ছয় বিভাগে দশটির বেশি শব্দ। স্মার্ট পরামর্শ, শব্দ মিক্স, ঘড়ি নিয়ন্ত্রণ। এক স্পর্শে তাড়িয়ে দিন। বাইরে নিরাপদ থাকুন!"),
  ("no", "nb-NO-IselinNeural", "Ville hunder? Slanger? aper? Shoo er din lommeforjager. Tigerbrøl, løveknurring, ørneskrik, skudd og mer. Over ti lyder i seks kategorier. Smarte anbefalinger, lydmiks, klokkekontroll. Et trykk for å skremme dem. Vær trygg utendørs!"),
  ("pa", "pa-IN-NoorNeural", "ਜੰਗਲੀ ਕੁੱਤੇ? ਸੱਪ? ਬਾਂਦਰ? Shoo ਤੁਹਾਡਾ ਜੇਬ ਉਪਕਰਣ ਹੈ। ਬਾਘ ਦੀ ਗਰਜ, ਸ਼ੇਰ ਦੀ ਗਰਜ, ਗਰੁੱਧ ਦੀ ਚੀਂਕ, ਗੋਲੀ ਦੀ ਆਵਾਜ਼ ਅਤੇ ਹੋਰ। ਛੇ ਵਰਗਾਂ ਵਿੱਚ ਦਸ ਤੋਂ ਵੱਧ ਧੁਨੀਆਂ। ਸਮਾਰਟ ਸੁਝਾਅ, ਧੁਨੀ ਮਿਕਸ, ਘੜੀ ਕੰਟਰੋਲ। ਇੱਕ ਛੋਹ ਨਾਲ ਭਜਾਓ। ਬਾਹਰ ਸੁਰੱਖਿਅਤ ਰਹੋ!"),
  ("sv", "sv-SE-SofieNeural", "Vilda hundar? Ormar? Apor? Shoo är din fickförrjagare. Tigerbröl, lejontjejud, örnsskrin, skott och mer. Över tio ljud i sex kategorier. Smarta rekommendationer, ljudmix, klock-kontroll. En tryckning för att skrämma dem. Var säker utomhus!"),
  ("sk", "sk-SK-ViktoriaNeural", "Divé psy? Hady? Opice? Shoo je váš vreckový odstrašovač. Tigrí rev, lvie vrčanie, orlí výkrik, výstrel a viac. Viac ako desať zvukov v šiestich kategóriách. Inteligentné odporúčania, mix zvukov, ovládanie hodiniek. Jeden dotyk na odstrašenie. Buďte v bezpečí vonku!"),
  ("sl", "sl-SI-PetraNeural", "Divji psi? Kače? Opice? Shoo je vaš žepni odganjalec. Tigrji rženje, levje renčanje, krik orla, strel in več. Več kot deset zvokov v šestih kategorijah. Pametna priporočila, mix zvokov, nadzor ure. En dotik za prestrašenje. Bodite varni zunaj!"),
  ("te", "te-IN-ShrutiNeural", "అడవి కుక్కలు? పాములు? కోతులు? Shoo మీ జేబి పరికరం. పులి గర్జన, సింహం గర్జన, గరుడ అరుపు, తుపాకి చప్పుడు మరియు మరిన్ని. ఆరు వర్గాలలో పదికి పైగా శబ్దాలు. స్మార్ట్ సూచన, శబ్ద మిక్స్, గడియార నియంత్రణ. ఒక తాకిడితో తరిమివేయండి. బయట సురక్షితంగా ఉండండి!"),
  ("ta", "ta-IN-PallaviNeural", "காட்டு நாய்கள்? பாம்புகள்? குரங்குகள்? Shoo உங்கள் பாக்கெட் சாதனம். புலி கர்ஜனை, சிங்கம் கர்ஜனை, கழுகு கதறல், துப்பாக்கி சத்தம் மற்றும் மேலும். ஆறு வகைகளில் பத்துக்கும் மேற்பட்ட ஒலிகள். ஸ்மார்ட் பரிந்துரை, ஒலி கலப்பு, கடிகார கட்டுப்பாடு. ஒரு தொடுதல் விரட்ட. வெளியே பாதுகாப்பாக இருங்கள்!"),
  ("ur", "ur-IN-GulNeural", "جنگلی کتے؟ سانپ؟ بندر؟ Shoo آپ کی جیب کا آلہ ہے۔ باندھ کی دھاڑ، شیر کی دھاڑ، عقاب کی چیخ، گولی کی آواز اور مزید۔ چھ زمروں میں دس سے زیادہ آوازیں۔ سمارٹ تجاویز، آواز مکس، گھڑی کنٹرول۔ ایک چھوٹ سے بھگاؤ۔ باہر محفوظ رہیں!"),
  ("uk", "uk-UA-PolinaNeural", "Дикі собаки? Змії? Мавпи? Shoo — ваша кишенева відлякувач. Рик тигра, рик лева, крик орла, постріл та інше. Понад десять звуків у шести категоріях. Розумні рекомендації, мікс звуків, керування годинником. Один дотик щоб відлякати. Будьте в безпеці на вулиці!"),
  ("es-MX", "es-MX-DaliaNeural", "Perros salvajes? Serpientes? Monos? Shoo es tu repelente de bolsillo. Rugido de tigre, gruñido de león, grito de águila, disparo y más. Más de diez sonidos en seis categorías. Recomendaciones inteligentes, mezcla de sonidos, control remoto del reloj. Un toque para ahuyentarlos. Mantente seguro!"),
  ("he", "he-IL-HilaNeural", "כלבים פראיים? נחשים? קופים? Shoo הוא המרחיק שלך לכיס. שאגת טיגריס, נהמת אריה, צרחת נשר, ירי ועוד. מעל עשרה צלילים בשש קטגוריות. המלצות חכמות, ערבול צלילים, שליטת שעון. מגע אחד להבריח. שמרו על בטיחות בחוץ!"),
  ("el", "el-GR-AthinaNeural", "Άγρια σκυλιά; Φίδια; Πίθηκοι; Το Shoo είναι το τσεποδιακό σας απωθητικό. Βρυχηθμός τίγρης, γρύλισμα λιονταριού, κλαυθμός αετού, πυροβολισμός και άλλα. Πάνω από δέκα ήχοι σε έξι κατηγορίες. Έξυπνες προτάσεις, μίξη ήχων, έλεγχος ρολογιού. Μια αφή για να τα τρομάξετε. Μείνετε ασφαλείς έξω!"),
  ("hu", "hu-HU-NoemiNeural", "Vad kutyák? Kígyók? Majmok? A Shoo a zsebablelit-eszköze. Tigris üvöltés, oroszlán morgás, sas kiáltás, lövés és több. Több mint tíz hang hat kategóriában. Intelligens javaslatok, hangkeverés, óra vezérlés. Egy érintés elijesztésre. Legyen biztonságban kint!"),
  ("en-AU", "en-AU-NatashaNeural", "Wild dogs? Snakes? Monkeys? Shoo is your pocket deterrent. Tiger roar, lion growl, eagle cry, gunshot and more. Over ten sounds across six animal categories. Smart recommendations, sound mixing, watch remote control. One tap to scare them away. Stay safe outdoors!"),
  ("en-CA", "en-CA-ClaraNeural", "Wild dogs? Snakes? Monkeys? Shoo is your pocket deterrent. Tiger roar, lion growl, eagle cry, gunshot and more. Over ten sounds across six animal categories. Smart recommendations, sound mixing, watch remote control. One tap to scare them away. Stay safe outdoors!"),
  ("en-GB", "en-GB-SoniaNeural", "Wild dogs? Snakes? Monkeys? Shoo is your pocket deterrent. Tiger roar, lion growl, eagle cry, gunshot and more. Over ten sounds across six animal categories. Smart recommendations, sound mixing, watch remote control. One tap to scare them away. Stay safe outdoors!"),
]

for lang, voice, text in LANGS:
    out = os.path.join(BASE, lang, "narration.mp3")
    os.makedirs(os.path.dirname(out), exist_ok=True)
    if os.path.exists(out):
        os.remove(out)
    print(f"{lang}: generating with {voice}...")
    r = subprocess.run(["node", TTS_SCRIPT, text, out, f"--voice={voice}", "--rate=0"], capture_output=True, text=True)
    if r.returncode == 0:
        size = os.path.getsize(out) if os.path.exists(out) else 0
        # check duration
        dur_check = subprocess.run(["ffprobe", "-v", "error", "-show_entries", "format=duration", "-of", "csv=p=0", out], capture_output=True, text=True)
        dur = float(dur_check.stdout.strip()) if dur_check.stdout.strip() else 0
        print(f"  Done ({size/1024:.1f} KB, {dur:.1f}s)")
    else:
        print(f"  FAILED: {r.stderr[:100]}")

print("\nAll done!")
