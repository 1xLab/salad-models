#!/bin/bash
set -Eeuo pipefail

MODEL_DIR="${MODEL_DIR:-/models}"
MODEL_FILE="$MODEL_DIR/model.gguf"
TARGET_FILE="$MODEL_DIR/NVIDIA-Nemotron-3-Nano-30B-A3B-Q4_K_M.gguf"

mkdir -p "$MODEL_DIR"

if [[ ! -s "$MODEL_FILE" ]]; then
    echo "=== Downloading Nemotron GGUF from Backblaze B2 via rclone (8 parallel streams) ==="
    RCLONE_CONFIG_B2_TYPE=s3 \
    RCLONE_CONFIG_B2_PROVIDER=Other \
    RCLONE_CONFIG_B2_ACCESS_KEY_ID="${S3_ACCESS_KEY_ID:-0051347d3d9aae20000000005}" \
    RCLONE_CONFIG_B2_SECRET_ACCESS_KEY="${S3_SECRET_ACCESS_KEY:-K005WveF9EFGsY90eVJblneG2Kc+WhE}" \
    RCLONE_CONFIG_B2_ENDPOINT="${S3_ENDPOINT_URL:-https://s3.us-east-005.backblazeb2.com}" \
    rclone copy "b2:${S3_BUCKET:-devopsprojects}/models/NVIDIA-Nemotron-3-Nano-30B-A3B-Q4_K_M.gguf" "$MODEL_DIR/" \
        --progress --transfers 8 --multi-thread-streams 8 --s3-chunk-size 64M

    if [[ -f "$TARGET_FILE" ]]; then
        mv "$TARGET_FILE" "$MODEL_FILE"
    fi
    echo "=== Download complete: $(ls -lh "$MODEL_FILE") ==="
fi

echo "=== Starting llama-server on port ${PORT:-8080} ==="
exec /app/llama-server --temp "${LLAMA_SERVER_TEMP:-0.7}" --top-p "${LLAMA_SERVER_TOP_P:-0.80}" --min-p "${LLAMA_SERVER_MIN_P:-0.0}" "$@"
