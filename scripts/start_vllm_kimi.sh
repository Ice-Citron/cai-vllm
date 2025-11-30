#!/bin/bash
# =============================================================================
# vLLM Server Startup Script for Kimi-Linear-48B-A3B-Instruct
# For use with CAI (Cybersecurity AI) on NVIDIA B200 180GB
# =============================================================================

set -e

# Configuration
MODEL_NAME="moonshotai/Kimi-Linear-48B-A3B-Instruct"
PORT=8000
MAX_MODEL_LEN=32768  # 32K context, increase if needed (up to 1M supported)
TENSOR_PARALLEL=1    # Single GPU for B200 180GB (plenty of VRAM)
GPU_MEMORY_UTIL=0.85 # Use 85% of GPU memory

echo "=============================================="
echo "  vLLM Server for Kimi-Linear-48B"
echo "=============================================="
echo "Model: $MODEL_NAME"
echo "Port: $PORT"
echo "Max Context: $MAX_MODEL_LEN tokens"
echo "GPU Memory Utilization: $GPU_MEMORY_UTIL"
echo "=============================================="

# Check if vLLM is installed
if ! command -v vllm &> /dev/null; then
    echo "ERROR: vLLM not found. Install with:"
    echo "  pip install vllm"
    exit 1
fi

# Start vLLM server
echo ""
echo "Starting vLLM server..."
echo "Access at: http://localhost:$PORT/v1"
echo ""

vllm serve "$MODEL_NAME" \
    --port $PORT \
    --tensor-parallel-size $TENSOR_PARALLEL \
    --max-model-len $MAX_MODEL_LEN \
    --gpu-memory-utilization $GPU_MEMORY_UTIL \
    --trust-remote-code \
    --tool-call-parser kimi_k2 \
    --enable-auto-tool-choice \
    --disable-log-requests
