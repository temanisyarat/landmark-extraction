#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT_DIR"

venv="$1"

"$venv"/bin/python analyze.py

echo "Analysis complete."
