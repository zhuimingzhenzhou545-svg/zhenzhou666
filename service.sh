#!/system/bin/sh
# 电量追踪器 - 开机自启动脚本

LOG_DIR="/sdcard/BatteryTracker"
mkdir -p "${LOG_DIR}"

# 等待系统完全启动
sleep 20

# 启动电量追踪服务
nohup /system/bin/battery_tracker.sh > /dev/null 2>&1 &

# 启动Web服务器
nohup /system/bin/battery_web.sh > /dev/null 2>&1 &

exit 0
