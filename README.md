# 🦞 OpenClaw Skill Store v1.1.0

> AI代理技能商店 - 本地版 + 官方技能精选

---

# 🌟 重磅推荐：QMD Core - AI的记忆核心

## 💡 为什么QMD是必装技能？

**问题**: AI每轮对话都在"失忆"
- ❌ 记不住上周讨论的方案
- ❌ 找不到三个月前的代码片段
- ❌ 每次都要重读整个项目

**QMD解决方案**:
- ✅ **语义搜索** - 搜索"上次说的那个方案"，不用记得文件名
- ✅ **长期记忆** - 自动索引所有文档，随时检索
- ✅ **智能关联** - 新内容自动关联旧记忆

```bash
# 不用记文件名，描述意思就能找到！
qmd search "那个关于Twitter自动化的讨论"
qmd vsearch "上次说的记忆系统方案"
qmd query "Find the code about retweet functionality"
```

---

## 🚀 技能裂变：QMD能衍生出什么？

**QMD Core 是一个记忆基建，基于它可以开发无限技能**:

### 🔮 已实现的裂变技能

| 技能 | 描述 | 状态 |
|------|------|------|
| **qmd-memory-reader** | 每4小时自动生成记忆报告 | ✅ Stable |
| **qmd-memory-cleaner** | 健康检查与归档建议 | ✅ Stable |
| **memory-system** | 自动记忆持久化与恢复 | ✅ Stable |

### 🔮 可开发的裂变技能 (等你来！)

```
qmd-blog-search     → 博客全文语义搜索
                    $ qmd-blog-search "那篇讲技能商店的文章"

qmd-code-search     → 代码语义搜索
                    $ qmd-code-search "处理HTTP 400错误的那段代码"

qmd-knowledge-base  → 个人知识库系统
                    $ qmd-kb add "新学到的正则技巧"
                    $ qmd-kb search "正则"

qmd-conversation-memory → 对话长期记忆
                    $ qmd-cm recall "上周讨论的技术选型"

qmd-project-tracker → 项目进度语义追踪
                    $ qmd-pt status "美乳投票项目进度"

qmd-email-archive   → 邮件语义归档
                    $ qmd-email search "关于发票的那封邮件"

qmd-bookmarks       → 智能书签语义管理
                    $ qmd-bm add https://...
                    $ qmd-bm search "那个讲Linux内核的"

qmd-reading-list    → 阅读清单语义推荐
                    $ qmd-read add "量子计算入门"
                    $ qmd-read suggest "技术类"

qmd-daily-journal   → 智能日记本
                    $ qmd-journal today "今天搞定了QMD"
                    $ qmd-journal search "里程碑"

qmd-research-assistant → AI研究助手
                    $ qmd-research topic "向量数据库"
                    $ qmd-research summary "帮我整理相关文档"
```

---

## 💎 QMD vs 普通搜索

| 对比 | 传统搜索 | QMD语义搜索 |
|------|----------|-------------|
| **输入** | `grep "twitter" *.md` | `qmd search "发推相关的讨论"` |
| **理解** | 字面匹配 | 理解意思 |
| **结果** | 包含"twitter"的文件 | 关于发推、X自动化、社交媒体的所有文档 |
| **排序** | 无 | 按语义相似度排序 |

```bash
# 传统搜索 (需要记得关键词)
grep -r "转发" memory/

# QMD搜索 (描述意思就行)
qmd vsearch "关于Twitter转发按钮的那些尝试"
```

---

## 📦 商店技能总览

### 🌟 Featured (重磅推荐)
| 技能 | 版本 | 描述 | 评分 |
|------|------|------|------|
| **qmd-core** | 3.0.0 | 🌟 QMD Core - AI的记忆核心 | ⭐⭐⭐⭐⭐ |

### 🛠️  自定义技能 (9个)
| 技能 | 版本 | 描述 |
|------|------|------|
| moltbook-community | 1.2.0 | AI社区自动化 |
| x-twitter | 1.0.0 | X/Twitter自动化 |
| vision-core | 2.0.0 | 视觉控制系统 |
| qmd-memory-reader | 1.0.0 | QMD记忆读取服务 |
| qmd-memory-cleaner | 1.0.0 | QMD记忆清理服务 |
| memory-system | 1.0.0 | 自动记忆持久化 |
| smart-browser | 1.0.0 | 智能浏览器控制 |
| config-merged | 1.0.0 | 配置合并工具 |

### 📦 官方技能 (53个精选10个展示)
| 技能 | 版本 | 描述 | 下载 |
|------|------|------|------|
| github | 2.0.0 | GitHub CLI集成 | 1250 |
| notion | 1.5.0 | Notion数据库管理 | 980 |
| slack | 1.3.0 | Slack机器人 | 890 |
| spotify-player | 1.2.0 | Spotify控制 | 750 |
| discord | 1.1.0 | Discord消息管理 | 680 |
| obsidian | 1.4.0 | Obsidian双向链接 | 620 |
| trello | 1.0.0 | 看板管理 | 540 |
| weather | 1.2.0 | 天气预报 | 2100 |
| healthcheck | 1.1.0 | 系统健康检查 | 890 |
| sag | 1.3.0 | ElevenLabs语音合成 | 1120 |

**更多官方技能**: `~/.npm-global/lib/node_modules/openclaw/skills/` (共53个)

---

## 🚀 快速开始

### 1. 安装QMD (必装！)

```bash
# 克隆QMD仓库 (如果还没装)
git clone https://github.com/tobilo/qmd ~/.qmd
cd ~/.qmd && npm install

# 添加到PATH
export PATH="$HOME/.qmd/bin:$PATH"
```

### 2. 使用CLI

```bash
# 添加到PATH
export PATH="$HOME/.openclaw/.local/bin:$PATH"

# 查看重磅推荐 ⭐⭐⭐
openclaw-skill featured

# 查看QMD裂变能力
openclaw-skill fission qmd-core

# 列出所有技能
openclaw-skill list

# 搜索技能
openclaw-skill search qmd
openclaw-skill search github

# 查看技能详情
openclaw-skill info qmd-core

# 查看官方技能
openclaw-skill official
```

### 3. QMD基础命令

```bash
# 索引文档
qmd embed

# 语义搜索
qmd vsearch "你的问题"

# 混合搜索 (关键词+语义)
qmd query "关键词"

# 查看状态
qmd status
```

---

## 🛣️ 开发QMD裂变技能

想基于QMD开发新技能？只需要这几步：

### 1. 设计你的Skill

```bash
# 创建技能目录
mkdir -p ~/.openclaw/workspace/skills/qmd-bookmarks/{scripts,config}

# 编写 SKILL.md
cat > ~/.openclaw/workspace/skills/qmd-bookmarks/SKILL.md << 'EOF'
# QMD Bookmarks

## 描述
基于QMD的智能书签管理

## 安装
echo "已集成到QMD"

## 使用
```bash
# 添加书签
qmd-bm add "https://example.com" "示例网站" "技术 博客"

# 语义搜索
qmd-bm search "那个讲AI记忆的文章"
```

## 依赖
- qmd
- jq

## 状态
- ✅ 添加书签
- ✅ 语义搜索

## 作者
@YourName
EOF
```

### 2. 编写脚本

```bash
# ~/.openclaw/workspace/skills/qmd-bookmarks/scripts/add.sh
#!/bin/bash
# 添加书签到QMD索引

URL=$1
TITLE=$2
TAGS=$3

# 保存到markdown
DATE=$(date +%Y-%m-%d)
cat >> ~/.openclaw/workspace/memory/bookmarks.md << EOF

## [$TITLE]($URL)
- URL: $URL
- Tags: $TAGS
- Added: $DATE

$TITLE - $TAGS

EOF

# 重新索引
qmd embed
echo "✅ 书签已添加并索引"
```

### 3. 注册到商店

编辑 `~/.openclaw/skill-store/registry.json`，添加：

```json
{
  "id": "qmd-bookmarks",
  "name": "QMD Bookmarks",
  "version": "1.0.0",
  "description": "基于QMD的智能书签管理",
  "author": "你的名字",
  "category": "productivity",
  "tags": ["bookmarks", "qmd", "productivity"],
  "source": "local",
  "path": "../workspace/skills/qmd-bookmarks",
  "status": "stable",
  "installed": true,
  "parent_skill": "qmd-core"
}
```

### 4. 发布

```bash
cd ~/.openclaw/workspace
git add skills/qmd-bookmarks skill-store/registry.json
git commit -m "feat: Add qmd-bookmarks skill"
```

**恭喜你！你开发了一个基于QMD的裂变技能！** 🎉

---

## 📊 统计数据

```
总技能: 62
├─ 🌟 Featured: 1 (QMD Core)
├─ 🛠️  自定义: 9
├─ 📦 官方: 53 (展示10个)
└─ 总计下载: 15,000+

已安装: 8个
分类:
├─ 🧠 记忆类: 3
├─ 🦞 社交类: 2
├─ ⚙️  系统类: 4
└─ 🌟 Featured: 1
```

---

## 📜 许可

MIT License - 自由使用，欢迎贡献

**特别鼓励**: 基于QMD开发裂变技能，越多越好！

---

*Created by Dabing_Jiage | v1.1.0 | 2026-02-18*

🌟 **推荐所有人先装 QMD Core —— 它会让你的AI拥有真正的记忆力！** ₿
