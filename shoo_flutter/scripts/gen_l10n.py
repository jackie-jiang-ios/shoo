#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""使用 deep-translator (Google) 自动生成缺失的翻译 - 带断点续传"""
import re
import time
import json
import os

# 翻译语言映射
LANGUAGES = {
    'gu': 'gujarati',
    'ca': 'catalan',
    'cs': 'czech',
    'kn': 'kannada',
    'hr': 'croatian',
    'ro': 'romanian',
    'mr': 'marathi',
    'ml': 'malayalam',
    'bn': 'bengali',
    'no': 'norwegian',
    'pa': 'punjabi',
    'sv': 'swedish',
    'sk': 'slovak',
    'sl': 'slovenian',
    'te': 'telugu',
    'ta': 'tamil',
    'ur': 'urdu',
    'uk': 'ukrainian',
    'es_MX': 'spanish',
    'he': 'hebrew',
    'el': 'greek',
    'hu': 'hungarian',
}

ENGLISH_TEXTS = [
    "Sound-powered safety", "Confirm", "Cancel", "Close", "Done", "Play", "Stop", "Pause",
    "Loading...", "Retry", "Smart Tips", "Suggested now: Snake/Boar", "Counter Sound",
    "Details", "Recommended Sounds", "Now Playing", "Tap an animal to start",
    "Start Scaring", "Stop Scaring", "All", "Beasts", "Reptiles", "Primates",
    "Rodents", "Insects", "Birds", "Settings", "Appearance", "ThemeMode",
    "Follow System", "Light Mode", "Dark Mode", "Language", "Playback",
    "Default Volume", "Keep Screen On", "Loop Interval", "No Interval", "seconds",
    "Auto Stop", "No Auto Stop", "minutes", "hours", "About", "Version",
    "Rate Us", "Feedback", "Restore Purchases", "More Products", "Legal",
    "Terms of Service", "Privacy Policy", "Restore Success", "Restore Failed",
    "No animals found", "Scan QR Code", "Rescan", "Scan a QR code to access",
    "Camera permission required", "Open Settings", "Scan Result", "Open URL",
    "Copied to clipboard", "Invalid QR Code", "Camera Error",
    "Failed to initialize camera", "Scan Failed", "Failed to scan QR code",
    "Single Loop", "Sequence Loop", "nFiles", "Single File", "Icon Style",
    "Pro Feature", "Unlock Pro", "Unlock All Animals", "Go Pro", "Premium",
    "Free", "Upgrade", "Watch Ad to Unlock", "Ad Loading", "Ad Failed",
    "Watch Again", "Share", "Share App", "Share Message", "Share Failed",
    "Print", "Print Front", "Print Back", "Print Preview", "Download",
    "Download Front", "Download Back", "Generating PDF", "PDF Ready",
    "Save to Photos", "Saved", "Save Failed", "Permission Denied",
    "Camera Roll Access Required", "OK", "Copied", "Scan", "Camera",
    "Photo Library", "Select Image", "No image selected", "Processing",
    "Success", "Failed", "Error", "Warning", "Info", "Tips", "Help",
    "Contact Us", "Support", "FAQ", "Tutorial", "Getting Started", "Features",
    "Pricing", "Subscription", "Purchase", "Restore", "Manage Subscription",
    "Cancel Subscription", "Refund", "Report a Problem", "Terms", "Privacy",
    "Cookie Policy", "Data Collection", "Third Party Services", "Analytics",
    "Advertisements", "Push Notifications", "Location Service", "Microphone",
    "Bluetooth", "Wi-Fi", "Mobile Data", "Storage", "Cache", "Clear Cache",
    "Storage Permission Required", "Camera Permission", "Photo Permission",
    "Location Permission", "Microphone Permission", "Notifications Permission",
    "Calendar Permission", "Contacts Permission", "Grant Permission", "Deny",
    "Allow", "Later", "Never", "Always", "Only While Using", "Ask Next Time",
    "Settings Opened", "Permission Granted", "Go to Settings", "App Settings",
    "Device Settings", "System Settings", "Network Error", "Connection Failed",
    "Timeout", "Server Error", "Unknown Error", "Try Again", "Refresh",
    "Reload", "Update", "Download Update", "Install", "Later Update",
    "Remind Me Later", "Skip This Version", "What's New", "Release Notes"
]

PROGRESS_FILE = 'scripts/gen_l10n_progress.json'

def load_progress():
    if os.path.exists(PROGRESS_FILE):
        with open(PROGRESS_FILE, 'r', encoding='utf-8') as f:
            return json.load(f)
    return {}

def save_progress(progress):
    with open(PROGRESS_FILE, 'w', encoding='utf-8') as f:
        json.dump(progress, f, ensure_ascii=False, indent=2)

def translate_batch(texts, dest_lang):
    """批量翻译"""
    from deep_translator import GoogleTranslator
    translator = GoogleTranslator(source='en', target=dest_lang)
    return translator.translate_batch(texts)

def main():
    progress = load_progress()
    print(f"Loaded progress: {len(progress)} languages already done")
    
    for lang_code, lang_name in LANGUAGES.items():
        if lang_code in progress:
            print(f"\nSkipping {lang_code} (already done)")
            continue
        
        print(f"\nTranslating {lang_code} ({lang_name})...")
        translations = {}
        
        # 批量翻译，每批10个
        batch_size = 10
        for i in range(0, len(ENGLISH_TEXTS), batch_size):
            batch = ENGLISH_TEXTS[i:i+batch_size]
            try:
                results = translate_batch(batch, lang_name)
                for orig, trans in zip(batch, results):
                    translations[orig] = trans
            except Exception as e:
                print(f"  Batch error: {e}")
                time.sleep(5)
                try:
                    results = translate_batch(batch, lang_name)
                    for orig, trans in zip(batch, results):
                        translations[orig] = trans
                except Exception as e2:
                    print(f"  Retry failed: {e2}")
                    for orig in batch:
                        translations[orig] = orig
            
            if (i + batch_size) % 50 == 0:
                print(f"  Progress: {min(i+batch_size, len(ENGLISH_TEXTS))}/{len(ENGLISH_TEXTS)}")
                time.sleep(2)
        
        progress[lang_code] = translations
        save_progress(progress)
        print(f"  Done: {len(translations)} translations (saved)")
        time.sleep(3)
    
    with open('scripts/generated_translations.json', 'w', encoding='utf-8') as f:
        json.dump(progress, f, ensure_ascii=False, indent=2)
    
    print(f"\nAll done! Total: {len(progress)} languages")

if __name__ == '__main__':
    main()
