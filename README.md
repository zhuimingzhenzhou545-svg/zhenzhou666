# 电量追踪器 Battery Tracker v2.0

一款用于安卓设备的电量变化记录工具（Magisk模块）。

## 功能特性
- 🔋 实时记录电量百分比变化及耗时
- 🌐 内置Web服务器，提供精美中文界面查看数据
- 📊 支持统计：记录总数、起始/结束电量、总耗时
- 📥 支持导出 CSV 格式数据
- 🚀 开机自启动，无需手动操作

## 安装步骤

1. 在 Magisk Manager 中刷入 `电量追踪器.zip`
2. 重启设备
3. 等待1-2分钟，让服务启动
4. 在手机浏览器中访问：
   - **http://localhost:8888**
   - 或 **http://你的设备IP:8888**

## 文件路径

- 日志文件：`/sdcard/BatteryTracker/log.txt`
- 主脚本：`/system/bin/battery_tracker.sh`
- Web服务：`/system/bin/battery_web.sh`
- 记录格式：`电量n%，n时n分n秒，耗时n时n分n秒`

## 手动控制

```bash
# 启动追踪
sh /system/bin/battery_tracker.sh

# 启动Web服务
sh /system/bin/battery_web.sh

# 查看日志
cat /sdcard/BatteryTracker/log.txt

# 清空日志
rm /sdcard/BatteryTracker/log.txt
```

## 日志示例

```
电量85%，16时30分00秒，耗时00时05分30秒
电量84%，16时35分30秒，耗时00时12分45秒
电量80%，17时13分15秒，耗时00时45分10秒
```

## 技术说明

- 需要：Android + Magisk + Python3 或 busybox
- 电量记录：每10秒检查一次电量，变化时写入日志
- Web服务：端口 8888，内置 Python HTTP 服务器
