#!/usr/bin/env bash
# argus-daily-brief.sh — DVS Argus Daily Intelligence Brief Pipeline
# Tavily-native fetch replacing dead RSSHub feeds
# Non-interactive, timeout-safe

set -o pipefail

LOG="/tmp/argus-brief.log"
DATE="$(TZ=Europe/Berlin date +%Y-%m-%d)"
TIMESTAMP="$(TZ=Europe/Berlin date '+%Y-%m-%d %H:%M %Z')"
WIKI="/root/workspace/my-wiki"
export BRIEF_OUT="${WIKI}/wiki/daily-brief-${DATE}.md"
INBOX_OUT="${WIKI}/raw/daily-inbox/${DATE}.md"
TELEGRAM_CHAT_ID="6127567978"

MODEL_NAME="google/gemini-2.0-flash-001"
TIMEOUT_VAL="120"
CUTOFF_HOURS=36

exec > >(tee -a "$LOG") 2>&1

echo ""
echo "=============================================="
echo "ARGUS BRIEF — ${TIMESTAMP}"
echo "=============================================="

TIER1="VitalikButerin karpathy koeppelmann timbeiko samczsun gakonst superphiz hudsonjameson"
TIER2="shivsakhuja echinstitute ethereumfndn AustinGriffiths cyrilXBT"
TIER3="aboutcircles GnosisDAO gnosischain safe gnosisguild cowswap kylearojas thedaofund chaskin22 etheconomiczone"

source /root/.hermes/.env 2>/dev/null || true
OPENAI_KEY=$(grep "^OPENAI_API_KEY=" /root/.hermes/.env | tail -1 | cut -d'=' -f2)
ORKEY=$(grep "^OPENROUTER_API_KEY=" /root/.hermes/.env | tail -1 | cut -d'=' -f2)
TAVILY_KEY=$(grep "^TAVILY_API_KEY=" /root/.hermes/.env | tail -1 | cut -d'=' -f2)

POSTS_FILE="/tmp/argus-posts-${DATE}.txt"
> "$POSTS_FILE"

echo "--- Fetching signals via Tavily ---"

python3 - <<PYEOF >> "$POSTS_FILE"
import os, json, sys
from datetime import datetime, timezone, timedelta
from tavily import TavilyClient

tavily = TavilyClient(api_key="${TAVILY_KEY}")
cutoff = datetime.now(timezone.utc) - timedelta(hours=${CUTOFF_HOURS})

queries = [
    "Ethereum protocol news Vitalik Buterin",
    "Ethereum staking consensus timbeiko superphiz hudsonjameson",
    "Ethereum security samczsun gakonst",
    "AI agents blockchain Ethereum karpathy",
    "AI Ethereum convergence x402 EIP",
    "Gnosis DAO GnosisChain Safe Cow Protocol",
    "koeppelmann Gnosis ecosystem update",
    "DAO governance public goods Ethereum 2026",
    "ETHis 2026 Ethereum event Munich",
    "DeFi Ethereum protocol update 2026",
    "ReFi regenerative finance DAO",
]

results = []
for query in queries:
    try:
        res = tavily.search(query, max_results=5, days=2)
        for r in res.get("results", []):
            url = r.get("url", "")
            title = r.get("title", "").strip()
            content = r.get("content", "").strip()[:300]
            if title and len(title) > 10:
                handle = "web"
                if "x.com/" in url or "twitter.com/" in url:
                    parts = url.split("/")
                    handle = "@" + parts[3] if len(parts) > 3 else "@web"
                results.append({
                    "handle": handle,
                    "title": title,
                    "link": url,
                    "summary": content,
                    "query": query
                })
    except Exception as e:
        sys.stderr.write(f"[WARN] Tavily query failed: {query} — {e}\n")

seen = set()
unique = []
for r in results:
    if r["link"] not in seen:
        seen.add(r["link"])
        unique.append(r)

for r in unique:
    print(f"HANDLE={r['handle']}|||TITLE={r['title']}|||LINK={r['link']}|||SUMMARY={r['summary']}")

sys.stderr.write(f"[ARGUS] Tavily fetch complete: {len(unique)} unique signals\n")
PYEOF

POST_COUNT=$(wc -l < "$POSTS_FILE" | tr -d ' ')
echo "Signals found: $POST_COUNT"

SCORED_FILE="/tmp/argus-scored-${DATE}.json"
POSTS_CONTENT=$(cat "$POSTS_FILE" 2>/dev/null || echo "")

python3 - <<PYEOF > "$SCORED_FILE"
import json, sys, re, urllib.request, urllib.error

posts_raw = """$POSTS_CONTENT"""
lines = [l.strip() for l in posts_raw.strip().split('\n') if l.strip()]
posts = []
for line in lines:
    parts = {}
    for seg in line.split('|||'):
        if '=' in seg:
            k, v = seg.split('=', 1)
            parts[k] = v
    if 'HANDLE' in parts and 'TITLE' in parts:
        posts.append(parts)

if not posts:
    print(json.dumps({"posts": [], "error": "no signals found"}))
    sys.exit(0)

prompt = "You are Argus, an intelligence analyst for the DVS Agent Swarm. Score each signal 1-10 for relevance to Ethereum, DAOs, AI agents, Gnosis ecosystem, and Web3 public goods. Return ONLY a JSON array of objects with keys: handle, title, link, score, category, summary. Signals:\n"
for i, p in enumerate(posts[:25]):
    prompt += f"{i+1}. {p.get('HANDLE')} — {p.get('TITLE')} | {p.get('LINK')}\n"

api_key = """$ORKEY"""
payload = json.dumps({
    "model": "google/gemini-2.0-flash-001",
    "max_tokens": 2000,
    "messages": [{"role": "user", "content": prompt}]
}).encode()

req = urllib.request.Request(
    "https://openrouter.ai/api/v1/chat/completions",
    data=payload,
    headers={
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json",
        "HTTP-Referer": "https://github.com/DVSLewis/my-wiki",
        "X-Title": "DVS Argus Agent"
    },
    method="POST"
)

try:
    with urllib.request.urlopen(req, timeout=30) as resp:
        data = json.loads(resp.read().decode())
        output = data["choices"][0]["message"]["content"].strip()
        json_match = re.search(r'\[.*\]', output, re.DOTALL)
        if json_match:
            scored = json.loads(json_match.group())
            print(json.dumps({"posts": scored, "total_input": len(posts)}))
        else:
            raise Exception("No JSON in response")
except Exception as e:
    sys.stderr.write(f"[ERROR] Scoring: {e}\n")
    fallback = [{"handle": p.get("HANDLE",""), "title": p.get("TITLE",""), "link": p.get("LINK",""),
                 "score": 5, "category": "Uncategorized", "summary": p.get("SUMMARY", p.get("TITLE",""))}
                for p in posts]
    print(json.dumps({"posts": fallback, "total_input": len(posts), "error": str(e)}))
PYEOF

mkdir -p "${WIKI}/raw/daily-inbox"
python3 - <<PYEOF
import json, sys

try:
    with open("${SCORED_FILE}") as f: data = json.load(f)
except:
    data = {"posts": [], "error": "file read fail"}

posts = data.get("posts", [])
error = data.get("error", "")
brief_posts = [p for p in posts if p.get("score", 0) >= 7]
inbox_posts = [p for p in posts if p.get("score", 0) >= 8]

lines = [
    f"# Daily Brief — ${DATE}",
    "",
    f"> Generated: ${TIMESTAMP}",
    f"> Signals reviewed: {len(posts)}",
    f"> High signal (≥7): {len(brief_posts)}",
    f"> Inbox (≥8): {len(inbox_posts)}",
    f"> Status: {'[ERROR] ' + error if error else 'Healthy'}",
    "",
    "---",
    ""
]

if not brief_posts:
    lines.append("*No high-signal posts today.*")
else:
    for p in sorted(brief_posts, key=lambda x: x.get('score', 0), reverse=True):
        score = p.get('score', 0)
        handle = p.get('handle', '')
        title = p.get('title', '')
        link = p.get('link', '')
        category = p.get('category', '')
        summary = p.get('summary', '')
        lines.append(f"## [{score}/10] {title}")
        lines.append(f"**{handle}** | {category}")
        lines.append(f"{summary}")
        lines.append(f"[Source]({link})")
        lines.append("")

with open("${BRIEF_OUT}", 'w') as f:
    f.write('\n'.join(lines))

if inbox_posts:
    with open("${INBOX_OUT}", 'w') as f:
        f.write(f"# Inbox — ${DATE}\n\n")
        for p in inbox_posts:
            f.write(f"## {p.get('handle')}\n{p.get('summary')}\n{p.get('link')}\n\n")

tg_summary = f"DVS Brief ${DATE}: {len(brief_posts)} signals. " + (f"Errors: {error}" if error else "System nominal.")
with open("/tmp/argus-tg-summary.txt", 'w') as f:
    f.write(tg_summary)

print(f"[ARGUS] Brief written: {len(brief_posts)} signals, {len(inbox_posts)} inbox")
PYEOF

OPENAI_KEY=$(grep "^OPENAI_API_KEY=" /root/.hermes/.env | tail -1 | cut -d'=' -f2)
ORKEY=$(grep "^OPENROUTER_API_KEY=" /root/.hermes/.env | tail -1 | cut -d'=' -f2)

COGNEE_SKIP_CONNECTION_TEST=true \
OPENAI_API_KEY=$OPENAI_KEY \
EMBEDDING_PROVIDER=openai \
EMBEDDING_MODEL=text-embedding-3-small \
EMBEDDING_API_KEY=$OPENAI_KEY \
EMBEDDING_DIMENSIONS=1536 \
LLM_API_KEY=$ORKEY \
LLM_MODEL=openrouter/anthropic/claude-haiku-4.5 \
LLM_PROVIDER=openai \
LLM_ENDPOINT=https://openrouter.ai/api/v1 \
python3 /tmp/cognee_block.py

TG_MSG=$(cat /tmp/argus-tg-summary.txt 2>/dev/null || echo "DVS Brief ${DATE}: no data")
timeout "$TIMEOUT_VAL" /root/.hermes/hermes-agent/venv/bin/hermes chat -Q -q "Send to Donny on Telegram: ${TG_MSG}" \
  --provider openrouter --model "$MODEL_NAME" 2>/dev/null || echo "[WARN] TG send failed"

echo "[${TIMESTAMP}] ARGUS | daily-brief | complete | ${BRIEF_OUT}" >> "${WIKI}/wiki/log.md"

cd "$WIKI" && git add . && git commit -m "Argus Brief ${DATE}" && git push origin main 2>/dev/null || echo "[WARN] Git sync failed"

rm -f /tmp/argus-posts-${DATE}.txt /tmp/argus-scored-${DATE}.json /tmp/argus-tg-summary.txt

echo ""
echo "ARGUS COMPLETE — ${TIMESTAMP}"
echo "=============================================="
