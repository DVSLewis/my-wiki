# DVS Agent Swarm — Reference Library
Maintained by Athena | Last updated: April 2026

## Core Architecture

### Karpathy LLM Wiki Pattern
Source: https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f
Relevance: Foundation architecture for entire DVS wiki system
Three layers: raw/ (immutable sources), wiki/ (LLM maintained), schema/ (agent constitution)
Three operations: Ingest, Query, Lint
Index.md breaks at 100-200 pages — add BM25/vector search beyond that

## Agent Framework

### Hermes Agent
Source: https://github.com/NousResearch/hermes-agent
Guide: https://hermesatlas.com/guide
Orange Book: https://github.com/alchaincyf/hermes-agent-orange-book
Docs: https://hermes-agent.nousresearch.com/docs
Running on Zo Computer paid plan, Claude Sonnet 4.6, port 8644

## Ethereum and Web3

### Ethereum MCP
Source: https://github.com/ETHCF/ethereum-mcp
153 tools across 7 sources: Etherscan, DefiLlama, CoinGecko, growthepie, Blobscan, Dune, JSON-RPC
60+ supported chains
Install: curl -fsSL https://raw.githubusercontent.com/ETHCF/ethereum-mcp/main/install.sh | bash
Requires: Free Etherscan API key from etherscan.io/apis
For: Midas and Janus

### ETH24 News Scraper
Source: https://github.com/ETHCF/eth24
For: Athena primary Ethereum news feed

### DeFi Skills by Nethermind
Source: https://defi-skills.nethermind.io
GitHub: https://github.com/NethermindEth/defi-skills
Install: npx clawhub install defi-skills
53 actions across 13 protocols: Aave V3, Uniswap V3, Lido, EigenLayer, Compound V3, Balancer V2, Curve, MakerDAO, Rocket Pool, WETH, Transfers, Pendle
Supported chains: Ethereum, Arbitrum, Base, Optimism, Polygon, Sepolia
Converts natural language DeFi intents into unsigned transactions for OWS to sign
Never signs, never broadcasts — outputs unsigned tx ready for OWS
For: Janus execution engine

### Open Wallet Standard (OWS)
Source: https://openwallet.sh
Docs: https://docs.openwallet.sh
Install: npm install -g @open-wallet-standard/core
One wallet, all chains: BTC ETH SOL ATOM TON TRON from single seed
Agents never see plaintext keys — scoped API tokens only
Built-in policy engine: spending limits, allowlists, chain restrictions
Install on Zo not Mac, paper backup keys immediately after creation
For: All agent wallets, especially Midas and Janus

## Payments and Agent Economy

### x402 Payment Rails
Relevance: Machine-to-machine micropayments for Midas
Status: Research and implementation pending
HTTP 402 Payment Required standard for agent commerce

### EIP-8004 Agent Identity
Relevance: On-chain identity and reputation for DVS agents
Status: Research and implementation pending

## Model Providers

### Anthropic
Console: https://console.anthropic.com
Models: Claude Sonnet 4.6 (primary), Claude Opus 4.6 (escalation only)

### OpenRouter
Source: https://openrouter.ai
Keys: https://openrouter.ai/keys
Status: NOT SET UP — priority task
Needed for: Multi-model routing, compression, Gemini Flash, DeepSeek, GPT-4o

### Nous Portal
Source: https://portal.nousresearch.com
Single subscription covering Claude, GPT, GLM, MiniMax and more
Alternative to managing multiple API keys

## Infrastructure

### Zo Computer
Source: https://zo.computer
Plan: Paid, always-on
API: https://api.zo.computer/zo/ask
Capabilities: Files, code, web browse, email, calendar, tasks, image gen, deployments

### GitHub
Wiki repo: https://github.com/DVSLewis/my-wiki (PUBLIC)
Auth: Personal access token, 90 day expiry, regenerate at github.com/settings/tokens

## Donny Platforms

Website: https://donnylewis.com
ETHis: https://ethis.xyz
IRK Magazine: https://irk-magazine.com
WeTryBetter: https://wetrybetter.com
Beyond Design Agency: https://beyonddesignagency.com

## X Posts To Be Ingested
These require Athena browser access — first priority when Athena is built:
- https://x.com/rubenhassid/status/2040293285168808063 — agent architecture
- https://x.com/hooeem/status/2039723470691451072 — agent setup
- https://x.com/milesdeutscher/status/2041972675418189933 — trading/DeFi
- https://x.com/bloggersarvesh/status/2041890491919430083 — agent tooling
- https://x.com/noisyb0y1/status/2042086577636061436 — agent infrastructure
- https://x.com/rubenhassid/status/2042558212990292013 — follow-up architecture
- https://x.com/karpathy/status/2040470801506541998 — original LLM wiki tweet
- https://x.com/blocmates/status/2042539396638085339 — Hermes use cases
- https://x.com/hooeem/status/2042293751805329445 — DeFi agent context
- https://x.com/51bodila/status/2046982199455428878 — CRITICAL: dependency graph architecture for agent build ordering

## NotebookLM Integration
Python: https://github.com/teng-lin/notebooklm-py
Use for: Research knowledge synthesis only
Never use for: Donny's unpublished creative work (screenplays, poems)
