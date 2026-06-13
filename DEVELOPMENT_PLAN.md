# 🛡️ 防兽神器（Shoo）- 全平台开发计划

> **最后更新**：2026-06-02  
> **当前阶段**：Phase 1 - MVP 手机端（进行中）

## 一、项目概述

|| 项目 | 内容 |
|------|------|
| **名称** | 防兽神器（Shoo） |
| **定位** | 用声音驱赶野兽的多平台应用 |
| **目标平台** | Android / iOS / 鸿蒙手机 + Apple Watch / Wear OS / 华为手表 |
| **核心功能** | 声音驱兽、定时播放、多声音混合、手表遥控 |
| **核心交互** | 按动物分类驱赶（非按声音分类），每种动物关联推荐声音 |

---

## 二、技术选型

### 2.1 各平台技术方案

|| 平台 | 技术方案 | 语言 | UI 框架 |
|------|---------|------|---------|
| **Android 手机** | Flutter | Dart | Flutter Widget |
| **iOS 手机** | Flutter | Dart | Flutter Widget |
| **鸿蒙手机** | ArkTS 原生 | ArkTS | ArkUI (声明式) |
| **Apple Watch** | 原生 | Swift | SwiftUI + WatchKit |
| **Wear OS 手表** | 原生 | Kotlin | Compose for Wear OS |
| **华为手表** | 原生 | ArkTS | ArkUI (声明式) |

### 2.2 核心依赖

|| 功能 | Flutter | Swift (Watch) | Kotlin (Wear) | ArkTS (鸿蒙) |
|------|---------|--------------|---------------|-------------|
| 音频播放 | just_audio | AVAudioPlayer | MediaPlayer | media.Library |
| 后台播放 | flutter_background_service | BGTaskScheduler | ForegroundService | BackgroundTask |
| 手机↔手表通信 | Platform Channel | WatchConnectivity | Wearable API | @ohos.wearengine |
| 状态管理 | Riverpod | @Observable | Compose State | @State |
| 本地存储 | shared_preferences + Hive | UserDefaults | DataStore | @ohos.data.preferences |
| 路由 | go_router | - | - | - |
| 国际化 | 自定义 S 类 (中/英) | - | - | - |

### 2.3 为什么这样选？

- **手机端用 Flutter**：一套代码覆盖 Android + iOS，开发效率翻倍；音频插件生态成熟
- **手表端各原生**：没有跨平台框架能同时支持三种手表系统，只能原生开发
- **鸿蒙原生 ArkTS**：Flutter 对鸿蒙适配尚不成熟，短期必须原生开发

---

## 三、项目结构

```
Shoo/
├── shoo_flutter/                  # 📱 Flutter 手机端 (Android + iOS)
│   ├── lib/
│   │   ├── main.dart              # 入口
│   │   ├── app.dart               # App配置 + 路由 + 国际化
│   │   ├── core/
│   │   │   ├── audio/
│   │   │   │   ├── audio_engine.dart         # 音频引擎核心
│   │   │   │   ├── audio_mixer.dart          # 多声音混合
│   │   │   │   └── ultrasonic_generator.dart  # 超声波生成（Platform Channel）
│   │   │   ├── timer/
│   │   │   │   └── play_scheduler.dart        # 定时播放调度
│   │   │   ├── storage/
│   │   │   │   └── preferences.dart           # 本地偏好存储
│   │   │   └── platform/
│   │   │       ├── platform_channel.dart      # 原生通道统一接口
│   │   │       ├── watch_channel.dart         # 手表通信通道
│   │   │       └── background_channel.dart    # 后台播放通道
│   │   ├── models/
│   │   │   ├── animal.dart                    # 🐾 动物模型 + 推荐声音
│   │   │   ├── sound.dart                     # 声音模型（兼容旧版）
│   │   │   ├── play_mode.dart                 # 播放模式 + 播放配置
│   │   │   └── watch_command.dart             # 手表通信协议
│   │   ├── features/
│   │   │   ├── home/
│   │   │   │   ├── home_page.dart             # 首页（智能推荐 + 动物列表 + 底部播放器）
│   │   │   │   └── widgets/
│   │   │   ├── sounds/
│   │   │   │   ├── sound_library_page.dart    # 声音库（按动物浏览）
│   │   │   │   ├── sound_player_page.dart     # 声音播放器
│   │   │   │   └── widgets/
│   │   │   ├── mixer/
│   │   │   │   ├── mixer_page.dart            # 声音混合
│   │   │   │   └── widgets/
│   │   │   ├── timer/
│   │   │   │   ├── timer_page.dart            # 定时播放
│   │   │   │   └── widgets/
│   │   │   ├── watch/
│   │   │   │   ├── watch_connect_page.dart    # 手表连接
│   │   │   │   └── widgets/
│   │   │   └── settings/
│   │   │       ├── settings_page.dart         # 设置
│   │   │       └── widgets/
│   │   ├── theme/
│   │   │   ├── app_theme.dart                 # 主题配置（亮/暗）
│   │   │   ├── colors.dart                    # 色彩系统
│   │   │   └── typography.dart                # 文字排版
│   │   └── l10n/
│   │       └── app_localizations.dart         # 国际化（中文/英文）
│   ├── assets/
│   │   ├── sounds/                            # 🔊 声音资源（待准备）
│   │   │   ├── ultrasonic/                    # 超声波
│   │   │   ├── animal/                        # 动物威慑声
│   │   │   ├── firecracker/                   # 炮仗声
│   │   │   ├── alarm/                         # 警报声
│   │   │   └── metal/                         # 金属撞击声
│   │   ├── images/
│   │   └── fonts/
│   ├── android/
│   ├── ios/
│   ├── macos/
│   ├── web/
│   ├── test/
│   └── pubspec.yaml
│
├── shoo_watch_os/                 # ⌚ Apple Watch (SwiftUI) — Phase 2
├── shoo_wear_os/                  # ⌚ Wear OS (Kotlin + Compose) — Phase 3
├── shoo_harmony/                  # 📱 鸿蒙手机 + ⌚ 华为手表 — Phase 4
│
├── shared/                        # 🔗 共享资源与协议
│   ├── sounds/                    # 统一声音资源文件（待准备）
│   │   ├── ultrasonic/
│   │   ├── animal/
│   │   ├── firecracker/
│   │   ├── alarm/
│   │   └── metal/
│   └── protocol/
│       └── watch_protocol.json    # 手机↔手表统一通信协议定义
│
└── docs/
    ├── DEVELOPMENT_PLAN.md        # 本文档
    ├── 动物驱赶功能设计 (1).vue   # 原始设计稿
    └── ...
```

---

## 四、手机↔手表通信协议

所有平台的手表通信统一使用以下 JSON 协议：

### 4.1 手机 → 手表

```json
// 播放命令
{
  "type": "play",
  "animalId": "wild_dog",
  "soundId": "tiger_roar",
  "volume": 0.8,
  "mode": "continuous"   // continuous | interval
}

// 停止命令
{
  "type": "stop",
  "soundId": "tiger_roar"
}

// 停止所有
{
  "type": "stop_all"
}

// 同步动物+声音列表
{
  "type": "sync_animals",
  "animals": [
    { "id": "wild_dog", "name": "野狗", "nameEn": "Wild Dog", "category": "beast",
      "sounds": [
        { "id": "tiger_roar", "name": "虎啸声", "rating": 5 },
        { "id": "lion_roar", "name": "狮吼声", "rating": 4 }
      ]
    }
  ]
}
```

### 4.2 手表 → 手机

```json
// 遥控播放（选择动物驱赶）
{
  "type": "remote_play",
  "animalId": "wild_dog",
  "soundId": "tiger_roar",
  "volume": 0.8
}

// 状态上报
{
  "type": "status",
  "playing": true,
  "animalId": "wild_dog",
  "soundId": "tiger_roar",
  "elapsed": 12.5
}

// 紧急求救（手表快速触发）
{
  "type": "emergency",
  "soundIds": ["siren", "gunshot"],
  "volume": 1.0
}
```

---

## 五、动物与声音库规划

### 5.1 按动物分类驱赶（核心交互）

> 💡 设计原则：用户按"遇到什么动物"来选择驱赶方式，而非按"有什么声音"来选择。

|| 分类 | 动物 | 最佳克制声音 | 备选声音 |
|------|------|-------------|---------|
| 🦁 猛兽威胁 | 野狗 | ⭐⭐⭐⭐⭐ 虎啸声 | ⭐⭐⭐⭐ 狮吼声、⭐⭐⭐ 猎豹叫声 |
| 🦁 猛兽威胁 | 野猪 | ⭐⭐⭐⭐⭐ 狮子吼叫 | ⭐⭐⭐⭐ 大象怒吼、⭐⭐⭐ 人群呐喊 |
| 🦁 猛兽威胁 | 熊 | ⭐⭐⭐⭐⭐ 枪声模拟 | ⭐⭐⭐⭐ 人群呐喊、⭐⭐⭐ 金属撞击 |
| 🦁 猛兽威胁 | 狼 | ⭐⭐⭐⭐⭐ 狼嚎声 | ⭐⭐⭐⭐ 枪声、⭐⭐⭐ 篝火爆裂声 |
| 🦁 猛兽威胁 | 狐狸 | ⭐⭐⭐⭐⭐ 狗吠声 | ⭐⭐⭐⭐ 枪声、⭐⭐⭐ 金属碰撞声 |
| 🐍 爬行类 | 毒蛇 | ⭐⭐⭐⭐⭐ 雄鸡啼鸣 | ⭐⭐⭐⭐ 獴叫声、⭐⭐⭐ 割草机震动声 |
| 🐒 灵长类 | 猴子 | ⭐⭐⭐⭐⭐ 鹰啸声 | ⭐⭐⭐⭐ 猎犬吠叫、⭐⭐⭐ 尖锐哨声 |
| 🐭 啮齿类 | 老鼠 | ⭐⭐⭐⭐⭐ 猫叫声 | ⭐⭐⭐⭐ 超声波、⭐⭐⭐ 拍打声 |
| 🐭 啮齿类 | 野兔 | ⭐⭐⭐⭐⭐ 猎犬吠叫 | ⭐⭐⭐⭐ 鹰啸声、⭐⭐⭐ 脚步声 |
| 🐛 昆虫类 | 毒蜘蛛 | ⭐⭐⭐⭐⭐ 高频震动声 | ⭐⭐⭐⭐ 扫帚清扫声、⭐⭐⭐ 敲击声 |
| 🐛 昆虫类 | 马蜂 | ⭐⭐⭐⭐⭐ 低频声波 | ⭐⭐⭐⭐ 喷雾剂声、⭐⭐⭐ 风声 |
| 🦅 鸟类 | 乌鸦 | ⭐⭐⭐⭐⭐ 鹰啸声 | ⭐⭐⭐⭐ 枪声、⭐⭐⭐ 哨子声 |

### 5.2 声音来源

| 声音类型 | 来源方案 | 说明 |
|---------|---------|------|
| 动物威慑声 | 购买商用音效库 / AI 生成 | 虎啸、狮吼、鹰啸等 |
| 超声波 | 程序合成（UltrasonicGenerator） | 18/20/22kHz |
| 炮仗/枪声 | 购买商用音效库 / AI 生成 | 枪声模拟、炮仗 |
| 警报/人群 | 购买商用音效库 / AI 生成 | 警报、呐喊 |
| 金属撞击 | 购买商用音效库 / 实地录制 | 锣声、铁桶 |
| 其他 | AI 生成 + 编辑 | 猫叫、鸡鸣、脚步声等 |

---

## 六、功能清单

### 6.1 MVP（第一阶段）— 手机端核心

|| # | 功能 | 优先级 | 状态 | 说明 |
|---|------|--------|------|------|
| 1 | 动物驱赶首页 | P0 | ✅ 已完成 | 智能推荐 + 动物列表 + 底部播放器 |
| 2 | 动物详情弹窗 | P0 | ✅ 已完成 | 推荐声音 + 星级评分 + 播放 |
| 3 | 分类筛选 | P0 | ✅ 已完成 | 猛兽/爬行/灵长/啮齿/昆虫/鸟类 |
| 4 | 声音播放 | P0 | 🔧 框架完成 | 播放/停止/暂停（待接入真实音频资源） |
| 5 | 音量控制 | P0 | ✅ 已完成 | 滑块调节 |
| 6 | 播放模式 | P0 | ✅ 已完成 | 持续/间隔两种模式 |
| 7 | 国际化（中/英） | P0 | ✅ 已完成 | 所有文案中英双语 |
| 8 | 后台播放 | P0 | 🔧 框架完成 | 需接入 flutter_background_service |
| 9 | 超声波播放 | P1 | 🔧 框架完成 | UltrasonicGenerator + iOS 原生实现 |
| 10 | 多声音混合 | P1 | ✅ 已完成 | 同时播放多种声音 |
| 11 | 定时关闭 | P1 | ✅ 已完成 | 预设 + 自定义时长 |
| 12 | 收藏动物/声音 | P2 | 📝 待开发 | 快速访问常用动物 |
| 13 | App 图标 | P0 | 📝 待开发 | 动态图标（按模式切换） |
| 14 | 声音资源准备 | P0 | 📝 待开发 | 12种动物的推荐声音 MP3 |

### 6.2 第二阶段 — Apple Watch

|| # | 功能 | 优先级 | 状态 | 说明 |
|---|------|--------|------|------|
| 15 | 手表遥控驱赶 | P0 | 📝 待开发 | 手表端选择动物+声音播放 |
| 16 | 手机配对 | P0 | 📝 待开发 | WatchConnectivity 配对 |
| 17 | 紧急按钮 | P0 | 📝 待开发 | 一键播放最大音量警报 |
| 18 | 触觉反馈 | P1 | 📝 待开发 | 播放时手表振动 |
| 19 | 表盘小组件 | P2 | 📝 待开发 | 快速启动入口 |
| 20 | 独立播放 | P2 | 📝 待开发 | 不连手机也能播放 |

### 6.3 第三阶段 — Wear OS

|| # | 功能 | 优先级 | 状态 | 说明 |
|---|------|--------|------|------|
| 21 | Wear OS 遥控驱赶 | P0 | 📝 待开发 | 手表端选择动物+播放 |
| 22 | 手机配对 | P0 | 📝 待开发 | Wearable API 配对 |
| 23 | 紧急按钮 | P0 | 📝 待开发 | 一键最大音量警报 |
| 24 | 独立播放 | P1 | 📝 待开发 | 手表本地播放 |

### 6.4 第四阶段 — 鸿蒙全平台

|| # | 功能 | 优先级 | 状态 | 说明 |
|---|------|--------|------|------|
| 25 | 鸿蒙手机端 | P0 | 📝 待开发 | 完整手机端功能 |
| 26 | 华为手表配对 | P0 | 📝 待开发 | 鸿蒙手表遥控播放 |
| 27 | 华为手表独立播放 | P1 | 📝 待开发 | 手表本地播放 |
| 28 | 鸿蒙元服务卡片 | P2 | 📝 待开发 | 桌面快速启动卡片 |

---

## 七、开发里程碑

### Phase 1：MVP 手机端（4 周）

|| 周次 | 任务 | 交付物 | 状态 |
|------|------|--------|------|
| W1 | Flutter 项目搭建 + 数据模型 + 主题 + 国际化 | 项目骨架 + 所有页面 | ✅ 完成 |
| W2 | 声音资源准备 + 音频引擎接入 + 播放器完善 | 可真实播放声音的原型 | 🔧 进行中 |
| W3 | 后台播放 + 超声波合成 + 多声音混合 | 高级音频功能 | 📝 待开始 |
| W4 | App 图标 + UI 美化 + 收藏 + 测试 | MVP 可发布版本 | 📝 待开始 |

### Phase 2：Apple Watch 版（3 周）

|| 周次 | 任务 | 交付物 | 状态 |
|------|------|--------|------|
| W5 | Watch 项目搭建 + WatchConnectivity | 手表可配对手机 | 📝 待开始 |
| W6 | 手表遥控驱赶 + 紧急按钮 + 触觉反馈 | 功能完整手表端 | 📝 待开始 |
| W7 | 表盘小组件 + 独立播放 + 测试 | Watch 可发布版本 | 📝 待开始 |

### Phase 3：Wear OS 版（3 周）

|| 周次 | 任务 | 交付物 | 状态 |
|------|------|--------|------|
| W8 | Wear OS 项目搭建 + Wearable API 配对 | 手表可配对手机 | 📝 待开始 |
| W9 | 手表遥控驱赶 + 紧急按钮 | 功能完整手表端 | 📝 待开始 |
| W10 | 独立播放 + 测试 | Wear OS 可发布版本 | 📝 待开始 |

### Phase 4：鸿蒙全平台（4 周）

|| 周次 | 任务 | 交付物 | 状态 |
|------|------|--------|------|
| W11 | 鸿蒙手机端搭建 + 音频播放 | 鸿蒙手机可播放声音 | 📝 待开始 |
| W12 | 鸿蒙手机端完整功能 | 鸿蒙手机功能完整 | 📝 待开始 |
| W13 | 华为手表端 + 配对通信 | 华为手表可遥控 | 📝 待开始 |
| W14 | 元服务卡片 + 全平台联调测试 | 鸿蒙全平台发布 | 📝 待开始 |

---

## 八、开发环境

### 8.1 当前环境

|| 工具 | 版本 | 状态 |
|------|------|------|
| Flutter SDK | 3.44.1 (stable) | ✅ 已安装 |
| Dart SDK | 3.12.1 | ✅ 已安装 |
| Xcode | - | ✅ 可用 |
| Chrome | 148.0 | ✅ 可用（Web 调试） |
| macOS | 26.1 | ✅ 可用（桌面调试） |

### 8.2 必装工具（后续阶段）

|| 工具 | 用途 | 需要阶段 |
|------|------|---------|
| Android Studio | Android + Wear OS 开发 | Phase 1 (APK) / Phase 3 |
| DevEco Studio | 鸿蒙手机 + 华为手表开发 | Phase 4 |

### 8.3 可选工具

|| 工具 | 用途 |
|------|------|
| Figma | UI/UX 设计 |
| Audacity | 声音编辑处理 |

---

## 九、风险与对策

|| 风险 | 影响 | 对策 |
|------|------|------|
| 超声波在某些设备上无法播放 | 核心功能受限 | 提前测试主流设备，备选可听频段方案 |
| 后台播放被系统杀掉 | 播放中断 | 各平台单独优化保活策略，添加前台通知 |
| 手表端音量太小 | 驱兽效果差 | 手表端优先遥控手机播放，独立播放仅做辅助 |
| Flutter 鸿蒙适配不成熟 | 无法一套代码覆盖鸿蒙 | 短期用 ArkTS 原生开发鸿蒙端 |
| 声音资源版权问题 | 上架审核风险 | 使用商用授权音效库或 AI 生成 |
| Apple Watch 存储有限 | 无法存放大量声音 | 默认仅同步 3-5 个核心声音，其余按需下载 |
| 动物驱赶效果验证不足 | 用户信任度低 | 收集学术/实测数据，标注推荐指数依据 |

---

## 十、上架计划

|| 平台 | 应用商店 | 预计时间 |
|------|---------|---------|
| iOS | App Store | Phase 1 完成后 |
| Android | Google Play + 国内应用市场 | Phase 1 完成后 |
| Apple Watch | App Store（随 iOS 应用） | Phase 2 完成后 |
| Wear OS | Google Play（随 Android 应用） | Phase 3 完成后 |
| 鸿蒙 | 华为应用市场 | Phase 4 完成后 |
| 华为手表 | 华为应用市场（随鸿蒙应用） | Phase 4 完成后 |

---

## 十一、Phase 1 进度详情

### ✅ 已完成

- [x] Flutter SDK 安装（3.44.1 stable）
- [x] Flutter 项目创建 + 平台支持（Android / iOS / macOS / Web）
- [x] 项目目录结构搭建
- [x] 数据模型设计（动物模型 + 推荐声音 + 播放模式）
- [x] 主题系统（亮/暗 + 分类色彩 + 文字排版）
- [x] 国际化系统（中/英完整双语）
- [x] 首页（智能推荐 + 动物分类列表 + 底部播放控制）
- [x] 动物详情弹窗（推荐声音 + ⭐星级评分 + 播放按钮）
- [x] 声音播放器页面（音量 + 播放模式 + 声音选择）
- [x] 多声音混合页面
- [x] 定时播放页面
- [x] 手表连接页面
- [x] 设置页面
- [x] 音频引擎核心框架
- [x] 超声波生成器（PCM/WAV 合成）
- [x] 音频混合器框架
- [x] 定时播放调度器
- [x] 本地偏好存储
- [x] 原生 Platform Channel 接口（音频/手表/后台）
- [x] iOS 原生超声波播放（AppDelegate.swift）
- [x] Android 原生通道（MainActivity.kt）
- [x] 手表通信协议定义
- [x] 路由系统（go_router + ShellRoute + 底部导航）

### 🔧 进行中

- [ ] 声音资源文件准备（MP3 音效）
- [ ] 音频引擎接入真实音频资源
- [ ] 后台播放服务完善
- [ ] App 图标配置

### 📝 待开始

- [ ] 收藏动物/声音功能
- [ ] 播放历史
- [ ] 智能推荐算法（时段/季节/地区）
- [ ] iOS 上架配置（签名/证书/截图）
- [ ] Android 上架配置（签名/混淆/多渠道）
- [ ] 完整测试用例
- [ ] 性能优化
