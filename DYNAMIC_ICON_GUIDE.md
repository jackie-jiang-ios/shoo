# 🛡️ 防兽神器 - 动态图标切换方案

## 一、设计理念

用户选择不同驱兽场景时，APP图标自动切换为对应的主题图标：

| 场景 | 图标主题 | 主色调 | 动物元素 |
|------|---------|--------|---------|
| 🛡️ 通用 | 盾牌+声波 | 深蓝绿 + 金黄 | 无 |
| 🐕 防狗 | 狗剪影+禁止 | 深红棕 + 红橙 | 狗+禁止标 |
| 🐗 防野猪 | 猪剪影+禁止 | 深棕 + 土黄 | 野猪+獠牙 |
| 🐍 防蛇 | 蛇剪影+禁止 | 深绿 + 亮绿 | 蛇+蛇信 |
| 🐺 防狼 | 狼剪影+禁止 | 深灰蓝 + 蓝白 | 狼+尖耳 |
| 🐻 防熊 | 熊剪影+禁止 | 深褐 + 橙色 | 熊+圆耳 |
| 🐵 防猴 | 猴剪影+禁止 | 深青 + 金黄 | 猴+卷尾 |

---

## 二、各平台实现方案

### 2.1 iOS 实现（支持动态图标切换 ✅）

iOS 10.3+ 原生支持动态图标切换，这是最成熟的方案。

#### Info.plist 配置

```xml
<key>CFBundleIcons</key>
<dict>
    <key>CFBundlePrimaryIcon</key>
    <dict>
        <key>CFBundleIconFiles</key>
        <array>
            <string>icon_universal</string>
        </array>
    </dict>
    <key>CFBundleAlternateIcons</key>
    <dict>
        <key>dog</key>
        <dict>
            <key>CFBundleIconFiles</key>
            <array>
                <string>icon_dog</string>
            </array>
        </dict>
        <key>pig</key>
        <dict>
            <key>CFBundleIconFiles</key>
            <array>
                <string>icon_pig</string>
            </array>
        </dict>
        <key>snake</key>
        <dict>
            <key>CFBundleIconFiles</key>
            <array>
                <string>icon_snake</string>
            </array>
        </dict>
        <key>wolf</key>
        <dict>
            <key>CFBundleIconFiles</key>
            <array>
                <string>icon_wolf</string>
            </array>
        </dict>
        <key>bear</key>
        <dict>
            <key>CFBundleIconFiles</key>
            <array>
                <string>icon_bear</string>
            </array>
        </dict>
        <key>monkey</key>
        <dict>
            <key>CFBundleIconFiles</key>
            <array>
                <string>icon_monkey</string>
            </array>
        </dict>
    </dict>
</dict>
```

#### Swift 切换代码

```swift
import UIKit

class IconManager {
    
    enum AnimalMode: String, CaseIterable {
        case universal = ""      // 默认图标，不需要设置
        case dog = "dog"
        case pig = "pig"
        case snake = "snake"
        case wolf = "wolf"
        case bear = "bear"
        case monkey = "monkey"
    }
    
    static let shared = IconManager()
    private let savedModeKey = "selectedAnimalMode"
    
    var currentMode: AnimalMode {
        get {
            if let saved = UserDefaults.standard.string(forKey: savedModeKey),
               let mode = AnimalMode(rawValue: saved) {
                return mode
            }
            return .universal
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: savedModeKey)
        }
    }
    
    /// 切换APP图标
    /// - Parameter mode: 动物模式
    /// - Parameter completion: 完成回调 (success, error)
    func switchIcon(to mode: AnimalMode, completion: @escaping (Bool, Error?) -> Void) {
        // 检查是否支持动态图标
        guard UIApplication.shared.supportsAlternateIcons else {
            completion(false, NSError(domain: "IconManager", code: -1, 
                                     userInfo: [NSLocalizedDescriptionKey: "当前系统不支持动态图标"]))
            return
        }
        
        let iconName: String? = mode == .universal ? nil : mode.rawValue
        
        UIApplication.shared.setAlternateIconName(iconName) { [weak self] error in
            if let error = error {
                completion(false, error)
            } else {
                self?.currentMode = mode
                completion(true, nil)
            }
        }
    }
}

// 使用示例
IconManager.shared.switchIcon(to: .dog) { success, error in
    if success {
        print("图标切换成功！")
    } else {
        print("图标切换失败：\(error?.localizedDescription ?? "")")
    }
}
```

---

### 2.2 Android 实现（Activity别名方案 ✅）

Android 通过配置多个 `<activity-alias>` 实现图标切换。

#### AndroidManifest.xml

```xml
<application
    android:enableOnBackInvokedCallback="true"
    ...>
    
    <!-- 默认启动入口（通用图标） -->
    <activity-alias
        android:name=".MainUniversal"
        android:enabled="true"
        android:icon="@mipmap/icon_universal"
        android:label="防兽神器"
        android:targetActivity=".MainActivity">
        <intent-filter>
            <action android:name="android.intent.action.MAIN" />
            <category android:name="android.intent.category.LAUNCHER" />
        </intent-filter>
    </activity-alias>

    <!-- 防狗模式入口 -->
    <activity-alias
        android:name=".MainDog"
        android:enabled="false"
        android:icon="@mipmap/icon_dog"
        android:label="防兽神器-防狗"
        android:targetActivity=".MainActivity">
        <intent-filter>
            <action android:name="android.intent.action.MAIN" />
            <category android:name="android.intent.category.LAUNCHER" />
        </intent-filter>
    </activity-alias>

    <!-- 防野猪模式入口 -->
    <activity-alias
        android:name=".MainPig"
        android:enabled="false"
        android:icon="@mipmap/icon_pig"
        android:label="防兽神器-防猪"
        android:targetActivity=".MainActivity">
        <intent-filter>
            <action android:name="android.intent.action.MAIN" />
            <category android:name="android.intent.category.LAUNCHER" />
        </intent-filter>
    </activity-alias>

    <!-- 其他模式类似添加... -->
    
</application>
```

#### Kotlin 切换代码

```kotlin
class IconManager(private val context: Context) {
    
    enum class AnimalMode(val alias: String) {
        UNIVERSAL(".MainUniversal"),
        DOG(".MainDog"),
        PIG(".MainPig"),
        SNAKE(".MainSnake"),
        WOLF(".MainWolf"),
        BEAR(".MainBear"),
        MONKEY(".MainMonkey")
    }
    
    private val prefs = context.getSharedPreferences("icon_prefs", Context.MODE_PRIVATE)
    
    var currentMode: AnimalMode
        get() = AnimalMode.valueOf(prefs.getString("mode", AnimalMode.UNIVERSAL.name)!!)
        set(value) = prefs.edit().putString("mode", value.name).apply()
    
    fun switchIcon(to mode: AnimalMode) {
        val packageName = context.packageName
        val pm = context.packageManager
        
        // 禁用当前别名
        pm.setComponentEnabledSetting(
            ComponentName(packageName, packageName + currentMode.alias),
            PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
            PackageManager.DONT_KILL_APP
        )
        
        // 启用新别名
        pm.setComponentEnabledSetting(
            ComponentName(packageName, packageName + mode.alias),
            PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
            PackageManager.DONT_KILL_APP
        )
        
        currentMode = mode
    }
}

// 使用示例
val iconManager = IconManager(context)
iconManager.switchIcon(to = IconManager.AnimalMode.DOG)
```

---

### 2.3 Flutter 实现（跨平台统一接口）

```dart
import 'package:flutter/services.dart';

enum AnimalMode {
  universal,
  dog,
  pig,
  snake,
  wolf,
  bear,
  monkey,
}

class IconManager {
  static const _channel = MethodChannel('com.shoo.app/icon');
  
  static final IconManager _instance = IconManager._();
  factory IconManager() => _instance;
  IconManager._();

  AnimalMode _currentMode = AnimalMode.universal;
  AnimalMode get currentMode => _currentMode;

  /// 切换APP图标
  Future<bool> switchIcon(AnimalMode mode) async {
    try {
      final result = await _channel.invokeMethod<bool>('switchIcon', {
        'mode': mode.name,
      });
      if (result == true) {
        _currentMode = mode;
      }
      return result ?? false;
    } on PlatformException catch (e) {
      print('图标切换失败: ${e.message}');
      return false;
    }
  }
}

// 使用示例
await IconManager().switchIcon(AnimalMode.dog);
```

---

### 2.4 鸿蒙实现（ArkTS）

鸿蒙目前不直接支持动态图标切换，可采用以下替代方案：

| 方案 | 说明 | 推荐度 |
|------|------|--------|
| 桌面卡片 | 不同模式提供不同的服务卡片（Widget），卡片图标不同 | ⭐⭐⭐ |
| 快捷方式 | 长按APP弹出不同模式的快捷入口 | ⭐⭐ |
| 统一图标 | 鸿蒙端使用通用图标，不做切换 | ⭐ |

---

### 2.5 各手表平台

手表端图标空间极小，建议：

| 平台 | 方案 |
|------|------|
| Apple Watch | 使用 Complication 显示当前模式图标 |
| Wear OS | 不支持动态图标，使用通用图标 |
| 华为手表 | 通过表盘卡片展示当前模式 |

---

## 三、用户体验设计

### 3.1 切换流程

```
用户选择「防狗模式」
    ↓
弹出确认：「是否切换APP图标为防狗模式？」
    ↓  是
调用系统API切换图标
    ↓
系统弹出提示：「您已更改APP图标」（iOS系统自带提示）
    ↓
图标切换完成，桌面图标变为防狗主题
```

### 3.2 切换时机

| 时机 | 行为 |
|------|------|
| 用户主动切换模式 | 弹窗确认后切换图标 |
| APP启动时 | 读取存储的模式，如果图标不一致则静默同步 |
| 紧急模式触发 | 不切换图标（避免延迟） |

### 3.3 注意事项

| 平台 | 限制 |
|------|------|
| **iOS** | 切换时系统会弹出提示；需审核时说明动态图标功能；图标需全部包含在APP包内 |
| **Android** | 切换时桌面可能有短暂闪烁；部分 Launcher 不支持；需 DONT_KILL_APP 避免重启 |
| **鸿蒙** | 不直接支持动态图标切换 |

---

## 四、图标资源清单

### 已生成图标

```
assets/icons/
├── universal/          # 🛡️ 通用模式
│   ├── icon_universal_1024.png
│   ├── icon_universal_512.png
│   ├── icon_universal_180.png   ← iOS @3x
│   ├── icon_universal_120.png   ← iOS @2x
│   └── ...其他尺寸
├── dog/                # 🐕 防狗模式
├── pig/                # 🐗 防野猪模式
├── snake/              # 🐍 防蛇模式
├── wolf/               # 🐺 防狼模式
├── bear/               # 🐻 防熊模式
├── monkey/             # 🐵 防猴模式
└── preview_all.png     # 预览拼图
```

### 各平台所需尺寸

| 平台 | 尺寸(px) | 用途 |
|------|---------|------|
| iOS | 1024×1024 | App Store |
| iOS | 180×180 | iPhone @3x |
| iOS | 120×120 | iPhone @2x |
| iOS | 87×87 | iPad Pro @3x |
| iOS | 80×80 | iPad @2x |
| iOS | 58×58 | iPhone Spotlight @2x |
| iOS | 29×29 | Settings @2x |
| Android | 512×512 | Google Play |
| Android | 192×192 | xxxhdpi |
| Android | 144×144 | xxhdpi |
| Android | 96×96 | xhdpi |
| Android | 72×72 | hdpi |
| Android | 48×48 | mdpi |
| 鸿蒙 | 216×216 | 大图标 |
| 鸿蒙 | 108×108 | 小图标 |
