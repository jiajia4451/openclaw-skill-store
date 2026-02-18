#!/bin/bash
# 记忆恢复脚本 - 对话开始时自动执行
# 用QMD搜索相关记忆，恢复上下文

WORKSPACE="/home/jiajia4451/.openclaw/workspace"
QUERY="$1"
OUTPUT_FILE="/tmp/memory-recovery-result.txt"

export PATH="$HOME/.bun/bin:$PATH"

echo "=== 记忆恢复 ==="
echo "查询: $QUERY"
echo ""

# 1. QMD搜索记忆文件
QMD_RESULT=$(qmd search "$QUERY" -c openclaw-memory 2>/dev/null | head -30)

if [ -n "$QMD_RESULT" ]; then
    echo "📚 找到相关记忆文件:"
    echo "$QMD_RESULT" | grep "^qmd://" | head -5
    echo ""
fi

# 2. 检查今日记忆文件
TODAY=$(date +%Y-%m-%d)
TODAY_FILE="$WORKSPACE/memory/$TODAY.md"

if [ -f "$TODAY_FILE" ]; then
    echo "📅 今日记忆 ($TODAY):"
    head -10 "$TODAY_FILE"
    echo ""
fi

# 3. 输出建议
if [ -n "$QMD_RESULT" ]; then
    echo "💡 建议读取以下文件获取上下文:"
    echo "$QMD_RESULT" | grep "^qmd://" | sed 's/qmd:\/\/openclaw-memory\//  - /' | head -5
fi

echo ""
echo "=== 记忆恢复完成 ==="
