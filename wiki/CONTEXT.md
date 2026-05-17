# DVS Context — 2026-05-17 (Fresh Audit)

**Purpose:** Single source of truth for all DVS swarm operations. Updated at the start of every session. Stale info causes confusion — this file must be current.

---

## WHO IS DONNY

Donny Lewis. Munich/US. EN/FR/DE. Ecosystem operator, writer, model, actor, creative director.
- Core contributor ETHis 2026 (July 2-3, Deutsches Museum Munich)
- Editor IRK Magazine Paris
- Creative Director Beyond Design Agency
- Co-founder WeTryBetter, Viridis (green-tech DAO)
- Web3 8+ years

Treat as trusted co-worker. Security priority one. Never paste API keys in chat.

---

## THE VISION

Fully autonomous agent swarm operating as a one-person company — research, writing, code, operations, commerce, trading, marketing, monitoring. Donny is architect and strategic counselor, not operator.

Immediate 90 days: Land Tether role. Truth About Trust series → book. Aphrodite live for Kristina. Tiny Stars Publishing KDP. Trading bots online. ETHis 2026 core organizer.

---

## INFRASTRUCTURE — WHAT'S LIVE RIGHT NOW

### Hermes (Orchestrator)
- **Status:** RUNNING — PID 15428 — `/root/.hermes/hermes-agent/venv/bin/python3 /root/.hermes/hermes-agent/venv/bin/hermes`
- **Telegram:** @DVS_HermesBot — DM `6127567978`
- **Config:** `~/.hermes/config.yaml` (model: claude-sonnet-4-6, provider: anthropic)
- **Uptime:** Since May 16 08:01 (over 24h)
- **Git repo:** DVSLewis/hermes (git push working)
- **.env:** `/root/.hermes/.env` — 35 keys present

### Aphrodite Video Pipeline
- **Status:** RUNNING — PID 75 — `bun /home/workspace/Skills/aphrodite-video/scripts/autoclip-api.ts`
- **Location:** `/home/workspace/Skills/aphrodite-video/`
- **Owner:** Hephaestus-built Aphrodite. Brand configs: RBYS coral-purple gradient, DVS custom.

### Zo Computer
- **Status:** Paid, always-on
- **Note:** No crontab on the system level — cron runs through Hermes's built-in scheduler

---

## ACTIVE CRON JOBS (Hermes internal)

| ID | Name | Schedule | Next Run | Last Run | Status |
|---|---|---|---|---|---|
| `e2c09bee222e` | wiki-daily-backup | `0 21 * * *` | 2026-05-16 21:00 | 2026-05-15 21:00 | ✅ ok |
| `1b4dc234acf3` | athena-weekly-synthesis | `0 8 * * 1,4` | 2026-05-18 08:00 | 2026-04-27 08:00 | ⚠️ paused |
| `cf97d1b5303a` | Argus Daily Brief v2 | `0 9 * * *` | — | 2026-04-28 09:01 | ⚠️ paused |

**Note:** The Argus and Athena jobs above are from OLD configs. The LIVE jobs (created May 15-16) are stored in:
- `/root/.hermes/cron/` (JSON files per job)

Run `ls /root/.hermes/cron/*.json` to see all current cron jobs.

---

## DAILY PIPELINE — WHAT'S ACTUALLY RUNNING

### Argus (Intelligence Gathering)
- **Script:** `argus-daily-brief.sh` at `/root/workspace/my-wiki/scripts/` (old shell version)
- **Canonical runner (newer):** `/root/.hermes/scripts/argus-daily-brief-canonical.py` (spec exists, verify if live)
- **Fetch:** Tavily — 11 topic clusters, ~54-115 signals per run
- **Scoring:** OpenAI gpt-4o-mini (1-10 relevance)
- **Output:** `wiki/daily-brief-YYYY-MM-DD.md` + `raw/daily-inbox/YYYY-MM-DD.md` (signals ≥8)
- **Cognee:** Ingested after each run — knowledge graph growing
- **Git:** Athena pushes to GitHub after each run
- **Delivery:** Telegram — message_id logged in runbooks

### Athena (Synthesis)
- **Script:** `athena-weekly-synthesis.sh` at `/root/workspace/my-wiki/scripts/`
- **Schedule:** `30 7 * * *` (7:30am UTC = 8:30am CET)
- **Output:** `wiki/knowledge-synthesis-YYYY-MM-DD.md`
- **Delivery:** Telegram — message_id 512 (May 17 run confirmed)
- **Git:** Pushes to GitHub after each run

---

## WATCHDOG SYSTEM (Active — May 17 setup)

Independent fallback scripts that fire after main cron jobs:
- **Argus Watchdog:** Fires at 07:05 UTC if Argus misses its 07:00 run → Telegram message_id 513 (May 17 verified)
- **Athena Watchdog:** Fires at 07:40 UTC if Athena misses its 07:30 run → Telegram message_id 514 (May 17 verified)
- **Location:** `/root/.hermes/scripts/dvs-watchdog.py`
- **Delivery:** Direct Python stdlib `urllib` — no Hermes dependency
- **Log:** `/root/.hermes/logs/watchdogs/`

---

## SUPERVISED SERVICES (Zo User Services)

| Service | PID | Status | Since |
|---|---|---|---|
| Hermes gateway | 15428 | ✅ running | 2026-05-16 08:01 |
| Aphrodite autoclip-api | 75 | ✅ running | 2026-05-16 |

---

## GITHUB REPOS

| Repo | Status |
|---|---|
| DVSLewis/hermes | ✅ git push working |
| DVSLewis/my-wiki | ✅ git push working |

---

## KNOWLEDGE SYNTHESIS RECENT

| Date | File | Signals |
|---|---|---|
| 2026-05-17 | `knowledge-synthesis-2026-05-17.md` | 4 inbox files |
| 2026-05-16 | `knowledge-synthesis-2026-05-16.md` | 1 inbox file |
| 2026-05-15 | `knowledge-synthesis-2026-05-15.md` | 3 inbox files |

Key themes from recent syntheses:
- Ethereum 2026 roadmap: decentralization as rebellion, native account abstraction, quantum resilience
- Ethereum Economic Zone (EEZ): real-time proving to reunify fragmented L2 ecosystem
- AI agents as first-class blockchain citizens (ERC-8004/X-402 standards emerging)
- ETH trading $2,122-$2,407 range — accumulation by core builders

---

## SKILLS INVENTORY (Last audit: 2026-05-15 23:45 UTC)

| Status | Count |
|--------|-------|
| WORKING | 56 |
| PARTIAL | 16 |
| BROKEN | 6 |
| DUPLICATE | 2 |
| **TOTAL** | **80** |

### Broken (need fixing)
- `email/himalaya` — himalaya binary not installed
- `social-media/xurl` — xurl binary not installed
- `creative/ascii-art` — pyfiglet + cowsay not installed
- `creative/manim-video` — manim not installed
- `creative/p5js` — manim not installed

### Missing API keys (PARTIAL)
- `LINEAR`, `NOTION`, `GOOGLE`, `TELEGRAM`, `HUE_API`, `WANDB`, `HF_TOKEN` — not in .env

---

## WHAT HAPPENED MAY 15-16 (Session summary)

**May 15-16 was a 4-hour infrastructure hardening session:**
1. Hermes gateway migrated to Zo User Service (supervised) — stable
2. Argus canonical runner built and cron switched over
3. Watchdog system created and verified
4. Project snapshot exported to `Exports/dvs-pantheon-condensed-project-sources-2026-05-16.zip`
5. Git commits: 7 across hermes and my-wiki repos

**Incident:** Hermes gateway supervision failure on May 17 morning — watchdog triggered, Hermes restarted.

---

## KEY FILES

| File | Purpose |
|---|---|
| `wiki/CONTEXT.md` | This file — live state snapshot |
| `wiki/log.md` | Session-by-session activity log |
| `wiki/snapshots/` | Pre-proof baseline snapshots |
| `wiki/incidents/` | Incident post-mortems |
| `wiki/runbooks/` | Operational runbooks |
| `sync/hermes-cron-desired.json` | Durable cron desired state (git-tracked) |
| `sync/manifest.md` | Change manifest |

---

## WHAT'S BROKEN OR UNVERIFIED

| Item | Status | Notes |
|---|---|---|
| Hermes cron persistence across sandbox reset | Unknown | Watchdogs should compensate |
| Cognee bootstrap complete | Unknown | Not verified this session |
| Athena end-to-end research pipeline | Unverified | Script exists, never run live |
| Kristina/RewriteBeforeYouSend Google Drive | Not built | Client is waiting |
| Aphrodite email-to-agent pipeline | Not built | No delivery mechanism |
| Hermes SOUL.md for all 9 agents | Partial | SOUL.md exists but not all verified |

---

## NEXT SESSION PRIORITY ORDER

1. Verify Argus canonical runner is actually the live one firing at 07:00 UTC
2. Verify all 5 broken skills — install missing binaries
3. Bootstrap Cognee with all wiki pages
4. Build Kristina Google Drive submission flow for RewriteBeforeYouSend
5. Fix Hermes cron persistence — prove it survives sandbox reset
6. Truth About Trust Chapter 4 — Apollo ready to write
7. Verify Athena end-to-end research pipeline

---

*CONTEXT.md last updated: 2026-05-17 14:35 UTC — Fresh audit from live system*