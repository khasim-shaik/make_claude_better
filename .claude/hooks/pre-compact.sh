#!/bin/bash
# pre-compact.sh - Backup transcript before context compaction
#
# This hook runs BEFORE Claude Code compacts context (manual or automatic).
# It provides a safety net by backing up the transcript.
#
# Note: This hook's output goes to stderr (not added as context).
# It receives JSON input on stdin with transcript_path and trigger info.
#
# Usage: Automatically triggered by Claude Code PreCompact hook

set -e

# Get project directory
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
TIMESTAMP=$(date +%Y-%m-%d_%H%M%S)
DATE=$(date +%Y-%m-%d)
LOGS_DIR="$PROJECT_DIR/docs/logs"

# Create logs directory if needed
mkdir -p "$LOGS_DIR"

# Read input JSON from stdin
INPUT=$(cat)

# Extract transcript path and trigger
# Handle case where jq is not installed (fallback to grep)
if command -v jq &> /dev/null; then
    TRANSCRIPT=$(echo "$INPUT" | jq -r '.transcript_path // empty')
    TRIGGER=$(echo "$INPUT" | jq -r '.trigger // "unknown"')
else
    # Fallback: basic grep parsing (less reliable but works without jq)
    TRANSCRIPT=$(echo "$INPUT" | grep -o '"transcript_path"[[:space:]]*:[[:space:]]*"[^"]*"' | cut -d'"' -f4 || true)
    TRIGGER=$(echo "$INPUT" | grep -o '"trigger"[[:space:]]*:[[:space:]]*"[^"]*"' | cut -d'"' -f4 || echo "unknown")
fi

# Log the compaction event
echo "[$TIMESTAMP] PreCompact triggered (trigger: $TRIGGER)" >> "$LOGS_DIR/compaction.log"

# Backup transcript if it exists and is readable
if [ -n "$TRANSCRIPT" ] && [ -f "$TRANSCRIPT" ]; then
    BACKUP_FILE="$LOGS_DIR/transcript_backup_$TIMESTAMP.jsonl"

    if cp "$TRANSCRIPT" "$BACKUP_FILE" 2>/dev/null; then
        echo "Transcript backed up to: $BACKUP_FILE" >&2
        echo "[$TIMESTAMP] Transcript backed up: $BACKUP_FILE" >> "$LOGS_DIR/compaction.log"

        # Keep only last 10 backups to prevent disk bloat
        BACKUP_COUNT=$(ls -1 "$LOGS_DIR"/transcript_backup_*.jsonl 2>/dev/null | wc -l | tr -d ' ')
        if [ "$BACKUP_COUNT" -gt 10 ]; then
            # Remove oldest backups (keep 10 most recent)
            ls -1t "$LOGS_DIR"/transcript_backup_*.jsonl | tail -n +11 | xargs rm -f 2>/dev/null || true
            echo "[$TIMESTAMP] Cleaned old backups (kept 10 most recent)" >> "$LOGS_DIR/compaction.log"
        fi
    else
        echo "Warning: Could not backup transcript" >&2
    fi
else
    echo "[$TIMESTAMP] No transcript to backup" >> "$LOGS_DIR/compaction.log"
fi

# Reminder message (goes to stderr, visible in verbose mode)
echo "" >&2
echo "PreCompact hook executed." >&2
echo "Reminder: Ensure state is saved in docs/ before compaction." >&2
echo "Use /save-state if you haven't already." >&2

exit 0
