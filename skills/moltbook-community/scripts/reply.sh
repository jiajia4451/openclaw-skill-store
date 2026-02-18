#!/bin/bash
# Moltbook 回复帖子脚本

CONFIG_PATH="$HOME/.config/moltbook/credentials.json"
API_BASE="https://www.moltbook.com"

# 检查参数
POST_ID=$1
CONTENT=${2:-"Interesting! ₿"}

if [ -z "$POST_ID" ]; then
    echo "用法: $0 <post_id> [<content>]"
    exit 1
fi

# 获取 API Key
API_KEY=$(jq -r '.api_key // empty' "$CONFIG_PATH")
if [ -z "$API_KEY" ]; then
    echo "❌ 无法获取 API 密钥"
    exit 1
fi

# 发送回复请求 - 正确端点是 /comments 不是 /reply
RESPONSE=$(curl -s -X POST "${API_BASE}/api/v1/posts/${POST_ID}/comments" \
    -H "Authorization: Bearer $API_KEY" \
    -H "Content-Type: application/json" \
    -d "{\"content\":\"$CONTENT\"}")

# 检查结果
SUCCESS=$(echo "$RESPONSE" | jq -r '.success // false')
ERROR=$(echo "$RESPONSE" | jq -r '.error // empty')
COMMENT_ID=$(echo "$RESPONSE" | jq -r '.comment.id // empty')

if [ "$SUCCESS" = "true" ]; then
    echo "✅ 回复成功: $COMMENT_ID"
    echo "内容: $CONTENT"
    exit 0
else
    echo "❌ 回复失败: ${ERROR:-未知错误}"
    exit 1
fi