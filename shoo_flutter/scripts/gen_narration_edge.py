#!/usr/bin/env python3
# gen_narration_edge.py - 使用本地 edge-tts 逐个生成旁白 mp3（已去掉手表功能引用，确保15秒+）
# 用法: python3 scripts/gen_narration_edge.py
import subprocess, os

BASE = os.path.join(os.path.dirname(__file__), "..", "fastlane", "screenshots")

# 文案修改说明：
# 1. 去掉了所有"连接手表远程控制"/"watch remote control"引用（手表功能已移除）
# 2. 确保每种语言文本朗读时长 >= 15 秒（测试中文 ~5字/秒，英文 ~2.5字/秒）

LANGS = [
  ("zh-Hans", "zh-CN-XiaoxiaoNeural",
   "遇到野兽不要慌。防兽神器，你的口袋驱兽专家。内置虎啸、狮吼、鹰啸、枪声等十余种驱赶声音，覆盖六大动物分类。智能推荐最有效声音，支持多声音混合播放，增强驱赶效果。户外出行，野外露营，一键驱兽，守护家人安全。"),
  ("zh-Hant", "zh-CN-XiaoxiaoNeural",
   "遇到野獸不要慌。防獸神器，你的口袋驅獸專家。內建虎嘯、獅吼、鷹嘯、槍聲等十餘種驅趕聲音，覆蓋六大動物分類。智能推薦最有效聲音，支持多聲音混合播放，增強驅趕效果。戶外出行，野外露營，一鍵驅獸，守護家人安全。"),
  ("en-US", "en-US-AriaNeural",
   "Wild dogs? Snakes? Monkeys? Animal Repellent is your pocket wildlife deterrent. Tiger roar, lion growl, eagle cry, gunshot and more. Over ten proven repellent sounds across six animal categories. Smart recommendations find the most effective sound for each pest. Mix multiple sounds together for maximum effect. One tap to scare them away. Stay safe outdoors on your adventures!"),
  ("en-AU", "en-AU-NatashaNeural",
   "Wild dogs? Snakes? Monkeys? Animal Repellent is your pocket wildlife deterrent. Tiger roar, lion growl, eagle cry, gunshot and more. Over ten proven repellent sounds across six animal categories. Smart recommendations find the most effective sound for each pest. Mix multiple sounds together for maximum effect. One tap to scare them away. Stay safe outdoors on your adventures!"),
  ("en-CA", "en-CA-ClaraNeural",
   "Wild dogs? Snakes? Monkeys? Animal Repellent is your pocket wildlife deterrent. Tiger roar, lion growl, eagle cry, gunshot and more. Over ten proven repellent sounds across six animal categories. Smart recommendations find the most effective sound for each pest. Mix multiple sounds together for maximum effect. One tap to scare them away. Stay safe outdoors on your adventures!"),
  ("en-GB", "en-GB-SoniaNeural",
   "Wild dogs? Snakes? Monkeys? Animal Repellent is your pocket wildlife deterrent. Tiger roar, lion growl, eagle cry, gunshot and more. Over ten proven repellent sounds across six animal categories. Smart recommendations find the most effective sound for each pest. Mix multiple sounds together for maximum effect. One tap to scare them away. Stay safe outdoors on your adventures!"),
  ("ja", "ja-JP-NanamiNeural",
   "野生動物に出ても大丈夫。動物撃退は虎の咆哮、ライオンの唸り声、鷹の鳴き声、銃声など10種類以上の忌避音を内蔵。6つの動物カテゴリーに対応。スマート推薦で最も効果的な音を提案。複数音をミックスして効果アップ。ワンタップで追い払おう。アウトドアで安全を守ろう。"),
  ("ko", "ko-KR-SunHiNeural",
   "야생동물을 만나도 걱정 없습니다. 동물퇴치는 호랑이 포효, 사자 울음, 독수리 울음, 총소리 등 10여 종의 퇴치 소리를 내장했습니다. 6대 동물 분류 지원. 스마트 추천으로 가장 효과적인 소리를 찾아드립니다. 여러 소리를 믹스하여 효과를 높이세요. 원터치로 쫓아내세요. 아웃도어에서 안전을 지키세요!"),
  ("fr-FR", "fr-FR-DeniseNeural",
   "Chiens sauvages? Serpents? Singes? Répulsif Animaux est votre répulsif de poche. Rugissement de tigre, grognement de lion, cri d'aigle, coup de feu et plus encore. Plus de dix sons dans six catégories. Recommandations intelligentes pour trouver le son le plus efficace. Mixez plusieurs sons pour un effet maximal. Un toucher pour les effrayer. Restez en sécurité lors de vos aventures!"),
  ("fr-CA", "fr-CA-SylvieNeural",
   "Chiens sauvages? Serpents? Singes? Répulsif Animaux est votre répulsif de poche. Rugissement de tigre, grognement de lion, cri d'aigle, coup de feu et plus. Plus de dix sons dans six catégories. Recommandations intelligentes pour trouver le son le plus efficace. Mixez plusieurs sons pour un effet maximal. Un toucher pour les effrayer. Restez en sécurité lors de vos aventures!"),
  ("de-DE", "de-DE-KatjaNeural",
   "Wilde Hunde? Schlangen? Affen? Tiervertreibung ist Ihr Taschen-Abwehrgerät. Tigerbrüllen, Löwengeknurr, Adlerschrei, Schüsse und mehr. Über zehn Klänge in sechs Kategorien. Intelligente Empfehlungen finden den effektivsten Klang. Mischen Sie mehrere Klänge für maximale Wirkung. Ein Tipp zum Vertreiben. Bleiben Sie bei Ihren Abenteuern sicher!"),
  ("es-ES", "es-ES-ElviraNeural",
   "Perros salvajes? Serpientes? Monos? Ahuyentador es tu repelente de bolsillo. Rugido de tigre, gruñido de león, grito de águila, disparo y más. Más de diez sonidos en seis categorías. Recomendaciones inteligentes encuentran el sonido más efectivo. Mezcla varios sonidos para un efecto máximo. Un toque para ahuyentarlos. Mantente seguro en tus aventuras!"),
  ("es-MX", "es-MX-DaliaNeural",
   "Perros salvajes? Serpientes? Monos? Ahuyentador es tu repelente de bolsillo. Rugido de tigre, gruñido de león, grito de águila, disparo y más. Más de diez sonidos en seis categorías. Recomendaciones inteligentes encuentran el sonido más efectivo. Mezcla varios sonidos para un efecto máximo. Un toque para ahuyentarlos. Mantente seguro en tus aventuras!"),
  ("ru", "ru-RU-SvetlanaNeural",
   "Дикие собаки? Змеи? Обезьяны? Отпугиватель — ваш карманный отпугиватель. Рык тигра, рычание льва, крик орла, выстрел и более десяти звуков. Шесть категорий животных. Умные рекомендации находят самый эффективный звук. Смешивайте звуки для максимального эффекта. Одно касание — и они убегут. Будьте в безопасности на природе!"),
  ("pt-BR", "pt-BR-FranciscaNeural",
   "Cães selvagens? Cobras? Macacos? Repelente é seu repelente de bolso. Rugido de tigre, rosnado de leão, grito de águia, tiro e mais. Mais de dez sons em seis categorias. Recomendações inteligentes encontram o som mais eficaz. Misture vários sons para efeito máximo. Um toque para espantar. Mantenha-se seguro em suas aventuras!"),
  ("th", "th-TH-PremwadeeNeural",
   "หมาป่า? งู? ลิง? ไล่สัตว์ คือเครื่องไล่สัตว์ในกระเป๋าของคุณ เสียงเสือคำราม เสียงสิงห์คำราม เสียงเหยี่ยว เสียงปืน และอีกกว่า 10 เสียง 6 หมวดสัตว์ แนะนำอัจฉริยะหาเสียงที่มีประสิทธิภาพที่สุด ผสมเสียงหลายเสียงเพื่อเพิ่มประสิทธิภาพ แตะเดียวไล่ทันที ปลอดภัยในการผจญภัย!"),
  ("ar-SA", "ar-SA-MagedNeural",
   "كلاب برية؟ أفاعٍ؟ قرود؟ طارد الحيوانات هو طاردك الجيبي. زئير النمر، زمجرة الأسد، صراخ النسر، طلقات نارية والمزيد. أكثر من عشرة أصوات في ست فئات حيوانية. توصيات ذكية تجد الصوت الأكثر فعالية. امزج أصواتاً متعددة للتأثير الأقصى. لمسة واحدة لإخافتها. ابقَ آمناً في مغامراتك!"),
  ("id", "id-ID-GadisNeural",
   "Anjing liar? Ular? Monyet? Usir Hewan adalah pengusir saku Anda. Auman harimau, geraman singa, jeritan elang, tembakan dan lainnya. Lebih dari sepuluh suara dalam enam kategori. Rekomendasi cerdas menemukan suara paling efektif. Campur beberapa suara untuk efek maksimal. Satu ketuk untuk menakuti. Tetap aman di luar!"),
  ("it", "it-IT-ElsaNeural",
   "Cani selvatici? Serpenti? Scimmie? Respingi Animali è il tuo repellente tascabile. Ruggito di tigre, ringhio di leone, strida di aquila, spari e altro. Più di dieci suoni in sei categorie. Suggerimenti intelligenti trovano il suono più efficace. Mixa più suoni per un effetto massimo. Un tocco per spaventarli. Resta al sicuro nelle tue avventure!"),
  ("ms", "ms-MY-YasminNeural",
   "Anjing liar? Ular? Monyet? Usir Haiwan ialah pengusir saku anda. Auman harimau, geraman singa, jeritan helang, tembakan dan lain-lain. Lebih dari sepuluh bunyi dalam enam kategori. Cadangan pintar mencari bunyi paling berkesan. Campur beberapa bunyi untuk kesan maksimum. Satu ketik untuk menakutkan. Kekal selamat di luar!"),
  ("nl-NL", "nl-NL-ColetteNeural",
   "Wilde honden? Slangen? Apen? Dierenverjaging is jouw zakelijke verjager. Tijgergebrul, leeuwgegrom, arendsschreeuw, geweerschoten en meer. Meer dan tien geluiden in zes categorieën. Slimme aanbevelingen vinden het meest effectieve geluid. Meng meer geluiden voor maximaal effect. Duw om ze te verjagen. Blijf veilig buiten!"),
  ("pl", "pl-PL-ZofiaNeural",
   "Dzikie psy? Węże? Małpy? Odstraszanie Zwierząt to Twój kieszonkowy odstraszacz. Ryk tygrysa, warczenie lwa, krzyk orła, strzały i więcej. Ponad dziesięć dźwięków w sześciu kategoriach. Inteligentne rekomendacje znajdują najskuteczniejszy dźwięk. Mieszaj dźwięki dla maksymalnego efektu. Jedno dotknięcie, by je odstraszyć. Bądź bezpieczny na zewnątrz!"),
  ("tr", "tr-TR-EmelNeural",
   "Vahşi köpekler? Yılanlar? Maymunlar? Hayvan Kovucu cepteki kovucunuz. Kaplan kükremesi, aslan homurtusu, kartal çığlığı, silah sesleri ve daha fazlası. Altı kategoride ondan fazla ses. Akıllı öneriler en etkili sesi bulur. Maksimum etki için sesleri karıştırın. Tek dokunuşla korkutun. Dışarıda güvende kalın!"),
  ("vi", "vi-VN-HoaiMyNeural",
   "Chó hoang? Rắn? Khỉ? Đuổi Động Vật là thiết bị xua đuổi bỏ túi của bạn. Tiếng hổ gầm, sư tử gầm, đại bàng kêu, súng nổ và hơn thế nữa. Hơn mười âm thanh trong sáu danh mục. Gợi ý thông minh tìm âm thanh hiệu quả nhất. Trộn nhiều âm thanh để hiệu quả tối đa. Một chạm để dọa chúng. An toàn trong chuyến phiêu lưu!"),
  ("hi", "hi-IN-SwaraNeural",
   "जंगली कुत्ते? सांप? बंदर? जानवर भगाने वाला आपकी जेब का उपकरण है। बाघ की दहाड़, शेर की गरजन, चील की चीख, गोली की आवाज़ और भी। छह श्रेणियों में दस से अधिक ध्वनि। स्मार्ट सुझाव सबसे प्रभावी ध्वनि खोजता है। अधिकतम प्रभाव के लिए ध्वनियों को मिलाएं। एक स्पर्श से भगाएं। बाहर सुरक्षित रहें!"),
  ("da", "da-DK-ChristelNeural",
   "Vilde hunde? Slanger? Aber? Driv Væk er din lommeforjager. Tigerbrøl, løveknurren, ørneskrig, skud og mere. Over ti lyde i seks kategorier. Smarte anbefalinger finder den mest effektive lyd. Bland lyde for maksimal effekt. Et tryk for at skræmme dem. Bliv sikker udendørs!"),
  ("fi", "fi-FI-NooraNeural",
   "Villiä koiria? Käärmeitä? Apinoita? Eläinkarkoitus on taskukarkottimesi. Tiikerin karjunta, leijonan murina, kotkan huuto, laukaus ja enemmän. Yli kymmenen ääntä kuudessa kategoriassa. Älykkäät suositukset löytävät tehokkaimman äänen. Sekoita ääniä maksimivaikutusta varten. Yksi kosketus karkottaaksesi. Pysy turvassa ulkona!"),
  ("gu", "gu-IN-DhwaniNeural",
   "જંગલી કૂતરાઓ? સાપ? વાંદર? પ્રાણીઓ ભગાવો તમારું પોકેટ ઉપકરણ છે. વાઘની ગર્જના, સિંહની ગર્જના, ઈગલની ચીસ, ગોળીનો અવાજ અને વધુ. છ કેટેગરીમાં દસથી વધુ અવાજ. સ્માર્ટ સૂચન સૌથી અસરકારક અવાજ શોધે છે. મહત્તમ અસર માટે અવાજ મિક્સ કરો. એક સ્પર્શથી ભગાડો. બહાર સુરક્ષિત રહો!"),
  ("ca", "ca-ES-JoanaNeural",
   "Gossos salvatges? Serps? Micos? Espanta Animals és el teu repel·lent de butxaca. Rugit de tigre, grunyit de lleó, xiscle d'àliga, tret i més. Més de deu sons en sis categories. Recomanacions intel·ligents troben el so més efectiu. Mescla diversos sons per a un efecte màxim. Un toc per espantar-los. Estigues segur a l'exterior!"),
  ("cs", "cs-CZ-VlastaNeural",
   "Divokí psi? Had? Opice? Odehnat Zvířata je vaše kapesní odstrašovač. Tygří řev, lví vrčení, výskrek orla, výstřel a více. Více než deset zvuků v šesti kategoriích. Chytrá doporučení najdou nejefektivnější zvuk. Smíchejte zvuky pro maximální efekt. Jedno dotknutí pro odstrašení. Buďte v bezpečí venku!"),
  ("kn", "kn-IN-SapnaNeural",
   "ಕಾಡು ನಾಯಿಗಳು? ಹಾವುಗಳು? ಕೋತಿಗಳು? ಪ್ರಾಣಿಗಳನ್ನು ಓಡಿಸಿ ನಿಮ್ಮ ಖುಟ್ಟಿನ ಉಪಕರಣ. ಹುಲಿ ಗರ್ಜನೆ, ಸಿಂಹ ಗರ್ಜನೆ, ಗರುಡ ಕೂಗು, ಗುಂಡಿನ ಸದ್ದು ಮತ್ತು ಹೆಚ್ಚು. ಆರು ವರ್ಗಗಳಲ್ಲಿ ಹತ್ತಕ್ಕಿಂತ ಹೆಚ್ಚು ಧ್ವನಿಗಳು. ಸ್ಮಾರ್ಟ್ ಸಲಹೆ ಅತ್ಯಂತ ಪ್ರಭಾವಶಾಲಿ ಧ್ವನಿಯನ್ನು ಹುಡುಕುತ್ತದೆ. ಗರಿಷ್ಠ ಪ್ರಭಾವಕ್ಕಾಗಿ ಧ್ವನಿಗಳನ್ನು ಮಿಕ್ಸ್ ಮಾಡಿ. ಒಂದು ಸ್ಪರ್ಶದಿಂದ ಓಡಿಸಿ. ಹೊರಗೆ ಸುರಕ್ಷಿತವಾಗಿರಿ!"),
  ("hr", "hr-HR-GabrijelaNeural",
   "Divlji psi? Zmije? Majmuni? Tjeranje Životinja je vaš džepni odvraćivač. Tigrov url, lavovo režanje, krik orla, pucanj i više. Više od deset zvukova u šest kategorija. Pametne preporuke pronalaze najučinkovitiji zvuk. Miješajte zvukove za maksimalni učinak. Jedan dodir za zastrašivanje. Budite sigurni vani!"),
  ("ro", "ro-RO-AlinaNeural",
   "Câini sălbatici? Șerpi? Maimuțe? Alungit Animale este repelentul tău de buzunar. Răget de tigru, mârâit de leu, țipăt de vultur, împușcături și mai mult. Peste zece sunete în șase categorii. Recomandări inteligente găsesc cel mai eficient sunet. Amestecați sunete pentru efect maxim. O atingere pentru a speria. Rămâi în siguranță!"),
  ("mr", "mr-IN-AarohiNeural",
   "जंगली कुत्री? साप? वानर? प्राणी भागवा तुमचे खिशातले उपकरण आहे. वाघाची गर्जना, सिंहाची गर्जना, गरुडाची चीत्कार, गोळीचा आवाज आणि अधिक. सहा वर्गांमध्ये दहापेक्षा जास्त आवाज. स्मार्ट सुजाव सर्वात प्रभावी आवाज शोधतो. सर्वात जास्त परिणामासाठी आवाज मिक्स करा. एक स्पर्शाने घालवा. बाहेर सुरक्षित रहा!"),
  ("ml", "ml-IN-MidhunaNeural",
   "കാട്ടുനായ്കൾ? പാമ്പുകൾ? കുരങ്ങുകൾ? മൃഗങ്ങളെ ഓടിക്കുക നിങ്ങളുടെ പോക്കറ്റ് ഉപകരണം. കടുവ കർഷണം, സിംഹ ഗർജ്ജനം, പരുന്ത് ചിലയ്ക്കൽ, വെടിയും കൂടുതൽ. ആറ് വിഭാഗങ്ങളിൽ പത്തിലധികം ശബ്ദങ്ങൾ. സ്മാർട്ട് നിർദ്ദേശം ഏറ്റവും ഫലപ്രദമായ ശബ്ദം കണ്ടെത്തുന്നു. പരമാവധി ഫലത്തിന് ശബ്ദങ്ങൾ മിക്സ് ചെയ്യുക. ഒരു സ്പർശനം മതി. പുറത്ത് സുരക്ഷിതം!"),
  ("bn", "bn-IN-TanishaaNeural",
   "বন্য কুকুর? সাপ? বানর? প্রাণী তাড়ানো আপনার পকেট ডিভাইস। বাঘের গর্জন, সিংহের গর্জন, ঈগলের চিৎকার, বন্দুকের শব্দ এবং আরও। ছয় বিভাগে দশটির বেশি শব্দ। স্মার্ট পরামর্শ সবচেয়ে কার্যকর শব্দ খুঁজে পায়। সর্বোচ্চ প্রভাবের জন্য শব্দ মিক্স করুন। এক স্পর্শে তাড়িয়ে দিন। বাইরে নিরাপদ থাকুন!"),
  ("no", "nb-NO-PernilleNeural",
   "Ville hunder? Slanger? aper? Dyrefordrivelse er din lommeforjager. Tigerbrøl, løveknurring, ørneskrik, skudd og mer. Over ti lyder i seks kategorier. Smarte anbefalinger finner den mest effektive lyden. Bland lyder for maksimal effekt. Et trykk for å skremme dem. Vær trygg utendørs!"),
  ("pa", "pa-IN-NoorNeural",
   "ਜੰਗਲੀ ਕੁੱਤੇ? ਸੱਪ? ਬਾਂਦਰ? ਜਾਨਵਰ ਭਗਾਓ ਤੁਹਾਡਾ ਜੇਬ ਉਪਕਰਣ ਹੈ। ਬਾਘ ਦੀ ਗਰਜ, ਸ਼ੇਰ ਦੀ ਗਰਜ, ਗਰੁੱਧ ਦੀ ਚੀਂਕ, ਗੋਲੀ ਦੀ ਆਵਾਜ਼ ਅਤੇ ਹੋਰ। ਛੇ ਵਰਗਾਂ ਵਿੱਚ ਦਸ ਤੋਂ ਵੱਧ ਧੁਨੀਆਂ। ਸਮਾਰਟ ਸੁਝਾਅ ਸਭ ਤੋਂ ਪ੍ਰਭਾਵੀ ਧੁਨੀ ਲੱਭਦਾ ਹੈ। ਵੱਧ ਤੋਂ ਵੱਧ ਪ੍ਰਭਾਵ ਲਈ ਧੁਨੀਆਂ ਨੂੰ ਮਿਕਸ ਕਰੋ। ਇੱਕ ਛੋਹ ਨਾਲ ਭਜਾਓ। ਬਾਹਰ ਸੁਰੱਖਿਅਤ ਰਹੋ!"),
  ("sv", "sv-SE-SofieNeural",
   "Vilda hundar? Ormar? Apor? Djurbortdrivande är din fickförrjagare. Tigerbröl, lejontjejud, örnsskrin, skott och mer. Över tio ljud i sex kategorier. Smarta rekommendationer hittar den mest effektiva ljudet. Blanda ljud för maximal effekt. Tryck för att skrämma dem. Var säker utomhus!"),
  ("sk", "sk-SK-ViktoriaNeural",
   "Divé psy? Hady? Opice? Odplašenie Zvierat je váš vreckový odstrašovač. Tigrí rev, lvie vrčanie, orlí výkrik, výstrel a viac. Viac ako desať zvukov v šiestich kategóriách. Inteligentné odporúčania nájdu najefektívnejší zvuk. Zmiešajte zvuky pre maximálny efekt. Jeden dotyk na odstrašenie. Buďte v bezpečí vonku!"),
  ("sl", "sl-SI-PetraNeural",
   "Divji psi? Kače? Opice? Odganjanje Živali je vaš žepni odganjalec. Tigrji rženje, levje renčanje, krik orla, strel in več. Več kot deset zvukov v šestih kategorijah. Pametna priporočila najdejo najučinkovitejši zvuk. Mešajte zvukove za maksimalen učinek. En dotik za prestrašenje. Bodite varni zunaj!"),
  ("te", "te-IN-ShrutiNeural",
   "అడవి కుక్కలు? పాములు? కోతులు? జంతువులను తరిమికొట్టు మీ జేబి పరికరం. పులి గర్జన, సింహం గర్జన, గరుడ అరుపు, తుపాకి చప్పుడు మరియు మరిన్ని. ఆరు వర్గాలలో పదికి పైగా శబ్దాలు. స్మార్ట్ సూచన అత్యంత ప్రభావవంతమైన శబ్దాన్ని కనుగొంటుంది. గరిష్ఠ ప్రభావం కోసం శబ్దాలను మిక్స్ చేయండి. ఒక తాకిడితో తరిమివేయండి. బయట సురక్షితంగా ఉండండి!"),
  ("ta", "ta-IN-PallaviNeural",
   "காட்டு நாய்கள்? பாம்புகள்? குரங்குகள்? விலங்குகளை ஓட்டுங்கள் உங்கள் பாக்கெட் சாதனம். புலி கர்ஜனை, சிங்கம் கர்ஜனை, கழுகு கதறல், துப்பாக்கி சத்தம் மற்றும் மேலும். ஆறு வகைகளில் பத்துக்கும் மேற்பட்ட ஒலிகள். ஸ்மார்ட் பரிந்துரை மிகவும் பலனளிக்கும் ஒலியைக் கண்டறிகிறது. அதிக விளைவுக்கு ஒலிகளை கலக்கவும். ஒரு தொடுதல் விரட்ட. வெளியே பாதுகாப்பாக இருங்கள்!"),
  ("ur", "ur-IN-GulNeural",
   "جنگلی کتے؟ سانپ؟ بندر؟ جانوروں کو بھگائیں آپ کی جیب کا آلہ ہے۔ باندھ کی دھاڑ، شیر کی دھاڑ، عقاب کی چیخ، گولی کی آواز اور مزید۔ چھ زمروں میں دس سے زیادہ آوازیں۔ سمارٹ تجاویز سب سے مؤثر آواز ڈھونڈتی ہیں۔ زیادہ سے زیادہ اثر کے لیے آوازیں مرکب کریں۔ ایک چھوٹ سے بھگاؤ۔ باہر محفوظ رہیں!"),
  ("uk", "uk-UA-PolinaNeural",
   "Дикі собаки? Змії? Мавпи? Відштовхувач — ваша кишенева відлякувач. Рик тигра, рик лева, крик орла, постріл та інше. Понад десять звуків у шести категоріях. Розумні рекомендації знаходять найефективніший звук. Змішуйте звуки для максимального ефекту. Один дотик щоб відлякати. Будьте в безпеці на вулиці!"),
  ("he", "he-IL-HilaNeural",
   "כלבים פראיים? נחשים? קופים? מהדהד בעלי חיים הוא המרחיק שלך לכיס. שאגת טיגריס, נהמת אריה, צרחת נשר, ירי ועוד. מעל עשרה צלילים בשש קטגוריות. המלצות חכמות מוצאות את הצליל היעיל ביותר. ערבב צלילים להשפעה מקסימלית. מגע אחד להבריח. שמרו על בטיחות בחוץ!"),
  ("el", "el-GR-AthinaNeural",
   "Άγρια σκυλιά; Φίδια; Πίθηκοι; Η Απομάκρυνση Ζώων είναι το τσεποδιακό σας απωθητικό. Βρυχηθμός τίγρης, γρύλισμα λιονταριού, κλαυθμός αετού, πυροβολισμός και άλλα. Πάνω από δέκα ήχοι σε έξι κατηγορίες. Έξυπνες προτάσεις βρίσκουν τον πιο αποτελεσματικό ήχο. Μείξτε ήχους για μέγιστη επίδραση. Μια αφή για να τα τρομάξετε. Μείνετε ασφαλείς έξω!"),
  ("hu", "hu-HU-NoemiNeural",
   "Vad kutyák? Kígyók? Majmok? Az Állatűző a zsebablelit-eszköze. Tigris üvöltés, oroszlán morgás, sas kiáltás, lövés és több. Több mint tíz hang hat kategóriában. Intelligens javaslatok megtalálják a leginkább hatékony hangot. Keverje össze a hangokat a maximális hatásért. Egy érintés elijesztésre. Legyen biztonságban kint!"),
]

count = 0
total = len(LANGS)
for lang, voice, text in LANGS:
    count += 1
    out = os.path.join(BASE, lang, "narration.mp3")
    os.makedirs(os.path.dirname(out), exist_ok=True)
    print(f"[{count}/{total}] {lang} (voice={voice})...", flush=True)
    try:
        r = subprocess.run(
            ["python3", "-m", "edge_tts", "--voice", voice, "--text", text, "--write-media", out],
            capture_output=True, text=True, timeout=60
        )
        if r.returncode == 0 and os.path.exists(out) and os.path.getsize(out) > 1000:
            dur = subprocess.run(
                ["ffprobe", "-v", "error", "-show_entries", "format=duration", "-of", "csv=p=0", out],
                capture_output=True, text=True
            )
            dur_val = float(dur.stdout.strip()) if dur.stdout.strip() else 0
            size_kb = os.path.getsize(out) / 1024
            status = "✓" if dur_val >= 15 else "⚠ SHORT"
            print(f"    {status} {dur_val:.1f}s, {size_kb:.1f} KB")
            if dur_val < 15:
                print(f"    ⚠ 不足15秒！")
        else:
            print(f"    ✗ FAILED: {r.stderr[:100]}")
    except Exception as e:
        print(f"    ✗ ERROR: {str(e)[:100]}")

print(f"\n=== Done: {total} languages ===")
