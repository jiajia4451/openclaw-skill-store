#!/bin/bash
# record.sh — Real-time event recording to daily memory file
# Usage: ./record.sh "事件描述" [分类] [详细内容]

WORKSPACE="/home/jiajia4451/.openclaw/workspace"
MEMORY_DIR="$WORKSPACE/memory"
DATE=$(date +%Y-%m-%d)
TIME=$(date +%H:%M)
MEMORY_FILE="$MEMORY_DIR/$DATE.md"

# Ensure memory directory exists
mkdir -p "$MEMORY_DIR"

# Parameters
EVENT="$1"
CATEGORY="${2:-一般记录}"
DETAIL="${3:-}"

# Determine emoji based on category
case "$CATEGORY" in
  "决策"|"decision") EMOJI="🎯" ;;
  "代码"|"code"|"变更") EMOJI="📝" ;;
  "里程碑"|"milestone") EMOJI="🚀" ;;
  "错误"|"error"|"教训") EMOJI="⚠️" ;;
  "备忘"|"memo"|"用户备忘") EMOJI="💡" ;;
  "项目"|"project") EMOJI="🏗️" ;;
  *) EMOJI="📌" ;;
esac

# Create file header if doesn't exist
if [ ! -f "$MEMORY_FILE" ]; then
  echo "# $DATE 工作记录" > "$MEMORY_FILE"
  echo "" >> "$MEMORY_FILE"
  echo "**创建时间**: $TIME" >> "$MEMORY_FILE"
  echo "" >> "$MEMORY_FILE"
fi

# Append event
{
  echo ""
  echo "---"
  echo ""
  echo "## $EMOJI $TIME — $CATEGORY"
  echo ""
  echo "$EVENT"
  
  if [ -n "$DETAIL" ]; then
    echo ""
    echo "**详细内容**:"
    echo "```"
    echo "$DETAIL"
    echo "```"
  fi
  
  echo ""
  echo "**记录者**: 大饼 ₿"
} >> "$MEMORY_FILE"

echo "✅ 已记录到 $MEMORY_FILE"
