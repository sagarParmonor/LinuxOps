
#!/bin/bash

# LinuxOps - System Health Check

REPORT_DIR="$HOME/linuxops/reports"
TIMESTAMP=$(date "+%Y-%m-%d_%H-%M-%S")
REPORT_FILE="$REPORT_DIR/health_$TIMESTAMP.txt"

# Ensure the report directory exists
mkdir -p "$REPORT_DIR"

# Start the report
{
    echo "=================================="
    echo "       LINUXOPS HEALTH REPORT"
    echo "=================================="
    echo "Date: $(date)"
    echo "Hostname: $(hostname)"
    echo

    echo "----- UPTIME -----"
    uptime
    echo

    echo "----- MEMORY USAGE -----"
    free -h
    echo

    echo "----- DISK USAGE -----"
    df -h /
    echo

    echo "----- TOP PROCESSES -----"
    ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -n 6
    echo

} > "$REPORT_FILE"

echo "Health check completed."
echo "Report saved to: $REPORT_FILE"
