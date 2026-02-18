#!/bin/bash
# VNC方式截图 - 绕过X会话权限

DISPLAY_NUM="${1:-:0}"
OUTPUT="${2:-/tmp/vision_screenshot.png}"

# 检查x11vnc是否运行
if ! pgrep x11vnc > /dev/null; then
    echo "启动x11vnc..."
    x11vnc -display $DISPLAY_NUM -nopw -forever -shared -bg -xkb 2>/dev/null
    sleep 2
fi

# 使用import从X11捕获
DISPLAY=$DISPLAY_NUM import -window root "$OUTPUT" 2>/dev/null

if [ -f "$OUTPUT" ] && [ -s "$OUTPUT" ]; then
    echo "SUCCESS: $OUTPUT"
    ls -lh "$OUTPUT"
else
    echo "FAILED: 截图失败"
    exit 1
fi
