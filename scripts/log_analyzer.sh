
#!/bin/bash

# LinuxOps - Application Log Analyzer

LOG_FILE="logs/app.log"
REPORT_DIR="reports"

if [[ ! -f "$LOG_FILE" ]]; then
    echo "ERROR: Log file not found: $LOG_FILE"
    exit 2
fi

mkdir -p "$REPORT_DIR"

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
REPORT_FILE="$REPORT_DIR/log_report_$TIMESTAMP.txt"

TOTAL_LINES=$(wc -l < "$LOG_FILE")
ERROR_COUNT=$(grep -c "ERROR" "$LOG_FILE")
WARNING_COUNT=$(grep -c "WARNING" "$LOG_FILE")
INFO_COUNT=$(grep -c "INFO" "$LOG_FILE")

{
    echo "===== LinuxOps Log Analysis ====="
    echo "Generated: $(date)"
    echo "Log file: $LOG_FILE"
    echo "Total lines: $TOTAL_LINES"
    echo "Errors: $ERROR_COUNT"
    echo "Warnings: $WARNING_COUNT"
    echo "Info messages: $INFO_COUNT"
    echo
    echo "===== Error Details ====="
    grep "ERROR" "$LOG_FILE" || echo "No errors found."
} > "$REPORT_FILE"

echo "Log analysis completed."
echo "Report saved to: $REPORT_FILE"
