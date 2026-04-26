# Aphrodite Video Pipeline

> Built by Hephaestus on 2026-04-26 for the DVS Pantheon
> Status: Active

---

## Overview

Aphrodite manages the creative video pipeline for DVS — producing short-form videos, branded carousels, and sourced content. Three tools handle the heavy lifting: a multi-platform video export script (FFmpeg), a multi-format carousel generator (ImageMagick), and a YouTube download utility (yt-dlp).

---

## 1. tiktok-editor.sh

**Purpose:** Export a single input video to all platform formats simultaneously.

**Location:** `aphrodite-training/bin/tiktok-editor.sh`

### Requirements
- `ffmpeg` + `ffprobe` (H.264, AAC, libass)
- `bc` for floating-point arithmetic

### Usage
```bash
./tiktok-editor.sh <input.mp4> [srt_captions_file]
```

All outputs are written to the same directory as the input.

### Formats

| Platform | Resolution | Max Duration | Output File |
|----------|-----------|--------------|-------------|
| TikTok | 1080×1920 portrait | 20–30s | `<filename>-tiktok.mp4` |
| Instagram Reels | 1080×1920 portrait | 20–30s | `<filename>-reels.mp4` |
| YouTube Shorts | 1080×1920 portrait | 60s | `<filename>-youtube-short.mp4` |
| YouTube (long-form) | 1920×1080 landscape | 60 min | `<filename>-youtube.mp4` |
| Instagram Feed (square) | 1080×1080 | 60s | `<filename>-ig-square.mp4` |
| Instagram Feed (portrait) | 1080×1350 | 60s | `<filename>-ig-portrait.mp4` |

### Trim Logic
- **≤ target duration:** use as-is
- **just over (≤ 2× target):** trim from start
- **well over:** center-trim (skips intro + outro equally)

### Captions
Pass an SRT file as the second argument to burn hardcoded captions into all outputs:
```bash
./tiktok-editor.sh raw_footage.mp4 my_captions.srt
```
If `<filename>.srt` exists alongside the input, it is auto-detected.

### Encoding Specs
- Video: H.264 (libx264), CRF 23, `fast` preset
- Audio: AAC 128kbps
- Container: MP4 with `faststart` for streaming

---

## 2. carousel-maker.sh

**Purpose:** Generate branded image slides in multiple social formats.

**Location:** `aphrodite-training/bin/carousel-maker.sh`

### Requirements
- `ImageMagick` (`convert`, `composite`)

### Usage
```bash
./carousel-maker.sh <text> <output.png> \
  [--format <name>] \
  [--gradient <preset>] \
  [--gradient '#hex1,#hex2'] \
  [--font-size <px>] \
  [--font <fontname>]
```

### Formats

| Name | Resolution | Aspect | Output Use |
|------|-----------|--------|------------|
| `ig-square` | 1080×1080 | square | Instagram feed |
| `ig-portrait` | 1080×1350 | 4:5 portrait | Instagram feed |
| `tiktok` | 1080×1920 | 9:16 portrait | TikTok slideshow |
| `linkedin` | 1200×627 | landscape | LinkedIn feed |

Default: `ig-square`.

### Gradient Presets

| Preset | Colors | Brand |
|--------|--------|-------|
| `violet-indigo` | Purple → Indigo | RBYS default |
| `sunset` | Orange → Pink | — |
| `ocean` | Navy → Cyan | — |
| `emerald` | Emerald → Teal | — |
| `rose-gold` | Rose → Gold | — |
| `custom` | Any two hex colors | Per-client |

### Custom Color Example
```bash
# Client: Acme Corp brand colors
./carousel-maker.sh "Big News!" acme.png \
  --format ig-square \
  --gradient '#FF3300,#0033CC'
```

### What it does
1. Plasma gradient background with blur for smooth color transitions
2. Vignette overlay for depth
3. Helvetica Bold text, word-wrapped at 28 chars (38 for LinkedIn)
4. Drop shadow for readability on any background
5. 6px branded border in the gradient's primary color

### Examples
```bash
./carousel-maker.sh "Welcome to DVS" dvs-slide.png \
  --format ig-square --gradient violet-indigo --font-size 80

./carousel-maker.sh "Q3 Results" q3.png \
  --format linkedin --gradient ocean

./carousel-maker.sh "Drop is Live" drop.png \
  --format tiktok --gradient '#FF6B6B,#9B59B6'
```

---

## 3. yt-dlp — YouTube Downloader

**Purpose:** Download YouTube videos as source material for editing.

### Install
```bash
pip install yt-dlp
```

### Basic Usage
```bash
# Download best available quality
yt-dlp "https://www.youtube.com/watch?v=VIDEO_ID"

# Download as MP4, best video + audio
yt-dlp -f "bv+ba" -f mp4 "https://www.youtube.com/watch?v=VIDEO_ID"

# Download audio only (MP3)
yt-dlp -x --audio-format mp3 "https://www.youtube.com/watch?v=VIDEO_ID"

# Download at specific resolution
yt-dlp -f "bv[height<=1080]+ba" "https://www.youtube.com/watch?v=VIDEO_ID"

# Download a playlist (all videos)
yt-dlp "https://www.youtube.com/playlist?list=PLAYLIST_ID"
```

### Workflow: Download → Edit
```
1. yt-dlp "https://youtube.com/watch?v=..."   # download source
2. tiktok-editor.sh source.mp4               # export all platform formats
3. carousel-maker.sh "Key Frame" slide.png  # make carousel from screenshot
4. Upload to Capcut / Adobe Express
```

---

## Integration

### Workflow: Sourced Video → Multi-Platform Post
```
1. Download raw footage    →  yt-dlp or screen record
2. Edit in Capcut / Premiere
3. Export master clip      →  master.mp4
4. Run tiktok-editor.sh    →  All 6 platform files
5. Extract key frames       →  Screenshots at 1080p
6. Run carousel-maker.sh   →  Branded carousel slides
7. Upload to each platform
```

### Profile Model
Aphrodite uses `google/gemini-2.0-flash-001` via OpenRouter — optimized for high-frequency creative inference.

| Profile | Model | Provider |
|---------|-------|----------|
| apollo | `openai/gpt-4o` | openrouter |
| hephaestus | `deepseek/deepseek-chat-v3` | openrouter |
| aphrodite | `google/gemini-2.0-flash-001` | openrouter |

---

## Notes
- All scripts are idempotent and non-destructive
- Temporary files cleaned via `trap cleanup EXIT`
- yt-dlp requires ffmpeg for merging video/audio streams
- Captions in tiktok-editor.sh are optional; all 6 outputs generate regardless
- Scripts are executable and ready to use immediately
