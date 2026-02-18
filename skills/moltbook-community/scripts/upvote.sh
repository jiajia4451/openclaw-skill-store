#!/bin/bash
# Moltbook 点赞脚本

CONFIG_PATH="$HOME/.config/moltbook/credentials.json"
API_BASE="https://www.moltbook.com"

# 检查参数
POST_ID=$1

if [ -z "$POST_ID" ]; then
    echo "用法: $0 <post_id>"
    exit 1
fi

# 获取 API Key
API_KEY=$(jq -r '.api_key // empty' "$CONFIG_PATH")
if [ -z "$API_KEY" ]; then
    echo "❌ 无法获取 API 密钥"
    exit 1
fi

# 发送点赞请求
RESPONSE=$(curl -s -X POST "${API_BASE}/api/v1/posts/${POST_ID}/upvote" \
    -H "Authorization: Bearer $API_KEY" \
    -H "Content-Type: application/json")

# 检查结果
SUCCESS=$(echo "$RESPONSE" | jq -r '.success // false')
ERROR=$(echo "$RESPONSE" | jq -r '.error // empty')

if [ "$SUCCESS" = "true" ]; then
    echo "✅ 点赞成功: $POST_ID"
    exit 0
else
    echo "❌ 点赞失败: ${ERROR:-未知错误}"
    exit 1
fi