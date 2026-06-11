#!/bin/bash

# ============================================================
#  防兽神器 - 多平台运行脚本
#  用法: ./run.sh [平台] [选项]
#
#  平台:
#    ios          运行到 iOS 模拟器（默认）
#    android      运行到 Android 模拟器
#    macos        运行到 macOS 桌面
#    web / h5     运行到 Web 浏览器 (Chrome)
#    watch        运行到 Apple Watch 模拟器
#    real         运行到真机（需连接设备）
#
#  选项:
#    --release    以 release 模式运行
#    --profile    以 profile 模式运行
#    --clean      运行前先 flutter clean
#    --verbose    详细日志输出
#    -h / --help  显示帮助
#
#  示例:
#    ./run.sh              # 默认 iOS 模拟器
#    ./run.sh ios          # iOS 模拟器
#    ./run.sh android      # Android 模拟器
#    ./run.sh web          # Web (Chrome)
#    ./run.sh h5           # Web (Chrome)
#    ./run.sh macos        # macOS
#    ./run.sh watch        # Apple Watch
#    ./run.sh real         # 真机
#    ./run.sh ios --release --clean
# ============================================================

set -e

FLUTTER="/Users/jiangzheng/flutter/bin/flutter"
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR"

# ─── 颜色 ───
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# ─── 帮助信息 ───
show_help() {
    head -30 "$0" | tail -28 | sed 's/^# \?//' | sed "s/\\$/  ./run.sh/"
    exit 0
}

# ─── 解析参数 ───
PLATFORM=""
BUILD_MODE=""
EXTRA_FLAGS=""
NEED_CLEAN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        ios|android|macos|web|h5|watch|real)
            PLATFORM="$1"
            ;;
        --release)
            BUILD_MODE="--release"
            ;;
        --profile)
            BUILD_MODE="--profile"
            ;;
        --clean)
            NEED_CLEAN=true
            ;;
        --verbose)
            EXTRA_FLAGS="$EXTRA_FLAGS --verbose"
            ;;
        -h|--help)
            show_help
            ;;
        *)
            echo -e "${RED}❌ 未知参数: $1${NC}"
            echo "运行 ./run.sh --help 查看帮助"
            exit 1
            ;;
    esac
    shift
done

# 默认平台
if [ -z "$PLATFORM" ]; then
    PLATFORM="ios"
fi

# ─── 清理 ───
if [ "$NEED_CLEAN" = true ]; then
    echo -e "${YELLOW}🧹 执行 flutter clean...${NC}"
    $FLUTTER clean
    echo -e "${YELLOW}📦 重新获取依赖...${NC}"
    $FLUTTER pub get
fi

# ─── 确保 pub get ───
if [ ! -d ".dart_tool" ]; then
    echo -e "${CYAN}📦 获取依赖...${NC}"
    $FLUTTER pub get
fi

# ─── 平台处理 ───
run_ios() {
    echo -e "${BLUE}📱 正在准备 iOS 模拟器...${NC}"

    # 检查模拟器是否已启动
    if ! xcrun simctl list devices | grep -q "Booted"; then
        echo -e "${YELLOW}📱 未检测到已启动的模拟器，正在启动 iOS Simulator...${NC}"
        open -a Simulator
        echo -e "${YELLOW}⏳ 等待模拟器启动...${NC}"
        sleep 8
    fi

    # 获取模拟器设备 ID
    DEVICE_ID=$($FLUTTER devices 2>/dev/null | grep -m1 "simulator" | grep -oE '[A-F0-9]{8}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{12}')

    if [ -z "$DEVICE_ID" ]; then
        echo -e "${RED}❌ 未找到可用的 iOS 模拟器${NC}"
        echo "   请检查 Xcode 和模拟器是否正确安装"
        echo "   提示: 可在 Xcode > Window > Devices 中创建模拟器"
        exit 1
    fi

    # 获取模拟器名称
    DEVICE_NAME=$($FLUTTER devices 2>/dev/null | grep "$DEVICE_ID" | sed 's/(.*//' | xargs)

    echo -e "${GREEN}🚀 运行到 iOS 模拟器: ${BOLD}$DEVICE_NAME${NC}"
    $FLUTTER run -d "$DEVICE_ID" $BUILD_MODE $EXTRA_FLAGS
}

run_android() {
    echo -e "${GREEN}🤖 正在准备 Android 模拟器...${NC}"

    # 检查是否有 Android 模拟器或设备
    ANDROID_DEVICE=$($FLUTTER devices 2>/dev/null | grep -m1 "android" | grep -oE 'emulator-\S+|\S+\.android')

    if [ -z "$ANDROID_DEVICE" ]; then
        # 尝试启动模拟器
        echo -e "${YELLOW}🤖 未检测到 Android 设备，尝试启动模拟器...${NC}"
        EMULATOR_ID=$($FLUTTER emulators 2>/dev/null | grep -m1 "android" | awk '{print $2}')

        if [ -n "$EMULATOR_ID" ]; then
            echo -e "${CYAN}🤖 启动模拟器: $EMULATOR_ID${NC}"
            $FLUTTER emulators --launch "$EMULATOR_ID" 2>/dev/null || true
            echo -e "${YELLOW}⏳ 等待模拟器启动...${NC}"
            sleep 15
        else
            echo -e "${RED}❌ 未找到 Android 模拟器${NC}"
            echo "   请先在 Android Studio 中创建 AVD 模拟器"
            echo "   或通过 flutter emulators --create 创建"
            exit 1
        fi
    fi

    echo -e "${GREEN}🚀 运行到 Android 设备/模拟器${NC}"
    $FLUTTER run -d android $BUILD_MODE $EXTRA_FLAGS
}

run_macos() {
    echo -e "${GREEN}🖥️  运行到 macOS 桌面${NC}"
    $FLUTTER run -d macos $BUILD_MODE $EXTRA_FLAGS
}

run_web() {
    echo -e "${GREEN}🌐 运行到 Web (Chrome)${NC}"
    $FLUTTER run -d chrome $BUILD_MODE $EXTRA_FLAGS \
        --web-port=8080 \
        --web-hostname=localhost
}

run_watch() {
    echo -e "${BLUE}⌚ 正在准备 Apple Watch 模拟器...${NC}"

    # 检查 watchOS 模拟器
    WATCH_DEVICE=$($FLUTTER devices 2>/dev/null | grep -m1 "Watch" | grep -oE '[A-F0-9]{8}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{12}')

    if [ -z "$WATCH_DEVICE" ]; then
        echo -e "${YELLOW}⌚ 未检测到 Apple Watch 模拟器，正在尝试启动...${NC}"

        # 查找 Watch 模拟器 runtime
        WATCH_RUNTIME=$(xcrun simctl list runtimes 2>/dev/null | grep -m1 "watchOS" | awk '{print $NF}')

        if [ -z "$WATCH_RUNTIME" ]; then
            echo -e "${RED}❌ 未找到 watchOS Runtime${NC}"
            echo "   请在 Xcode > Settings > Platforms 中下载 watchOS 模拟器 Runtime"
            exit 1
        fi

        # 查找 Watch 设备类型
        WATCH_TYPE=$(xcrun simctl list devicetypes 2>/dev/null | grep -m1 "Apple Watch" | awk '{print $1}' | tr -d ':')

        if [ -n "$WATCH_TYPE" ]; then
            echo -e "${CYAN}⌚ 创建并启动 Apple Watch 模拟器...${NC}"
            WATCH_UUID=$(xcrun simctl create "Apple Watch for Shoo" "$WATCH_TYPE" "$WATCH_RUNTIME" 2>/dev/null || true)
            if [ -n "$WATCH_UUID" ]; then
                xcrun simctl boot "$WATCH_UUID" 2>/dev/null || true
                sleep 5
                WATCH_DEVICE="$WATCH_UUID"
            fi
        fi
    fi

    if [ -z "$WATCH_DEVICE" ]; then
        echo -e "${RED}❌ 无法启动 Apple Watch 模拟器${NC}"
        echo "   请确保已安装 watchOS 模拟器 Runtime"
        exit 1
    fi

    echo -e "${GREEN}🚀 运行到 Apple Watch 模拟器${NC}"
    $FLUTTER run -d "$WATCH_DEVICE" $BUILD_MODE $EXTRA_FLAGS
}

run_real() {
    echo -e "${BLUE}📱 查找已连接的真机...${NC}"

    REAL_DEVICE=$($FLUTTER devices 2>/dev/null | grep -m1 "mobile" | grep -v "simulator" | grep -v "wireless" | head -1)

    if [ -z "$REAL_DEVICE" ]; then
        # 也尝试无线连接的设备
        REAL_DEVICE=$($FLUTTER devices 2>/dev/null | grep -m1 "wireless" | head -1)
    fi

    if [ -z "$REAL_DEVICE" ]; then
        echo -e "${RED}❌ 未找到已连接的真机${NC}"
        echo "   请确保:"
        echo "   1. 设备已通过 USB 连接或同一 Wi-Fi"
        echo "   2. 已信任此电脑（设备上点击"信任"）"
        echo "   3. 开发者模式已开启"
        exit 1
    fi

    echo -e "${GREEN}🚀 运行到真机${NC}"
    $FLUTTER run -d ios $BUILD_MODE $EXTRA_FLAGS
}

# ─── 执行 ───
echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}${CYAN}  防兽神器 Shoo - 多平台运行${NC}"
echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

case $PLATFORM in
    ios)
        run_ios
        ;;
    android)
        run_android
        ;;
    macos)
        run_macos
        ;;
    web|h5)
        run_web
        ;;
    watch)
        run_watch
        ;;
    real)
        run_real
        ;;
    *)
        echo -e "${RED}❌ 不支持的平台: $PLATFORM${NC}"
        echo "   支持的平台: ios, android, macos, web/h5, watch, real"
        exit 1
        ;;
esac
