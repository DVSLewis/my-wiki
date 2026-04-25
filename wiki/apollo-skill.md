# Apollo Skill — invoke-apollo

> Voice-aware delegation skill for Apollo writing tasks.
> Status: active | Installed: 2026-04-25

## Overview

`invoke-apollo` is a Hermes skill that bridges voice memory across subagent isolation. When any agent in the DVS Pantheon delegates a writing task to Apollo, this skill automatically reads Donny's voice profile, injects it as mandatory context, and spawns Apollo with full voice memory — preventing the generic AI drift that happens when subagents lose cross-session context.

## How It Works

```
Any Agent (Hermes, Athena, Hephaestus, etc.)
         │
         ▼
┌─────────────────────────────────────┐
│  invoke-apollo skill                │
│                                     │
│  1. Read voice profile              │
│     /root/.hermes/profiles/         │
│        apollo/apollo-voice-profile.md│
│                                     │
│  2. Prepend full profile as context │
│                                     │
│  3. Spawn Apollo via:               │
│     hermes chat --profile apollo    │
│     with combined prompt            │
└─────────────────────────────────────┘
         │
         ▼
   Apollo writes in Donny's voice
   every time — no drift, no generic tone
```

## Voice Profile

**Path:** `/root/.hermes/profiles/apollo/apollo-voice-profile.md`

**Privacy:** PRIVATE — never push to GitHub, never share outside this system.

The voice profile is excluded from all git operations. It lives only on this server.

## Usage

### Delegation from any agent

```
Use invoke-apollo. Task: [describe writing task]
```

### Terminal

```bash
hermes skills run invoke-apollo --task "Write a short essay on..."
```

### Cron (scheduled Apollo tasks)

```bash
hermes cron create "0 9 * * *" \
  --prompt "Use invoke-apollo. Task: Morning reflection — 3 paragraphs on ETHis project state." \
  --delivery telegram
```

## Prompt Injection Template

The skill uses this pattern to inject voice context:

```
[VOICE PROFILE — MANDATORY CONTEXT]
<full apollo-voice-profile.md content>

[TASK]
<user task description>

Write in Donny Lewis's voice. Follow the voice profile above exactly.
```

## Privacy Note

The voice profile contains Donny Lewis's personal writing style, creative preferences, rhetorical patterns, and private content samples. It must never be:
- Pushed to GitHub or any remote repository
- Shared in Slack, Discord, Telegram, or any messaging platform
- Included in any skill manifest or public hub listing

## Related

- [[agent-build-order.md]] — DVS agent build order and architecture
- [[apollo-voice-profile-reference.md]] — (internal only — private path)
- [[pantheon-guardrails.md]] — security and access control for the swarm