#!/system/bin/sh
# Battery Tracker Module
# Records battery percentage changes with timestamps

LOG_FILE="/sdcard/BatteryTracker/log.txt"
PID_FILE="/dev/battery_tracker.pid"

# Create log directory if not exists
mkdir -p /sdcard/BatteryTracker

# Check if already running
if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat "$PID_FILE")
    if kill -0 "$OLD_PID" 2>/dev/null; then
        exit 1
    fi
fi

# Write PID
echo $$ > "$PID_FILE"

# Initialize
LAST_PERCENT=""
START_TIME=""

# Get current time in format: n时n分n秒
get_time_str() {
    local t=$(date +"%H时%M分%S秒")
    echo "$t"
}

# Calculate duration
calc_duration() {
    local start=$1
    local end=$2
    
    if [ -z "$start" ] || [ -z "$end" ]; then
        echo "00时00分00秒"
        return
    fi
    
    local start_sec=$(echo "$start" | awk -F: '{print $1*3600 + $2*60 + $3}')
    local end_sec=$(echo "$end" | awk -F: '{print $1*3600 + $2*60 + $3}')
    
    local diff=$((end_sec - start_sec))
    
    if [ $diff -lt 0 ]; then
        diff=0
    fi
    
    local hours=$((diff / 3600))
    local minutes=$(((diff % 3600) / 60))
    local seconds=$((diff % 60))
    
    printf "%02d时%02d分%02d秒\n" $hours $minutes $seconds
}

# Get battery percentage
get_battery_percent() {
    local level=$(cat /sys/class/power_supply/battery/capacity 2>/dev/null)
    if [ -z "$level" ]; then
        level=$(dumpsys battery | grep level | awk '{print $2}')
    fi
    echo "$level"
}

# Get current time in seconds since epoch
get_time_seconds() {
    date +%s
}

# Main tracking loop
while true; do
    CURRENT_PERCENT=$(get_battery_percent)
    CURRENT_TIME=$(get_time_str)
    CURRENT_SECONDS=$(get_time_seconds)
    
    if [ -n "$CURRENT_PERCENT" ]; then
        if [ -n "$LAST_PERCENT" ] && [ "$CURRENT_PERCENT" != "$LAST_PERCENT" ]; then
            # Battery percentage changed
            DURATION=$(calc_duration "$START_TIME_SEC" "$CURRENT_SECONDS")
            echo "电量${CURRENT_PERCENT}%，${CURRENT_TIME}，耗时${DURATION}" >> "$LOG_FILE"
        fi
        
        if [ "$CURRENT_PERCENT" != "$LAST_PERCENT" ]; then
            LAST_PERCENT="$CURRENT_PERCENT"
            START_TIME="$CURRENT_TIME"
            START_TIME_SEC="$CURRENT_SECONDS"
        fi
    fi
    
    sleep 10
done