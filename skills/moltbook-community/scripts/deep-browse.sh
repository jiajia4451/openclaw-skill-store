#!/bin/bash
# deep-browse.sh — 深度浏览脚本 (修复版)
# 【功能】大量浏览帖子，使用正确的 Bearer Token 认证

WORKSPACE="/home/jiajia4451/.openclaw/workspace"
API_BASE="https://www.moltbook.com"
CREDS_FILE="$WORKSPACE/.config/moltbook/credentials.json"

# 默认参数
COUNT=50
TYPE="mixed"  # mixed, new, hot

# 解析参数
while [ $# -gt 0 ]; do
  case "$1" in
    --count)
      COUNT="$2"
      shift 2
      ;;
    --type)
      TYPE="$2"
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done

# 从凭证文件读取 API Key
if [ ! -f "$CREDS_FILE" ]; then
  echo "❌ 凭证文件不存在: $CREDS_FILE"
  exit 1
fi

API_KEY=$(grep '"api_key"' "$CREDS_FILE" | cut -d'"' -f4)
if [ -z "$API_KEY" ]; then
  echo "❌ 无法读取 API Key"
  exit 1
fi

echo "📚 深度浏览模式"
echo "数量: $COUNT 条"
echo "类型: $TYPE"
echo ""

NEW_COUNT=0
HOT_COUNT=0

# 根据类型获取帖子
if [ "$TYPE" = "new" ] || [ "$TYPE" = "mixed" ]; then
  echo "🔍 获取最新帖子..."
  NEW_POSTS=$(curl -s "$API_BASE/api/v1/feed?sort=new&limit=$COUNT" \
    -H "Authorization: Bearer $API_KEY" \
    -H "Content-Type: application/json" 2>/dev/null)
  NEW_COUNT=$(echo "$NEW_POSTS" | grep -o '"id":' | wc -l)
  echo "  ✅ 获取到 $NEW_COUNT 条最新帖子"
  
  # 保存帖子到临时文件供后续分析
  echo "$NEW_POSTS" > /tmp/moltbook_new_posts.json
fi

if [ "$TYPE" = "hot" ] || [ "$TYPE" = "mixed" ]; then
  echo "🔥 获取热门帖子..."
  HOT_POSTS=$(curl -s "$API_BASE/api/v1/feed?sort=hot&limit=$COUNT" \
    -H "Authorization: Bearer $API_KEY" \
    -H "Content-Type: application/json" 2>/dev/null)
  HOT_COUNT=$(echo "$HOT_POSTS" | grep -o '"id":' | wc -l)
  echo "  ✅ 获取到 $HOT_COUNT 条热门帖子"
  
  # 保存帖子到临时文件
  echo "$HOT_POSTS" > /tmp/moltbook_hot_posts.json
fi

# 输出浏览总结
TOTAL=$((NEW_COUNT + HOT_COUNT))
echo ""
echo "📊 浏览总结"
echo "总浏览量: $TOTAL 条"
[ "$NEW_COUNT" -gt 0 ] && echo "  - 最新: $NEW_COUNT 条"
[ "$HOT_COUNT" -gt 0 ] && echo "  - 热门: $HOT_COUNT 条"

# 如果获取到帖子，显示一些统计信息
if [ "$TOTAL" -gt 0 ]; then
  echo ""
  echo "📈 内容概览:"
  
  # 尝试提取一些帖子标题
  if [ -f /tmp/moltbook_new_posts.json ]; then
    echo "  最新帖子预览:"
    grep -o '"title":"[^"]*"' /tmp/moltbook_new_posts.json | head -3 | while read line; do
      title=$(echo "$line" | cut -d'"' -f4)
      echo "    • $title"
    done
  fi
fi
