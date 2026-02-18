#!/bin/bash
# 系统截图方案 - 用系统工具截图到剪贴板，然后读取

OUTPUT="${1:-/tmp/screenshot_system.png}"

echo "=== System Screenshot Capture ==="

# 方法1: 尝试gnome-screenshot -c (复制到剪贴板)
if command -v gnome-screenshot >/dev/null 2>&1; then
    echo "Using gnome-screenshot..."
    gnome-screenshot -c 2>/dev/null  # 复制到剪贴板
    sleep 0.5
    
    # 尝试从剪贴板读取
    if command -v xclip >/dev/null 2>&1; then
        xclip -selection clipboard -t image/png -o > "$OUTPUT" 2>/dev/null
        if [ -s "$OUTPUT" ]; then
            echo "✓ Screenshot captured from clipboard"
            ls -lh "$OUTPUT"
            exit 0
        fi
    fi
fi

# 方法2: gnome-screenshot保存到文件
if command -v gnome-screenshot >/dev/null 2>&1; then
    echo "Saving to file..."
    gnome-screenshot -f "$OUTPUT" 2>/dev/null
    if [ -f "$OUTPUT" ] && [ -s "$OUTPUT" ]; then
        echo "✓ Screenshot saved to $OUTPUT"
        ls -lh "$OUTPUT"
        exit 0
    fi
fi

# 方法3: xdotool触发PrintScreen (系统快捷键)
echo "Triggering PrintScreen key..."
xdotool key Print 2>/dev/null
sleep 1

# 检查默认截图保存位置 (Ubuntu通常是 ~/Pictures/Screenshots/)
LATEST=$(ls -t ~/Pictures/Screenshots/*.png 2>/dev/null | head -1)
if [ -n "$LATEST" ] && [ -f "$LATEST" ]; then
    cp "$LATEST" "$OUTPUT"
    echo "✓ Screenshot from default location: $LATEST"
    ls -lh "$OUTPUT"
    exit 0
fi

echo "✗ Failed to capture screenshot"
exit 1
