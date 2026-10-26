#!/bin/bash

# LinuxOps - System Health Check

PROJECT_DIR="$HOME/linuxops"
REPORT_DIR="$PROJECT_DIR/reports"
CONFIG_FILE="$PROJECT_DIR/config/thresholds.conf"

# Load monitoring thresholds
if [[ ! -r "$CONFIG_FILE" ]]; then
    echo "ERROR: Cannot read $CONFIG_FILE"
    exit 2
fi

# shellcheck disable=SC1090
source "$CONFIG_FILE"

# Validate configuration values
if ! [[ "$DISK_THRESHOLD" =~ ^[0-9]+$ ]] ||
   ! [[ "$MEMORY_THRESHOLD" =~ ^[0-9]+$ ]] ||
   (( DISK_THRESHOLD > 100 || MEMORY_THRESHOLD > 100 )); then
    echo "ERROR: Thresholds must be numbers from 0 to 100."
    exit 2
fi

mkdir -p "$REPORT_DIR" || exit 2

TIMESTAMP=$(date "+%Y-%m-%d_%H-%M-%S")
REPORT_FILE="$REPORT_DIR/health_$TIMESTAMP.txt"

# Collect system metrics
DISK_USAGE=$(df -P / | awk 'NR==2 {gsub("%","",$5); print $5}')
MEMORY_USAGE=$(free | awk '/^Mem:/ {printf "%d", ($3/$2)*100}')

if ! [[ "$DISK_USAGE" =~ ^[0-9]+$ ]] ||
   ! [[ "$MEMORY_USAGE" =~ ^[0-9]+$ ]]; then
    echo "ERROR: Could not collect system metrics."
    exit 2
fi

STATUS=0

if (( DISK_USAGE >= DISK_THRESHOLD )); then
    DISK_STATUS="WARNING"
    STATUS=1
else
    DISK_STATUS="OK"
fi

if (( MEMORY_USAGE >= MEMORY_THRESHOLD )); then
    MEMORY_STATUS="WARNING"
    STATUS=1
else
    MEMORY_STATUS="OK"
fi

# Generate report
{
    echo "=================================="
    echo "       LINUXOPS HEALTH REPORT"
    echo "=================================="
    echo "Date: $(date)"
    echo "Hostname: $(hostname)"
    echo

    echo "----- SYSTEM UPTIME -----"
    uptime
    echo

    echo "----- MEMORY -----"
    free -h
    echo "Memory usage: ${MEMORY_USAGE}%"
    echo "Memory status: $MEMORY_STATUS"
    echo

    echo "----- DISK -----"
    df -h /
    echo "Root disk usage: ${DISK_USAGE}%"
    echo "Disk status: $DISK_STATUS"
    echo

    echo "----- TOP PROCESSES -----"
    ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -n 6
    echo

    echo "----- OVERALL STATUS -----"
    if (( STATUS == 0 )); then
        echo "OK: All configured thresholds are satisfied."
    else
        echo "WARNING: One or more thresholds have been reached."
    fi
} > "$REPORT_FILE" || {
    echo "ERROR: Failed to write report."
    exit 2
}

cat "$REPORT_FILE"

echo
echo "Report saved to: $REPORT_FILE"
exit "$STATUS"

