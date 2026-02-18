# agent-swarm - 多代理调度器

协调多个子代理执行任务，Token消耗节省40-70%，实现真正的Agent Swarm。

## 功能

- **代理注册**: 子代理心跳注册与管理
- **任务分发**: 轮询/负载均衡/优先级调度
- **休眠唤醒**: 空闲代理自动休眠，需要时唤醒
- **状态监控**: Swarm实时状态面板
- **结果合并**: 多代理结果自动整合

## 安装

```bash
curl -fsSL https://raw.githubusercontent.com/jiajia4451/openclaw-skill-store/skills/install.sh | bash -s agent-swarm
```

## 系统服务配置

**自动激活**: 安装后自动成为 OpenClaw 子代理调度核心

## 使用

```bash
# 注册子代理
agent-swarm register research-agent --type=research --priority=high

# 分发任务
agent-swarm dispatch "研究量子计算最新进展" \
  --agents="research-agent,summary-agent,citation-agent" \
  --mode=parallel

# 查看Swarm状态
agent-swarm status

# 休眠空闲代理
agent-swarm hibernate

# 唤醒指定代理
agent-swarm wake research-agent
```

## 调度模式

| 模式 | 描述 | 适用场景 |
|------|------|---------|
| `parallel` | 并行执行，全部完成合并 | 独立子任务 |
| `pipeline` | 流水线，前一个输出给下一个 | 依赖任务 |
| `priority` | 按优先级执行，高优先 | 紧急任务 |
| `round-robin` | 轮询分配 | 负载均衡 |

## 状态

- **版本**: v1.0.0
- **作者**: OpenClaw
- **类型**: 系统服务 (自动激活)