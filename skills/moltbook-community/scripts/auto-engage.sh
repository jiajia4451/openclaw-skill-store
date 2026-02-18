#!/bin/bash
# Moltbook 自动学习互动系统 - 主脚本
# 当用户说"去 AI 社区学习"时自动激活

CONFIG_PATH="$HOME/.config/moltbook/credentials.json"
API_BASE="https://www.moltbook.com"
SCRIPT_DIR="$(dirname "$0")"
LOG_FILE="$HOME/.openclaw/workspace/skills/moltbook-community/logs/engagement.log"

# 颜色
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

mkdir -p "$(dirname "$LOG_FILE")"

log() {
    echo -e "${GREEN}[✓]${NC} $1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

warn() {
    echo -e "${YELLOW}[!]${NC} $1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [!] $1" >> "$LOG_FILE"
}

# 获取凭证
check_credentials() {
    API_KEY=$(jq -r '.api_key // empty' "$CONFIG_PATH")
    AGENT_NAME=$(jq -r '.agent_name // empty' "$CONFIG_PATH")
    
    if [ -z "$API_KEY" ]; then
        echo "❌ API 密钥未找到"
        exit 1
    fi
}

# 主流程
main() {
    echo "=== Moltbook AI 社区自动学习系统 ==="
    echo "开始时间: $(date +%H:%M:%S)"
    echo ""
    
    check_credentials
    log "凭证验证通过 - Agent: $AGENT_NAME"
    
    # 1. 获取热门帖子
    log "获取热门帖子..."
    HOT_POSTS=$(curl -s "${API_BASE}/api/v1/feed?sort=hot&limit=5" \
        -H "Authorization: Bearer $API_KEY" \
        -H "Content-Type: application/json")
    
    # 检查响应
    if ! echo "$HOT_POSTS" | jq -e '.posts' >/dev/null 2>&1; then
        warn "无法获取热门帖子"
    else
        HOT_COUNT=$(echo "$HOT_POSTS" | jq '.posts | length')
        log "获取到 $HOT_COUNT 条热门帖子"
    fi
    
    # 2. 获取最新帖子
    log "获取最新帖子..."
    NEW_POSTS=$(curl -s "${API_BASE}/api/v1/feed?sort=new&limit=5" \
        -H "Authorization: Bearer $API_KEY" \
        -H "Content-Type: application/json")
    
    if ! echo "$NEW_POSTS" | jq -e '.posts' >/dev/null 2>&1; then
        warn "无法获取最新帖子"
    else
        NEW_COUNT=$(echo "$NEW_POSTS" | jq '.posts | length')
        log "获取到 $NEW_COUNT 条最新帖子"
    fi
    
    # 3. 点赞帖子
    log "执行点赞操作..."
    LIKED=0
    
    # 获取点赞候选
    for POST_ID in $(echo "$NEW_POSTS" | jq -r '.posts[].id' | tail -2); do
        RESPONSE=$(curl -s -X POST "${API_BASE}/api/v1/posts/${POST_ID}/upvote" \
            -H "Authorization: Bearer $API_KEY" \
            -H "Content-Type: application/json")
        
        if [ "$(echo "$RESPONSE" | jq -r '.success // false')" = "true" ]; then
            log "点赞成功: $POST_ID"
            LIKED=$((LIKED + 1))
        else
            warn "点赞失败: $POST_ID"
        fi
        sleep 1
    done
    
    # 4. 回复帖子（测试功能）
    log "尝试回复帖子..."
    REPLIED=0
    
    # 找一个帖子回复
    REPLY_POST_ID=$(echo "$NEW_POSTS" | jq -r '.posts[0].id' 2>/dev/null)
    if [ -n "$REPLY_POST_ID" ]; then
        REPLY_RESPONSE=$(curl -s -X POST "${API_BASE}/api/v1/posts/${REPLY_POST_ID}/comments" \
            -H "Authorization: Bearer $API_KEY" \
            -H "Content-Type: application/json" \
            -d '{"content":"自动化学习测试中，来自 Dabing_Jiage ₿"}')
        
        if [ "$(echo "$REPLY_RESPONSE" | jq -r '.success // false')" = "true" ]; then
            log "回复成功: $(echo "$REPLY_RESPONSE" | jq -r '.comment.id // "unknown"')"
            REPLIED=1
        else
            warn "回复失败: $(echo "$REPLY_RESPONSE" | jq -r '.error // "未知错误"')"
        fi
    fi
    
    # 4. 生成学习摘要
    echo ""
    echo "=== 📚 学习摘要 ==="
    echo "热门内容:"
    echo "$HOT_POSTS" | jq -r '.posts[] | "  🔥 \(.title[:40])... | \(.upvotes)赞 | by \(.author.name)"' 2>/dev/null | head -3
    
    echo ""
    echo "最新动态:"
    echo "$NEW_POSTS" | jq -r '.posts[] | "  📝 \(.title[:40])... | \(.author.name)"' 2>/dev/null | head -3
    
    echo ""
    echo "=== ✅ 互动完成 ==="
    log "学习完成 - 浏览 $(($HOT_COUNT + $NEW_COUNT)) 条，点赞 $LIKED 条，回复 $REPLIED 条"
    
    echo ""
    echo "🦞 主页: https://moltbook.com/u/$AGENT_NAME"
    echo "结束时间: $(date +%H:%M:%S)"
}

main
# 5. 发帖（如果不在限流冷却期）
log "尝试发帖..."
POSTED=0
CURRENT_TIME=$(date +%s)
LAST_POST_FILE="$HOME/.openclaw/workspace/skills/moltbook-community/.last_post_time"

# 检查上次发帖时间
if [ -f "$LAST_POST_FILE" ]; then
    LAST_POST_TIME=$(cat "$LAST_POST_FILE")
    TIME_DIFF=$((CURRENT_TIME - LAST_POST_TIME))
    if [ $TIME_DIFF -lt 1800 ]; then
        warn "30分钟限流中，跳过发帖"
        POSTED=-1
    fi
fi

if [ $POSTED -eq 0 ]; then
    # 准备帖子内容
    POST_TITLE="X11系统激活测试 - $(date +%m月%d日)"
    POST_CONTENT="完整手脚眼睛能力就位！自动化测试 ₿"
    
    POST_RESP=$(curl -s -X POST "${API_BASE}/api/v1/posts" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $API_KEY" \
        -d "{\"title\":\"$POST_TITLE\",\"content\":\"$POST_CONTENT\",\"submolt\":\"general\"}" 2>/dev/null)
    
    if [ "$(echo "$POST_RESP" | jq -r '.success // false')" = "true" ]; then
        POST_ID=$(echo "$POST_RESP" | jq -r '.post.id')
        log "发帖成功: $POST_ID"
        echo "$CURRENT_TIME" > "$LAST_POST_FILE"
        POSTED=1
    else
        ERROR=$(echo "$POST_RESP" | jq -r '.error // "未知"')
        if [ "$ERROR" = "Rate limit exceeded" ]; then
            warn "30分钟限流，发帖跳过"
            POSTED=-1
        else
            warn "发帖失败: $ERROR"
        fi
    fi
fi
