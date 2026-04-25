# DVS Agent Swarm — Session Context
Last updated: April 25 2026 (Session 10)

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
- SOUL.md and SOUL.json: written and loaded (all 9 agents)
- about-donny.md: written and in wiki/
- OpenRouter: SET
- XMCP: LIVE — 20 tools, authenticated as @Jerri_nft via OAuth1, Fileverse MCP deployed on Cloudflare

## NINE AGENTS
1. Hermes — Orchestrator — RUNNING — Claude Sonnet 4.6
2. Athena — Research/Wiki — ACTIVE — Claude Sonnet 4.6
3. Apollo — Writing/Voice — SOUL WRITTEN — GPT-4o via OpenRouter
4. Iris — Operations — SOUL WRITTEN — Gemini Flash via OpenRouter
5. Hephaestus — Code — ACTIVE — DeepSeek via OpenRouter
6. Midas — Commerce/x402 — SOUL WRITTEN — Claude Sonnet 4.6
7. Janus — Trading/DeFi — SOUL WRITTEN — Claude Sonnet 4.6
8. Argus — Monitoring — CONFIGURED — Gemini Flash via OpenRouter, daily brief pipeline
9. Aphrodite — Marketing — SOUL WRITTEN — Gemini Flash via OpenRouter

Note: Iris and Argus build as Hermes skills calling Zo API, not full agents.
Apollo: Donny has ChatGPT voice training already done — port to GPT-4o.
Janus needs: defi-skills + Ethereum MCP + OWS wallet.

## ENV VARS NEEDED (on Zo ~/.hermes/.env)
- ANTHROPIC_API_KEY: SET (rotated Apr 23)
- TELEGRAM_BOT_TOKEN: SET
- EMAIL_ADDRESS: SET
- OPENROUTER_API_KEY: SET (live Apr 24)
- GITHUB_TOKEN: NOT SET
- ETHERSCAN_API_KEY: NOT SET
- ZO_CLIENT_IDENTITY_TOKEN: SET AND VERIFIED

## NEXT PRIORITIES
1. Apollo voice activation - training corpus assembled at /root/workspace/apollo-training/voice/ (private, not in wiki repo)
2. Ethereum MCP stack
3. OWS wallet
4. Janus Midas activation
5. CONTEXT.md protection hook via Hephaestus

## ZO TERMINAL NOTES
- hermes not found: source ~/.zshrc
- Gateway restart: hermes gateway stop && hermes gateway run &
- File writing: use cat heredoc method, nano has paste issues
- Git push needs GitHub personal access token as password
- If push rejected: git pull origin main --rebase then push

## INTELLIGENCE PIPELINES

### Argus Daily Brief (automated, runs 9am Berlin daily)
- Script: /root/workspace/argus-daily-brief.sh
- Reads RSSHub feeds for all 23 monitored accounts (3 tiers)
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
Session 12 Apr 25: Apollo activated with voice profile (241-line Donny voice), invoke-apollo skill created, Hephaestus m-dash hard rule added, Aphrodite client deliverables (RewriteBeforeYouSend campaign) shown but not yet saved to filesystem. Session logged manually via Zo terminal.
Session 12 Apr 25: Apollo activated with voice training. First essay written — ethis-2026-essay.md. Hephaestus invoke-apollo skill in progress.
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
Session 11 Apr 25 — All 9 agent SOUL.md files fully integrated with DVS Oath and individual principles. Pantheon soul complete.
## END OF SESSION PROTOCOL
1. Update this file — keep it under 2000 words
2. Update references.md if new sources added
3. cd ~/Documents/my-wiki
4. git add wiki/CONTEXT.md wiki/references.md
5. git commit -m "Session handoff [date]"
6. git push origin main

## NEW SESSION START PROMPT
Fetch and read these two files:
https://raw.githubusercontent.com/DVSLewis/my-wiki/main/wiki/CONTEXT.md
https://raw.githubusercontent.com/DVSLewis/my-wiki/main/wiki/references.md
Then say: I have read CONTEXT.md and references.md. Ready to continue — what is the priority today?

