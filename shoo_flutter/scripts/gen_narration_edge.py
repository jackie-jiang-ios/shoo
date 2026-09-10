#!/usr/bin/env python3
"""Generate narration.mp3 for remaining 8 languages using edge-tts."""
import asyncio, os
import edge_tts

BASE = os.path.join(os.path.dirname(__file__), "..", "fastlane", "screenshots")

LANGS = [
    ("hi", "hi-IN-SwaraNeural", "जंगली कुत्ते? सांप? बंदर? जानवर भगाने वाला आपकी जेब का उपकरण है। बाघ की दहाड़, शेर की गरजन, चील की चीख, गोली की आवाज़ और भी। छह श्रेणियों में दस से अधिक ध्वनि। स्मार्ट सुझाव, ध्वनि मिश्रण, घड़ी नियंत्रण। एक स्पर्श से भगाएं। बाहर सुरक्षित रहें!"),
    ("da", "da-DK-ChristelNeural", "Vilde hunde? Slanger? Aber? Driv Væk er din lommeforjager. Tigerbrøl, løveknurren, ørneskrig, skud og mere. Over ti lyde i seks kategorier. Smarte anbefalinger, lydmix, ur-kontrol. Et tryk for at skræmme dem. Bliv sikker udendørs!"),
    ("fi", "fi-FI-NooraNeural", "Villiä koiria? Käärmeitä? Apinoita? Eläinkarkoitus on taskukarkottimesi. Tiikerin karjunta, leijonan murina, kotkan huuto, laukaus ja enemmän. Yli kymmenen ääntä kuudessa kategoriassa. Älykkäät suositukset, äänimixaus, kello-kauko-ohjaus. Yksi kosketus karkottamaan. Pysy turvassa ulkona!"),
    ("hr", "hr-HR-GabrijelaNeural", "Divlji psi? Zmije? Majmuni? Tjeranje Životinja je vaš džepni odvraćivač. Tigrov url, lavovo režanje, krik orla, pucanj i više. Više od deset zvukova u šest kategorija. Pametne preporuke, mix zvukova, kontrola sata. Jedan dodir za zastrašivanje. Budite sigurni vani!"),
    ("sv", "sv-SE-SofieNeural", "Vilda hundar? Ormar? Apor? Djurbortdrivande är din fickförrjagare. Tigerbröl, lejontjejud, örnsskrin, skott och mer. Över tio ljud i sex kategorier. Smarta rekommendationer, ljudmix, kock-kontroll. En tryckning för att skrämma dem. Var säker utomhus!"),
    ("sk", "sk-SK-ViktoriaNeural", "Divé psy? Hady? Opice? Odplašenie Zvierat je váš vreckový odstrašovač. Tigrí rev, lvie vrčanie, orlí výkrik, výstrel a viac. Viac ako desať zvukov v šiestich kategóriách. Inteligentné odporúčania, mix zvukov, ovládanie hodiniek. Jeden dotyk na odstrašenie. Buďte v bezpečí vonku!"),
    ("el", "el-GR-AthinaNeural", "Άγρια σκυλιά; Φίδια; Πίθηκοι; Η Απομάκρυνση Ζώων είναι το τσεποδιακό σας απωθητικό. Βρυχηθμός τίγρης, γρύλισμα λιονταριού, κλαυθμός αετού, πυροβολισμός και άλλα. Πάνω από δέκα ήχοι σε έξι κατηγορίες. Έξυπνες προτάσεις, μίξη ήχων, έλεγχος ρολογιού. Μια αφή για να τα τρομάξετε. Μείνετε ασφαλείς έξω!"),
    ("hu", "hu-HU-NoemiNeural", "Vad kutyák? Kígyók? Majmok? Az Állatűző a zsebablelit-eszköze. Tigris üvöltés, oroszlán morgás, sas kiáltás, lövés és több. Több mint tíz hang hat kategóriában. Intelligens javaslatok, hangkeverés, óra vezérlés. Egy érintés elijesztésre. Legyen biztonságban kint!"),
]

async def main():
    for lang, voice, text in LANGS:
        out = os.path.join(BASE, lang, "narration.mp3")
        os.makedirs(os.path.dirname(out), exist_ok=True)
        print(f"{lang}: generating with {voice}...")
        communicate = edge_tts.Communicate(text, voice)
        await communicate.save(out)
        size = os.path.getsize(out)
        print(f"  Done ({size/1024:.1f} KB)")

asyncio.run(main())
print("\nAll done!")
