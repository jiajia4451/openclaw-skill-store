#!/bin/bash
# memory-cleaner.sh — QMD 记忆清理服务 (v1.0)
# 【系统服务】分析无用/过时记忆，生成清理建议报告

WORKSPACE="/home/jiajia4451/.openclaw/workspace"
MEMORY_DIR="$WORKSPACE/memory"
CLEANER_DIR="$MEMORY_DIR/cleaner-reports"
DATE=$(date +%Y-%m-%d)
TIME=$(date +%H:%M)
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# 颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

# 确保报告目录存在
mkdir -p "$CLEANER_DIR"

REPORT_FILE="$CLEANER_DIR/cleaner-report-${TIMESTAMP}.md"
CANDIDATES_FILE="$CLEANER_DIR/candidates-${TIMESTAMP}.txt"

echo -e "${GREEN}🧹 QMD 记忆清理服务启动${NC}"
echo "时间: $DATE $TIME"
echo "报告: $REPORT_FILE"
echo "================================"

# 初始化报告
cat > "$REPORT_FILE" << EOF
# 🧹 QMD 记忆清理报告

**分析时间**: $DATE $TIME  
**服务**: qmd-memory-cleaner (按需执行)  
**报告ID**: $TIMESTAMP

> ⚠️ **注意**: 本报告仅提供清理建议，不会自动删除任何文件！  
> 请仔细审阅后再决定是否执行删除操作。

---

## 📋 清理候选列表

EOF

# 清理候选计数器
CANDIDATE_COUNT=0

# -------------------------------------------------
# 🎯 1. 查找超过30天未访问的旧记忆文件
# -------------------------------------------------
echo -e "${BLUE}🔍 查找超过30天未访问的记忆文件...${NC}"
echo "" >> "$REPORT_FILE"
echo "### 1️⃣ 超过30天的旧记忆文件" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

OLD_DAYS=30
OLD_FILES=$(find "$MEMORY_DIR" -name "2026-*.md" -type f -atime +$OLD_DAYS 2>/dev/null | sort)

if [ -n "$OLD_FILES" ]; then
    echo "| 文件 | 大小 | 最后访问 | 建议操作 |" >> "$REPORT_FILE"
    echo "|------|------|----------|----------|" >> "$REPORT_FILE"
    
    while IFS= read -r file; do
        name=$(basename "$file")
        size=$(du -h "$file" 2>/dev/null | cut -f1)
        last_access=$(stat -c %x "$file" 2>/dev/null | cut -d' ' -f1)
        echo "| $name | $size | $last_access | ⚠️ 建议归档 |" >> "$REPORT_FILE"
        echo "$file" >> "$CANDIDATES_FILE"
        ((CANDIDATE_COUNT++))
    done <<< "$OLD_FILES"
    
    echo -e "${YELLOW}  发现 $(echo "$OLD_FILES" | wc -l) 个旧文件${NC}"
else
    echo "✅ 未发现超过30天的旧文件" >> "$REPORT_FILE"
    echo -e "${GREEN}  ✅ 未发现旧文件${NC}"
fi

# -------------------------------------------------
# 🎯 2. 查找重复/备份文件
# -------------------------------------------------
echo -e "\n---\n" >> "$REPORT_FILE"
echo -e "${BLUE}🔍 查找重复/备份文件...${NC}"
echo "" >> "$REPORT_FILE"
echo "### 2️⃣ 重复/备份文件" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

DUPLICATE_PATTERNS=("*.backup*" "*.copy*" "*副本*" "*.bak" "*~" "*#*")
FOUND_DUP=false

for pattern in "${DUPLICATE_PATTERNS[@]}"; do
    DUPS=$(find "$MEMORY_DIR" -name "$pattern" -type f 2>/dev/null)
    if [ -n "$DUPS" ]; then
        if [ "$FOUND_DUP" = false ]; then
            echo "| 文件 | 大小 | 建议操作 |" >> "$REPORT_FILE"
            echo "|------|------|----------|" >> "$REPORT_FILE"
            FOUND_DUP=true
        fi
        
        while IFS= read -r file; do
            name=$(basename "$file")
            size=$(du -h "$file" 2>/dev/null | cut -f1)
            echo "| $name | $size | 🔴 建议删除 |" >> "$REPORT_FILE"
            echo "$file" >> "$CANDIDATES_FILE"
            ((CANDIDATE_COUNT++))
        done <<< "$DUPS"
    fi
done

if [ "$FOUND_DUP" = false ]; then
    echo "✅ 未发现重复/备份文件" >> "$REPORT_FILE"
    echo -e "${GREEN}  ✅ 未发现重复文件${NC}"
fi

# -------------------------------------------------
# 🎯 3. 查找超大文件 (>500KB) - 可能需要拆分
# -------------------------------------------------
echo -e "\n---\n" >> "$REPORT_FILE"
echo -e "${BLUE}🔍 查找超大文件 (>500KB)...${NC}"
echo "" >> "$REPORT_FILE"
echo "### 3️⃣ 超大文件 (可能需要拆分)" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

LARGE_FILES=$(find "$MEMORY_DIR" -name "*.md" -size +500k -type f 2>/dev/null | sort -k5 -n)

if [ -n "$LARGE_FILES" ]; then
    echo "| 文件 | 大小 | 行数 | 建议操作 |" >> "$REPORT_FILE"
    echo "|------|------|------|----------|" >> "$REPORT_FILE"
    
    while IFS= read -r file; do
        name=$(basename "$file")
        size=$(du -h "$file" 2>/dev/null | cut -f1)
        lines=$(wc -l < "$file" 2>/dev/null)
        echo "| $name | $size | $lines | ⚠️ 建议拆分 |" >> "$REPORT_FILE"
        echo "$file (大小: $size, 行数: $lines)" >> "$CANDIDATES_FILE"
        ((CANDIDATE_COUNT++))
    done <<< "$LARGE_FILES"
    
    echo -e "${YELLOW}  发现 $(echo "$LARGE_FILES" | wc -l) 个超大文件${NC}"
else
    echo "✅ 未发现超大文件" >> "$REPORT_FILE"
    echo -e "${GREEN}  ✅ 无超大文件${NC}"
fi

# -------------------------------------------------
# 🎯 4. 查找空文件
# -------------------------------------------------
echo -e "\n---\n" >> "$REPORT_FILE"
echo -e "${BLUE}🔍 查找空文件...${NC}"
echo "" >> "$REPORT_FILE"
echo "### 4️⃣ 空文件或接近空" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

EMPTY_FILES=$(find "$MEMORY_DIR" -name "*.md" -size -100c -type f 2>/dev/null)

if [ -n "$EMPTY_FILES" ]; then
    echo "| 文件 | 大小 | 建议操作 |" >> "$REPORT_FILE"
    echo "|------|------|----------|" >> "$REPORT_FILE"
    
    while IFS= read -r file; do
        name=$(basename "$file")
        size=$(du -h "$file" 2>/dev/null | cut -f1)
        echo "| $name | $size | 🔴 建议删除 |" >> "$REPORT_FILE"
        echo "$file" >> "$CANDIDATES_FILE"
        ((CANDIDATE_COUNT++))
    done <<< "$EMPTY_FILES"
    
    echo -e "${YELLOW}  发现 $(echo "$EMPTY_FILES" | wc -l) 个空文件${NC}"
else
    echo "✅ 未发现空文件" >> "$REPORT_FILE"
    echo -e "${GREEN}  ✅ 无空文件${NC}"
fi

# -------------------------------------------------
# 🎯 5. 查找可能导致死循环的硬编码规则
# -------------------------------------------------
echo -e "\n---\n" >> "$REPORT_FILE"
echo -e "${BLUE}🔍 扫描潜在死循环触发词...${NC}"
echo "" >> "$REPORT_FILE"
echo "### 5️⃣ 潜在的"死循环"触发词 ⚠️" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# 危险模式：自动触发词、硬编码规则
DANGER_PATTERNS=(
    "自动执行"
    "无需确认"
    "立即执行"
    "系统服务"
    "自动触发"
    "无条件执行"
    "强制"
    "必须执行"
)

FOUND_DANGER=false

for pattern in "${DANGER_PATTERNS[@]}"; do
    MATCHES=$(grep -rn "$pattern" "$MEMORY_DIR"/*.md 2>/dev/null | head -3)
    if [ -n "$MATCHES" ]; then
        if [ "$FOUND_DANGER" = false ]; then
            echo "| 文件 | 危险关键词 | 上下文 |" >> "$REPORT_FILE"
            echo "|------|------------|--------|" >> "$REPORT_FILE"
            FOUND_DANGER=true
        fi
        
        while IFS= read -r match; do
            file=$(echo "$match" | cut -d':' -f1 | sed "s|$MEMORY_DIR/||")
            line=$(echo "$match" | cut -d':' -f2)
            context=$(echo "$match" | cut -d':' -f3- | cut -c1-50)
            echo "| $file:$line | $pattern | ...$context... |" >> "$REPORT_FILE"
        done <<< "$MATCHES"
    fi
done

if [ "$FOUND_DANGER" = false ]; then
    echo "✅ 未发现潜在死循环触发词" >> "$REPORT_FILE"
    echo -e "${GREEN}  ✅ 无危险触发词${NC}"
fi

# -------------------------------------------------
# 🎯 6. 检查 skills/ 中未使用的脚本
# -------------------------------------------------
echo -e "\n---\n" >> "$REPORT_FILE"
echo -e "${BLUE}🔍 检查旧技能/脚本...${NC}"
echo "" >> "$REPORT_FILE"
echo "### 6️⃣ 可能过时的技能配置" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

if [ -d "$WORKSPACE/skills" ]; then
    echo "| 技能目录 | 最后修改 | 建议操作 |" >> "$REPORT_FILE"
    echo "|----------|----------|----------|" >> "$REPORT_FILE"
    
    for skill_dir in "$WORKSPACE/skills"/*/; do
        if [ -d "$skill_dir" ]; then
            skill_name=$(basename "$skill_dir")
            last_mod=$(stat -c %y "$skill_dir" 2>/dev/null | cut -d' ' -f1)
            days_ago=$(( ( $(date +%s) - $(stat -c %Y "$skill_dir" 2>/dev/null) ) / 86400 ))
            
            if [ $days_ago -gt 14 ]; then
                echo "| $skill_name | $last_mod (${days_ago}天前) | ⚠️ 检查是否在用 |" >> "$REPORT_FILE"
            fi
        fi
    done
fi

# -------------------------------------------------
# 🚨 危险警告汇总
# -------------------------------------------------
echo -e "\n---\n" >> "$REPORT_FILE"
echo -e "\n${BLUE}🚨 生成危险警告...${NC}"
echo "" >> "$REPORT_FILE"
echo "## 🚨 危险警告汇总" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

if [ $CANDIDATE_COUNT -gt 0 ]; then
    echo -e "${RED}⚠️  发现 $CANDIDATE_COUNT 个待清理候选文件${NC}"
    echo "**总计**: $CANDIDATE_COUNT 个候选文件待处理" >> "$REPORT_FILE"
else
    echo -e "${GREEN}✅ 记忆库健康，无清理候选${NC}"
    echo "✅ **记忆库健康**: 未发现需要清理的文件" >> "$REPORT_FILE"
fi

# -------------------------------------------------
# 📊 建议操作清单
# -------------------------------------------------
echo "" >> "$REPORT_FILE"
echo "## 📝 建议操作清单" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

if [ -s "$CANDIDATES_FILE" ]; then
    echo "### 清理命令 (请人工审核后执行):" >> "$REPORT_FILE"
    echo "\`\`\`bash" >> "$REPORT_FILE"
    echo "# 归档旧文件 (推荐)" >> "$REPORT_FILE"
    echo "mkdir -p $MEMORY_DIR/archive" >> "$REPORT_FILE"
    while IFS= read -r file; do
        if [ -f "$file" ]; then
            echo "# mv \"$file\" $MEMORY_DIR/archive/" >> "$REPORT_FILE"
        fi
    done < "$CANDIDATES_FILE"
    echo "\`\`\`" >> "$REPORT_FILE"
fi

echo "" >> "$REPORT_FILE"
echo "### 安全操作指南:" >> "$REPORT_FILE"
cat >> "$REPORT_FILE" << 'EOF'

1. **永远先备份**: 在删除前 `cp -r memory/ memory.backup-$(date +%Y%m%d)/`
2. **小批量操作**: 一次只删除/归档 3-5 个文件
3. **验证后再删除**: 先用 `cat` 查看内容，确认不再需要
4. **保留至少30天**: 不要删除30天内创建的文件
5. **归档优于删除**: 将旧文件移动到 `memory/archive/` 而非直接删除

EOF

# -------------------------------------------------
# ✅ 完成报告
# -------------------------------------------------
echo "" >> "$REPORT_FILE"
echo "---" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "## ✅ 分析完成" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "**分析时间**: $(date '+%Y-%m-%d %H:%M:%S')" >> "$REPORT_FILE"
echo "**候选文件**: $CANDIDATE_COUNT" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "---" >> "$REPORT_FILE"
echo "*本报告由 qmd-memory-cleaner 自动生成*  
*⚠️ 警告: 删除操作不可逆，请务必人工审核后再执行!*" >> "$REPORT_FILE"

# 显示摘要
echo ""
echo -e "${GREEN}✅ 记忆清理分析完成!${NC}"
echo -e "${CYAN}📄 报告位置: $REPORT_FILE${NC}"
echo -e "${CYAN}📋 候选列表: $CANDIDATES_FILE${NC}"
echo ""

if [ $CANDIDATE_COUNT -gt 0 ]; then
    echo -e "${YELLOW}⚠️  发现 $CANDIDATE_COUNT 个候选文件需要清理${NC}"
    echo -e "${CYAN}请查看报告并谨慎操作!${NC}"
    echo ""
    echo "REPORT_PATH: $REPORT_FILE"
else
    echo -e "${GREEN}✅ 记忆库健康，无需要清理的文件!${NC}"
fi
