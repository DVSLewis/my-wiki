# DVS Session Handoff — April 27, 2026 (Session 17)

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
- OpenRouter: CONFIRMED WORKING
- OpenAI: CONFIRMED WORKING (added Session 17 for embeddings)
- Private storage: /root/workspace/dvs-private/ — not in git
- Pre-commit hook: changed from REJECT to WARN (allows CONTEXT.md size changes)
- CONTEXT.md 2000 word limit: REMOVED — full content now preserved

## COGNEE STATUS — FULLY OPERATIONAL ✓

**This is the biggest win of Session 17.**

Cognee 1.0.2 is now confirmed working end-to-end:

- remember() — WORKING ✓
- cognify() — WORKING ✓ (graph extraction confirmed, 9 agents as nodes)
- search(query_type=SearchType.CHUNKS) — WORKING ✓ (returned results)
- Knowledge graph built with nodes and edges for all 9 DVS agents

### CRITICAL: How to run Cognee correctly

All environment variables MUST be set at shell level BEFORE Python starts.
The lru_cache loads config at import time — runtime injection doesn't work.

**The correct run command:**

```bash
OPENAI_KEY=$(grep "^OPENAI_API_KEY=" ~/.hermes/.env | tail -1 | cut -d'=' -f2)
ORKEY=$(grep "^OPENROUTER_API_KEY=" ~/.hermes/.env | cut -d'=' -f2)

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
- Database path: /usr/local/lib/python3.12/site-packages/cognee/.cognee_system/databases

### What's confirmed working in Cognee

- forget(everything=True) — clears all vectors and graph
- remember("text") — ingests text to vector store
- cognify() — builds knowledge graph from ingested data
- search(query, query_type=SearchType.CHUNKS) — vector similarity search

### Available SearchType values

SUMMARIES, CHUNKS, RAG_COMPLETION, TRIPLET_COMPLETION, GRAPH_COMPLETION,
GRAPH_COMPLETION_DECOMPOSITION, GRAPH_SUMMARY_COMPLETION, CYPHER,
NATURAL_LANGUAGE, GRAPH_COMPLETION_COT, GRAPH_COMPLETION_CONTEXT_EXTENSION,
FEELING_LUCKY, TEMPORAL, CODING_RULES, CHUNKS_LEXICAL

### Next Cognee steps (Session 18)

1. Bootstrap all wiki pages into Cognee:
   Run /root/workspace/my-wiki/scripts/bootstrap_cognee.py
   (Script exists from prior session design — may need the correct env vars added)
2. Wire delta-sync: after Athena writes any wiki page, call cognee.remember()
3. Replace Athena's grep-based search with cognee.search(SearchType.CHUNKS)
4. Activate in Hermes config: set provider: cognee in ~/.hermes/config.yaml
5. Test session memory: each agent uses session_id = agent_name + date

## HONEST AGENT STATUS

### CONFIRMED WORKING ✓

- Hermes — RUNNING — orchestrator — Telegram @DVS_HermesBot live
- Apollo — ACTIVE — Gemini Flash via OpenRouter — invoke-apollo.sh working
  Voice profile 252 lines PROVEN. Truth About Trust 3 complete (22,598 bytes).
- Cognee memory layer — FULLY OPERATIONAL as of Session 17

### PARTIALLY BUILT — NOT VERIFIED END TO END ✗

- Athena — READ LOCKED from git wipe incident — cannot push to git
  Tavily installed but API key never confirmed working end-to-end
  Research pipeline exists but never verified live with real output
  Fix needed: restore git push permissions safely
- Argus — Cron job exists, script exists, BUT:
  Tavily API key status unknown — never confirmed in .env
  Telegram delivery to Hermes never verified end-to-end
  Daily briefs NOT confirmed reaching Donny via Telegram
  This has been broken the entire time — not just recently
- Aphrodite — tiktok-editor.sh production ready (6 platforms, caption support) ✓
  carousel-maker.sh exists (contents not verified)
  Neil Patel training docs ingested
  BUT: No Google Drive architecture
  No way for Kristina to submit files or instructions
  No email-to-agent pipeline
  No delivery mechanism back to Kristina
  Kristina client deadline missed — needs to be prioritized Session 18

### SOUL WRITTEN — NOT BUILT ✗

- Iris — operations — NOT BUILT
- Midas — commerce — NOT BUILT (do not build until foundation solid)
- Janus — trading — NOT BUILT (do not build until foundation solid)

## PANTHEON ORCHESTRATION — DESIGNED, NOT WRITTEN

Architecture decisions locked in Sessions 16-17:

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
- ~/.hermes/profiles/{agent}/SOUL.md — APPEND ONLY reference (not written yet)

**SOUL append rule:** One new section added per agent, never rewrite existing content:
"## Pantheon Protocol — when I need help, complete task, return NEEDS block.
Format: see wiki/pantheon-orchestration.md"

**Cognee's role in routing:**
Every inter-agent call recorded → Cognee graph → Hermes queries routing history →
Next similar request routes smarter. This is the Karpathy recursive learning loop.

**DO NOT write pantheon-orchestration.md until:**

- Cognee bootstrap complete ✓ (Cognee now working — this unblocks it)
- Wiki pages ingested into Cognee
- Athena git lock resolved

## SESSION 18 PRIORITY ORDER

1. **Argus/Tavily fix** — verify TAVILY_API_KEY in .env, test brief end-to-end
   Donny has been without daily briefs the entire build. Fix this first.

```bash
grep "TAVILY" ~/.hermes/.env | sed 's/=.*/=SET/'
```

2. **Bootstrap Cognee with wiki** — ingest all wiki pages

```bash
# Run with correct env vars
OPENAI_KEY=$(grep "^OPENAI_API_KEY=" ~/.hermes/.env | tail -1 | cut -d'=' -f2)
ORKEY=$(grep "^OPENROUTER_API_KEY=" ~/.hermes/.env | cut -d'=' -f2)

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
python3 /root/workspace/my-wiki/scripts/bootstrap_cognee.py
```

3. **Kristina/RewriteBeforeYouSend Google Drive setup** — client is waiting
   - Create /RewriteBeforeYouSend/ folder structure in Google Drive
   - raw-uploads/ working/ finished/ brand-guidelines/
   - Email → Hermes → Aphrodite pipeline
   - Aphrodite processes → outputs to finished/ → notifies Kristina

4. **Resolve Athena git lock** — restore push permissions safely
   Athena was locked after git wipe incident. Determine safe permissions.

5. **Write pantheon-orchestration.md** — now unblocked by Cognee
   Then append Pantheon Protocol section to all 9 SOUL.md files (append only)

6. **Activate Cognee in Hermes config**

```bash
# Update config.yaml
sed -i "s|provider: ''|provider: 'cognee'|" ~/.hermes/config.yaml
# Restart Hermes gateway
```

7. **Verify Hermes skill: dvs-pantheon-comms**
   ~/.hermes/skills/autonomous-ai-agents/dvs-pantheon-comms/SKILL.md exists
   Review and update with confirmed protocol

## APHRODITE TRAINING DIRECTORY

Location: /root/workspace/aphrodite-training/
Contents confirmed:
- bin/tiktok-editor.sh — production ready, 6 platforms, optional SRT captions
- bin/carousel-maker.sh — exists, contents not verified
- neil-patel/ — 8 training PDFs ingested
- neil-patel-framework-summary.md
- client-deliverables/rewritebeforeyousend-campaign.md
aphrodite-studio/ workspace not yet created.
Decision needed: keep aphrodite-training/ or restructure to aphrodite-studio/

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

## KEY TECHNICAL LESSONS FROM SESSIONS 16-17

- "Designed and documented" ≠ "running and proven" — Cognee was never executed
- Cognee lru_cache: ALL env vars must be set at shell level before Python imports
- OpenRouter does NOT support embedding endpoints — OpenAI key required
- OpenRouter model ID format: openrouter/provider/model (e.g. openrouter/anthropic/claude-haiku-4.5)
- text-embedding-3-small max dimensions: 1536 (not 3072 default)
- forget() requires everything=True parameter in Cognee 1.0.2
- Cognee 1.0.2 API: remember/recall/forget/improve (dataset parameter removed)
- CONTEXT.md was being truncated to 93 lines due to 2000 word limit — now removed
- Pre-commit hook was blocking CONTEXT.md restoration — now set to WARN not REJECT
- Athena is git-push locked — only Zo or terminal can push to GitHub currently
- Security: never paste API keys in chat — always use shell interpolation

## GITHUB STATE

- Repo: github.com/DVSLewis/my-wiki (PUBLIC)
- Last confirmed push: Session 16 handoff (121 lines after Zo fix)
- Cache-bust format: CONTEXT.md?v=YYYYMMDD

## NEW SESSION START INSTRUCTIONS

Fetch and read both files, then confirm ready:

https://raw.githubusercontent.com/DVSLewis/my-wiki/main/wiki/CONTEXT.md?v=20260427
https://raw.githubusercontent.com/DVSLewis/my-wiki/main/wiki/references.md?v=20260427

Then say: "I have read CONTEXT.md and references.md. Ready to continue — what is the priority today?"
