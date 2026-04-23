# DVS Agent Swarm — Session Context
Last updated: April 23 2026

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
- SOUL.md and SOUL.json: written and loaded
- about-donny.md: written and in wiki/

## NINE AGENTS
1. Hermes — Orchestrator — RUNNING — Claude Sonnet 4.6
2. Athena — Research/Wiki — BUILT — Claude Sonnet 4.6
3. Apollo — Writing/Voice — NOT BUILT — GPT-4o via OpenRouter
4. Iris — Operations — NOT BUILT — Gemini Flash via OpenRouter
5. Hephaestus — Code — NOT BUILT — DeepSeek via OpenRouter
6. Midas — Commerce/x402 — NOT BUILT — Claude Sonnet 4.6
7. Janus — Trading/DeFi — NOT BUILT — Claude Sonnet 4.6
8. Argus — Monitoring — NOT BUILT — Gemini Flash via OpenRouter
9. Aphrodite — Marketing — NOT BUILT — Gemini Flash via OpenRouter

Note: Iris and Argus build as Hermes skills calling Zo API, not full agents.
Apollo: Donny has ChatGPT voice training already done — port to GPT-4o.
Janus needs: defi-skills + Ethereum MCP + OWS wallet.

## ENV VARS NEEDED (on Zo ~/.hermes/.env)
- ANTHROPIC_API_KEY: SET (rotated Apr 23)
- TELEGRAM_BOT_TOKEN: SET
- EMAIL_ADDRESS: SET
- OPENROUTER_API_KEY: NOT SET (do this first)
- GITHUB_TOKEN: NOT SET
- ETHERSCAN_API_KEY: NOT SET
- ZO_CLIENT_IDENTITY_TOKEN: SET AND VERIFIED

## NEXT PRIORITIES
1. Run Athena bootstrap to ingest wiki into Cognee
2. Sign up openrouter.ai, add OPENROUTER_API_KEY to ~/.hermes/.env
3. Add GITHUB_TOKEN to ~/.hermes/.env
4. Create raw/ folder in wiki repo
5. Install Ethereum MCP on Zo
6. Install defi-skills on Zo
7. Install OWS on Zo, create agent-treasury wallet, paper backup keys
8. Create apollo-private GitHub repo

## ZO TERMINAL NOTES
- hermes not found: source ~/.zshrc
- Gateway restart: hermes gateway stop && hermes gateway run &
- File writing: use cat heredoc method, nano has paste issues
- Git push needs GitHub personal access token as password
- If push rejected: git pull origin main --rebase then push

## SESSION LOG
Session 1 Apr 21: Mac setup, GitHub wiki, Hermes install, Telegram live
Session 2 Apr 22: Zo paid plan, SOUL.md, about-donny.md, Geode grant via Cowork
Session 3 Apr 23: SOUL.json, Zo API architecture, merged CONTEXT.md, repo made public
Session 4 Apr 23: Athena built, Cognee installed, API key rotated, gateway stable

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
