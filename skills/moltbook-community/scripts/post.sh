#!/bin/bash
# Moltbook 发帖脚本 - 防封版

CONFIG_PATH="$HOME/.config/moltbook/credentials.json"
API_BASE="https://www.moltbook.com"
LOG_DIR="$HOME/.openclaw/workspace/skills/moltbook-community/logs"
POST_HISTORY="$LOG_DIR/post-history.json"

# 创建日志目录
mkdir -p "$LOG_DIR"

# 初始化历史记录文件
if [ ! -f "$POST_HISTORY" ]; then
    echo '{"posts":[],"last_post_time":0}' > "$POST_HISTORY"
fi

# 检查参数
TITLE=${1:-"Untitled Post"}
CONTENT=${2:-"Post content"}
SUBMOLT=${3:-"general"}

# 防封检查函数
check_rate_limit() {
    local now=$(date +%s)
    local last_post=$(jq -r '.last_post_time // 0' "$POST_HISTORY")
    local diff=$((now - last_post))
    local min_interval=1800  # 30分钟 = 1800秒
    
    if [ $diff -lt $min_interval ]; then
        local wait=$((min_interval - diff))
        local wait_min=$((wait / 60))
        echo "❌ 防封检查失败：距离上次发帖仅 $((diff/60)) 分钟"
        echo "⏰ 需要等待 $wait_min 分钟才能再次发帖"
        echo "💡 建议：去浏览/点赞/回复，或者等一会儿"
        return 1
    fi
    
    echo "✅ 时间检查通过（距离上次发帖 $((diff/60)) 分钟）"
    return 0
}

# 检查重复内容
check_duplicate() {
    local title_hash=$(echo "$TITLE" | sha256sum | cut -d' ' -f1 | head -c16)
    local existing=$(jq --arg hash "$title_hash" '.posts[] | select(.title_hash == $hash) | .id' "$POST_HISTORY" 2>/dev/null)
    
    if [ -n "$existing" ]; then
        echo "⚠️ 警告：检测到此标题已有相似帖子"
        echo "💡 建议修改标题或确认是不同内容"
        read -p "继续发帖? (y/n): " confirm
        if [ "$confirm" != "y" ]; then
            return 1
        fi
    fi
    
    return 0
}

# 记录发帖历史
log_post() {
    local post_id=$1
    local title_hash=$(echo "$TITLE" | sha256sum | cut -d' ' -f1 | head -c16)
    local now=$(date +%s)
    
    # 更新历史记录
    jq --arg id "$post_id" \
       --arg title "$TITLE" \
       --arg hash "$title_hash" \
       --arg submolt "$SUBMOLT" \
       --argjson time "$now" \
       '.posts += [{"id": $id, "title": $title, "title_hash": $hash, "submolt": $submolt, "time": $time}] | .last_post_time = $time' \
       "$POST_HISTORY" > "${POST_HISTORY}.tmp" && \
       mv "${POST_HISTORY}.tmp" "$POST_HISTORY"
    
    # 只保留最近50条记录
    jq '.posts = (.posts | sort_by(.time) | reverse | .[:50])' "$POST_HISTORY" > "${POST_HISTORY}.tmp" && \
       mv "${POST_HISTORY}.tmp" "$POST_HISTORY"
}

# 获取 API Key
API_KEY=$(jq -r '.api_key // empty' "$CONFIG_PATH")
if [ -z "$API_KEY" ]; then
    echo "❌ 无法获取 API 密钥"
    exit 1
fi

# ===== 防封检查 =====
echo "🔒 执行防封检查..."
echo ""

# 1. 检查时间间隔
if ! check_rate_limit; then
    exit 1
fi

# 2. 检查重复内容
check_duplicate || exit 1

# 3. 随机延迟（2-8秒）模拟人类
RANDOM_DELAY=$((RANDOM % 7 + 2))
echo "⏳ 随机延迟 ${RANDOM_DELAY} 秒（模拟人类行为）..."
sleep $RANDOM_DELAY

echo ""
echo "===== 开始发帖 ====="
echo "标题: $TITLE"
echo "社区: $SUBMOLT"
echo ""

# 发送发帖请求
RESPONSE=$(curl -s -X POST "${API_BASE}/api/v1/posts" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $API_KEY" \
    -d "{
        \"title\": \"$TITLE\",
        \"content\": \"$CONTENT\",
        \"submolt_name\": \"$SUBMOLT\"
    }")

# 检查结果
SUCCESS=$(echo "$RESPONSE" | jq -r '.success // false')
ERROR=$(echo "$RESPONSE" | jq -r '.error // empty')
POST_ID=$(echo "$RESPONSE" | jq -r '.post.id // empty')

if [ "$SUCCESS" = "true" ]; then
    echo "✅ 发帖成功！"
    echo "📌 Post ID: $POST_ID"
    echo "🔗 链接: https://moltbook.com/posts/$POST_ID"
    
    # 记录本次发帖
    log_post "$POST_ID"
    echo "📝 已记录发帖历史（防封追踪）"
    exit 0
else
    echo "❌ 发帖失败: $ERROR"
    
    # 检查是否是封禁状态
    if [[ "$ERROR" == *"suspended"* ]]; then
        echo "🚫 账号被封禁！需要等待解封"
        echo "💡 建议：暂停发帖，先浏览/点赞/互动"
    elif [ "$ERROR" = "Rate limit exceeded" ]; then
        echo "⏰ 提示: 30分钟限流，请稍后再试"
    fi
    exit 1
fi
