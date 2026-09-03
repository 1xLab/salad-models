#!/bin/bash
set -e

mkdir -p /models
MODEL_FILE="/models/model.gguf"

if [ ! -s "$MODEL_FILE" ]; then
    echo "=== Downloading Qwen 3.6 35B from GitHub Releases (1xLab/salad-models) ==="
    TMP_DIR="/tmp/qwen_parts"
    mkdir -p "$TMP_DIR"
    cd "$TMP_DIR"

    BASE_URL="https://github.com/1xLab/salad-models/releases/download/v1.0-qwen"
    
    # Download all parts
    for i in 00 01 02 03 04 05 06 07 08 09 10 11; do
        PART_URL="$BASE_URL/qwen.part.$i"
        echo "Downloading $PART_URL..."
        if curl -L --fail -C - -o "qwen.part.$i" "$PART_URL"; then
            echo "Part $i downloaded."
        else
            rm -f "qwen.part.$i"
            break
        fi
    done

    echo "Assembling model..."
    cat qwen.part.* > "$MODEL_FILE"
    rm -rf "$TMP_DIR"
    echo "Model ready: $(ls -lh "$MODEL_FILE")"
fi

echo "Starting llama-server on port 8080..."
exec /app/llama-server --temp "${LLAMA_SERVER_TEMP:-0.7}" --top-p "${LLAMA_SERVER_TOP_P:-0.80}" --min-p "${LLAMA_SERVER_MIN_P:-0.0}" "$@"
