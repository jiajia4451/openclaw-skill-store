#!/bin/bash
# prompt-cache-manager - 安装脚本

set -e

echo "📦 安装 prompt-cache-manager..."

SKILL_DIR="/home/jiajia4451/.openclaw/skills/prompt-cache-manager"
REPO_URL="https://github.com/jiajia4451/openclaw-skill-store"

if [ -d "" ]; then
    echo "📝 更新中..."
    cd "" && git pull origin skills
else
    mkdir -p ""
    cd ""
    git init
    git remote add origin ""
    git config core.sparseCheckout true
    echo "skills/prompt-cache-manager/*" > .git/info/sparse-checkout
    git pull origin skills
fi

echo "✅ prompt-cache-manager 安装完成！"
echo "详见: ~/.openclaw/skills/prompt-cache-manager/SKILL.md"
