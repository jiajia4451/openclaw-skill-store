#!/bin/bash
# install.sh — QMD Memory Cleaner Service 安装脚本

WORKSPACE="/home/jiajia4451/.openclaw/workspace"
SKILL_DIR="$WORKSPACE/skills/qmd-memory-cleaner"

echo "🧹 安装 QMD Memory Cleaner 系统服务..."

# 创建目录
mkdir -p "$SKILL_DIR/scripts"
mkdir -p "$SKILL_DIR/config"
mkdir -p "$WORKSPACE/memory/cleaner-reports"

# 设置权限
chmod +x "$SKILL_DIR/scripts/memory-cleaner.sh"

# 创建系统服务状态文件
cat > "$SKILL_DIR/config/service-status.json" << EOF
{
  "name": "qmd-memory-cleaner",
  "version": "1.0.0",
  "type": "system_service",
  "installed_at": "$(date -Iseconds)",
  "trigger": "manual",
  "status": "active",
  "last_run": null,
  "report_dir": "$WORKSPACE/memory/cleaner-reports"
}
EOF

echo ""
echo "✅ QMD Memory Cleaner 安装完成!"
echo ""
echo "📋 服务信息:"
echo "  - 触发方式: 手动 (按需执行)"
echo "  - 报告位置: $WORKSPACE/memory/cleaner-reports/"
echo "  - 核心脚本: $SKILL_DIR/scripts/memory-cleaner.sh"
echo ""
echo "🚀 使用方法:"
echo "  bash $SKILL_DIR/scripts/memory-cleaner.sh"
echo ""
echo "⚠️ 警告: 本服务仅生成清理建议，不会自动删除任何文件!"
