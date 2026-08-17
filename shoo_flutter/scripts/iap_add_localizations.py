#!/usr/bin/env python3
"""Add localizations to the Shoo Pro lifetime IAP item via App Store Connect API.
Note: IAP description field has a max of 55 characters."""
import jwt
import time
import json
import requests
import sys
import os

KEY_ID = "29HD53FFYV"
ISSUER_ID = "4b86ecb0-5c72-4d3a-81b8-e6d62a056467"
KEY_FILEPATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "fastlane", "AuthKey_29HD53FFYV.p8")
IAP_ID = "6802161206"

# All 11 localizations for the IAP item
# App Store Connect IAP description max = 55 characters
# Each entry: (locale, display_name, description)
IAP_LOCALIZATIONS = [
    ("zh-Hans", "Shoo Pro 永久解锁",
     "解锁全部动物声音与所有高级功能"),
    ("zh-Hant", "Shoo Pro 永久解鎖",
     "解鎖全部動物聲音與所有高級功能"),
    ("en-US", "Shoo Pro Lifetime Unlock",
     "Unlock all animal sounds and premium features"),
    ("ja", "Shoo Pro 永久解除",
     "全動物の音と全機能を永久的に解放"),
    ("ko", "Shoo Pro 영구 잠금 해제",
     "모든 동물 소리와 프리미엄 기능 잠금 해제"),
    ("fr-FR", "Shoo Pro Déblocage à vie",
     "Débloquer tous les sons et fonctionnalités"),
    ("de-DE", "Shoo Pro Lebensfreischaltung",
     "Alle Tierstimmen und Funktionen freischalten"),
    ("es-ES", "Shoo Pro Desbloqueo permanente",
     "Desbloquea todos los sonidos y funciones"),
    ("ru", "Shoo Pro Постоянная разблокировка",
     "Разблокировать все звуки и функции"),
    ("pt-BR", "Shoo Pro Desbloqueio vitalício",
     "Desbloqueie todos os sons e recursos"),
    ("th", "Shoo Pro ปลดล็อกถาวร",
     "ปลดล็อกเสียงและฟังก์ชั่นทั้งหมด"),
]


def create_jwt():
    with open(KEY_FILEPATH, "r") as f:
        private_key = f.read()
    payload = {
        "iss": ISSUER_ID,
        "iat": int(time.time()),
        "exp": int(time.time()) + 20 * 60,
        "aud": "appstoreconnect-v1",
    }
    headers = {"alg": "ES256", "kid": KEY_ID, "typ": "JWT"}
    return jwt.encode(payload, private_key, algorithm="ES256", headers=headers)


def add_localization(locale, name, description):
    # Verify description length
    desc_len = len(description)
    name_len = len(name)
    if desc_len > 55:
        print(f"  ✗ [{locale}] description too long ({desc_len} > 55 chars)")
        return False
    if name_len > 30:
        print(f"  ✗ [{locale}] name too long ({name_len} > 30 chars)")
        return False

    token = create_jwt()
    url = "https://api.appstoreconnect.apple.com/v1/inAppPurchaseLocalizations"
    payload = {
        "data": {
            "type": "inAppPurchaseLocalizations",
            "attributes": {
                "description": description,
                "name": name,
                "locale": locale,
            },
            "relationships": {
                "inAppPurchaseV2": {
                    "data": {
                        "type": "inAppPurchases",
                        "id": IAP_ID,
                    }
                }
            },
        }
    }
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json",
    }
    resp = requests.post(url, headers=headers, json=payload)
    status = "✓" if resp.status_code == 201 else "✗"
    print(f"  {status} [{locale}] {name} (name:{name_len}, desc:{desc_len}) → Status: {resp.status_code}")
    if resp.status_code != 201:
        try:
            error_detail = resp.json()
            print(f"    Error: {json.dumps(error_detail, indent=2, ensure_ascii=False)}")
        except Exception:
            print(f"    Response: {resp.text}")
    return resp.status_code == 201


def main():
    print(f"Adding IAP localizations for IAP ID: {IAP_ID}")
    print(f"Total localizations to add: {len(IAP_LOCALIZATIONS)}")
    print()

    # Verify all lengths first
    print("Validation check:")
    for locale, name, desc in IAP_LOCALIZATIONS:
        print(f"  [{locale}] name={len(name)}ch, desc={len(desc)}ch {'✓' if len(desc) <= 55 and len(name) <= 30 else '✗ TOO LONG'}")
    print()

    success_count = 0
    for locale, name, desc in IAP_LOCALIZATIONS:
        if add_localization(locale, name, desc):
            success_count += 1
        time.sleep(0.5)  # Rate limiting

    print()
    print(f"Done! {success_count}/{len(IAP_LOCALIZATIONS)} localizations added successfully.")

    if success_count == len(IAP_LOCALIZATIONS):
        print("\n🎉 All localizations added! The IAP state should now be READY_TO_SUBMIT.")
    elif success_count > 0:
        print("\n⚠️  Some localizations failed. Check the errors above and retry.")
    else:
        print("\n❌ All localizations failed. Check the errors above.")


if __name__ == "__main__":
    main()
