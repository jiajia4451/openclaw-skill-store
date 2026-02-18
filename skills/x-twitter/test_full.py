#!/usr/bin/env python3
"""PyAutoGUI 完整功能测试"""

import pyautogui
import cv2
import time

print("🤖 PyAutoGUI 完整功能测试")
print("=" * 40)

# 安全设置
pyautogui.FAILSAFE = True

print("\n1️⃣ 屏幕尺寸:")
width, height = pyautogui.size()
print(f"   分辨率: {width}x{height}")

print("\n2️⃣ 鼠标位置:")
x, y = pyautogui.position()
print(f"   当前位置: ({x}, {y})")

print("\n3️⃣ 截图功能:")
screenshot = pyautogui.screenshot()
screenshot.save('/tmp/test_screen.png')
print(f"   ✅ 截图已保存: /tmp/test_screen.png")

print("\n4️⃣ 像素颜色:")
color = pyautogui.pixel(x, y)
print(f"   当前位置颜色: {color}")

print("\n5️⃣ OpenCV 检查:")
print(f"   ✅ OpenCV 版本: {cv2.__version__}")

print("\n✅ PyAutoGUI 完整功能测试通过!")
print("\n🎉 现在可以开始训练 X/Twitter 转发功能!")
