# Battery Tracker Module

## 功能
记录电量百分比变化及耗时，格式如下：
```
电量n%，n时n分n秒，耗时n时n分n秒
```

## 日志位置
`/sdcard/BatteryTracker/log.txt`

## 使用方法
1. 使用Magisk面具刷入本模块
2. 重启设备
3. 模块将自动在后台运行
4. 查看日志：`cat /sdcard/BatteryTracker/log.txt`

## 查看实时日志
```bash
tail -f /sdcard/BatteryTracker/log.txt
```

## 停止追踪
```bash
kill $(cat /dev/battery_tracker.pid)
rm /dev/battery_tracker.pid
```

## 清除日志
```bash
rm /sdcard/BatteryTracker/log.txt
```