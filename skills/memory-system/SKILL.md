---
name: memory-system
description: Automatic memory persistence and recovery system service for OpenClaw. Auto-triggers on boot to restore context from memory files, auto-records important conversations during sessions, auto-generates reset reports when sessions are interrupted, and provides on-demand memory search. This is a system service that runs automatically without manual activation - it detects trigger conditions and executes immediately without user confirmation.
---

# Memory System — Automatic Context Persistence Service

<!-- 【中文说明】这是一个自动运行的系统服务，不是手动工具！ -->

**服务类型**: 自动运行的系统服务 (System Service)  
**运行模式**: 自动检测触发条件 → 立即执行 → 主动汇报  
**手动干预**: 不需要！全自动运行

## 核心特性 (全自动)

| 功能 | 触发条件 | 执行方式 | 汇报方式 |
|------|----------|----------|----------|
| **启动恢复** | OpenClaw 启动 | ✅ 自动执行 | 输出恢复状态 |
| **实时记录** | 检测到记录条件 | ✅ 自动执行 | 静默记录 |
| **重置报告** | 会话重置检测 | ✅ 自动生成 | 主动汇报 |
| **记忆搜索** | 用户查询请求 | ✅ 自动执行 | 返回结果 |

**注意**: scripts/ 目录下的脚本由系统自动调用，不需要手动运行！

---

## 🔍 记忆搜索方案对比

我们提供 **3种** 记忆搜索方式，根据需求选择：

| 方案 | 速度 | 成本 | 智能程度 | 适用场景 |
|------|------|------|----------|----------|
| **grep搜索** (memory-search.sh) | ⚡ 最快 | 免费 | 关键词匹配 | 快速查找 |
| **QMD搜索** (qmd-search.sh) | 🚀 快 | 免费 | BM25+向量混合 | **推荐日常** |
| **语义搜索** (OpenClaw内置) | 🐢 较慢 | 需API Key | 纯向量语义 | 深度语义查询 |

**推荐**: 日常使用 **QMD**（已安装配置好），无需API Key，支持全文+语义混合搜索。

### QMD 快速使用

```bash
# BM25全文搜索 (最快)
./scripts/qmd-search.sh "moltbook发帖"

# 混合搜索 (BM25+向量，最精准)
./scripts/qmd-search.sh "API破解" query 5

# 查看帮助
./scripts/qmd-search.sh
```

**QMD特点**:
- ✅ 完全免费，无需API Key
- ✅ 本地运行，隐私安全
- ✅ BM25全文 + 向量语义混合
- ✅ 智能评分排序
- ⚠️ 向量功能需下载~1GB模型（自动）

### 1. Real-Time Recorder (Continuous)
Automatically logs important conversations as they happen.

**Trigger Conditions** (when to record immediately):
- Code changes / version releases
- Important decisions / agreements
- User says "remember this" / "记下来"
- Project milestones completed
- Errors / lessons learned
- Significant technical discoveries
- Business decisions or pivots

**Storage Format**: Append-only to `memory/YYYY-MM-DD.md`

### 2. Boot Restorer (On Startup)
Automatically executed when OpenClaw starts or session resets.

**Recovery Sequence**:
1. Read `SOUL.md` — confirm identity
2. Read `USER.md` — confirm service target
3. Read `MEMORY.md` — restore long-term memory
4. Read `memory/YYYY-MM-DD.md` — restore today's context
5. Read `memory/projects/*.md` — restore project states
6. Generate reset report if session was interrupted

### 3. Memory Search & Query (On Demand)
Semantic search across all memory files.

**Search Capabilities**:
- Full-text search in MEMORY.md and memory/*.md
- Session transcript search (historical sessions)
- Date-based filtering
- Project-specific queries

## Scripts

### Record Event
```bash
./scripts/record.sh "事件描述" [分类] [详细内容文件]
```
Appends formatted entry to today's memory file.

### Boot Recovery
```bash
./scripts/recover.sh [--report]
```
Executes full recovery sequence. Use `--report` to generate reset summary.

### Memory Search (Original - Semantic)
```bash
./scripts/search.sh "查询内容" [--date YYYY-MM-DD] [--project 项目名]
```
Returns matching memory snippets with paths and relevance scores.

⚠️ **Requires**: OpenAI/Google/Voyage API Key (paid service)

### Memory Search (Free - Local Grep) ⭐ RECOMMENDED
```bash
./scripts/memory-search.sh "关键词" [最大结果数]
```
**Free alternative** to the semantic search - uses local `grep`, no API key needed!

**Examples**:
```bash
./scripts/memory-search.sh "moltbook"       # Search moltbook-related
./scripts/memory-search.sh "API Key" 5      # Max 5 results
./scripts/memory-search.sh "技能" 20        # Chinese keyword search
```

**Comparison**:
| Feature | semantic search | memory-search.sh |
|---------|-----------------|------------------|
| Cost | Paid (API calls) | **Free** ✅ |
| Speed | Slower (network) | **Fast** ✅ |
| Accuracy | Semantic matching | Exact text match |
| Setup | Requires API key | **Zero setup** ✅ |

**Recommendation**: Use `memory-search.sh` for most searches. Use semantic search only when you need fuzzy/semantic matching.

### Memory Search (QMD - Hybrid) ⭐⭐ BEST
```bash
./scripts/qmd-search.sh "关键词" [模式] [最大结果数]
```
**Best of both worlds** — BM25 full-text + vector semantic + smart ranking. Completely free!

**Examples**:
```bash
./scripts/qmd-search.sh "moltbook发帖"           # BM25 search (fast)
./scripts/qmd-search.sh "API破解" query 5         # Hybrid search (most accurate)
./scripts/qmd-search.sh "技能学习" vsearch 10   # Vector semantic search
```

**Modes**:
- `search` — BM25 full-text, fastest, no extra model download
- `vsearch` — Vector semantic, needs ~1GB model download (auto)
- `query` — Hybrid BM25+vector+reranking, best quality

**Comparison**:
| Feature | grep | QMD | Semantic |
|---------|------|-----|----------|
| Cost | Free ✅ | Free ✅ | Paid 💰 |
| Speed | Fastest ⚡ | Fast 🚀 | Slow 🐢 |
| Intelligence | Exact match | BM25 + Vector | Pure vector |
| Setup | None | Bun + 2GB models | API Key |

**Recommendation**: Use **QMD** for daily searches. It's smarter than grep and free unlike OpenAI!

### Session Reset Reporter
```bash
./scripts/reset-report.sh [previous_session_id]
```
Generates structured report when session resets are detected.

## Directory Structure

```
workspace/
├── MEMORY.md                    # Curated long-term memory
├── memory/
│   ├── 2026-02-15.md           # Today's raw logs
│   ├── 2026-02-14.md           # Historical daily logs
│   └── projects/
│       ├── 美乳投票.md         # Project-specific memory
│       └── 安卓计划.md
└── skills/memory-system/
    ├── SKILL.md                # This file
    ├── scripts/
    │   ├── record.sh           # Real-time recording
    │   ├── recover.sh          # Boot recovery
    │   ├── search.sh           # Memory search (OpenAI - paid)
    │   ├── memory-search.sh    # Memory search (grep - free)
    │   ├── qmd-search.sh       # Memory search (QMD - hybrid, free) ⭐
    │   └── reset-report.sh     # Reset detection & reporting
    └── references/
        └── recording-rules.md  # Detailed recording triggers
```

## Recording Rules (Auto-Trigger)

See [references/recording-rules.md](references/recording-rules.md) for comprehensive trigger conditions and formatting templates.

**Quick Reference - Always Record**:
| Trigger | Example | Format |
|---------|---------|--------|
| Decision | "我们决定用方案B" | ## 🎯 决策记录 |
| Code Change | 修改了核心参数 | ## 📝 代码变更 |
| Milestone | "v2.0完成了" | ## 🚀 里程碑 |
| Error/Lesson | 踩坑记录 | ## ⚠️ 教训记录 |
| User Request | "记住这个" | ## 💡 用户备忘 |

## Boot Recovery Report Template

When session reset detected, generate:

```markdown
## 🔄 会话重置恢复报告

**重置时间**: [timestamp]
**前会话ID**: [session_id]
**前会话大小**: [size]
**最后活跃**: [last_update]

### 已恢复记忆
- [x] SOUL.md — 身份确认
- [x] USER.md — 服务对象确认
- [x] MEMORY.md — 长期记忆 [N条]
- [x] memory/YYYY-MM-DD.md — 今日上下文
- [x] memory/projects/*.md — 项目状态 [N个]

### 当前项目状态
| 项目 | 进度 | 最后更新 |
|------|------|----------|
| [项目名] | [状态] | [时间] |

### 待续事项
- [ ] [事项1]
- [ ] [事项2]
```

## Integration

### Automatic Triggers

1. **On Every Message**: Check recording rules, append if triggered
2. **On Boot**: Execute `recover.sh --report`
3. **On Session Reset**: Detect via session ID change, run `reset-report.sh`

### Manual Usage

**Record immediately**:
```
记住：佳哥决定放弃安卓计划，转向Web开发
```
→ Triggers real-time recorder

**Search memory**:
```
查一下我们上次讨论的MCP Hub方案
```
→ Triggers semantic search

**Force recovery**:
```
恢复上次的会话状态
```
→ Triggers boot recovery sequence

## Safety & Persistence

- **Append-only**: Never overwrites existing entries
- **Git-backed**: All changes committed automatically
- **Daily rotation**: New file each day to prevent corruption
- **Project separation**: Active projects get dedicated files
- **Session archive**: Historical sessions preserved in `.openclaw/agents/main/sessions/`

## Dependencies

- `memory/` directory exists (create if missing)
- Git repository initialized in workspace
- `OPENCLAW_DEFAULT_CONFIG.json` includes boot hooks (handled by config-loader skill)
