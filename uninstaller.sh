#!/system/bin/sh
# 电量追踪器 - 卸载清理脚本

# 停止服务
kill $(cat /dev/battery_tracker.pid 2>/dev/null) 2>/dev/null
kill $(cat /dev/battery_web.pid 2>/dev/null) 2>/dev/null

# 清理临时文件
rm -f /dev/battery_tracker.pid
rm -f /dev/battery_web.pid
rm -rf /data/local/BatteryTracker

exit 0
