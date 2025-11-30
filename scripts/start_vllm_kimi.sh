#!/bin/bash
# =============================================================================
# vLLM Server Startup Script for Kimi-Linear-48B-A3B-Instruct
# For use with CAI (Cybersecurity AI) on NVIDIA B200 180GB
#
# Tool calling: Uses kimi_k2 parser (confirmed compatible with Kimi Linear)
# Reference: https://huggingface.co/moonshotai/Kimi-Linear-48B-A3B-Instruct/discussions/8
# =============================================================================

set -e

# Configuration
MODEL_NAME="moonshotai/Kimi-Linear-48B-A3B-Instruct"
SERVED_MODEL_NAME="kimi-linear"  # Friendly name for API calls
PORT=8000
MAX_MODEL_LEN=32768    # 32K context (can go up to 1M, but uses more memory)
TENSOR_PARALLEL=1      # Single GPU for B200 180GB
GPU_MEMORY_UTIL=0.85   # Use 85% of GPU memory

echo "=============================================="
echo "  vLLM Server for Kimi-Linear-48B"
echo "=============================================="
echo "Model: $MODEL_NAME"
echo "Served as: $SERVED_MODEL_NAME"
echo "Port: $PORT"
echo "Max Context: $MAX_MODEL_LEN tokens"
echo "Tensor Parallel: $TENSOR_PARALLEL"
echo "GPU Memory Utilization: $GPU_MEMORY_UTIL"
echo "Tool Parser: kimi_k2"
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
echo "API endpoint: http://localhost:$PORT/v1"
echo "Health check: http://localhost:$PORT/health"
echo ""

vllm serve "$MODEL_NAME" \
    --served-model-name "$SERVED_MODEL_NAME" \
    --port $PORT \
    --tensor-parallel-size $TENSOR_PARALLEL \
    --max-model-len $MAX_MODEL_LEN \
    --gpu-memory-utilization $GPU_MEMORY_UTIL \
    --trust-remote-code \
    --enable-auto-tool-choice \
    --tool-call-parser kimi_k2 \
    --disable-log-requests
