#!/bin/bash
# 快速浏览 - 简化版前台浏览
# 直接启动Chrome并导航，一步到位

URL="$1"
WAIT_TIME=${2:-3}
OUTPUT_DIR="/tmp/quick-browser"
mkdir -p "$OUTPUT_DIR"

SCREENSHOT="$OUTPUT_DIR/screenshot_$(date +%s).png"

# 1. 直接启动Chrome并导航（一步完成）
if ! pgrep -x "chrome" > /dev/null 2>&1; then
    # Chrome未运行，直接启动并导航
    google-chrome "$URL" &
    sleep $WAIT_TIME
else
    # Chrome已运行，激活并导航
    WID=$(xdotool search --class "google-chrome" | tail -1)
    xdotool windowactivate "$WID"
    # 直接在新标签页打开URL
    xdotool key ctrl+t
    sleep 0.5
    xdotool type --delay 10 "$URL"
    xdotool key Return
    sleep $WAIT_TIME
fi

# 2. 立即截图
flameshot full --path "$SCREENSHOT" 2>/dev/null

# 3. 输出结果
if [ -f "$SCREENSHOT" ]; then
    echo "✅ 浏览完成: $URL"
    echo "📸 截图: $SCREENSHOT"
    echo "📊 大小: $(du -h "$SCREENSHOT" | cut -f1)"
else
    echo "❌ 截图失败"
    exit 1
fi
