# Hermes Skills Inventory
> Generated: 2026-05-15 23:45 UTC — AUDIT ONLY, read-only scan
> Paths scanned: `/root/.hermes/skills` (78 SKILL.md), `/home/workspace/Skills` (2 SKILL.md)
> Note: No API keys, tokens, or credential values are stored in this file.

## Summary

| Status | Count |
|--------|-------|
| WORKING | 56 |
| PARTIAL | 16 |
| BROKEN | 6 |
| DUPLICATE | 2 |
| UNKNOWN | 0 |
| **TOTAL** | **80** |

### Empty Category Directories (no SKILL.md)

- `.hub (empty)`
- `diagramming (has DESCRIPTION.md)`
- `domain (has DESCRIPTION.md)`
- `feeds (has DESCRIPTION.md)`
- `gifs (has DESCRIPTION.md)`
- `inference-sh (has DESCRIPTION.md)`

---

## Skill Details


### [HERMES] apollo-voice-profile

#### apollo-voice-profile ✅ `WORKING`
- **Owner:** Apollo
- **Trigger:** Contains Donny Lewis's voice profile for consistent writing. NEVER share outside this system.
- **Notes:** `gh` ✓

### [HERMES] apple

#### apple/apple-notes ✅ `WORKING`
- **Owner:** Hermes
- **Trigger:** Manage Apple Notes via the memo CLI on macOS (create, view, search, edit).

#### apple/apple-reminders ⚠️ `PARTIAL`
- **Owner:** Hermes
- **Trigger:** Manage Apple Reminders via remindctl CLI (list, add, complete, delete).
- **Notes:** `GOOGLE` not found in .env; `NOTION` not found in .env

#### apple/findmy ✅ `WORKING`
- **Owner:** Hermes
- **Trigger:** Track Apple devices and AirTags via FindMy.app on macOS using AppleScript and screen capture.

#### apple/imessage ⚠️ `PARTIAL`
- **Owner:** Hermes
- **Trigger:** Send and receive iMessages/SMS via the imsg CLI on macOS.
- **Notes:** `TELEGRAM` not found in .env

### [HERMES] autonomous-ai-agents

#### autonomous-ai-agents/claude-code ✅ `WORKING`
- **Owner:** Hermes
- **Trigger:** Delegate coding tasks to Claude Code (Anthropic's CLI agent). Use for building features, refactoring, PR reviews, and it
- **Notes:** `git` ✓; `npm` ✓; `ANTHROPIC_API_KEY` present ✓

#### autonomous-ai-agents/codex ✅ `WORKING`
- **Owner:** Hermes
- **Trigger:** Delegate coding tasks to OpenAI Codex CLI agent. Use for building features, refactoring, PR reviews, and batch issue fix
- **Notes:** `gh` ✓; `git` ✓; `npm` ✓

#### autonomous-ai-agents/dvs-pantheon-comms ⚠️ `PARTIAL`
- **Owner:** Athena
- **Trigger:** How to communicate with and query DVS pantheon agents (Argus, Athena, etc.) — finding agent configs, reading monitored a
- **Notes:** `TELEGRAM` not found in .env; `GOOGLE` not found in .env; `gh` ✓; `zo` ✓; `athena` ✓; `argus` ✓

#### autonomous-ai-agents/hermes-agent ⚠️ `PARTIAL`
- **Owner:** Hermes
- **Trigger:** Complete guide to using and extending Hermes Agent — CLI usage, setup, configuration, spawning additional agents, gatewa
- **Notes:** `TELEGRAM` not found in .env; `gh` ✓; `git` ✓

#### autonomous-ai-agents/manual-context-injection ✅ `WORKING`
- **Owner:** Hermes
- **Trigger:** Delivers prompts by manual context injection.

#### autonomous-ai-agents/opencode ✅ `WORKING`
- **Owner:** Hermes
- **Trigger:** Delegate coding tasks to OpenCode CLI agent for feature implementation, refactoring, PR review, and long-running autonom
- **Notes:** `git` ✓; `npm` ✓

### [HERMES] creative

#### creative/architecture-diagram ⚠️ `PARTIAL`
- **Owner:** Hermes
- **Trigger:** Generate dark-themed SVG diagrams of software systems and cloud infrastructure as standalone HTML files with inline SVG 
- **Notes:** `GOOGLE` not found in .env; linked files: templates/template.html

#### creative/ascii-art ❌ `BROKEN`
- **Owner:** Hermes
- **Trigger:** Generate ASCII art using pyfiglet (571 fonts), cowsay, boxes, toilet, image-to-ascii, remote APIs (asciified, ascii.co.u
- **Notes:** requires `pyfiglet` — NOT INSTALLED; requires `cowsay` — NOT INSTALLED; `python3` ✓

#### creative/ascii-video ✅ `WORKING`
- **Owner:** Hermes
- **Trigger:** Production pipeline for ASCII art video — any format. Converts video/audio/images/generative input into colored ASCII ch
- **Notes:** `ffmpeg` ✓; linked files: references/shaders.md, references/effects.md, references/optimization.md, references/troubleshooting.md, references/architecture.md, references/scenes.md, references/inputs.md, references/composition.md

#### creative/baoyu-infographic ⚠️ `PARTIAL`
- **Owner:** Hermes
- **Trigger:** Generate professional infographics with 21 layout types and 21 visual styles. Analyzes content, recommends layout×style 
- **Notes:** `LINEAR` not found in .env; linked files: references/structured-content-template.md, references/layouts, references/analysis-framework.md, references/base-prompt.md, references/styles

#### creative/creative-ideation ✅ `WORKING`
- **Owner:** Hermes
- **Trigger:** Generate project ideas through creative constraints. Use when the user says 'I want to build something', 'give me a proj
- **Notes:** `gh` ✓; `git` ✓; `npm` ✓; linked files: references/full-prompt-library.md

#### creative/excalidraw ✅ `WORKING`
- **Owner:** Hermes
- **Trigger:** Create hand-drawn style diagrams using Excalidraw JSON format. Generate .excalidraw files for architecture diagrams, flo
- **Notes:** linked files: scripts/upload.py, references/dark-mode.md, references/colors.md, references/examples.md

#### creative/manim-video ❌ `BROKEN`
- **Owner:** Hermes
- **Trigger:** Production pipeline for mathematical and technical animations using Manim Community Edition. Creates 3Blue1Brown-style e
- **Notes:** requires `manim` — NOT INSTALLED; `ffmpeg` ✓; `node` ✓; linked files: scripts/setup.sh, references/troubleshooting.md, references/updaters-and-trackers.md, references/visual-design.md, references/production-quality.md, references/camera-and-3d.md, references/graphs-and-data.md, references/mobjects.md, references/animations.md, references/scene-planning.md, references/animation-design-thinking.md, references/equations.md, references/rendering.md, references/decorations.md, references/paper-explainer.md

#### creative/p5js ❌ `BROKEN`
- **Owner:** Hermes
- **Trigger:** Production pipeline for interactive and generative visual art using p5.js. Creates browser-based sketches, generative ar
- **Notes:** requires `manim` — NOT INSTALLED; linked files: scripts/setup.sh, scripts/serve.sh, scripts/render.sh, scripts/export-frames.js, templates/viewer.html, references/animation.md, references/troubleshooting.md, references/core-api.md, references/shapes-and-geometry.md, references/typography.md, references/export-pipeline.md, references/color-systems.md, references/interaction.md, references/webgl-and-3d.md, references/visual-effects.md

#### creative/pixel-art ✅ `WORKING`
- **Owner:** Hermes
- **Trigger:** Convert images into retro pixel art with hardware-accurate palettes (NES, Game Boy, PICO-8, C64, etc.), and animate them
- **Notes:** linked files: scripts/__init__.py, scripts/palettes.py, scripts/pixel_art.py, scripts/pixel_art_video.py, references/palettes.md

#### creative/popular-web-designs ⚠️ `PARTIAL`
- **Owner:** Hermes
- **Trigger:** >
- **Notes:** `GOOGLE` not found in .env; `LINEAR` not found in .env; `NOTION` not found in .env; linked files: templates/superhuman.md, templates/replicate.md, templates/together.ai.md, templates/stripe.md, templates/sentry.md, templates/claude.md, templates/framer.md, templates/cohere.md, templates/miro.md, templates/posthog.md, templates/webflow.md, templates/spacex.md, templates/clay.md, templates/figma.md, templates/mintlify.md, templates/resend.md, templates/composio.md, templates/opencode.ai.md, templates/airtable.md, templates/notion.md, templates/coinbase.md, templates/clickhouse.md, templates/cursor.md, templates/bmw.md, templates/revolut.md, templates/vercel.md, templates/x.ai.md, templates/pinterest.md, templates/raycast.md, templates/linear.app.md, templates/sanity.md, templates/uber.md, templates/mistral.ai.md, templates/ollama.md, templates/mongodb.md, templates/spotify.md, templates/expo.md, templates/voltagent.md, templates/intercom.md, templates/elevenlabs.md, templates/warp.md, templates/runwayml.md, templates/ibm.md, templates/cal.md, templates/kraken.md, templates/lovable.md, templates/supabase.md, templates/zapier.md, templates/wise.md, templates/minimax.md, templates/airbnb.md, templates/hashicorp.md, templates/apple.md, templates/nvidia.md

#### creative/songwriting-and-ai-music ✅ `WORKING`
- **Owner:** Hermes
- **Trigger:** >
- **Notes:** `gh` ✓

### [HERMES] data-science

#### data-science/jupyter-live-kernel ✅ `WORKING`
- **Owner:** Hermes
- **Trigger:** >
- **Notes:** `git` ✓; `python3` ✓; `jupyter` ✓

### [HERMES] delegate-to-athena

#### delegate-to-athena ✅ `WORKING`
- **Owner:** Athena
- **Trigger:** Delegate research tasks to the Athena wiki agent by running athena chat -q 'task'. Athena maintains the DVS wiki, ingest
- **Notes:** `athena` ✓

### [HERMES] devops

#### devops/webhook-subscriptions ⚠️ `PARTIAL`
- **Owner:** Hermes
- **Trigger:** Create and manage webhook subscriptions for event-driven agent activation, or for direct push notifications (zero LLM co
- **Notes:** `TELEGRAM` not found in .env

### [HERMES] dogfood

#### dogfood ✅ `WORKING`
- **Owner:** Hermes
- **Trigger:** Systematic exploratory QA testing of web applications — find bugs, capture evidence, and generate structured reports
- **Notes:** `gh` ✓; linked files: templates/dogfood-report-template.md, references/issue-taxonomy.md

### [HERMES] email

#### email/himalaya ❌ `BROKEN`
- **Owner:** Hermes
- **Trigger:** CLI to manage emails via IMAP/SMTP. Use himalaya to list, read, write, reply, forward, search, and organize emails from 
- **Notes:** requires `himalaya` — NOT INSTALLED; `gh` ✓; linked files: references/configuration.md, references/message-composition.md

### [HERMES] gaming

#### gaming/minecraft-modpack-server ✅ `WORKING`
- **Owner:** Hermes
- **Trigger:** Set up a modded Minecraft server from a CurseForge/Modrinth server pack zip. Covers NeoForge/Forge install, Java version
- **Notes:** `git` ✓

#### gaming/pokemon-player ✅ `WORKING`
- **Owner:** Hermes
- **Trigger:** Play Pokemon games autonomously via headless emulation. Starts a game server, reads structured game state from RAM, make
- **Notes:** `gh` ✓; `python3` ✓

### [HERMES] github

#### github/codebase-inspection ✅ `WORKING`
- **Owner:** Hermes
- **Trigger:** Inspect and analyze codebases using pygount for LOC counting, language breakdown, and code-vs-comment ratios. Use when a
- **Notes:** `gh` ✓; `node` ✓

#### github/github-auth ✅ `WORKING`
- **Owner:** Hermes
- **Trigger:** Set up GitHub authentication for the agent using git (universally available) or the gh CLI. Covers HTTPS tokens, SSH key
- **Notes:** `gh` ✓; `git` ✓; linked files: scripts/gh-env.sh

#### github/github-cache-refresh ✅ `WORKING`
- **Owner:** Hermes
- **Trigger:** Force GitHub to refresh its cache for a file after a successful push. Useful when changes are not immediately reflected.
- **Notes:** `git` ✓; `zo` ✓

#### github/github-code-review ✅ `WORKING`
- **Owner:** Hermes
- **Trigger:** Review code changes by analyzing git diffs, leaving inline comments on PRs, and performing thorough pre-push review. Wor
- **Notes:** `gh` ✓; `git` ✓; `python3` ✓; linked files: references/review-output-template.md

#### github/github-issues ✅ `WORKING`
- **Owner:** Hermes
- **Trigger:** Create, manage, triage, and close GitHub issues. Search existing issues, add labels, assign people, and link to PRs. Wor
- **Notes:** `gh` ✓; `git` ✓; `python3` ✓; linked files: templates/bug-report.md, templates/feature-request.md

#### github/github-pr-workflow ✅ `WORKING`
- **Owner:** Hermes
- **Trigger:** Full pull request lifecycle — create branches, commit changes, open PRs, monitor CI status, auto-fix failures, and merge
- **Notes:** `gh` ✓; `git` ✓; linked files: templates/pr-body-bugfix.md, templates/pr-body-feature.md, references/conventional-commits.md, references/ci-troubleshooting.md

#### github/github-repo-management ✅ `WORKING`
- **Owner:** Hermes
- **Trigger:** Clone, create, fork, configure, and manage GitHub repositories. Manage remotes, secrets, releases, and workflows. Works 
- **Notes:** `gh` ✓; `git` ✓; `python3` ✓; linked files: references/github-api-cheatsheet.md

### [HERMES] invoke-apollo

#### invoke-apollo 🔁 `DUPLICATE`
- **Owner:** Apollo
- **Trigger:** Delegates writing tasks to Apollo while automatically injecting Donny Lewis's voice profile as mandatory context. Use th
- **Notes:** also exists at: []

### [HERMES] mcp

#### mcp/native-mcp ✅ `WORKING`
- **Owner:** Hermes
- **Trigger:** Built-in MCP (Model Context Protocol) client that connects to external MCP servers, discovers their tools, and registers
- **Notes:** `node` ✓

### [HERMES] media

#### media/gif-search ⚠️ `PARTIAL`
- **Owner:** Hermes
- **Trigger:** Search and download GIFs from Tenor using curl. No dependencies beyond curl and jq. Useful for finding reaction GIFs, cr
- **Notes:** `GOOGLE` not found in .env

#### media/heartmula ✅ `WORKING`
- **Owner:** Hermes
- **Trigger:** Set up and run HeartMuLa, the open-source music generation model family (Suno-like). Generates full songs from lyrics + 
- **Notes:** `git` ✓

#### media/songsee ✅ `WORKING`
- **Owner:** Hermes
- **Trigger:** Generate spectrograms and audio feature visualizations (mel, chroma, MFCC, tempogram, etc.) from audio files via CLI. Us
- **Notes:** `ffmpeg` ✓

#### media/youtube-content ✅ `WORKING`
- **Owner:** Hermes
- **Trigger:** >
- **Notes:** `gh` ✓; `python3` ✓; linked files: scripts/fetch_transcript.py, references/output-formats.md

### [HERMES] mlops

#### mlops/evaluation/lm-evaluation-harness ✅ `WORKING`
- **Owner:** Hermes
- **Trigger:** Evaluates LLMs across 60+ academic benchmarks (MMLU, HumanEval, GSM8K, TruthfulQA, HellaSwag). Use when benchmarking mod
- **Notes:** linked files: references/distributed-eval.md, references/api-evaluation.md, references/custom-tasks.md, references/benchmark-guide.md

#### mlops/evaluation/weights-and-biases ⚠️ `PARTIAL`
- **Owner:** Hermes
- **Trigger:** Track ML experiments with automatic logging, visualize training in real-time, optimize hyperparameters with sweeps, and 
- **Notes:** `WANDB` not found in .env; linked files: references/integrations.md, references/sweeps.md, references/artifacts.md

#### mlops/huggingface-hub ⚠️ `PARTIAL`
- **Owner:** Hermes
- **Trigger:** Hugging Face Hub CLI (hf) — search, download, and upload models and datasets, manage repos, query datasets with SQL, dep
- **Notes:** `HF_TOKEN` not found in .env

#### mlops/inference/llama-cpp ✅ `WORKING`
- **Owner:** Hermes
- **Trigger:** llama.cpp local GGUF inference + HF Hub model discovery.
- **Notes:** `git` ✓; linked files: references/troubleshooting.md, references/hub-discovery.md, references/quantization.md, references/server.md, references/optimization.md, references/advanced-usage.md

#### mlops/inference/obliteratus ✅ `WORKING`
- **Owner:** Hermes
- **Trigger:** Remove refusal behaviors from open-weight LLMs using OBLITERATUS — mechanistic interpretability techniques (diff-in-mean
- **Notes:** `git` ✓; `python3` ✓; linked files: templates/abliteration-config.yaml, templates/analysis-study.yaml, templates/batch-abliteration.yaml, references/methods-guide.md, references/analysis-modules.md

#### mlops/inference/outlines ✅ `WORKING`
- **Owner:** Hermes
- **Trigger:** Guarantee valid JSON/XML/code structure during generation, use Pydantic models for type-safe outputs, support local mode
- **Notes:** `gh` ✓; `git` ✓; linked files: references/examples.md, references/json_generation.md, references/backends.md

#### mlops/inference/vllm ✅ `WORKING`
- **Owner:** Hermes
- **Trigger:** Serves LLMs with high throughput using vLLM's PagedAttention and continuous batching. Use when deploying production LLM 
- **Notes:** `gh` ✓; linked files: references/quantization.md, references/optimization.md, references/troubleshooting.md, references/server-deployment.md

#### mlops/models/audiocraft ✅ `WORKING`
- **Owner:** Hermes
- **Trigger:** PyTorch library for audio generation including text-to-music (MusicGen) and text-to-sound (AudioGen). Use when you need 
- **Notes:** linked files: references/advanced-usage.md, references/troubleshooting.md

#### mlops/models/segment-anything ✅ `WORKING`
- **Owner:** Hermes
- **Trigger:** Foundation model for image segmentation with zero-shot transfer. Use when you need to segment any object in images using
- **Notes:** `gh` ✓; linked files: references/advanced-usage.md, references/troubleshooting.md

#### mlops/research/dspy ✅ `WORKING`
- **Owner:** Hermes
- **Trigger:** Build complex AI systems with declarative programming, optimize prompts automatically, create modular RAG systems and ag
- **Notes:** linked files: references/optimizers.md, references/modules.md, references/examples.md

#### mlops/training/axolotl ✅ `WORKING`
- **Owner:** Hermes
- **Trigger:** Expert guidance for fine-tuning LLMs with Axolotl - YAML configs, 100+ models, LoRA/QLoRA, DPO/KTO/ORPO/GRPO, multimodal
- **Notes:** linked files: references/index.md, references/api.md, references/dataset-formats.md, references/other.md

#### mlops/training/trl-fine-tuning ✅ `WORKING`
- **Owner:** Hermes
- **Trigger:** Fine-tune LLMs using reinforcement learning with TRL - SFT for instruction tuning, DPO for preference alignment, PPO/GRP
- **Notes:** linked files: templates/basic_grpo_training.py, references/dpo-variants.md, references/grpo-training.md, references/reward-modeling.md, references/sft-training.md, references/online-rl.md

#### mlops/training/unsloth ✅ `WORKING`
- **Owner:** Hermes
- **Trigger:** Expert guidance for fast fine-tuning with Unsloth - 2-5x faster training, 50-80% less memory, LoRA/QLoRA optimization
- **Notes:** linked files: references/llms-full.md, references/llms-txt.md, references/index.md, references/llms.md

### [HERMES] note-taking

#### note-taking/obsidian ✅ `WORKING`
- **Owner:** Hermes
- **Trigger:** Read, search, and create notes in the Obsidian vault.

### [HERMES] productivity

#### productivity/google-workspace ❌ `BROKEN`
- **Owner:** Hermes
- **Trigger:** Gmail, Calendar, Drive, Contacts, Sheets, and Docs integration for Hermes. Uses Hermes-managed OAuth2 setup, prefers the
- **Notes:** requires `himalaya` — NOT INSTALLED; `gh` ✓; linked files: scripts/google_api.py, scripts/gws_bridge.py, scripts/setup.py, references/gmail-search-syntax.md

#### productivity/linear ⚠️ `PARTIAL`
- **Owner:** Hermes
- **Trigger:** Manage Linear issues, projects, and teams via the GraphQL API. Create, update, search, and organize issues. Uses API key
- **Notes:** `LINEAR` not found in .env; `node` ✓; `python3` ✓

#### productivity/maps ⚠️ `PARTIAL`
- **Owner:** Hermes
- **Trigger:** >
- **Notes:** `TELEGRAM` not found in .env; `GOOGLE` not found in .env; `python3` ✓; linked files: scripts/maps_client.py

#### productivity/nano-pdf ✅ `WORKING`
- **Owner:** Hermes
- **Trigger:** Edit PDFs with natural-language instructions using the nano-pdf CLI. Modify text, fix typos, update titles, and make con

#### productivity/notion ⚠️ `PARTIAL`
- **Owner:** Hermes
- **Trigger:** Notion API for creating and managing pages, databases, and blocks via curl. Search, create, update, and query Notion wor
- **Notes:** `NOTION` not found in .env; linked files: references/block-types.md

#### productivity/ocr-and-documents ✅ `WORKING`
- **Owner:** Hermes
- **Trigger:** Extract text from PDFs and scanned documents. Use web_extract for remote URLs, pymupdf for local text-based PDFs, marker
- **Notes:** `gh` ✓; `python3` ✓; linked files: scripts/extract_pymupdf.py, scripts/extract_marker.py

#### productivity/powerpoint ✅ `WORKING`
- **Owner:** Hermes
- **Trigger:** Use this skill any time a .pptx file is involved in any way — as input, output, or both. This includes: creating slide d
- **Notes:** `gh` ✓; linked files: scripts/add_slide.py, scripts/clean.py, scripts/office, scripts/__init__.py

### [HERMES] red-teaming

#### red-teaming/godmode ✅ `WORKING`
- **Owner:** Hermes
- **Trigger:** Jailbreak API-served LLMs using G0DM0D3 techniques — Parseltongue input obfuscation (33 techniques), GODMODE CLASSIC sys
- **Notes:** linked files: scripts/godmode_race.py, scripts/auto_jailbreak.py, scripts/load_godmode.py, scripts/parseltongue.py, templates/prefill-subtle.json, templates/prefill.json, references/jailbreak-templates.md, references/refusal-detection.md

### [HERMES] research

#### research/arxiv ✅ `WORKING`
- **Owner:** Hermes
- **Trigger:** Search and retrieve academic papers from arXiv using their free REST API. No API key needed. Search by keyword, author, 
- **Notes:** `gh` ✓; `python3` ✓; linked files: scripts/search_arxiv.py

#### research/blogwatcher ✅ `WORKING`
- **Owner:** Hermes
- **Trigger:** Monitor blogs and RSS/Atom feeds for updates using the blogwatcher-cli tool. Add blogs, scan for new articles, track rea

#### research/llm-wiki ✅ `WORKING`
- **Owner:** Hermes
- **Trigger:** Karpathy's LLM Wiki — build and maintain a persistent, interlinked markdown knowledge base. Ingest sources, query compil

#### research/polymarket ✅ `WORKING`
- **Owner:** Hermes
- **Trigger:** Query Polymarket prediction market data — search markets, get prices, orderbooks, and price history. Read-only via publi
- **Notes:** linked files: scripts/polymarket.py, references/api-endpoints.md

#### research/research-paper-writing ⚠️ `PARTIAL`
- **Owner:** Hermes
- **Trigger:** End-to-end pipeline for writing ML/AI research papers — from experiment design through analysis, drafting, revision, and
- **Notes:** `LINEAR` not found in .env; `gh` ✓; `git` ✓; linked files: templates/neurips2025, templates/iclr2026, templates/README.md, templates/aaai2026, templates/colm2025, templates/acl, templates/icml2026, references/checklists.md, references/citation-workflow.md, references/human-evaluation.md, references/paper-types.md, references/autoreason-methodology.md, references/experiment-patterns.md, references/writing-guide.md, references/reviewer-guidelines.md, references/sources.md

### [HERMES] smart-home

#### smart-home/openhue ⚠️ `PARTIAL`
- **Owner:** Hermes
- **Trigger:** Control Philips Hue lights, rooms, and scenes via the OpenHue CLI. Turn lights on/off, adjust brightness, color, color t
- **Notes:** `HUE_API` not found in .env

### [HERMES] social-media

#### social-media/xurl ❌ `BROKEN`
- **Owner:** Hermes
- **Trigger:** Interact with X/Twitter via xurl, the official X API CLI. Use for posting, replying, quoting, searching, timelines, ment
- **Notes:** requires `xurl` — NOT INSTALLED; `npm` ✓

### [HERMES] software-development

#### software-development/plan ✅ `WORKING`
- **Owner:** Hermes
- **Trigger:** Plan mode for Hermes — inspect context, write a markdown plan into the active workspace's `.hermes/plans/` directory, an

#### software-development/requesting-code-review ✅ `WORKING`
- **Owner:** Hermes
- **Trigger:** >
- **Notes:** `git` ✓; `node` ✓; `npm` ✓

#### software-development/subagent-driven-development ✅ `WORKING`
- **Owner:** Hermes
- **Trigger:** Use when executing implementation plans with independent tasks. Dispatches fresh delegate_task per task with two-stage r
- **Notes:** `gh` ✓; `git` ✓

#### software-development/systematic-debugging ✅ `WORKING`
- **Owner:** Hermes
- **Trigger:** Use when encountering any bug, test failure, or unexpected behavior. 4-phase root cause investigation — NO fixes without
- **Notes:** `git` ✓

#### software-development/test-driven-development ✅ `WORKING`
- **Owner:** Hermes
- **Trigger:** Use when implementing any feature or bugfix, before writing implementation code. Enforces RED-GREEN-REFACTOR cycle with 

#### software-development/write_task_to_file ✅ `WORKING`
- **Owner:** Hermes
- **Trigger:** Writes a task to a file using the terminal.

#### software-development/writing-plans ✅ `WORKING`
- **Owner:** Hermes
- **Trigger:** Use when you have a spec or requirements for a multi-step task. Creates comprehensive implementation plans with bite-siz
- **Notes:** `git` ✓

### [WORKSPACE] aphrodite-video

#### aphrodite-video ✅ `WORKING`
- **Owner:** Aphrodite
- **Trigger:** >
- **Notes:** `ffmpeg` ✓; `node` ✓; `npm` ✓; `zo` ✓; linked files: scripts/autoclip-api.ts, scripts/run-api.sh, scripts/cut_clip_with_captions.py, scripts/autoclip-detect.ts, scripts/autoclip-post.ts, scripts/autoclip-ingest.ts, scripts/autoclip-orchestrate.ts, scripts/autoclip-edit.ts, scripts/generate_tiktok_captions.py, scripts/autoclip-detect-from-transcript.ts

### [WORKSPACE] invoke-apollo

#### invoke-apollo 🔁 `DUPLICATE`
- **Owner:** Apollo
- **Trigger:** >
- **Notes:** also exists at: []

---

## Smoke Test Results

| Test | Result |
|------|--------|
| `zo` CLI present | ✅ |
| `athena` CLI present | ✅ |
| `argus` CLI present | ✅ |
| `gh` CLI present | ✅ |
| `ffmpeg` present | ✅ |
| `himalaya` present | ❌ — email skills BROKEN |
| `xurl` present | ❌ — X/Twitter skill BROKEN |
| `pyfiglet` (python) | ❌ — ascii-art skill BROKEN |
| `manim` present | ❌ — manim-video skill BROKEN |
| `cowsay` present | ❌ — ascii-art PARTIAL |
| `.hermes/.env` readable | ✅ |
| Env keys detected (names only) | 35 keys present |

---

## Blockers

| Tool Missing | Affected Skills |
|-------------|-----------------|
| `himalaya` | email/himalaya |
| `xurl` | social-media/xurl |
| `pyfiglet` | creative/ascii-art |
| `manim` | creative/manim-video |
| `cowsay` | creative/ascii-art (partial) |