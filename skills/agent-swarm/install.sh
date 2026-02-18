#!/bin/bash
# agent-swarm - 安装脚本

set -e

echo "🚀 安装 agent-swarm..."

SKILL_DIR="/home/jiajia4451/.openclaw/skills/agent-swarm"
REPO_URL="https://github.com/jiajia4451/openclaw-skill-store"

cd ~/.openclaw/workspace

# 使用稀疏检出
if [ -d "" ]; then
    echo "📝 更新 agent-swarm..."
    cd ""
    git pull origin skills
else
    echo "📦 下载 agent-swarm..."
    mkdir -p ""
    cd ""
    git init
    git remote add origin ""
    git config core.sparseCheckout true
    echo "skills/agent-swarm/*" > .git/info/sparse-checkout
    git pull origin skills
fi

# 添加到PATH
SCRIPT_DIR="/skills/agent-swarm/scripts"
if ! echo $PATH | grep -q ""; then
    echo "export PATH=\":$PATH\"" >> ~/.bashrc
    echo "✅ 已添加到 PATH"
fi

# 初始化
if [ -f "/agent-swarm.sh" ] || [ -f "/router.sh" ] || [ -f "/swarm.sh" ] || [ -f "/batcher.sh" ]; then
    echo "🔧 初始化配置..."
    # 查找主脚本
    for script in "/agent-swarm.sh" "/router.sh" "/swarm.sh" "/batcher.sh"; do
        if [ -f "$script" ]; then
            "$script" init 2>/dev/null || true
            break
        fi
    done
fi

echo "✅ agent-swarm 安装完成！"
echo ""
echo "使用方法:"
if [ -f "/agent-swarm.sh" ]; then
    echo "  agent-swarm --help"
else
    echo "  agent-swarm init"
fi
