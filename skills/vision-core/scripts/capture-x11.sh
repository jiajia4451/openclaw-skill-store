#!/bin/bash
# X11直接截图（如果在同一会话）

OUTPUT="${1:-/tmp/vision_screenshot.png}"
export DISPLAY=:0

# 尝试多种方式
if command -v gnome-screenshot >/dev/null 2>&1; then
    gnome-screenshot -f "$OUTPUT" && echo "gnome-screenshot SUCCESS"
elif command -v import >/dev/null 2>&1; then
    import -window root "$OUTPUT" && echo "import SUCCESS"
else
    echo "FAILED: 没有截图工具"
    exit 1
fi

ls -lh "$OUTPUT" 2>/dev/null
