#!/bin/bash
# boot-memory-recovery.sh — Automatic memory recovery on OpenClaw boot
# This script is called by OpenClaw gateway on startup

SKILL_DIR="/home/jiajia4451/.openclaw/workspace/skills/memory-system"
LOG_FILE="/tmp/memory-recovery.log"

echo "[$(date '+%H:%M:%S')] Memory system boot recovery starting..." > "$LOG_FILE"

# Run recovery
if [ -f "$SKILL_DIR/scripts/recover.sh" ]; then
  "$SKILL_DIR/scripts/recover.sh" --report >> "$LOG_FILE" 2>&1
  echo "[$(date '+%H:%M:%S')] Memory recovery completed" >> "$LOG_FILE"
else
  echo "[$(date '+%H:%M:%S')] ERROR: recover.sh not found" >> "$LOG_FILE"
fi

# Check for session reset
if [ -f "$SKILL_DIR/scripts/reset-report.sh" ]; then
  "$SKILL_DIR/scripts/reset-report.sh" >> "$LOG_FILE" 2>&1
fi

echo "[$(date '+%H:%M:%S')] Memory system boot complete" >> "$LOG_FILE"
