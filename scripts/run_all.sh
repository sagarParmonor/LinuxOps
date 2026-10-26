#!/bin/bash

# LinuxOps - Master Monitoring Script

REPORT_DIR="reports"
LOG_DIR="logs"

mkdir -p "$REPORT_DIR" "$LOG_DIR"

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
RUN_LOG="$LOG_DIR/monitoring_$TIMESTAMP.log"

echo "===== LinuxOps Monitoring Started =====" | tee -a "$RUN_LOG"
echo "Time: $(date)" | tee -a "$RUN_LOG"

echo
echo "Running system health check..."

./scripts/health_check.sh >> "$RUN_LOG" 2>&1
HEALTH_STATUS=$?

if [[ $HEALTH_STATUS -eq 0 ]]; then
    echo "Health check: PASSED" | tee -a "$RUN_LOG"
else
    echo "Health check: WARNING or FAILED (exit code $HEALTH_STATUS)" | tee -a "$RUN_LOG"
fi

echo
echo "Running log analyzer..."

./scripts/log_analyzer.sh >> "$RUN_LOG" 2>&1
ANALYZER_STATUS=$?

if [[ $ANALYZER_STATUS -eq 0 ]]; then
    echo "Log analyzer: PASSED" | tee -a "$RUN_LOG"
else
    echo "Log analyzer: FAILED (exit code $ANALYZER_STATUS)" | tee -a "$RUN_LOG"
fi

echo | tee -a "$RUN_LOG"
echo "===== Monitoring Finished =====" | tee -a "$RUN_LOG"

if [[ $HEALTH_STATUS -eq 2 || $ANALYZER_STATUS -ne 0 ]]; then
    exit 2
elif [[ $HEALTH_STATUS -ne 0 ]]; then
    exit 1
else
    exit 0
fi
