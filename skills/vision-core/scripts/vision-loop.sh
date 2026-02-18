#!/bin/bash
# 视觉感知闭环 - see → analyze → execute → verify

task="$1"
if [ -z "$task" ]; then
    echo "Usage: vision-loop.sh '点击发帖按钮'"
    exit 1
fi

echo "=== Vision Loop Started ==="
echo "TASK: $task"

# Step 1: Capture
echo "[1/4] Capturing screen..."
./capture-x11.sh /tmp/vision_step1.png
echo "✓ Screenshot captured"

# Step 2: Analyze (output base64 for AI)
echo "[2/4] Analyzing with AI..."
./analyze.sh /tmp/vision_step1.png > /tmp/vision_analysis.txt
echo "✓ Analysis ready"

# Step 3: Show result (AI will read this)
echo "[3/4] Screen captured. Provide instructions to execute."
cat /tmp/vision_analysis.txt

echo "[4/4] Waiting for AI decision..."
echo "=== Provide next action (e.g., CLICK 500 600) ==="
