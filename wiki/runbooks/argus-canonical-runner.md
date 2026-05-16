# Argus Canonical Runner — Specification

**File:** `/root/.hermes/scripts/argus-daily-brief-canonical.py`  
**Status:** Draft — do not implement yet  
**Cron job target:** `argus-daily-brief` (id `42cd1df992e7`)  
**Current active script:** `argus-daily-brief-v3.py`  

---

## 1. Overview

The canonical Argus runner generates the daily intelligence brief for the DVS swarm. It fetches social and news feeds, scores and classifies signals, writes structured artifacts to the wiki, delivers Telegram summaries, and syncs to GitHub — all without touching the Hermes gateway lifecycle.

**Non-negotiable constraint:** This script must never start or stop the Hermes gateway. It must not call `hermes gateway run` or `hermes gateway stop` under any circumstances.

---

## 2. Language & Structure

**Recommended: Option B — Create new `argus-daily-brief-canonical.py`**

| Option | Pros | Cons |
|---|---|---|
| **A: Patch v3 into v4** | Preserves v3 Telegram direct-delivery logic | v3 is tightly coupled to Tavily, mixes concerns, hard to extend cleanly |
| **B: New canonical Python** | Clean architecture, schema-first, testable, no legacy pollution | Slightly more work upfront |
| **C: Shell wrapper + Python core** | Preserves bash RSS parsing, timeout, feed logic | Two languages to maintain, harder to test |

**Decision: Option B.** The metadata normalization, JSON sidecars, rejection logs, platform grouping, and direct Telegram message_id logging require a language with strong data structure support. Python is the right tool. The existing v3 Python is not a good base to patch because its Tavily coupling, lack of TIER classification, and absence of git sync make it architecturally incompatible with the requirements.

The new canonical script should be **single-file Python**, self-contained, with zero external dependencies beyond the Python 3 standard library and `requests` (already available in the Hermes venv).

---

## 3. Source Fetching

### 3.1 RSS Feed Sources

Use RSSBridge via `https://rsshub.app/twitter/user/{handle}` for X/Twitter accounts.

**TIER1** (signal priority — tight freshness windows):  
`VitalikButerin karpathy koeppelmann timbeiko samczsun gakonst superphiz hudsonjameson`

**TIER2** (secondary — medium freshness):  
`shivsakhuja echinstitute ethereumfndn AustinGriffiths cyrilXBT`

**TIER3** (background — loose freshness):  
`aboutcircles GnosisDAO gnosischain safe gnosisguild cowswap kylearojas thedaofund chaskin22 etheconomiczone`

### 3.2 Fetch Behavior

- Fetch all feeds concurrently using `concurrent.futures.ThreadPoolExecutor` (max 10 threads)
- Each feed fetch has a **30-second timeout** per handle
- Failed feeds (404, timeout, empty) are logged as `[SKIP]` and do not abort the run
- If ALL feeds fail, the script exits with code 2 (pipeline failure — see §11)
- Feed content is parsed for `<item>` and `<atom:entry>` elements
- Each item must extract: `title`, `link`, `pubDate`/`published`

---

## 4. Freshness Rules

| Tier | Default cutoff | Background exception |
|---|---|---|
| TIER1 | 72 hours | Marked `freshness_status: background` if older |
| TIER2 | 72 hours | Same |
| TIER3 | 7 days | Same |
| Undated / parse error | Treated as `undated` | Must NOT be treated as fresh — always tagged `freshness_status: undated`, `disposition: background` |

**Rule:** No item with `freshness_status: undated` may be set to `disposition: brief` or `disposition: inbox`. All undated items go to background.

---

## 5. Item Schema

Every scored item MUST contain these fields:

```python
{
    "id": "<uuid-v4>",                    # auto-generated, stable per item
    "title": "<string, up to 300 chars>", # cleaned title
    "url": "<string, valid URL>",
    "source_platform": x | reddit | substack | youtube | github | luma | rss | web | other,
    "source_type": direct_post | blog | newsletter | video | repo | event | news_aggregator | podcast | unknown,
    "source_tier": TIER_1 | TIER_2 | TIER_3,
    "source_name": "<display name>",       # e.g. "GnosisDAO"
    "handle_or_feed": "<handle or feed URL>",
    "published_date": "<ISO8601 or null>", # parsed from feed, null if not parseable
    "retrieved_at": "<ISO8601>",           # UTC now
    "freshness_status": fresh | recent | background | stale | undated,
    "relevance_score": <int 1-10>,        # LLM-assigned
    "disposition": brief | inbox | background | rejected,
    "reason_selected": "<string>",         # why disposition was assigned
    "reason_rejected": "<string or null>",
    "tags": ["<tag1>", ...],              # e.g. ["ethereum", "dao", "governance"]
    "entity_mentions": ["<entity1>", ...]  # extracted named entities
}
```

---

## 6. Scoring

- Feed items are collected with their metadata
- Items are submitted to the LLM (via Hermes `hermes chat` or direct OpenRouter API) in batches of 20
- Each batch prompt requests JSON array of scored items with the full schema above
- Score ≥ 8 → `disposition: inbox` (Athena synthesis input)
- Score 7 → `disposition: brief` (daily brief only)
- Score 5–6 → `disposition: background` (archived, not deleted)
- Score < 5 → `disposition: rejected` (logged, not sent to Telegram)
- **Timeout:** LLM call capped at **120 seconds** with `subprocess.run(timeout=125)`
- **Fallback:** If LLM fails, all items default to score 7, disposition `brief`, with `reason_selected: "fallback scoring — LLM unavailable"`
- **No `[SILENT]` suppression** — artifact generation proceeds regardless of signal volume

---

## 7. Artifact Generation

All files are written to `/root/workspace/my-wiki/`.

### 7.1 Required artifacts

| Path | Content | Always written? |
|---|---|---|
| `raw/daily-inbox/YYYY-MM-DD.md` | Markdown digest of inbox signals | ✅ (even if empty: "No inbox signals today.") |
| `raw/daily-inbox/YYYY-MM-DD.json` | JSON array of all inbox items (schema §5) | ✅ |
| `raw/rejected/YYYY-MM-DD.md` | Markdown log of rejected items | ✅ (even if empty: "No rejections.") |
| `raw/rejected/YYYY-MM-DD.json` | JSON array of rejected items (schema §5) | ✅ |
| `wiki/daily-brief-YYYY-MM-DD.md` | Grouped daily brief by platform | ✅ |
| `wiki/log.md` | Entry: `## [YYYY-MM-DD HH:MM] ARGUS | N brief signals, M inbox signals` | ✅ |

### 7.2 Optional artifacts

| Path | Content | Written when |
|---|---|---|
| `wiki/knowledge-graph/YYYY-MM-DD.json` | Entities, tags, relationship graph for Athena | When inbox ≥ 3 items |
| `wiki/signals/YYYY-MM-DD.md` | Individual signal file | When enabled in config |
| `wiki/signals/index.md` | Signal index update | When signals written |

### 7.3 Git sync

After all artifacts are written:

```bash
cd /root/workspace/my-wiki
git add raw/daily-inbox/YYYY-MM-DD.md raw/daily-inbox/YYYY-MM-DD.json \
       raw/rejected/YYYY-MM-DD.md raw/rejected/YYYY-MM-DD.json \
       wiki/daily-brief-YYYY-MM-DD.md wiki/log.md
git commit -m "Argus Brief YYYY-MM-DD"
git push origin main
```

- Git failure logs a warning and continues — artifacts are NOT erased
- Git is not retried in this run; the next run will pick up any unpushed changes

---

## 8. Telegram Delivery

### 8.1 Direct API only

Telegram is sent via `requests.post` directly to `https://api.telegram.org/bot{TOKEN}/sendMessage`.  
**Do NOT use `hermes chat` for Telegram delivery.**

### 8.2 Message splitting

- Telegram hard limit: **4096 characters per message**
- Split algorithm: deterministic — accumulate items until adding the next would exceed 3900 chars (leaving 196 for header/footer)
- Multiple messages are sent sequentially
- Each message_id is logged in the run log: `Telegram message_id: {id}`

### 8.3 Content

```
[ARGUS BRIEF YYYY-MM-DD]
{N} signals — {M} inbox, {B} background, {R} rejected
Generated: {HH:MM UTC}

--- X ---
[TIER1 signal items grouped by platform]
--- Reddit ---
...
--- Background ---
[Background items listed briefly]
```

### 8.4 No signal behavior

- If `disposition: brief` items == 0, send:  
  `[ARGUS BRIEF YYYY-MM-DD] No high-signal posts today. System nominal.`
- This message is ALWAYS sent (not suppressed) unless config has `suppress_empty_brief: true`

### 8.5 Telegram retry

- On Telegram failure, retry exactly **once** after 3 seconds
- If retry fails, log: `Telegram delivery failed after retry — message_id: None` and continue
- Never let Telegram failure prevent artifact generation

---

## 9. Platform Grouping

The daily brief and Telegram message group items by `source_platform`, then `source_tier`. Order:

1. **X** — X/Twitter posts (TIER1 first, then TIER2, TIER3)
2. **Reddit** — subreddit aggregations
3. **Substack** — newsletter posts
4. **YouTube** — video content
5. **GitHub** — repository activity
6. **Events / Luma** — event announcements
7. **RSS / Web** — generic web feeds
8. **Background** — items with `disposition: background`

---

## 10. Configuration

All configuration via environment variables or a `config.json` file next to the script.

```json
{
  "wiki_path": "/root/workspace/my-wiki",
  "telegram_chat_id": "6127567978",
  "model_name": "google/gemini-2.0-flash-001",
  "provider": "openrouter",
  "llm_timeout": 120,
  "feed_timeout": 30,
  "max_threads": 10,
  "suppress_empty_brief": false,
  "knowledge_graph_enabled": true,
  "knowledge_graph_min_items": 3
}
```

**API keys** (Telegram bot token, optional OpenRouter key) are read from `/root/.hermes/.env` directly by the script — not hardcoded. Use `os.environ` with fallback to `.env` file.

---

## 11. Failure Modes & Exit Codes

| Exit code | Meaning |
|---|---|
| 0 | Success — brief generated, Telegram delivered |
| 1 | Partial failure — artifacts written, Telegram failed after retry |
| 2 | Pipeline failure — no artifacts written (all feeds failed or fatal config error) |

**Never exit 2 if at least one feed succeeded.** Exit 1 if Telegram failed but artifacts were written. Exit 0 on full success.

**Failure log:** Every run writes `/tmp/argus-canonical-errors.json` with structure:
```json
{
  "run_at": "<ISO8601>",
  "exit_code": 0,
  "feed_errors": [],
  "telegram_error": null,
  "git_error": null,
  "llm_fallback": false
}
```

---

## 12. Dependencies

- Python 3.12+ (standard library only for core logic)
- `requests` (already available in `/root/.hermes/hermes-agent/venv`)
- `concurrent.futures` (stdlib)
- `xml.etree.ElementTree` (stdlib)
- `json`, `datetime`, `uuid` (stdlib)

---

## 13. Cron Migration Checklist

**Pre-requisite:** Manual dry run MUST pass all checks before cron is updated.

### 13.1 Manual dry run checklist

- [ ] Script exists at `/root/.hermes/scripts/argus-daily-brief-canonical.py`
- [ ] `bash -n argus-daily-brief-canonical.py` → syntax OK
- [ ] Run with `--dry-run` flag (if implemented) or run with test date
- [ ] Verify `raw/daily-inbox/YYYY-MM-DD.md` and `.json` written
- [ ] Verify `raw/rejected/YYYY-MM-DD.md` and `.json` written
- [ ] Verify `wiki/daily-brief-YYYY-MM-DD.md` written with nonzero content
- [ ] Verify `wiki/log.md` entry appended
- [ ] Verify Telegram message_id returned from `sendMessage` API
- [ ] Verify no secrets printed to stdout/log
- [ ] Verify Hermes PID unchanged (no PID race)
- [ ] Verify Athena can read output files
- [ ] Verify git commit pushed to `origin main`

### 13.2 Cron update command

```bash
/heremes/hermes-agent/venv/bin/hermes cron edit 42cd1df992e7 \
  --prompt "bash /root/.hermes/scripts/argus-daily-brief-canonical.py"
```

---

## 14. Rollback

**Current cron job:** `argus-daily-brief` (id `42cd1df992e7`)  
**Active script:** `argus-daily-brief-v3.py` at `/root/.hermes/scripts/argus-daily-brief-v3.py`

### To revert to v3

```bash
/heremes/hermes-agent/venv/bin/hermes cron edit 42cd1df992e7 \
  --prompt "python3 /root/.hermes/scripts/argus-daily-brief-v3.py"
```

### Files to inspect after failure

| File | What to check |
|---|---|
| `/tmp/argus-canonical-errors.json` | Structured failure reasons |
| `/tmp/argus-brief.log` | Full run stdout/stderr |
| `/root/workspace/my-wiki/wiki/log.md` | Last ARGUS entry, check timestamp |
| `/root/workspace/my-wiki/raw/daily-inbox/YYYY-MM-DD.md` | Whether inbox was written before failure |
| `/dev/shm/hermes-gateway_err.log` | Whether Hermes crashed during run |
| `/root/.hermes/cron/output/42cd1df992e7/*.md` | Cron's own output capture |

---

## 15. Implementation Recommendation Summary

**Create a new single-file Python script** at `/root/.hermes/scripts/argus-daily-brief-canonical.py`. Do not patch v3 and do not create a shell wrapper.

**Why not patch v3:** v3's architecture is tightly coupled to Tavily, lacks TIER classification, has no git sync, and has no multi-schema output. The patches required would effectively replace most of the file.

**Why not shell wrapper:** Shell is adequate for feed fetching but poor for JSON schema normalization, date parsing, entity extraction, and structured logging. The complexity in this runner is in the data pipeline, not the process orchestration.

**Next step after this spec:** Author `argus-daily-brief-canonical.py`, then run the manual dry-run checklist (§13.1) before updating cron.