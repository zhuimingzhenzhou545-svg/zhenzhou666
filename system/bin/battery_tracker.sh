#!/system/bin/sh
# 电量追踪器 - 主脚本
# 功能：监控电量变化并记录日志

LOG_DIR="/sdcard/BatteryTracker"
LOG_FILE="${LOG_DIR}/log.txt"
PID_FILE="/dev/battery_tracker.pid"
PID_WEB="/dev/battery_web.pid"

# 创建日志目录
mkdir -p "${LOG_DIR}"

# 检查是否已运行
if [ -f "${PID_FILE}" ]; then
    OLD_PID=$(cat "${PID_FILE}")
    if kill -0 "${OLD_PID}" 2>/dev/null; then
        exit 0
    fi
fi

# 写入PID
echo $$ > "${PID_FILE}"

# 初始化
LAST_PERCENT=""
LAST_TIME_S=""

# 获取电量百分比
get_battery_percent() {
    local level=$(cat /sys/class/power_supply/battery/capacity 2>/dev/null)
    if [ -z "${level}" ]; then
        level=$(dumpsys battery 2>/dev/null | grep level | awk '{print $2}')
    fi
    if [ -z "${level}" ]; then
        level=$(cat /sys/class/power_supply/battery/capacity 2>/dev/null)
    fi
    echo "${level}"
}

# 记录初始时间戳
get_time_seconds() {
    date +%s
}

# 获取格式化时间
get_time_str() {
    local h=$(date +%H)
    local m=$(date +%M)
    local s=$(date +%S)
    echo "${h}时${m}分${s}秒"
}

# 计算耗时并格式化
calc_duration() {
    local start=$1
    local end=$2
    local diff=$((end - start))
    if [ ${diff} -lt 0 ]; then
        diff=0
    fi
    local hours=$((diff / 3600))
    local minutes=$(((diff % 3600) / 60))
    local seconds=$((diff % 60))
    printf "%02d时%02d分%02d秒" ${hours} ${minutes} ${seconds}
}

# 主循环
while true; do
    CURRENT_PERCENT=$(get_battery_percent)
    CURRENT_TIME=$(get_time_str)
    CURRENT_TIME_S=$(get_time_seconds)

    if [ -n "${CURRENT_PERCENT}" ]; then
        if [ -n "${LAST_PERCENT}" ] && [ "${CURRENT_PERCENT}" != "${LAST_PERCENT}" ]; then
            # 电量变化，记录
            DURATION=$(calc_duration "${LAST_TIME_S}" "${CURRENT_TIME_S}")
            echo "电量${CURRENT_PERCENT}%，${CURRENT_TIME}，耗时${DURATION}" >> "${LOG_FILE}"
        fi

        if [ "${CURRENT_PERCENT}" != "${LAST_PERCENT}" ]; then
            LAST_PERCENT="${CURRENT_PERCENT}"
            LAST_TIME_S="${CURRENT_TIME_S}"
        fi
    fi

    sleep 10
done
