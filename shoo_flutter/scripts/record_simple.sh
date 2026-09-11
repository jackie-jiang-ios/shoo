#!/bin/bash
# record_simple.sh - 完整的录屏脚本（启动 flutter test + 控制录屏 + 合成）
# 用法: bash scripts/record_simple.sh
set -e

DEVICE="${DEVICE:-AFDC591F-F2B4-4BE2-8ED6-1A9CAF5CDFE0}"
APP_ID="com.yangshiqin.shoo"
FFMPEG="${FFMPEG:-$(command -v ffmpeg || true)}"
FFPROBE="${FFPROBE:-$(command -v ffprobe || true)}"
[ -z "$FFMPEG" ] && [ -x /usr/local/bin/ffmpeg ] && FFMPEG=/usr/local/bin/ffmpeg
[ -z "$FFPROBE" ] && [ -x /usr/local/bin/ffprobe ] && FFPROBE=/usr/local/bin/ffprobe
# Output naming: IPHONE_65-0.mp4 or IPAD_PRO_3GEN_129-0.mp4
TYPE="${TYPE:-IPHONE_65}"
# Video dimensions (WxH)
VID_W="${VID_W:-886}"
VID_H="${VID_H:-1920}"
# Screenshots subdirectory suffix (e.g. _ipad)
SUFFIX="${SUFFIX:-}"
# Base output directory
SCREENSHOTS_DIR="fastlane/screenshots${SUFFIX}"

echo "=== Simple Video Recorder ==="
echo "Device: $DEVICE"
echo "Output: fastlane/screenshots${SUFFIX}/<lang>/${TYPE}-0.mp4 (${VID_W}x${VID_H})"
echo ""

# Step 1: 启动模拟器
echo "[1/4] Booting simulator..."
if ! xcrun simctl list devices | grep "$DEVICE" | grep -q "Booted"; then
  xcrun simctl boot "$DEVICE"
  for i in $(seq 1 30); do
    xcrun simctl list devices | grep "$DEVICE" | grep -q "Booted" && break
    sleep 2
  done
fi
sleep 3
echo "  Simulator booted."

# Step 2: 杀掉旧进程
xcrun simctl terminate "$DEVICE" "$APP_ID" 2>/dev/null || true
sleep 1

# Step 3: 清理信号
rm -f /tmp/shoo_video_lang /tmp/shoo_video_start /tmp/shoo_video_done /tmp/shoo_video_stopped

# Step 4: 启动 flutter test（后台）
echo "[2/4] Starting flutter test..."
TEST_LOG="${SCREENSHOTS_DIR}/video_test.log"
mkdir -p "${SCREENSHOTS_DIR}"
flutter test integration_test/video_test.dart -d "$DEVICE" >"$TEST_LOG" 2>&1 &
TEST_PID=$!
echo "  Flutter test PID: $TEST_PID"

# Step 5: 等待信号 → 录屏 → 合成的循环
echo "[3/4] Waiting for test signals..."
RECORDED=0

while true; do
  # 等待 test 写入语言信号（最多等 5 分钟）
  LANG_READY=""
  for i in $(seq 1 300); do
    if [ -f "/tmp/shoo_video_lang" ]; then
      LANG_READY=$(cat /tmp/shoo_video_lang)
      break
    fi
    # 检查 test 进程是否还活着
    if ! kill -0 "$TEST_PID" 2>/dev/null; then
      echo "  Flutter test exited."
      break
    fi
    sleep 1
  done

  if [ -z "$LANG_READY" ]; then
    if ! kill -0 "$TEST_PID" 2>/dev/null; then
      echo "  Test finished."
    else
      echo "  Timeout waiting for language signal."
    fi
    break
  fi

  echo "--- Recording: $LANG_READY ---"
  rm -f /tmp/shoo_video_lang  # 消费掉

  # 准备录制
  OUTPUT_DIR="${SCREENSHOTS_DIR}/$LANG_READY"
  RAW_VIDEO="$OUTPUT_DIR/raw_video.mp4"
  FINAL_VIDEO="$OUTPUT_DIR/${TYPE}-0.mp4"
  mkdir -p "$OUTPUT_DIR"
  rm -f "$RAW_VIDEO" "$FINAL_VIDEO"

  # 通知 test 已准备好开始
  touch "/tmp/shoo_video_start"

  # 启动录屏
  xcrun simctl io "$DEVICE" recordVideo --codec=h264 --mask=ignored -f "$RAW_VIDEO" >/dev/null 2>&1 &
  REC_PID=$!
  echo "  Recording started (PID: $REC_PID)..."

  # 等待 test 完成信号（最多 60 秒）
  DONE=0
  for i in $(seq 1 60); do
    if [ -f "/tmp/shoo_video_done" ]; then
      DONE=1
      break
    fi
    sleep 1
  done

  # 停止录屏
  kill -INT "$REC_PID" 2>/dev/null || true
  wait "$REC_PID" 2>/dev/null || true
  sleep 1

  # 通知 test 已停止
  touch "/tmp/shoo_video_stopped"
  echo "  Recording stopped."

  # 合成视频（无声版本，占位）
  if [ -s "$RAW_VIDEO" ] && [ -n "$FFMPEG" ]; then
    RAW_DUR=$("$FFPROBE" -v error -show_entries format=duration -of csv=p=0 "$RAW_VIDEO" 2>/dev/null | cut -d. -f1)
    echo "  Raw video: ${RAW_DUR}s"
    # 转为目标分辨率（无音频，纯视频）
    "$FFMPEG" -y -i "$RAW_VIDEO" \
      -vf "scale=${VID_W}:${VID_H}:force_original_aspect_ratio=decrease,pad=${VID_W}:${VID_H}:(ow-iw)/2:(oh-ih)/2:black,fps=30" \
      -c:v libx264 -profile:v high -level 4.0 -b:v 10M -pix_fmt yuv420p \
      -an -movflags +faststart "$FINAL_VIDEO" 2>/dev/null
    if [ -f "$FINAL_VIDEO" ]; then
      RECORDED=$((RECORDED + 1))
      echo "  OK: $LANG_READY -> $FINAL_VIDEO"
    else
      echo "  FAIL: $LANG_READY"
    fi
  else
    echo "  No raw video or no ffmpeg: $LANG_READY"
  fi

  # 清理完成信号
  rm -f /tmp/shoo_video_done /tmp/shoo_video_start /tmp/shoo_video_stopped
done

# 等待 test 进程退出
if kill -0 "$TEST_PID" 2>/dev/null; then
  echo "Waiting for test to exit..."
  wait "$TEST_PID" 2>/dev/null || true
fi

echo ""
echo "[4/4] === Done: $RECORDED languages recorded ==="
