# lm-extraction

**MediaPipe Holistic Landmark Extraction Pipeline for BISINDO (Bahasa Isyarat Indonesia) Sign Language Recognition**

This pipeline processes raw sign language video recordings — extracting pose and hand landmarks using [MediaPipe Tasks API](https://developers.google.com/mediapipe/solutions/vision/pose_landmarker) for downstream deep learning classification. Designed for the **BISINDO** (Indonesian Sign Language) dataset with multi-signer, multi-word video recordings.

## Overview

```
videoset/  ──►  augmentation.sh  ──►  augmented/  ──►  extract.sh  ──►  data/  +  landmarked/
(raw MP4s)      (ffmpeg variants)     (10× videos)     (MediaPipe)      (.npz landmarks)
                                                                        (annotated MP4s)
```

The pipeline supports **9 signers**, **20 word classes**, and **10 augmentation variants** per source video (1 original + 9 augmented), yielding ~1,800 total samples.

## Directory Layout

| Path          | Purpose                                         |
| ------------- | ----------------------------------------------- |
| `videoset/`   | Raw input videos: `{signer}/{word}/{word}.mp4`  |
| `augmented/`  | ffmpeg-augmented video variants                 |
| `data/`       | Extracted landmarks as compressed `.npz` arrays |
| `landmarked/` | Output videos with landmarks drawn on frames    |
| `reformated/` | Re-encoded landmark videos (libx264)            |
| `tasks/`      | MediaPipe model files (`.task`)                 |
| `analysis/`   | Dataset analytics report and visualizations     |

## Requirements

- **Python** ≥ 3.10
- **ffmpeg** (required for augmentation scripts)
- Python packages: `opencv-python`, `mediapipe`, `numpy`

## Installation

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

Or via the included Makefile:

```bash
make venv
```

## Usage

### Full Pipeline

```bash
make all
```

This runs: `venv → augmentation.sh → extract.sh`

### Step by Step

**1. Data Augmentation** — generates 9 ffmpeg-based variants per video:

```bash
./augmentation.sh
```

Variants: `slow`, `fast`, `hflip`, `shift_left`, `shift_right`, `hflip_slow`, `hflip_fast`, `hflip_shift_left`, `hflip_shift_right` (plus `orig` copy).

**2. Landmark Extraction** — runs MediaPipe PoseLandmarker + HandLandmarker:

```bash
./extract.sh .venv
```

**3. Re-encode Output Videos** (optional, for compatibility):

```bash
./reformat.sh
```

### Manual Landmark Extraction

```bash
# Single video
python main.py single input.mp4 --out-video output.mp4 --out-npy output.npz

# Batch folder
python main.py batch videos/ --recursive --out-npy-dir data/
```

### Additional Options

```bash
# Dataset analysis and visualization
python analyze.py

# Convert .npz to TensorFlow TFRecord
python concat.py batch data/ --out tfrecords/
```

## Extracted Landmarks

- **Pose** (9 upper-body keypoints): nose, shoulders, elbows, wrists, hips — shape `[T, 9, 4]` (x, y, z, visibility)
- **Hands** (21 landmarks per hand): 2 hands — shape `[T, 2, 21, 3]` (x, y, z)

Selected from MediaPipe's 33 full-body pose landmarks, retaining only the upper body keypoints relevant for sign language.

## MediaPipe Models

Place model files in `tasks/`:

- `pose_landmarker_heavy.task` — Heavy (most accurate) pose model
- `hand_landmarker.task` — Hand landmark model
- `face_landmarker.task` — Face landmark model (available but not extracted by default)

## Dataset Statistics

| Metric | Value |
|--------|-------|
| Signers | 8 |
| Word classes | 20 |
| Total samples | 1,600 (160 original + 1,440 augmented) |
| Average frames/video | 71.3 (range: 38–125) |
| Pose NaN rate | 0.05% |
| Hand NaN rate | 30.46% (H0: 14.86%, H1: 46.06%) |

See `analysis/REPORT.md` for the full analytics report.

## TFRecord Conversion

The `concat.py` script converts `.npz` landmarks into TensorFlow TFRecord format for model training:

```bash
python concat.py single data/signer/word/word_orig.npz --out tfrecords/
python concat.py batch data/ --out tfrecords/
```

Sequences are padded/truncated to 100 frames, producing a 261-dimensional feature vector per frame.

## Project Structure

| File              | Purpose                                              |
| ----------------- | ---------------------------------------------------- |
| `main.py`         | CLI entry point for landmark extraction              |
| `extractor.py`    | Core `LandmarkExtractor` class (MediaPipe Tasks API) |
| `augmentation.sh` | ffmpeg-based video augmentation                      |
| `extract.sh`      | Batch extraction orchestration                       |
| `reformat.sh`     | Video re-encoding with libx264                       |
| `analyze.py`      | Dataset analytics and visualization                  |
| `Makefile`        | Pipeline automation                                  |

## License

This project is provided for research and educational purposes.
