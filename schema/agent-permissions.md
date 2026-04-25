# Agent Write Permissions — DVS Pantheon

> Defines exactly what each agent can and cannot write to within `/root/workspace/my-wiki/`.
> Last updated: 2026-04-25

---

## Athena
- **CAN:** `wiki/` and `raw/` directories
- **CANNOT:** shrink `CONTEXT.md` (fewer lines than previous version)
- **CANNOT:** write to `schema/` or any other directory without Donny's approval

## Hermes
- **CAN:** append new lines to `wiki/CONTEXT.md` only (session log entries, status updates)
- **CANNOT:** edit, delete, or rewrite existing content in `CONTEXT.md`
- **CANNOT:** write anywhere else without explicit approval

## Hephaestus
- **CAN:** write to `scripts/` directory only
- **CANNOT:** write to `wiki/`, `raw/`, `schema/`, or any other directory
- **CANNOT:** modify `CONTEXT.md` or any tracked documents

## Apollo
- **CAN:** write to `wiki/` (marketing copy, voice/style docs)
- **CANNOT:** write to `raw/`, `schema/`, or `scripts/` without explicit approval

## Argus
- **CAN:** write to `wiki/daily-brief-*.md` and `raw/daily-inbox/` only
- **CANNOT:** write to any other directory

## Iris
- **CAN:** write to `wiki/` (operations notes, status logs)
- **CANNOT:** write to `raw/`, `schema/`, or `scripts/`

## Janus
- **CAN:** write to `wiki/` (DeFi/trading notes, market analysis)
- **CANNOT:** write to `raw/`, `schema/`, or `scripts/` without explicit approval

## Midas
- **CAN:** write to `wiki/` (commerce notes, revenue tracking)
- **CANNOT:** write to `raw/`, `schema/`, or `scripts/` without explicit approval

## Aphrodite
- **CAN:** write to `wiki/` (marketing copy, content drafts)
- **CANNOT:** write to `raw/`, `schema/`, or `scripts/` without explicit approval

---

## Global Rules
- **NO agent** writes to `schema/` without explicit Donny approval (except to read)
- **NO agent** deletes files from `wiki/` or `raw/` without Donny approval
- **NO agent** can modify `.git/hooks/` — Donny-only
- **NO agent** writes secrets, API keys, or credentials anywhere in the workspace
- All write operations are logged in `CONTEXT.md` SESSION LOG

## Enforcement
This file is enforced by:
1. Pre-commit hook: prevents shrinking of `CONTEXT.md`
2. Agent SOUL.md: each agent knows their permissions
3. Donny review: all non-trivial writes visible in git diff