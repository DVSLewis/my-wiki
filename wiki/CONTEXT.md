# DVS Agent Swarm — Master Context File
Last updated: April 2026 · Sessions 1 and 2

## How to Use This File
Start every session with: "Read wiki/CONTEXT.md and 
references.md — that's your full context."
Append new session handoff to bottom after each session.

## Infrastructure Status
- Zo Computer: paid plan, always-on confirmed
- Hermes: installed and running on Zo
- Claude Sonnet 4.6: configured as main model
- Telegram: @DVS_HermesBot live 24/7
- Email: donny@donnylewis.com connected
- Webhooks: configured port 8644
- GitHub wiki: github.com/DVSLewis/my-wiki
- SOUL.md: written with full pantheon context
- about-donny.md: written and pushed to wiki
- CLAUDE.md: operational schema written
- Gateway: runs automatically on Zo paid plan

## File Locations
### On Mac
~/Documents/my-wiki — local wiki repo
~/Documents/my-wiki/schema/CLAUDE.md — agent constitution
~/Documents/my-wiki/wiki/about-donny.md — Donny profile
~/Documents/my-wiki/wiki/CONTEXT.md — this file
~/Documents/my-wiki/wiki/references.md — resources

### On Zo
~/.hermes/ — all Hermes config
~/.hermes/SOUL.md — Hermes personality
~/.hermes/.env — API keys
~/.hermes/config.yaml — main config
~/.hermes/skills/ — 71 bundled skills installed

### On GitHub
github.com/DVSLewis/my-wiki — main wiki repo
Private repo needed: apollo-private (not yet created)

## The Nine Agent Pantheon
1. Hermes — Orchestrator — RUNNING on Zo
2. Athena — Research and Knowledge — NOT YET BUILT
3. Apollo — Writing and Creative Voice — NOT YET BUILT
4. Iris — Operations and Communications — NOT YET BUILT
5. Hephaestus — Code and Technical — NOT YET BUILT
6. Midas — Commerce and x402 — NOT YET BUILT
7. Janus — Trading and Finance — NOT YET BUILT
8. Argus — Monitoring and Security — NOT YET BUILT
9. Aphrodite — Marketing and Creative Direction — NOT YET BUILT

## Zo Terminal Notes
- Use cat heredoc method for writing files, nano has paste issues
- If hermes not found: source ~/.zshrc
- Gateway restart: hermes gateway stop && hermes gateway run &
- Gateway runs in background on paid Zo plan
- Check gateway: send Telegram message to @DVS_HermesBot

## Next Session Priority Tasks
1. OpenRouter setup
   - Sign up at openrouter.ai
   - Add OPENROUTER_API_KEY to ~/.hermes/.env
   - Fixes compression warning
   - Enables multi-model swarm
2. Add persistent memory to Hermes
   hermes memory add "Donny's nine agents are..."
3. Create Athena profile
   hermes profile create athena
4. Connect wiki repo to Hermes on Zo
   cd ~/.hermes && git clone github.com/DVSLewis/my-wiki
5. Install Ethereum MCP
   github.com/ETHCF/ethereum-mcp
6. Install eth24 news scraper for Athena
   github.com/ETHCF/eth24
7. Set up OWS wallet infrastructure
   openwallet.sh — install on Zo not Mac
8. Set Cowork to Sonnet not Opus in settings
9. Create apollo-private GitHub repo
10. Set up Aphrodite social media skills

## Security Notes
- Anthropic API key saved in ~/.hermes/.env
- Telegram bot token regenerated after accidental exposure
- German phone is primary secure device
- US ATT phone isolated from all clouds
- Ledger and SafePal hardware wallets available
- OWS chosen for agent wallet infrastructure
- No browser crypto extensions
- Bitwarden set up but not fully utilized yet
- Old browser wallets with onchain history — migrate to hardware
- Paper backup of keys planned for OWS vault

## Key Decisions Made
- Zo over Hetzner — community trust, easier interface
- Sonnet not Opus for main agent — credit efficiency
- OWS for all agent wallets — security architecture
- GitHub as wiki backbone — version control and sync
- Telegram as primary agent interface
- Nine named mythological agents vs operational names
- apollo-private repo for unpublished creative work
- NotebookLM for knowledge synthesis (research only, not creative)
- cat heredoc method for all file writing in Zo terminal

## About Donny — Quick Reference
Full profile: wiki/about-donny.md
- Ecosystem operator, writer, model, actor
- Web3 veteran 8 plus years, Ethereum-aligned
- Core contributor ETHis 2026 July 2-3 Munich
  Deutsches Museum, 1500 attendees, 100 speakers
  Partners: BMW Siemens BlackRock JPMorgan TUM
- Contributing editor IRK Magazine Paris
- Creative Director Beyond Design Agency
- Co-founder WeTryBetter nonprofit
- Consultant Viridis green-tech DAO Munich
- Based Munich and US, EN FR DE fluent
- Thousands of pages published writing for Apollo
- Two major unpublished screenplays — confidential
- Recently rebuilt Mac from scratch after security incident
- Intel Mac, older hardware

## Working Relationship Rules
- Treat Donny as trusted co-worker not a user
- Always flag better alternatives BEFORE starting process
- Direct honest dialogue always
- Security is priority one in all decisions
- Credit efficiency matters — flag expensive operations
- Use Sonnet for routine, Opus only for complex reasoning
- Haiku for monitoring and simple scheduled tasks
- End every session by updating this file and pushing to GitHub

## Session Log
### Session 1 — April 21 2026
- Set up Mac dev environment
- Created GitHub wiki repo
- Wrote CLAUDE.md and about-donny.md
- Installed Hermes on Zo
- Configured Telegram, email, webhooks
- Confirmed always-on with Zo paid plan

### Session 2 — April 22 2026
- Fixed gateway persistence with Zo paid plan
- Wrote and deployed SOUL.md for Hermes
- Added persistent memory entries
- Submitted Geode Labs grant for ETHis via Cowork
- Created CONTEXT.md and references.md
- Donny walked out to eat and rest Mac
