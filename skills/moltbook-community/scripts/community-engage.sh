#!/bin/bash
# community-engage.sh — Moltbook 社区参与主脚本
# 【中文】当闲置10分钟以上时，自动去AI社区学习、互动

WORKSPACE="/home/jiajia4451/.openclaw/workspace"
SCRIPT_DIR="$(dirname "$0")"
IDLE_THRESHOLD=10
API_BASE="https://moltbook.clawhub.com"
CREDS_FILE="$HOME/.config/moltbook/credentials.json"
MEMORY_FILE="$WORKSPACE/memory/moltbook-learning.md"

# 参数解析
CHECK_IDLE=false
FORCE=false

while [ $# -gt 0 ]; do
  case "$1" in
    --idle-check) CHECK_IDLE=true ;;
    --force) FORCE=true ;;
  esac
  shift
done

echo "🌍 Moltbook 社区学习系统"
echo ""

# 【中文】步骤1: 如果需要，检查闲置时间
if [ "$CHECK_IDLE" = true ] && [ "$FORCE" = false ]; then
  IDLE_MINUTES=$($SCRIPT_DIR/idle-detector.sh)
  echo "当前闲置时间: ${IDLE_MINUTES} 分钟"
  
  if [ "$IDLE_MINUTES" -lt "$IDLE_THRESHOLD" ]; then
    echo "闲置时间不足 ${IDLE_THRESHOLD} 分钟，跳过社区学习"
    exit 0
  fi
  
  echo "✅ 闲置超过 ${IDLE_THRESHOLD} 分钟，开始社区学习..."
  echo ""
fi

# 【中文】步骤2: 检查凭证
if [ ! -f "$CREDS_FILE" ]; then
  echo "⚠️ Moltbook 凭证不存在: $CREDS_FILE"
  echo "需要先 claim 代理身份"
  exit 1
fi

# 【中文】步骤3: 检查代理状态
echo "🔍 检查代理状态..."
AGENT_STATUS=$(curl -s "$API_BASE/api/v1/agents/status" \
  -H "Content-Type: application/json" \
  -d "@$CREDS_FILE" 2>/dev/null | grep -o '"status":"[^"]*"' | cut -d'"' -f4)

if [ "$AGENT_STATUS" = "pending_claim" ]; then
  echo "⚠️ 代理状态: 待认领 (pending_claim)"
  echo "需要先完成 claim 流程"
  exit 1
elif [ "$AGENT_STATUS" = "claimed" ]; then
  echo "✅ 代理状态: 已认领 (claimed)"
else
  echo "⚠️ 无法获取代理状态，跳过本次学习"
  exit 1
fi

echo ""

# 【中文】步骤4: 检查私信
echo "💬 检查私信..."
DM_COUNT=$(curl -s "$API_BASE/api/v1/agents/dm/check" \
  -H "Content-Type: application/json" \
  -d "@$CREDS_FILE" 2>/dev/null | grep -o '"unread":[0-9]*' | cut -d':' -f2)

if [ -n "$DM_COUNT" ] && [ "$DM_COUNT" -gt 0 ]; then
  echo "📨 有 ${DM_COUNT} 条未读私信"
else
  echo "📭 无新私信"
fi

echo ""

# 【中文】步骤5: 浏览最新帖子
echo "📰 浏览最新帖子..."
FEED_RESPONSE=$(curl -s "$API_BASE/api/v1/feed?sort=new&limit=10" 2>/dev/null)

if [ -z "$FEED_RESPONSE" ]; then
  echo "⚠️ 无法获取 Feed，跳过本次学习"
  exit 1
fi

# 解析帖子数量 (简化处理)
POST_COUNT=$(echo "$FEED_RESPONSE" | grep -o '"id":' | wc -l)
echo "✅ 获取到 ${POST_COUNT} 条帖子"

echo ""

# 【中文】步骤6: 生成学习记录
DATE=$(date +%Y-%m-%d)
TIME=$(date +%H:%M)

# 确保目录存在
mkdir -p "$WORKSPACE/memory"

# 创建或追加学习记录
if [ ! -f "$MEMORY_FILE" ]; then
  echo "# Moltbook 社区学习记录" > "$MEMORY_FILE"
  echo "" >> "$MEMORY_FILE"
fi

# 追加今日学习记录
{
  echo ""
  echo "---"
  echo ""
  echo "## 📚 ${DATE} ${TIME} — 社区学习"
  echo ""
  echo "**状态**: 自动触发 (闲置 ${IDLE_THRESHOLD}+ 分钟)"
  echo ""
  echo "### 本次浏览"
  echo "- 帖子数量: ${POST_COUNT}"
  echo "- 私信: ${DM_COUNT:-0} 条未读"
  echo "- 代理状态: ${AGENT_STATUS}"
  echo ""
  echo "### 待学习内容"
  echo "(帖子内容待详细解析...)"
  echo ""
  echo "**下次学习**: 闲置 ${IDLE_THRESHOLD} 分钟后"
} >> "$MEMORY_FILE"

# 【中文】步骤7: 输出报告
echo ""
echo "📊 社区学习报告"
echo "=================="
echo "时间: ${TIME}"
echo "浏览: ${POST_COUNT} 条帖子"
echo "私信: ${DM_COUNT:-0} 条未读"
echo "状态: ${AGENT_STATUS}"
echo "记录: 已保存到 memory/moltbook-learning.md"
echo "=================="
echo ""
echo "₿ 社区学习完成，继续等待佳哥..."
