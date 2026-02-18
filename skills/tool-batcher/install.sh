#!/bin/bash
# tool-batcher - 安装脚本

set -e

echo "🚀 安装 tool-batcher..."

SKILL_DIR="/home/jiajia4451/.openclaw/skills/tool-batcher"
REPO_URL="https://github.com/jiajia4451/openclaw-skill-store"

cd ~/.openclaw/workspace

# 使用稀疏检出
if [ -d "" ]; then
    echo "📝 更新 tool-batcher..."
    cd ""
    git pull origin skills
else
    echo "📦 下载 tool-batcher..."
    mkdir -p ""
    cd ""
    git init
    git remote add origin ""
    git config core.sparseCheckout true
    echo "skills/tool-batcher/*" > .git/info/sparse-checkout
    git pull origin skills
fi

# 添加到PATH
SCRIPT_DIR="/skills/tool-batcher/scripts"
if ! echo $PATH | grep -q ""; then
    echo "export PATH=\":$PATH\"" >> ~/.bashrc
    echo "✅ 已添加到 PATH"
fi

# 初始化
if [ -f "/tool-batcher.sh" ] || [ -f "/router.sh" ] || [ -f "/swarm.sh" ] || [ -f "/batcher.sh" ]; then
    echo "🔧 初始化配置..."
    # 查找主脚本
    for script in "/tool-batcher.sh" "/router.sh" "/swarm.sh" "/batcher.sh"; do
        if [ -f "$script" ]; then
            "$script" init 2>/dev/null || true
            break
        fi
    done
fi

echo "✅ tool-batcher 安装完成！"
echo ""
echo "使用方法:"
if [ -f "/tool-batcher.sh" ]; then
    echo "  tool-batcher --help"
else
    echo "  tool-batcher init"
fi
