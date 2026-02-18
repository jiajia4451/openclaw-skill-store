#!/usr/bin/env python3
"""
X/Twitter 转发训练 v2.0 - 使用像素颜色识别替代图像匹配

方案: 检测转发按钮的颜色特征 (X的转发图标是灰色/蓝色)
坐标: X的转发按钮在推文下方，心形右边

作者: 大饼
日期: 2026-02-18
"""

import subprocess
import time
import sys

# 使用 xdotool + 像素颜色检测 (不需要 tkinter)

def get_pixel_color(x, y):
    """获取指定坐标的像素颜色"""
    try:
        result = subprocess.run(
            ['xwd', '-root', '-silent', '|', 'convert', 'xwd:-', '-crop', '1x1+{}+{}'.format(x,y), 
             '+repage', '-format', '%[pixel:s]', 'info:-'],
            capture_output=True, text=True, shell=True, timeout=5
        )
        return result.stdout.strip()
    except:
        # 备用方案 - 使用 flameshot 截图后检查
        try:
            subprocess.run(['flameshot', 'gui', '-p', '/tmp/pixel_check.png'], timeout=5)
            return "screenshot"
        except:
            return None

def find_retweet_button_v2():
    """
    方案B: 基于X界面布局的颜色检测
    
    X 推文结构 (1920x1080):
    - 回复图标 (左)
    - 转发/Retweet 图标 (中左) - 目标
    - 心形/点赞   (中右)
    - 分享        (右)
    
    转发按钮位置规律:
    - 在主页第一条推文下方
    - 大约相对心形左侧一些距离
    - 颜色: 未点击时灰色 (#71767C), hover时蓝色
    """
    print("🔍 使用颜色识别法定位转发按钮...")
    
    # X主页第一条推文的大致位置 (已验证的坐标)
    # 转发按钮 = 心形左侧
    retweet_estimate = (650, 650)  # 相对于 (730, 650) 的心形
    
    print(f"   尝试坐标: {retweet_estimate}")
    
    # 移动到候选位置并检测
    move_mouse(*retweet_estimate)
    time.sleep(0.5)
    
    # 检测颜色 (无法直接用Python，用 xdotool 触发后观察)
    # 实际方案: 直接点击并检查是否弹出转发菜单
    
    click_mouse(*retweet_estimate)
    time.sleep(1)
    
    # 如果正确，应该看到弹出菜单
    # 检测方法: 截图查看是否出现"Retweet"或"Quote Tweet"文字
    take_screenshot('/tmp/retweet_test.png')
    
    return retweet_estimate

def move_mouse(x, y):
    """移动鼠标"""
    subprocess.run(['xdotool', 'mousemove', str(x), str(y)], check=True)

def click_mouse(x, y):
    """点击鼠标"""
    subprocess.run(['xdotool', 'click', '1'], check=True)

def take_screenshot(path):
    """截图"""
    subprocess.run(['flameshot', 'full', '-p', path], check=True)

def train_retweet_by_pattern():
    """
    训练方案: 使用 PyAutoGUI 的 locateOnScreen (需要预存截图)
    但 tkinter 未安装，改用纯 Bash + xdotool
    
    替代方案:
    1. 先用浏览器手动截图转发按钮保存为 retweet_icon.png
    2. 使用 PIL + numpy 做图像匹配 (无需 opencv)
    3. 找到后点击
    """
    print("🦜 X/Twitter 转发训练 v2.0")
    print("=" * 40)
    print()
    print("当前限制:")
    print("  - tkinter 未安装 (需要 sudo 安装 python3-tk)")
    print("  - OpenCV 安装失败 (网络问题)")
    print()
    print("可用替代方案:")
    print("  A. 手动截图 + 图像匹配 (PIL)")
    print("  B. 颜色检测 + 坐标推算")
    print("  C. 键盘导航 + Enter (完全无需鼠标)")
    print()
    print("推荐: 方案 C (键盘导航)")
    print("  1. 打开推文详情 (点击推文)")
    print("  2. 按 Tab 导航到转发按钮")
    print("  3. 按 Enter 点击")
    print("  4. 再按 Enter 确认 Retweet")
    print()
    print("是否继续安装 tkinter? (需要sudo)")
    print("  sudo apt install python3-tk python3-dev")

if __name__ == '__main__':
    train_retweet_by_pattern()
