#!/usr/bin/env bash
# argus-daily-brief.sh
# DVS Argus Daily Intelligence Brief Pipeline
# Runs via Hermes cron at 9am Europe/Berlin daily
# Reads RSSHub feeds for all monitored accounts, scores posts 1-10,
# writes daily brief to wiki, sends Telegram summary, saves high-scorers to inbox
# Logs to /tmp/argus-brief.log

set -euo pipefail

LOG="/tmp/argus-brief.log"
DATE="$(TZ=Europe/Berlin date +%Y-%m-%d)"
TIMESTAMP="$(TZ=Europe/Berlin date '+%Y-%m-%d %H:%M %Z')"
WIKI="/root/workspace/my-wiki"
BRIEF_OUT="${WIKI}/wiki/daily-brief-${DATE}.md"
INBOX_OUT="${WIKI}/raw/daily-inbox/${DATE}.md"
RSSHUB_BASE="https://rsshub.app/twitter/user"
TELEGRAM_CHAT_ID="6127567978"
HERMES_GATEWAY="http://127.0.0.1:4242"  # Hermes local API if available

exec > >(tee -a "$LOG") 2>&1
echo ""
echo "=============================================="
echo "ARGUS BRIEF — ${TIMESTAMP}"
echo "=============================================="

# ---------------------------------------------------------------------------
# Account tiers
# ---------------------------------------------------------------------------
TIER1="VitalikButerin karpathy koeppelmann timbeiko samczsun gakonst superphiz hudsonjameson"
TIER2="shivsakhuja echinstitute ethereumfndn AustinGriffiths cyrilXBT"
TIER3="aboutcircles GnosisDAO gnosischain safe gnosisguild cowswap kylearojas thedaofund chaskin22 etheconomiczone"

ALL_ACCOUNTS="$TIER1 $TIER2 $TIER3"
TOTAL_ACCOUNTS=$(echo "$ALL_ACCOUNTS" | wc -w | tr -d ' ')

echo "Accounts to scan: $TOTAL_ACCOUNTS"

# ---------------------------------------------------------------------------
# Fetch RSS feeds via RSSHub
# ---------------------------------------------------------------------------
FEED_DIR="/tmp/argus-feeds-${DATE}"
mkdir -p "$FEED_DIR"

fetch_feed() {
    local handle="$1"
    local url="${RSSHUB_BASE}/${handle}"
    local out="${FEED_DIR}/${handle}.xml"
    
    if curl -sf --max-time 15 --retry 2 "$url" -o "$out" 2>/dev/null; then
        echo "[OK] $handle"
    else
        echo "[SKIP] $handle — feed unavailable"
        echo "" > "$out"
    fi
}

echo ""
echo "--- Fetching RSS feeds ---"
for handle in $ALL_ACCOUNTS; do
    fetch_feed "$handle" &
done
wait
echo "Feeds fetched."

# ---------------------------------------------------------------------------
# Parse posts from RSS XML (extract titles + links, last 24h only)
# ---------------------------------------------------------------------------
POSTS_FILE="/tmp/argus-posts-${DATE}.txt"
> "$POSTS_FILE"

parse_feed() {
    local handle="$1"
    local feed="${FEED_DIR}/${handle}.xml"
    
    if [ ! -s "$feed" ]; then
        return
    fi
    
    # Extract items: title, link, pubDate using python for reliability
    python3 - <<PYEOF
import xml.etree.ElementTree as ET
import sys
from datetime import datetime, timezone, timedelta

handle = "$handle"
feed_file = "$feed"
cutoff = datetime.now(timezone.utc) - timedelta(hours=24)

try:
    tree = ET.parse(feed_file)
    root = tree.getroot()
    
    # Handle both RSS and Atom formats
    ns = {'atom': 'http://www.w3.org/2005/Atom'}
    items = root.findall('.//item') or root.findall('.//atom:entry', ns)
    
    for item in items[:10]:  # cap at 10 per account
        title_el = item.find('title') or item.find('atom:title', ns)
        link_el = item.find('link') or item.find('atom:link', ns)
        date_el = item.find('pubDate') or item.find('published') or item.find('atom:published', ns)
        
        title = title_el.text if title_el is not None else ''
        link = link_el.text if link_el is not None else (link_el.get('href', '') if link_el is not None else '')
        date_str = date_el.text if date_el is not None else ''
        
        if not title or len(title.strip()) < 5:
            continue
            
        # Try to filter by recency — skip if older than 24h
        # (be permissive if date parse fails)
        try:
            from email.utils import parsedate_to_datetime
            pub_date = parsedate_to_datetime(date_str)
            if pub_date < cutoff:
                continue
        except Exception:
            pass  # keep item if date unparseable
        
        title = title.strip().replace('\n', ' ')[:200]
        link = link.strip() if link else 'https://x.com/' + handle
        
        print(f"HANDLE={handle}|||TITLE={title}|||LINK={link}")
except Exception as e:
    sys.stderr.write(f"[WARN] parse error for {handle}: {e}\n")
PYEOF
}

echo ""
echo "--- Parsing posts ---"
for handle in $ALL_ACCOUNTS; do
    parse_feed "$handle" >> "$POSTS_FILE" 2>/dev/null
done

POST_COUNT=$(wc -l < "$POSTS_FILE" | tr -d ' ')
echo "Posts found (last 24h): $POST_COUNT"

if [ "$POST_COUNT" -eq 0 ]; then
    echo "[WARN] No posts found. Feeds may be down. Check RSSHub."
    POST_COUNT=0
fi

# ---------------------------------------------------------------------------
# Score and rank posts using LLM (Hermes chat -q with free model context)
# ---------------------------------------------------------------------------
echo ""
echo "--- Scoring posts via LLM ---"

SCORED_FILE="/tmp/argus-scored-${DATE}.json"

# Build scoring prompt
POSTS_CONTENT=$(cat "$POSTS_FILE" 2>/dev/null || echo "")

python3 - <<PYEOF > "$SCORED_FILE"
import json
import subprocess
import sys

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

# Build scoring prompt — use free model (gemini-flash or similar)
prompt_lines = ["You are Argus, intelligence analyst for DVS (Donny Lewis). Score each post 1-10 for relevance to:"]
prompt_lines += ["1. Ethereum protocol (EIPs, upgrades, client updates, staking, security)"]
prompt_lines += ["2. DAOs, governance, public goods, ReFi, Circles UBI"]
prompt_lines += ["3. AI agents and LLM research"]
prompt_lines += ["4. Gnosis ecosystem (Chain, Safe, CoW, Circles, Guild)"]
prompt_lines += ["5. Donny's active projects: ETHis 2026, WeTryBetter, IRK Magazine Paris"]
prompt_lines += [""]
prompt_lines += ["Scoring: 9-10=breaking/critical, 7-8=strong signal, 5-6=informational, 1-4=noise"]
prompt_lines += ["Assign ONE category: EthereumCore | DAOsPublicGoods | DeFi | AIAgents"]
prompt_lines += [""]
prompt_lines += ["Respond ONLY with JSON array. Each item: {\"handle\": \"...\", \"title\": \"...\", \"link\": \"...\", \"score\": N, \"category\": \"...\", \"summary\": \"one line\"}"]
prompt_lines += [""]
prompt_lines += ["Posts to score:"]

for i, p in enumerate(posts[:50]):  # cap at 50 per run
    prompt_lines.append(f"{i+1}. @{p.get('HANDLE','')} — {p.get('TITLE','')} | {p.get('LINK','')}")

prompt = '\n'.join(prompt_lines)

# Call hermes with free model
try:
    result = subprocess.run(
        ["hermes", "chat", "-q", prompt, "--provider", "openrouter", "--model", "google/gemini-flash-1.5"],
        capture_output=True, text=True, timeout=120
    )
    output = result.stdout.strip()
    
    # Extract JSON from output
    import re
    json_match = re.search(r'\[.*\]', output, re.DOTALL)
    if json_match:
        scored = json.loads(json_match.group())
        print(json.dumps({"posts": scored, "total_input": len(posts)}))
    else:
        # Fallback: return unscored posts with score=5
        fallback = [{"handle": p.get("HANDLE",""), "title": p.get("TITLE",""), 
                     "link": p.get("LINK",""), "score": 5, 
                     "category": "EthereumCore", "summary": p.get("TITLE","")} for p in posts]
        print(json.dumps({"posts": fallback, "total_input": len(posts), "error": "llm_parse_fail", "raw": output[:500]}))
except subprocess.TimeoutExpired:
    print(json.dumps({"posts": [], "error": "llm_timeout"}))
except Exception as e:
    print(json.dumps({"posts": [], "error": str(e)}))
PYEOF

echo "Scoring complete."

# ---------------------------------------------------------------------------
# Render daily brief markdown from scored posts
# ---------------------------------------------------------------------------
echo ""
echo "--- Rendering brief ---"

python3 - <<PYEOF
import json
import sys
from datetime import datetime

date_str = "$DATE"
timestamp = "$TIMESTAMP"
wiki = "$WIKI"
brief_out = "$BRIEF_OUT"
inbox_out = "$INBOX_OUT"
scored_file = "$SCORED_FILE"

try:
    with open(scored_file) as f:
        data = json.load(f)
except Exception as e:
    print(f"[ERROR] Could not read scored file: {e}")
    sys.exit(1)

posts = data.get("posts", [])
total_input = data.get("total_input", len(posts))

# Filter 7+ for brief, 8+ for inbox
brief_posts = [p for p in posts if p.get("score", 0) >= 7]
inbox_posts = [p for p in posts if p.get("score", 0) >= 8]

# Sort descending by score
brief_posts.sort(key=lambda x: x.get("score", 0), reverse=True)
inbox_posts.sort(key=lambda x: x.get("score", 0), reverse=True)

categories = {
    "EthereumCore": ("Ethereum Core", "Protocol upgrades, EIPs, client updates, staking, security"),
    "DAOsPublicGoods": ("DAOs and Public Goods", "Governance, grants, ReFi, Circles, ETHis 2026 adjacent"),
    "DeFi": ("DeFi", "CoW Protocol, Gnosis Chain, Safe, MEV, on-chain analytics"),
    "AIAgents": ("AI and Agents", "LLM research, AI x crypto, autonomous agents, infra"),
}

# Build brief markdown
lines = [f"# Daily Brief — {date_str}", ""]
lines += [f"> Generated: {timestamp}"]
lines += [f"> Sources: {$TOTAL_ACCOUNTS} accounts across 3 tiers | Posts reviewed: {total_input} | Included (7+): {len(brief_posts)}"]
lines += [""]

has_content = False
for cat_key, (cat_name, cat_desc) in categories.items():
    cat_posts = [p for p in brief_posts if p.get("category") == cat_key]
    if not cat_posts:
        continue
    has_content = True
    lines += [f"---", f"", f"### {cat_name}", f"*{cat_desc}*", ""]
    for p in cat_posts:
        handle = p.get("handle", "unknown")
        score = p.get("score", 0)
        summary = p.get("summary", p.get("title", ""))[:120]
        link = p.get("link", "")
        lines.append(f"- [{score}/10] **@{handle}** — {summary}. [Link]({link})")
    lines.append("")

if not has_content:
    lines += ["---", "", "*No posts scored 7+ today. Low-signal day or feed issues.*", ""]

# Action items placeholder
lines += ["---", "", "### Donny Action Items", ""]
action_posts = [p for p in brief_posts if p.get("score", 0) >= 9]
if action_posts:
    for p in action_posts:
        lines.append(f"- [ ] @{p.get('handle','')} — {p.get('summary','')[:80]} [{p.get('score',0)}/10]")
else:
    lines.append("- [ ] No urgent action items today")
lines.append("")

# Gaps and flags
lines += ["---", "", "### Gaps and Flags", ""]
error = data.get("error", "")
if error:
    lines.append(f"- Pipeline note: {error}")
lines.append(f"- Total posts reviewed: {total_input} from {$TOTAL_ACCOUNTS} accounts")
lines.append("")

# Telegram summary (plain text, max 4 sentences)
top_items = brief_posts[:3]
if top_items:
    tg_items = "; ".join([f"@{p.get('handle','')} on {p.get('summary','')[:50]}" for p in top_items])
    tg_summary = f"DVS Brief {date_str}: {len(brief_posts)} signals found across Ethereum, DAOs, DeFi, AI. Top: {tg_items}."
    if action_posts:
        tg_summary += f" {len(action_posts)} item(s) need your attention."
else:
    tg_summary = f"DVS Brief {date_str}: Low-signal day. {total_input} posts reviewed, none scored 7+. Check feeds."

lines += ["---", "", "**Telegram Summary:**", f"> {tg_summary}", ""]

# Related pages
lines += ["---", "", "## Related Pages", "- [[argus-monitored-accounts.md]]", "- [[argus-brief-template.md]]", ""]

# Write brief
with open(brief_out, 'w') as f:
    f.write('\n'.join(lines))
print(f"[OK] Brief written: {brief_out}")

# Write inbox (8+ posts for Athena)
if inbox_posts:
    inbox_lines = [f"# High-Signal Inbox — {date_str}", ""]
    inbox_lines += [f"> Posts scored 8+ saved for Athena synthesis."]
    inbox_lines += [f"> Source: Argus daily brief | Accounts: {$TOTAL_ACCOUNTS}"]
    inbox_lines += [""]
    for p in inbox_posts:
        handle = p.get("handle", "")
        score = p.get("score", 0)
        title = p.get("title", "")
        summary = p.get("summary", title)
        link = p.get("link", "")
        cat = p.get("category", "")
        inbox_lines.append(f"## [{score}/10] @{handle} — {cat}")
        inbox_lines.append(f"**{title}**")
        inbox_lines.append(f"> {summary}")
        inbox_lines.append(f"Source: {link}")
        inbox_lines.append("")
    with open(inbox_out, 'w') as f:
        f.write('\n'.join(inbox_lines))
    print(f"[OK] Inbox written: {inbox_out} ({len(inbox_posts)} posts)")
else:
    print(f"[INFO] No 8+ posts today — inbox not written")

# Export telegram summary for shell to pick up
with open("/tmp/argus-tg-summary.txt", 'w') as f:
    f.write(tg_summary)

print(f"[OK] Render complete. Brief posts: {len(brief_posts)}, Inbox posts: {len(inbox_posts)}")
PYEOF

# ---------------------------------------------------------------------------
# Send Telegram summary via Hermes
# ---------------------------------------------------------------------------
echo ""
echo "--- Sending Telegram summary ---"

TG_MSG=$(cat /tmp/argus-tg-summary.txt 2>/dev/null || echo "DVS Brief ${DATE}: pipeline completed. Check wiki for full brief.")

hermes chat -q "Send this message to Donny on Telegram (chat ID 6127567978): ${TG_MSG}

Then confirm it was sent." --provider anthropic --model claude-haiku-3-5 2>/dev/null || \
echo "[WARN] Hermes Telegram send failed — brief still written to wiki"

# ---------------------------------------------------------------------------
# Push to GitHub
# ---------------------------------------------------------------------------
echo ""
echo "--- Pushing to GitHub ---"

cd "$WIKI"
git add wiki/daily-brief-${DATE}.md \
        raw/daily-inbox/${DATE}.md \
        wiki/argus-monitored-accounts.md \
        wiki/argus-brief-template.md \
        2>/dev/null || true

if git diff --cached --quiet; then
    echo "[INFO] Nothing new to commit."
else
    git commit -m "Argus daily brief ${DATE}: automated intelligence pipeline"
    git push origin main
    echo "[OK] Pushed to GitHub."
fi

# ---------------------------------------------------------------------------
# Cleanup temp files
# ---------------------------------------------------------------------------
rm -rf "$FEED_DIR" /tmp/argus-posts-${DATE}.txt /tmp/argus-scored-${DATE}.json /tmp/argus-tg-summary.txt 2>/dev/null || true

echo ""
echo "=============================================="
echo "ARGUS BRIEF COMPLETE — ${DATE}"
echo "Brief: ${BRIEF_OUT}"
echo "=============================================="
