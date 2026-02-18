#!/bin/bash
# 视觉截图脚本 - X11桌面截图
# 注意: WebChat环境下由于X11会话隔离，直接截图可能失败
# 解决方案: 请用户发截图，然后分析

OUTPUT="${1:-/tmp/vision_screenshot_$(date +%s).png}"
export DISPLAY=:0

echo "=== Vision Screenshot ==="
echo "目标: $OUTPUT"
echo ""

# 检查X11会话
if [ -z "$DISPLAY" ]; then
    echo "⚠️ 警告: DISPLAY环境变量未设置"
    echo "在WebChat环境下，直接截图可能失败"
    echo ""
    echo "💡 建议: 请用户发送屏幕截图，然后分析"
    echo ""
fi

# 尝试多种截图方式
echo "尝试截图..."

# 方法1: flameshot (推荐)
if command -v flameshot >/dev/null 2>&1; then
    flameshot full --path "$OUTPUT" 2>/dev/null && {
        echo "✅ Flameshot 截图成功"
        ls -lh "$OUTPUT"
        exit 0
    }
fi

# 方法2: gnome-screenshot
if command -v gnome-screenshot >/dev/null 2>&1; then
    gnome-screenshot -f "$OUTPUT" 2>/dev/null && {
        echo "✅ gnome-screenshot 成功"
        ls -lh "$OUTPUT"
        exit 0
    }
fi

# 方法3: ImageMagick import
if command -v import >/dev/null 2>&1; then
    import -window root "$OUTPUT" 2>/dev/null && {
        echo "✅ ImageMagick import 成功"
        ls -lh "$OUTPUT"
        exit 0
    }
fi

# 方法4: xdotool (需要先有窗口)
if command -v xdotool >/dev/null 2>&1; then
    # 尝试截取根窗口
    WID=$(xdotool getactivewindow 2>/dev/null)
    if [ -n "$WID" ]; then
        xdotool windowcapture "$WID" "$OUTPUT" 2>/dev/null && {
            echo "✅ xdotool windowcapture 成功"
            ls -lh "$OUTPUT"
            exit 0
        }
    fi
fi

# 所有方法都失败
echo ""
echo "❌ 截图失败"
echo ""
echo "可能原因:"
echo "  1. X11会话隔离 (WebChat环境)"
echo "  2. 缺少截图工具 (flameshot/gnome-screenshot/import)"
echo "  3. 权限问题"
echo ""
echo "💡 替代方案: 请用户发送屏幕截图"
echo "   收到截图后，我可以直接分析内容"
echo ""
exit 1
