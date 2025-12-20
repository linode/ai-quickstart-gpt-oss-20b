#!/usr/bin/env bash

set -euo pipefail

# Get project name from script's parent directory
PROJECT_NAME="$(basename "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)")"

# Log file
LOG_FILE="/var/log/${PROJECT_NAME}-setup.log"

# ANSI color codes
readonly YELLOW='\033[1;33m'
readonly GREEN='\033[0;32m'
readonly NC='\033[0m'

# Logging function
log() {
    echo "$1" | tee -a "$LOG_FILE"
}

# Check if setup was already completed
if [ -f "$LOG_FILE" ] && grep -q "Setup completed successfully!" "$LOG_FILE"; then
    echo "Setup already completed. Exiting to avoid duplicate execution."
    echo "If you need to re-run setup, remove the log file: $LOG_FILE"
    exit 0
fi

#==============================================================================
# Step 1: Check if required containers are running
#==============================================================================
log "🔍 Checking required containers..."

for container in vllm open-webui caddy; do
    docker ps --format '{{.Names}}' | grep -q "$container" || { log "ERROR: Container '$container' is not running"; exit 1; }
done

#==============================================================================
# Step 2: Wait for Open-WebUI to be ready
#==============================================================================
log "⏳ Waiting for Open-WebUI to be ready..."

START_TIME=$(date +%s)
WEBUI_READY=false
while [ $(($(date +%s) - START_TIME)) -lt 120 ]; do
    [ "$(curl -s -o /dev/null -w '%{http_code}' http://localhost:8080/health || echo 000)" = "200" ] && { WEBUI_READY=true; break; }
    sleep 2
done
[ "$WEBUI_READY" = true ] || { log "ERROR: Timeout waiting for Open-WebUI health check"; exit 1; }

#==============================================================================
# Step 3: Wait for vLLM to download gpt-oss model
#==============================================================================
log "⏳ Waiting for vLLM to download gpt-oss model... (this may take 5 - 10 minutes)"

VLLM_START=$(date +%s)
while [ $(($(date +%s) - VLLM_START)) -lt 600 ]; do
    curl -s http://localhost:8000/v1/models | grep -q '"id":"openai/gpt-oss-20b"' && break
    sleep 5
done

log "Setup completed successfully!"

exit 0
