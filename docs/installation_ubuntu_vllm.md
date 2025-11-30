# CAI + vLLM Installation Guide for Ubuntu

This guide shows how to install CAI with vLLM support on Ubuntu for local, high-performance inference.

## Prerequisites

- Ubuntu 20.04+ (22.04 or 24.04 recommended)
- NVIDIA GPU (H100, A100, RTX 4090, etc.)
- CUDA 11.8+ installed
- At least 40GB disk space
- Sufficient GPU memory for your chosen model

## Quick Install (Ubuntu 24.04)

```bash
# 1. System dependencies
sudo apt-get update && \
    sudo apt-get install -y git python3-pip python3.12-venv

# 2. Create virtual environment
python3.12 -m venv cai_env
source cai_env/bin/activate

# 3. Install CAI (from your fork with vLLM support)
pip install git+https://github.com/Ice-Citron/cai-vllm.git

# 4. Install vLLM
pip install vllm

# 5. Configure environment
cat > .env <<EOF
OPENAI_API_KEY="sk-1234"
ANTHROPIC_API_KEY=""
OLLAMA=""
VLLM_API_BASE="http://localhost:8000/v1"
CAI_MODEL="vllm/OpenPipe/Qwen3-14B-Instruct"
CAI_PRICE_LIMIT="0"
CAI_TRACING="false"
PROMPT_TOOLKIT_NO_CPR=1
CAI_STREAM=false
EOF

# 6. Done! Now start vLLM and CAI
```

## Detailed Installation

### Step 1: Install System Dependencies

#### Ubuntu 24.04
```bash
sudo apt-get update
sudo apt-get install -y \
    git \
    python3-pip \
    python3.12-venv \
    build-essential \
    curl
```

#### Ubuntu 22.04
```bash
sudo apt-get update
sudo apt-get install -y \
    git \
    python3-pip \
    python3.12-venv \
    build-essential \
    curl
```

#### Ubuntu 20.04
```bash
sudo apt-get update
sudo apt-get install -y software-properties-common

# Add Python 3.12 repository
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt update

sudo apt install -y \
    python3.12 \
    python3.12-venv \
    python3.12-dev \
    git \
    build-essential \
    curl
```

### Step 2: Verify NVIDIA GPU and CUDA

```bash
# Check GPU
nvidia-smi

# Check CUDA version (should be 11.8+)
nvcc --version

# If CUDA not installed, install it:
# See: https://developer.nvidia.com/cuda-downloads
```

### Step 3: Create Python Virtual Environment

```bash
# Create venv
python3.12 -m venv cai_env

# Activate it
source cai_env/bin/activate

# Verify Python version
python --version  # Should show Python 3.12.x
```

### Step 4: Install CAI with vLLM Support

```bash
# Option A: Install from your GitHub fork
pip install git+https://github.com/Ice-Citron/cai-vllm.git

# Option B: Clone and install locally
git clone https://github.com/Ice-Citron/cai-vllm.git
cd cai-vllm
pip install -e .
```

### Step 5: Install vLLM

```bash
# Install vLLM with CUDA support
pip install vllm

# Verify installation
python -c "import vllm; print(vllm.__version__)"
```

### Step 6: Configure Environment

```bash
# Create .env file
cat > .env <<'EOF'
# API Keys (sk-1234 is placeholder)
OPENAI_API_KEY="sk-1234"
ANTHROPIC_API_KEY=""
OLLAMA=""

# vLLM Configuration
VLLM_API_BASE="http://localhost:8000/v1"
CAI_MODEL="vllm/OpenPipe/Qwen3-14B-Instruct"

# CAI Settings
CAI_PRICE_LIMIT="0"           # Free local inference
CAI_TRACING="false"           # Disable OpenAI tracing
CAI_STREAM=false
PROMPT_TOOLKIT_NO_CPR=1

# Optional: Stop tokens to prevent response repetition (defaults work for most models)
# VLLM_STOP_TOKENS="<|im_start|>,<|im_end|>,<|endoftext|>"
EOF
```

**Important Notes:**
- CAI automatically manages conversation history to prevent context overflow
- Duplicate user messages are automatically removed to prevent infinite loops
- Conversation is truncated to 50 messages to stay within context limits
- Default stop tokens work for Qwen, Llama, Mistral, and most chat models

### Step 7: Start vLLM Server

```bash
# Basic startup
vllm serve OpenPipe/Qwen3-14B-Instruct \
    --host 0.0.0.0 \
    --port 8000 \
    --enable-auto-tool-choice \
    --tool-call-parser hermes

# For H100 (80GB VRAM)
vllm serve OpenPipe/Qwen3-14B-Instruct \
    --host 0.0.0.0 \
    --port 8000 \
    --enable-auto-tool-choice \
    --tool-call-parser hermes \
    --gpu-memory-utilization 0.9 \
    --max-model-len 32768

# For A100 (40GB VRAM)
vllm serve OpenPipe/Qwen3-14B-Instruct \
    --host 0.0.0.0 \
    --port 8000 \
    --enable-auto-tool-choice \
    --tool-call-parser hermes \
    --gpu-memory-utilization 0.7 \
    --max-model-len 16384

# For RTX 4090 (24GB VRAM)
vllm serve Qwen/Qwen2.5-7B-Instruct \
    --host 0.0.0.0 \
    --port 8000 \
    --enable-auto-tool-choice \
    --tool-call-parser hermes \
    --gpu-memory-utilization 0.6 \
    --max-model-len 8192
```

### Step 8: Launch CAI

In a new terminal:

```bash
# Activate environment
cd /path/to/your/project
source cai_env/bin/activate

# Launch CAI
cai
```

## Comparison: Standard vs. vLLM Setup

| Aspect | Standard CAI | CAI + vLLM |
|--------|-------------|------------|
| **Installation Time** | 5 min | 10 min |
| **Disk Space** | 500MB | 3-5GB (includes model) |
| **Dependencies** | Python only | Python + CUDA + vLLM |
| **Model Download** | On-demand (API) | One-time (local) |
| **Cost** | $0.50-$5/session | $0 (free) |
| **Latency** | Higher (API calls) | Lower (local) |
| **Privacy** | Data sent to API | 100% local |
| **Setup Complexity** | Easy | Medium |

## Key Differences from Standard Install

### 1. Additional Dependencies
```bash
# Standard CAI only needs:
pip install cai-framework

# vLLM setup needs:
pip install cai-framework vllm
```

### 2. Environment Variables
```bash
# Standard .env:
OPENAI_API_KEY="sk-your-key"
CAI_MODEL="gpt-4o"

# vLLM .env:
OPENAI_API_KEY="sk-1234"              # Placeholder only
VLLM_API_BASE="http://localhost:8000/v1"
CAI_MODEL="vllm/ModelName"
CAI_TRACING="false"                   # Must disable
```

### 3. Server Management
```bash
# Standard CAI: No server needed
cai

# vLLM: Need to start server first
# Terminal 1:
vllm serve model --host 0.0.0.0 --port 8000

# Terminal 2:
cai
```

## Running as a Service (Production Setup)

For production use, run vLLM as a systemd service:

```bash
# Create service file
sudo tee /etc/systemd/system/vllm.service > /dev/null <<EOF
[Unit]
Description=vLLM Inference Server
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$HOME
Environment="PATH=$HOME/cai_env/bin:/usr/local/bin:/usr/bin:/bin"
ExecStart=$HOME/cai_env/bin/vllm serve OpenPipe/Qwen3-14B-Instruct \\
    --host 0.0.0.0 \\
    --port 8000 \\
    --enable-auto-tool-choice \\
    --tool-call-parser hermes \\
    --gpu-memory-utilization 0.7
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Enable and start
sudo systemctl daemon-reload
sudo systemctl enable vllm
sudo systemctl start vllm

# Check status
sudo systemctl status vllm

# View logs
sudo journalctl -u vllm -f
```

## Troubleshooting

### GPU Not Detected
```bash
# Install NVIDIA drivers
sudo apt-get install -y nvidia-driver-535

# Reboot
sudo reboot

# Verify
nvidia-smi
```

### CUDA Issues
```bash
# Check CUDA version
nvcc --version

# Install CUDA 12.1 (example)
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb
sudo apt-get update
sudo apt-get install -y cuda-toolkit-12-1
```

### vLLM Installation Fails
```bash
# Install with CUDA 11.8
pip install vllm --extra-index-url https://download.pytorch.org/whl/cu118

# Or CUDA 12.1
pip install vllm --extra-index-url https://download.pytorch.org/whl/cu121
```

### Out of Memory
```bash
# Reduce GPU memory utilization
vllm serve model --gpu-memory-utilization 0.5

# Or use a smaller model
vllm serve Qwen/Qwen2.5-7B-Instruct
```

### Connection Refused
```bash
# Check vLLM is running
curl http://localhost:8000/v1/models

# Check firewall
sudo ufw allow 8000

# Check the process
ps aux | grep vllm
```

### Context Window Exceeded Error
```
ContextWindowExceededError: This model's maximum context length is 40960 tokens.
However, your request has 41906 input tokens.
```

**Solution**: CAI automatically truncates conversation history to 50 messages and removes duplicate messages. If you still hit this error:

1. Restart CAI to clear the conversation history
2. Reduce vLLM's max context length:
   ```bash
   vllm serve model --max-model-len 16384
   ```
3. The error will no longer occur as CAI now manages history automatically

### Repetitive Tool Calls (Model Stuck in Loop)

**Symptoms**: Agent keeps making the same curl/tool calls repeatedly without progressing

**Causes**:
1. Conversation history growing unbounded
2. Model generating repetitive responses
3. Duplicate user messages in history

**Solutions** (all implemented automatically in CAI now):
- ✅ Message deduplication (removes duplicate consecutive user messages)
- ✅ Conversation truncation (limits to 50 messages)
- ✅ Stop tokens (prevents response repetition)

If issues persist after updating to latest cai-vllm:
```bash
# Pull latest changes
cd /path/to/cai-vllm
git pull

# Restart CAI (no reinstall needed with editable install)
cai
```

## Performance Optimization

### 1. Use Quantized Models
```bash
# 4-bit AWQ quantization (smaller, faster)
vllm serve Qwen/Qwen2.5-14B-Instruct-AWQ-INT4
```

### 2. Enable Prefix Caching
```bash
vllm serve model --enable-prefix-caching
```

### 3. Adjust Batch Size
```bash
# For high throughput
vllm serve model --max-num-seqs 512

# For low latency
vllm serve model --max-num-seqs 64
```

### 4. Multi-GPU Setup
```bash
# Use 2 GPUs
vllm serve model --tensor-parallel-size 2
```

## Monitoring

```bash
# GPU utilization
watch -n 1 nvidia-smi

# vLLM metrics
curl http://localhost:8000/metrics

# System resources
htop
```

## Next Steps

1. ✅ vLLM server running
2. ✅ CAI configured
3. 🚀 Start testing: `cai`

## Recommended Models by GPU

| GPU | VRAM | Recommended Model | Context |
|-----|------|-------------------|---------|
| H100 | 80GB | Qwen2.5-32B-Instruct | 32K |
| A100 | 80GB | Qwen2.5-32B-Instruct | 32K |
| A100 | 40GB | Qwen3-14B-Instruct | 16K |
| RTX 4090 | 24GB | Qwen2.5-7B-Instruct | 16K |
| RTX 3090 | 24GB | Qwen2.5-7B-Instruct | 8K |

## Additional Resources

- [vLLM Documentation](https://docs.vllm.ai/)
- [CAI Documentation](https://aliasrobotics.github.io/cai/)
- [Qwen Models](https://huggingface.co/Qwen)
- [CUDA Installation](https://developer.nvidia.com/cuda-downloads)
