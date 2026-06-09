#!/bin/bash

shopt -s nullglob
# Modify based on signer folders

reformat_one() {
  local video="$1"
  local dir signer label basename outdir

  dir=$(dirname "$video")
  label=$(basename "$dir")
  dir=$(dirname "$dir")
  signer=$(basename "$dir")
  basename=$(basename "$video" .mp4)
  outdir="./reformated/$signer/$label"

  mkdir -p "$outdir"

  ffmpeg -y -i "$video" \
    -c:v libx264 \
    "$outdir/${basename}_reformated.mp4" </dev/null

}
export -f reformat_one

find ./landmarked -name '*.mp4' -type f -print0 |
  parallel -0 -j "$(nproc)" --bar reformat_one {}

echo "Reformat selesai."
