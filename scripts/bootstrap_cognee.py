#!/usr/bin/env python3
"""
Bootstrap Cognee with all wiki pages.
Uses Cognee 1.0.2 remember/recall API.
Run with full env vars set at shell level (see CONTEXT.md).
"""

import asyncio
import cognee
from pathlib import Path

WIKI_DIR = Path("/root/workspace/my-wiki/wiki")
DATASET = "dvs-wiki"

async def bootstrap():
    md_files = sorted(WIKI_DIR.glob("*.md"))
    print(f"[BOOTSTRAP] Found {len(md_files)} wiki pages to ingest")

    for f in md_files:
        text = f.read_text(encoding="utf-8")
        if not text.strip():
            print(f"  [SKIP] {f.name} — empty")
            continue
        await cognee.remember(text, dataset_name=DATASET)
        print(f"  [ADD] {f.name} ({len(text)} chars)")

    print("[BOOTSTRAP] All pages ingested. Running recall test...")
    results = await cognee.recall("DVS agent swarm build order")
    print(f"[BOOTSTRAP] Recall test returned {len(results)} results")
    for r in results[:3]:
        print(f"  - {str(r)[:120]}")
    print("[BOOTSTRAP] Done.")

if __name__ == "__main__":
    asyncio.run(bootstrap())
