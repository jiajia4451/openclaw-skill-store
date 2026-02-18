#!/bin/bash
# 智能点击 - 结合视觉+执行

X="$1"
Y="$2"
DESC="$3"

echo "执行点击: [$DESC] at ($X, $Y)"
xdotool mousemove $X $Y && xdotool click 1
echo "✓ Clicked at $X $Y"

# 验证截图
echo "---"
echo "验证: 截图检查点击效果..."
sleep 0.5
./capture-x11.sh /tmp/verify.png 2>/dev/null