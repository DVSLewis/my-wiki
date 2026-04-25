#!/usr/bin/env bash
# argus-daily-brief.sh — DVS Argus Daily Intelligence Brief Pipeline
# Non-interactive, timeout-safe, Zo API fallback

set -o pipefail

LOG="/tmp/argus-brief.log"
DATE="$(TZ=Europe/Berlin date +%Y-%m-%d)"
TIMESTAMP="$(TZ=Europe/Berlin date '+%Y-%m-%d %H:%M %Z')"
WIKI="/root/workspace/my-wiki"
BRIEF_OUT="${WIKI}/wiki/daily-brief-${DATE}.md"
INBOX_OUT="${WIKI}/raw/daily-inbox/${DATE}.md"
RSSHUB_BASE="https://rsshub.app/twitter/user"
TELEGRAM_CHAT_ID="6127567978"

MODEL_NAME="google/gemini-2.0-flash-001"
TIMEOUT_VAL="60s"
CURL_OPTS="--max-time 20 --retry 3 --retry-delay 2 -sf"

exec > >(tee -a "$LOG") 2>&1

echo ""
echo "=============================================="
echo "ARGUS BRIEF — ${TIMESTAMP}"
echo "=============================================="

# Account tiers
TIER1="VitalikButerin karpathy koeppelmann timbeiko samczsun gakonst superphiz hudsonjameson"
TIER2="shivsakhuja echinstitute ethereumfndn AustinGriffiths cyrilXBT"
TIER3="aboutcircles GnosisDAO gnosischain safe gnosisguild cowswap kylearojas thedaofund chaskin22 etheconomiczone"
ALL_ACCOUNTS="$TIER1 $TIER2 $TIER3"

# Fetch RSS feeds
FEED_DIR="/tmp/argus-feeds-${DATE}"
mkdir -p "$FEED_DIR"

fetch_feed() {
    local handle="$1"
    local url="${RSSHUB_BASE}/${handle}"
    local out="${FEED_DIR}/${handle}.xml"
    if curl $CURL_OPTS "$url" -o "$out" 2>/dev/null && [ -s "$out" ]; then
        echo "[OK] $handle"
    else
        echo "[SKIP] $handle"
        echo "" > "$out"
    fi
}

echo "--- Fetching RSS feeds ---"
for handle in $ALL_ACCOUNTS; do
    fetch_feed "$handle" &
done
wait

# Parse posts
POSTS_FILE="/tmp/argus-posts-${DATE}.txt"
> "$POSTS_FILE"

parse_feed() {
    local handle="$1"
    local feed="${FEED_DIR}/${handle}.xml"
    [ ! -s "$feed" ] && return
    python3 - 2>/dev/null <<PYEOF
import xml.etree.ElementTree as ET
from datetime import datetime, timezone, timedelta
from email.utils import parsedate_to_datetime

handle = "$handle"
feed_file = "$feed"
cutoff = datetime.now(timezone.utc) - timedelta(hours=36)

try:
    tree = ET.parse(feed_file)
    root = tree.getroot()
    ns = {'atom': 'http://www.w3.org/2005/Atom'}
    items = root.findall('.//item') or root.findall('.//atom:entry', ns)
    for item in items[:10]:
        title_el = item.find('title') or item.find('atom:title', ns)
        link_el = item.find('link') or item.find('atom:link', ns)
        date_el = item.find('pubDate') or item.find('published') or item.find('atom:published', ns)
        title = title_el.text if title_el is not None else ''
        link = ''
        if link_el is not None:
            link = link_el.text if link_el.text else (link_el.get('href', '') if hasattr(link_el, 'get') else '')
        date_str = date_el.text if date_el is not None else ''
        if not title or len(title.strip()) < 5:
            continue
        try:
            pub_date = parsedate_to_datetime(date_str)
            if pub_date < cutoff:
                continue
        except Exception:
            pass
        title = title.strip().replace('\n', ' ')[:200]
        link = link.strip() if link else 'https://x.com/' + handle
        print(f"HANDLE={handle}|||TITLE={title}|||LINK={link}")
except Exception:
    pass
PYEOF
}

for handle in $ALL_ACCOUNTS; do
    parse_feed "$handle" >> "$POSTS_FILE"
done

POST_COUNT=$(wc -l < "$POSTS_FILE" | tr -d ' ')
echo "Posts found: $POST_COUNT"

# Score posts
SCORED_FILE="/tmp/argus-scored-${DATE}.json"
POSTS_CONTENT=$(cat "$POSTS_FILE" 2>/dev/null || echo "")

python3 - <<PYEOF > "$SCORED_FILE"
import json, subprocess, sys, re

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
    print(json.dumps({"posts": [], "error": "no posts found"}))
    sys.exit(0)

prompt = f"You are Argus, an intelligence analyst. Score each post 1-10 for relevance to Ethereum, DAOs, AI, and Gnosis. Return ONLY a JSON array of objects with keys: handle, title, link, score, category, summary. Posts:\n"
for i, p in enumerate(posts[:50]):
    prompt += f"{i+1}. @{p.get('HANDLE')} — {p.get('TITLE')} | {p.get('LINK')}\n"

try:
    res = subprocess.run(
        ["timeout", "$TIMEOUT_VAL", "hermes", "chat", "--non-interactive", "-q", prompt, "--provider", "openrouter", "--model", "$MODEL_NAME"],
        capture_output=True, text=True, timeout=65
    )
    if res.returncode != 0:
        raise Exception(f"Hermes failed: {res.returncode}")
    output = res.stdout.strip()
    json_match = re.search(r'\[.*\]', output, re.DOTALL)
    if json_match:
        scored = json.loads(json_match.group())
        print(json.dumps({"posts": scored, "total_input": len(posts)}))
    else:
        raise Exception("No JSON in LLM output")
except Exception as e:
    sys.stderr.write(f"[ERROR] Scoring: {e}\n")
    fallback = [{"handle": p.get("HANDLE",""), "title": p.get("TITLE",""), "link": p.get("LINK",""), "score": 5, "category": "Uncategorized", "summary": p.get("TITLE","")} for p in posts]
    print(json.dumps({"posts": fallback, "total_input": len(posts), "error": str(e)}))
PYEOF

# Render brief
python3 - <<PYEOF
import json, sys
from datetime import datetime

try:
    with open("$SCORED_FILE") as f: data = json.load(f)
except: data = {"posts": [], "error": "file read fail"}

posts = data.get("posts", [])
error = data.get("error", "")
brief_posts = [p for p in posts if p.get("score", 0) >= 7]
inbox_posts = [p for p in posts if p.get("score", 0) >= 8]

lines = [
    f"# Daily Brief — $DATE",
    "",
    f"> Generated: $TIMESTAMP",
    f"> Status: {'[ERROR] ' + error if error else 'Healthy'}",
    ""
]
if not brief_posts:
    lines.append("*No high-signal posts today.*")
else:
    for p in sorted(brief_posts, key=lambda x: x.get('score', 0), reverse=True):
        lines.append(f"- [{p.get('score')}/10] **@{p.get('handle')}**: {p.get('summary')} [Link]({p.get('link')})")

with open("$BRIEF_OUT", 'w') as f: f.write('\n'.join(lines))

if inbox_posts:
    with open("$INBOX_OUT", 'w') as f:
        f.write(f"# High-Signal — $DATE\n\n")
        for p in inbox_posts:
            f.write(f"## {p.get('handle')}\n{p.get('summary')}\n{p.get('link')}\n\n")

tg_summary = f"DVS Brief $DATE: {len(brief_posts)} signals. " + (f"Errors: {error}" if error else "System nominal.")
with open("/tmp/argus-tg-summary.txt", 'w') as f: f.write(tg_summary)
PYEOF

# Send Telegram summary
TG_MSG=$(cat /tmp/argus-tg-summary.txt 2>/dev/null || echo "DVS Brief $DATE: no data")
timeout "$TIMEOUT_VAL" hermes chat --non-interactive -q "Send to Donny on Telegram: ${TG_MSG}" --provider openrouter --model "$MODEL_NAME" 2>/dev/null || echo "[WARN] TG send failed"

# Git sync
cd "$WIKI" && git add . && git commit -m "Argus Brief $DATE" && git push origin main 2>/dev/null || echo "[WARN] Git sync failed"

# Cleanup
rm -rf "$FEED_DIR" /tmp/argus-posts-${DATE}.txt "$SCORED_FILE" /tmp/argus-tg-summary.txt 2>/dev/null
echo "DONE."