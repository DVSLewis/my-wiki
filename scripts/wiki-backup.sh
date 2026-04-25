#!/usr/bin/env bash
# wiki-backup.sh — Daily backup of my-wiki at 11pm Europe/Berlin
# Runs independently from the main repo

set -o pipefail

SRC="/root/workspace/my-wiki"
DST="/root/workspace/my-wiki-backup"
LOG="/tmp/wiki-backup.log"
DATE="$(date '+%Y-%m-%d')"
TIMESTAMP="$(date '+%Y-%m-%d %H:%M %Z')"

exec >> >(tee -a "$LOG") 2>&1

echo ""
echo "=== WIKI BACKUP — $TIMESTAMP ==="

# Sync all files from my-wiki to backup directory
rsync -a --delete "$SRC/" "$DST/" 2>>"$LOG"

# Commit with timestamp inside the backup repo
cd "$DST" || exit 1
git add .
git commit -m "Backup $DATE" 2>/dev/null || echo "[INFO] No changes to commit"
echo "Backup complete → $DST"
echo "DONE."