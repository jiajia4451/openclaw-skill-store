#!/bin/bash
# full-memory-reader.sh — QMD 完整记忆读取服务 (v1.0)
# 【系统服务】每4小时自动执行，完整读取所有记忆并生成摘要

WORKSPACE="/home/jiajia4451/.openclaw/workspace"
MEMORY_DIR="$WORKSPACE/memory"
REPORT_DIR="$MEMORY_DIR/qmd-reports"
DATE=$(date +%Y-%m-%d)
TIME=$(date +%H:%M)
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# 颜色输出
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

# 确保报告目录存在
mkdir -p "$REPORT_DIR"

REPORT_FILE="$REPORT_DIR/memory-report-${TIMESTAMP}.md"
SUMMARY_FILE="$REPORT_DIR/latest-summary.md"

echo -e "${GREEN}🧠 QMD 完整记忆读取服务启动${NC}"
echo "时间: $DATE $TIME"
echo "报告: $REPORT_FILE"
echo "================================"

# 初始化报告
cat > "$REPORT_FILE" << EOF
# 🧠 QMD 完整记忆读取报告

**读取时间**: $DATE $TIME  
**服务**: qmd-memory-reader (每4小时自动执行)  
**报告ID**: $TIMESTAMP

---

## 📊 记忆概览

### 文件统计
EOF

# 统计记忆文件
echo -e "${BLUE}📁 统计记忆文件...${NC}"
MEMORY_COUNT=$(find "$MEMORY_DIR" -name "*.md" -type f 2>/dev/null | wc -l)
DAY_MEMORY_COUNT=$(find "$MEMORY_DIR" -name "2026-*.md" -type f 2>/dev/null | wc -l)
PROJECT_COUNT=$(find "$MEMORY_DIR/projects" -name "*.md" -type f 2>/dev/null | wc -l)
REPORT_COUNT=$(find "$REPORT_DIR" -name "*.md" -type f 2>/dev/null | wc -l)

cat >> "$REPORT_FILE" << EOF
| 类型 | 数量 |
|------|------|
| 总记忆文件 | $MEMORY_COUNT |
| 每日记录 (YYYY-MM-DD.md) | $DAY_MEMORY_COUNT |
| 项目记忆 | $PROJECT_COUNT |
| 历史报告 | $REPORT_COUNT |

---

## 🔍 QMD 索引状态

EOF

# 检查 QMD 状态
echo -e "${BLUE}🔍 检查 QMD 索引状态...${NC}"
QMD_STATUS=$(qmd status 2>/dev/null)
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ QMD 运行正常${NC}"
    echo "### QMD 状态" >> "$REPORT_FILE"
    echo "\`\`\`" >> "$REPORT_FILE"
    echo "$QMD_STATUS" | head -20 >> "$REPORT_FILE"
    echo "\`\`\`" >> "$REPORT_FILE"
else
    echo -e "${RED}⚠️ QMD 状态异常${NC}"
    echo "⚠️ QMD 需要重新索引" >> "$REPORT_FILE"
fi

echo -e "\n---\n" >> "$REPORT_FILE"
echo -e "${BLUE}📚 读取核心记忆文件...${NC}"

# 读取核心文件摘要
echo "## 📚 核心记忆摘要" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# MEMORY.md 摘要
if [ -f "$WORKSPACE/MEMORY.md" ]; then
    echo -e "${CYAN}  📖 MEMORY.md${NC}"
    echo "### MEMORY.md (长期记忆)" >> "$REPORT_FILE"
    echo "**最后更新**: $(stat -c %y "$WORKSPACE/MEMORY.md" 2>/dev/null | cut -d' ' -f1)" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    echo "**关键章节**:" >> "$REPORT_FILE"
    grep -E "^## |^### " "$WORKSPACE/MEMORY.md" 2>/dev/null | head -10 >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
fi

# SOUL.md 摘要
if [ -f "$WORKSPACE/SOUL.md" ]; then
    echo -e "${CYAN}  👤 SOUL.md${NC}"
    echo "### SOUL.md (身份定义)" >> "$REPORT_FILE"
    echo "**最后更新**: $(stat -c %y "$WORKSPACE/SOUL.md" 2>/dev/null | cut -d' ' -f1)" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
fi

# USER.md 摘要
if [ -f "$WORKSPACE/USER.md" ]; then
    echo -e "${CYAN}  👤 USER.md${NC}"
    echo "### USER.md (用户信息)" >> "$REPORT_FILE"
    echo "**最后更新**: $(stat -c %y "$WORKSPACE/USER.md" 2>/dev/null | cut -d' ' -f1)" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
fi

# 今日记忆
TODAY_FILE="$MEMORY_DIR/$DATE.md"
if [ -f "$TODAY_FILE" ]; then
    echo -e "${CYAN}  📝 今日记忆 ($DATE.md)${NC}"
    echo "### 今日记忆 ($DATE)" >> "$REPORT_FILE"
    echo "**条目数**: $(grep -c "^## " "$TODAY_FILE" 2>/dev/null || echo 0)" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    echo "**今日要点**:" >> "$REPORT_FILE"
    grep -E "^## " "$TODAY_FILE" 2>/dev/null | head -5 >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
else
    echo -e "${YELLOW}  ⚠️ 今日记忆文件尚未创建${NC}"
    echo "### 今日记忆 ($DATE)" >> "$REPORT_FILE"
    echo "⚠️ 今日记忆文件尚未创建" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
fi

# 项目记忆
echo -e "\n---\n" >> "$REPORT_FILE"
echo -e "${BLUE}📂 读取项目记忆...${NC}"
echo "## 📂 项目记忆状态" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
if [ -d "$MEMORY_DIR/projects" ]; then
    for proj in "$MEMORY_DIR/projects"/*.md; do
        if [ -f "$proj" ]; then
            proj_name=$(basename "$proj" .md)
            proj_size=$(du -h "$proj" 2>/dev/null | cut -f1)
            last_update=$(stat -c %y "$proj" 2>/dev/null | cut -d' ' -f1)
            echo -e "${CYAN}  📁 $proj_name ($proj_size)${NC}"
            echo "- **$proj_name** | $proj_size | 更新: $last_update" >> "$REPORT_FILE"
        fi
    done
else
    echo "- 暂无项目记忆目录" >> "$REPORT_FILE"
fi

echo "" >> "$REPORT_FILE"

# QMD 搜索结果示例
echo -e "\n---\n" >> "$REPORT_FILE"
echo -e "${BLUE}🔍 执行示例搜索 (最近更新)...${NC}"
echo "## 🔍 智能搜索示例" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "### 最近的技能更新" >> "$REPORT_FILE"
echo "\`\`\`bash" >> "$REPORT_FILE"
cd "$WORKSPACE" && qmd search "skill" -n 3 2>/dev/null | head -20 >> "$REPORT_FILE"
echo "\`\`\`" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# 记忆健康度检查
echo "---" >> "$REPORT_FILE"
echo -e "${BLUE}🩺 执行记忆健康检查...${NC}"
echo "" >> "$REPORT_FILE"
echo "## 🩺 记忆健康度检查" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# 检查大文件 (>100KB)
echo -e "${YELLOW}  检查大文件...${NC}"
LARGE_FILES=$(find "$MEMORY_DIR" -name "*.md" -size +100k 2>/dev/null)
if [ -n "$LARGE_FILES" ]; then
    echo "⚠️ **大文件警告** (>100KB):" >> "$REPORT_FILE"
    echo "$LARGE_FILES" | while read f; do
        size=$(du -h "$f" 2>/dev/null | cut -f1)
        echo "  - $(basename "$f"): $size" >> "$REPORT_FILE"
    done
else
    echo "✅ 无 oversized 文件" >> "$REPORT_FILE"
fi

# 检查重复文件
echo -e "${YELLOW}  检查潜在重复...${NC}"
DUPLICATES=$(find "$MEMORY_DIR" -name "*副本*" -o -name "*copy*" -o -name "*backup*" 2>/dev/null | head -5)
if [ -n "$DUPLICATES" ]; then
    echo "" >> "$REPORT_FILE"
    echo "⚠️ **潜在重复文件**:" >> "$REPORT_FILE"
    echo "$DUPLICATES" | sed 's/^/  - /' >> "$REPORT_FILE"
else
    echo "" >> "$REPORT_FILE"
    echo "✅ 未发现重复文件" >> "$REPORT_FILE"
fi

# 完成报告
echo "" >> "$REPORT_FILE"
echo "---" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "## ✅ 读取完成" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "**总耗时**: $(date +%s) 秒" >> "$REPORT_FILE"
echo "**下次读取**: $(date -d '+4 hours' '+%Y-%m-%d %H:%M') (4小时后)" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "---" >> "$REPORT_FILE"
echo "*本报告由 qmd-memory-reader 自动生成*" >> "$REPORT_FILE"

# 更新最新摘要链接
ln -sf "$REPORT_FILE" "$SUMMARY_FILE"

echo ""
echo -e "${GREEN}✅ 完整记忆读取完成!${NC}"
echo -e "${CYAN}📄 报告位置: $REPORT_FILE${NC}"
echo -e "${CYAN}🔗 最新摘要: $SUMMARY_FILE${NC}"
echo ""
echo "关键发现:"
echo "  - 总记忆文件: $MEMORY_COUNT"
echo "  - 每日记录: $DAY_MEMORY_COUNT"
echo "  - 项目记忆: $PROJECT_COUNT"

# 输出报告路径 (供调用者使用)
echo ""
echo "REPORT_PATH: $REPORT_FILE"
