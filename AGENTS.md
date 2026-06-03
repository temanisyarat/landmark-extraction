# AGENTS.md — LM (Landmark Extraction)

## What This Repo Does

MediaPipe landmark extraction pipeline for **BISINDO (Indonesian Sign Language)** recognition. Processes raw sign language MP4s → extracts upper-body pose + hand landmarks → saves as `.npz` arrays for downstream DL classification.

## Pipeline

```
videoset/ → augmentation.sh → augmented/ → extract.sh → data/ + landmarked/
(raw MP4s)   (ffmpeg variants)   (10× videos)   (MediaPipe)  (.npz + annotated MP4s)
```

## Directory Layout

| Path | Purpose |
|------|---------|
| `videoset/{signer}/{word}/` | Raw input videos |
| `augmented/{signer}/{word}/` | 10 variants per video (orig + 9 aug) |
| `data/{signer}/{word}/` | Extracted landmarks as `.npz` files |
| `landmarked/{signer}/{word}/` | Output videos with landmarks drawn |
| `reformated/` | Re-encoded landmark videos (libx264) |
| `tasks/` | MediaPipe `.task` model files |
| `analysis/` | Analytics report + visualizations |
| `archive/batch1/` | Snapshot of a previous pipeline run |

## Key Files

| File | Purpose |
|------|---------|
| `main.py` | CLI entry point (`python main.py single|batch`) |
| `extractor.py` | Core `LandmarkExtractor` class (MediaPipe Tasks API) |
| `augmentation.sh` | ffmpeg-based augmentation (speed, flip, shift) |
| `extract.sh` | Batch extraction orchestration per signer |
| `analyze.py` | Dataset analytics → `analysis/REPORT.md` |
| `reformat.sh` | Re-encode to libx264 for compatibility |

## Extracted Landmarks

- **Pose**: 9 upper-body keypoints → `[T, 9, 4]` (x, y, z, visibility) — nose, shoulders, elbows, wrists, hips
- **Hands**: 21 landmarks per hand → `[T, 2, 21, 3]` (x, y, z)

Indices defined in `extractor.py` as `POSE_UPPER_IDX = [0, 11, 12, 13, 14, 15, 16, 23, 24]`.

## Signers & Words

- **6 signers**: willi, farras, ivan, ian, fredi, kevin
- **20 word classes**: aku, apel, ayah, besok, buku, dia, dua, hari ini, ibu, kamu, kuning, maaf, merah, nama, pisang, salam, satu, teman, terima kasih, tiga
- **10 variants**: orig, slow, fast, hflip, shift_left, shift_right, hflip_slow, hflip_fast, hflip_shift_left, hflip_shift_right

## Code Conventions

- **Python 3.10+**, type-annotated with `from __future__ import annotations`
- `numpy` for array data, `opencv-python` for video I/O, `mediapipe` for landmark extraction
- Config via `@dataclass` (`ExtractorConfig`), result via `@dataclass` (`ExtractionResult`)
- Logging uses `logging.getLogger(__name__)` with `INFO` level
- NaN padding for missing landmarks
- `Makefile` drives the pipeline: `make all` → venv → augment → extract → analyze

## TFRecord Conversion

The README references `concat.py` (not in repo) for converting `.npz` → TFRecord. Sequences padded/truncated to 100 frames, 261-dim feature vector per frame.
