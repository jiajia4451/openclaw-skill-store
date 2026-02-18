# tool-batcher - 工具批量执行

Parallel tool calling + 结果裁剪，减少2-3倍轮次，复杂任务从5-10轮降到2-4轮。

## 功能

- **批量调用**: 并行执行多个工具
- **智能裁剪**: 只保留需要的字段，减少Token
- **依赖排序**: 有依赖的工具自动串行，无依赖的并行
- **结果合并**: 多工具结果智能整合

## 安装

```bash
curl -fsSL https://raw.githubusercontent.com/jiajia4451/openclaw-skill-store/skills/install.sh | bash -s tool-batcher
```

## 系统服务集成

**自动激活**: 安装后自动拦截工具调用，批量优化

## 使用示例

```bash
# 批量执行
tool-batcher exec \
  --tool=web_search --args="{\"q\":\"量子计算\"}" \
  --tool=web_search --args="{\"q\":\"量子霸权\"}" \
  --tool=web_search --args="{\"q\":\"量子算法\"}" \
  --parallel

# 带依赖的执行
tool-batcher exec \
  --tool=web_search --args="{\"q\":\"OpenAI\"}" --id=search1 \
  --tool=web_fetch --args="{\"url\":\"{{search1.results[0]}}\"}" --depends=search1

# 裁剪结果
tool-batcher crop --fields="title,url,snippet" --max-length=500
```

## 效率提升

| 场景 | 原轮次 | 批量后 | 提升 |
|------|--------|--------|------|
| 多源搜索 | 5轮 | 1轮并行 | 5x |
| 数据聚合 | 8轮 | 2轮 | 4x |
| 链式调用 | 10轮 | 3轮 | 3.3x |

## 状态

- **版本**: v1.0.0
- **作者**: OpenClaw
- **类型**: 系统服务 (自动激活)