#!/bin/bash
# QMD 搜索封装脚本 - 为OpenClaw优化
# 用法: ./qmd-search.sh "关键词" [模式:search|vsearch|query] [最大结果]

# 确保Bun在PATH中
export PATH="$HOME/.bun/bin:$PATH"

QUERY="$1"
MODE="${2:-search}"  # 默认BM25搜索
MAX_RESULTS="${3:-10}"
COLLECTION="openclaw-memory"

if [ -z "$QUERY" ]; then
    cat << 'EOF'
🔍 QMD 记忆搜索 (语义+全文)

用法: 
  ./qmd-search.sh "关键词" [模式] [最大结果]

模式:
  search  - BM25全文搜索 (快速，默认)
  vsearch - 向量语义搜索 (需LLM支持)
  query   - 混合搜索 (BM25+向量+重排，最精准)

示例:
  ./qmd-search.sh "moltbook发帖"
  ./qmd-search.sh "API破解" search 5
  ./qmd-search.sh "技能学习" query 20

注意:
  - vsearch/query需要下载额外模型(~1.1GB)
  - 首次使用自动下载，可能需要几分钟

EOF
    exit 1
fi

echo "🔍 QMD [$MODE]: '$QUERY' (最多$MAX_RESULTS条)"
echo "---"

# 执行搜索
case "$MODE" in
    search)
        # BM25搜索 - 最快，不需要额外模型
        qmd search "$QUERY" 2>/dev/null | head -n "$((MAX_RESULTS * 5))"
        ;;
    vsearch)
        # 向量语义搜索
        qmd vsearch "$QUERY" 2>/dev/null | head -n "$((MAX_RESULTS * 5))"
        ;;
    query)
        # 混合搜索 - 最佳质量
        qmd query "$QUERY" 2>/dev/null | head -n "$((MAX_RESULTS * 5))"
        ;;
    *)
        echo "❌ 未知模式: $MODE"
        echo "可用模式: search, vsearch, query"
        exit 1
        ;;
esac

echo "---"
echo "✅ 搜索完成"
