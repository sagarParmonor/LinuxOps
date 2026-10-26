
#!/bin/bash

# LinuxOps - Health Check Tests

PROJECT_DIR="$HOME/linuxops"
CONFIG_FILE="$PROJECT_DIR/config/thresholds.conf"
HEALTH_SCRIPT="$PROJECT_DIR/scripts/health_check.sh"

# Verify the required files exist
if [[ ! -f "$CONFIG_FILE" || ! -f "$HEALTH_SCRIPT" ]]; then
    echo "FAIL: Required project files are missing."
    exit 1
fi

if [[ ! -x "$HEALTH_SCRIPT" ]]; then
    echo "FAIL: Health check script is not executable."
    exit 1
fi

echo "PASS: Required files exist and script is executable."

# Back up configuration before testing
BACKUP_FILE=$(mktemp) || exit 1
OUTPUT_FILE=$(mktemp) || {
    rm -f "$BACKUP_FILE"
    exit 1
}

cp "$CONFIG_FILE" "$BACKUP_FILE" || {
    rm -f "$BACKUP_FILE" "$OUTPUT_FILE"
    exit 1
}

# Always restore the original configuration
cleanup() {
    cp "$BACKUP_FILE" "$CONFIG_FILE"
    rm -f "$BACKUP_FILE" "$OUTPUT_FILE"
}

trap cleanup EXIT

# Set thresholds to zero to force a warning
printf 'DISK_THRESHOLD=0\nMEMORY_THRESHOLD=0\n' > "$CONFIG_FILE"

echo "Testing warning detection..."

if "$HEALTH_SCRIPT" > "$OUTPUT_FILE" 2>&1; then
    EXIT_CODE=0
else
    EXIT_CODE=$?
fi

if [[ "$EXIT_CODE" -eq 1 ]] &&
   grep -q "WARNING" "$OUTPUT_FILE"; then
    echo "PASS: Warning detection works."
else
    echo "FAIL: Warning detection did not behave as expected."
    echo "Exit code: $EXIT_CODE"
    cat "$OUTPUT_FILE"
    exit 1
fi

echo "All tests passed."
