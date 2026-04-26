# DVS Agent Swarm — Session Context
Last updated: April 26 2026 (Session 13)

## READ FIRST
Fetch references.md for full resource details.
Ask Donny what the priority is today.

## WHO
Donny Lewis. Munich/US. EN/FR/DE.
Ecosystem operator, writer, model, actor, creative director.
Core contributor ETHis 2026 (July 2-3 Deutsches Museum Munich).
Editor IRK Magazine Paris. Creative Director Beyond Design Agency.
Co-founder WeTryBetter. Viridis green-tech DAO.
Web3 8+ years. Ethereum, DAOs, ReFi, public goods.
Treat as trusted co-worker. Security priority one.
Flag better options BEFORE starting. Flag expensive operations.

## INFRASTRUCTURE
- Zo Computer: paid plan, always-on
- Hermes: RUNNING on Zo, Claude Sonnet 4.6
- Telegram: @DVS_HermesBot live 24/7
- Email: donny@donnylewis.com connected
- GitHub wiki: github.com/DVSLewis/my-wiki (PUBLIC)
- Mac wiki: ~/Documents/my-wiki
- Zo wiki: /root/workspace/my-wiki
- Hermes config: ~/.hermes/ on Zo
- SOUL.md files: LIVE at ~/.hermes/profiles/{agent}/SOUL.md — private, NOT in git. All 9 agents have SOULs written. Safe from external exposure.
- about-donny.md: written and in wiki/
- OpenRouter: SET
- XMCP: LIVE — 20 tools, authenticated as @Jerri_nft via OAuth1, Fileverse MCP deployed on Cloudflare
- Fileverse MCP: VERIFIED WORKING — storage_id 53c6777f840f8a03a5001b53, all tools operational (create, read, list, delete via MCP protocol through Hermes)
- DVS Private Storage: /root/workspace/dvs-private/ — NOT in git, NOT on GitHub. Agent secrets, private goals, credentials. Athena has read access via MANIFEST.md.

## NINE AGENTS — ALL ACTIVE
1. Hermes — Orchestrator — RUNNING — Claude Sonnet 4.6, full Pantheon SOUL loaded
2. Athena — Research/Wiki — ACTIVE, producing strong writing, read-locked when needed
3. Apollo — Writing/Voice — ACTIVE, invoke-apollo skill operational with hard rules (no m-dashes, no crypto Twitter voice), 241-line Donny voice profile
4. Iris — Operations — SOUL WRITTEN — Gemini Flash via OpenRouter
5. Hephaestus — Code — ACTIVE — DeepSeek via OpenRouter
6. Midas — Commerce/x402 — SOUL WRITTEN — Claude Sonnet 4.6
7. Janus — Trading/DeFi — SOUL WRITTEN — Claude Sonnet 4.6
8. Argus — Monitoring — CONFIGURED — Gemini Flash via OpenRouter, daily brief pipeline running
9. Aphrodite — Marketing — SOUL WRITTEN — Gemini Flash via OpenRouter, RewriteBeforeYouSend client active

Note: Iris and Argus build as Hermes skills calling Zo API, not full agents.
Apollo: Donny has ChatGPT voice training already done — port to GPT-4o.
Janus needs: defi-skills + Ethereum MCP + OWS wallet.

## PRIVATE STORAGE (DVS-PRIVATE)
Private files live at: /root/workspace/dvs-private/ — NOT in git, NOT on GitHub.
- MANIFEST.md — tracks what's in private storage, Athena reads this to know what's there without burning API calls
- dvs-vision.md — Donny's personal goals + 5-year vision + Athena's collective intelligence framing (written via Fileverse MCP)

## ENV VARS NEEDED (on Zo ~/.hermes/.env)
- ANTHROPIC_API_KEY: SET
- TELEGRAM_BOT_TOKEN: SET
- EMAIL_ADDRESS: SET
- OPENROUTER_API_KEY: SET
- GITHUB_TOKEN: SET — stored in ~/.git-credentials (not in .env files), accessed via git's credential.helper=store. Used by git push to DVSLewis/my-wiki. NEVER uncomment or export into .env files.
- ETHERSCAN_API_KEY: NOT SET
- ZO_CLIENT_IDENTITY_TOKEN: SET AND VERIFIED

## ZO TERMINAL NOTES
- hermes not found: source ~/.zshrc
- Gateway restart: hermes gateway stop && hermes gateway run &
- File writing: use cat heredoc method, nano has paste issues
- Git push needs GitHub personal access token as password
- If push rejected: git pull origin main --rebase then push
- Fileverse MCP: use hermes mcp call fileverse_storage_create with auth token from ~/.hermes/.env — tools work via Hermes MCP protocol

## INTELLIGENCE PIPELINES

### Argus Daily Brief (automated, runs 9am Berlin daily)
- Script: /root/workspace/argus-daily-brief.sh
- Reads RSSHub feeds for all 26 monitored accounts (3 tiers)
- Scores posts 1-10 via Gemini Flash free model
- Writes: wiki/daily-brief-YYYY-MM-DD.md (7+ posts)
- Saves: raw/daily-inbox/YYYY-MM-DD.md (8+ posts for Athena)
- Sends: Telegram concise summary to Donny
- Pushes: to GitHub
- Logs: /tmp/argus-brief.log
- Account tiers: wiki/argus-monitored-accounts.md
- Template: wiki/argus-brief-template.md

### Athena Weekly Synthesis (automated, runs 10am Berlin Mon + Thu)
- Script: /root/workspace/athena-weekly-synthesis.sh
- Reads all raw/daily-inbox/ files since last synthesis
- Identifies top insights, patterns, emerging signals
- Updates wiki/references.md with new high-value sources
- Creates: wiki/knowledge-synthesis-YYYY-MM-DD.md
- Sends: Telegram knowledge base update summary to Donny
- Pushes: to GitHub
- Logs: /tmp/athena-synthesis.log
- State tracker: /root/workspace/my-wiki/.last-synthesis

## SESSION LOG
Session 13 Apr 26: Fileverse MCP verified working (storage_id 53c6777f840f8a03a5001b53). Private storage /root/workspace/dvs-private/ set up with MANIFEST.md. DVS Vision document created via Fileverse MCP — Donny's personal goals + Athena's collective intelligence framing. Athena producing strong writing (DVS Vision section). All 9 agents active. Argus pipeline running. Hermes SOUL, Apollo SOUL, Aphrodite SOUL all updated with latest principles. invoke-apollo hard rules confirmed (no m-dashes, no crypto Twitter). CONTEXT.md updated and ready for next session.

Session 14 Apr 26: Tavily search integrated into Athena pipeline. tavily-python installed in /root/workspace/my-wiki/scripts/. TavilySearch class built with TavilySearchContext for persistent research context, TavilySearchResults for one-shot queries, and search_and_ingest() for wiki-wiki ingestion pipeline. All 26 Argus-monitored accounts now have fresh summaries via Tavily. references.md updated with Tavily search SDK. CONTEXT.md + references.md pushed to GitHub. Athena now has both RSS aggregation (Argus) and live web search (Tavily) in her intelligence pipeline.
Session 12 Apr 25: Apollo activated with voice profile (241-line Donny voice), invoke-apollo skill created, Hephaestus m-dash hard rule added. Aphrodite RewriteBeforeYouSend campaign shown but not yet saved to filesystem.
Session 11 Apr 25: All 9 agent SOUL.md files fully integrated with DVS Oath and individual principles. Pantheon soul complete.
Session 1 Apr 21: Mac setup, GitHub wiki, Hermes install, Telegram live
Session 2 Apr 22: Zo paid plan, SOUL.md, about-donny.md, Geode grant via Cowork
Session 3 Apr 23: SOUL.json, Zo API architecture, merged CONTEXT.md, repo made public
Session 4 Apr 23: Athena built, Cognee installed, API key rotated, gateway stable
Session 5 Apr 23: SOUL.md written for all 7 remaining agents (Apollo, Iris, Hephaestus, Midas, Janus, Argus, Aphrodite) — all 9 SOULs complete
Session 6 Apr 24: Full intelligence pipeline built — Argus daily brief + Athena synthesis + cron jobs set
Session 7 Apr 24: XMCP live (20 tools, @Jerri_nft OAuth1), OpenRouter live, Argus CONFIGURED, all crons verified (Argus 9am CET daily, Athena 10am CET Mon+Thu)
Session 8 Apr 25: CONTEXT.md updated — Athena ACTIVE, Athena is in a read-only locked state for the rest of the day., OPENROUTER_API_KEY + ZO_CLIENT_IDENTITY_TOKEN verified, XMCP 20 tools authenticated. Sunday goal set: full swarm operational.
Session 9 Apr 25: Ongoing — building toward full swarm.

## END OF SESSION PROTOCOL
1. Update this file — keep it under 2000 words
2. Update references.md if new sources added
3. cd ~/Documents/my-wiki
4. git add wiki/CONTEXT.md wiki/references.md
5. git commit -m "Session handoff [date]"
6. git push origin main

## NEW SESSION START PROMPT
Fetch and read these two files:
https://raw.githubusercontent.com/DVSLewis/my-wiki/main/wiki/CONTEXT.md?v=$(date +%Y%m%d)
https://raw.githubusercontent.com/DVSLewis/my-wiki/main/wiki/references.md?v=$(date +%Y%m%d)
Then say: I have read CONTEXT.md and references.md. Ready to continue — what is the priority today?