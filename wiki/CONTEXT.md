# DVS Agent Swarm — Master Context File
Last updated: April 23 2026 — Merged from Sessions 1, 2, and 3
Purpose: Complete context for any new Claude session. Read this first, then references.md. You are then fully operational.

## HOW TO START A NEW SESSION
Read this file completely. Read wiki/references.md completely.
Then say: "I have read CONTEXT.md and references.md. Last session ended with [X]. Ready to continue — what is the priority today?"

## END OF SESSION PROTOCOL
1. Update this CONTEXT.md with everything that happened
2. Update references.md if new sources were added
3. Run from Mac terminal:
cd ~/Documents/my-wiki
git add wiki/CONTEXT.md wiki/references.md
git commit -m "Session handoff — [date]"
git push origin main

---

## 1. WHO WE ARE WORKING WITH

Donny Lewis (DVSLewis)
Based: Munich Germany (primary) and United States
Languages: English, French, German fluent
Profession: Ecosystem operator, writer, model, actor, creative director, public speaker, Web3 veteran

Current roles:
- Core contributor ETHis 2026 (July 2-3 Deutsches Museum Munich)
- Contributing editor IRK Magazine Paris
- Creative Director Beyond Design Agency
- Co-founder WeTryBetter nonprofit
- Strategy Viridis green-tech DAO Munich
- Independent Web3 advisory 8 plus years

Contact:
- Email: donny@donnylewis.com
- Telegram: @DVS_HermesBot
- GitHub: DVSLewis
- Website: donnylewis.com
- ETHis: ethis.xyz

Writing: Thousands of pages published work — primary corpus for Apollo voice training
Unpublished: Two major screenplays (confidential — never reference or share)
Security: Recently rebuilt Mac from scratch after MetaMask browser extension attack
Devices: German phone primary secure device, US ATT phone isolated from all clouds
Hardware wallets: Ledger and SafePal available
Password manager: Bitwarden set up, not fully populated

Working relationship rules:
- Treat Donny as trusted co-worker, not a user
- Direct honest dialogue always, no sycophancy
- Flag better alternatives BEFORE starting a process, never after
- Security is priority one in all decisions
- Credit efficiency matters — flag expensive operations before running them
- When in doubt ask one clarifying question

---

## 2. WHAT WE ARE BUILDING

A full AI agent swarm running 24/7, accessible via Telegram, built on Hermes Agent framework by Nous Research, powered primarily by Claude Sonnet 4.6, hosted on Zo Computer paid plan.

This is a full Web3 autonomous agent economy with:
- Nine specialized mythological agents with distinct roles and model assignments
- Persistent knowledge base on Karpathy LLM Wiki architecture
- On-chain wallet infrastructure via Open Wallet Standard
- DeFi execution via defi-skills by Nethermind
- Ethereum data access via Ethereum MCP
- x402 machine-to-machine payment rails (future)
- EIP-8004 agent identity and reputation (future)

---

## 3. THE NINE AGENT PANTHEON

Agent | Role | Model | Status
Hermes | Orchestrator and Messenger | Claude Sonnet 4.6 | RUNNING on Zo
Athena | Research and Knowledge, Wiki Maintainer | Claude Sonnet 4.6 | NOT BUILT
Apollo | Writing and Creative Voice | GPT-4o via OpenRouter | NOT BUILT
Iris | Operations and Communications | Gemini Flash via OpenRouter | NOT BUILT
Hephaestus | Code and Technical | DeepSeek via OpenRouter | NOT BUILT
Midas | Commerce and x402 Payments | Claude Sonnet 4.6 | NOT BUILT
Janus | Trading and Finance | Claude Sonnet 4.6 (Opus on escalation) | NOT BUILT
Argus | Monitoring and Security | Gemini Flash via OpenRouter | NOT BUILT
Aphrodite | Marketing and Creative Direction | Gemini Flash via OpenRouter | NOT BUILT

Model rationale:
- Hermes Athena Midas Janus use Sonnet: orchestration, research, financial accuracy required
- Apollo uses GPT-4o: Donny has trained ChatGPT on his writing for months, voice partially learned there already
- Hephaestus uses DeepSeek: excellent at code, fraction of Sonnet cost
- Iris Argus Aphrodite use Gemini Flash: lightweight ops, monitoring, creative briefs
- Opus available as escalation model for Janus on high-stakes trades above limits

Architectural note on Iris and Argus:
These two are better implemented as Hermes skills calling the Zo API at https://api.zo.computer/zo/ask rather than full separate agent builds. Zo does the execution, Hermes does the orchestration. This is more efficient and uses Zo's built-in capabilities.

---

## 4. INFRASTRUCTURE STATUS

Zo Computer:
- Plan: Paid, always-on confirmed
- User: root
- Home: /root
- Workspace: /root/workspace
- Hermes location: ~/.hermes/
- Wiki clone: /root/workspace/my-wiki
- Zo API endpoint: https://api.zo.computer/zo/ask
- ZO_CLIENT_IDENTITY_TOKEN: check with echo $ZO_CLIENT_IDENTITY_TOKEN

Hermes Agent:
- Status: RUNNING
- Model: claude-sonnet-4-6
- Provider: Anthropic
- Gateway: Running as background process on Zo paid plan
- Port: 8644
- SOUL.json: Loaded via prefill_messages_file
- SOUL.md: Written with full pantheon context
- Telegram: Connected as @DVS_HermesBot
- Email: Connected as donny@donnylewis.com
- Memory: Enabled
- Compression: Enabled
- Tirith security: Enabled (flags dangerous commands)

GitHub Wiki Repo:
- Repo: github.com/DVSLewis/my-wiki (PRIVATE)
- Local clone on Mac: ~/Documents/my-wiki
- Local clone on Zo: /root/workspace/my-wiki
- Branch: main
- Auth: Personal access token (regenerate at github.com if expired, 90 day tokens)

---

## 5. REPO FILE STRUCTURE

my-wiki/
README.md
raw/ (does not exist yet — needs to be created)
wiki/
  CONTEXT.md (this file)
  SOUL.md (Hermes constitution)
  about-donny.md (full Donny profile)
  index.md (empty — Athena will maintain)
  references.md (all resources and URLs)
schema/
  CLAUDE.md (agent operational schema)
  SOUL.json (Hermes prefill messages — more reliable than SOUL.md alone)
logs/
  log.md (empty — agents will append)
assets/ (empty)

---

## 6. ENVIRONMENT VARIABLES

Location: ~/.hermes/.env on Zo

ANTHROPIC_API_KEY — SET
TELEGRAM_BOT_TOKEN — SET (regenerated after accidental exposure in chat)
EMAIL_ADDRESS=donny@donnylewis.com — SET
EMAIL_IMAP_HOST=imap.gmail.com — SET
EMAIL_SMTP_HOST=smtp.gmail.com — SET
GITHUB_TOKEN — NOT SET (needed for Hermes Skills Hub access)
OPENROUTER_API_KEY — NOT SET (needed for multi-model routing and compression)
ZO_CLIENT_IDENTITY_TOKEN — NOT VERIFIED (check echo $ZO_CLIENT_IDENTITY_TOKEN on Zo)
ETHERSCAN_API_KEY — NOT SET (needed for Ethereum MCP)

---

## 7. TERMINAL NOTES

On Zo terminal:
- If hermes command not found: source ~/.zshrc
- Gateway restart: hermes gateway stop and then hermes gateway run and symbol
- Check gateway: send Telegram message to @DVS_HermesBot
- File writing: use cat heredoc method, nano has paste issues in Zo terminal
- Example: cat > filename << ENDOFFILE then content then ENDOFFILE

On Mac terminal:
- Wiki location: ~/Documents/my-wiki
- Always cd ~/Documents/my-wiki before git commands
- Git push needs GitHub personal access token as password
- If push rejected: git pull origin main --rebase then git push origin main

---

## 8. NEXT SESSION PRIORITY TASKS

In order of priority:

1. Set Cowork model to Sonnet not Opus
   Claude desktop app Settings, saves significant credits immediately

2. OpenRouter setup
   Sign up at openrouter.ai
   Get API key
   Add to ~/.hermes/.env as OPENROUTER_API_KEY=key
   Restart gateway
   Fixes compression warning and enables multi-model swarm

3. Add GITHUB_TOKEN to ~/.hermes/.env
   Generate at github.com Settings Developer settings Personal access tokens
   Enables Hermes Skills Hub access

4. Verify ZO_CLIENT_IDENTITY_TOKEN
   Run: echo $ZO_CLIENT_IDENTITY_TOKEN on Zo terminal
   Add to .env if present

5. Create raw/ folder and add Karpathy LLM Wiki source
   mkdir -p /root/workspace/my-wiki/raw
   Download karpathy gist and save as raw/karpathy-llm-wiki.md

6. Install Ethereum MCP on Zo
   curl -fsSL https://raw.githubusercontent.com/ETHCF/ethereum-mcp/main/install.sh | bash
   Requires free Etherscan API key from etherscan.io/apis

7. Install defi-skills on Zo
   npx clawhub install defi-skills
   Required for Janus DeFi execution

8. Install OWS on Zo (not Mac)
   npm install -g @open-wallet-standard/core
   ows wallet create --name agent-treasury
   Paper backup of keys immediately after

9. Build Athena profile (first agent after Hermes)
   hermes profile create athena on Zo
   Write Athena SOUL.md with wiki maintenance instructions

10. Create apollo-private GitHub repo
    For unpublished screenplays, poems, essays
    Never goes to NotebookLM or public services

11. Read dependency graph X post
    x.com/51bodila/status/2046982199455428878
    Critical for agent build ordering

12. Download Hermes Orange Book PDF
    github.com/alchaincyf/hermes-agent-orange-book
    Add to raw/ as primary implementation reference

13. Install ETH24 news scraper
    github.com/ETHCF/eth24
    Athena primary Ethereum news feed

---

## 9. AGENT SPECIFICATIONS

Hermes — RUNNING
Model: Claude Sonnet 4.6
SOUL.md: Written and loaded
SOUL.json: Written and loaded via prefill_messages_file
Role: Primary interface, coordinates all other agents, routes tasks
Knows: Full pantheon, Donny profile, priority projects, security rules

Athena — NOT BUILT
Model: Claude Sonnet 4.6
Core job: Wiki maintenance, source ingestion, research synthesis
Implements: Full Karpathy LLM Wiki pattern (ingest, query, lint)
Tool access: GitHub, web search, Ethereum MCP (for Web3 research), ETH24 news feed
First task when built: Read and ingest all unread X posts from references.md queue

Apollo — NOT BUILT
Model: GPT-4o via OpenRouter
Core job: Writing in Donny's voice across all formats
Note: Donny has partially trained ChatGPT on his writing already — Apollo inherits this
Corpus: Thousands of pages published work plus private unpublished work
Private repo: apollo-private (not yet created)
Formats known: Philosophy essays, fiction, poetry, screenplays, Web3 ecosystem writing
Voice registers: Philosophical long-form, Web3 technical, editorial, creative

Iris — NOT BUILT
Model: Gemini Flash via OpenRouter
Core job: Calendar, scheduling, email triage, operational coordination
Architecture: Hermes skill calling Zo API, not full agent build
ETHis priority: Speaker curation, partner coordination, founder networking

Hephaestus — NOT BUILT
Model: DeepSeek via OpenRouter
Core job: Code writing, debugging, GitHub management, Web3 tooling
DeepSeek competitive with Sonnet on code at fraction of cost

Midas — NOT BUILT
Model: Claude Sonnet 4.6
Core job: Machine-to-machine micropayments, agent commerce, x402 payment rails
Tool access: OWS wallet, Ethereum MCP, x402 rails, EIP-8004 identity
Security: Hard spending limits, allowlisted recipients, human approval above threshold

Janus — NOT BUILT
Model: Claude Sonnet 4.6 (escalates to Opus for high-stakes decisions)
Core job: DeFi execution, portfolio monitoring, yield optimization
Tool access: defi-skills (53 actions across 13 protocols), Ethereum MCP (153 tools), OWS wallet
Allowlisted protocols: Aave, Uniswap, Lido, EigenLayer, Compound, Balancer, Curve, MakerDAO, Rocket Pool, Pendle
Security rules: Hard limits per transaction and per day, mandatory simulation before execution, human approval above routine threshold, never arbitrary contract calls

Argus — NOT BUILT
Model: Gemini Flash via OpenRouter
Core job: System monitoring, security alerts, anomaly detection
Architecture: Hermes cron job calling Zo API for lightweight monitoring

Aphrodite — NOT BUILT
Model: Gemini Flash via OpenRouter
Core job: Social media, marketing strategy, creative direction
Platforms: X, Instagram, YouTube, TikTok, Facebook
Serves: Donny personal brand, Beyond Design Agency, app marketing (TBD)
Note: X posting only after Apollo voice established and with Donny review gate

---

## 10. SECURITY NOTES

- No browser crypto extensions — hardware wallet only
- Old MetaMask wallets with onchain history — migrate to hardware, treat as view-only
- US ATT phone isolated from all cloud services
- German phone is primary secure device and authenticator
- Bitwarden to be populated with all credentials
- OWS wallet vault to live on Zo, not Mac
- Paper backup of all OWS keys required immediately after creation
- Telegram bot token was accidentally exposed in chat — regenerated immediately
- All financial operations require human approval above set limits
- Janus and Midas never operate without OWS policy engine

---

## 11. SESSION LOG

Session 1 — April 21 2026 (Claude chat)
- Set up Mac dev environment (Homebrew, Python, Git)
- Created GitHub wiki repo github.com/DVSLewis/my-wiki
- Wrote CLAUDE.md operational schema
- Installed Hermes on Zo
- Configured Telegram bot @DVS_HermesBot
- Connected email donny@donnylewis.com
- Configured webhooks port 8644
- Confirmed Hermes responding on Telegram

Session 2 — April 22 2026 (Claude chat)
- Confirmed always-on with Zo paid plan
- Wrote and deployed SOUL.md for Hermes
- Wrote about-donny.md full profile
- Added persistent memory entries to Hermes
- Submitted Geode Labs grant for ETHis via Cowork
- Created CONTEXT.md and references.md system
- Identified SOUL.json as more reliable than SOUL.md alone

Session 3 — April 23 2026 (parallel Claude chat)
- Wrote SOUL.json prefill messages implementation
- Cloned wiki repo to Zo at /root/workspace/my-wiki
- Researched and documented DeFi Skills by Nethermind
- Identified Zo API architecture for Iris and Argus
- Documented full environment variables needed
- Identified dependency graph X post as critical reading
- Identified self-hosting as long-term goal with three phases
- Reconciled both sessions into this master CONTEXT.md

---

## 12. SELF-HOSTING ROADMAP

Phase 1 (now): Zo as platform, build everything portable
Phase 2: Dedicated VPS when swarm is stable and proven
Phase 3: Full sovereign infrastructure — own Ethereum node, local models where appropriate

Portability rules:
- All credentials in .env with consistent naming
- No vendor lock-in in agent SOUL files
- Wiki on GitHub is already portable
- OWS wallet is already local-first
- Hermes is open source, runs anywhere
- OpenRouter abstracts model providers

---

## 13. INCOMPLETE ITEMS

- GITHUB_TOKEN not added to .env
- raw/ folder not created in wiki repo
- Karpathy LLM Wiki not yet in raw/
- OpenRouter not set up
- ZO_CLIENT_IDENTITY_TOKEN not verified
- Hermes Orange Book PDF not downloaded
- Cowork still on Opus not Sonnet
- 8 of 9 agents not yet built
- Apollo private GitHub repo not created
- Ethereum MCP not installed on Zo
- defi-skills not installed on Zo
- OWS not installed on Zo
- ETH24 not installed on Zo
- Etherscan API key not obtained
- All X posts in references.md queue not yet read
- Bitwarden not fully populated
