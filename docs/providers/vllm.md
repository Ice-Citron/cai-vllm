# vLLM Configuration

#### [vLLM Integration](https://docs.vllm.ai/)

For local models using vLLM, add the following to your .env:

```bash
CAI_MODEL=vllm/OpenPipe/Qwen3-14B-Instruct
VLLM_API_BASE=http://localhost:8000/v1 # note, maybe you have a different endpoint
```

Make sure that the vLLM server is running and accessible at the specified base URL.

## Starting vLLM Server

```bash
vllm serve OpenPipe/Qwen3-14B-Instruct \
    --host 0.0.0.0 \
    --port 8000 \
    --enable-auto-tool-choice \
    --tool-call-parser hermes \
    --gpu-memory-utilization 0.7
```

## Configuration Options

### Environment Variables

- `VLLM_API_BASE`: Base URL for your vLLM server (default: `http://localhost:8000/v1`)
- `CAI_MODEL`: Model identifier with `vllm/` or `openai/` prefix
- `VLLM_STOP_TOKENS`: Comma-separated list of stop tokens to prevent response repetition (optional)
  - Default: `<|im_start|>,<|im_end|>,<|endoftext|>`
  - Override example: `VLLM_STOP_TOKENS="<|eot_id|>,<|end_of_text|>"`

### Example Configuration

```bash
# .env file
OPENAI_API_KEY="sk-1234"           # Placeholder (required but not used)
VLLM_API_BASE="http://localhost:8000/v1"
CAI_MODEL="vllm/OpenPipe/Qwen3-14B-Instruct"
CAI_PRICE_LIMIT="0"                # No cost for local models
CAI_TRACING="false"                # Disable OpenAI tracing
CAI_STREAM=false
PROMPT_TOOLKIT_NO_CPR=1

# Optional: Custom stop tokens for specific models
# VLLM_STOP_TOKENS="<|im_start|>,<|im_end|>,<|endoftext|>"
```

### Preventing Repetitive Tool Calls

CAI automatically manages conversation history to prevent context overflow and repetitive behavior:

1. **Automatic Message Deduplication**: Duplicate consecutive user messages are removed to prevent loops
2. **Conversation Truncation**: History is limited to 50 messages (keeping system prompt + recent context)
3. **Stop Tokens**: Default stop tokens prevent the model from generating repetitive responses

If you still experience repetitive tool calls:
- Reduce max context length: `--max-model-len 16384` (when starting vLLM)
- Disable prefix caching: `--no-enable-prefix-caching`
- Try different stop tokens via `VLLM_STOP_TOKENS` environment variable

## Supported Models

vLLM supports any HuggingFace model that implements the transformers interface. Popular choices include:

- Qwen3-14B-Instruct
- Qwen2.5-32B-Instruct
- Llama 3 variants
- Mistral variants
- And many more...

## GPU Memory Configuration

Adjust GPU memory usage based on your hardware:

```bash
# For H100 (80GB)
vllm serve model --gpu-memory-utilization 0.9

# For A100 (40GB)
vllm serve model --gpu-memory-utilization 0.7

# For RTX 4090 (24GB)
vllm serve model --gpu-memory-utilization 0.6
```

## Tool Calling Support

CAI requires tool calling support for cybersecurity operations. Enable it with:

```bash
vllm serve model \
    --enable-auto-tool-choice \
    --tool-call-parser hermes
```

## Troubleshooting

### Connection Issues

If CAI can't connect to vLLM:

```bash
# Test the endpoint
curl http://localhost:8000/v1/models

# Check vLLM is running
ps aux | grep vllm
```

### Out of Memory

If you get OOM errors:

1. Reduce `--gpu-memory-utilization` to 0.6 or lower
2. Reduce `--max-model-len` to 4096 or 8192
3. Use a quantized model variant (e.g., AWQ, GPTQ)

### Tool Calling Not Working

Ensure you've started vLLM with:
- `--enable-auto-tool-choice`
- `--tool-call-parser hermes`

## Performance Tips

1. **Use Flash Attention**: vLLM automatically uses FlashAttention on supported GPUs (H100, A100)
2. **Adjust batch size**: Use `--max-num-seqs` to control concurrent requests
3. **Enable prefix caching**: Speeds up repeated queries with `--enable-prefix-caching`
4. **Use tensor parallelism**: For multi-GPU setups, use `--tensor-parallel-size N`

## Example: Running Qwen3-14B on H100

```bash
# Start vLLM server
vllm serve OpenPipe/Qwen3-14B-Instruct \
    --host 0.0.0.0 \
    --port 8000 \
    --enable-auto-tool-choice \
    --tool-call-parser hermes \
    --gpu-memory-utilization 0.8 \
    --max-model-len 16384 \
    --max-num-seqs 256

# Configure CAI
export VLLM_API_BASE="http://localhost:8000/v1"
export CAI_MODEL="vllm/OpenPipe/Qwen3-14B-Instruct"
export CAI_TRACING="false"

# Run CAI
cai
```

## Comparison with Ollama

| Feature | vLLM | Ollama |
|---------|------|--------|
| Setup Complexity | Medium | Easy |
| Performance | Highest | Good |
| GPU Utilization | Optimal | Good |
| Model Selection | Any HF model | Curated models |
| Tool Calling | Manual setup | Automatic |
| Production Ready | Yes | Yes |

Choose vLLM for:
- Maximum performance on high-end GPUs
- Custom/fine-tuned models
- Production deployments
- Research and experimentation

Choose Ollama for:
- Quick setup
- Simple model management
- Local development
- Ease of use
