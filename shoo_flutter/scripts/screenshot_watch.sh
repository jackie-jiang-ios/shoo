#!/bin/bash
# screenshot_watch.sh - Watch App 截图脚本（单张主界面）
# 用法:
#   scripts/screenshot_watch.sh build          # 编译 Watch App
#   scripts/screenshot_watch.sh capture        # 截取主界面
#   scripts/screenshot_watch.sh all            # 编译+截取

set -e

WATCH_UDID="F7BFDD28-1965-4FEA-A38F-5C465ED1C32E"
WATCH_NAME="Apple Watch Series 11 (46mm)"
WATCH_BUNDLE="com.yangshiqin.shoo.watch"
PROJECT_DIR="/Users/jiangzheng/Project/iOS/Shoo/shoo_flutter/ios/ShooWatch"
OUTPUT_DIR="/Users/jiangzheng/Project/iOS/Shoo/shoo_flutter/fastlane/screenshots_watch/en-US"

build_watch() {
    echo "=== Building Watch App ==="
    cd "$PROJECT_DIR"
    xcodegen generate 2>/dev/null || true
    xcodebuild -project ShooWatch.xcodeproj -scheme ShooWatch \
        -destination "platform=watchOS Simulator,name=$WATCH_NAME,OS=26.1" \
        -derivedDataPath ./build build 2>&1 | tail -3
    echo "=== Build done ==="
}

capture_home() {
    echo "=== Capturing Watch Home ==="
    mkdir -p "$OUTPUT_DIR"
    
    # 确保模拟器已启动
    xcrun simctl boot "$WATCH_NAME" 2>/dev/null || true
    
    # 安装 App
    xcrun simctl install "$WATCH_NAME" "$PROJECT_DIR/build/Build/Products/Debug-watchsimulator/ShooWatch.app"
    
    # 启动 App（截图模式）
    xcrun simctl terminate "$WATCH_NAME" "$WATCH_BUNDLE" 2>/dev/null || true
    xcrun simctl launch "$WATCH_NAME" "$WATCH_BUNDLE"
    
    # 等待加载
    sleep 3
    
    # 截图
    xcrun simctl io "$WATCH_NAME" screenshot "$OUTPUT_DIR/01_Home.png"
    
    echo "=== Screenshot saved to $OUTPUT_DIR/01_Home.png ==="
    sips -g pixelWidth -g pixelHeight "$OUTPUT_DIR/01_Home.png"
}

case "${1:-all}" in
    build)     build_watch ;;
    capture)   capture_home ;;
    all)       build_watch && capture_home ;;
    *)         echo "Usage: $0 {build|capture|all}" ;;
esac
