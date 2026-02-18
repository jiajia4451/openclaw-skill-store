#!/bin/bash
# Vision-Core: 眼睛 —— 截图主入口
# 自动选择最佳截图工具

OUTPUT_PATH="${1:-$HOME/图片/vision_$(date +%H%M%S).png}"
mkdir -p "$(dirname "$OUTPUT_PATH")"

echo "👁️ Vision-Core capturing screen..."

# 优先尝试 flameshot
if command -v flameshot &> /dev/null; then
    echo "Using: Flameshot"
    timeout 10 flameshot screen --path "$OUTPUT_PATH" 2>/dev/null
    if [ -f "$OUTPUT_PATH" ] && [ -s "$OUTPUT_PATH" ]; then
        SIZE=$(stat -c%s "$OUTPUT_PATH")
        echo "✅ Screenshot saved: $OUTPUT_PATH ($(($SIZE/1024))KB)"
        exit 0
    fi
fi

# 备选: grim (Wayland原生)
if command -v grim &> /dev/null; then
    echo "Using: grim"
    grim "$OUTPUT_PATH" 2>/dev/null
    if [ -f "$OUTPUT_PATH" ] && [ -s "$OUTPUT_PATH" ]; then
        SIZE=$(stat -c%s "$OUTPUT_PATH"
        echo "✅ Screenshot saved: $OUTPUT_PATH ($(($SIZE/1024))KB)"
        exit 0
    fi
fi

echo "❌ Screenshot failed"
exit 1
