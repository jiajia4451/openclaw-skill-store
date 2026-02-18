# security-scanner - 安全扫描

企业级安全扫描，VirusTotal集成，检测SSRF、路径穿越、凭证泄露等100+安全风险。

## 功能

- **文件扫描**: VirusTotal API集成
- **URL检测**: 恶意链接识别
- **漏洞扫描**: SSRF、路径穿越、容器逃逸
- **合规检查**: 企业安全合规报告
- **凭证保护**: 自动检测敏感信息泄露

## 安装

```bash
curl -fsSL https://raw.githubusercontent.com/jiajia4451/openclaw-skill-store/skills/install.sh | bash -s security-scanner
```

## 使用

```bash
# 扫描文件
security-scanner file ./suspicious-file.bin

# 扫描URL
security-scanner url https://example.com

# 扫描代码仓库
security-scanner repo ./my-project

# 生成合规报告
security-scanner report --format=pdf
```

## 状态

- **版本**: v1.0.0
- **作者**: OpenClaw
- **类型**: 安全工具
- **商店**: ✅ 上架 OpenClaw Skill Store
- **要求**: VirusTotal API Key