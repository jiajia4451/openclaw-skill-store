#!/bin/bash
# 🖱️ 鼠标点击
X=${1:-500}
Y=${2:-500}
xdotool mousemove $X $Y click 1
echo "Clicked at $X,$Y"
