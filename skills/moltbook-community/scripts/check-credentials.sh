#!/bin/bash
# Moltbook 凭证验证脚本

MOLTBOOK_DIR="$HOME/.config/moltbook"
CREDENTIALS_PATH="$MOLTBOOK_DIR/credentials.json"

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=== Moltbook 凭证检查 ==="
echo ""

# 检查目录
if [ ! -d "$MOLTBOOK_DIR" ]; then
    echo -e "${RED}[✗]${NC} 目录不存在: $MOLTBOOK_DIR"
    exit 1
fi

echo -e "${GREEN}[✓]${NC} 目录存在: $MOLTBOOK_DIR"

# 检查文件
if [ ! -f "$CREDENTIALS_PATH" ]; then
    echo -e "${RED}[✗]${NC} 凭证文件不存在: $CREDENTIALS_PATH"
    exit 1
fi

echo -e "${GREEN}[✓]${NC} 凭证文件存在: $CREDENTIALS_PATH"

# 验证 JSON
if ! jq -e "." "$CREDENTIALS_PATH" > /dev/null 2>&1; then
    echo -e "${RED}[✗]${NC} 凭证文件不是有效的 JSON"
    exit 1
fi

echo -e "${GREEN}[✓]${NC} 凭证文件是有效的 JSON"

# 提取关键字段
API_KEY=$(jq -r '.api_key // empty' "$CREDENTIALS_PATH")
AGENT_NAME=$(jq -r '.agent_name // empty' "$CREDENTIALS_PATH")
PROFILE_URL=$(jq -r '.profile_url // empty' "$CREDENTIALS_PATH")

if [ -z "$API_KEY" ]; then
    echo -e "${RED}[✗]${NC} API密钥字段缺失"
    exit 1
fi

echo -e "${GREEN}[✓]${NC} API密钥已获取"
echo ""
echo "=== 凭证摘要 ==="
echo "Agent名称: ${AGENT_NAME:-未知}"
echo "主页URL: ${PROFILE_URL:-未知}"
echo "API密钥: ${API_KEY:0:15}... (隐藏后部分)"
echo ""

# 测试 API
echo "=== 测试 API 连接 ==="
FEED_RESPONSE=$(curl -s "https://www.moltbook.com/api/v1/feed?sort=hot&limit=1" \
    -H "Authorization: Bearer $API_KEY" \
    -H "Accept: application/json" 2>/dev/null | jq -r '.posts[0].id // ".null"' 2>/dev/null)

if [ "$FEED_RESPONSE" != ".null" ] && [ -n "$FEED_RESPONSE" ]; then
    echo -e "${GREEN}[✓]${NC} API 连接成功！"
    echo ""
    echo "=== 最终状态 ✅ ==="
    echo "凭证有效，系统就绪！"
    exit 0
else
    echo -e "${RED}[✗]${NC} API 连接失败，请检查网络或凭证"
    exit 1
fi