# Hermes Agent Orange Book — Complete Guide Summary

> Source: "Hermes Agent: The Complete Guide" (橙皮书 / Orange Book)
> Author: HuaShu (花叔 / AI进化论-花生), Bilibili + WeChat
> Version: v260408, April 2026 | Based on Hermes Agent v0.7.0
> GitHub: github.com/alchaincyf/hermes-agent-orange-book
> Local PDF: raw/hermes-orange-book.pdf (placeholder) | raw/papers/hermes-orange-book-en.pdf (full 77pp)
> All Orange Books: huasheng.ai
> License: For learning purposes only — refer to official docs for latest

---

## Overview

Hermes Agent (by Nous Research) is the first production implementation of Harness Engineering
— a methodology coined by Mitchell Hashimoto (Terraform creator) where you systematically build
scaffolding around an AI model to control its behavior. Released February 2026, it hit 27,000+
GitHub stars in two months. MIT license, fully open source.

The Orange Book is a 17-chapter, 5-part guide structured as follows:

  Part 1 (§01-02): Concepts
  Part 2 (§03-06): Core Mechanisms
  Part 3 (§07-11): Hands-On Setup
  Part 4 (§12-15): Real-World Scenarios
  Part 5 (§16-17): Deep Thinking

---

## Part 1: Concepts

### §01 — Not Another Agent: From Harness to Hermes

Harness Engineering background: In early 2026, the LangChain team demonstrated that adjusting
the "harness" around the same model (GPT-5.2-Codex) caused benchmark scores to jump from
52.8% to 66.5% — from Top 30 to Top 5 — without changing a single line of model code.

Five Harness Components and how Hermes maps them:

  Harness Component   | Manual Way                        | Hermes Built-in
  --------------------|-----------------------------------|------------------------------------------
  Instruction Layer   | Hand-write CLAUDE.md / AGENTS.md  | Skill system (auto-created + self-improving)
  Constraint Layer    | Configure hooks / linter / CI     | Tool permissions + sandbox + toolset on-demand
  Feedback Layer      | Manual review / evaluator Agent   | Self-improving Learning Loop (auto-retrospective)
  Memory Layer        | Manually maintain knowledge base  | Three-layer memory + Honcho user modeling
  Orchestration Layer | Build your own multi-Agent pipeline | Sub-Agent delegation + cron scheduling

Key differentiator from OpenClaw: OpenClaw gives you configuration-as-behavior (you write
SOUL.md). Hermes has all five dimensions built in and they run automatically. Claude Code
requires you to build the harness manually. Hermes builds its own harness while it runs.

### §02 — Hermes Agent at a Glance: 60 Seconds

Architecture in one line:
  Learning Loop → Three-Layer Memory → Skill System → 40+ Tools → Multi-Platform Gateway

Key numbers (v0.7.0, April 3, 2026):

  Metric                 | Data
  -----------------------|------------------------------------------
  GitHub stars           | 27,000+ (two months after release)
  Built-in tools         | 40+
  Supported platforms    | 14
  MCP integrations       | 6,000+ apps
  Sub-Agent concurrency  | Up to 3
  Minimum deployment     | $5/month VPS
  Memory usage           | <500MB (without local LLM)
  License                | MIT (fully open source)

Cost comparison: Claude Code Pro is $20/month, Max is $200/month. Hermes on $5 VPS + API
costs under $10/month for most use cases.

---

## Part 2: Core Mechanisms

### §03 — The Learning Loop: Self-Harnessing Agent

Five steps wired into a closed loop — the flywheel that makes Hermes improve over time:

  Curate Memory → Create Skill → Skill Self-Improvement → FTS5 Recall → User Modeling

Step 1: Memory Curation
  After each conversation Hermes actively decides what to keep — not passive storage.
  Works like writing a diary: looks back at the exchange, decides what was notable, writes
  it to SQLite with FTS5 indexing. A periodic nudge mechanism reminds the agent to review
  recent interactions (like a journaling app notification). Not a video tape — a notebook.

Step 2: Autonomous Skill Creation
  When Hermes finishes a complex task, it asks: "will this solution be useful again?"
  If yes, it distills the solution into a Skill file saved to ~/.hermes/skills/
  The Skill captures: task description, execution steps, pitfalls to watch for.
  Example: after importing a CSV to a database, it might auto-create csv-to-database.md
  recording common cleaning steps, your preferred db connection method, and validation rules.

Step 3: Skill Self-Improvement
  Every time a Skill is used and you provide feedback, Hermes modifies the Skill file itself.
  You say "this import script should check if the table exists first" — Hermes doesn't just
  add it this time, it edits the Skill file so the check is included by default next time.
  Analogous to updating documentation + standards after a production incident.

Step 4: FTS5 Cross-Session Recall
  Before each new conversation, Hermes searches historical memory using FTS5 based on the
  current topic and loads only the relevant fragments — not all history.
  Ask a database question: loads database-related memories.
  Ask a frontend question: loads frontend memories.
  All data is local SQLite — never leaves your machine.

Step 5: Honcho User Modeling (optional)
  External integration by Plastic Labs. 12-layer dialectical identity modeling.
  Infers user characteristics from behavior patterns, not just what you say.
  Covers: technical level, work rhythm, communication style, goal inference, emotional
  patterns, preference contradictions (what you say vs. what you actually do).
  Results injected as invisible context into subsequent conversations.

The causal chain (flywheel):
  Memory feeds Skill creation → Skills generate new memories → new memories trigger Skill
  improvement → improved Skills produce better results → better results make Honcho modeling
  more accurate → more accurate profiling makes memory curation more targeted.

Mitchell Hashimoto comparison: Mitchell manually added rules to CLAUDE.md every time Claude
made a mistake. Hermes automates exactly this process. Trade-off: you give up some control
over the rules, but the barrier drops to zero.

### §04 — Three-Layer Memory: From Goldfish to Old Friend

Each layer answers a different question. All stored locally in SQLite — no cloud dependency.
All data lives in ~/.hermes/ — fully portable (copy directory to migrate machines).

**Layer 1 — Session Memory (Episodic)**
  Question: "What happened?"
  - Every conversation, tool call, and return result written to SQLite with FTS5 indexing
  - On-demand retrieval: NOT loading all history — searching relevant fragments per topic
  - Analogy to hippocampus (episodic memory in cognitive science)

  Approach         | Context Usage              | Long-term Viability | Speed
  -----------------|----------------------------|---------------------|---------------------
  Load Everything  | Grows linearly             | Hits wall after days| Gets slower over time
  Hermes FTS5      | Essentially constant       | Works for months/years | Stays the same

**Layer 2 — Persistent Memory (Semantic)**
  Question: "Who are you?"
  - Stores durable state: coding preferences, project structure habits, toolchain patterns
  - Persists across sessions, survives new conversations — does not wipe on restart
  - Also stored in SQLite, managed via the memory tool
  - Portable: copy ~/.hermes/ to migrate; mount /opt/data in Docker for persistence
  - Human can override, add, or delete entries at any time

**Layer 3 — Skill Memory (Procedural)**
  Question: "How to do things?"
  - Each Skill is a standalone markdown file in ~/.hermes/skills/
  - Human-readable and directly editable
  - Records methodologies and operating procedures, not conversation content
  - Auto-created by the agent, manually writable, or installed from the community Hub

Cognitive science mapping:
  - Session memory   = episodic memory  ("what happened last time")
  - Persistent memory = semantic memory  ("what the world is like")
  - Skill memory     = procedural memory ("how to do things")

**Honcho: 12-Layer Dialectical User Modeling**

After each conversation, Honcho infers:
  - Technical level and skill
  - Work rhythm and active hours
  - Communication style preferences
  - Goal inference from task patterns
  - Emotional patterns (concise answers when frustrated)
  - Preference contradictions (what you say vs. what you actually do)

Key: Honcho catches inconsistencies between stated and revealed preferences. You never said
"I prefer concise code style" but it inferred it from how you modify code across sessions.

**Memory Comparison: Hermes vs Claude Code**

  Dimension            | Claude Code                           | Hermes Agent
  ---------------------|---------------------------------------|----------------------------------
  Memory format        | CLAUDE.md + auto-memory text files    | SQLite + FTS5 + Skill files
  Write method         | CLAUDE.md manual, auto-memory semi    | Fully automatic, human can override
  Retrieval            | CLAUDE.md loaded in full at startup   | On-demand FTS5 full-text search
  Memory granularity   | Project-level (one CLAUDE.md)         | Both global and project-level
  User modeling        | None (user writes preferences)        | Honcho auto-infers user profile
  Procedural memory    | Instructions in CLAUDE.md             | Standalone Skill files, self-improving
  Storage limit        | CLAUDE.md recommended a few KB        | SQLite's theoretical limit is very high

**Memory Limitations (important)**
  - No automatic expiration: database grows with long-term use — audit ~/.hermes/ periodically
  - Memory pollution: wrong early inferences persist and affect later behavior
  - Only store preferences, habits, and patterns — not one-off tasks or sensitive info
  - Sensitive info (passwords, keys, personal identity) must not enter the memory store

### §05 — The Skill System: Capabilities That Evolve on Their Own

**What a Skill Is**

Each Skill is a standalone markdown file in ~/.hermes/skills/<skill-name>/SKILL.md
It captures the agent's procedural memory for how to do something. Three sources:

  Source          | Description                                              | Scale
  ----------------|----------------------------------------------------------|------------------
  Bundled Skills  | Pre-built capabilities shipped with install (MLOps,      | 40+
                  | GitHub workflows, research)                              |
  Agent-Created   | After completing complex tasks, auto-distilled solutions | Grows with usage
  Skills Hub      | Community-contributed skill packs, one-click install     | Continuously growing

Agent-created Skills are the "killer feature." Same "write code" Skill, after three weeks with
a Python developer vs. a Rust developer, evolves into two entirely different versions.

**Skill Self-Improvement Mechanism**

  1  Execute the Skill
     Agent follows the steps recorded in the Skill to complete the task

  2  Collect Feedback
     User reactions (satisfied / unsatisfied / corrections) logged to session memory

  3  Update the Skill
     Agent analyzes feedback and automatically modifies relevant steps in the Skill file

  4  Next Execution Uses the New Version
     Improved Skill takes effect automatically in subsequent tasks

Skills are alive — they run inside a learning loop, automatically optimizing based on real
feedback. Every Skill update is visible as a diff in ~/.hermes/skills/ — not a black box.

**agentskills.io Standard**

Hermes Skills follow the agentskills.io standard, supported by 30+ tools as of early 2026
including Claude Code, Cursor, Copilot, Codex CLI, and Gemini CLI. This means:
  - Skills written for Claude Code work directly in Hermes
  - Skills Hermes auto-creates can be used in Claude Code
  - Your Skill library is a portable asset, not locked to any single tool
  - OpenClaw's 5,700+ ClawHub Skills are callable via agentskills.io standard

**Comparison: Hermes Skills vs OpenClaw Skills**

  Dimension       | OpenClaw Skills                 | Hermes Skills
  ----------------|---------------------------------|------------------------------------------
  Creation        | Manually written SOUL.md        | Agent-created + manually written
  Maintenance     | Manual updates                  | Auto-evolution + manual intervention
  Personalization | Generic templates, fork/customize | Grows organically from your usage habits
  Interoperability| agentskills.io standard         | agentskills.io standard (interoperable)
  Ecosystem Size  | 5,700+ (large)                  | 40+ bundled + community (growing)

OpenClaw strength: scale and transparency (you know exactly what every step does — you wrote it).
Hermes strength: adaptability (grows into a custom fit from your actual usage patterns).

### §06 — 40+ Tools and MCP: Connect Everything

**Five Tool Categories**

  Category     | Core Tools                     | What They Do
  -------------|--------------------------------|------------------------------------------------
  Execution    | terminal, code_execution, file | Run commands, execute code (sandboxed), read/write files
  Information  | web, browser, session_search   | Web search, browser automation, search conversation history
  Media        | vision, image_gen, tts         | Understand images, generate images, text-to-speech
  Memory       | memory, skills, todo, cronjob  | Operate memory layer, manage Skills, task planning, scheduled jobs
  Coordination | delegation, moa, clarify       | Delegate to sub-agents, multi-model reasoning, ask user

Notable tools:
  - session_search: FTS5 full-text search over conversation history with LLM summarization.
    Most agents don't have this — every conversation starts from scratch.
  - moa (Multi-model Orchestrated Answering): calls multiple LLMs simultaneously, synthesizes
    into one answer. Useful for fact-checking or technical decisions requiring high reliability.
  - cronjob: scheduled tasks in natural language. "Check GitHub notifications every morning at
    9am" — no cron expressions, no scheduler config needed.

**Toolsets: On-Demand, Not Everything On**

Tools grouped into Toolsets and enabled/disabled in config.yaml:

  toolsets:
    - web
    - terminal
    - file
    - skills
    - delegation
    # - homeassistant  # comment out what you don't need

Fewer enabled tools = more focused agent + faster responses + fewer tokens consumed.
Toolsets are also the constraint layer — precise control over what the agent can touch.

**MCP: A Unified Interface to 6,000+ Apps**

MCP (Model Context Protocol) — proposed by Anthropic, late 2024. The "USB port" of AI tools.
Two transport modes:
  - stdio: local subprocess, communicates over stdin/stdout. Fast, no network overhead.
    Use for local tools, filesystems, databases.
  - HTTP (StreamableHTTP): remote server, shared across multiple agents.
    Use for cloud services or team-shared MCP servers.

Per-server tool filtering: an MCP Server may expose 20 tools — restrict the agent to 3 of them.
Common integrations: GitHub, Slack, Jira, Google Drive, databases, Notion, etc.

---

## Part 3: Hands-On Setup

### §07 — Installation and Configuration: Three Approaches

**Option 1: Local Install (5 minutes)**

  curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash
  # Edit ~/.hermes/config.yaml with API key
  hermes

Works on macOS, Linux, WSL2. Handles Python, Node.js, and all dependencies automatically.
Verify: hermes --version (should show v0.7.0)

**Option 2: Docker (Clean Isolation)**

  docker pull nousresearch/hermes-agent:latest
  docker run -v ~/.hermes:/opt/data nousresearch/hermes-agent:latest

Key: -v flag maps container data volume to host. All state (memory, Skills, config) in /opt/data.
Delete and rebuild the container — your data survives.

**Option 3: $5 VPS for 24/7 Uptime**

  VPS Provider        | Monthly Cost | Notes
  --------------------|--------------|----------------------------------
  Hetzner CX22        | ~$4/mo       | Best value, European nodes
  DigitalOcean Droplet| $5/mo        | Singapore/US West nodes
  Vultr               | $5/mo        | Tokyo node, low latency

Pick Ubuntu 22.04 LTS, SSH in, run the install script — identical to local installation.
Without local LLMs, memory usage stays under 500MB. Pair with Telegram Gateway for
phone access. Price of a coffee = 24-hour AI assistant.

Serverless option: Daytona or Modal as backends. Hibernates when idle, wakes on message.
Set terminal: daytona or terminal: modal in config.yaml.

**config.yaml Deep Dive**

Minimal working config:

  model:
    provider: openrouter
    api_key: sk-or-xxxxx
    model: anthropic/claude-sonnet-4
  terminal: local
  gateway:
    telegram:
      token: YOUR_BOT_TOKEN
    discord:
      token: YOUR_BOT_TOKEN

Supported providers:

  Provider     | Recommended Models          | Best For
  -------------|-----------------------------|-----------------------------------------
  OpenRouter   | Claude Sonnet 4 / GPT-4o   | 200+ models, flexible switching
  Nous Portal  | Hermes 3 series             | Officially recommended, deeply integrated
  OpenAI       | GPT-4o / o3                 | Direct OpenAI API connection
  z.ai / Zhipu | GLM-5                       | China-friendly option
  Ollama       | Hermes 3 8B/70B             | Fully offline, privacy first

Note (April 2026): Anthropic banned third-party tools from accessing Claude through Pro/Max
subscriptions. Use Claude via pay-as-you-go API keys, or use OpenRouter / Nous Portal instead.

Terminal backends (where code executes):
  local, docker, ssh, daytona, modal, singularity
  Recommendation: local for most users; docker if you want isolation on production servers.

**Troubleshooting**
  - Install script hanging: Check network / proxy for regions with restricted access
  - hermes command not found: Run source ~/.bashrc or reopen terminal (fish shell quirk)
  - Docker container starts but nothing happens: Ensure config.yaml exists and has model info

### §08 — First Conversation: Letting Hermes Get to Know You

After first launch, the ~/.hermes/ directory structure:

  ~/.hermes/
  ├── config.yaml           # Your configuration
  ├── state.db              # SQLite database (conversation history + FTS5 index)
  ├── skills/               # Skills directory
  │   └── bundled/          # Built-in Skills
  └── memories/             # Persistent memory (MEMORY.md + USER.md)

What happens behind the scenes from your first message:
  - Session memory is written to state.db immediately
  - Preferences mentioned casually are saved to persistent memory layer
  - After complex tasks, Hermes auto-creates a Skill file in skills/
  - You don't write config, edit files, or set rules — just use it

Skill auto-creation example: Ask Hermes to convert Markdown to WeChat-blog HTML. After
completing it, check ~/.hermes/skills/ — a markdown-to-wechat.md Skill has appeared,
recording the conversion rules and output requirements for future reuse.

### §09 — Multi-Platform Access: Reach It Anywhere

**Gateway Architecture: One Process, All Platforms**

One Hermes Agent instance. One memory. One Skill set. All platforms.
A message from Telegram and a command from the CLI are indistinguishable to Hermes.

14 supported platforms: Telegram, Discord, Slack, WhatsApp, Signal, Email, SMS (Twilio),
Home Assistant, Mattermost, Matrix, DingTalk, Feishu/Lark, WeCom, Open WebUI.

**Telegram Bot Setup (Recommended Entry Point)**

  1. Find @BotFather in Telegram → /newbot → get Token
  2. Add to config.yaml:
       gateway:
         telegram:
           token: 123456789:ABCdefGhIJKlmNoPQRsTUVwxyz
  3. Run: hermes

Three steps, under two minutes. Telegram also supports voice messages — auto-transcribed
before processing. Say something during your commute; no typing needed.

**Cross-Platform Conversation Continuity**

Start a task on Telegram from your phone, continue it in the terminal at the office.
No re-explaining context — one brain, all doors. What you said on Telegram can be
continued in the CLI; Discord channel conversations can be referenced from Slack.

**Automated Scheduling via Gateway**

Scheduled task results get pushed through the Gateway to whatever platform you specify.
Hermes doesn't just wait for you to talk — it can work proactively.
Example: "Send me a news briefing every morning at 8am" → delivers to Telegram daily.

**Practical Full Deployment Setup**

  $5 VPS (Ubuntu 22.04)
  ├── Hermes Agent Core
  ├── Messaging Gateway
  │   ├── Telegram Bot (reachable from phone)
  │   ├── Discord Bot (team collaboration)
  │   └── Slack App (enterprise use)
  ├── ~/.hermes/
  │   ├── state.db (all conversation history)
  │   ├── skills/ (capabilities that accumulate automatically)
  │   └── config.yaml (one file, everything configured)
  └── Model calls → OpenRouter API

Total cost: VPS $5/month + model API fees ($2-5/month for light usage).

### §10 — Custom Skills: Teaching Hermes New Tricks

**Skill File Format and Structure**

A Skill is a markdown file. No framework to learn, no API to call.
Each Skill lives in its own folder under ~/.hermes/skills/<skill-name>/SKILL.md
Optional subdirectories: references/, templates/, scripts/

YAML frontmatter:

  ---
  name: skill-name
  description: What this Skill does
  version: "1.0.0"
  ---

Complete Skill anatomy (from the book's git-commit-style example):

  ---
  name: git-commit-style
  description: Enforce a consistent Git commit message format
  version: "1.0.0"
  ---
  # Git Commit Style

  ## Trigger
  Activate when the user asks me to commit code, write a commit message, or review commit history.

  ## Rules
  ### Commit Message Format
  - First line: type(scope): summary (50 chars max)
  - Blank line
  - Body: explain WHY, not WHAT

  ### Type Enum
  - feat: new feature
  - fix: bug fix
  - refactor: restructure (no behavior change)
  - docs: documentation
  - test: tests
  - chore: build/toolchain

  ### Constraints
  - Body in plain language, types in English
  - Don't write "modified XX file" -- that's noise
  - One commit, one thing

  ## Example
  feat(auth): add WeChat QR code login
  (reason for change)

**Anatomy of a Good Skill (from the book's empirical analysis)**

  Section   | Purpose                             | Required?
  ----------|-------------------------------------|-------------------
  Title     | Lets Hermes quickly identify what   | Yes
            | the Skill does                      |
  Trigger   | When to activate this Skill         | Strongly recommended
  Rules     | Concrete steps, constraints, formats| Yes
  Example   | A complete input-to-output example  | Strongly recommended
  Don'ts    | Explicit boundaries to prevent drift| Optional

Trigger specificity matters: "When the user mentions code" is too vague.
"When the user asks me to commit code, write a commit message, or review commit history" — good.

Skill triggering is automatic via FTS5 full-text search + semantic understanding.
You never say "use XX Skill" — Hermes matches the most relevant Skill on its own.

**Auto-Created Skill Example (GitHub Daily Digest)**

Hermes auto-generates after you run the task 3-4 times:

  # GitHub Daily Digest
  ## Trigger Conditions
  User mentions "GitHub notifications", "daily summary", etc.
  ## Steps
  1. Call GitHub MCP to fetch notifications from the past 24 hours
  2. Filter out automated notifications from bot accounts
  3. Group by type (PR / Issue / Discussion)
  4. Sort by importance (mention > review request > other)
  5. Present as a concise list
  ## User Preferences
  - Only titles and status needed, no detailed content
  - PRs and Issues displayed separately

**Installing Community Skills from Skills Hub**

  1. Ask Hermes: "What community Skills are available?" — lists popular Skills by category
  2. "Install XX Skill" — downloads to ~/.hermes/skills/, takes effect immediately (no restart)
  3. Customize: open the SKILL.md and edit. Community Skills are a starting point.

**Debugging Skills**
  - Ask: "What Skills do you have loaded right now?" — Hermes lists active Skills
  - Logs at ~/.hermes/logs/ record which Skills matched, why they were selected, why others skipped
  - Test incrementally: simplest request first, then edge cases
  - Skills can conflict: two overlapping triggers → Hermes picks highest match score

**Porting Claude Code Skills to Hermes**

agentskills.io standard makes it zero-friction:
  cp ~/.claude/skills/proofreading/SKILL.md ~/.hermes/skills/proofreading/SKILL.md
  Works immediately. No format changes, no API adapters.
  Only exception: if Skill references Claude Code-specific MCP Servers — swap those for
  Hermes equivalents. Core logic, triggers, and rules are all portable.

### §11 — MCP Integration: Connecting Your Tool Stack

**GitHub MCP Setup (Most Common Integration)**

  1. GitHub Settings → Developer settings → Personal access tokens
     Minimum scopes: repo, read:org. For Issues/PRs add write access.

  2. Add to config.yaml:
       mcp_servers:
         github:
           command: "npx"
           args: ["-y", "@modelcontextprotocol/server-github"]
           env:
             GITHUB_PERSONAL_ACCESS_TOKEN: "${GITHUB_TOKEN}"

  3. Restart Hermes → "List my GitHub repos" to verify

  4. Natural language operations:
     "Create an Issue in repo X titled Y"
     "Look at this PR's changes and do a code review"
     "What new Issues were opened this past week? Group by label"

**Database MCP (PostgreSQL example)**

  mcp_servers:
    postgres:
      command: "npx"
      args: ["-y", "@modelcontextprotocol/server-postgres"]
      env:
        POSTGRES_CONNECTION_STRING: "postgresql://user:***@localhost:5432/mydb"

Note: Database MCP has read-write access by default. Connect with a read-only account for
production databases. SQLite and MySQL have their own MCP Servers with identical config pattern.

**Per-Server Tool Filtering**

  mcp_servers:
    github:
      command: "npx"
      args: ["-y", "@modelcontextprotocol/server-github"]
      env:
        GITHUB_PERSONAL_ACCESS_TOKEN: "ghp_xxxxx"
      allowed_tools:
        - "list_issues"
        - "create_issue"
        - "get_pull_request"
        - "create_pull_request_review"

Even if the GitHub MCP exposes high-privilege tools (delete repos, change settings), Hermes
cannot call them unless they appear in allowed_tools. Principle of least privilege.

**MCP vs Native Tools Decision**

  Use native tools for: terminal, file, web search, image gen, memory, sub-Agent delegation
  Use MCP for: GitHub, databases, Slack, Jira, Google Drive — services requiring specific APIs

For Git: terminal for local commits/pushes; GitHub MCP for cross-repo management and PR reviews.

**MCP + Skills Combo**

Example: GitHub MCP provides PR diff reading ability; Code Review Skill defines the review
standards (naming conventions, error handling, test coverage). Combined = automated code
review against your specific standards. Add a cron job and it runs unattended.

---

## Part 4: Real-World Scenarios

### §12 — Personal Knowledge Assistant: The Power of Cross-Session Memory

Problem with traditional AI: every new conversation costs 3-5 minutes of context-setting.
Three weeks of research means re-introducing yourself to ChatGPT every single session.

What Hermes remembers across sessions:

  Memory Layer             | What It Records                                    | Purpose
  -------------------------|----------------------------------------------------|-----------------------
  Session memory (SQLite)  | What you asked, what it looked up, raw text        | Precise retrieval
  Persistent memory        | "User is researching X, ruled out Y, prefers low cost" | Auto-loads for next convo
  Skill memory             | "Research tasks: list dimensions -> dig -> summarize" | Methodology reuse

Result: Week two, you just say "Let's continue with the Serverless options." Hermes already
knows the project, may proactively surface: "Last week you mentioned Daytona's free tier had
limitations — want to check if the policy has been updated?"

Key design: persistent memory stores summaries (a few hundred words), and when details
are needed, FTS5 searches raw conversations, injecting only the most relevant snippets.
Like carrying a one-page cheat sheet and going back to the filing cabinet only for specifics.

Honcho's role: if you consistently pick the cheapest option across three research sessions,
Honcho infers "cost-sensitive" and surfaces pricing info first in future recommendations.
You don't configure this — it infers from behavioral patterns.

HuaShu's experience: After two weeks, Hermes started giving shorter, punchier replies —
it noticed he wants conclusions, not lengthy analysis. Gradual, automatic adaptation.

Memory value scales with task duration. One-off tasks ("translate this paragraph") — zero
advantage. Long research projects spanning weeks — massive efficiency gain.

### §13 — Dev Automation: From Code Review to Deployment

Scenario: Wake up to three Telegram messages from Hermes (all while you slept):
  - PR merged into main last night: 387 new lines, 2 issues found, report saved to project Skill
  - CI pipeline ran at 2:40 AM: 3 test failures (2 from PR, 1 flaky)
  - Daily standup notes drafted from yesterday's commits/PRs — needs sign-off

This runs via cron scheduling + GitHub MCP + memory system.

**Automated Code Review Setup**

  1. Connect GitHub MCP (config.yaml)
  2. Set cron: "Check main branch for new PRs every 6 hours and do a code review"
  3. Define review standards as a Skill: functions under 50 lines, custom error types,
     all API endpoints must have tests

Key: Review standards live in a Skill that self-improves. You flag a missed issue, and
the Skill updates to catch that pattern permanently. Unlike static lint rules — alive.

**Test Generation and Execution**

Hermes discovers which functions lack tests on its own, writes the tests, runs them, fixes
failures, and delivers a report. Tools working together:
  file: scans codebase for modules without tests
  code_execution: runs tests in sandbox
  terminal: generates coverage reports
  memory: remembers which modules have been reviewed and which tests are flaky

**Claude Code and Hermes Division of Labor**

  Dimension        | Claude Code                          | Hermes Agent
  -----------------|--------------------------------------|----------------------------------
  Interaction mode | Real-time conversation (you present) | Background, reports on schedule
  Strengths        | Writing code, refactoring, debugging | Monitoring, auditing, summarizing
  Time horizon     | Single session                       | Across days and weeks
  Trigger          | You initiate it                      | Cron or event-driven

In one sentence: Claude Code is the craftsman. Hermes is the butler.
  Claude Code writes code → opens PR → Hermes auto-reviews → runs tests → generates daily report

### §14 — Content Creation: From Research to Final Draft

Traditional problem: static CLAUDE.md doesn't update itself. Style rules learned in one session
vanish by the next. Every article series means re-explaining the reader persona and style guide.

**Content Series with Hermes**

After article 1, memory records: series positioning, target audience, your editing preferences
(every long sentence you broke into short ones), which concepts were already covered.
For article 2: say "write the next one, topic is XXX" — it knows style, prior coverage, and
what you were unhappy with last time. By article 5, the understanding is remarkably precise.

**Parallel Research with Sub-Agents**

For a deep technical article, dispatch three sub-agents simultaneously:
  Sub-Agent 1: Research Hermes architecture
  Sub-Agent 2: Research OpenClaw ecosystem
  Sub-Agent 3: Collect community feedback

Research that used to take over an hour: done in 20 minutes. Each sub-agent gets only the
toolsets it needs (web + browser for research; restricted toolsets aren't just safety — efficiency).

**Skills That Accumulate Writing Style**

Style rules stored as a Skill. Initially: don't use cliched summary phrases, keep paragraphs
to 3-5 lines, use casual language. Then it self-improves:
  - If you change "formal phrasing" to "natural phrasing" three times → adds rule to Skill
  - If you delete a "forced inspirational ending" → learns "don't force uplifting conclusions"
After a month: dozens of rules accumulated from your real edits. Your personal editorial handbook.
Every Skill update is visible as a diff in ~/.hermes/skills/ — inspectable and correctable.

HuaShu's approach: Claude Code for one-off sponsored articles (fast, real-time brand feedback).
Hermes for content series and personal columns (writing Skill grows over time). No conflict.

### §15 — Multi-Agent Orchestration: Running Three Horses at Once

**Why Multiple Agents**

Two ceilings for a single agent:
  - Context explosion: research + coding + testing in one context interfere with each other
  - Time bottleneck: sequential 30-min tasks = 90 min total; parallel = max(30, 30, 30) = 30 min

delegate_task solves both. Up to 3 sub-agents simultaneously, each with own context and toolset.

**delegate_task Feature Table**

  Feature                 | Description
  ------------------------|--------------------------------------------------------------
  Independent context     | Each sub-agent has own conversation history, no pollution
  Restricted toolsets     | You specify which toolsets each sub-agent can use
  Blocked sub-agent tools | delegate_task, clarify, memory, send_message, execute_code
                          | are always blocked for sub-agents (no recursive spawning)
  Isolated terminal       | Each sub-agent has its own terminal session, no interference
  Max 3 concurrent        | Hard-coded limit — attention dispersion beyond 3 in testing
  Result relay            | Sub-agent results returned to main agent for consolidation

The 3-concurrent limit is a deliberate design choice, not a compute constraint. Nous Research
found in testing that beyond 3 sub-agents, the main agent's consolidation quality drops sharply.

**Real Example: Competitive Analysis Report**

Traditional: research product A, then B, then C, then integrate = A+B+C minutes
With delegate_task:

  Main Agent defines task template
  → "Research [product] along: positioning, features, architecture, pricing, community, pros/cons"

  Parallel execution (simultaneously):
  Sub-Agent A: researches Claude Code | toolsets: web + browser
  Sub-Agent B: researches Cursor      | toolsets: web + browser
  Sub-Agent C: researches Hermes      | toolsets: web + browser

  Main Agent consolidates all three into comparison report

Result: 40 minutes → 15 minutes (reported in the book).

**Security Design of Restricted Toolsets**

Principle of least privilege at the agent level:
  Research sub-agents: web + browser only
  Coding sub-agents: terminal + file + code_execution only
  Consolidation sub-agents: no external tools — text processing only

If a research sub-agent finds malicious code online and has no terminal access,
the code comes back as text for the main agent to review — it cannot execute it.

**Relationship to Anthropic's Three-Agent Architecture**

Anthropic proposed: Planner → Generator → Evaluator (plan/execute/evaluate chain).

  Dimension       | Anthropic Three-Agent         | Hermes delegate_task
  ----------------|-------------------------------|---------------------------------------
  Role assignment | Fixed (plan/execute/evaluate) | Task-driven, flexible roles
  Communication   | Chain (sequential)            | Star topology (main ↔ sub-agents)
  Parallelism     | Typically sequential          | Up to 3 concurrent
  Memory          | No built-in memory            | Main agent maintains full memory

Hermes's model is more flexible: implement Anthropic's three-agent architecture if needed
(one sub-agent per role), OR run three parallel same-type tasks. Architecture isn't fixed.

Anthropic's three-agent architecture = mental framework (tells you what to split into).
Hermes delegate_task = execution tool (turns that framework into reality).

**When NOT to Use delegate_task**

If a task fits comfortably in one context window, splitting adds overhead and consolidation
errors. Good decomposition: each sub-agent's output should be self-contained, uniformly
formatted, and directly composable. If you need lengthy consolidation instructions, the
task decomposition is probably wrong.

---

## Part 5: Deep Thinking

### §16 — Hermes vs OpenClaw vs Claude Code: Not a Choice

**Three Design Philosophies**

  Dimension           | Claude Code              | OpenClaw                     | Hermes Agent
  --------------------|--------------------------|------------------------------|----------------------------------
  Core philosophy     | Interactive coding       | Configuration as behavior    | Autonomous background + self-improvement
  Your role           | Sitting at terminal      | Writing config files         | Deploy and check in occasionally
  Memory mechanism    | CLAUDE.md + auto-memory  | SOUL.md + Daily Logs + semantic | Three-layer self-improving
  Skill source        | Manually installed       | ClawHub 5,700+ community     | Agent-created + community Hub
  Run mode            | On-demand                | On-demand                    | 24/7 background
  Deployment          | Local CLI (subscription) | Local CLI (free + API costs) | $5 VPS / Docker / Serverless
  Skill maintenance   | Manual                   | Manual                       | Auto-evolving + manual override

**Which Tool for Which Scenario**

  Scenario                                | Recommended Tool      | Why
  ----------------------------------------|-----------------------|------------------------------------
  New feature / code refactoring          | Claude Code           | Needs real-time human judgment
  Team standardized agents                | OpenClaw              | SOUL.md transparent and auditable
  24/7 code review                        | Hermes                | Cron + GitHub MCP, runs unattended
  Personal knowledge assistant            | Hermes                | Three-layer memory compounds
  Customer support / community bot        | Hermes                | 14-platform Gateway native
  Rapid product validation                | Claude Code           | Fast iteration, real-time feedback
  Enterprise high-control scenarios       | OpenClaw              | Predictable, auditable behavior
  Long-term content creation              | Hermes + Claude Code  | Hermes for research/accumulation,
                                          |                       | Claude Code for writing

**agentskills.io: Why Skill Interoperability Matters**

In early 2026, agentskills.io gained adoption across 16+ tools: Claude Code, Cursor,
OpenAI Codex, Gemini CLI, Hermes. A Skill written for Claude Code works directly in Hermes.
Your Skill library is your own asset, not a platform's appendage.

If OpenClaw's 5,700+ ClawHub Skills become callable via agentskills.io, Hermes's capability
boundary expands instantly. And Skills Hermes auto-creates and improves can feed back into
the broader ecosystem.

**HuaShu's Workflow**

  Claude Code = "day shift" (present, interactive — writing, coding, product decisions)
  Hermes = "night shift" (autonomous — monitoring repos, scheduled research, knowledge bases)
  OpenClaw's SOUL.md = standardized config layer for behavioral constraints in both

**Underlying Divergence**

These three tools appear to converge (Claude Code adds auto-memory, Hermes adds Skills Hub)
but the underlying divergence is widening:
  - Claude Code: fundamentally real-time human-AI conversation. Subscription model means
    you're always present.
  - Hermes: fundamentally AI running autonomously in the background. MIT open-source + self-
    hosted model means it keeps working when you're not there.
  - OpenClaw: transparent and controllable. Unique value for enterprise compliance.

Competition won't converge to a single winner. Interactive coding, configuration management,
and autonomous operation are three distinct work modes that will coexist long-term.

### §17 — The Boundaries of Self-Improving Agents: How Far Can They Go

**The Three-Level Loop Framework (from Kief Morris)**

  In the loop: reviewing every line of the agent's output
  On the loop: not checking outputs, just holding the reins
  Out of the loop: you say what you want, the agent handles everything

Hermes pushes toward "out of the loop" territory: its learning cycle is automatic. It creates
Skills on its own, improves them on its own, decides what to remember on its own. The reins
are growing by themselves.

**Technical Safeguards (What Exists)**

  - Skill files are readable markdown diffs — not black-box weights. You can see what changed.
  - Memory is local SQLite — inspectable and deletable directly.
  - Tool permissions are sandboxed — the agent cannot acquire new system permissions.
  - MIT license: you own the source code, can audit and modify the learning loop, or turn
    off automatic Skill creation entirely.

Technically controlled. Practically? The question is whether you actually exercise that right.

**The Fundamental Tension**

"The value of an autonomous agent is not having to watch it, but safety requires you to watch it."

The ceiling of self-improvement is not technical — it's the feedback signal.
  - If you're present and giving feedback: supervised improvement works.
  - If you're not: the agent uses its own evaluation criteria. It thinks the response was
    "faster and more accurate" — but "fast and accurate" doesn't equal "correct." Some
    errors require domain knowledge the agent doesn't have.

Mitchell Hashimoto could write excellent harness for Ghostty because he understood terminal
emulators deeply. A self-improving agent doesn't have domain knowledge. It can optimize
execution efficiency, but it cannot judge whether the direction is right.

"Self-improvement makes agents run faster in a known direction. But the direction still needs
a human to set."

**Open Source vs Closed Source Trust**

  Claude Code (closed): business incentives keep behavior predictable — reputational risk if
  agent damages a user's codebase. "I trust your business incentives."

  Hermes (open source): you can see all code, but if self-improvement causes a problem, Nous
  Research has no commercial obligation. You bear the consequences. "I trust my own ability to audit."

For technical users: open source is clearly better — you control everything.
For non-technical users: closed-source commercial may be safer — someone else is on the hook.

**Open Questions the Book Leaves Unanswered**

  - How much autonomous self-improvement are you comfortable with? Rewriting Skill files: fine.
    Modifying core configuration: maybe not. Modifying the learning loop: absolutely not.
    Where do you draw the line?
  - Who audits the results of self-improvement?
  - Do self-improving agents need a "forgetting" mechanism? (Humans forget; agents only accumulate.)
  - If junior developers never touch code details, who will design the harness in the future?

HuaShu's conclusion: Let the agent self-improve on the "how." Keep humans owning the "what"
and the "don't." Self-improvement makes agents run faster in a known direction — but the
direction itself still needs a human to set.

---

## Running Parallel Profiles (Multi-Profile Setup)

The book describes a practical "parallel profiles" deployment pattern enabled by Hermes's
file-based architecture. Because all state lives under a single directory (~/.hermes/),
you can run multiple distinct Hermes instances with different configurations:

  Profile A (Work):    ~/.hermes-work/     → config with terminal + file + github toolsets
  Profile B (Personal): ~/.hermes-personal/ → config with web + telegram + writing Skills
  Profile C (Research): ~/.hermes-research/ → config with web + browser + knowledge Skills

Each profile has its own state.db (separate memory), its own skills/ directory (different
Skill sets tuned to each context), and its own config.yaml (different models or toolsets).

Launch with profile-specific directory:
  HERMES_HOME=~/.hermes-work hermes     # Work profile
  HERMES_HOME=~/.hermes-personal hermes # Personal profile

Docker deployment makes this cleaner:
  docker run -v ~/.hermes-work:/opt/data nousresearch/hermes-agent:latest   # Work
  docker run -v ~/.hermes-personal:/opt/data nousresearch/hermes-agent:latest # Personal

In multi-platform Gateway deployments (VPS + Telegram + Discord), each platform shares
the same agent instance and memory. Cross-platform continuity means the same profile
is accessible from all configured platforms simultaneously.

---

## Key Architectural Decisions Explained

**Why max 3 sub-agents?**
Testing showed consolidation quality drops sharply beyond 3. Not a compute limitation —
an attention dispersion problem when LLMs integrate too many independent information sources.

**Why SQLite + FTS5 instead of vector DB?**
FTS5 is a SQLite extension — no extra database installation needed. All data is local files.
Purely local storage: your conversation memory never leaves your machine. Portable by design.

**Why Skills as markdown files?**
Human-readable, directly editable, version-controllable with git, portable across tools
(agentskills.io standard). Not a black box — you can see what changed in a diff.

**Why ~/.hermes/ as single directory?**
One directory = full backup. Migrate machines by copying the directory.
Docker: mount /opt/data. Serverless: persist between runs. No scattered state.

---

## Glossary

  Harness Engineering   — Methodology of building scaffolding around AI models to control behavior
  Learning Loop         — Five-step closed loop: memory → skills → improvement → recall → modeling
  agentskills.io        — Cross-tool Skills standard (16+ tools as of early 2026)
  delegate_task         — Hermes tool for spawning up to 3 parallel sub-agents
  FTS5                  — SQLite full-text search extension used for Hermes's memory retrieval
  Honcho                — Optional Plastic Labs user modeling integration (12-layer dialectical)
  Toolsets              — Grouped tool sets enabled/disabled in config.yaml for focus and security
  MCP                   — Model Context Protocol (Anthropic, late 2024) — USB port for AI tools
  stdio transport       — MCP local subprocess mode (fast, no network overhead)
  StreamableHTTP        — MCP remote server mode (for cloud services and team-shared MCP servers)
  moa                   — Multi-model Orchestrated Answering (calls multiple LLMs, synthesizes)
  Star topology         — Hermes orchestration pattern: main agent ↔ sub-agents (not chain)

---

## Related Pages

- [[agent-build-order.md]] — DVS agent dependency graph and build sequence
- [[SOUL.md]] — Hermes orchestrator identity and routing rules for the DVS swarm
- [[CONTEXT.md]] — Current infrastructure state and session handoff
- [[references.md]] — Full source library including Hermes documentation links
- [[cognee-setup.md]] — Cognee knowledge engine as potential alternative to flat markdown retrieval

---

## Source

Title: Hermes Agent: The Complete Guide (Hermes Agent 从入门到精通)
Author: HuaShu (花叔 / AI进化论-花生)
Series: Orange Book (橙皮书)
Version: v260408 | Based on Hermes Agent v0.7.0
Released: April 2026 (created April 8, 2026 per PDF metadata)
License: For learning purposes only — refer to official docs for latest
GitHub: https://github.com/alchaincyf/hermes-agent-orange-book
More Orange Books: https://huasheng.ai
Local source: raw/papers/hermes-orange-book-en.pdf (77 pages, English)
