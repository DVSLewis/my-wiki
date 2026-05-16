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

*Append new manifest entries above this line. Each entry must have all fields filled. Delete incomplete entries.*