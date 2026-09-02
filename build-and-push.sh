#!/bin/bash
set -ex

echo "$(gh auth token)" | docker login ghcr.io -u 1xlab --password-stdin

echo "=== Building Nemotron ==="
docker buildx build \
  --file ./Dockerfile.nemotron \
  --build-arg HF_TOKEN="${HF_TOKEN}" \
  --tag ghcr.io/1xlab/nemotron3-nano-30b-a3b:latest \
  --push \
  --provenance false \
  .

docker builder prune -af 2>/dev/null || true

echo "=== Building Qwen ==="
docker buildx build \
  --file ./Dockerfile.qwen \
  --build-arg HF_TOKEN="${HF_TOKEN}" \
  --tag ghcr.io/1xlab/qwen36-35b-a3b:latest \
  --push \
  --provenance false \
  .

echo "=== DONE ==="
