# DVS Project Snapshots — ChatGPT & Claude

**Version:** 1.0 — 2026-05-16

Snapshots are point-in-time exports of project state from ChatGPT and Claude. They may diverge from canonical sources and must be periodically refreshed.

---

## ChatGPT Project Files

**Project name:** VERIFY REQUIRED
**Export location:** VERIFY REQUIRED
**Last exported:** VERIFY REQUIRED

### Manual Refresh Process

1. **Open ChatGPT project**
   - Navigate to ChatGPT → Projects → [DVS project name]
   - Verify project is the correct one by checking `wiki/CONTEXT.md` for project identifier

2. **Identify included files**
   - List all files currently in the ChatGPT project
   - Cross-reference against the canonical source list below

3. **Identify missing files**
   - Compare ChatGPT project contents against canonical locations in `/root/workspace/my-wiki/wiki/` and `/root/.hermes/profiles/*/`
   - Flag any files in canonical but not in ChatGPT project

4. **Export updated files**
   - For each file that has changed since last export, copy content from canonical location to ChatGPT project
   - Preserve the `YYYY-MM-DD-EXPORT` suffix convention for snapshot files

5. **Record export metadata**
   - Update last-exported date in this file
   - Update files-included list
   - Update files-missing list

### Files Included in ChatGPT Project (VERIFY REQUIRED)

```markdown
# Copy current file list from ChatGPT project here after export
# Format: filename | canonical location | last modified

```

### Files Missing Since Export

```markdown
# List files that are in canonical but not in ChatGPT project
# Format: filename | canonical location | reason missing

```

### Known Stale Snapshots

```markdown
# List snapshots that are known to be outdated
# Format: filename | snapshot date | reason stale | priority to refresh

```

---

## Claude Project Files

**Project name:** VERIFY REQUIRED
**Export location:** VERIFY REQUIRED
**Last exported:** VERIFY REQUIRED

### Manual Refresh Process

1. **Open Claude project**
   - Navigate to Claude.ai → Projects → [DVS project name]
   - Verify project is the correct one by checking `wiki/CONTEXT.md` for project identifier

2. **Identify included files**
   - List all files currently in the Claude project
   - Cross-reference against the canonical source list below

3. **Identify missing files**
   - Compare Claude project contents against canonical locations in `/root/workspace/my-wiki/wiki/` and `/root/.hermes/profiles/*/`
   - Flag any files in canonical but not in Claude project

4. **Export updated files**
   - For each file that has changed since last export, copy content from canonical location to Claude project
   - Preserve the `YYYY-MM-DD-EXPORT` suffix convention for snapshot files

5. **Record export metadata**
   - Update last-exported date in this file
   - Update files-included list
   - Update files-missing list

### Files Included in Claude Project (VERIFY REQUIRED)

```markdown
# Copy current file list from Claude project here after export
# Format: filename | canonical location | last modified

```

### Files Missing Since Export

```markdown
# List files that are in canonical but not in Claude project
# Format: filename | canonical location | reason missing

```

### Known Stale Snapshots

```markdown
# List snapshots that are known to be outdated
# Format: filename | snapshot date | reason stale | priority to refresh

```

---

## Canonical Source List for Comparison

Use this list to check if ChatGPT and Claude project files are up-to-date with their canonical sources.

### Core System Files

| Canonical Location | File Purpose |
|---|
| `wiki/CONTEXT.md` | Session priorities, active agents, infrastructure state |
| `wiki/SOUL.md` | Agent identity and behavior |
| `wiki/log.md` | Chronological action log |
| `wiki/references.md` | Project cross-references |
| `hermes/profiles/apollo/SOUL.md` | Apollo writing agent identity |
| `hermes/profiles/athena/SOUL.md` | Athena synthesis agent identity |
| `hermes/profiles/argus/SOUL.md` | Argus monitoring agent identity |
| `hermes/profiles/hephaestus/SOUL.md` | Hephaestus code agent identity |
| `hermes/profiles/hermes/SOUL.md` | Hermes messaging agent identity |
| `hermes/scripts/argus-daily-brief-canonical.py` | Argus canonical runner |
| `hermes/scripts/hermescheck.py` | Hermes health check script |
| `hermes/config.yaml` | Hermes configuration |
| `hermes/cron/jobs.json` | Scheduled job definitions |

### Runbooks

| Canonical Location | File Purpose |
|---|
| `wiki/runbooks/hermes-gateway-service.md` | Hermes service migration runbook |
| `wiki/runbooks/argus-canonical-runner.md` | Argus canonical runner specification |
| `wiki/sync/source-of-truth.md` | Authority map (this file) |
| `wiki/sync/manifest.md` | Change manifest |

---

## Export Convention

When exporting files from canonical locations to ChatGPT or Claude projects:

1. **Snapshot files** must include the export date in the filename:
   - `CONTEXT-2026-05-16-EXPORT.md` (not just `CONTEXT.md`)
   - This makes stale snapshots immediately obvious

2. **Compare before overwrite** — always diff the current ChatGPT/Claude version against the canonical version before replacing

3. **Record the comparison** — if there are differences, note them in the relevant `files-missing` or `known-stale` section above

4. **Do not export secrets** — never export files containing `token`, `secret`, `key`, `api_key`, `sk-`, `bot`, `password`, `bearer`

---

*VERIFICATION REQUIRED: The fields in this file (project names, export locations, dates, included files) must be verified and filled in manually during the next session that has access to ChatGPT and Claude project interfaces.*