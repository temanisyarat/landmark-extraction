#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

venv="$1"
export ROOT_DIR venv

"$ROOT_DIR/$venv/bin/python" "$ROOT_DIR/src/analyze.py"

echo "Analysis complete."
