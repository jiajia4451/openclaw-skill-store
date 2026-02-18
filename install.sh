#!/bin/bash
# OpenClaw Skill Installer
# Usage: curl -fsSL .../install.sh | bash -s [skill-name]

set -e

SKILL_NAME="${1:-}"
SKILLS_DIR="${HOME}/.openclaw/skills"
REPO_URL="https://github.com/jiajia4451/openclaw-skill-store"
BRANCH="skills"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_banner() {
    echo -e "${BLUE}"
    echo "🦞 OpenClaw Skill Installer"
    echo "=========================="
    echo -e "${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ️  $1${NC}"
}

# Check dependencies
check_deps() {
    if ! command -v git &> /dev/null; then
        print_error "git is required but not installed"
        exit 1
    fi
    
    if ! command -v curl &> /dev/null; then
        print_error "curl is required but not installed"
        exit 1
    fi
}

# Create skills directory
setup_dir() {
    mkdir -p "$SKILLS_DIR"
    print_info "Skills directory: $SKILLS_DIR"
}

# Install single skill
install_skill() {
    local skill="$1"
    local skill_dir="$SKILLS_DIR/$skill"
    
    print_info "Installing $skill..."
    
    # Check if already installed
    if [ -d "$skill_dir" ]; then
        print_info "$skill already exists, updating..."
        rm -rf "$skill_dir"
    fi
    
    # Clone specific directory using sparse checkout
    local tmp_dir=$(mktemp -d)
    cd "$tmp_dir"
    
    git init --quiet
    git remote add origin "$REPO_URL"
    git config core.sparseCheckout true
    echo "skills/$skill" > .git/info/sparse-checkout
    git pull --depth 1 origin "$BRANCH" --quiet
    
    # Move skill to destination
    if [ -d "skills/$skill" ]; then
        mv "skills/$skill" "$skill_dir"
        print_success "$skill installed successfully"
        
        # Run setup if exists
        if [ -f "$skill_dir/setup.sh" ]; then
            print_info "Running setup for $skill..."
            cd "$skill_dir"
            bash setup.sh || print_error "Setup script failed, but skill is installed"
        fi
        
        # Show SKILL.md if exists
        if [ -f "$skill_dir/SKILL.md" ]; then
            print_info "Documentation: $skill_dir/SKILL.md"
        fi
    else
        print_error "Skill '$skill' not found in repository"
        rm -rf "$tmp_dir"
        exit 1
    fi
    
    # Cleanup
    rm -rf "$tmp_dir"
}

# Install all skills
install_all() {
    print_info "Installing all official skills..."
    
    local skills=(
        "qmd-memory-reader"
        "qmd-memory-cleaner"
        "memory-system"
        "moltbook-community"
        "x-twitter"
        "vision-core"
        "smart-browser"
    )
    
    for skill in "${skills[@]}"; do
        echo ""
        install_skill "$skill"
    done
    
    echo ""
    print_success "All skills installed!"
}

# List available skills
list_skills() {
    print_info "Available skills:"
    echo ""
    echo "  qmd-memory-reader    - 每4小时自动记忆报告"
    echo "  qmd-memory-cleaner   - 记忆库健康检查"
    echo "  memory-system        - 自动记忆持久化"
    echo "  moltbook-community   - AI社区自动化"
    echo "  x-twitter            - X/Twitter自动化"
    echo "  vision-core          - 视觉控制系统"
    echo "  smart-browser        - 智能浏览器控制"
    echo ""
    echo "Usage:"
    echo "  Install single:  curl -fsSL .../install.sh | bash -s SKILL_NAME"
    echo "  Install all:     curl -fsSL .../install.sh | bash -s --all"
}

# Main
main() {
    print_banner
    check_deps
    setup_dir
    
    if [ -z "$SKILL_NAME" ] || [ "$SKILL_NAME" == "--help" ] || [ "$SKILL_NAME" == "-h" ]; then
        list_skills
        exit 0
    fi
    
    if [ "$SKILL_NAME" == "--all" ]; then
        install_all
    else
        install_skill "$SKILL_NAME"
    fi
    
    echo ""
    print_success "Done! Skill installed to: $SKILLS_DIR/$SKILL_NAME"
}

main