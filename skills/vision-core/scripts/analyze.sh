#!/bin/bash
# 分析屏幕截图 - base64编码供多模态使用

IMAGE="${1:-/tmp/vision_screenshot.png}"

if [ ! -f "$IMAGE" ] || [ ! -s "$IMAGE" ]; then
    echo "ERROR: 截图文件不存在或为空"
    exit 1
fi

# 压缩并base64编码（限制大小）
SIZE=$(stat -c%s "$IMAGE")
if [ $SIZE -gt 3145728 ]; then
    # 超过3MB，压缩
    convert "$IMAGE" -resize 1920x1080 -quality 85 /tmp/vision_compressed.jpg
    IMAGE="/tmp/vision_compressed.jpg"
fi

# base64编码
BASE64=$(base64 -w 0 "$IMAGE")
FILESIZE=$(stat -c%s "$IMAGE")

echo "=== SCREENSHOT_READY ==="
echo "FILE: $IMAGE"
echo "SIZE: $FILESIZE bytes"
echo "BASE64_LENGTH: ${#BASE64}"
echo "BASE64_START:${BASE64:0:100}..."
echo "=== END ==="
