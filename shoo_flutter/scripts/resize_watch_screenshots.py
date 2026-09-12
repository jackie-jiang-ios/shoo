#!/usr/bin/env python3
"""Resize watch screenshots to 368x448 for Series 6 44mm"""
import os, glob
from PIL import Image

src_dir = 'fastlane/screenshots_watch'
dst_dir = 'fastlane/screenshots_watch_44mm'
os.makedirs(dst_dir, exist_ok=True)

for lang_dir in sorted(glob.glob(f'{src_dir}/*')):
    lang = os.path.basename(lang_dir)
    src_file = os.path.join(lang_dir, '01_Home.png')
    if not os.path.exists(src_file):
        continue
    img = Image.open(src_file)
    img = img.resize((368, 448), Image.LANCZOS)
    os.makedirs(f'{dst_dir}/{lang}', exist_ok=True)
    img.save(f'{dst_dir}/{lang}/01_Home.png')
    print(f'{lang}: {img.size}')

print('Done!')
