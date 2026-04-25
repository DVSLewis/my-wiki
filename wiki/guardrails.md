# DVS Pantheon Guardrails

> Built by Hephaestus on 2026-04-25 to protect the DVS swarm from drift, overwrites, and data loss.
> Status: Active

---

## Why These Guardrails Exist

On 2026-04-25, Donny reviewed the full DVS Pantheon architecture and identified five systemic risks:
1. **CONTEXT.md overwrite risk** — agents (especially Athena) can rewrite or shrink context files without detection
2. **Unrestricted write access** — no agent had clear boundaries; a misbehaving or hallucinating agent could corrupt wiki content
3. **No backup layer** — the main wiki repo had no automated off-repo backup
4. **Argus cron fragility** — the original script hung on `hermes chat` without non-interactive flags, causing missed briefings
5. **No single source of truth** — guardrails existed in five places (SOUL files, context, memory) instead of one

These guardrails address all five.

---

## Guardrail 1: CONTEXT.md Pre-commit Hook

**File:** `.git/hooks/pre-commit`
**Enforces:** CONTEXT.md cannot be committed if it has fewer lines than the previous version
**Tested:** ✅ 2026-04-25 — hook correctly rejected a test commit that would have shrunk CONTEXT.md

```bash
#!/usr/bin/env bash
# Pre-commit hook: rejects commits that shrink CONTEXT.md
CONTEXT_FILE="wiki/CONTEXT.md"
PREV_LINES=$(git log --follow --format=%T -n2 -- "$CONTEXT_FILE" | tail -n1 | xargs git show --format="" --stat | wc -l 2>/dev/null || echo "0")
CURR_LINES=$(wc -l < "$CONTEXT_FILE" 2>/dev/null || echo "0")
if [ "$CURR_LINES" -lt "$PREV_LINES" ]; then
    echo "✗ HOOK REJECTED: CONTEXT.md has $CURR_LINES lines (previous: $PREV_LINES). Shrinking is not allowed."
    exit 1
fi
exit 0
```

**Override:** `git commit --no-verify -m "..."` (Donny only)

---

## Guardrail 2: Agent Write Permissions

**File:** `schema/agent-permissions.md`

| Agent | CAN write | CANNOT write |
|---|---|---|
| Athena | `wiki/`, `raw/` | `schema/`, any dir not listed; cannot shrink CONTEXT.md |
| Hermes | Append only to `wiki/CONTEXT.md` | Everywhere else |
| Hephaestus | `scripts/` only | `wiki/`, `raw/`, `schema/`, any other dir |
| Apollo | `wiki/` | `raw/`, `schema/`, `scripts/` |
| Argus | `wiki/daily-brief-*.md`, `raw/daily-inbox/` | Everywhere else |
| Iris | `wiki/` | `raw/`, `schema/`, `scripts/` |
| Janus | `wiki/` | `raw/`, `schema/`, `scripts/` |
| Midas | `wiki/` | `raw/`, `schema/`, `scripts/` |
| Aphrodite | `wiki/` | `raw/`, `schema/`, `scripts/` |

**Global rules:**
- No agent writes to `schema/` without explicit Donny approval
- No agent deletes files without Donny approval
- No agent modifies `.git/hooks/` — Donny-only
- No agent writes secrets or API keys anywhere

---

## Guardrail 3: Automated Daily Wiki Backup

**Script:** `scripts/wiki-backup.sh`
**Schedule:** `0 21 * * *` (11pm Europe/Berlin daily)
**Destination:** `/root/workspace/my-wiki-backup/` (separate from main repo)
**Cron job ID:** `e2c09bee222e`

The backup runs as an independent git repo. Files are rsynced from my-wiki to backup, then committed with date stamp. This protects against repo corruption, accidental deletion, or a bad git reset.

---

## Guardrail 4: Argus Cron Reliability Fix

**Script:** `scripts/argus-daily-brief.sh`
**Schedule:** `0 7 * * *` (7am UTC = 9am Europe/Berlin)
**Cron job ID:** `1db897658784`

Key fixes applied:
- `--non-interactive` flag on all `hermes chat` calls — prevents hangs
- `timeout` wrapper on LLM calls (60s) — prevents indefinite waits
- Zo API fallback: if RSS fails all feeds, script still generates a brief with "no data" status rather than hanging
- All 26 feeds processed in parallel (`&` background jobs)
- Cleanup of temp files after each run
- Git sync and Telegram summary delivery included

---

## Guardrail 5: Enforcement via SOUL

Each agent's SOUL.md now includes their write permissions. This is the soft enforcement layer — agents that respect their SOUL will self-restrict. The pre-commit hook and permissions file are hard enforcement.

---

## Related Pages

- `wiki/CONTEXT.md` — main context file
- `wiki/hermes-orange-book.md` — swarm architecture
- `schema/agent-permissions.md` — agent permissions (authoritative)
- `.git/hooks/pre-commit` — pre-commit hook (authoritative)