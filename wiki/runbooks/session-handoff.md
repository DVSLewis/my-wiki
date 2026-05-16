# DVS Session Handoff Runbook

**Version:** 1.0 — 2026-05-16

Every session (interactive or scheduled) should follow this checklist to ensure continuity and prevent work from being lost or forgotten.

---

## Session Start Checklist

Complete these steps before beginning any work:

### 1. Read Required Files

```bash
# Always read these in order at the start of every session
cat /root/workspace/my-wiki/wiki/CONTEXT.md
tail -50 /root/workspace/my-wiki/wiki/log.md
```

### 2. Verify Hermes Service Status

```bash
# Check Hermes is running
ps aux | grep "hermes gateway run" | grep -v grep

# Check PID matches gateway.pid
cat /root/.hermes/gateway.pid

# Quick Telegram verification (optional)
BOT_TOKEN=$(grep '^TELEGRAM_BOT_TOKEN=' /root/.hermes/.env | cut -d= -f2)
CHAT_ID=$(grep '^TELEGRAM_HOME_CHANNEL=' /root/.hermes/config.yaml | cut -d: -f2 | tr -d ' ')
curl -s "https://api.telegram.org/bot${BOT_TOKEN}/getUpdates" | python3 -c "import json,sys; d=json.load(sys.stdin); print('queued:', len(d.get('result',[])))"
```

### 3. Run Hermes Check

```bash
python3 /root/.hermes/scripts/hermescheck.py
```

Expected output:
- Gateway process running
- Last Hermes message recent
- Cron jobs showing expected next-run times

### 4. Check Git Status

```bash
# Hermes repo
cd /root/.hermes && git log --oneline -3 && git status --short

# Wiki repo
cd /root/workspace/my-wiki && git log --oneline -3 && git status --short
```

If commits are unpushed, push before doing anything else.

### 5. Verify Required Logs

```bash
# Check for new Hermes errors since last session
tail -30 /dev/shm/hermes-gateway_err.log 2>/dev/null

# Check for any new PID race errors
grep "PID file race" /dev/shm/hermes-gateway_err.log 2>/dev/null | tail -5
```

### 6. Read Any Active Runbooks

If working on a multi-step process (migration, service setup, etc.), read the relevant runbook before starting:
- `wiki/runbooks/hermes-gateway-service.md`
- `wiki/runbooks/argus-canonical-runner.md`

---

## Session End Checklist

Complete these steps before ending any session:

### 1. Update CONTEXT.md

```bash
# If infrastructure state changed, update CONTEXT.md
# At minimum, note: what was done, what's in progress, what's next
nano /root/workspace/my-wiki/wiki/CONTEXT.md
```

Update the INFRASTRUCTURE STATE section if any of the following changed:
- New service registered or removed
- Cron job added, modified, or removed
- New API key or secret added
- Agent script added or changed

### 2. Append to log.md

```bash
# Record session activity in log.md
nano /root/workspace/my-wiki/wiki/log.md
```

Append a session summary in the format:
```markdown
## [YYYY-MM-DD HH:MM] session | summary of what was done
- Key action 1
- Key action 2
- Next session: what remains
```

### 3. Push Hermes Repo

```bash
cd /root/.hermes && git add -A && git commit -m "session: [brief description]" && git push
```

### 4. Push Wiki Repo

```bash
cd /root/workspace/my-wiki && git add -A && git commit -m "session: [brief description]" && git push
```

If push fails with GH013 (push protection), check for secrets in staged files:
```bash
git diff --cached | grep -iE "token|secret|key|password|api_key|sk-|bearer"
```

### 5. Final Hermes Check

```bash
# Confirm Hermes is still alive after all session work
ps aux | grep "hermes gateway run" | grep -v grep
python3 /root/.hermes/scripts/hermescheck.py
```

### 6. Confirm Next Scheduled Jobs

```bash
# Review next cron runs
/root/.hermes/hermes-agent/venv/bin/hermes cron list
```

Confirm that tomorrow's scheduled runs are expected and correct.

---

## Required Files to Read Per Session Type

### New Session (no prior context)
1. `wiki/CONTEXT.md` — full read
2. `wiki/log.md` — last 50 lines
3. `wiki/SOUL.md` — full read
4. `wiki/references.md` — full read

### Continuing Session ( resuming work)
1. `wiki/CONTEXT.md` — full read
2. `wiki/log.md` — last 20 lines
3. Any active runbook in `wiki/runbooks/`
4. `wiki/sync/manifest.md` — last 3 entries (if working on ongoing changes)

### Emergency Session (something broken)
1. `wiki/log.md` — last 10 lines
2. `hermescheck.py` — full read
3. `tail -50 /dev/shm/hermes-gateway_err.log`
4. `wiki/sync/manifest.md` — relevant entry

---

## Required Git Checks

### Before Any Work
```bash
cd /root/.hermes && git fetch origin && git status
cd /root/workspace/my-wiki && git fetch origin && git status
```

If local is behind remote: `git reset --hard origin/master`

### After Any Change
```bash
# Verify no secret files staged
git diff --cached | grep -iE "token|secret|key|password|api_key|sk-|bearer|bot"
```

### Before Ending Session
```bash
# Confirm all commits pushed
git log --oneline origin/main..HEAD  # wiki
cd /root/.hermes && git log --oneline origin/master..HEAD  # hermes
```

---

## What to Update Before Ending a Session

| If you changed... | Then update... |
|---|---|
| Infrastructure state | `wiki/CONTEXT.md` (INFRASTRUCTURE STATE section) |
| Agent scripts | `wiki/log.md` with commit hash and description |
| Cron jobs | `wiki/log.md` + `wiki/sync/manifest.md` |
| Secrets | `wiki/log.md` (note that secret was updated, not the value) |
| Service registration | `wiki/runbooks/hermes-gateway-service.md` |
| Argus runner | `wiki/runbooks/argus-canonical-runner.md` |
| Source of truth map | `wiki/sync/source-of-truth.md` |
| Change manifest | `wiki/sync/manifest.md` |

---

## Quick Reference Commands

```bash
# Session start
cat /root/workspace/my-wiki/wiki/CONTEXT.md
tail -50 /root/workspace/my-wiki/wiki/log.md
python3 /root/.hermes/scripts/hermescheck.py

# Git hygiene
cd /root/.hermes && git status --short && git log --oneline -3
cd /root/workspace/my-wiki && git status --short && git log --oneline -3

# Push all
cd /root/.hermes && git add -A && git commit -m "session: description" && git push
cd /root/workspace/my-wiki && git add -A && git commit -m "session: description" && git push

# Session end
python3 /root/.hermes/scripts/hermescheck.py
```

---

*At the start of every session, say: "I have read CONTEXT.md and log.md. Ready to continue — what is the priority today?"*