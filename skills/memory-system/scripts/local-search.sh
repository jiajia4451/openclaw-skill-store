#!/bin/bash
# 本地记忆文件搜索 - 免费版，无需API Key
# 用法: ./local-search.sh "关键词" [最大结果数]

WORKSPACE="/home/jiajia4451/.openclaw/workspace"
MEMORY_DIR="$WORKSPACE/memory"
QUERY="$1"
MAX_RESULTS="${2:-10}"

# 颜色
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

if [ -z "$QUERY" ]; then
    echo "用法: $0 \"搜索关键词\" [最大结果数]"
    echo "示例: $0 \"moltbook\" 5"
    exit 1
fi

echo "=== 🔍 本地记忆搜索 ==="
echo "关键词: $QUERY"
echo "最大结果: $MAX_RESULTS"
echo ""

# 搜索所有.md文件
echo "--- 匹配结果 ---"

# 使用临时文件存储结果
tmpfile=$(mktemp)
grep -ri --include="*.md" -n "$QUERY" "$MEMORY_DIR" "$WORKSPACE/MEMORY.md" "$WORKSPACE/SOUL.md" "$WORKSPACE/USER.md" 2>/dev/null > "$tmpfile"

# 显示结果（限制行数）
head -n "$MAX_RESULTS" "$tmpfile" | while read -r line; do
    # 提取文件名和行号
    if [[ "$line" =~ ^(.*/)?([^/]+\.md):([0-9]+):(.*)$ ]]; then
        filename="${BASH_REMATCH[2]}"
        lineno="${BASH_REMATCH[3]}"
        content="${BASH_REMATCH[4]}"
        echo -e "${GREEN}$filename${NC}:${YELLOW}$lineno${NC}: $content"
    else
        echo "$line"
    fi
done

# 统计
count=$(wc -l < "$tmpfile")
rm "$tmpfile"

echo ""
echo "=== 搜索完成 (找到 $count 条) ==="
