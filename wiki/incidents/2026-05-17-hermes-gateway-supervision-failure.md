# Incident: Hermes scheduler dispatch failure under Zo supervision

Date: 2026-05-17
Severity: HIGH
Status: RECOVERED / HARDENING IN PROGRESS

## Impact

- Argus missed scheduled 07:00 UTC run.
- Athena missed scheduled 07:30 UTC run.
- Manual Argus recovery succeeded around 07:16–07:17 UTC.
- Manual Athena recovery succeeded around 07:45 UTC.
- Telegram delivery eventually confirmed:
  - Argus recovery: msg_id=510
  - Athena recovery: msg_id=512

## Failure Evidence

- `hermes cron list` showed jobs active.
- `hermes cron list` also reported: "Gateway is not running — jobs won't fire automatically."
- `gateway.pid` was stale or absent.
- Hermes process existence alone was not enough to prove scheduler health.
- Zo supervisord was running.
- Hermes Zo User Service was registered.
- `supervisorctl` required explicit config:
  `/etc/zo/supervisord-user.conf`
- Default `supervisorctl` context did not correctly manage or verify the Zo user service.
- Watchdog behavior was not proven by 07:45 UTC.

## Root Cause

Hermes internal health logic assumes `gateway.pid` is authoritative.
After migration to Zo User Service, lifecycle authority moved to Zo supervisord:

- Process owner: `/etc/zo/supervisord-user.conf`
- Runtime service: `hermes-gateway`
- Supervisord authority command:
  `supervisorctl -c /etc/zo/supervisord-user.conf`

Therefore, `gateway.pid` is no longer authoritative under this deployment model.
It is advisory only.

Hermes cron warning may be a false alarm when the supervised process is healthy but
Hermes cannot self-locate through its PID file.

## Architectural Lesson

Supervised process does not equal healthy service.
Cron job listed does not equal scheduler dispatching.
Watchdog scheduled does not equal watchdog verified.
No Telegram message means failure until delivery is externally confirmed.
Every deployed process must have an explicit lifecycle authority map.

## Authority Correction

For Hermes under Zo User Service:

| Signal | Authority |
|---|---|
| Process lifecycle | Zo supervisord |
| Service config | `/etc/zo/supervisord-user.conf` |
| Service status | `supervisorctl -c /etc/zo/supervisord-user.conf status` |
| PID file | Advisory only |
| Hermes cron list | Useful but not sufficient |
| Telegram delivery | External verification required |

## What Worked

- Canonical Argus runner worked when run directly.
- Athena manual recovery worked.
- Telegram delivery confirmation worked.
- Git commit/push path worked.
- `hermescheck.py` stale PID cleanup partially worked.
- Zo User Service registration survived.

## What Failed

- Hermes gateway died silently.
- Supervisord did not restart/manage it through the command path initially used.
- Hermes cron health relied on PID semantics incompatible with Zo supervision.
- Watchdog recovery was not proven.
- `hermescheck.py` initially reported OK before fully excluding stale PID state.

## Permanent Fixes Required

1. Patch `hermescheck.py`:
   - detect Zo User Service deployment
   - use `supervisorctl -c /etc/zo/supervisord-user.conf`
   - classify `gateway.pid` as advisory under Zo
   - call `hermes cron list`
   - reclassify exact gateway warning as false-positive only when supervisord confirms RUNNING

2. Harden watchdogs:
   - run Python scripts directly
   - never depend on Hermes gateway
   - log OK / RECOVERED / FAILED every run
   - send direct Telegram alerts on recovery/failure

3. Treat Hermes cron as probationary:
   - not production-trusted until 2026-05-18 Argus and Athena runs survive
   - verify Telegram delivery IDs
   - verify watchdog behavior

4. Add process supervision authority runbook.

## Current Recovery State

As of 2026-05-17 08:10 UTC:

- Hermes gateway restarted.
- `hermes-gateway` running under Zo supervisord.
- Telegram bot connected.
- Cron warning understood as PID-authority mismatch.
- Next production proof window:
  - Argus: 2026-05-18 07:00 UTC
  - Athena: 2026-05-18 07:30 UTC

## Verdict

KEEP the Zo User Service migration.
IMPROVE health detection, watchdog proof, and authority mapping.
Do not roll back to nohup/bashrc.
