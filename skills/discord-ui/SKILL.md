# discord-ui - Discord交互组件

快速构建Discord Bot交互界面：按钮、选择菜单、模态框、附件支持。

## 功能

- **按钮组件**: 原生Discord按钮快速创建
- **选择菜单**: 下拉选择、多选菜单
- **模态框**: 弹出表单收集用户输入
- **附件支持**: 文件上传/下载处理

## 安装

```bash
curl -fsSL https://raw.githubusercontent.com/jiajia4451/openclaw-skill-store/skills/install.sh | bash -s discord-ui
```

## 使用

```bash
# 创建按钮消息
discord-ui button --channel=123456 --label="点击我" --style=primary

# 创建选择菜单
discord-ui select --channel=123456 --options="选项1,选项2,选项3"

# 创建模态框
discord-ui modal --title="用户信息" --fields="姓名,邮箱,反馈"
```

## 状态

- **版本**: v1.0.0
- **作者**: OpenClaw
- **类型**: 社交通讯
- **商店**: ✅ 上架 OpenClaw Skill Store
- **要求**: OpenClaw v2026.2.15+ (Discord Components v2)