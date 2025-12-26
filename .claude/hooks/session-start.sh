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
MAX_STATE_LINES=100
MAX_LOG_LINES=80
MAX_GIT_LINES=20

echo "## Context Auto-Restored"
echo ""
echo "**Project**: $(basename "$PROJECT_DIR")"
echo "**Date**: $DATE"
echo ""

# 1. Read current state (primary context - tactical + strategic)
if [ -f "$PROJECT_DIR/docs/current_state.md" ]; then
    echo "---"
    echo ""
    echo "### Current State"
    echo ""
    head -n $MAX_STATE_LINES "$PROJECT_DIR/docs/current_state.md"

    # Check if file was truncated
    TOTAL_LINES=$(wc -l < "$PROJECT_DIR/docs/current_state.md" | tr -d ' ')
    if [ "$TOTAL_LINES" -gt "$MAX_STATE_LINES" ]; then
        echo ""
        echo "*[Truncated - full state in docs/current_state.md]*"
    fi
    echo ""
else
    echo "**Warning**: docs/current_state.md not found. Run /save-state to create it."
    echo ""
fi

# 2. Read today's log if it exists
if [ -f "$PROJECT_DIR/docs/logs/$DATE.md" ]; then
    echo "---"
    echo ""
    echo "### Today's Activity"
    echo ""
    head -n $MAX_LOG_LINES "$PROJECT_DIR/docs/logs/$DATE.md"
    echo ""
fi

# 3. Read session state for immediate context (if exists)
if [ -f "$PROJECT_DIR/.claude/session_state.md" ]; then
    echo "---"
    echo ""
    echo "### Immediate Context (Last Session)"
    echo ""
    cat "$PROJECT_DIR/.claude/session_state.md"
    echo ""
fi

# 4. Quick git status for code state awareness
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
echo "**Context auto-restored from docs/.** Ready to continue where you left off."
echo ""
echo "*Tip: Use /save-state before ending your session to preserve context.*"

exit 0
