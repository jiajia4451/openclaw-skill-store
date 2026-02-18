# Vision-Core Skill

## 功能
完整桌面视觉与控制能力（眼睛👁️ + 手脚🖐️）

**核心原则**: X11桌面控制优先，浏览器控制只是可选补充

---

## 🎯 正确的视觉工作流

### 第一优先级：X11 桌面视觉（推荐）
```
收到用户截图/需求
  ↓
直接分析图片内容（用户已提供）
  ↓
用 xdotool 执行操作（点击、输入、快捷键）
 ↓
如需验证，请用户发截图确认
```

### 第二优先级：启动浏览器（仅在需要时）
```
需要操作网页且用户未提供截图
  ↓
启动 Chrome（xdotool 直接控制）
  ↓
windowactivate 激活到前台
  ↓
执行操作
  ↓
最小化（不要关闭）
```

**重要**: Chrome浏览器控制 ≠ Chrome扩展！我们使用xdotool直接控制窗口，不需要安装任何扩展。

---

## ✅ 正确的工作规范

### 当用户发截图时
| 场景 | 操作 |
|------|------|
| 用户已发截图 | ✅ **直接分析截图**，不需要开浏览器！ |
| 需要操作某个应用 | ✅ 用 xdotool 直接控制该应用 |
| 需要打开网页 | ✅ 启动 Chrome，操作完最小化 |
| 需要验证结果 | ✅ 请用户发截图确认 |

### 当用户没发截图时
| 场景 | 操作 |
|------|------|
| 需要网页操作 | 启动 Chrome，操作完最小化 |
| 需要桌面操作 | 直接用 xdotool |
| 不确定状态 | **问用户要截图** |

**禁止**: ❌ 明明有截图还要问"你看到什么"  
**禁止**: ❌ 没截图时硬要连什么Chrome扩展

---

## 🛠️ 脚本使用

### 1. 截图当前桌面（X11）
```bash
./scripts/capture-screen.sh [文件名]
```
**注意**: 这需要X11会话。在WebChat环境下，**请用户发截图**更可靠。

### 2. 点击坐标
```bash
./scripts/click-coord.sh X Y
```
- 自动激活窗口并点击
- 适用于任何X11应用，不限于Chrome

### 3. 启动 Chrome（需要时再用）
```bash
./scripts/start-chrome.sh
```
- 检查是否已有Chrome运行
- 无则启动，有则激活
- **仅在需要网页操作时使用**

### 4. 智能操作序列
```bash
./scripts/smart-action.sh
```
流程: 激活 → 操作 → 分析 → 执行 → 最小化

---

## 🖱️ xdotool 核心命令

```bash
# 查找任何窗口（不只是Chrome）
WID=$(xdotool search --class "应用类名" | tail -1)

# 激活窗口（关键！）
xdotool windowactivate $WID

# 移动鼠标
xdotool mousemove X Y

# 点击
xdotool click 1

# 输入文字
xdotool type --delay 30 "文字"

# 快捷键
xdotool key ctrl+t    # 新标签
xdotool key ctrl+w    # 关闭标签
xdotool key ctrl+l    # 聚焦地址栏
xdotool key Return    # 回车
xdotool key Escape    # ESC

# 最小化（推荐，不要关闭）
xdotool windowminimize $WID
```

---

## 📸 截图工具选择

| 场景 | 工具 | 命令 |
|------|------|------|
| 全屏 | Flameshot | `flameshot full --path ~/图片/xxx.png` |
| 区域 | Flameshot | `flameshot gui --path ~/图片/xxx.png` |
| 指定窗口 | xdotool | `xdotool windowcapture $WID ~/图片/xxx.png` |
| WebChat环境 | **用户发送** | 请用户发截图 |

**WebChat环境限制**: 由于X11会话隔离，直接截图可能失败。  
**解决方案**: 请用户发截图 → 分析 → 用xdotool执行操作

---

## 🔄 正确的工作流程

### 场景1: 用户发截图问问题
```
用户: [发送截图]
  ↓
我: 直接分析图片内容 ✅
  ↓
如果需要操作: 用xdotool执行
  ↓
如果需要验证: "操作完成，请截图确认"
```

### 场景2: 用户要求操作网页
```
用户: "帮我打开moltbook.com"
  ↓
我: 启动Chrome → 打开网页 → 操作 → 最小化 ✅
  ↓
"已完成，请查看"
```

### 场景3: 需要验证结果
```
我: 执行操作
  ↓
"请发当前屏幕截图，我确认操作结果"
  ↓
用户: [发截图]
  ↓
我: 分析并反馈
```

---

## ⚠️ 常见错误（不要再犯）

### ❌ 错误1: 明明有截图还问"你看到什么"
**正确**: 直接分析用户发的截图

### ❌ 错误2: 执着于Chrome扩展
**正确**: 用xdotool直接控制Chrome窗口，不需要扩展

### ❌ 错误3: 没截图时硬要截图
**正确**: 先xdotool盲操作，然后请用户验证

### ❌ 错误4: 操作完关闭Chrome
**正确**: 最小化，保持常驻（避免恢复弹窗）

---

## 🔧 故障排除

### Chrome 恢复弹窗
```bash
# 清除恢复状态
rm ~/.config/google-chrome/Default/Preferences
```

### xdotool 找不到窗口
```bash
# 确保X11会话
# 检查DISPLAY环境变量
echo $DISPLAY  # 应该是 :0 或类似值

# 查找窗口ID
xdotool search --class "google-chrome"
xdotool search --class "firefox"
xdotool search --name "窗口标题"
```

### WebChat环境截图失败
**原因**: X11会话隔离  
**解决**: 请用户发截图 → 分析 → xdotool操作

---

## 💡 核心要点

1. **用户发的截图 = 我的眼睛** ✅  
   不要无视，直接分析

2. **xdotool = 我的手** ✅  
   能控制任何X11应用，不限于浏览器

3. **Chrome = 一个应用** ✅  
   需要时用，用完最小化，不是唯一选择

4. **Chrome扩展 = 不需要** ❌  
   我们用xdotool直接控制，不依赖扩展

---

**版本**: v5.0  
**更新**: 2026-02-17 - 去除Chrome扩展执念，强调X11视觉优先  
**状态**: X11验证通过 ✅
