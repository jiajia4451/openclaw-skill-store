#!/bin/bash
# 🦶 快捷键
KEY="${1:-ctrl+c}"
xdotool key $KEY
echo "Key: $KEY"
