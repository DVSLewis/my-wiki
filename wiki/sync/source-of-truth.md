# DVS Source of Truth — Authority Map

**Version:** 1.0 — 2026-05-16
**Status:** VERIFY REQUIRED — refresh authority claims at each session start

---

## Authority Map

| System / Layer | Canonical Location | Type | Public Sync? | Owner |
|---|---|---|---|---|
| Live Zo state | `/root/workspace/` | live | NO | Donny / Zo |
| GitHub wiki | `DVSLewis/my-wiki` (main) | canonical | YES | Hermes / Argo |
| Hermes repo | `DVSLewis/hermes` (master) | canonical | partial | Hermes / Argo |
| Hermes runtime | `/root/.hermes/` | live | NO | Hermes service |
| Hermes config | `/root/.hermes/config.yaml` | live | NO | Hermes service |
| Hermes secrets | `/root/.hermes/.env` | live | NO | — never sync — |
| dvs-private | `/root/workspace/dvs-private/` | live | NO | — never sync — |
| ChatGPT project | VERIFY REQUIRED | snapshot | VERIFY | Donny |
| Claude project | VERIFY REQUIRED | snapshot | VERIFY | Donny |
| Telegram (DVS_HermesBot) | live | conduit | NO | Hermes |
| Zo logs (Loki) | `http://localhost:3100` | live | NO | Zo |

---

## File Ownership — Which File Owns Which Truth

### Persistent State Files

| File | Authority Over | Kind |
|---|---|---|
| `wiki/CONTEXT.md` | Current session priorities, active agents, infrastructure state | SOLE source |
| `wiki/SOUL.md` | Agent identity, personality, behavior rules | SOLE source |
| `wiki/log.md` | Chronological record of all wiki actions, decisions, incidents | SOLE source |
| `wiki/references.md` | Project cross-references, file paths, system state | SOLE source |
| `hermes/config.yaml` | Hermes agent configuration, profiles, providers | SOLE source |
| `hermes/cron/jobs.json` | Scheduled job definitions, active cron ids | SOLE source |
| `hermes/profiles/*/SOUL.md` | Per-agent SOUL files | SOLE source |
| `hermes/profiles/*/.env` | Per-profile secrets (API keys, tokens) | SOLE source — NEVER sync |
| `hermes/scripts/*.py` | Executable agent scripts | SOLE source |
| `hermes/scripts/*.sh` | Executable shell scripts | SOLE source |
| `dvs-private/MANIFEST.md` | Swarm architecture, agent build order | SOLE source |
| `dvs-private/dvs-vision.md` | Vision, principles, constraints | SOLE source |

### Mirror Files (read from canonical, do not edit)

| File | Canonical Source | Mirror Purpose |
|---|---|---|
| `wiki/daily-brief-YYYY-MM-DD.md` | Argus canonical runner → raw/daily-inbox/ | Human-readable daily brief |
| `wiki/knowledge-synthesis-YYYY-MM-DD.md` | Athena synthesis → raw/daily-inbox/ | Human-readable synthesis |
| `wiki/signals/` | Argus canonical runner | Signal artifacts |
| `hermes/gateway.pid` | Hermes runtime (supervisor PID) | Runtime state — not committed |
| `hermes/logs/` | Hermes runtime | Runtime logs — not committed |

### Snapshot Files (periodic exports, may diverge from canonical)

| File | Source | Refresh Frequency | Stale Risk |
|---|---|---|---|
| ChatGPT project files | VERIFY REQUIRED | manual | HIGH |
| Claude project files | VERIFY REQUIRED | manual | HIGH |
| `/root/workspace/` (full tree) | Live Zo state | On-demand | LOW |

---

## Canonical vs Mirror vs Snapshot

### Canonical
- The **authoritative source** — owned, edited, and updated only in its canonical location
- All other copies are derived from it
- **Only the canonical location is committed to git**

### Mirror
- Automatically derived from canonical by an automated process
- May be overwritten at any time by the canonical's next update
- Should be readable but not manually edited
- **Commit to git only if it is the canonical source**

### Snapshot
- A point-in-time export that may have diverged from canonical
- May be manually refreshed
- Should be clearly labeled with export date
- **Commit to git as a snapshot with a date suffix**

---

## Private / Public Boundary

### NEVER sync publicly (private only)

- `/root/.hermes/.env` — all API keys, bot tokens, secrets
- `/root/.hermes/profiles/*/.env` — per-profile API keys
- `/root/workspace/dvs-private/` — all files
- `/root/workspace/my-wiki/wiki/.env` — any local env vars
- `gateway.pid` — runtime PID marker
- `hermes/logs/` — runtime logs
- `/root/workspace/my-wiki/scripts/bootstrap_cognee.py` — contains API keys
- Any file containing `sk-`, `tvly-`, `bot`, `token`, `secret`, `bearer` in content

### MAY sync publicly (audit each file)

- `wiki/` — documentation, runbooks, context, SOUL files
- `hermes/scripts/` — executable scripts (no secrets embedded)
- `hermes/profiles/*/SOUL.md` — agent identity (no API keys)
- `hermes/config.yaml` — config only (no secrets)
- `hermes/cron/jobs.json` — job definitions (no secrets)
- `raw/` — research outputs, signal data (no secrets)
- `runbooks/` — operational procedures

### Audit rule for any new file

```
Before committing any file to a public repo:
1. grep -iE "token|secret|key|password|api_key|sk-|bearer|bot" FILE
2. If matches > 0: do NOT commit; file belongs in private storage
3. If matches = 0: safe to commit with git add -f acknowledgment
```

---

## Zo Bot vs HermesBot vs Athena vs Hephaestus Responsibilities

### Zo Bot (this system)

**Authority over:** All Zo infrastructure, services, integrations, secrets management, workspace files.

**Responsibilities:**
- Read and write all workspace files
- Manage Zo User Services (Hermes gateway, autoclip-api, etc.)
- Configure integrations (Gmail, Google Calendar, Notion, Linear, etc.)
- Manage secrets via Settings > Advanced
- Create and manage zo.space routes
- Publish Zo Sites
- Orchestrate all other agents

**Does NOT do:**
- Send Telegram messages (HermesBot owns this)
- Execute Hermes cron jobs (Hermes owns this)
- Write agent SOUL files (agents own their own identity)

---

### HermesBot (DVS_HermesBot — Telegram interface)

**Authority over:** Telegram group communication, scheduled Argus/Athena cron jobs, Hermes gateway runtime.

**Responsibilities:**
- Receive and process Telegram messages via Hermes gateway
- Run Argus daily brief (via `argus-daily-brief` cron job id `42cd1df992e7`)
- Run Athena synthesis (via `athena-synthesis` cron job id `6f7eec24c6a0`)
- Run Athena weekly synthesis (via `athena-weekly-synthesis` cron job id `1b4dc234acf3`)
- Manage `hermes cron` job definitions
- Write to `hermes/gateway.pid` — runtime PID marker
- Push to `DVSLewis/hermes` git repo

**Does NOT do:**
- Access workspace files directly
- Manage Zo User Services
- Configure integrations

---

### Athena (Research & Synthesis Agent)

**Authority over:** Knowledge synthesis, inbox processing, wiki page creation.

**Responsibilities:**
- Read from `raw/daily-inbox/` — collects Argus brief outputs
- Write to `wiki/knowledge-synthesis-YYYY-MM-DD.md`
- Push wiki to `DVSLewis/my-wiki`
- Maintain `wiki/log.md` entries
- Run via HermesBot cron jobs (see above)
- Use `cognee` for knowledge graph management

**Does NOT do:**
- Send Telegram messages
- Manage Hermes runtime
- Execute shell scripts outside of cron context

---

### Hephaestus (Code & Infrastructure Agent)

**Authority over:** Code execution, infrastructure setup, bot and service maintenance.

**Responsibilities:**
- Write and maintain scripts in `/root/.hermes/scripts/`
- Manage Hermes service configuration
- Handle Git operations for Hermes repo
- Build and deploy services (autoclip-api, etc.)
- Maintain zo.space routes and assets

**Does NOT do:**
- Own Telegram communication
- Write SOUL files
- Manage Athena's knowledge synthesis

---

## Drift Definitions

### Session Drift
When a session ends without updating the required handoff files.

**Evidence:** `CONTEXT.md` last-modified date before session start time.
**Severity:** HIGH — next session has no context.
**Fix:** Run session-end checklist before closing.

### Git Drift
When local git state does not match remote after a session that made commits.

**Evidence:** `git status` shows unpushed commits.
**Severity:** MEDIUM — work is not backed up.
**Fix:** `git push` before ending session.

### Cron Drift
When a scheduled job's last-run time is unexpected.

**Evidence:** `hermes cron list` shows jobs with `last_run` before expected time or with non-`ok` status.
**Severity:** HIGH — automated pipeline is broken.
**Fix:** Diagnose via `hermescheck.py`, inspect `/dev/shm/hermes-gateway_err.log`.

### Agent SOUL Drift
When an agent's SOUL file in the wiki differs from its canonical location in `/root/.hermes/profiles/*/SOUL.md`.

**Evidence:** `diff wiki/SOUL.md /root/.hermes/profiles/*/SOUL.md` is non-empty.
**Severity:** HIGH — agent identity is split.
**Fix:** Copy canonical SOUL to wiki (or vice versa depending on which is authoritative).

### Secrets Drift
When a secret value changes but the `.env` file was not updated.

**Evidence:** API calls fail with auth errors; `.env` last-modified after last known good state.
**Severity:** HIGH — all dependent jobs fail.
**Fix:** Update `/root/.hermes/.env` with correct value via Zo Settings > Advanced.

### Service Drift
When a Zo User Service is not in RUNNING state.

**Evidence:** `list_user_services` shows service not RUNNING; `/dev/shm/hermes-gateway_err.log` has errors.
**Severity:** HIGH — HermesBot goes offline.
**Fix:** `service_doctor` → `update_user_service` with current entrypoint.

---

## Session Boundaries

### Session Start
1. Read `wiki/CONTEXT.md`
2. Read `wiki/log.md` (last 50 lines)
3. Run `hermescheck.py` — verify Hermes PID
4. `cd /root/.hermes && git log --oneline -3` — verify no unpushed commits

### Session End
1. Update `wiki/CONTEXT.md` if active work changed infrastructure state
2. `cd /root/.hermes && git push` — push all commits
3. `cd /root/workspace/my-wiki && git push` — push all wiki commits
4. Append session summary to `wiki/log.md`
5. Run `hermescheck.py` — confirm Hermes still alive

---

*Authority claims marked VERIFY REQUIRED must be confirmed against live state before use.*