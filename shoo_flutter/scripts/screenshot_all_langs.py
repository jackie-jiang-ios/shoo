#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Batch screenshot script - All locales, 3 pages each (Home, Detail, Settings)
Saves screenshots directly to the project's fastlane/screenshots directory.
"""
import subprocess
import time
import os

# ===== Configuration =====
PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BUNDLE_ID = "com.yangshiqin.shoo"
APP_PATH = os.path.join(PROJECT_ROOT, "build", "ios", "iphonesimulator", "Runner.app")
OUTPUT_BASE = os.path.join(PROJECT_ROOT, "fastlane", "screenshots")
DEVICE_UDID = "D74FCB5D-1885-4A42-976D-B813CF6EB7E1"
DEVICE_NAME = "iPhone 17 Pro Max"

# Phone logical resolution
PHONE_W = 428
PHONE_H = 926

LOCALES = [
    ("zh-Hans", "zh-Hans", "zh_Hans_CN"),
]


def run(cmd, capture=True):
    return subprocess.run(cmd, shell=True, capture_output=capture, text=True)


def boot_simulator():
    result = run(f"xcrun simctl list devices | grep {DEVICE_UDID}")
    if "(Booted)" in result.stdout:
        return True
    print("  Booting simulator...")
    run(f"xcrun simctl boot {DEVICE_UDID}")
    time.sleep(3)
    return True


def install_app():
    print("  Installing app...")
    run(f"xcrun simctl install booted {APP_PATH}")


def get_sim_rect():
    """Get simulator window rect as (x, y, w, h) in screen points."""
    pos = run("osascript -e 'tell application \"System Events\" to tell process \"Simulator\" to get position of window 1'")
    size = run("osascript -e 'tell application \"System Events\" to tell process \"Simulator\" to get size of window 1'")
    try:
        p = pos.stdout.strip().replace("{", "").replace("}", "").split(",")
        s = size.stdout.strip().replace("{", "").replace("}", "").split(",")
        return int(p[0]), int(p[1]), int(s[0]), int(s[1])
    except:
        return 54, 30, 399, 850


def tap(phone_x, phone_y):
    """Tap at phone logical coordinates."""
    sx, sy, sw, sh = get_sim_rect()
    # Map phone coords to window coords
    win_x = (phone_x / PHONE_W) * sw
    win_y = (phone_y / PHONE_H) * sh
    # Convert to screen coords
    screen_x = sx + win_x
    screen_y = sy + win_y
    run(f'/usr/local/bin/cliclick c:{int(screen_x)},{int(screen_y)}')
    time.sleep(0.5)


def swipe(x1, y1, x2, y2):
    """Swipe on phone logical coordinates."""
    sx, sy, sw, sh = get_sim_rect()
    sx1 = sx + (x1 / PHONE_W) * sw
    sy1 = sy + (y1 / PHONE_H) * sh
    sx2 = sx + (x2 / PHONE_W) * sw
    sy2 = sy + (y2 / PHONE_H) * sh
    run(f'/usr/local/bin/cliclick dd:{int(sx1)},{int(sy1)}')
    time.sleep(0.1)
    run(f'/usr/local/bin/cliclick dm:{int(sx2)},{int(sy2)}')
    time.sleep(0.1)
    run(f'/usr/local/bin/cliclick du:{int(sx2)},{int(sy2)}')
    time.sleep(0.5)


def set_language(lang, locale_id):
    run(f'xcrun simctl spawn booted defaults write .GlobalPreferences AppleLanguages -array "{lang}"')
    run(f'xcrun simctl spawn booted defaults write .GlobalPreferences AppleLocale "{locale_id}"')


def terminate_app():
    run(f"xcrun simctl terminate booted {BUNDLE_ID} 2>/dev/null")


def launch_app():
    result = run(f"xcrun simctl launch booted {BUNDLE_ID}")
    return result.returncode == 0


def screenshot(path):
    result = run(f"xcrun simctl io booted screenshot {path}")
    time.sleep(0.5)  # Ensure write completes
    return result.returncode == 0


def process_locale(locale, lang, locale_id):
    output_dir = os.path.join(OUTPUT_BASE, locale)
    os.makedirs(output_dir, exist_ok=True)

    set_language(lang, locale_id)
    terminate_app()
    time.sleep(1)

    if not launch_app():
        print("    Launch FAILED", end="")
        return []

    # Wait for splash screen
    time.sleep(10)

    screenshots = []

    # 1. Home
    home_file = os.path.join(output_dir, "01_Home.png")
    print(" Loading...", end="", flush=True)
    if screenshot(home_file):
        screenshots.append("Home")
        print(" Home", end=" ", flush=True)

    # Tap first animal card (left column, first row)
    # Phone layout: nav 0~130, banner 130~210, tabs 210~280, grid 280+
    # First card center: x=107 (428/4 - margin), y=460
    time.sleep(2)
    tap(107, 460)
    time.sleep(3)

    # 2. Detail
    detail_file = os.path.join(output_dir, "02_Detail.png")
    if screenshot(detail_file):
        screenshots.append("Detail")
        print("Detail", end=" ", flush=True)

    # Close detail
    time.sleep(1)
    swipe(214, 400, 214, 800)
    time.sleep(2)

    # Settings
    tap(390, 145)
    time.sleep(3)

    # 3. Settings
    settings_file = os.path.join(output_dir, "03_Settings.png")
    if screenshot(settings_file):
        screenshots.append("Settings")
        print("Settings", end=" ", flush=True)

    return screenshots


def main():
    print("=" * 60)
    print("  Shoo Batch Screenshots")
    print(f"  Device: {DEVICE_NAME}")
    print(f"  Output: fastlane/screenshots/")
    print("=" * 60)
    print()

    boot_simulator()
    install_app()
    run('osascript -e \'tell application "Simulator" to activate\'')
    time.sleep(1)
    print()

    success = failed = total = 0

    for i, (locale, lang, locale_id) in enumerate(LOCALES):
        print(f"[{i+1:2d}/{len(LOCALES)}] {locale}: ", end="", flush=True)
        try:
            ss = process_locale(locale, lang, locale_id)
            print()
            if len(ss) == 3:
                success += 1
                total += 3
            else:
                failed += 1
                total += len(ss)
        except Exception as e:
            print(f" ERR: {e}")
            failed += 1

    print()
    print("=" * 60)
    print(f"  Done! {success} full / {failed} failed, {total} screenshots")
    print("=" * 60)


if __name__ == "__main__":
    main()
