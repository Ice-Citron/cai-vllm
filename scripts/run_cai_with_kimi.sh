#!/bin/bash
# =============================================================================
# All-in-One Script: Start vLLM + Run CAI with Kimi-Linear-48B
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=============================================="
echo "  CAI + Kimi-Linear-48B Setup"
echo "=============================================="

# Check if vLLM server is already running
if curl -s http://localhost:8000/health > /dev/null 2>&1; then
    echo "vLLM server already running on port 8000"
else
    echo "Starting vLLM server in background..."
    nohup "$SCRIPT_DIR/start_vllm_kimi.sh" > /tmp/vllm_kimi.log 2>&1 &
    VLLM_PID=$!
    echo "vLLM PID: $VLLM_PID"
    echo "Log: /tmp/vllm_kimi.log"

    # Wait for server to be ready
    echo "Waiting for vLLM server to start..."
    for i in {1..60}; do
        if curl -s http://localhost:8000/health > /dev/null 2>&1; then
            echo "vLLM server is ready!"
            break
        fi
        if [ $i -eq 60 ]; then
            echo "ERROR: vLLM server failed to start. Check /tmp/vllm_kimi.log"
            exit 1
        fi
        sleep 5
        echo "  Waiting... ($i/60)"
    done
fi

# Source environment
source "$SCRIPT_DIR/cai_env.sh"

# Run CAI
echo ""
echo "Starting CAI..."
cai "$@"
