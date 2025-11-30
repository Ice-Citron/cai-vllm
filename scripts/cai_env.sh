#!/bin/bash
# =============================================================================
# CAI Environment Configuration for vLLM + Kimi Linear
# Source this file before running CAI: source cai_env.sh
#
# IMPORTANT: vLLM server must be running first! (./start_vllm_kimi.sh)
# =============================================================================

# IMPORTANT: Use "openai/" prefix, NOT "vllm/"
# "vllm/" makes LiteLLM spawn its own vLLM instance (causes trust_remote_code error)
# "openai/" makes LiteLLM connect to your running vLLM server via OpenAI-compatible API

# Point OpenAI SDK to your vLLM server
export OPENAI_API_BASE="http://localhost:8000/v1"
export OPENAI_API_KEY="sk-dummy-key-for-local-vllm"

# Also set VLLM_API_BASE for CAI's internal routing
export VLLM_API_BASE="http://localhost:8000/v1"

# Model name - must match --served-model-name in vLLM
# Using openai/ prefix tells CAI to use OpenAI-compatible API
export CAI_MODEL="openai/kimi-linear"

# Stop tokens to prevent response loops (Kimi uses ChatML format)
export VLLM_STOP_TOKENS="<|im_end|>,<|endoftext|>,<|im_start|>"

# Disable any proxy routing
unset ALIAS_API_KEY

echo "=============================================="
echo "  CAI Environment Configured for vLLM"
echo "=============================================="
echo "OPENAI_API_BASE: $OPENAI_API_BASE"
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
