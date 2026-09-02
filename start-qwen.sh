#!/bin/bash
set -e

mkdir -p /models
MODEL_FILE="/models/model.gguf"

if [ ! -s "$MODEL_FILE" ]; then
    echo "Downloading Qwen 3.6 35B-A3B GGUF..."
    curl -L -C - --fail \
        ${HF_TOKEN:+-H "Authorization: Bearer ${HF_TOKEN}"} \
        -o "$MODEL_FILE" \
        "${MODEL_URL:-https://huggingface.co/unsloth/Qwen3.6-35B-A3B-GGUF/resolve/main/Qwen3.6-35B-A3B-UD-Q4_K_XL.gguf}"
    echo "Download complete."
fi

echo "Starting llama-server..."
exec /app/llama-server --temp "${LLAMA_SERVER_TEMP:-0.7}" --top-p "${LLAMA_SERVER_TOP_P:-0.80}" --min-p "${LLAMA_SERVER_MIN_P:-0.0}" "$@"
