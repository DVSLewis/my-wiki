#!/usr/bin/env bash
# athena-weekly-synthesis.sh
# DVS Athena Weekly Knowledge Synthesis Pipeline
# Runs via Hermes cron at 10am Europe/Berlin every Monday and Thursday
# Reads raw/daily-inbox/ since last synthesis, identifies patterns,
# updates wiki pages, creates synthesis note, sends Telegram summary
# Logs to /tmp/athena-synthesis.log

set -euo pipefail

LOG="/tmp/athena-synthesis.log"
DATE="$(TZ=Europe/Berlin date +%Y-%m-%d)"
TIMESTAMP="$(TZ=Europe/Berlin date '+%Y-%m-%d %H:%M %Z')"
WIKI="/root/workspace/my-wiki"
INBOX_DIR="${WIKI}/raw/daily-inbox"
SYNTHESIS_OUT="${WIKI}/wiki/knowledge-synthesis-${DATE}.md"
REFERENCES="${WIKI}/wiki/references.md"
LAST_SYNTHESIS_FILE="${WIKI}/.last-synthesis"
TELEGRAM_CHAT_ID="6127567978"

exec > >(tee -a "$LOG") 2>&1
echo ""
echo "=============================================="
echo "ATHENA SYNTHESIS — ${TIMESTAMP}"
echo "=============================================="

# ---------------------------------------------------------------------------
# Determine scope: files in inbox since last synthesis
# ---------------------------------------------------------------------------
LAST_SYNTHESIS_DATE=""
if [ -f "$LAST_SYNTHESIS_FILE" ]; then
    LAST_SYNTHESIS_DATE=$(cat "$LAST_SYNTHESIS_FILE" | tr -d '[:space:]')
    echo "Last synthesis: $LAST_SYNTHESIS_DATE"
else
    echo "First synthesis run — reading all inbox files"
fi

# Gather inbox files newer than last synthesis (or all if first run)
INBOX_FILES=()
if [ -n "$LAST_SYNTHESIS_DATE" ]; then
    while IFS= read -r -d '' f; do
        fname=$(basename "$f" .md)
        if [[ "$fname" > "$LAST_SYNTHESIS_DATE" ]]; then
            INBOX_FILES+=("$f")
        fi
    done < <(find "$INBOX_DIR" -name "*.md" -not -name ".gitkeep" -print0 2>/dev/null | sort -z)
else
    while IFS= read -r -d '' f; do
        INBOX_FILES+=("$f")
    done < <(find "$INBOX_DIR" -name "*.md" -not -name ".gitkeep" -print0 2>/dev/null | sort -z)
fi

echo "Inbox files to process: ${#INBOX_FILES[@]}"

if [ "${#INBOX_FILES[@]}" -eq 0 ]; then
    echo "[INFO] No new inbox files since last synthesis. Exiting."
    # Send brief Telegram notification
    hermes chat -q "Send this to Donny on Telegram (chat ID 6127567978): Athena synthesis ${DATE}: no new high-signal posts since last run. Knowledge base current." \
        --provider anthropic --model claude-haiku-3-5 2>/dev/null || true
    exit 0
fi

# ---------------------------------------------------------------------------
# Concatenate inbox content for LLM synthesis
# ---------------------------------------------------------------------------
COMBINED_INBOX="/tmp/athena-combined-${DATE}.txt"
> "$COMBINED_INBOX"

for f in "${INBOX_FILES[@]}"; do
    fname=$(basename "$f")
    echo "" >> "$COMBINED_INBOX"
    echo "=== FILE: $fname ===" >> "$COMBINED_INBOX"
    cat "$f" >> "$COMBINED_INBOX"
    echo "" >> "$COMBINED_INBOX"
done

COMBINED_LINES=$(wc -l < "$COMBINED_INBOX")
echo "Combined inbox: $COMBINED_LINES lines"

# ---------------------------------------------------------------------------
# Read existing wiki state for context
# ---------------------------------------------------------------------------
echo ""
echo "--- Reading wiki context ---"

EXISTING_WIKI_PAGES=$(find "${WIKI}/wiki/" -name "*.md" -not -name "daily-brief-*" -not -name "knowledge-synthesis-*" 2>/dev/null | sort | head -20)
WIKI_SUMMARY=""
for page in $EXISTING_WIKI_PAGES; do
    pname=$(basename "$page")
    first_line=$(head -1 "$page" 2>/dev/null || echo "")
    WIKI_SUMMARY="${WIKI_SUMMARY}\n- ${pname}: ${first_line}"
done

# ---------------------------------------------------------------------------
# Run Athena synthesis via Hermes (Claude Sonnet 4.6)
# ---------------------------------------------------------------------------
echo ""
echo "--- Running Athena synthesis ---"

SYNTHESIS_PROMPT="You are Athena, the DVS knowledge synthesis agent. You maintain the DVS wiki using the Karpathy LLM wiki pattern.

Today is ${DATE}. You are synthesizing intelligence from ${#INBOX_FILES[@]} high-signal posts (scored 8+) collected by Argus since ${LAST_SYNTHESIS_DATE:-the beginning}.

EXISTING WIKI PAGES:
${WIKI_SUMMARY}

INBOX CONTENT TO SYNTHESIZE:
$(cat "$COMBINED_INBOX" | head -3000)

Your tasks:
1. Identify the 3-5 most important insights, patterns, or developments across all posts
2. List any new sources worth tracking (add to references.md)
3. List existing wiki pages that should be updated with new information
4. Write a synthesis report: key themes, cross-domain patterns, emerging signals
5. Draft a 3-sentence Telegram summary for Donny (plain text, no markdown)

Output format (strict JSON):
{
  \"insights\": [\"insight 1\", \"insight 2\", ...],
  \"new_sources\": [{\"name\": \"...\", \"url\": \"...\", \"why\": \"...\"}],
  \"wiki_updates\": [{\"page\": \"page.md\", \"what_to_add\": \"brief description\"}],
  \"synthesis_report\": \"full markdown synthesis text (500-800 words)\",
  \"telegram_summary\": \"plain text 3-sentence summary for Donny\"
}"

SYNTHESIS_RESULT="/tmp/athena-synthesis-result-${DATE}.json"

hermes chat -q "$SYNTHESIS_PROMPT" \
    --provider anthropic \
    --model claude-sonnet-4-6 \
    2>/dev/null > "/tmp/athena-raw-output-${DATE}.txt" || true

# Extract JSON from LLM output
python3 - <<PYEOF > "$SYNTHESIS_RESULT"
import json, re, sys

with open("/tmp/athena-raw-output-${DATE}.txt") as f:
    raw = f.read()

# Try to find JSON block
json_match = re.search(r'\{.*\}', raw, re.DOTALL)
if json_match:
    try:
        data = json.loads(json_match.group())
        print(json.dumps(data))
        sys.exit(0)
    except json.JSONDecodeError:
        pass

# Fallback: construct minimal result
print(json.dumps({
    "insights": ["Synthesis LLM parse failed — review raw output"],
    "new_sources": [],
    "wiki_updates": [],
    "synthesis_report": raw[:2000] if raw else "No output from LLM",
    "telegram_summary": f"Athena synthesis {DATE}: processed {len(${#INBOX_FILES[@]})} inbox files. Check wiki for details."
}))
PYEOF

echo "Synthesis complete."

# ---------------------------------------------------------------------------
# Write knowledge synthesis wiki page
# ---------------------------------------------------------------------------
echo ""
echo "--- Writing synthesis page ---"

python3 - <<PYEOF
import json, sys, os
from datetime import datetime

date_str = "$DATE"
timestamp = "$TIMESTAMP"
synthesis_file = "$SYNTHESIS_RESULT"
synthesis_out = "$SYNTHESIS_OUT"
references_file = "$REFERENCES"
inbox_count = len(${#INBOX_FILES[@]:0:1})  # bash array not directly accessible

try:
    with open(synthesis_file) as f:
        data = json.load(f)
except Exception as e:
    print(f"[ERROR] Could not read synthesis result: {e}")
    sys.exit(1)

insights = data.get("insights", [])
new_sources = data.get("new_sources", [])
wiki_updates = data.get("wiki_updates", [])
report = data.get("synthesis_report", "")
tg_summary = data.get("telegram_summary", "")

# Write synthesis markdown
lines = [
    f"---",
    f"title: Knowledge Synthesis {date_str}",
    f"created: {date_str}",
    f"updated: {date_str}",
    f"type: synthesis",
    f"tags: [synthesis, intelligence, ethereum, daos, ai-agents]",
    f"sources: [raw/daily-inbox/]",
    f"---",
    "",
    f"# Knowledge Synthesis — {date_str}",
    "",
    f"> Athena weekly synthesis. Generated: {timestamp}",
    f"> Inbox files processed: ${#INBOX_FILES[@]}",
    "",
    "---",
    "",
    "## Key Insights",
    "",
]
for insight in insights:
    lines.append(f"- {insight}")
lines += ["", "---", "", "## Full Synthesis", ""]
lines.append(report)
lines += ["", "---", "", "## Wiki Updates Triggered", ""]
if wiki_updates:
    for u in wiki_updates:
        lines.append(f"- **{u.get('page','')}** — {u.get('what_to_add','')}")
else:
    lines.append("- No specific page updates identified this cycle")
lines += ["", "---", "", "## New Sources Identified", ""]
if new_sources:
    for s in new_sources:
        lines.append(f"- **{s.get('name','')}** ({s.get('url','')}) — {s.get('why','')}")
else:
    lines.append("- No new sources identified this cycle")
lines += ["", "---", "", "## Related Pages", "- [[references.md]]", "- [[argus-monitored-accounts.md]]", ""]

with open(synthesis_out, 'w') as f:
    f.write('\n'.join(lines))
print(f"[OK] Synthesis page written: {synthesis_out}")

# Update references.md if new sources
if new_sources:
    try:
        with open(references_file, 'a') as f:
            f.write(f"\n\n## New Sources — {date_str} (Athena synthesis)\n")
            for s in new_sources:
                f.write(f"- **{s.get('name','')}**: {s.get('url','')} — {s.get('why','')}\n")
        print(f"[OK] references.md updated with {len(new_sources)} new sources")
    except Exception as e:
        print(f"[WARN] Could not update references.md: {e}")

# Save telegram summary for shell
with open("/tmp/athena-tg-summary.txt", 'w') as f:
    f.write(tg_summary)

print("[OK] Python synthesis render complete")
PYEOF

# ---------------------------------------------------------------------------
# Send Telegram summary
# ---------------------------------------------------------------------------
echo ""
echo "--- Sending Telegram summary ---"

TG_MSG=$(cat /tmp/athena-tg-summary.txt 2>/dev/null || echo "Athena synthesis ${DATE} complete. Check wiki for knowledge synthesis report.")

hermes chat -q "Send this message to Donny on Telegram (chat ID 6127567978): ${TG_MSG}

Then confirm it was sent." \
    --provider anthropic --model claude-haiku-3-5 2>/dev/null || \
echo "[WARN] Hermes Telegram send failed — synthesis still written to wiki"

# ---------------------------------------------------------------------------
# Push to GitHub
# ---------------------------------------------------------------------------
echo ""
echo "--- Pushing to GitHub ---"

cd "$WIKI"
git add wiki/knowledge-synthesis-${DATE}.md \
        wiki/references.md \
        2>/dev/null || true

# Also stage any wiki page updates if they exist
git add wiki/ 2>/dev/null || true

if git diff --cached --quiet; then
    echo "[INFO] Nothing new to commit."
else
    git commit -m "Athena synthesis ${DATE}: weekly knowledge update"
    git push origin main
    echo "[OK] Pushed to GitHub."
fi

# ---------------------------------------------------------------------------
# Update last synthesis marker
# ---------------------------------------------------------------------------
echo "$DATE" > "$LAST_SYNTHESIS_FILE"
echo "[OK] Last synthesis marker updated: $DATE"

# ---------------------------------------------------------------------------
# Cleanup
# ---------------------------------------------------------------------------
rm -f "/tmp/athena-combined-${DATE}.txt" \
      "/tmp/athena-raw-output-${DATE}.txt" \
      "/tmp/athena-synthesis-result-${DATE}.json" \
      "/tmp/athena-tg-summary.txt" 2>/dev/null || true

echo ""
echo "=============================================="
echo "ATHENA SYNTHESIS COMPLETE — ${DATE}"
echo "Synthesis: ${SYNTHESIS_OUT}"
echo "=============================================="
