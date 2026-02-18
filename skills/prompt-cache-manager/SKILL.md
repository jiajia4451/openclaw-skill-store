# prompt-cache-manager - Prompt缓存管理

管理OpenClaw Prompt缓存，提升命中率70-90%，追踪热点Prompt，生成成本节省报告。

## 功能

- **缓存统计**: 实时监控缓存命中率
- **热点分析**: 识别高频使用Prompt
- **智能清理**: 自动清理过期缓存
- **成本报告**: 量化缓存带来的节省

## 安装

```bash
curl -fsSL https://raw.githubusercontent.com/jiajia4451/openclaw-skill-store/skills/install.sh | bash -s prompt-cache-manager
```

## 使用

```bash
# 查看缓存统计
prompt-cache-manager stats

# 分析热点Prompt
prompt-cache-manager hotspots

# 清理过期缓存
prompt-cache-manager clean --older-than=7d

# 生成成本报告
prompt-cache-manager report --period=weekly
```

## 状态

- **版本**: v1.0.0
- **作者**: OpenClaw
- **类型**: 工具类
- **商店**: ✅ 上架 OpenClaw Skill Store