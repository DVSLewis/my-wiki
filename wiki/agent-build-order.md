---
title: DVS Agent Build Order — Dependency Graph
created: 2026-04-23
updated: 2026-04-23
type: concept
tags: [agents, architecture, build-order, dependency-graph, hermes, infrastructure]
sources:
  - references.md
  - wiki/CONTEXT.md
  - x.com/51bodila/status/2046982199455428878 (article behind X login — content not retrieved)
  - x.com/blocmates/status/2042539396638085339 (Hermes Agent article)
  - x.com/karpathy/status/2040470801506541998 (LLM Wiki follow-up)
---

# DVS Agent Build Order — Dependency Graph

This page defines the correct build sequence for the DVS Agent Pantheon. Build order is
determined by hard infrastructure dependencies — an agent cannot be built until its
prerequisites are in place. Violating build order wastes setup time and creates broken states.

## CRITICAL SOURCE NOTE

The primary reference for this page is @51bodila/status/2046982199455428878 (Apr 22 2026),
labeled "dependency graph architecture for agent build ordering." This post links to a
long-form X article (x.com/i/article/2034716088756219904) that was inaccessible without X
login at time of ingestion. @51bodila is described as a "Researcher & Analyst in web3 & AI"
and @polymarket believer. The post received 358 bookmarks and 105 likes.

ACTION REQUIRED: Log into X and retrieve the full article text, then update this page.

Until then this page is built from CONTEXT.md, SOUL.md, and the other ingested X posts.

---

## The Nine Agents — Status Overview

| # | Name       | Role                    | Model                       | Status      |
|---|------------|-------------------------|-----------------------------|-------------|
| 1 | Hermes     | Orchestrator            | Claude Sonnet 4.6           | RUNNING     |
| 2 | Athena     | Research / Wiki         | Claude Sonnet 4.6           | IN PROGRESS |
| 3 | Apollo     | Writing / Voice         | GPT-4o via OpenRouter       | NOT BUILT   |
| 4 | Iris       | Operations / Comms      | Gemini Flash via OpenRouter | NOT BUILT   |
| 5 | Hephaestus | Code / Technical        | DeepSeek via OpenRouter     | NOT BUILT   |
| 6 | Midas      | Commerce / x402         | Claude Sonnet 4.6           | NOT BUILT   |
| 7 | Janus      | Trading / DeFi          | Claude Sonnet 4.6           | NOT BUILT   |
| 8 | Argus      | Monitoring / Security   | Gemini Flash via OpenRouter | NOT BUILT   |
| 9 | Aphrodite  | Marketing / Creative    | Gemini Flash via OpenRouter | NOT BUILT   |

---

## Infrastructure Prerequisites (Must Come First)

Before any agent can be built, these shared foundation items must be in place.
Some are done. Some are not.

### Done
- Hermes installed and running on Zo Computer (Claude Sonnet 4.6, port 8644)
- ANTHROPIC_API_KEY: SET
- TELEGRAM_BOT_TOKEN: SET
- EMAIL_ADDRESS: SET
- ZO_CLIENT_IDENTITY_TOKEN: SET AND VERIFIED
- GitHub wiki repo: DVSLewis/my-wiki PUBLIC — live

### Not Yet Done (Blockers)
- OPENROUTER_API_KEY: NOT SET — blocks Apollo, Iris, Hephaestus, Argus, Aphrodite
- GITHUB_TOKEN: NOT SET — blocks code repos and Hephaestus
- ETHERSCAN_API_KEY: NOT SET — blocks Janus and Midas (Ethereum MCP)
- OWS wallet: NOT INSTALLED — blocks Midas and Janus (treasury and trading wallets)
- Ethereum MCP: NOT INSTALLED — blocks Janus
- defi-skills: NOT INSTALLED — blocks Janus

---

## Dependency Graph

Agents are organized in four tiers based on their dependencies.

Tier 0 is the foundation already running.
Tier 1 agents depend only on Tier 0 (Hermes).
Tier 2 agents depend on Tier 1 agents or external infrastructure.
Tier 3 agents have the heaviest multi-dependency requirements.

### Tier 0 — Foundation (DONE)

    [Hermes] — Orchestrator — RUNNING
    Zo Computer, Claude Sonnet 4.6, Telegram connected

    Hermes is the root node of the entire graph.
    Every other agent routes through or is coordinated by Hermes.

### Tier 1 — Early Builds (No External API Dependencies Beyond Anthropic)

    [Athena] — Research / Wiki
    Depends on: Hermes only
    Unlock condition: hermes profile create athena
    Build now — IN PROGRESS (this session)

    Why first: Athena maintains the wiki. The wiki informs every other build.
    Without Athena, institutional knowledge stays in CONTEXT.md only —
    fragile and not cross-referenced.

### Tier 2 — Mid Builds (Require OpenRouter API Key)

    [Apollo] — Writing / Voice
    Depends on: Hermes + OPENROUTER_API_KEY + GPT-4o access
    Special note: Donny has ChatGPT voice training already done — port to GPT-4o.
    Unlock condition: Sign up openrouter.ai, set OPENROUTER_API_KEY

    [Iris] — Operations / Communications
    Depends on: Hermes + OPENROUTER_API_KEY + Gemini Flash access
    Build method: NOT a full agent — builds as a Hermes skill calling the Zo API
    Unlock condition: OPENROUTER_API_KEY + Zo API integration skill

    [Hephaestus] — Code / Technical
    Depends on: Hermes + OPENROUTER_API_KEY + GITHUB_TOKEN + DeepSeek access
    Unlock condition: OPENROUTER_API_KEY + GITHUB_TOKEN in ~/.hermes/.env

    [Argus] — Monitoring / Security
    Depends on: Hermes + OPENROUTER_API_KEY + Gemini Flash access
    Build method: NOT a full agent — builds as a Hermes skill calling the Zo API
    Unlock condition: OPENROUTER_API_KEY + Zo API integration skill

    [Aphrodite] — Marketing / Creative Direction
    Depends on: Hermes + OPENROUTER_API_KEY + Gemini Flash access
    Benefits from: Athena (wiki content) and Apollo (voice/writing)
    Unlock condition: OPENROUTER_API_KEY

### Tier 3 — Heavy Infrastructure Builds

    [Midas] — Commerce / x402 Payments
    Depends on: Hermes + OWS wallet + x402 protocol research + Ethereum MCP
    Unlock conditions:
      - OWS installed on Zo (NOT Mac)
      - Agent treasury wallet created
      - Paper backup of seed phrase done
      - ETHERSCAN_API_KEY set
      - x402 payment rails research complete
    Warning: Financial agent. Hard spending limits required before activation.

    [Janus] — Trading / DeFi
    Depends on: Hermes + Midas (OWS wallet) + defi-skills + Ethereum MCP + ETHERSCAN_API_KEY
    This is the most dependency-heavy agent in the pantheon.
    Unlock conditions (ALL required):
      - Ethereum MCP installed on Zo
      - defi-skills installed (npx clawhub install defi-skills)
      - OWS wallet configured
      - ETHERSCAN_API_KEY set
      - Hard trading limits configured in Hermes policy
    Note: Janus converts natural language DeFi intents to unsigned transactions.
    OWS signs. Janus never sees plaintext keys.

---

## Recommended Build Sequence

This is the optimal path given current state (April 23 2026).

    Step 1  [NOW]     Complete Athena setup — hermes profile create athena
    Step 2  [NEXT]    Set OPENROUTER_API_KEY — unlocks 5 agents at once
    Step 3            Set GITHUB_TOKEN — unlocks Hephaestus
    Step 4            Build Apollo — voice and writing active
    Step 5            Build Iris as Hermes skill — operations layer active
    Step 6            Build Argus as Hermes skill — monitoring active
    Step 7            Build Hephaestus — code agent active
    Step 8            Build Aphrodite — marketing active
    Step 9            Install Ethereum MCP + defi-skills on Zo
    Step 10           Install OWS on Zo, create agent-treasury wallet, paper backup
    Step 11           Set ETHERSCAN_API_KEY
    Step 12           Build Midas — commerce active
    Step 13           Build Janus — DeFi trading active (last, most dangerous)

---

## Architecture Notes from Ingested X Posts

### blocmates — "What Hermes Agent Can Do for You" (Apr 10 2026)
Describes Hermes as the foundation layer for the entire productivity stack.
Three-layer model: Knowledge Layer (Karpathy LLM-Wiki = Athena's job),
Execution Layer (tools and skills), and Memory Layer (persistent sessions).
This validates Athena's Tier 1 position — she is the Knowledge Layer.
Source: x.com/blocmates/status/2042539396638085339 — 164K views

### karpathy — LLM Wiki idea file (Apr 4 2026)
Follow-up to viral LLM Knowledge Bases tweet. Karpathy introduced the concept of
an "idea file" — in the LLM agent era, sharing the idea is more valuable than
sharing code. The agent rebuilds the implementation from the idea. This is exactly
the pattern Athena operationalizes in this wiki.
Source: x.com/karpathy/status/2040470801506541998 — 26K likes, 46K bookmarks

### noisyb0y1 — Claude Code security warning (Apr 9 2026)
SECURITY NOTE relevant to all agents, especially Janus and Midas:
Claude Code (and by extension any file-reading agent) can read wallet seed phrases,
SSH keys, and AWS credentials if not properly sandboxed. A malicious CLAUDE.md in
a cloned repo can exfiltrate data. This validates the OWS architecture — agents
never see plaintext keys, only scoped API tokens. Review security settings before
any financial agent goes live.
Source: x.com/noisyb0y1/status/2042086577636061436

### rubenhassid — 8 files to set up Claude (Apr 10 2026)
Describes a file-based configuration approach: about-me.md, and 7 other context
files that Claude reads before every task, eliminating repetitive prompting.
This is the same pattern as SOUL.md + CONTEXT.md + about-donny.md already in place.
Validates the current DVS setup architecture.
Source: x.com/rubenhassid/status/2042558212990292013

### milesdeutscher — Claude Code + Obsidian (Apr 8 2026)
"Claude Code + Obsidian is the most powerful AI combo I've ever used."
Built an AI second brain inspired by Karpathy's LLM-Wiki. Confirms the
wiki pattern has widespread validation and real-world adoption at scale.
Source: x.com/milesdeutscher/status/2041972675418189933

---

## Open Questions (Flagged for Donny)

1. CRITICAL: The @51bodila article on dependency graph architecture is behind
   X login. Retrieve it and update this page. It may contain a more formal
   dependency graph that supersedes or refines what is here.

2. Iris and Argus build as "Hermes skills calling Zo API" — what is the Zo API
   skill or integration pattern? This needs a wiki page once implemented.

3. Apollo voice training: how exactly is the ChatGPT voice training ported to
   GPT-4o via OpenRouter? Needs research before Apollo build.

4. x402 payment rails: status is "research pending." Midas cannot be built
   without this. Needs a dedicated wiki page.

5. EIP-8004 Agent Identity: on-chain identity for DVS agents. Status pending.
   Relevant to all agents once active. Needs a wiki page.

---

## Cross-References

- [[CONTEXT.md]] — master nine-agent list and status
- [[references.md]] — source library including OWS, Ethereum MCP, defi-skills install commands
- [[SOUL.md]] — Hermes orchestrator identity and routing rules

---

## Log

2026-04-23: Page created by Athena. Based on CONTEXT.md, ingested X posts,
and available (non-login-gated) content. @51bodila article not retrieved —
flagged as open gap. Build sequence derived from dependency analysis.
