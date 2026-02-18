#!/bin/bash
# 全演示 - Vision Skill工作流

echo "=== Vision Core Demo ==="
echo "1. Screenshot"
cd /home/jiajia4451/.openclaw/workspace/skills/vision-core/scripts
chmod +x *.sh

# 捕获
export DISPLAY=:0
scrot /tmp/demo_screenshot.png 2>/dev/null
if [ -f /tmp/demo_screenshot.png ]; then
    ls -lh /tmp/demo_screenshot.png
    echo "Screenshot captured"
    
    # 分析
    echo ""
    echo "2. Analyze (base64 encode)"
    ./analyze.sh /tmp/demo_screenshot.png | head -10
    
    # 准备给多模态
    echo ""
    echo "3. AI can now see the screen"
    echo "Send /tmp/demo_screenshot.png to AI for analysis"
fi

echo ""
echo "=== Demo Complete ==="