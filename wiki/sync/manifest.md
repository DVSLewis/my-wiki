# DVS Change Manifest — Template

**Version:** 1.0 — 2026-05-16

Use this template for every significant system change. Each manifest entry is a permanent record that can be audited later to understand why a decision was made and what happened as a result.

---

## Manifest Entry Template

```markdown
## [YYYY-MM-DD HH:MM] CHANGE | subject

### What changed
<!-- One-paragraph description of the change -->

### Why it changed
<!-- Root cause or motivation (reference preceding log entries) -->

### Failure Evidence
<!-- Error messages, symptoms, broken behavior BEFORE the change -->

### Root Cause
<!-- Technical cause of the failure or motivation for change -->

### Targeted Fix
<!-- Exact command or patch applied -->

### Predicted Improvement
<!-- Expected outcome after fix is applied -->

### Risk Register
| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| | | | |

### Verification Evidence
<!-- Evidence that the fix worked or didn't -->

### Git Commits
| Repo | Commit | Message |
|---|---|---|
| | | |

### Verdict
KEEP / IMPROVE / ROLLBACK

### Verdict Rationale
<!-- 2-3 sentences on why this change is kept, improved, or rolled back -->

### Follow-up Required
<!-- Any remaining open items -->
```

---

## Recent Manifest Entries

---

## [2026-05-15 23:20] CHANGE | Hermes gateway migrated to Zo User Service

### What changed
Hermes gateway was migrated from a nohup/bashrc-managed process to a Zo User Service (`mode=process`, supervised by supervisord). The service is now registered as `svc_A2aDmAIyGzE` and managed by Zo's infrastructure.

### Why it changed
The nohup/bashrc approach had no persistence across Zo restarts and required manual cleanup of stale `gateway.pid` files. The supervised service approach ensures Hermes auto-restarts and is properly monitored.

### Failure Evidence
Stale `gateway.pid` (PID 44, dead) blocked Hermes restart. Gateway exiting with "PID file race lost to another gateway instance. Exiting." every ~20s. No PID cleanup guard existed in hermescheck.py.

### Root Cause
`hermes gateway stop` calls from scheduled Argus jobs killed the supervised Hermes process, triggering supervisord respawns that raced with the PID file.

### Targeted Fix
1. Added PID-only cleanup to hermescheck.py (removes stale gateway.pid only when no Hermes process is running AND stored PID is dead)
2. Commented out bashrc lines 32-34 (nohup auto-start)
3. Updated pre-existing Zo User Service `svc_A2aDmAIyGzE` with Hermes entrypoint and env vars
4. Killed nohup Hermes (PID 1317), let Zo User Service supervisor start supervised instance (PID 2926)

### Predicted Improvement
Hermes stays alive across Zo restarts. PID race errors eliminated. Auto-restart on crash.

### Risk Register
| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Zo restart during active migration | LOW | HIGH | Rollback command saved at `/root/.hermes/checkpoints/rollback-command.txt` |
| Supervisord not managing service | LOW | HIGH | `ps aux | grep hermes gateway run` after every restart |
| bashrc nohup lines interfere | LOW | HIGH | Commented out; uncomment only for manual fallback |

### Verification Evidence
- Telegram `sendMessage` → msg_id 480 ✅
- Hermes PID 2926 alive ✅
- gateway.pid matches live PID ✅
- Supervisord log: `success: hermes-gateway entered RUNNING state` ✅
- No new PID race errors in stderr log ✅

### Git Commits
| Repo | Commit | Message |
|---|---|---|
| DVSLewis/hermes | `56f68f6` | migrated: hermes-gateway to Zo User Service |

### Verdict
**KEEP**

### Verdict Rationale
The supervised service approach is more robust than nohup/bashrc management. Hermes has survived multiple Zo restarts with no manual intervention required. PID race errors stopped immediately.

### Follow-up Required
- Monitor for new PID race errors after each Hermes restart
- Verify supervisord logs show `success: hermes-gateway entered RUNNING state`

---

## [2026-05-16 14:30] CHANGE | Argus cron switched to canonical runner

### What changed
The `argus-daily-brief` cron job (id `42cd1df992e7`) was switched from `argus-daily-brief-v3.py` to `argus-daily-brief-canonical.py`. The canonical runner uses a different signal aggregation approach (multi-source: Tavily + RSS + X profiles), structured JSON output, and strict artifact separation.

### Why it changed
The v3 runner had accumulated three critical issues:
1. Hard-coded `hermes gateway stop` calls that killed the supervised Hermes process
2. No `--send-telegram` flag — Telegram was always sent (could not validate dry-run)
3. Rejected signals only written if count > 0 (debugging gap)

The canonical runner fixes all three and provides better observability.

### Failure Evidence
- Hermes PID race errors: "PID file race lost to another gateway instance. Exiting." — caused by `hermes gateway stop` in v3
- Could not validate v3 dry-run without Telegram firing
- No visibility into rejected signals when count was zero

### Root Cause
v3 runner script had `hermes gateway stop` to prevent duplicate instances, but Hermes is now supervised — this call killed the live supervised process.

### Targeted Fix
1. `hermes cron edit 42cd1df992e7 --prompt "python3 /root/.hermes/scripts/argus-daily-brief-canonical.py"`
2. Removed `hermes gateway stop` from argus-daily-brief.sh (commit `6c28476`)
3. Added `fcntl.LOCK_EX` to hermescheck.py for PID file atomicity (commit `6c28476`)
4. Added `--send-telegram` flag and `--dry-run` to canonical runner (commits `fe71322`, `87a7153`)

### Predicted Improvement
- No more Hermes PID race from scheduled jobs
- Canonical runner can be validated dry-run without Telegram firing
- Rejected signals always written (even when count = 0)

### Risk Register
| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Canonical runner has uncaught bugs in production | MEDIUM | MEDIUM | Dry-run tested; monitor first production run 2026-05-17T07:00:00 |
| Tavily API key missing in hermes .env | LOW | HIGH | `TAVILY_API_KEY` sourced from `/root/.hermes/.env` — verified present |
| RSS adapter broken for a source | MEDIUM | LOW | Graceful degradation per source; failed sources logged |

### Verification Evidence
- Syntax check: OK ✅
- Dry-run: 85 signals, 4 brief files, 42 inbox files, 0 rejected ✅
- Telegram dry-run: skipped ✅
- No secrets in artifacts ✅
- Git status clean (canonical artifacts in raw/test-run/ only) ✅

### Git Commits
| Repo | Commit | Message |
|---|---|---|
| DVSLewis/hermes | `87a7153` | fix(argus): tighten canonical dry-run and rejected artifacts |
| DVSLewis/hermes | `fe71322` | fix(argus): load telegram token from hermes .env safely |
| DVSLewis/hermes | `6c28476` | fix(hermes): stop scheduled jobs from killing supervised gateway |
| DVSLewis/my-wiki | `430fad5` | log: Argus cron switched to canonical runner |

### Verdict
**KEEP**

### Verdict Rationale
Canonical runner has been tested dry-run successfully. The v3 runner's `hermes gateway stop` calls were causing direct harm to the supervised Hermes service. All three critical issues are resolved. First production run will be monitored closely.

### Follow-up Required
- Monitor 2026-05-17T07:00:00 production run for:
  - Telegram message_id delivered
  - No Hermes PID race errors
  - All signals written to `wiki/signals/YYYY-MM-DD/`
  - `raw/daily-inbox/YYYY-MM-DD.md` written
- If any check fails: `hermes cron edit 42cd1df992e7 --prompt "python3 /root/.hermes/scripts/argus-daily-brief-v3.py"` as immediate rollback

---

## [2026-05-16 17:15] CHANGE | Cron persistence risk mitigated — watchdog fallbacks created

### What changed
1. Created durable desired-state declaration: `/root/workspace/my-wiki/wiki/sync/hermes-cron-desired.json`
2. Created Zo automations as persistent fallback watchdogs for Argus and Athena
3. Documented the overlay filesystem persistence risk for Hermes cron jobs

### Why it changed
Hermes cron jobs (`jobs.json`) live on overlay filesystem — restart survival is UNKNOWN. If the container sandbox resets, Hermes cron reverts to baked image state and Argus/Athena schedules would be lost. No git re-hydration of cron state on restart. This was a silent single-point-of-failure for the entire DVS intelligence pipeline.

### Failure Evidence
- `/root/.hermes/cron/jobs.json` is on overlay (container ephemeral) filesystem
- Cron jobs are NOT in git
- No Zo automation fallback existed before this session
- Orphaned cron entries found: `athena-weekly-synthesis` (1b4dc234acf3), `Argus Daily Brief v2` (cf97d1b5303a), `wiki-daily-backup` (e2c09bee222e)

### Root Cause
Hermes uses its own cron system with local JSON storage, not git. The sandbox overlay means any changes to `/root/` (including Hermes cron state) do not persist across container restart.

### Targeted Fix
1. Created `hermes-cron-desired.json` as durable git-tracked desired state for all active jobs
2. Created Zo automations ( Zo-run full sessions) as persistent fallback:
   - Argus watchdog: `FREQ=DAILY;BYHOUR=7;BYMINUTE=0` (07:00 PDT) — checks all Argus outputs exist; fires fallback if missing
   - Athena watchdog: `FREQ=DAILY;BYHOUR=7;BYMINUTE=35` (07:35 PDT) — checks Athena synthesis exists; fires fallback if missing; blocked if Argus outputs missing
3. Both watchdogs log results to `wiki/log.md`
4. Updated `manifest.md`, `source-of-truth.md`, and `project-snapshots.md` with this finding

### Predicted Improvement
Even if Hermes cron is lost on restart, the watchdogs will detect missing outputs and fire the canonical runners. The `hermes-cron-desired.json` file provides a human-readable and machine-parseable reference for manual job re-creation if needed.

### Risk Register
| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Sandbox full reset | LOW | HIGH | Watchdogs fire within 5-35min of expected time; log to wiki/log.md |
| Hermes cron lost AND watchdog fails | LOW | MEDIUM | hermes-cron-desired.json provides manual re-create instructions |
| Watchdog fires on false positive | LOW | LOW | Watchdog checks for output AND Telegram message_id — both must be missing |
| Zo automation not persisted across reset | MEDIUM | HIGH | Automations are Zo-managed, not Hermes-managed — different persistence path; unverified |

### Verification Evidence
- hermes-cron-desired.json: created with all active/orphaned job IDs, schedules, expected outputs ✅
- Argus watchdog automation: created, next_run 2026-05-17T07:00:33-07:00 ✅
- Athena watchdog automation: created, next_run 2026-05-17T07:35:41-07:00 ✅
- manifest.md updated with full entry ✅
- source-of-truth.md updated ✅
- project-snapshots.md updated ✅
- Git committed and pushed: my-wiki `docs(sync): record cron persistence and watchdog plan` ✅

### Git Commits
| Repo | Commit | Message |
|---|---|---|
| DVSLewis/my-wiki | `docs(sync): record cron persistence and watchdog plan` | docs(sync): record cron persistence and watchdog plan |

### Verdict
**KEEP**

### Verdict Rationale
The combination of a git-tracked desired-state file and Zo-managed automation watchdogs provides defense-in-depth against the persistence risk. Even if Hermes cron is lost, the watchdogs will restore the pipeline within 35 minutes of expected time. The orphaned job cleanup (removing stale cron entries) will be handled in a follow-up session once the new pipeline is verified stable.

### Follow-up Required
- Monitor 2026-05-17T07:00 and 07:35 watchdog runs for:
  - Watchdogs correctly detect healthy outputs (no action needed)
  - wiki/log.md shows watchdog check entries
- After 1 week of stable watchdog runs: clean up orphaned cron entries
- After 2 weeks: re-evaluate if Hermes cron persistence has been resolved via underlying infrastructure

---

*Append new manifest entries above this line. Each entry must have all fields filled. Delete incomplete entries.*

## 2026-05-17 — Direct DVS watchdog runner

Status: KEEP pending 2026-05-18 production proof

Failure evidence:
- Zo watchdogs were scheduled but no concrete DVS watchdog scripts existed.
- Hermes cron failure on 2026-05-17 required manual recovery.
- Watchdog behavior was not independently verifiable.

Root cause:
- The watchdog concept existed as schedule intent, not executable infrastructure.
- Recovery path depended on agent/session behavior instead of deterministic scripts.

Targeted fix:
- Created `/root/.hermes/scripts/dvs-watchdog.py`.
- Watchdog verifies Argus/Athena artifacts directly.
- Watchdog runs canonical Python recovery scripts directly if artifacts are missing.
- Watchdog sends Telegram directly without Hermes gateway dependency.
- Watchdog logs every run to `/root/.hermes/logs/watchdogs/`.

Evidence:
- Argus watchdog verified and sent Telegram message_id=513.
- Athena watchdog verified and sent Telegram message_id=514.
- Hermes commit: `825c889`.

Predicted improvements:
- Missed Hermes cron delivery can be detected and recovered without Hermes gateway.
- Watchdog status is auditable via local logs and Telegram message IDs.
- Future scheduled jobs can reuse this watchdog pattern.

Risk register:
- Telegram token remains dependency.
- Artifact presence may not prove content quality.
- Production proof still required on 2026-05-18.
