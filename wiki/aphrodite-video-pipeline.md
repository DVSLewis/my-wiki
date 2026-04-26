# Aphrodite Video Pipeline

> Built by Hephaestus on 2026-04-26 for the DVS Pantheon
> Status: Active

---

## Overview

Aphrodite manages the creative video pipeline for DVS — producing TikTok-style short-form videos and branded carousel posts. Two bash scripts handle the heavy lifting: one for video editing (FFmpeg) and one for image generation (ImageMagick).

---

## 1. tiktok-editor.sh

**Purpose:** Trim, resize, and caption a video for TikTok/Reels vertical format.

**Location:** `aphrodite-training/bin/tiktok-editor.sh`

### Requirements
- `ffmpeg` + `ffprobe` (libx264, libass, AAC)
- `bc` for floating-point arithmetic

### Usage
```bash
./tiktok-editor.sh <input.mp4> [output.mp4]
```

### What it does
1. **Probe** input duration and dimensions
2. **Trim** to 20–30s window (skips intro if > 30s, centers clip otherwise)
3. **Scale + pad** to 1080×1920 vertical with black bars
4. **Hardcode SRT captions** (auto-generated placeholder segments, 5s each)
5. **Export** as H.264 MP4 with AAC audio + faststart for streaming

### Output
- Format: MP4 (H.264 / AAC)
- Resolution: 1080×1920
- Duration: 20–30s
- Codec: libx264 CRF 23, AAC 128kbps

### Customizing Captions
Edit the `YOUR CAPTION HERE` placeholder in the generated `captions.srt` temp file, or replace the subtitle step entirely with your own SRT file:
```bash
ffmpeg -y -i input.mp4 -ss 5 -t 25 \
  -vf "scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:(ow-iw)/2:(oh-ih)/2:color=black,subtitles=my_captions.srt" \
  -c:v libx264 -preset fast -crf 23 \
  -c:a aac -b:a 128k \
  -movflags +faststart \
  output.mp4
```

---

## 2. carousel-maker.sh

**Purpose:** Generate branded 1080×1080 carousel slides with gradient backgrounds and text overlays.

**Location:** `aphrodite-training/bin/carousel-maker.sh`

### Requirements
- `ImageMagick` (convert, composite)

### Usage
```bash
./carousel-maker.sh <text> <output.png> [--gradient <name>] [--font <size>]
```

### Gradient Presets
| Name | Colors |
|------|--------|
| `violet-indigo` | Purple → Indigo → Dark Indigo |
| `blue-cyan` | Blue → Cyan → Dark Cyan |
| `emerald-teal` | Emerald → Teal → Dark Teal |
| `sunset` | Orange → Pink → Dark Rose |
| `ocean` | Navy → Blue → Cyan |
| `rose-gold` | Rose → Amber → Gold |

### What it does
1. **Gradient background** — plasma blend with blur for smooth gradients
2. **Vignette layer** — radial darkening for depth
3. **Text rendering** — Helvetica Bold, word-wrapped at 28 chars
4. **Shadow pass** — offset black shadow for readability
5. **Branded border** — 4px solid border in gradient's primary color

### Example
```bash
./carousel-maker.sh "Welcome to DVS" dvs-slide.png --gradient ocean --font 90
```

---

## Integration

### Workflow: Video → Carousel
```
1. Record or source raw footage
2. Trim with tiktok-editor.sh  →  <brand>_tiktok.mp4
3. Screenshot key frames at 1080×1920
4. Generate carousel slides with carousel-maker.sh
5. Upload both to Capcut / Adobe Express for final assembly
```

### Profile Model
Aphrodite uses `google/gemini-2.0-flash-001` via OpenRouter — optimized for high-frequency creative inference tasks.

---

## Notes
- Both scripts are idempotent and non-destructive (write to new output file)
- Temporary files are cleaned up automatically via `trap cleanup EXIT`
- Captions are auto-generated placeholders — replace with real copy before posting
- Scripts are executable and ready to use immediately after cloning