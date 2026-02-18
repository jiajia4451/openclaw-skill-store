#!/bin/bash
# 会话记忆搜索 - 结合QMD和会话记录
# 注：sessions_history需要sessionKey，此脚本用于说明整合思路

QUERY="$1"

echo "=== 会话记忆搜索 ==="
echo "查询: $QUERY"
echo ""

echo "📚 记忆文件搜索 (QMD):"
export PATH="$HOME/.bun/bin:$PATH"
qmd query "$QUERY" 2>/dev/null | head -5 || qmd search "$QUERY" 2>/dev/null | head -5

echo ""
echo "💬 会话记录搜索:"
echo "注意: sessions_history需要sessionKey参数"
echo "使用方法: sessions_history(sessionKey=xxx, query=\"$QUERY\")"
echo ""

echo "=== 搜索完成 ==="
echo ""
echo "💡 整合策略:"
echo "  1. 先用QMD搜索记忆文件"
echo "  2. 再用sessions_history搜索过往会话"
echo "  3. 合并结果作为上下文"
