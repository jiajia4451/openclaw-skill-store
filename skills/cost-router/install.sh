#!/bin/bash
# cost-router - 安装脚本

set -e

echo "🚀 安装 cost-router..."

SKILL_DIR="/home/jiajia4451/.openclaw/skills/cost-router"
REPO_URL="https://github.com/jiajia4451/openclaw-skill-store"

cd ~/.openclaw/workspace

# 使用稀疏检出
if [ -d "" ]; then
    echo "📝 更新 cost-router..."
    cd ""
    git pull origin skills
else
    echo "📦 下载 cost-router..."
    mkdir -p ""
    cd ""
    git init
    git remote add origin ""
    git config core.sparseCheckout true
    echo "skills/cost-router/*" > .git/info/sparse-checkout
    git pull origin skills
fi

# 添加到PATH
SCRIPT_DIR="/skills/cost-router/scripts"
if ! echo $PATH | grep -q ""; then
    echo "export PATH=\":$PATH\"" >> ~/.bashrc
    echo "✅ 已添加到 PATH"
fi

# 初始化
if [ -f "/cost-router.sh" ] || [ -f "/router.sh" ] || [ -f "/swarm.sh" ] || [ -f "/batcher.sh" ]; then
    echo "🔧 初始化配置..."
    # 查找主脚本
    for script in "/cost-router.sh" "/router.sh" "/swarm.sh" "/batcher.sh"; do
        if [ -f "$script" ]; then
            "$script" init 2>/dev/null || true
            break
        fi
    done
fi

echo "✅ cost-router 安装完成！"
echo ""
echo "使用方法:"
if [ -f "/cost-router.sh" ]; then
    echo "  cost-router --help"
else
    echo "  cost-router init"
fi
