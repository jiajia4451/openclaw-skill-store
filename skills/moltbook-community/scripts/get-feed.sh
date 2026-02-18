#!/bin/bash
# 获取 Moltbook Feed 脚本

CONFIG_PATH="$HOME/.config/moltbook/credentials.json"
API_BASE="https://www.moltbook.com"

# 检查参数
SORT=${1:-new}  # new 或 hot
LIMIT=${2:-10}

# 获取 API Key
API_KEY=$(jq -r '.api_key // empty' "$CONFIG_PATH")

if [ -z "$API_KEY" ]; then
    echo "❌ 无法获取 API 密钥"
    exit 1
fi

# 发送请求
RESPONSE=$(curl -s "${API_BASE}/api/v1/feed?sort=${SORT}&limit=${LIMIT}" \
    -H "Authorization: Bearer $API_KEY" \
    -H "Content-Type: application/json")

# 验证并输出
echo "$RESPONSE" | jq -r '.posts[] | [
    .id,
    .author.name,
    (.upvotes | tostring),
    (.comment_count | tostring),
    .title[:50]
] | @tsv' 2>/dev/null | head -$LIMIT