#!/bin/bash
# search.sh — Semantic memory search across all memory files
# Usage: ./search.sh "查询内容" [--date YYYY-MM-DD] [--project 项目名]

WORKSPACE="/home/jiajia4451/.openclaw/workspace"
MEMORY_DIR="$WORKSPACE/memory"
QUERY="$1"
DATE_FILTER=""
PROJECT_FILTER=""

# Parse arguments
shift
while [ $# -gt 0 ]; do
  case "$1" in
    --date)
      DATE_FILTER="$2"
      shift 2
      ;;
    --project)
      PROJECT_FILTER="$2"
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done

echo "🔍 搜索记忆: \"$QUERY\""
echo ""

# Build search scope
SEARCH_FILES=""

# Add MEMORY.md
if [ -f "$WORKSPACE/MEMORY.md" ]; then
  SEARCH_FILES="$SEARCH_FILES $WORKSPACE/MEMORY.md"
fi

# Add daily memory files
if [ -n "$DATE_FILTER" ]; then
  # Search specific date
  if [ -f "$MEMORY_DIR/$DATE_FILTER.md" ]; then
    SEARCH_FILES="$SEARCH_FILES $MEMORY_DIR/$DATE_FILTER.md"
  fi
else
  # Search all dates
  for f in "$MEMORY_DIR"/2026-*.md "$MEMORY_DIR"/2025-*.md; do
    if [ -f "$f" ]; then
      SEARCH_FILES="$SEARCH_FILES $f"
    fi
  done
fi

# Add project files
if [ -n "$PROJECT_FILTER" ]; then
  if [ -f "$MEMORY_DIR/projects/$PROJECT_FILTER.md" ]; then
    SEARCH_FILES="$SEARCH_FILES $MEMORY_DIR/projects/$PROJECT_FILTER.md"
  fi
else
  for f in "$MEMORY_DIR/projects/"*.md; do
    if [ -f "$f" ]; then
      SEARCH_FILES="$SEARCH_FILES $f"
    fi
  done
fi

# Search using grep with context
if [ -n "$SEARCH_FILES" ]; then
  echo "=== 搜索结果 ==="
  echo ""
  
  # Simple keyword search (case insensitive)
  RESULTS=$(grep -i -n -B2 -A2 "$QUERY" $SEARCH_FILES 2>/dev/null | head -100)
  
  if [ -n "$RESULTS" ]; then
    echo "$RESULTS" | while IFS= read -r line; do
      # Highlight matches
      if echo "$line" | grep -qi "$QUERY"; then
        echo "  🔹 $line"
      else
        echo "     $line"
      fi
    done
    echo ""
    echo "✅ 找到匹配内容"
  else
    echo "  ⚠️ 未找到匹配内容"
  fi
else
  echo "  ⚠️ 无可用记忆文件"
fi

echo ""
echo "💡 提示: 使用 --date YYYY-MM-DD 搜索特定日期，--project 项目名 搜索特定项目"
