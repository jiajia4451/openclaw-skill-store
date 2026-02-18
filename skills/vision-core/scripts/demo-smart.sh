#!/bin/bash
# 演示: PrintScreen + 剪贴板读取

echo "=== Smart Screenshot Demo ==="
echo "This will trigger PrintScreen and capture from clipboard"
echo ""
echo "Step 1: Triggering PrintScreen in 2 seconds..."
sleep 2

# 激活窗口并触发PrintScreen
export DISPLAY=:0
xdotool search --class "google-chrome" windowactivate 2>/dev/null
sleep 0.5
xdotool key Print
echo "✓ PrintScreen triggered"
sleep 1

# 方法A: 从剪贴板读取 (xclip)
echo "Attempting to read from clipboard..."
if command -v xclip >/dev/null 2>&1; then
    # 尝试读取剪贴板中的图片
    CLIP_OUT="/tmp/clipboard_screenshot.png"
    xclip -selection clipboard -t image/png -o > "$CLIP_OUT" 2>/dev/null
    if [ -s "$CLIP_OUT" ]; then
        echo "✓ Screenshot from clipboard!"
        ls -lh "$CLIP_OUT"
        echo "File: $CLIP_OUT"
        exit 0
    fi
fi

# 方法B: 查找最新截图
echo "Checking default screenshot location..."
LATEST=$(ls -t ~/Pictures/Screenshots/*.png 2>/dev/null | head -1)
if [ -n "$LATEST" ]; then
    echo "✓ Found screenshot: $LATEST"
    ls -lh "$LATEST"
    exit 0
fi

echo "Please check if screenshot was saved to ~/Pictures/Screenshots/"
ls -lh ~/Pictures/Screenshots/*.png 2>/dev/null | tail -5 || echo "No screenshots found"
