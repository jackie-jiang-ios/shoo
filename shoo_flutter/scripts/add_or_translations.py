#!/usr/bin/env python3
"""Add Odia (or) translations to app_localizations.dart by matching English values."""
import re

FILE = '/Users/jiangzheng/Project/iOS/Shoo/shoo_flutter/lib/l10n/app_localizations.dart'

# Odia translations indexed by English source text
EN_TO_OR = {
    'Animal Repellent': 'ପଶୁ ତଡ଼ିବା ଔଷଧ',
    'Sound-powered safety': 'ଧ୍ୱନି ଦ୍ୱାରା ସୁରକ୍ଷା',
    'Confirm': 'ନିଶ୍ଚିତ କରନ୍ତୁ',
    'Cancel': 'ବାତିଲ୍ କରନ୍ତୁ',
    'Close': 'ବନ୍ଦ କରନ୍ତୁ',
    'Done': 'ହୋଇଗଲା',
    'Play': 'ଚଲାନ୍ତୁ',
    'Stop': 'ବନ୍ଦ କରନ୍ତୁ',
    'Pause': 'ବିରାମ ଦିଅନ୍ତୁ',
    'Loading...': 'ଲୋଡ୍ ହେଉଛି...',
    'Retry': 'ପୁଣି ଚେଷ୍ଟା କରନ୍ତୁ',
    'Smart Tips': 'ସ୍ମାର୍ଟ ଟିପ୍ସ୍',
    'Suggested now: Snake/Boar': 'ବର୍ତ୍ତମାନ ପରାମର୍ଶ: ସାପ/ବରାହ',
    'Counter Sound': 'Counter Sound',
    'Details': 'ବିବରଣୀ',
    'Recommended Sounds': 'ପରାମର୍ଶିତ ଧ୍ୱନି',
    'Now Playing': 'ବର୍ତ୍ତମାନ ଚାଲୁଛି',
    'Tap an animal to start': 'ଆରମ୍ଭ କରିବାକୁ ଗୋଟିଏ ପଶୁକୁ ଟ୍ୟାପ୍ କରନ୍ତୁ',
    'Start Scaring': 'ଭୟ ଦେଖାଇବା ଆରମ୍ଭ କରନ୍ତୁ',
    'Stop Scaring': 'ଭୟ ଦେଖାଇବା ବନ୍ଦ କରନ୍ତୁ',
    'All': 'ସମସ୍ତ',
    'Beasts': 'ବିରାଟ ପଶୁ',
    'Reptiles': 'ସରୀସୃପ',
    'Primates': 'ପ୍ରାଇମେଟ୍',
    'Rodents': 'ଗଣ୍ଡା',
    'Insects': 'କୀଟ',
    'Birds': 'ପକ୍ଷୀ',
    'Wild Dog': 'ବଣ୍ଟା କୁକୁର',
    'Venomous Snake': 'ବିଷଧରି ସାପ',
    'Wild Boar': 'ବଣ୍ଟା ବରାହ',
    'Bear': 'ଭାଲୁ',
    'Monkey': 'ମାଙ୍କଡ଼',
    'Mouse': 'ନେଉଡ଼ି',
    'Wolf': 'ବାଘିଆ',
    'Venomous Spider': 'ବିଷଧରି ମାକଡ଼ା',
    'Wasp': 'ବଣ୍ଟା ମହୁମାଛି',
    'Wild Rabbit': 'ବଣ୍ଟା ଠେଁଟ',
    'Crow': 'କଣ୍ଠା',
    'Fox': 'କୋକି',
    'Volume': 'ଭଲ୍ୟୁମ୍',
    'Play Mode': 'ପ୍ଲେ ମୋଡ୍',
    'Continuous': 'ନିରନ୍ତର',
    'Interval': 'ଅନ୍ତରାଳ',
    'Interval Time': 'ଅନ୍ତରାଳ ସମୟ',
    'Sound Mix': 'ଧ୍ୱନି ମିଶ୍ରଣ',
    'Add Sound': 'ଧ୍ୱନି ଯୋଡ଼ନ୍ତୁ',
    'Start Mix': 'ମିଶ୍ରଣ ଆରମ୍ଭ',
    'Stop Mix': 'ମିଶ୍ରଣ ବନ୍ଦ',
    'Timer': 'ଟାଇମର୍',
    'Set Timer': 'ଟାଇମର୍ ସେଟ୍ କରନ୍ତୁ',
    'Duration': 'ଅବଧି',
    'min': 'ମିନିଟ୍',
    'hr': 'ଘଣ୍ଟା',
    'sec': 'ସେକେଣ୍ଡ',
    'No interval': 'କୌଣସି ଅନ୍ତରାଳ ନାହିଁ',
    'Start': 'ଆରମ୍ଭ',
    'Timer done, stopped': 'ଟାଇମର୍ ଶେଷ, ବନ୍ଦ ହେଲା',
    'No auto stop': 'କୌଣସି ସ୍ୱତଃ ବନ୍ଦ ନାହିଁ',
    'Settings': 'ସେଟିଂସ୍',
    'Appearance': 'ରୂପ',
    'Theme': 'ଥିମ୍',
    'System': 'ସିଷ୍ଟମ୍',
    'Light': 'ଆଲୁଅ',
    'Dark': 'ଅନ୍ଧାର',
    'Language': 'ଭାଷା',
    'Default Volume': 'ଡିଫଲ୍ଟ ଭଲ୍ୟୁମ୍',
    'Keep Screen On': 'ସ୍କ୍ରିନ୍ ଅନ୍ ରଖନ୍ତୁ',
    'Auto Stop': 'ସ୍ୱତଃ ବନ୍ଦ',
    'About': 'ବିଷୟରେ',
    'Version': 'ସଂସ୍କରଣ',
    'Rate Us': 'ଆମକୁ ରେଟ୍ କରନ୍ତୁ',
    'Feedback': 'ମତାମତ',
    'Legal': 'ଆଇନଗତ',
    'Terms of Service': 'ସେବାର ସର୍ତ୍ତାବଳୀ',
    'Privacy Policy': 'ଗୋପନୀୟତା ନୀତି',
    'Playback': 'ପ୍ଲେବ୍ୟାକ୍',
    'Sounds': 'ଧ୍ୱନି',
    'Ultrasonic': 'ଅଲ୍ଟ୍ରାସୋନିକ୍',
    'Animal': 'ପଶୁ',
    'Firecracker': 'ଫଟକା',
    'Alarm': 'ଆଲାର୍ମ',
    'Metal': 'ଧାତବ',
    'Target': 'ଲକ୍ଷ୍ୟ',
    'Frequency': 'ଫ୍ରିକ୍ୱେନ୍ସୀ',
    'Home': 'ଘର',
    'Mix': 'ମିଶ୍ରଣ',
    'Icon Style': 'ଆଇକନ୍ ଶୈଳୀ',
    'Mode': 'ମୋଡ୍',
    'Single': 'ଏକକ',
    'Multi': 'ବହୁ',
    'Select': 'ଚୟନ କରନ୍ତୁ',
    'Single loop': 'ଏକକ ଲୁପ୍',
    'Multi loop': 'ବହୁ ଲୁପ୍',
    ' files': ' ଫାଇଲ୍ସମୂହ',
    'Single file': 'ଏକକ ଫାଇଲ୍',
    'Selected files play in order on loop, then start over.': 'ଚୟନିତ ଫାଇଲ୍ସମୂହ କ୍ରମରେ ଲୁପ୍ରେ ଚାଲନ୍ତୁ, ତାପରେ ପୁଣି ଆରମ୍ଭ ହୁଏ।',
    'Loop Interval': 'ଲୁପ୍ ଅନ୍ତରାଳ',
    'Off': 'ଅଫ୍',
    'Tap to preview sounds': 'ଧ୍ୱନି ପୂର୍ବାବଲୋକନ କରିବାକୁ ଟ୍ୟାପ୍ କରନ୍ତୁ',
    'File': 'ଫାଇଲ୍',
    'Generating waveform': 'ତରଙ୍ଗରୂପ ସୃଷ୍ଟି ହେଉଛି',
    'Switch and play': 'ସୁଇଚ୍ କରନ୍ତୁ ଏବଂ ଚଲାନ୍ତୁ',
    'Selected': 'ଚୟନିତ',
    'Not selected': 'ଚୟନ ହୋଇନାହିଁ',
    'Waveform Preview': 'ତରଙ୍ଗରୂପ ପୂର୍ବାବଲୋକନ',
    'Output': 'ଆଉଟପୁଟ୍',
    'Freq': 'ଫ୍ରିକ୍',
    'Intensity': 'ତୀବ୍ରତା',
    'Shape': 'ଆକୃତି',
    'Soft': 'ନରମ',
    'Balanced': 'ସନ୍ତୁଳିତ',
    'Strong': 'ଶକ୍ତ',
    'Powerful': 'ଶକ୍ତିଶାଳୀ',
    'Bass-led': 'ବାସ୍-ନିର୍ଦେଶିତ',
    'Mid-balanced': 'ମଧ୍ୟମ-ସନ୍ତୁଳିତ',
    'Treble-clear': 'ଟ୍ରେବଲ୍-ସ୍ପଷ୍ଟ',
    'Ultra-high': 'ଅତି-ଉଚ୍ଚ',
    'Wave motion stays active during playback so the output feels easier to read.': 'ତରଙ୍ଗ ଗତି ପ୍ଲେବ୍ୟାକ୍ ସମୟରେ ସକ୍ରିୟ ରହିଥାଏ ଯାହା ଆଉଟପୁଟକୁ ପଢ଼ିବାକୁ ସହଜ ଲାଗେ।',
    'The preview stays static when idle and animates during playback.': 'ପୂର୍ବାବଲୋକନ ନିଷ୍କ୍ରିୟ ଥିବାବେଳେ ସ୍ଥିର ରହିଥାଏ ଏବଂ ପ୍ଲେବ୍ୟାକ୍ ସମୟରେ ଆନିମେଟ୍ ହୋଇଥାଏ।',
    'Custom Duration': 'କଷ୍ଟମ୍ ଅବଧି',
    'Volume Low': 'ଭଲ୍ୟୁମ୍ ନିମ୍ନ',
    'Current volume may not be effective. Try turning it up or using an external speaker.': 'ବର୍ତ୍ତମାନର ଭଲ୍ୟୁମ୍ ପ୍ରଭାବଶାଳୀ ନୁହେଁ। ଏହାକୁ ବଢ଼ାନ୍ତୁ କିମ୍ବା ଏକ ବାହ୍ୟ ସ୍ପିକର୍ ବ୍ୟବହାର କରନ୍ତୁ।',
    'Gradually increasing volume...': 'ଧୀରେ ଧୀରେ ଭଲ୍ୟୁମ୍ ବଢ଼ୁଛି...',
    'Turn Up': 'ବଢ଼ାନ୍ତୁ',
    'Playing': 'ଚାଲୁଛି',
    'Upgrade to Pro': 'ପ୍ରୋକୁ ଅପଗ୍ରେଡ୍ କରନ୍ତୁ',
    'Shoo Pro': 'Shoo Pro',
    'Unlock all animal sounds': 'ସମସ୍ତ ପଶୁ ଧ୍ୱନି ଅନଲକ୍ କରନ୍ତୁ',
    'Free animals': 'ମାଗଣା ପଶୁ',
    'Wild dog, Snake, Mouse, Crow': 'ବଣ୍ଟା କୁକୁର, ସାପ, ନେଉଡ଼ି, କଣ୍ଠା',
    'All animals': 'ସମସ୍ତ ପଶୁ',
    'Boar, Bear, Wolf, Fox, Monkey, Rabbit, Spider, Wasp and more': 'ବରାହ, ଭାଲୁ, ବାଘିଆ, କୋକି, ମାଙ୍କଡ଼, ଠେଁଟ, ମାକଡ଼ା, ବଣ୍ଟା ମହୁମାଛି ଏବଂ ଅଧିକ',
    'All features': 'ସମସ୍ତ ବୈଶିଷ୍ଟ୍ୟ',
    'Sound mixing, timer, interval playback': 'ଧ୍ୱନି ମିଶ୍ରଣ, ଟାଇମର୍, ଅନ୍ତରାଳ ପ୍ଲେବ୍ୟାକ୍',
    'Future updates': 'ଭବିଷ୍ୟତର ଅପଡେଟ୍',
    'New animals and features included': 'ନୂତନ ପଶୁ ଏବଂ ବୈଶିଷ୍ଟ୍ୟ ଅନ୍ତର୍ଭୁକ୍ତ',
    'One-time purchase, yours forever': 'ଏକକ-ବ୍ୟୟୀ କ୍ରୟ, ସବୁଦିନ ପାଇଁ ଆପଣଙ୍କର',
    '$0.99': '$0.99',
    'Unlock Pro': 'ପ୍ରୋ ଅନଲକ୍ କରନ୍ତୁ',
    'Restore Purchases': 'କ୍ରୟଗୁଡ଼ିକ ପୁନରୁଦ୍ଧାର କରନ୍ତୁ',
    'Secure payment via App Store': 'App Store ମାଧ୍ୟମରେ ସୁରକ୍ଷିତ ଦେୟ',
    'Purchase successful! All animals unlocked': 'କ୍ରୟ ସଫଳ! ସମସ୍ତ ପଶୁ ଅନଲକ୍ ହୋଇଛି',
    'Restore successful!': 'ପୁନରୁଦ୍ଧାର ସଫଳ!',
    'No purchases to restore': 'ପୁନରୁଦ୍ଧାର କରିବାକୁ କୌଣସି କ୍ରୟ ନାହିଁ',
    'Pro': 'ପ୍ରୋ',
    'Got it': 'ବୁଝିଲି',
    'More Products': 'ଅଧିକ ଉତ୍ପାଦ',
    'Follow System': 'ସିଷ୍ଟମ୍ ଅନୁସରଣ',
}

with open(FILE, 'r') as f:
    content = f.read()

# Pattern: String get NAME => _t(const { BODY });
# Closing is "\n  });" or "\n});"
pattern = r"(String get (\w+) => _t\(const \{)(.*?)(\n\s*\}\);)"

def add_or_translation(match):
    getter = match.group(2)
    body = match.group(3)
    
    # Find the English value in the body
    en_match = re.search(r"'en': '([^']*)'", body)
    if not en_match:
        en_match = re.search(r"'en_AU': '([^']*)'", body)
    
    if en_match:
        en_text = en_match.group(1)
        if en_text in EN_TO_OR:
            or_value = EN_TO_OR[en_text]
            # Find the last entry line and insert after it
            lines = body.split('\n')
            last_entry_idx = -1
            for i in range(len(lines) - 1, -1, -1):
                if "'" in lines[i] and ':' in lines[i] and not lines[i].strip().startswith('//'):
                    last_entry_idx = i
                    break
            
            if last_entry_idx >= 0:
                indent = '    '
                lines.insert(last_entry_idx + 1, f"{indent}'or': '{or_value}',")
                new_body = '\n'.join(lines)
                return match.group(1) + new_body + match.group(4)
    
    return match.group(0)

result = re.sub(pattern, add_or_translation, content, flags=re.DOTALL)

or_count = result.count("'or':")
print(f"Added {or_count} 'or' translation entries")

with open(FILE, 'w') as f:
    f.write(result)

print("Done!")
