#!/bin/bash
# cost-router - 成本感知模型路由
# 自动根据任务复杂度选择最优模型

CONFIG_FILE="$HOME/.config/openclaw/cost-router.json"
LOG_FILE="$HOME/.local/share/openclaw/cost-router.log"
REPORT_DIR="$HOME/.local/share/openclaw/cost-reports"

# 确保目录存在
mkdir -p "$(dirname "$CONFIG_FILE")" "$(dirname "$LOG_FILE")" "$REPORT_DIR"

# 默认配置
init_config() {
    if [[ ! -f "$CONFIG_FILE" ]]; then
        cat > "$CONFIG_FILE" << 'EOF'
{
  "monthly_budget": 50,
  "budget_currency": "USD",
  "models": {
    "simple": { "id": "minimax-m2.5", "cost_per_1k": 0.001, "description": "简单问答、日常对话" },
    "medium": { "id": "kimi-k2.5", "cost_per_1k": 0.005, "description": "中等分析、总结" },
    "complex": { "id": "gpt-4", "cost_per_1k": 0.03, "description": "复杂编程、深度推理" }
  },
  "complexity_keywords": {
    "simple": ["你好", "谢谢", "对吗", "简单", "是什么"],
    "medium": ["分析", "总结", "对比", "解释", "为什么"],
    "complex": ["编程", "代码", "debug", "架构", "设计", "优化", "算法"]
  },
  "auto_fallback": true,
  "alert_threshold": 0.8
}
EOF
    fi
}

# 评估任务复杂度
assess_complexity() {
    local prompt="$1"
    local config=$(cat "$CONFIG_FILE")
    
    # 检查复杂关键词
    for keyword in $(echo "$config" | jq -r '.complexity_keywords.complex[]'); do
        if [[ "$prompt" == *"$keyword"* ]]; then
            echo "complex"
            return
        fi
    done
    
    # 检查中等关键词
    for keyword in $(echo "$config" | jq -r '.complexity_keywords.medium[]'); do
        if [[ "$prompt" == *"$keyword"* ]]; then
            echo "medium"
            return
        fi
    done
    
    # 检查简单关键词或短文本
    local length=${#prompt}
    if [[ $length -lt 50 ]]; then
        echo "simple"
        return
    fi
    
    # 默认中等
    echo "medium"
}

# 路由模型
route_model() {
    local prompt="$1"
    local complexity=$(assess_complexity "$prompt")
    local config=$(cat "$CONFIG_FILE")
    
    # 检查预算
    local budget=$(echo "$config" | jq -r '.monthly_budget')
    local current_cost=$(get_monthly_cost)
    local threshold=$(echo "$config" | jq -r '.alert_threshold')
    local alert_limit=$(echo "$budget * $threshold" | bc)
    
    if (( $(echo "$current_cost > $alert_limit" | bc -l) )); then
        echo "⚠️ 预算使用超过 ${threshold}%，强制使用最经济模型" >&2
        complexity="simple"
    fi
    
    # 返回模型ID
    local model=$(echo "$config" | jq -r ".models.$complexity.id")
    echo "$model"
    
    # 记录日志
    log_usage "$complexity" "$model" "${#prompt}"
}

# 获取本月成本
get_monthly_cost() {
    local month=$(date +%Y-%m)
    local report="$REPORT_DIR/$month.json"
    
    if [[ -f "$report" ]]; then
        cat "$report" | jq -r '.total_cost // 0'
    else
        echo "0"
    fi
}

# 记录使用日志
log_usage() {
    local complexity="$1"
    local model="$2"
    local length="$3"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "[$timestamp] complexity=$complexity model=$model length=$length" >> "$LOG_FILE"
}

# 生成每日报告
daily_report() {
    local date=$(date +%Y-%m-%d)
    local log="$LOG_FILE"
    
    if [[ ! -f "$log" ]]; then
        echo "暂无使用记录"
        return
    fi
    
    # 统计今日
    local today=$(grep "^\[$date" "$log" | wc -l)
    local simple=$(grep "^\[$date" "$log" | grep "complexity=simple" | wc -l)
    local medium=$(grep "^\[$date" "$log" | grep "complexity=medium" | wc -l)
    local complex=$(grep "^\[$date" "$log" | grep "complexity=complex" | wc -l)
    
    echo "📊 今日路由统计 ($date)"
    echo "━━━━━━━━━━━━━━━━━━━━━━"
    echo "总请求数: $today"
    echo "简单任务: $simple ($(echo "scale=1; $simple * 100 / $today" | bc)%)"
    echo "中等任务: $medium ($(echo "scale=1; $medium * 100 / $today" | bc)%)"
    echo "复杂任务: $complex ($(echo "scale=1; $complex * 100 / $today" | bc)%)"
}

# CLI入口
case "$1" in
    init)
        init_config
        echo "✅ cost-router 配置已初始化"
        echo "配置文件: $CONFIG_FILE"
        ;;
    route)
        shift
        route_model "$*"
        ;;
    today)
        daily_report
        ;;
    budget)
        local cost=$(get_monthly_cost)
        local config=$(cat "$CONFIG_FILE")
        local budget=$(echo "$config" | jq -r '.monthly_budget')
        local percent=$(echo "scale=1; $cost * 100 / $budget" | bc)
        
        echo "💰 本月预算使用情况"
        echo "━━━━━━━━━━━━━━━━━━━━━━"
        echo "预算: $budget USD"
        echo "已用: $cost USD ($percent%)"
        
        if (( $(echo "$percent > 80" | bc -l) )); then
            echo "⚠️ 警告: 即将超支！"
        fi
        ;;
    stats)
        daily_report
        echo ""
        $0 budget
        ;;
    *)
        echo "cost-router - 成本感知模型路由"
        echo ""
        echo "用法:"
        echo "  cost-router init          # 初始化配置"
        echo "  cost-router route <text>  # 路由文本到最优模型"
        echo "  cost-router today         # 今日统计"
        echo "  cost-router budget        # 预算使用情况"
        echo "  cost-router stats         # 完整统计"
        ;;
esac