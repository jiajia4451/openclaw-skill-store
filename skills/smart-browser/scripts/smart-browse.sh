#!/bin/bash
# 智能浏览 - 自动选择后台/前台模式

URL="$1"
MAX_RETRIES=${2:-2}
OUTPUT_DIR="/tmp/smart-browser"
mkdir -p "$OUTPUT_DIR"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 日志
LOG_FILE="$OUTPUT_DIR/smart-browse.log"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Browsing: $URL" >> "$LOG_FILE"

# 首先尝试后台API
echo "{\"url\":\"$URL\",\"status\":\"trying_api\"}"

API_RESULT=$("$SCRIPT_DIR/browse-api.sh" "$URL" 2>&1)
API_STATUS=$(echo "$API_RESULT" | grep -o '"status":"[^"]*"' | cut -d'"' -f4)

if [ "$API_STATUS" = "success" ]; then
    echo "$API_RESULT"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] API mode success" >> "$LOG_FILE"
    exit 0
fi

# API失败，尝试前台截图
echo "{\"url\":\"$URL\",\"status\":\"api_failed\",\"reason\":\"$API_STATUS\",\"fallback\":\"visual\"}"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] API failed ($API_STATUS), trying visual..." >> "$LOG_FILE"

VISUAL_RESULT=$("$SCRIPT_DIR/browse-visual.sh" "$URL" 2>&1)
echo "$VISUAL_RESULT"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Visual mode done" >> "$LOG_FILE"
