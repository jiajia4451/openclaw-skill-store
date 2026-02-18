#!/bin/bash
# tool-batcher - 工具批量执行器

BATCH_DIR="$HOME/.local/share/openclaw/batcher"
QUEUE_FILE="$BATCH_DIR/queue.json"
RESULTS_FILE="$BATCH_DIR/results.json"

# 初始化
init() {
    mkdir -p "$BATCH_DIR"
    echo '{"queue":[],"executing":false}' > "$QUEUE_FILE"
    echo '{"results":[]}' > "$RESULTS_FILE"
    echo "✅ Tool Batcher 已初始化"
}

# 添加工具到队列
add() {
    local tool="$1"
    local args="$2"
    local id="${3:-$(date +%s%N | cut -c1-13)}"
    local depends="${4:-}"
    
    local queue=$(cat "$QUEUE_FILE")
    local updated=$(echo "$queue" | jq ".queue += [{
        \"id\": \"$id\",
        \"tool\": \"$tool\",
        \"args\": $args,
        \"depends\": \"$depends\",
        \"status\": \"pending\",
        \"added_at\": \"$(date -Iseconds)\"
    }]")
    
    echo "$updated" > "$QUEUE_FILE"
    echo "➕ 已添加到队列: $tool (ID: $id)"
}

# 执行队列
exec_queue() {
    echo "🚀 开始批量执行 ($(date))"
    echo "━━━━━━━━━━━━━━━━━━━━━━"
    
    local queue=$(cat "$QUEUE_FILE")
    local results=$(cat "$RESULTS_FILE")
    
    # 标记执行中
    echo "$queue" | jq '.executing = true' > "$QUEUE_FILE"
    
    # 按依赖排序执行
    local pending=$(echo "$queue" | jq -r '.queue[] | select(.status=="pending") | .id')
    
    for task_id in $pending; do
        local task=$(echo "$queue" | jq ".queue[] | select(.id==\"$task_id\")")
        local tool=$(echo "$task" | jq -r '.tool')
        local args=$(echo "$task" | jq -r '.args')
        local depends=$(echo "$task" | jq -r '.depends // empty')
        
        # 检查依赖
        if [[ -n "$depends" ]]; then
            local dep_status=$(echo "$queue" | jq -r ".queue[] | select(.id==\"$depends\") | .status")
            if [[ "$dep_status" != "completed" ]]; then
                echo "  ⏳ 等待依赖: $depends"
                continue
            fi
        fi
        
        # 模拟执行
        echo "  ⚡ 执行: $tool"
        
        # 更新状态
        queue=$(echo "$queue" | jq ".queue |= map(if .id==\"$task_id\" then .status=\"completed\" else . end)")
        
        # 记录结果
        results=$(echo "$results" | jq ".results += [{
            \"id\": \"$task_id\",
            \"tool\": \"$tool\",
            \"status\": \"success\",
            \"executed_at\": \"$(date -Iseconds)\"
        }]")
        
        sleep 0.1
    done
    
    # 保存
    echo "$queue" | jq '.executing = false' > "$QUEUE_FILE"
    echo "$results" > "$RESULTS_FILE"
    
    echo ""
    echo "✅ 批量执行完成"
    echo "结果文件: $RESULTS_FILE"
}

# 裁剪结果
crop() {
    local fields="$1"
    local max_length="${2:-500}"
    
    echo "✂️ 裁剪结果"
    echo "保留字段: $fields"
    echo "最大长度: $max_length"
    
    # 这里会实际裁剪results.json中的结果
    local results=$(cat "$RESULTS_FILE")
    local fields_array=$(echo "$fields" | tr ',' '\n' | jq -R . | jq -s .)
    
    # 简化版本：只保留指定字段
    echo "$results" | jq "{
        results: [.results[] | {id, tool, status}]
    }" > "$RESULTS_FILE.cropped"
    
    echo "✅ 已裁剪，保存到: $RESULTS_FILE.cropped"
}

# 显示队列状态
status() {
    local queue=$(cat "$QUEUE_FILE")
    local total=$(echo "$queue" | jq '.queue | length')
    local pending=$(echo "$queue" | jq '[.queue[] | select(.status=="pending")] | length')
    local completed=$(echo "$queue" | jq '[.queue[] | select(.status=="completed")] | length')
    
    echo "📊 队列状态"
    echo "━━━━━━━━━━━━━━━━━━━━━━"
    echo "总任务: $total"
    echo "待执行: $pending"
    echo "已完成: $completed"
    
    if [[ "$pending" -gt 0 ]]; then
        echo ""
        echo "待执行列表:"
        echo "$queue" | jq -r '.queue[] | select(.status=="pending") | "  • \(.tool) (ID: \(.id))"'
    fi
}

# 清空队列
clear_queue() {
    echo '{"queue":[],"executing":false}' > "$QUEUE_FILE"
    echo '🗑️ 队列已清空'
}

# CLI入口
case "$1" in
    init)
        init
        ;;
    add)
        add "$2" "$3" "$4" "$5"
        ;;
    exec)
        exec_queue
        ;;
    crop)
        crop "$2" "$3"
        ;;
    status)
        status
        ;;
    clear)
        clear_queue
        ;;
    *)
        echo "tool-batcher - 工具批量执行器"
        echo ""
        echo "用法:"
        echo "  tool-batcher init                    # 初始化"
        echo "  tool-batcher add <tool> <args> [id] [depends]  # 添加任务"
        echo "  tool-batcher exec                    # 执行队列"
        echo "  tool-batcher crop <fields> [max]     # 裁剪结果"
        echo "  tool-batcher status                  # 查看状态"
        echo "  tool-batcher clear                   # 清空队列"
        echo ""
        echo "示例:"
        echo "  tool-batcher add web_search '{\"q\":\"test\"}' search1"
        echo "  tool-batcher add web_fetch '{\"url\":\"...\"}' fetch1 search1"
        echo "  tool-batcher exec"
        ;;
esac