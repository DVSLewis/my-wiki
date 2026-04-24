---
title: Cognee — Memory Layer Setup for DVS Agent Swarm
created: 2026-04-23
updated: 2026-04-23
type: concept
tags: [memory, knowledge-graph, infrastructure, agents, tool]
sources: [https://github.com/topoteretes/cognee]
---

# Cognee — Memory Layer Setup for DVS Agent Swarm

Cognee is an open-source knowledge engine that replaces flat markdown retrieval with a
persistent, graph-backed memory layer. It combines vector search, graph databases, and
cognitive science principles so that ingested documents are both searchable by meaning
and connected by relationships.

For DVS, Cognee becomes Athena's primary retrieval backend — the wiki markdown files
remain as the human-readable, version-controlled source of truth, but Cognee indexes
their content into a knowledge graph for fast, relationship-aware query routing.

Related: [[agent-build-order.md]] [[hermes-orange-book.md]] [[CONTEXT.md]]

---

## 1. Installation

Cognee is installed on Zo (Hermes host machine) via pip.

Status as of 2026-04-23: INSTALLED

```
pip install cognee
```

Python requirement: 3.10 to 3.13
Key dependencies installed: lancedb, sqlalchemy, openai, tiktoken, neo4j client,
networkx, fastapi, uvicorn, pydantic

Verify:
```
python -c "import cognee; print(cognee.__version__)"
```

---

## 2. Configuration

Cognee requires an LLM API key at minimum. Set it in the environment or a .env file.

```bash
export LLM_API_KEY="your-openai-api-key"
```

Or in ~/.hermes/.env (recommended for Hermes integration):
```
LLM_API_KEY=your-openai-api-key
```

To switch LLM providers (Anthropic, Mistral, local Ollama, etc.) see:
https://docs.cognee.ai/

For Cognee Cloud (managed, no local DB required):
```python
import cognee
await cognee.serve(url="https://your-instance.cognee.ai", api_key="ck_...")
```

Default local storage: SQLite + LanceDB (zero-config, good for DVS dev phase).
Production upgrade path: PostgreSQL + Qdrant or Neo4j.

---

## 3. The Four Core API Calls

Cognee exposes four operations. All are async.

### remember(data, dataset=None, session_id=None)

Ingests data permanently into the knowledge graph.
Runs the full pipeline: chunk -> embed -> extract entities -> build graph relations.

```python
import cognee
import asyncio

await cognee.remember("Athena is the wiki and research agent of the DVS swarm.")
await cognee.remember("ETHis 2026 takes place at Deutsches Museum Munich, July 2-3.")

# With a session scope (fast cache, syncs to graph in background):
await cognee.remember("User prefers concise answers.", session_id="chat_1")
```

Use this for:
- Onboarding all wiki pages at init time
- Adding new knowledge after Athena ingests a source
- Capturing agent decisions and outputs for cross-agent memory

### recall(query, dataset=None, session_id=None)

Queries the knowledge graph with auto-routing — Cognee picks the best search
strategy (vector similarity, graph traversal, or hybrid) based on the query type.

```python
results = await cognee.recall("What is the DVS build order?")
for r in results:
    print(r)

# Session-scoped recall (checks session memory first, falls through to graph):
results = await cognee.recall("What did we discuss today?", session_id="chat_1")
```

Use this as the primary retrieval call. Replaces grep-based search of markdown files.

### forget(dataset=None)

Deletes a dataset from the knowledge graph. Use carefully.

```python
await cognee.forget(dataset="staging_test")
```

For Athena: use to remove stale ingestions when a wiki page is archived or superseded.
Never call forget() on the main dataset without Donny's explicit approval.

### improve(data)

Feeds corrective feedback into the graph — updates existing nodes, resolves
contradictions, reinforces correct relationships.

```python
await cognee.improve("ETHis 2026 is organized by DVS in partnership with Ethereum Foundation.")
```

Use this after Donny corrects Athena's output. The correction becomes persistent.
Maps directly to the wiki's Update Policy for contradiction handling.

---

## 4. CLI Interface

Cognee ships a CLI for quick ops without writing Python:

```bash
cognee-cli remember "Cognee is the memory layer for DVS agents."
cognee-cli recall "What is DVS?"
cognee-cli forget --all
cognee-cli -ui    # opens local browser UI at localhost
```

The -ui flag launches a local dashboard for browsing the knowledge graph visually.
Useful for debugging ingestion and inspecting entity relationships.

---

## 5. Athena Integration Plan — Replacing Flat Markdown Retrieval

### Current State (Flat Markdown)

Athena currently retrieves knowledge by:
1. Reading index.md to find relevant page names
2. Calling read_file on those pages
3. Calling search_files with regex patterns across the wiki directory

Limitations:
- No semantic search — misses synonyms, conceptual matches
- No relationship traversal — cannot follow entity links automatically
- Retrieval quality degrades as wiki grows past ~50 pages
- Each session re-scans from scratch — no compounding query cache

### Target State (Cognee-backed)

Athena ingests all wiki pages into Cognee at session start (or delta-syncs changed
pages). Queries route through cognee.recall() first. Markdown files remain the
authoritative write surface — Cognee is the read index.

### Migration Steps

Step 1: Bootstrap ingest (one-time)
  - Read all files from wiki/ directory
  - Call cognee.remember() for each page with the dataset="dvs_wiki" tag
  - Verify recall works: cognee.recall("DVS agent build order")

Step 2: Delta sync on ingest
  - After Athena writes or updates any wiki page, immediately call cognee.remember()
    with the updated content
  - Use dataset="dvs_wiki" consistently so recall searches the full wiki corpus

Step 3: Replace search_files with recall for queries
  - Before: search_files("ethereum", path=wiki, file_glob="*.md")
  - After: cognee.recall("ethereum projects in DVS")
  - Fall back to search_files only if Cognee returns empty results (safety net)

Step 4: Use improve() for corrections
  - When Donny corrects a fact, call both:
    a. patch() to update the markdown file (human-readable truth)
    b. cognee.improve() with the corrected statement (graph truth)

Step 5: Session memory for agent coordination
  - Each agent uses session_id = agent name + date
  - cognee.remember(decision, session_id="athena-2026-04-23")
  - Other agents can recall Athena's session context without reading full wiki

### Bootstrap Script

```python
import cognee
import asyncio
import os

WIKI_PATH = "/root/workspace/my-wiki/wiki"
DATASET = "dvs_wiki"

async def bootstrap_wiki():
    for fname in os.listdir(WIKI_PATH):
        if not fname.endswith(".md"):
            continue
        fpath = os.path.join(WIKI_PATH, fname)
        with open(fpath, "r") as f:
            content = f.read()
        print(f"Ingesting {fname}...")
        await cognee.remember(content, dataset=DATASET)
        print(f"  done.")

    # Verify
    results = await cognee.recall("DVS agent swarm", dataset=DATASET)
    print(f"Recall test returned {len(results)} results.")
    for r in results:
        print(" -", r)

asyncio.run(bootstrap_wiki())
```

Run this once: python /root/workspace/my-wiki/scripts/bootstrap_cognee.py

---

## 6. Hermes Native Integration

Cognee is a first-class provider in Hermes Agent's memory system.
To activate (in ~/.hermes/config.yaml):

```yaml
memory:
  provider: cognee
```

Then set LLM_API_KEY in ~/.hermes/.env and restart Hermes.
Session memory and graph persistence become automatic — no manual API calls needed.
All agents in the swarm that run under Hermes inherit Cognee memory automatically.

---

## 7. MCP Integration

Cognee ships an MCP server (cognee-mcp/) for direct tool access by any MCP-capable agent.
See the native-mcp skill for how to configure MCP servers in Hermes.

Potential: expose cognee remember/recall as native Hermes tools so all swarm agents
can write and read shared memory without direct Python SDK calls.

---

## 8. Architecture Context

Cognee under the hood (local dev mode):
- Vector store: LanceDB (local columnar, no server required)
- Graph store: SQLite-backed NetworkX (upgradeable to Neo4j)
- Embeddings: OpenAI text-embedding-3-small by default
- Entity extraction: LLM-driven NER pass during cognify step
- Chunking: automatic, respects document structure

This means every cognee.remember() call:
1. Chunks the text
2. Embeds each chunk
3. Stores vectors in LanceDB
4. Extracts named entities and relationships via LLM
5. Writes nodes + edges into the graph store

Every cognee.recall() call:
1. Embeds the query
2. Runs vector ANN search (fast path)
3. Optionally traverses graph neighbors for richer context
4. Returns ranked results

---

## 9. Open Questions / Next Steps

- [ ] Confirm LLM_API_KEY is set in Zo's environment before running bootstrap
- [ ] Decide: local SQLite+LanceDB vs PostgreSQL+Qdrant for production DVS
- [ ] Evaluate: Cognee Cloud (managed) vs self-hosted for swarm scale
- [ ] Test recall quality on existing wiki pages (6 pages, good benchmark set)
- [ ] Wire delta-sync into Athena's ingest workflow (Step 2 above)
- [ ] Explore cognee-mcp for tool-level access by non-Python agents in swarm
- [ ] Consider: use Cognee session memory for CONTEXT.md handoff (replace flat file)

---

## References

- GitHub: https://github.com/topoteretes/cognee
- Docs: https://docs.cognee.ai/
- Research paper: arxiv.org/abs/2505.24478 (Optimizing KG Interface for LLM Reasoning)
- Colab walkthrough: linked in repo README
- MCP server: cognee-mcp/ directory in repo
- Hermes integration: README section "Use with AI Agents > Hermes Agent"
