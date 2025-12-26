#!/bin/bash
# session-start.sh - Auto-restore context on session start
#
# This script's stdout is automatically added as context to Claude.
# It runs on: session start, resume, and after compaction.
#
# Usage: Automatically triggered by Claude Code SessionStart hook

set -e

# Get project directory (from env or current directory)
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
DATE=$(date +%Y-%m-%d)

# Limit output to prevent context bloat (hook has 15s timeout)
# Note: With slim tracker + archive strategy, files are small by design
MAX_STATE_LINES=100
MAX_LOG_LINES=100
MAX_GIT_LINES=20

echo "## Context Auto-Restored"
echo ""
echo "**Project**: $(basename "$PROJECT_DIR")"
echo "**Date**: $DATE"
echo ""

# 1. Read implementation tracker (strategic context for leadership)
if [ -f "$PROJECT_DIR/docs/implementation_tracker.md" ]; then
    echo "---"
    echo ""
    echo "### Implementation Tracker"
    echo ""
    head -n $MAX_STATE_LINES "$PROJECT_DIR/docs/implementation_tracker.md"

    # Check if file was truncated
    TOTAL_LINES=$(wc -l < "$PROJECT_DIR/docs/implementation_tracker.md" | tr -d ' ')
    if [ "$TOTAL_LINES" -gt "$MAX_STATE_LINES" ]; then
        echo ""
        echo "*[Truncated - full tracker in docs/implementation_tracker.md]*"
    fi
    echo ""
else
    echo "**Warning**: docs/implementation_tracker.md not found. Run /save-state to create it."
    echo ""
fi

# 2. Read most recent daily log (handles work gaps - e.g., last worked Nov 29, returning Dec 26)
LOGS_DIR="$PROJECT_DIR/docs/logs"
if [ -d "$LOGS_DIR" ]; then
    # Find most recent .md file (excluding archive directory)
    RECENT_LOG=$(find "$LOGS_DIR" -maxdepth 1 -name "*.md" -type f 2>/dev/null | sort -r | head -1)

    if [ -n "$RECENT_LOG" ] && [ -f "$RECENT_LOG" ]; then
        LOG_DATE=$(basename "$RECENT_LOG" .md)
        echo "---"
        echo ""
        if [ "$LOG_DATE" = "$DATE" ]; then
            echo "### Today's Activity"
        else
            echo "### Last Session ($LOG_DATE)"
        fi
        echo ""
        head -n $MAX_LOG_LINES "$RECENT_LOG"
        echo ""
    fi
fi

# 3. Quick git status for code state awareness
echo "---"
echo ""
echo "### Git Status"
echo ""
if cd "$PROJECT_DIR" && git rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH=$(git branch --show-current 2>/dev/null || echo 'detached')
    echo "**Branch**: $BRANCH"
    echo ""

    # Show uncommitted changes
    CHANGES=$(git status --short 2>/dev/null | head -$MAX_GIT_LINES)
    if [ -n "$CHANGES" ]; then
        echo "**Uncommitted Changes**:"
        echo '```'
        echo "$CHANGES"
        echo '```'

        TOTAL_CHANGES=$(git status --short 2>/dev/null | wc -l | tr -d ' ')
        if [ "$TOTAL_CHANGES" -gt "$MAX_GIT_LINES" ]; then
            echo "*... and $((TOTAL_CHANGES - MAX_GIT_LINES)) more files*"
        fi
    else
        echo "Working tree clean."
    fi

    # Show recent commits (last 3)
    echo ""
    echo "**Recent Commits**:"
    echo '```'
    git log --oneline -3 2>/dev/null || echo "No commits yet"
    echo '```'
else
    echo "Not a git repository."
fi

echo ""
echo "---"
echo ""

# 4. Show current context usage (if we can get it)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -x "$SCRIPT_DIR/estimate-tokens.sh" ]; then
    CONTEXT_STATUS=$("$SCRIPT_DIR/estimate-tokens.sh" 2>/dev/null || echo "")
    if [ -n "$CONTEXT_STATUS" ]; then
        echo "### Context Status"
        echo ""
        echo "$CONTEXT_STATUS"
        echo ""
        echo "---"
        echo ""
    fi
fi

echo "**Context auto-restored from docs/.** Ready to continue where you left off."
echo ""
echo "*Tip: Use /save-state before ending your session to preserve context.*"

exit 0
