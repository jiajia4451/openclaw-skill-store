#!/bin/bash
# reset-report.sh — Detect session reset and generate structured report
# Usage: ./reset-report.sh [previous_session_id]

WORKSPACE="/home/jiajia4451/.openclaw/workspace"
MEMORY_DIR="$WORKSPACE/memory"
DATE=$(date +%Y-%m-%d)
TIME=$(date +%H:%M)
SESSIONS_DIR="$HOME/.openclaw/agents/main/sessions"

echo "🔄 会话重置检测与报告"
echo ""

# Find sessions
CURRENT_SESSION=$(ls -t "$SESSIONS_DIR"/*.jsonl 2>/dev/null | head -1)
PREV_SESSION=$(ls -t "$SESSIONS_DIR"/*.jsonl 2>/dev/null | head -2 | tail -1)

if [ -f "$CURRENT_SESSION" ]; then
  CURRENT_NAME=$(basename "$CURRENT_SESSION" .jsonl)
  CURRENT_SIZE=$(du -h "$CURRENT_SESSION" 2>/dev/null | cut -f1)
  CURRENT_TIME=$(stat -c %y "$CURRENT_SESSION" 2>/dev/null | cut -d' ' -f2 | cut -d'.' -f1 | cut -d':' -f1,2)
  
  echo "=== 当前会话 ==="
  echo "  ID: $CURRENT_NAME"
  echo "  大小: $CURRENT_SIZE"
  echo "  创建: $CURRENT_TIME"
fi

if [ -f "$PREV_SESSION" ]; then
  PREV_NAME=$(basename "$PREV_SESSION" .jsonl)
  PREV_SIZE=$(du -h "$PREV_SESSION" 2>/dev/null | cut -f1)
  PREV_TIME=$(stat -c %y "$PREV_SESSION" 2>/dev/null | cut -d' ' -f2 | cut -d'.' -f1 | cut -d':' -f1,2)
  
  echo ""
  echo "=== 前一会话 ==="
  echo "  ID: $PREV_NAME"
  echo "  大小: $PREV_SIZE"
  echo "  最后活跃: $PREV_TIME"
fi

# Check if reset occurred (current session is new and small, previous was large)
if [ -f "$CURRENT_SESSION" ] && [ -f "$PREV_SESSION" ]; then
  CURRENT_BYTES=$(stat -c %s "$CURRENT_SESSION" 2>/dev/null || echo 0)
  PREV_BYTES=$(stat -c %s "$PREV_SESSION" 2>/dev/null || echo 0)
  
  # If prev session > 1MB and current is small, likely a reset
  if [ $PREV_BYTES -gt 1048576 ] && [ $CURRENT_BYTES -lt 1048576 ]; then
    echo ""
    echo "⚠️ 检测到会话重置!"
    echo "   前会话: $(du -h "$PREV_SESSION" | cut -f1)"
    echo "   当前会话: $(du -h "$CURRENT_SESSION" | cut -f1)"
    
    # Generate detailed report
    REPORT_FILE="$MEMORY_DIR/reset-report-$DATE-$TIME.md"
    
    {
      echo "# 🔄 会话重置报告"
      echo ""
      echo "**检测时间**: $TIME"
      echo "**前会话ID**: $PREV_NAME"
      echo "**前会话大小**: $(du -h "$PREV_SESSION" | cut -f1)"
      echo "**当前会话ID**: $CURRENT_NAME"
      echo "**当前会话大小**: $(du -h "$CURRENT_SESSION" | cut -f1)"
      echo "**可能原因**: OpenClaw自动生命周期管理 (>5MB或>12h)"
      echo ""
      echo "## 已恢复记忆状态"
      echo ""
      echo "### 核心文件"
      [ -f "$WORKSPACE/SOUL.md" ] && echo "- [x] SOUL.md" || echo "- [ ] SOUL.md (缺失)"
      [ -f "$WORKSPACE/USER.md" ] && echo "- [x] USER.md" || echo "- [ ] USER.md (缺失)"
      [ -f "$WORKSPACE/MEMORY.md" ] && echo "- [x] MEMORY.md" || echo "- [ ] MEMORY.md (缺失)"
      [ -f "$MEMORY_DIR/$DATE.md" ] && echo "- [x] memory/$DATE.md" || echo "- [ ] memory/$DATE.md (缺失)"
      echo ""
      echo "### 项目记忆"
      for proj in "$MEMORY_DIR/projects/"*.md; do
        if [ -f "$proj" ]; then
          echo "- [x] $(basename "$proj" .md)"
        fi
      done
      echo ""
      echo "### 技能系统"
      for skill in "$WORKSPACE/skills/"*/SKILL.md; do
        if [ -f "$skill" ]; then
          echo "- [x] $(basename $(dirname "$skill"))"
        fi
      done
      echo ""
      echo "## 恢复完成"
      echo ""
      echo "记忆系统已自动恢复上下文。如有遗漏，请告诉我。"
      echo ""
      echo "**报告生成**: $TIME ₿"
    } > "$REPORT_FILE"
    
    echo ""
    echo "✅ 详细报告已保存: $REPORT_FILE"
  fi
fi

echo ""
echo "✅ 重置检测完成"
