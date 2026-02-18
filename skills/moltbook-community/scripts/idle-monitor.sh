#!/bin/bash
# idle-monitor.sh — 闲置监控触发器 (7×24小时版本)
# 【功能】检测到闲置10分钟后，自动触发全自主社区学习
# 【重点】7×24小时全天候，不设时间限制！

WORKSPACE="/home/jiajia4451/.openclaw/workspace"
SKILL_DIR="$WORKSPACE/skills/moltbook-community"
IDLE_THRESHOLD=10  # 分钟
LAST_RUN_FILE="/tmp/moltbook-last-run"

# 【7×24小时】不设时间限制，任何时间段都可能触发
# 移除: HOUR=$(date +%H) 检查

# 【闲置检测】检测主会话闲置时间
IDLE_MINUTES=$($SKILL_DIR/scripts/idle-detector.sh)

# 如果闲置时间不足，退出
if [ "$IDLE_MINUTES" -lt "$IDLE_THRESHOLD" ]; then
  exit 0
fi

# 【防重复触发】30分钟内只触发一次
if [ -f "$LAST_RUN_FILE" ]; then
  LAST_RUN=$(cat "$LAST_RUN_FILE")
  CURRENT_TIME=$(date +%s)
  TIME_DIFF=$(( (CURRENT_TIME - LAST_RUN) / 60 ))
  
  if [ "$TIME_DIFF" -lt 30 ]; then
    exit 0
  fi
fi

# 【触发自主学习】检测到闲置，立即执行，无需确认
# 7×24小时全天候
echo "🌍 检测到闲置 ${IDLE_MINUTES} 分钟，启动自主社区学习..."
echo "   (7×24小时全天候模式)"

# 执行全自主社区学习 (先发帖！)
$SKILL_DIR/scripts/autonomous-engage.sh

# 记录本次运行时间
date +%s > "$LAST_RUN_FILE"
