# CLAUDE.md — Agent Operating Schema

## Who I am working for
Donny (DVSLewis). Operating as a one-person company powered by an AI agent 
swarm. Based between the US and Germany. Security is the top priority in 
all operations.

## What this wiki is
A persistent, compounding knowledge base maintained entirely by AI agents.
Raw sources go in /raw. The wiki lives in /wiki. This file defines the rules.
Agents write and maintain the wiki. Donny curates sources and asks questions.

## Folder structure
- /raw — immutable source documents. Never modify these.
- /wiki — all LLM-generated markdown pages. Agents own this layer.
- /schema — this file and any other operating instructions.
- /logs — append-only log of all operations.
- /assets — images and attachments referenced by wiki pages.

## Agent domains
This wiki serves a swarm of specialized agents:
- Research Agent — builds knowledge pages from sources
- Writing Agent — produces content and documents
- Code Agent — manages software projects via GitHub
- Operations Agent — handles scheduling, email, communications
- Commerce Agent — manages x402 payments (spending limits enforced by OWS)
- Trading Agent — isolated wallet, hard spending caps, human approval required

## Core operations

### Ingest
When a new source is added to /raw:
1. Read the source fully
2. Discuss key takeaways
3. Write a summary page in /wiki
4. Update wiki/index.md
5. Update any relevant existing wiki pages
6. Append an entry to logs/log.md

### Query
When answering questions:
1. Read wiki/index.md first
2. Find relevant pages
3. Synthesize answer with citations
4. File valuable answers back into the wiki as new pages

### Lint
Periodically check for:
- Contradictions between pages
- Orphan pages with no inbound links
- Stale claims superseded by newer sources
- Missing cross-references

## Logging format
Every operation appended to logs/log.md must start with:
## [YYYY-MM-DD] operation-type | brief description

## Security rules
- Never store API keys, passwords, or seed phrases in the wiki
- Never write sensitive personal information to any wiki page
- Trading and commerce operations require human approval above set limits
- All agent wallet access goes through OWS policy engine only

## Wiki page format
Every wiki page should have:
- A clear title (H1)
- A one-line summary at the top
- Dated sections if content evolves over time
- Links to related pages
- Source citations where applicable