# Hermes Gateway — Zo User Service Migration Runbook

**Date:** 2026-05-15  
**Status:** Planning only — do not apply yet (but migration sequence CANONICAL and ready to execute)  
**Goal:** Migrate Hermes gateway from nohup/bashrc to managed Zo User Service

---

## 1. Current Failure Evidence

### What happened

After a Zo sandbox restart, the Hermes gateway failed to restart automatically.

### Evidence collected

| Symptom | Value |
|---|---|
| Stale PID file | `/root/.hermes/gateway.pid` contained PID 44 (dead process) |
| Error pattern | `ERROR gateway.run: PID file race lost to another gateway instance. Exiting.` — repeated every ~20s |
| Error log | `/dev/shm/hermes-gateway_err.log` — 21 lines of PID race errors, last modified `2026-05-15 21:55:41` |
| Hermes process | NOT running at session start (PID 44 dead, no live replacement) |
| Telegram | **No delivery** during the outage window |
| Resolution | Manual: removed stale `gateway.pid`, started gateway via nohup, Telegram confirmed live (message_id: 478) |

### Root cause

The nohup/bashrc auto-start script runs on every new shell session. After a sandbox restart:
1. The old Hermes process dies
2. The bashrc script runs `rm -f /root/.hermes/gateway.pid` then starts a new nohup instance
3. But if the gateway.pid from a *previous* boot somehow survived (or a race condition occurred), the new gateway finds the stale PID and exits immediately
4. No watchdog restarts it — Telegram goes silent until manual intervention

The nohup/bashrc method has **no process supervision**, **no automatic restart on crash**, and **no health check**.

---

## 2. Current Launch Method

### Active process

```
PID:      1317
Command:  /root/.hermes/hermes-agent/venv/bin/python3 /root/.hermes/hermes-agent/venv/bin/hermes gateway run
Started:  2026-05-15 22:33:13 (14 minutes ago as of write)
Parent:   nohup (orphaned, respawned by init)
```

### Launch command (from `/root/.bashrc` lines 32–34)

```bash
rm -f /root/.hermes/gateway.pid
nohup /root/.hermes/hermes-agent/venv/bin/hermes gateway run > /root/logs/hermes-gateway.log 2>&1 &
```

### Environment

- Launched without explicit `cd` — working directory is `/root`
- No environment variables passed at launch (HERMES reads `.env` internally via Python dotenv)
- No process supervision — crash = silence until manual restart

### Key paths

| Purpose | Path |
|---|---|
| Hermes binary | `/root/.hermes/hermes-agent/venv/bin/hermes` |
| Config | `/root/.hermes/config.yaml` |
| Memory (Donny) | `/root/.hermes/memories/MEMORY.md` |
| Memory (User) | `/root/.hermes/memories/USER.md` |
| Session state | `/root/.hermes/state.db` |
| Gateway state | `/root/.hermes/gateway_state.json` |
| Channel directory | `/root/.hermes/channel_directory.json` |
| Gateway PID | `/root/.hermes/gateway.pid` (currently absent — cleaned) |
| Cron definitions | `/root/.hermes/cron/` |
| Skills | `/root/.hermes/skills/` |

### Log paths

| Log | Path | Status |
|---|---|---|
| stdout (current) | `/dev/shm/hermes-gateway.log` | 0 bytes — empty |
| stderr (current) | `/dev/shm/hermes-gateway_err.log` | 1596 bytes — pre-restart error history |
| stdout (old bashrc) | `/root/logs/hermes-gateway.log` | 0 bytes |
| stderr (old bashrc) | `/root/logs/hermes-gateway.err` | 8629 bytes — May 14 errors |

> Note: After the PID cleanup restart, logs appear to be going to `/dev/shm/hermes-gateway.log` but it's empty. The Hermes process is running (PID 1317 confirmed alive) — logs may be buffered or going elsewhere.

---

## 3. Proposed Zo User Service

### Service definition

```json
{
  "label": "hermes-gateway",
  "mode": "process",
  "entrypoint": "/root/.hermes/hermes-agent/venv/bin/hermes",
  "args": ["gateway", "run"],
  "workdir": "/root/.hermes",
  "env_vars": {
    "HERMES_CONFIG_PATH": "/root/.hermes/config.yaml",
    "HERMES_MEMORY_PATH": "/root/.hermes/memories",
    "HERMES_LOG_PATH": "/root/logs/hermes-gateway.log"
  },
  "log_file": "/root/logs/hermes-gateway.log"
}
```

### Startup command

```
/root/.hermes/hermes-agent/venv/bin/hermes gateway run
```

### Working directory

```
/root/.hermes
```

### Environment loading strategy (AVOID sourcing .env)

**Problem:** `/root/.hermes/.env` contains bare API key values on individual lines that execute as shell commands when the file is `source`-d directly (e.g., `tvly-dev-...` and `sk-proj-...` treated as executable commands). Safe for `grep`, dangerous for `source`.

**Solution:** Pass environment variables via `env_vars` in the service definition. The Hermes binary reads `.env` internally via Python's `python-dotenv` library, which parses values safely without executing them as shell commands. The service definition only needs to inject the paths and behavioral flags Hermes needs at startup.

Required env vars to pass explicitly (from Settings → Advanced, not from `.env` directly):
- `HERMES_CONFIG_PATH=/root/.hermes/config.yaml`
- `HERMES_MEMORY_PATH=/root/.hermes/memories`
- `HERMES_LOG_PATH=/root/logs/hermes-gateway.log`

The `TELEGRAM_BOT_TOKEN` and `TELEGRAM_HOME_CHANNEL` are read by Hermes from its own `.env` via Python dotenv — no action needed in the service definition for these.

### Restart behavior

- **Auto-restart on crash** — managed by Zo's supervisor
- **No stale PID on restart** — supervisor handles process lifecycle, gateway.pid management is handled by the Hermes binary itself, not by an external script

### Health check method

```bash
ps aux | grep -E "hermes.*gateway.*run" | grep -v grep
# Expected: one line showing the hermes process
```

Or check via Hermes CLI:
```bash
/root/.hermes/hermes-agent/venv/bin/hermes status
```

### Telegram verification method

```bash
# Use grep to extract token, do NOT source the full .env
BOT_TOKEN=$(grep '^TELEGRAM_BOT_TOKEN=' /root/.hermes/.env | cut -d= -f2)
CHAT_ID=$(grep '^TELEGRAM_HOME_CHANNEL=' /root/.hermes/config.yaml | cut -d: -f2 | tr -d " '")
curl -s "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
  -d "chat_id=${CHAT_ID}" \
  -d "text=Zo service test $(date +%H:%M:%S)" | python3 -c \
  "import sys,json; d=json.load(sys.stdin); print('ok:', d.get('ok'), 'message_id:', d.get('result',{}).get('message_id'))"
```

Expected: `ok: True message_id: <number>`

---

## 4. Migration Procedure — NO DUAL GATEWAY

> **Critical constraint:** At no point should PID 1317 and a new supervised Hermes process both poll the Telegram gateway with the same bot token. Conflicting long-polls on the same bot token cause Telegram to deliver the same update to both processes — or drop updates entirely.

---

### Phase 0 — Snapshot / Checkpoint

**Do this first, before any changes.**

```bash
# 1. Confirm current Hermes is running
ps aux | grep -E "hermes.*gateway.*run" | grep -v grep
# Expected: one line, PID 1317

# 2. Verify Telegram is live (safe grep-only approach, no source)
BOT_TOKEN=$(grep '^TELEGRAM_BOT_TOKEN=' /root/.hermes/.env | cut -d= -f2)
CHAT_ID=$(grep '^TELEGRAM_HOME_CHANNEL=' /root/.hermes/config.yaml | cut -d: -f2 | tr -d " '")
curl -s "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
  -d "chat_id=${CHAT_ID}" \
  -d "text=Snapshot check $(date +%H:%M:%S)" \
  | python3 -c "import sys,json; d=json.load(sys.stdin); print('Telegram:', d.get('ok'), 'msg_id:', d.get('result',{}).get('message_id'))"

# 3. Commit current hermes state to git
cd /root/.hermes && git add -A && git commit -m "checkpoint: pre-service-migration-$(date +%Y%m%d-%H%M%S)"

# 4. Document current PID
echo "Current Hermes PID: $(pgrep -f 'hermes gateway run')" > /root/.hermes/checkpoints/pre-migration.txt
```

**Exit criteria before proceeding:** Telegram delivers a message ID. If it fails, abort and diagnose.

---

### Preferred Path — DO NOT USE (not supported by current Zo API)

> **DEPRECATED — No deferred-start available.**  
> `register_user_service` starts processes immediately. There is no `active=false`, `disabled`, `deferred`, or similar field in the current API. Tested 2026-05-15: `sleep 300` registered as process-only service → PID appeared within 3 seconds, no defer mechanism exists.  
> **Use Fallback Path only.**

#### Phase 1 — Snapshot

Same as Phase 0 above.

#### Phase 2 — Register service in disabled/not-started state

**[NOT POSSIBLE]** Skipping. `register_user_service` has no disabled/deferred-start option.

---

### Fallback Path — CANONICAL ✅

> **Confirmed working path.** `register_user_service` starts processes immediately, so old PID 1317 must be stopped before registration. No dual-gateway risk since zero Hermes processes will exist during the transition.

#### Phase 1 — Snapshot

Same as Phase 0 above.

#### Phase 2 — Save old nohup restart command for rollback

```bash
# Record the rollback command exactly as it appears in bashrc
echo "Rollback command: nohup /root/.hermes/hermes-agent/venv/bin/hermes gateway run > /root/logs/hermes-gateway.log 2>&1 &" > /root/.hermes/checkpoints/rollback-command.txt
cat /root/.hermes/checkpoints/rollback-command.txt
```

#### Phase 3 — Gracefully stop old nohup PID 1317 first

```bash
# 1. Confirm old PID
echo "Stopping Hermes PID: $(pgrep -f 'hermes gateway run')"

# 2. Kill old nohup Hermes
kill $(pgrep -f 'hermes gateway run')

# 3. Verify no Hermes gateway process is running
sleep 3
ps aux | grep -E "hermes.*gateway.*run" | grep -v grep
# Expected: empty — no Hermes running at all
```

#### Phase 4 — Verify no Hermes gateway process is running

```bash
ps aux | grep -E "hermes.*gateway.*run" | grep -v grep
# MUST be empty before proceeding
```

#### Phase 5 — Remove stale gateway.pid if needed

```bash
ls -la /root/.hermes/gateway.pid 2>/dev/null && rm -f /root/.hermes/gateway.pid || echo "No gateway.pid to clean"
```

#### Phase 6 — Immediately register hermes-gateway as Zo User Service

```bash
# Register and start immediately — no old process exists, so no dual-gateway risk
# Using Zo's register_user_service tool:
#   label:      hermes-gateway
#   mode:       process
#   entrypoint: /root/.hermes/hermes-agent/venv/bin/hermes
#   args:       ["gateway", "run"]
#   workdir:    /root/.hermes
#   env_vars:   {
#     "HERMES_CONFIG_PATH": "/root/.hermes/config.yaml",
#     "HERMES_MEMORY_PATH": "/root/.hermes/memories",
#     "HERMES_LOG_PATH":    "/root/logs/hermes-gateway.log"
#   }
```

#### Phase 7 — Verify service PID is live

```bash
sleep 5
ps aux | grep -E "hermes.*gateway.*run" | grep -v grep
# Expected: one supervised Hermes PID (not 1317)
```

#### Phase 8 — Verify Telegram sendMessage returns message ID

```bash
BOT_TOKEN=$(grep '^TELEGRAM_BOT_TOKEN=' /root/.hermes/.env | cut -d= -f2)
CHAT_ID=$(grep '^TELEGRAM_HOME_CHANNEL=' /root/.hermes/config.yaml | cut -d: -f2 | tr -d " '")
curl -s "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
  -d "chat_id=${CHAT_ID}" \
  -d "text=Service check $(date +%H:%M:%S)" \
  | python3 -c "import sys,json; d=json.load(sys.stdin); print('Telegram:', d.get('ok'), 'msg_id:', d.get('result',{}).get('message_id'))"
```

**Exit criteria:** `ok: True` with a numeric `message_id`.

#### Phase 9 — Verify getUpdates confirms delivery

```bash
sleep 2
curl -s "https://api.telegram.org/bot${BOT_TOKEN}/getUpdates" \
  | python3 -c "import sys,json; d=json.load(sys.stdin); msgs=[m['message'] for m in d.get('result',[]) if 'message' in m]; print('Messages in queue:', len(msgs)); [print(f'  id={m[\"message_id\"]} text={m[\"text\"][:50]}') for m in msgs[-3:] if 'text' in m]"
```

#### Phase 10 — Remove bashrc auto-start lines 32-34

**Only do this after Phases 8 and 9 both pass.**

```bash
# Edit /root/.bashrc — comment out lines 32-34:
# # Auto-start Hermes gateway
# rm -f /root/.hermes/gateway.pid
# nohup /root/.hermes/hermes-agent/venv/bin/hermes gateway run > /root/logs/hermes-gateway.log 2>&1 &
```

---

### Rollback

If the supervised service fails verification at any point:

#### Step 1 — Delete or disable the service

```bash
# Using Zo's service management:
# delete_user_service("hermes-gateway")
```

#### Step 2 — Restart the old nohup command using the saved rollback command

```bash
# Read the saved rollback command
cat /root/.hermes/checkpoints/rollback-command.txt

# Execute it
nohup /root/.hermes/hermes-agent/venv/bin/hermes gateway run > /root/logs/hermes-gateway.log 2>&1 &

# Verify
sleep 5
ps aux | grep -E "hermes.*gateway.*run" | grep -v grep
```

#### Step 3 — Verify Telegram is restored

```bash
BOT_TOKEN=$(grep '^TELEGRAM_BOT_TOKEN=' /root/.hermes/.env | cut -d= -f2)
CHAT_ID=$(grep '^TELEGRAM_HOME_CHANNEL=' /root/.hermes/config.yaml | cut -d: -f2 | tr -d " '")
curl -s "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
  -d "chat_id=${CHAT_ID}" \
  -d "text=Rollback verification $(date +%H:%M:%S)" \
  | python3 -c "import sys,json; d=json.load(sys.stdin); print('Telegram:', d.get('ok'), 'msg_id:', d.get('result',{}).get('message_id'))"
```

---

### Which path to use

| Condition | Path |
|---|---|
| `register_user_service` supports `active=false` or deferred-start | **Preferred path** — zero downtime, no gap |
| `register_user_service` starts immediately, no defer option | **Fallback path** — old process stopped first, brief gap |
| Not sure | Test with a throwaway service registration first to observe behavior |

To test deferred-start capability without affecting Hermes:
1. Register a dummy service with the same entrypoint but different config
2. Observe whether it auto-starts or waits
3. Delete the dummy and proceed with the real migration

---

## 5. Rollback

### How to disable the service

```bash
# Via Zo's service management:
# delete_user_service("hermes-gateway")
# This stops the supervised process but does NOT delete the Hermes installation
```

### How to restart the old nohup method (emergency fallback)

```bash
# 1. Remove gateway.pid if it exists (stale PID from failed service)
rm -f /root/.hermes/gateway.pid

# 2. Restore bashrc auto-start (uncomment lines 32-34 in /root/.bashrc if previously disabled)

# 3. Manually start the old way
nohup /root/.hermes/hermes-agent/venv/bin/hermes gateway run > /root/logs/hermes-gateway.log 2>&1 &

# 4. Verify
sleep 5
ps aux | grep -E "hermes.*gateway.*run" | grep -v grep
```

### How to restore previous state

1. `cd /root/.hermes && git log --oneline` — find the pre-migration commit
2. `cd /root/.hermes && git checkout <pre-migration-commit> -- scripts/hermescheck.py` — restore the old hermescheck.py
3. Restore any other files as needed
4. Rollback does NOT affect the workspace wiki — the runbook itself serves as documentation of what was changed

---

## 6. Open Issue — .env Shell Safety

### Problem

`/root/.hermes/.env` contains lines like:

```
tvly-dev-[REDACTED]
sk-proj-[REDACTED]
```

These are bare values with no `VAR=` prefix. When the file is `source`-d directly in bash, the shell interprets the first line as a command name and tries to execute it — producing errors like:
```
/root/.hermes/.env: line 415: tvly-dev-[REDACTED]: command not found
```

### Why Hermes still works

Hermes uses Python's `python-dotenv` library to read `.env`, which parses the file safely without executing shell commands. Hermes is unaffected.

### Why this matters for the migration

Any script that does `source /root/.hermes/.env` will produce spurious errors (non-fatal but noisy). The hermescheck.py script already uses `grep` + `cut` to extract values — this is safe.

### Recommended fix (outside scope of this task)

**Option A — Fix the .env file (low risk):**
Ensure all lines in `/root/.hermes/.env` follow `KEY=value` format. Uncomment or prefix the bare API key lines with a valid variable name. Test with `python3 -c "from dotenv import dotenv_values; print(dotenv_values('/root/.hermes/.env'))"`.

**Option B — Use Zo Secrets (recommended):**
Store sensitive values in Zo Settings → Advanced → Secrets. These are injected as real environment variables into the service process without any file sourcing risk.

**Option C — Parse-only access:**
Write a Python helper that reads `.env` using `python-dotenv` and exposes values via a JSON file or subprocess — scripts access the JSON, not the raw `.env`.

> **This task does NOT fix the .env file. The migration plan uses the safe grep/cut approach throughout.**

---

## 7. Security Constraints

### Never print secrets to stdout, logs, or chat

When extracting secrets for use in service env_vars or health check commands:
- Use `grep` + `cut` to extract values — assign directly to a variable or env var field
- **Never** `echo`, `print`, or `cat` the actual secret value
- Report only the **name** of the secret (e.g., "TELEGRAM_BOT_TOKEN"), never its value

Correct approach:
```bash
BOT_TOKEN=$(grep '^TELEGRAM_BOT_TOKEN=' /root/.hermes/.env | cut -d= -f2)
# BOT_TOKEN is now set — use it, don't print it
```

Incorrect approach:
```bash
# DO NOT do this:
cat /root/.hermes/.env | grep TELEGRAM_BOT_TOKEN   # prints the actual secret value
echo $TELEGRAM_BOT_TOKEN                            # prints the actual secret value
```

### Never source .env wholesale

The `/root/.hermes/.env` file contains bare values that execute as shell commands when sourced. Always use `grep`/`cut` to extract specific values, or let Hermes read `.env` directly via Python dotenv (which is safe).

### Env vars in service definition — secret names only

When registering the service, env_vars like `HERMES_CONFIG_PATH`, `HERMES_MEMORY_PATH`, and `HERMES_LOG_PATH` are path-only values — safe to reference literally. Do not embed bare secret values in the service definition. Hermes reads sensitive tokens via its own internal dotenv loading.

### Telegram verification — token name only in output

When reporting Telegram verification results, report `ok: True` and `message_id:` only. Never include the bot token or chat ID in any output.

---

## 8. Rollback Incident Logging

If rollback is triggered at any point, append a rollback incident entry to the wiki log immediately. Do not skip this — the log is the authoritative record of what happened and why.

### Required rollback log entry fields

```
## [YYYY-MM-DD HH:MM] ROLLBACK | hermes-gateway service migration
- **Failed step:** <phase name or number>
- **Failure reason:** <what caused the rollback>
- **Service ID if created:** <svc_... if register_user_service was called, otherwise none>
- **Orphaned supervised process found/killed:** YES/NO — <details>
- **Old nohup command restored:** YES/NO
- **Telegram verification after rollback:** ok: <bool> message_id: <number>
- **Remaining blocker:** <what still needs to be resolved before retry>
- **Bashrc lines 32-34:** NOT removed (rollback only fires if migration fails)
```

### When to log

- Immediately after `delete_user_service` is called
- After old nohup command is re-executed
- After Telegram verification confirms restoration or failure

### Example rollback log entry

```
## [2026-05-15 22:50] ROLLBACK | hermes-gateway service migration
- **Failed step:** Phase 8 — Telegram sendMessage returned ok: False
- **Failure reason:** Hermes supervised process was not polling Telegram (getUpdates returned 0 msgs)
- **Service ID if created:** svc_DK7pyTxqEVY
- **Orphaned supervised process found/killed:** YES — PID 1444 killed manually
- **Old nohup command restored:** YES — nohup /root/.hermes/hermes-agent/venv/bin/hermes gateway run > /root/logs/hermes-gateway.log 2>&1 &
- **Telegram verification after rollback:** ok: True message_id: 481
- **Remaining blocker:** Hermes supervised process not gettingUpdates from Telegram — investigate env_vars HERMES_CONFIG_PATH not being read correctly
- **Bashrc lines 32-34:** NOT removed
```

### Rollback rules

1. **Always verify Telegram after rollback** — do not assume it is working
2. **Never remove bashrc lines after rollback** — the nohup method is still active and must remain functional
3. **Always kill orphaned supervised process** — `delete_user_service` removes the definition but the process may survive; use `pkill -f 'hermes gateway run'` to ensure cleanup
4. **Do not re-attempt migration same session** — document the blocker, resolve it, then retry in a new session

---

## 9. Quick Reference — Key Commands

```bash
# Check Hermes is running
ps aux | grep -E "hermes.*gateway.*run" | grep -v grep

# Check PID file
cat /root/.hermes/gateway.pid

# View recent logs
tail -30 /root/logs/hermes-gateway.log

# Check service status (Zo tool)
list_user_services

# Telegram health check (safe, no source)
BOT_TOKEN=$(grep '^TELEGRAM_BOT_TOKEN=' /root/.hermes/.env | cut -d= -f2)
CHAT_ID=$(grep '^TELEGRAM_HOME_CHANNEL=' /root/.hermes/config.yaml | cut -d: -f2 | tr -d " '")
curl -s "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
  -d "chat_id=${CHAT_ID}" -d "text=health check $(date +%H:%M:%S)" \
  | python3 -c "import sys,json; d=json.load(sys.stdin); print('ok:', d.get('ok'), 'id:', d.get('result',{}).get('message_id'))"

# Hermes check script (includes PID cleanup)
python3 /root/.hermes/scripts/hermescheck.py
```