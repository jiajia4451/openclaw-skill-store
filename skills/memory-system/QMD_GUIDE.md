# QMD 完整指南 - 为什么我们需要它

## QMD 是什么？

**QMD (Query Markup Documents)** = 本地智能搜索引擎

不是简单的文件搜索，而是**理解语义的AI级搜索**。

---

## 🎯 QMD 三大核心价值

### 1. 💰 省钱！替代昂贵的OpenAI API

| 方案 | 成本 | 隐私 |
|------|------|------|
| OpenAI embedding | $0.0001/1K tokens | 数据送云端 |
| Google embedding | 有免费额度但有限 | 数据送云端 |
| **QMD** | **完全免费** ✅ | **本地运行** ✅ |

**算笔账**：
- 搜索100次记忆 ≈ 消耗 100K tokens（如果走OpenAI）
- 100K tokens × $0.0001 = **$0.01/次**
- 每天搜索100次 = **$1/天 = $30/月**
- **QMD = $0/月** ✅

---

### 2. 🧠 减少Token消耗！智能上下文管理

**问题**：当前我的上下文窗口限制131K tokens，记忆文件太多会撑爆

**传统方式**：
```
用户问: "moltbook发帖API怎么搞？"
↓
我: 读取整个MEMORY.md (10K tokens)
    + 读取2026-02-17.md (5K tokens)
    + 读取moltbook-post-solved.md (3K tokens)
    + ... 其他文件
↓
总共消耗: ~20K tokens 上下文
```

**QMD方式**：
```
用户问: "moltbook发帖API怎么搞？"
↓
QMD搜索: "moltbook发帖API" → 返回最相关的3个片段 (500 tokens)
↓
我只读取这3个片段
↓
总共消耗: ~500 tokens 上下文 ✅
节省: 95% token！
```

---

### 3. 🔍 比grep更智能！语义理解

**grep的局限**：
- 只能找"完全一样的字"
- "发帖API" 搜不到 "post.sh脚本"

**QMD的优势**：
- 理解语义关联
- "发帖API" 能找到 "post.sh", "submolt字段", "API破解"
- 智能评分排序

**实际例子**：
```bash
# grep搜索
grep "API失效" memory/*.md  
# 结果: 0条（因为文件里写的是"API认证失败"）

# QMD搜索
qmd search "API失效"
# 结果: 找到"API认证失败"相关内容 ✅
```

---

## 🛠️ QMD 具体能帮我们做什么？

### 场景1: 快速恢复上下文
**你**: "上次说的那个方案怎么样了？"
**我**: 
- 传统: 懵，得翻半天文件
- QMD: 秒搜到相关记忆 → 准确回答

### 场景2: 跨文件关联
**你**: "moltbook和vision-core有什么关联？"
**我**:
- 传统: 得分别读两个skill文档
- QMD: 搜索找到两个文件中相关的内容 → 整合回答

### 场景3: 避免重复犯错
**你**: "为什么又卡住了？"
**我**: 
- QMD搜"错误/教训/卡住" → 找到之前的踩坑记录 → 避免重复

### 场景4: 项目进度追踪
**你**: "美乳投票项目现在什么状态？"
**我**:
- QMD搜"美乳投票" → 找到所有相关记录 → 完整汇报进度

---

## ⚙️ 技术原理（简单版）

```
用户查询: "API破解"
    ↓
[Query Expansion] 扩展查询词: "API破解", "post API", "字段破解"
    ↓
[BM25搜索] 全文匹配 → 候选结果A
[向量搜索] 语义相似 → 候选结果B  
    ↓
[RRF Fusion] 合并结果，去重排序
    ↓
[LLM Re-ranking] Qwen模型重新评分
    ↓
最终输出: 最相关的5个片段
```

---

## 📊 当前我们的QMD配置

```
Collection: openclaw-memory
路径: /home/jiajia4451/.openclaw/workspace/memory/
文件数: 23个
Chunks: 73个
状态: ✅ 已索引，已嵌入向量
模型: embeddinggemma-300M (本地运行)
```

**使用方式**：
```bash
# 基本搜索（BM25，快）
./skills/memory-system/scripts/qmd-search.sh "关键词"

# 混合搜索（最准，稍慢）
./skills/memory-system/scripts/qmd-search.sh "关键词" query
```

---

## 🚀 下一步优化建议

1. **增量更新**: 每天新记忆自动embed
   ```bash
   qmd embed  # 只更新变更的文件
   ```

2. **多Collection**: 区分工作记忆和个人笔记
   ```bash
   qmd collection add ~/notes --name personal-notes
   ```

3. **配合我使用**: 
   - 你问我问题前，我先QMD搜索相关记忆
   - 只把最相关的片段加入上下文
   - 大幅减少token消耗，提高回答质量

---

## 💡 一句话总结

> **QMD = 免费的OpenAI语义搜索 + 减少95%token消耗 + 比grep更聪明**

它是我们的"第二大脑"索引系统！
