# Smart Browser Skill - 智能浏览

> **后台API优先，前台截图兜底** - 自动选择最优浏览策略

---

## 🎯 核心能力

双模式智能浏览系统：
- **后台模式** (API Mode): curl获取HTML → 解析 → 提取文字摘要
- **前台模式** (Visual Mode): Chrome截图 → AI视觉分析 → 结构化输出

**自动切换策略**:
```
用户请求浏览网页
    ↓
尝试后台API (curl)
    ├─ 成功 → 解析HTML → 文字摘要
    └─ 失败 (403/反爬/JS渲染) 
        ↓
    启动前台浏览器 → 截图 → AI分析
```

---

## 🛠️ 脚本使用

### 智能浏览（自动选择）
```bash
./scripts/smart-browse.sh <URL> [max_retries]
```

**示例**:
```bash
./scripts/smart-browse.sh "https://moltbook.com/m/general"
./scripts/smart-browse.sh "https://openai.com/news" 3
```

**输出格式**:
```json
{
  "url": "https://moltbook.com",
  "mode": "api", // or "visual"
  "title": "页面标题",
  "content": "提取的文字内容",
  "screenshot": "/path/to/screenshot.png", // 仅visual模式
  "status": "success",
  "error": null
}
```

### 后台API浏览
```bash
./scripts/browse-api.sh <URL>
```

### 前台截图浏览  
```bash
./scripts/browse-visual.sh <URL> [screenshot_name]
```

---

## 📊 双模式对比

| 特性 | 后台API (curl) | 前台截图 (Chrome) |
|------|----------------|-------------------|
| **速度** | ⚡ 毫秒级 | 🐢 秒级 |
| **成功率** | 🟡 70% (易被反爬) | 🟢 95% (模拟真人) |
| **成本** | 💰 低 (本地curl) | 💰 高 (启动Chrome+截图) |
| **JS渲染** | ❌ 不支持 | ✅ 完全支持 |
| **登录态** | 🟡 需cookie | 🟢 可扫码/输密码 |
| **反爬检测** | 🔴 易被ban | 🟢 较难检测 |

---

## 🔍 反爬检测逻辑

### 触发前台模式的条件
1. HTTP 403/429/503
2. 返回内容包含 "captcha", "blocked", "access denied"
3. 返回HTML但无实质内容（可能是JS渲染）
4. 连接超时 (>10秒)

### 触发后台模式的条件  
1. 快速成功返回 (HTTP 200)
2. 内容包含有效文本 (>100字符)
3. 不是纯JS框架页面

---

## 📝 使用场景

### 场景1: 新闻网站
```bash
# 后台足够
smart-browse.sh "https://example.com/news"
```

### 场景2: React/Vue SPA
```bash
# 自动切前台
smart-browse.sh "https://dashboard.example.com"
```

### 场景3: 被封IP的网站
```bash
# 强制前台+代理
BROWSER_PROXY="socks5://127.0.0.1:1080" smart-browse.sh "https://blocked.com"
```

---

## 🔧 高级配置

### 环境变量
```bash
export SMART_BROWSER_TIMEOUT=30      # API模式超时(秒)
export SMART_BROWSER_WAIT=5          # 视觉模式等待(秒)
export SMART_BROWSER_PROXY=""        # 代理设置
export SMART_BROWSER_HEADLESS=false  # true=无头模式
```

### 反爬策略库
见 `lib/anti-detect-patterns.json` - 已知反爬特征库

---

## 🚀 路线图

- [x] 基础双模式切换
- [x] 反爬检测逻辑
- [ ] 智能重试机制
- [ ] Cookie/Session持久化
- [ ] 代理池支持
- [ ] 分布式截图节点

---

**版本**: v1.0  
**创建**: 2026-02-17  
**状态**: ✅ 可用
