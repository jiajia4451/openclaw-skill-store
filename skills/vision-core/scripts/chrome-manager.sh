#!/bin/bash
# Smart Chrome Manager - 智能Chrome管理器
# 核心规则: 常驻运行，不要关闭，前台操作，最多3标签

set -e

# 配置
CHROME_CLASS="google-chrome"
MAX_TABS=3
SCREENSHOT_DIR="$HOME/图片"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[✓]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[!]${NC} $1"
}

error() {
    echo -e "${RED}[✗]${NC} $1"
}

# 1. 检查 Chrome 是否运行
check_chrome() {
    if pgrep -x "chrome" > /dev/null 2>&1; then
        log "Chrome 正在运行"
        return 0
    else
        warn "Chrome 未运行"
        return 1
    fi
}

# 2. 启动 Chrome
start_chrome() {
    log "启动 Chrome..."
    google-chrome &
    sleep 3
    
    # 等待窗口出现
    for i in {1..10}; do
        WID=$(xdotool search --class "$CHROME_CLASS" | tail -1)
        if [ -n "$WID" ]; then
            log "Chrome 启动成功，窗口 ID: $WID"
            echo "$WID"
            return 0
        fi
        sleep 1
    done
    
    error "Chrome 启动失败"
    return 1
}

# 3. 获取 Chrome 窗口 ID
get_chrome_wid() {
    WID=$(xdotool search --class "$CHROME_CLASS" | tail -1)
    if [ -z "$WID" ]; then
        error "无法获取 Chrome 窗口 ID"
        return 1
    fi
    echo "$WID"
}

# 4. 激活窗口到前台（关键！）
activate_chrome() {
    local WID=$1
    log "激活 Chrome 到前台..."
    xdotool windowactivate "$WID" 2>/dev/null || {
        warn "常规激活失败，尝试替代方法..."
        xdotool windowraise "$WID" 2>/dev/null
        xdotool windowfocus "$WID" 2>/dev/null
    }
    sleep 0.5
}

# 5. 检查标签数量（超过3个警告）
check_tabs() {
    # Chrome 不提供直接获取标签数的方法
    # 只能通过 heuristics 估算或使用扩展
    log "标签检查: 请手动确保不超过3个标签"
    log "超过时关闭旧标签: xdotool key ctrl+w"
}

# 6. 智能截图
smart_capture() {
    local WID=$1
    local filename=${2:-"screenshot_$(date +%s).png"}
    local filepath="$SCREENSHOT_DIR/$filename"
    
    log "截图..."
    # 先激活再截图
    activate_chrome "$WID"
    flameshot full --path "$filepath" 2>/dev/null || xdotool windowcapture "$WID" "$filepath"
    
    if [ -f "$filepath" ]; then
        log "截图保存: $filepath ($(du -h "$filepath" | cut -f1))"
        echo "$filepath"
    else
        error "截图失败"
        return 1
    fi
}

# 7. 安全最小化（不要关闭！）
minimize_chrome() {
    local WID=$1
    log "最小化 Chrome（保持常驻）..."
    xdotool windowminimize "$WID" 2>/dev/null || {
        warn "最小化失败，尝试 iconify..."
        xdotool windowminimize "$WID"
    }
    log "Chrome 已最小化，保持运行"
}

# 8. 单标签工作 - navigate 切换
navigate_to() {
    local WID=$1
    local URL=$2
    
    log "导航到: $URL"
    activate_chrome "$WID"
    
    # 点击地址栏
    xdotool key ctrl+l
    sleep 0.3
    
    # 输入 URL
    xdotool type --delay 30 "$URL"
    sleep 0.3
    
    # 回车
    xdotool key Return
    sleep 2
    
    log "导航完成"
}

# 主函数
main() {
    log "=== Vision-Core Chrome Manager v4.0 ==="
    log "规则: 常驻运行 | 最多3标签 | 前台操作 | 完毕最小化"
    
    # 检查环境
    if [ "$XDG_SESSION_TYPE" != "x11" ]; then
        error "当前不是 X11 会话！请切换到 'GNOME on Xorg'"
        exit 1
    fi
    
    # 获取或启动 Chrome
    if check_chrome; then
        WID=$(get_chrome_wid)
    else
        WID=$(start_chrome)
    fi
    
    if [ -z "$WID" ]; then
        error "无法获取 Chrome 窗口"
        exit 1
    fi
    
    log "Chrome 窗口 ID: $WID"
    
    # 根据参数执行不同操作
    case "$1" in
        activate)
            activate_chrome "$WID"
            ;;
        capture|screenshot)
            smart_capture "$WID" "$2"
            ;;
        navigate)
            navigate_to "$WID" "$2"
            ;;
        minimize|done)
            minimize_chrome "$WID"
            ;;
        fullcycle)
            log "执行完整流程: 激活 → 截图 → 最小化"
            activate_chrome "$WID"
            smart_capture "$WID" "auto_capture.png"
            minimize_chrome "$WID"
            ;;
        *)
            log "用法: $0 {activate|capture|navigate|minimize|fullcycle}"
            log "  activate    - 激活 Chrome 到前台"
            log "  capture     - 截图当前页面"
            log "  navigate    - 导航到指定 URL"
            log "  minimize    - 最小化（不要关闭！）"
            log "  fullcycle   - 完整流程: 激活→截图→最小化"
            ;;
    esac
}

main "$@"
