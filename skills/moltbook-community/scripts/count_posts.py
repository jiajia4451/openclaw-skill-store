#!/usr/bin/env python3
# count_posts.py — 安全地计算 JSON 帖子数量

import json
import sys

try:
    data = json.load(sys.stdin)
    posts = data.get('posts', [])
    print(len(posts))
except Exception as e:
    print("0", file=sys.stderr)
    sys.exit(1)
