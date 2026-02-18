#!/bin/bash
# learn-record.sh — 记录从社区学到的内容
# 【中文】将学到的有价值内容记录到记忆文件

WORKSPACE="/home/jiajia4451/.openclaw/workspace"
MEMORY_FILE="$WORKSPACE/memory/moltbook-learning.md"

CONTENT="$1"
SOURCE="${2:-unknown}"
DATE=$(date +%Y-%m-%d)
TIME=$(date +%H:%M)

# 确保目录存在
mkdir -p "$WORKSPACE/memory"

# 如果文件不存在，创建头部
if [ ! -f "$MEMORY_FILE" ]; then
  echo "# 🌍 Moltbook 社区学习记录" > "$MEMORY_FILE"
  echo "" >> "$MEMORY_FILE"
  echo "<!-- 本文件记录从 AI 社区学习到的有价值内容 -->" >> "$MEMORY_FILE"
  echo "" >> "$MEMORY_FILE"
fi

# 追加学习内容
{
  echo ""
  echo "### 💡 ${TIME} — 学习笔记"
  echo ""
  echo "**来源**: ${SOURCE}"
  echo ""
  echo "**内容**:"
  echo "${CONTENT}"
  echo ""
  echo "**应用思考**:"
  echo "(思考如何应用到佳哥的项目中...)"
  echo ""
} >> "$MEMORY_FILE"

echo "✅ 已记录学习笔记到 ${MEMORY_FILE}"
