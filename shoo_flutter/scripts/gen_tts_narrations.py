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
