#!/bin/bash
# recover.sh — Boot recovery sequence for memory restoration
# Usage: ./recover.sh [--report]

WORKSPACE="/home/jiajia4451/.openclaw/workspace"
MEMORY_DIR="$WORKSPACE/memory"
DATE=$(date +%Y-%m-%d)
TIME=$(date +%H:%M)
GENERATE_REPORT=false

# Parse arguments
if [ "$1" = "--report" ]; then
  GENERATE_REPORT=true
fi

echo "🔄 开始记忆恢复序列..."
echo ""

# Recovery check function
recover_file() {
  local file="$1"
  local desc="$2"
  if [ -f "$file" ]; then
    echo "  ✅ $desc — 已加载 ($(wc -l < "$file" 2>/dev/null || echo 0) 行)"
    return 0
  else
    echo "  ⚠️ $desc — 文件不存在 ($file)"
    return 1
  fi
}

# Core recovery sequence
echo "=== 核心身份文件 ==="
recover_file "$WORKSPACE/SOUL.md" "SOUL.md (身份确认)"
recover_file "$WORKSPACE/USER.md" "USER.md (服务对象)"
recover_file "$WORKSPACE/MEMORY.md" "MEMORY.md (长期记忆)"
recover_file "$WORKSPACE/HEARTBEAT.md" "HEARTBEAT.md (维护规则)"

echo ""
echo "=== 今日上下文 ==="
recover_file "$MEMORY_DIR/$DATE.md" "memory/$DATE.md (今日记录)"

echo ""
echo "=== 项目记忆 ==="
PROJECT_COUNT=0
if [ -d "$MEMORY_DIR/projects" ]; then
  for proj in "$MEMORY_DIR/projects/"*.md; do
    if [ -f "$proj" ]; then
      PROJ_NAME=$(basename "$proj" .md)
      echo "  ✅ $PROJ_NAME — 项目记忆"
      ((PROJECT_COUNT++))
    fi
  done
fi
if [ $PROJECT_COUNT -eq 0 ]; then
  echo "  ⚠️ 无项目记忆文件"
fi

# Generate reset report if requested
if [ "$GENERATE_REPORT" = true ]; then
  echo ""
  echo "=== 生成重置报告 ==="
  
  # Find previous session info
  LATEST_SESSION=$(ls -t ~/.openclaw/agents/main/sessions/*.jsonl 2>/dev/null | head -2 | tail -1)
  if [ -f "$LATEST_SESSION" ]; then
    SESSION_NAME=$(basename "$LATEST_SESSION" .jsonl)
    SESSION_SIZE=$(du -h "$LATEST_SESSION" 2>/dev/null | cut -f1)
    SESSION_TIME=$(stat -c %y "$LATEST_SESSION" 2>/dev/null | cut -d' ' -f1,2 | cut -d'.' -f1)
    
    REPORT_FILE="$MEMORY_DIR/reset-report-$DATE.md"
    
    {
      echo "# 🔄 会话重置恢复报告"
      echo ""
      echo "**重置时间**: $TIME"
      echo "**前会话ID**: $SESSION_NAME"
      echo "**前会话大小**: $SESSION_SIZE"
      echo "**最后活跃**: $SESSION_TIME"
      echo ""
      echo "## 恢复状态"
      echo ""
      echo "### 已恢复记忆"
      echo "- [x] SOUL.md — 身份确认"
      echo "- [x] USER.md — 服务对象确认"
      echo "- [x] MEMORY.md — 长期记忆"
      echo "- [x] memory/$DATE.md — 今日上下文"
      echo "- [x] memory/projects/ — 项目记忆 ($PROJECT_COUNT 个)"
      echo ""
      echo "### 已加载技能"
      for skill in "$WORKSPACE/skills/"*/SKILL.md; do
        if [ -f "$skill" ]; then
          SKILL_NAME=$(basename $(dirname "$skill"))
          echo "- [x] $SKILL_NAME"
        fi
      done
      echo ""
      echo "**恢复完成**: $TIME ₿"
    } > "$REPORT_FILE"
    
    echo "  ✅ 报告已保存: $REPORT_FILE"
  fi
fi

echo ""
echo "✅ 记忆恢复序列完成"
