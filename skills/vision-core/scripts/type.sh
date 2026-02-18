#!/bin/bash
# ⌨️ 模拟人类打字
TEXT="${1:-Hello}"
DELAY=${2:-30}
xdotool type --delay $DELAY "$TEXT"
echo "Typed: $TEXT"
