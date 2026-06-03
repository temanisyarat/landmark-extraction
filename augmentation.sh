#!/bin/bash

shopt -s nullglob

augment_one() {
  local video="$1"
  local dir signer label basename outdir

  dir=$(dirname "$video")
  label=$(basename "$dir")
  dir=$(dirname "$dir")
  signer=$(basename "$dir")
  basename=$(basename "$video" .mp4)
  outdir="./augmented/$signer/$label"

  mkdir -p "$outdir"

  cp "$video" "$outdir/${basename}_orig.mp4"

  ffmpeg -y -i "$video" \
    -vf "setpts=1.2*PTS" -an \
    "$outdir/${basename}_slow.mp4" < /dev/null

  ffmpeg -y -i "$video" \
    -vf "setpts=0.8*PTS" -an \
    "$outdir/${basename}_fast.mp4" < /dev/null

  ffmpeg -y -i "$video" \
    -vf "pad='2*round(iw*1.1/2)':ih:0:0,crop=iw:ih:'2*round(iw*1.1/2)-iw':0" -an \
    "$outdir/${basename}_shift_left.mp4" < /dev/null

  ffmpeg -y -i "$video" \
    -vf "pad='2*round(iw*1.1/2)':ih:'2*round(iw*1.1/2)-iw':0,crop=iw:ih:0:0" -an \
    "$outdir/${basename}_shift_right.mp4" < /dev/null

  ffmpeg -y -i "$video" \
    -vf "hflip" -an \
    "$outdir/${basename}_hflip.mp4" < /dev/null

  ffmpeg -y -i "$video" \
    -vf "hflip,setpts=1.2*PTS" -an \
    "$outdir/${basename}_hflip_slow.mp4" < /dev/null

  ffmpeg -y -i "$video" \
    -vf "hflip,setpts=0.8*PTS" -an \
    "$outdir/${basename}_hflip_fast.mp4" < /dev/null

  ffmpeg -y -i "$video" \
    -vf "hflip,pad='2*round(iw*1.1/2)':ih:0:0,crop=iw:ih:'2*round(iw*1.1/2)-iw':0" -an \
    "$outdir/${basename}_hflip_shift_left.mp4" < /dev/null

  ffmpeg -y -i "$video" \
    -vf "hflip,pad='2*round(iw*1.1/2)':ih:'2*round(iw*1.1/2)-iw':0,crop=iw:ih:0:0" -an \
    "$outdir/${basename}_hflip_shift_right.mp4" < /dev/null
}
export -f augment_one

find ./videoset -name '*.mp4' -type f -print0 \
  | parallel -0 -j "$(nproc)" --bar augment_one {}

echo "Augmentasi selesai."
