# DVS Session Handoff — April 28, 2026 (Session 18)

## WHO

Donny Lewis. Munich/US. EN/FR/DE. Ecosystem operator, writer, model, actor,
creative director. Core contributor ETHis 2026 (July 2-3 Deutsches Museum Munich).
Editor IRK Magazine Paris. Creative Director Beyond Design Agency.
Co-founder WeTryBetter. Viridis green-tech DAO. Web3 8+ years.
Treat as trusted co-worker. Security priority one. Never paste API keys in chat.

## THE VISION

Fully autonomous agent swarm operating as a one-person company — research, writing,
code, operations, commerce, trading, marketing, monitoring. Donny is architect and
strategic counselor, not operator. Swarm generates independent revenue.
Trust is the foundation. Sovereignty. Balance. The seesaw at center.
Immediate 90 days: Land Tether role. Truth About Trust series → book.
Aphrodite live for Kristina/rewritebeforeyousend.com. Tiny Stars Publishing KDP.
Trading bots online. ETHis 2026 core organizer.

## INFRASTRUCTURE STATE

- Zo Computer: paid, always-on
- Hermes: RUNNING on Zo, Claude Sonnet 4.6, Telegram @DVS_HermesBot LIVE ✓
- GitHub wiki: github.com/DVSLewis/my-wiki (PUBLIC)
- SOUL.md: all 9 agents complete at ~/.hermes/profiles/{agent}/SOUL.md
- Fileverse MCP: VERIFIED WORKING
- XMCP: LIVE, 20 tools, @Jerri_nft OAuth1
- OpenRouter: CONFIRMED WORKING (contention issue with Hermes — see below)
- OpenAI: CONFIRMED WORKING — now primary scoring engine for Argus
- Tavily: CONFIRMED WORKING — primary fetch engine for Argus
- Private storage: /root/workspace/dvs-private/ — not in git
- Pre-commit hook: WARN not REJECT (allows CONTEXT.md size changes)
- CONTEXT.md 2000 word limit: REMOVED — full content preserved

## CRITICAL: ZO BOT vs HERMESBOT — UNDERSTAND THE DIFFERENCE

- **Zo Computer Bot (TG)** — Zo's native assistant. Remote control for the Zo machine.
  Runs terminal commands, manages files, executes scripts. No DVS context by default.
  Use for: terminal commands, file writes, script execution.
- **@DVS_HermesBot (TG)** — YOUR custom orchestrator. Runs Hermes Agent framework
  with your SOUL.md files, skills, .env keys, agent profiles.
  Use for: pantheon tasks, agent routing, briefs, content, memory.
- Hermes binary location: /root/.hermes/hermes-agent/venv/bin/hermes
- Hermes has been running since Apr 27 6:37am — 20+ hours uptime

## OPENROUTER CONTENTION ISSUE — IMPORTANT

Hermes agent runs continuously and consumes OpenRouter credits/rate limits.
When Argus or other scripts also hit OpenRouter simultaneously, 429 rate limit
errors occur. This is resource contention, not a quota or credit issue.

**Resolution strategy:**

- Argus scoring: moved to OpenAI directly (FIXED Session 18)
- Argus TG delivery: still uses Hermes CLI → OpenRouter (BROKEN — fix Session 19)
- Long term: dedicated OpenRouter key for Argus if needed
- OpenAI key has plenty of credits — use for agent tasks where possible

## ARGUS STATUS — MOSTLY OPERATIONAL ✓

**This is the biggest win of Session 18.**

Argus daily brief pipeline is now confirmed working end-to-end with one remaining issue.

### What's confirmed working ✓

- Tavily fetch: 54 signals per run across 11 topic clusters
- OpenAI scoring: gpt-4o-mini scores signals 1-10 for relevance
- Brief writing: wiki/daily-brief-YYYY-MM-DD.md with scored signals
- Inbox writing: raw/daily-inbox/YYYY-MM-DD.md for signals ≥8
- Cognee ingestion: brief fed into knowledge graph after every run
- Git commit and push: Athena pushes to GitHub automatically
- Zo automation: scheduled to run daily at 8am UTC (9am CET)

### What's broken ✗

- TG delivery: HTTP 429 from OpenRouter when Hermes CLI sends notification
  Fix: bypass Hermes CLI, call Telegram Bot API directly
  Need: DVS_HermesBot token from @BotFather
  Chat ID: 6127567960 (hardcoded in script, verified correct)

### Argus script location

/root/workspace/my-wiki/scripts/argus-daily-brief.sh (137 lines, Tavily-native)
/root/workspace/my-wiki/scripts/argus-daily-brief.sh.bak (RSSHub version backup)
/root/workspace/my-wiki/scripts/cognee_block.py (permanent location, fixed Session 18)

### Argus architecture — Tavily topic clusters

11 search queries covering:

- Ethereum core: Vitalik, timbeiko, superphiz, hudsonjameson
- Ethereum security: samczsun, gakonst
- AI x Ethereum convergence: karpathy, x402, EIP
- Gnosis ecosystem: koeppelmann, GnosisDAO, GnosisChain, Safe, Cow Protocol
- DAO and public goods: governance, ETHis 2026 Munich
- DeFi and ReFi: protocols, regenerative finance

Scoring thresholds: ≥7 → daily brief, ≥8 → inbox

### Session 19 first task — Fix TG delivery

Replace Hermes CLI TG send (line 226) with direct Telegram Bot API call:

```bash
# Get bot token safely
grep "TELEGRAM\|BOT_TOKEN\|HERMESBOT" /root/.hermes/.env | sed 's/=.*/=SET/'

# Then replace line 226 in script with direct curl:
# curl -s "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
#   -d "chat_id=${TELEGRAM_CHAT_ID}&text=${TG_MSG}"
```

## COGNEE STATUS — FULLY OPERATIONAL ✓

Cognee 1.0.2 confirmed working. Knowledge graph growing with every Argus run.
Last confirmed run: 178 nodes, 177 edges (Session 18 test runs).

### CRITICAL: How to run Cognee correctly

All environment variables MUST be set at shell level BEFORE Python starts.
The lru_cache loads config at import time — runtime injection doesn't work.

```bash
OPENAI_KEY=$(grep "^OPENAI_API_KEY=" ~/.hermes/.env | tail -1 | cut -d'=' -f2)
ORKEY=$(grep "^OPENROUTER_API_KEY=" ~/.hermes/.env | tail -1 | cut -d'=' -f2)

COGNEE_SKIP_CONNECTION_TEST=true \
OPENAI_API_KEY=$OPENAI_KEY \
EMBEDDING_PROVIDER=openai \
EMBEDDING_MODEL=text-embedding-3-small \
EMBEDDING_API_KEY=$OPENAI_KEY \
EMBEDDING_DIMENSIONS=1536 \
LLM_API_KEY=$ORKEY \
LLM_MODEL=openrouter/anthropic/claude-haiku-4.5 \
LLM_PROVIDER=openai \
LLM_ENDPOINT=https://openrouter.ai/api/v1 \
python3 your_script.py
```

### Cognee provider summary

- LLM (entity extraction, graph building): OpenRouter → claude-haiku-4.5
- Embeddings (vector search): OpenAI → text-embedding-3-small (1536 dimensions)
- Vector store: LanceDB (local, no server required)
- Graph store: SQLite-backed NetworkX
- cognee_block.py: /root/workspace/my-wiki/scripts/cognee_block.py (permanent)

### Cognee next steps (Session 19+)

1. Bootstrap all wiki pages into Cognee:
   Run /root/workspace/my-wiki/scripts/bootstrap_cognee.py
1. Wire delta-sync: after Athena writes any wiki page, call cognee.remember()
1. Replace Athena's grep-based search with cognee.search(SearchType.CHUNKS)
1. Activate in Hermes config: set provider: cognee in ~/.hermes/config.yaml
1. Test session memory: each agent uses session_id = agent_name + date

## HONEST AGENT STATUS

### CONFIRMED WORKING ✓

- Hermes — RUNNING — orchestrator — Telegram @DVS_HermesBot live
  Binary: /root/.hermes/hermes-agent/venv/bin/hermes
  Running since: Apr 27 6:37am (20+ hours)
- Apollo — ACTIVE — Gemini Flash via OpenRouter — invoke-apollo.sh working
  Voice profile 252 lines PROVEN. Truth About Trust 3 complete (22,598 bytes).
- Argus — MOSTLY OPERATIONAL — Tavily fetch + OpenAI scoring working
  Brief writing, Cognee ingest, git push all confirmed working
  TG delivery broken (429) — fix Session 19
- Cognee memory layer — FULLY OPERATIONAL

### PARTIALLY BUILT — NOT VERIFIED END TO END ✗

- Athena — git push now WORKING (confirmed Session 18 — was never actually locked)
  Tavily installed and API key CONFIRMED WORKING (tested Session 18)
  Research pipeline exists but never verified live with real output
  Git push permissions restored — can now push to GitHub
- Aphrodite — tiktok-editor.sh production ready (6 platforms, caption support) ✓
  carousel-maker.sh exists (contents not verified)
  Neil Patel training docs ingested
  BUT: No Google Drive architecture
  No way for Kristina to submit files or instructions
  No email-to-agent pipeline
  No delivery mechanism back to Kristina
  Kristina client deadline missed — needs to be prioritized Session 19

### SOUL WRITTEN — NOT BUILT ✗

- Iris — operations — NOT BUILT
- Midas — commerce — NOT BUILT (do not build until foundation solid)
- Janus — trading — NOT BUILT (do not build until foundation solid)

## KEY DISCOVERIES SESSION 18

-  Athena's git lock was fixed by Donny and Zo computer.
- Tavily API key was always present and working — never the issue
- Argus script existed but was NEVER scheduled (no crontab, no automation)
- RSSHub feeds are dead — replaced with Tavily topic cluster search
- Hermes binary not in $PATH — must use full path:
  /root/.hermes/hermes-agent/venv/bin/hermes
- Zo server runs UTC — 9am CET = 8am UTC for scheduling
- OpenRouter contention: Hermes continuous process collides with script API calls
- OpenAI is the better choice for Argus scoring — separate account, generous limits
- cognee_block.py must live in /root/workspace/ not /tmp/ — /tmp/ gets wiped
- Zo bot summarizes instead of showing raw output — use specific grep/sed commands
  to force raw output, or pipe to files then cat
- "Designed and documented" ≠ "running and proven" — validate everything live

## PANTHEON ORCHESTRATION — DESIGNED, NOT WRITTEN

Architecture decisions locked in Sessions 16-18:

**Communication model:** Complete-and-return (not blocking mid-task)

Each agent runs to completion, returns structured NEEDS block:

```json
{
  "agent": "apollo",
  "task_id": "truth-about-trust-4",
  "status": "partial_complete",
  "completed": "Draft written, 1800 words",
  "needs": [
    {
      "from": "athena",
      "request": "research",
      "query": "Zero-knowledge proof adoption 2025-2026",
      "priority": "high"
    }
  ],
  "output_path": "/root/workspace/apollo-output/tat4-draft.md",
  "resume_instruction": "Inject research into Section 3, then finalize"
}
```

**Async model:** Telegram callbacks — Hermes notifies Donny when multi-step jobs complete

**Three-layer architecture:**

- wiki/pantheon-orchestration.md — SOURCE OF TRUTH (not written yet)
- ~/.hermes/skills/pantheon-comms/SKILL.md — EXECUTABLE (not written yet)
- ~/.hermes/profiles/{agent}/SOUL.md — APPEND ONLY reference

**DO NOT write pantheon-orchestration.md until:**

- Cognee bootstrap complete (wiki pages ingested)
- Athena git lock resolved ✓ (resolved Session 18)
- TG delivery fixed for Argus

## SESSION 19 PRIORITY ORDER

1. **Fix Argus TG delivery** — bypass Hermes CLI, call Telegram Bot API directly
   Get bot token: grep "TELEGRAM|BOT_TOKEN" /root/.hermes/.env | sed 's/=.*/=SET/'
   Replace line 226 in argus-daily-brief.sh with direct curl to Telegram API
   Then verify: manual run should deliver clean brief to @DVS_HermesBot TG

1. **Kristina/RewriteBeforeYouSend Google Drive setup** — client is waiting
   - Create /RewriteBeforeYouSend/ folder structure in Google Drive
   - raw-uploads/ working/ finished/ brand-guidelines/
   - Email → Hermes → Aphrodite pipeline
   - Aphrodite processes → outputs to finished/ → notifies Kristina

1. **Bootstrap Cognee with all wiki pages**
   Run /root/workspace/my-wiki/scripts/bootstrap_cognee.py with correct env vars
   All historical wiki content enters the knowledge graph

1. **Activate Cognee in Hermes config**
   sed -i "s|provider: ''|provider: 'cognee'|" ~/.hermes/config.yaml
   Restart Hermes gateway

1. **Write pantheon-orchestration.md** — now unblocked
   Then append Pantheon Protocol section to all 9 SOUL.md files (append only)

1. **Verify Athena end-to-end** — research pipeline live test
   Tavily key confirmed working — wire into Athena's research flow

1. **Truth About Trust Chapter 4** — Apollo ready to write
   Use invoke-apollo.sh with voice profile

## ARGUS DAILY BRIEF — SAMPLE OUTPUT SESSION 18

Brief confirmed containing real signals including:

- Vitalik Buterin pushing Ethereum builders beyond clone chains
- Ethereum Trillion Dollar Security Initiative
- x402 and ERC-8004 AI agent payment infrastructure
- AI x Ethereum convergence content
- Gnosis/Safe ecosystem updates

10 signals scored ≥7, 6 signals scored ≥8 (inbox) in final confirmed run.

## APOLLO INVOCATION — CORRECT METHOD

```bash
# 1. Build prompt file with voice profile
python3 - > /tmp/apollo-prompt.txt << 'PYEOF'
voice = open("/root/.hermes/profiles/apollo/apollo-voice-profile.md").read()
task = "YOUR TASK HERE"
print("[VOICE PROFILE]\n" + voice + "\n\n[TASK]\n" + task)
PYEOF

# 2. Run direct via Gemini Flash on OpenRouter
HERMES_BIN="/root/.hermes/hermes-agent/venv/bin/hermes"
source /root/.hermes/.env 2>/dev/null || true
PROMPT=$(cat /tmp/apollo-prompt.txt)
$HERMES_BIN chat -Q -q "$PROMPT" --provider openrouter \
  --model "google/gemini-2.0-flash-001" > output.md
```

## APHRODITE TRAINING DIRECTORY

Location: /root/workspace/aphrodite-training/

Contents confirmed:

- bin/tiktok-editor.sh — production ready, 6 platforms, optional SRT captions
- bin/carousel-maker.sh — exists, contents not verified
- neil-patel/ — 8 training PDFs ingested
- neil-patel-framework-summary.md
- client-deliverables/rewritebeforeyousend-campaign.md

Decision needed: keep aphrodite-training/ or restructure to aphrodite-studio/

## GITHUB STATE

- Repo: github.com/DVSLewis/my-wiki (PUBLIC)
- Last confirmed push: Session 18 — multiple commits during Argus debugging
- Most recent commit: Argus Brief 2026-04-28 (live brief with 10 signals)
- Cache-bust format: CONTEXT.md?v=YYYYMMDD
- Git push confirmed working from Zo

## TECHNICAL REFERENCE — ARGUS SCRIPT INTERNALS

File: /root/workspace/my-wiki/scripts/argus-daily-brief.sh

Key variables:

- DATE: TZ=Europe/Berlin (CET/CEST aware)
- BRIEF_OUT: exported so cognee_block.py can read it
- MODEL_NAME: google/gemini-2.0-flash-001 (TG send only — Hermes CLI)
- Scoring model: gpt-4o-mini via OpenAI direct
- TIMEOUT_VAL: 120 (Hermes CLI calls), urllib timeout: 60s (OpenAI calls)
- Signals scored: top 25 from Tavily fetch
- Retry logic: 3 attempts, 10s backoff on scoring failures

Key file paths:

- Script: /root/workspace/my-wiki/scripts/argus-daily-brief.sh
- Backup: /root/workspace/my-wiki/scripts/argus-daily-brief.sh.bak
- Cognee block: /root/workspace/my-wiki/scripts/cognee_block.py
- Brief output: /root/workspace/my-wiki/wiki/daily-brief-YYYY-MM-DD.md
- Inbox output: /root/workspace/my-wiki/raw/daily-inbox/YYYY-MM-DD.md
- Log: /tmp/argus-brief.log (session only — not persistent)

## NOTE FOR FUTURE PROJECT: THE STRUGGLE OF THE TRUSTLESS STATE

- Academic paper, 10-20 pages, ETHReS
- Thesis: the paradox of trustless architecture generating new trust dependencies
- Data sources: DeFi Llama, IQ.wiki (surfaced by Argus Session 18), academic literature
- Authors: Donny Lewis + Apollo
- Workflow: Athena researches → Apollo drafts in Donny's voice → Donny edits
- Purpose: genuine intellectual curiosity + swarm capability test
- Connection: complements ETHis 2026 "Trust Applied" talk

## NEW SESSION START INSTRUCTIONS

Fetch and read both files, then confirm ready:

https://raw.githubusercontent.com/DVSLewis/my-wiki/main/wiki/CONTEXT.md?v=20260428
https://raw.githubusercontent.com/DVSLewis/my-wiki/main/wiki/references.md?v=20260428

Then say: "I have read CONTEXT.md and references.md. Ready to continue — what is the priority today?"
