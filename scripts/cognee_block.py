import cognee
import asyncio
import os
import time

async def ingest_brief(path):
    if not path:
        print("[WARN] Cognee: no path provided")
        return
    try:
        text = open(path).read()
        await cognee.remember(text)
        time.sleep(2)
        await cognee.cognify()
        print(f"[ARGUS] Cognee ingested: {path}")
    except Exception as e:
        print(f"[WARN] Cognee ingest failed: {e}")

asyncio.run(ingest_brief(os.environ.get("BRIEF_OUT", "")))