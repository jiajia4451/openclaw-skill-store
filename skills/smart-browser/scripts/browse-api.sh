#!/bin/bash
# 后台API浏览 - curl获取HTML并解析

URL="$1"
TIMEOUT=${SMART_BROWSER_TIMEOUT:-10}
OUTPUT_DIR="/tmp/smart-browser"
mkdir -p "$OUTPUT_DIR"

OUTPUT_FILE="$OUTPUT_DIR/api_$(date +%s).json"
HTML_FILE="$OUTPUT_DIR/temp_$(date +%s).html"

# 反爬User-Agent轮换
USER_AGENTS=(
    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
)
RANDOM_UA="${USER_AGENTS[$RANDOM % ${#USER_AGENTS[@]}]}"

# 发送请求
RESPONSE=$(curl -sL -w "\nHTTP_CODE:%{http_code}\n" \
    -H "User-Agent: $RANDOM_UA" \
    -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" \
    -H "Accept-Language: en-US,en;q=0.5" \
    -H "Accept-Encoding: gzip, deflate, br" \
    --compressed \
    --max-time $TIMEOUT \
    "$URL" 2>/dev/null)

HTTP_CODE=$(echo "$RESPONSE" | grep "HTTP_CODE:" | cut -d: -f2 | tr -d '\r')
HTML=$(echo "$RESPONSE" | sed '/HTTP_CODE:/d')

# 检查是否成功
if [ "$HTTP_CODE" != "200" ]; then
    echo "{\"url\":\"$URL\",\"mode\":\"api\",\"status\":\"failed\",\"error\":\"HTTP $HTTP_CODE\",\"fallback\":\"visual\"}"
    exit 1
fi

# 检查是否被反爬
echo "$HTML" > "$HTML_FILE"
if grep -qiE "captcha|blocked|access denied|cloudflare|ddos|rate limit|unusual traffic" "$HTML_FILE"; then
    echo "{\"url\":\"$URL\",\"mode\":\"api\",\"status\":\"blocked\",\"error\":\"Anti-bot detected\",\"fallback\":\"visual\"}"
    exit 1
fi

# 提取标题
TITLE=$(echo "$HTML" | grep -oP '(?i)<title[^\u003e]*>\K[^<]+' | head -1 | tr -d '\n' | sed 's/"/\\"/g')

# 提取正文 (简化版)
CONTENT=$(echo "$HTML" | sed 's/<[^\u003e]*>//g' | tr -s ' \n' ' ' | head -c 2000 | sed 's/"/\\"/g')

# 输出结果
cat > "$OUTPUT_FILE" << EOF
{
  "url": "$URL",
  "mode": "api",
  "title": "$TITLE",
  "content": "$CONTENT",
  "status": "success",
  "error": null,
  "http_code": "$HTTP_CODE"
}
EOF

cat "$OUTPUT_FILE"

# 清理
rm -f "$HTML_FILE"
