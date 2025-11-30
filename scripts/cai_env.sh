#!/bin/bash
# =============================================================================
# CAI Environment Configuration for vLLM + Kimi
# Source this file before running CAI: source cai_env.sh
# =============================================================================

# vLLM Server Configuration
export VLLM_API_BASE="http://localhost:8000/v1"

# Model Configuration - use vllm/ prefix so CAI routes to local vLLM
export CAI_MODEL="vllm/moonshotai/Kimi-Linear-48B-A3B-Instruct"

# Stop tokens to prevent response loops (Kimi uses ChatML format)
export VLLM_STOP_TOKENS="<|im_end|>,<|endoftext|>,<|im_start|>"

# Disable the default API routing (prevents auth errors)
unset ALIAS_API_KEY

# Optional: Set a dummy API key (vLLM doesn't check it but LiteLLM needs something)
export OPENAI_API_KEY="sk-dummy-key-for-local-vllm"

echo "=============================================="
echo "  CAI Environment Configured for vLLM"
echo "=============================================="
echo "VLLM_API_BASE: $VLLM_API_BASE"
echo "CAI_MODEL: $CAI_MODEL"
echo "VLLM_STOP_TOKENS: $VLLM_STOP_TOKENS"
echo "=============================================="
echo ""
echo "Make sure vLLM server is running first!"
echo "  ./start_vllm_kimi.sh"
echo ""
echo "Then run CAI:"
echo "  cai"
echo "=============================================="
