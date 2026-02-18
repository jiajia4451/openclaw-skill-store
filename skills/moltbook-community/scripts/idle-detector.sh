#!/bin/bash
# idle-detector.sh — 检测主会话闲置时间 (v3.0)
# 【改进】正确解析毫秒级 Unix 时间戳

WORKSPACE="/home/jiajia4451/.openclaw/workspace"
SESSIONS_DIR="$HOME/.openclaw/agents/main/sessions"
IDLE_LOG="$WORKSPACE/.idle-tracker.log"

# 找到当前活跃会话
CURRENT_SESSION=$(ls -t "$SESSIONS_DIR"/*.jsonl 2>/dev/null | head -1)

if [ ! -f "$CURRENT_SESSION" ]; then
  echo "0"
  exit 0
fi

# 获取当前会话中最后一条用户消息的时间戳 (毫秒级)
LAST_USER_MSG_MS=0

if [ -f "$CURRENT_SESSION" ]; then
  # 提取最后一条用户消息的时间戳 (毫秒级 Unix timestamp)
  LAST_USER_LINE=$(grep '"role":"user"' "$CURRENT_SESSION" 2>/dev/null | tail -1)
  
  if [ -n "$LAST_USER_LINE" ]; then
    # 提取数字格式的时间戳 (毫秒级)
    LAST_USER_MSG_MS=$(echo "$LAST_USER_LINE" | grep -o '"timestamp":[0-9]*' | tail -1 | cut -d':' -f2)
  fi
fi

# 如果没有找到用户消息，使用文件修改时间 (转换为毫秒)
if [ -z "$LAST_USER_MSG_MS" ] || [ "$LAST_USER_MSG_MS" -eq 0 ]; then
  LAST_MOD_SEC=$(stat -c %Y "$CURRENT_SESSION" 2>/dev/null)
  LAST_USER_MSG_MS=$((LAST_MOD_SEC * 1000))
fi

# 获取当前时间 (毫秒级)
CURRENT_TIME_MS=$(date +%s%3N 2>/dev/null || echo $(( $(date +%s) * 1000 )))

# 计算闲置时间（分钟）
IDLE_MS=$((CURRENT_TIME_MS - LAST_USER_MSG_MS))
IDLE_MINUTES=$((IDLE_MS / 60000))

# 确保不为负数
if [ "$IDLE_MINUTES" -lt 0 ]; then
  IDLE_MINUTES=0
fi

# 调试日志
if [ -n "$IDLE_LOG" ]; then
  echo "$(date '+%H:%M:%S') - Session: $(basename $CURRENT_SESSION .jsonl), Idle: ${IDLE_MINUTES}min" >> "$IDLE_LOG" 2>/dev/null
fi

echo "$IDLE_MINUTES"
