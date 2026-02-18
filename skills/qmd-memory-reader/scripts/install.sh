#!/bin/bash
# install.sh — QMD Memory Reader Service 安装脚本

WORKSPACE="/home/jiajia4451/.openclaw/workspace"
SKILL_DIR="$WORKSPACE/skills/qmd-memory-reader"
CRON_FILE="/tmp/qmd-reader-cron.txt"

echo "🧠 安装 QMD Memory Reader 系统服务..."

# 创建目录
mkdir -p "$SKILL_DIR/scripts"
mkdir -p "$SKILL_DIR/config"
mkdir -p "$WORKSPACE/memory/qmd-reports"

# 设置权限
chmod +x "$SKILL_DIR/scripts/full-memory-reader.sh"

# 注册 cron 任务 (每4小时执行一次)
echo "⏰ 注册定时任务 (每4小时)..."

# 获取当前用户的 crontab
crontab -l 2>/dev/null > "$CRON_FILE" || true

# 检查是否已存在
if ! grep -q "qmd-memory-reader" "$CRON_FILE"; then
    echo "# QMD Memory Reader - 每4小时完整读取记忆" >> "$CRON_FILE"
    echo "0 */4 * * * cd $SKILL_DIR/scripts && bash full-memory-reader.sh >> $WORKSPACE/memory/qmd-reports/cron.log 2>&1" >> "$CRON_FILE"
    crontab "$CRON_FILE"
    echo "✅ Cron 任务已注册"
else
    echo "ℹ️ Cron 任务已存在，跳过"
fi

rm -f "$CRON_FILE"

# 创建系统服务状态文件
cat > "$SKILL_DIR/config/service-status.json" << EOF
{
  "name": "qmd-memory-reader",
  "version": "1.0.0",
  "type": "system_service",
  "installed_at": "$(date -Iseconds)",
  "schedule": "0 */4 * * *",
  "status": "active",
  "last_run": null,
  "report_dir": "$WORKSPACE/memory/qmd-reports"
}
EOF

echo ""
echo "✅ QMD Memory Reader 安装完成!"
echo ""
echo "📋 服务信息:"
echo "  - 执行频率: 每4小时"
echo "  - 报告位置: $WORKSPACE/memory/qmd-reports/"
echo "  - 核心脚本: $SKILL_DIR/scripts/full-memory-reader.sh"
echo ""
echo "🚀 手动测试:"
echo "  bash $SKILL_DIR/scripts/full-memory-reader.sh"
echo ""
echo "📊 查看 cron:"
echo "  crontab -l | grep qmd-memory-reader"
