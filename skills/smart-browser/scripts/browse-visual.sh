#!/bin/bash
# 前台截图浏览 - Chrome截图+AI分析

URL="$1"
FILENAME=${2:-"screenshot_$(date +%s).png"}
OUTPUT_DIR="/tmp/smart-browser"
mkdir -p "$OUTPUT_DIR"

SCREENSHOT="$OUTPUT_DIR/$FILENAME"
CHROME_CLASS="google-chrome"
WAIT_TIME=${SMART_BROWSER_WAIT:-5}

echo "{\"url\":\"$URL\",\"mode\":\"visual\",\"status\":\"starting\",\"step\":\"check_chrome\"}"

# 1. 检查/启动Chrome
if ! pgrep -x "chrome" > /dev/null 2>&1; then
    google-chrome &
    sleep 3
fi

# 2. 获取窗口ID
WID=$(xdotool search --class "$CHROME_CLASS" | tail -1)
if [ -z "$WID" ]; then
    echo "{\"url\":\"$URL\",\"mode\":\"visual\",\"status\":\"failed\",\"error\":\"Chrome window not found\"}"
    exit 1
fi

# 3. 激活并导航
echo "{\"url\":\"$URL\",\"mode\":\"visual\",\"status\":\"navigating\"}"
xdotool windowactivate "$WID"
sleep 0.5
xdotool key ctrl+l
sleep 0.3
xdotool type --delay 30 "$URL"
sleep 0.3
xdotool key Return

# 4. 等待页面加载
echo "{\"url\":\"$URL\",\"mode\":\"visual\",\"status\":\"waiting\",\"seconds\":$WAIT_TIME}"
sleep $WAIT_TIME

# 5. 截图
echo "{\"url\":\"$URL\",\"mode\":\"visual\",\"status\":\"capturing\"}"
xdotool windowactivate "$WID"
flameshot full --path "$SCREENSHOT" 2>/dev/null || xdotool windowcapture "$WID" "$SCREENSHOT"

if [ ! -f "$SCREENSHOT" ]; then
    echo "{\"url\":\"$URL\",\"mode\":\"visual\",\"status\":\"failed\",\"error\":\"Screenshot failed\"}"
    exit 1
fi

# 6. 最小化Chrome（不关闭）
xdotool windowminimize "$WID" 2>/dev/null

# 7. 输出结果
echo "{\"url\":\"$URL\",\"mode\":\"visual\",\"status\":\"success\",\"screenshot\":\"$SCREENSHOT\",\"size\":\"$(du -h \"$SCREENSHOT\" | cut -f1)\"}"
