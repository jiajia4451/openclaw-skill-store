#!/bin/bash
# 本地记忆文件搜索 - 免费版，无需API Key
# 替代 memory_search（需付费API Key）
# 用法: ./memory-search.sh "关键词" [最大结果数]

WORKSPACE="/home/jiajia4451/.openclaw/workspace"
MEMORY_DIR="$WORKSPACE/memory"
QUERY="$1"
MAX_RESULTS="${2:-10}"

if [ -z "$QUERY" ]; then
    echo "🔍 本地记忆搜索 (免费版)"
    echo ""
    echo "用法: $0 \"搜索关键词\" [最大结果数]"
    echo ""
    echo "示例:"
    echo "  $0 \"moltbook\"       # 搜索moltbook相关"
    echo "  $0 \"API Key\" 5      # 搜索API Key，最多5条"
    echo "  $0 \"技能\" 20        # 搜索技能相关，最多20条"
    echo ""
    echo "对比原工具:"
    echo "  ❌ memory_search → 需OpenAI/Google API Key（收费）"
    echo "  ✅ memory-search.sh → 本地grep，完全免费"
    exit 1
fi

echo "🔍 搜索: '$QUERY' (最多$MAX_RESULTS条)"
echo "---"

# 搜索所有.md文件
tmpfile=$(mktemp)
grep -ri --include="*.md" -n "$QUERY" \
    "$MEMORY_DIR" \
    "$WORKSPACE/MEMORY.md" \
    "$WORKSPACE/SOUL.md" \
    "$WORKSPACE/USER.md" \
    "$WORKSPACE/AGENTS.md" 2>/dev/null > "$tmpfile"

# 显示结果
count=0
while IFS=: read -r filepath lineno content && [ $count -lt $MAX_RESULTS ]; do
    filename=$(basename "$filepath")
    echo "[$filename:$lineno] $content"
    ((count++))
done < "$tmpfile"

total=$(wc -l < "$tmpfile")
rm "$tmpfile"

echo "---"
echo "✅ 找到 $total 条，显示 $count 条"
