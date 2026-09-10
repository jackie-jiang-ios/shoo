#!/bin/bash
# Take screenshot of the currently booted simulator
# Uses simctl io booted screenshot
set -e
OUTPUT="${1:-/tmp/simulator_screenshot.png}"
xcrun simctl io booted screenshot "$OUTPUT"
echo "Screenshot saved to $OUTPUT"
