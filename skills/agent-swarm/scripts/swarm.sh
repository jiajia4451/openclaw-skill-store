#!/bin/bash
# agent-swarm - 多代理调度器

SWARM_DIR="$HOME/.local/share/openclaw/swarm"
AGENTS_FILE="$SWARM_DIR/agents.json"
TASKS_FILE="$SWARM_DIR/tasks.json"
LOG_FILE="$SWARM_DIR/swarm.log"

# 初始化
init() {
    mkdir -p "$SWARM_DIR"
    
    if [[ ! -f "$AGENTS_FILE" ]]; then
        echo '{"agents":{},"next_id":1}' > "$AGENTS_FILE"
    fi
    
    if [[ ! -f "$TASKS_FILE" ]]; then
        echo '{"tasks":[],"next_id":1}' > "$TASKS_FILE"
    fi
    
    echo "✅ Agent Swarm 已初始化"
    echo "数据目录: $SWARM_DIR"
}

# 注册代理
register() {
    local name="$1"
    local type="${2:-general}"
    local priority="${3:-normal}"
    local agent_id=$(date +%s%N | cut -c1-13)
    
    local agents=$(cat "$AGENTS_FILE")
    local updated=$(echo "$agents" | jq ".agents[\"$agent_id\"] = {
        \"name\": \"$name\",
        \"type\": \"$type\",
        \"priority\": \"$priority\",
        \"status\": \"active\",
        \"registered_at\": \"$(date -Iseconds)\",
        \"last_heartbeat\": \"$(date -Iseconds)\",
        \"task_count\": 0
    }")
    
    echo "$updated" > "$AGENTS_FILE"
    echo "✅ 代理已注册: $name (ID: $agent_id)"
}

# 心跳更新
heartbeat() {
    local agent_id="$1"
    local agents=$(cat "$AGENTS_FILE")
    
    if echo "$agents" | jq -e ".agents[\"$agent_id\"]" > /dev/null 2>&1; then
        local updated=$(echo "$agents" | jq ".agents[\"$agent_id\"].last_heartbeat = \"$(date -Iseconds)\"")
        echo "$updated" > "$AGENTS_FILE"
    fi
}

# 列出所有代理
list() {
    echo "🤖 注册代理列表"
    echo "━━━━━━━━━━━━━━━━━━━━━━"
    
    cat "$AGENTS_FILE" | jq -r '.agents | to_entries[] | 
        "ID: \(.key)\n  名称: \(.value.name)\n  类型: \(.value.type)\n  状态: \(.value.status)\n  优先级: \(.value.priority)\n  任务数: \(.value.task_count)\n  最后心跳: \(.value.last_heartbeat)\n"'
}

# 分发任务
dispatch() {
    local task="$1"
    shift
    local agents_str=""
    local mode="parallel"
    
    # 解析参数
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --agents)
                agents_str="$2"
                shift 2
                ;;
            --mode)
                mode="$2"
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done
    
    echo "🚀 分发任务: $task"
    echo "模式: $mode"
    echo "━━━━━━━━━━━━━━━━━━━━━━"
    
    # 生成任务ID
    local task_id=$(date +%s%N | cut -c1-13)
    
    # 记录任务
    local tasks=$(cat "$TASKS_FILE")
    local updated=$(echo "$tasks" | jq ".tasks += [{
        \"id\": \"$task_id\",
        \"content\": \"$task\",
        \"mode\": \"$mode\",
        \"agents\": \"$agents_str\",
        \"status\": \"running\",
        \"created_at\": \"$(date -Iseconds)\"
    }]")
    echo "$updated" > "$TASKS_FILE"
    
    # 模拟分发 (实际会调用各agent)
    IFS=',' read -ra agents <<< "$agents_str"
    for agent in "${agents[@]}"; do
        echo "  📤 发送给: $agent"
        # 这里实际会调用子代理
    done
    
    echo ""
    echo "任务ID: $task_id"
    echo "等待结果中... (使用 'agent-swarm result $task_id' 查看)"
}

# 查看状态
status() {
    local agents=$(cat "$AGENTS_FILE" | jq '.agents | length')
    local tasks=$(cat "$TASKS_FILE" | jq '.tasks | length')
    local running=$(cat "$TASKS_FILE" | jq '[.tasks[] | select(.status=="running")] | length')
    
    echo "🌐 Swarm 状态"
    echo "━━━━━━━━━━━━━━━━━━━━━━"
    echo "注册代理: $agents"
    echo "总任务数: $tasks"
    echo "运行中: $running"
    echo ""
    
    # 显示活跃代理
    echo "活跃代理:"
    cat "$AGENTS_FILE" | jq -r '.agents | to_entries[] | select(.value.status=="active") | "  • \(.value.name) (\(.value.type))"'
}

# 休眠代理
hibernate() {
    local agent_id="$1"
    local agents=$(cat "$AGENTS_FILE")
    
    if [[ -z "$agent_id" ]]; then
        # 休眠所有空闲代理
        echo "😴 休眠所有空闲代理..."
        local updated=$(echo "$agents" | jq '.agents |= map_values(if .status == "active" and .task_count == 0 then .status = "hibernating" else . end)')
        echo "$updated" > "$AGENTS_FILE"
        echo "✅ 空闲代理已休眠"
    else
        # 休眠指定代理
        local updated=$(echo "$agents" | jq ".agents[\"$agent_id\"].status = \"hibernating\"")
        echo "$updated" > "$AGENTS_FILE"
        echo "✅ 代理 $agent_id 已休眠"
    fi
}

# 唤醒代理
wake() {
    local agent_id="$1"
    local agents=$(cat "$AGENTS_FILE")
    
    if echo "$agents" | jq -e ".agents[\"$agent_id\"]" > /dev/null 2>&1; then
        local updated=$(echo "$agents" | jq ".agents[\"$agent_id\"].status = \"active\"")
        echo "$updated" > "$AGENTS_FILE"
        echo "⏰ 代理 $agent_id 已唤醒"
    else
        echo "❌ 代理不存在: $agent_id"
    fi
}

# CLI入口
case "$1" in
    init)
        init
        ;;
    register)
        register "$2" "$3" "$4"
        ;;
    list)
        list
        ;;
    dispatch)
        shift
        dispatch "$@"
        ;;
    status)
        status
        ;;
    hibernate)
        hibernate "$2"
        ;;
    wake)
        wake "$2"
        ;;
    heartbeat)
        heartbeat "$2"
        ;;
    *)
        echo "agent-swarm - 多代理调度器"
        echo ""
        echo "用法:"
        echo "  agent-swarm init                              # 初始化"
        echo "  agent-swarm register <name> [type] [priority] # 注册代理"
        echo "  agent-swarm list                              # 列出代理"
        echo "  agent-swarm dispatch <task> --agents=a,b --mode=parallel"
        echo "  agent-swarm status                            # 查看状态"
        echo "  agent-swarm hibernate [agent_id]              # 休眠代理"
        echo "  agent-swarm wake <agent_id>                   # 唤醒代理"
        ;;
esac