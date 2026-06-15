#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

venv="$1"
export ROOT_DIR venv

extract_one_label() {
  local dir="$1"
  local signer label

  signer=$(basename "$(dirname "$dir")")
  label=$(basename "$dir")

  mkdir -p "$ROOT_DIR/data/$signer/$label" \
    "$ROOT_DIR/landmarked/$signer/$label"

  "$ROOT_DIR/$venv/bin/python" "$ROOT_DIR/main.py" batch \
    "$ROOT_DIR/augmented/$signer/$label" \
    --out-npy-dir "$ROOT_DIR/data/$signer/$label" \
    --out-video-dir "$ROOT_DIR/landmarked/$signer/$label"
}
export -f extract_one_label

find augmented -mindepth 2 -maxdepth 2 -type d -print0 |
  parallel -0 -j "$(nproc)" --bar extract_one_label {}

echo "All signer subdirectories processed."
