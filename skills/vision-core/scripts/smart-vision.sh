#!/bin/bash
# 智能视觉闭环 - 全自动化

ACTION="$1"
CYCLE="${2:-1}"

echo "=== Smart Vision Loop ==="
echo "Action: $ACTION"
echo "Cycles: $CYCLE"

for i in $(seq 1 $CYCLE); do
    echo ""
    echo "--- Cycle $i ---"
    
    # Step 1: Capture
    echo "[1/3] Capturing screen..."
    ./capture-system.sh /tmp/vision_$i.png
    if [ ! -f /tmp/vision_$i.png ]; then
        echo "✗ Capture failed"
        continue
    fi
    
    # Step 2: Analyze (prepare for AI)
    echo "[2/3] Preparing for AI analysis..."
    ./analyze.sh /tmp/vision_$i.png
    
    # Step 3: Show file ready
    echo "[3/3] Screenshot ready at: /tmp/vision_$i.png"
    echo "Send this to AI for analysis and action instructions"
    
    echo ""
    echo "AI should respond with:"
    echo "  - Current state description"
    echo "  - Recommended action (click X,Y / type text)"
    echo "  - Then run: ./smart-click.sh X Y 'description'"
done

echo ""
echo "=== Vision Loop Complete ==="
