#!/bin/bash
# install.sh - Install make_claude_better to any project
#
# Usage: ./install.sh [target_directory]
#
# This script copies the context management system to another project,
# enabling automatic context restoration via Claude Code hooks.

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get script location and target
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET_DIR="${1:-.}"

# Validate target
if [ ! -d "$TARGET_DIR" ]; then
    echo -e "${RED}Error: Target directory does not exist: $TARGET_DIR${NC}"
    exit 1
fi

TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

echo ""
echo -e "${BLUE}========================================"
echo "  make_claude_better Installation"
echo "========================================${NC}"
echo ""
echo "Source: $SCRIPT_DIR"
echo "Target: $TARGET_DIR"
echo ""

# Don't install to self (unless demo mode)
if [ "$SCRIPT_DIR" = "$TARGET_DIR" ]; then
    echo -e "${YELLOW}Note: Installing to source directory (demo mode)${NC}"
    echo ""
fi

# Create directory structure
echo -e "${GREEN}[1/7] Creating directory structure...${NC}"
mkdir -p "$TARGET_DIR/.claude/commands"
mkdir -p "$TARGET_DIR/.claude/hooks"
mkdir -p "$TARGET_DIR/docs/logs"

# Copy slash commands
echo -e "${GREEN}[2/7] Installing slash commands...${NC}"
cp "$SCRIPT_DIR/.claude/commands/"*.md "$TARGET_DIR/.claude/commands/"
echo "  - restore.md"
echo "  - save-state.md"
echo "  - context-status.md"
echo "  - archive-week.md"

# Copy and enable hooks
echo -e "${GREEN}[3/7] Installing automation hooks...${NC}"
cp "$SCRIPT_DIR/.claude/hooks/"*.sh "$TARGET_DIR/.claude/hooks/"
chmod +x "$TARGET_DIR/.claude/hooks/"*.sh
echo "  - session-start.sh (auto-restore on session start)"
echo "  - pre-compact.sh (auto-backup before compaction)"
echo "  - estimate-tokens.sh (real token usage monitoring)"

# Copy/merge settings
echo -e "${GREEN}[4/7] Configuring Claude Code settings...${NC}"
if [ -f "$TARGET_DIR/.claude/settings.json" ]; then
    echo -e "${YELLOW}  Existing settings.json found${NC}"
    echo "  Creating settings.json.new - please merge manually"
    cp "$SCRIPT_DIR/.claude/settings.json" "$TARGET_DIR/.claude/settings.json.new"
    echo ""
    echo -e "${YELLOW}  Add these hooks to your existing settings.json:${NC}"
    echo '  "hooks": {'
    echo '    "SessionStart": [{"matcher": "", "hooks": [{"type": "command", "command": "./.claude/hooks/session-start.sh", "timeout": 15000}]}],'
    echo '    "PreCompact": [{"matcher": "", "hooks": [{"type": "command", "command": "./.claude/hooks/pre-compact.sh", "timeout": 10000}]}]'
    echo '  }'
else
    cp "$SCRIPT_DIR/.claude/settings.json" "$TARGET_DIR/.claude/settings.json"
    echo "  - Created settings.json with hook configuration"
fi

# Initialize state files from templates (don't overwrite existing)
echo -e "${GREEN}[5/7] Initializing state files...${NC}"
DATE=$(date +%Y-%m-%d)

# Implementation tracker (replaces old current_state.md)
if [ ! -f "$TARGET_DIR/docs/implementation_tracker.md" ]; then
    if [ -f "$SCRIPT_DIR/templates/implementation_tracker.template.md" ]; then
        cp "$SCRIPT_DIR/templates/implementation_tracker.template.md" "$TARGET_DIR/docs/implementation_tracker.md"
        # Replace placeholder dates (works on both macOS and Linux)
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s/YYYY-MM-DD/$DATE/g" "$TARGET_DIR/docs/implementation_tracker.md"
        else
            sed -i "s/YYYY-MM-DD/$DATE/g" "$TARGET_DIR/docs/implementation_tracker.md"
        fi
        echo "  - Created docs/implementation_tracker.md (customize this!)"
    fi
else
    echo -e "${YELLOW}  docs/implementation_tracker.md already exists - skipping${NC}"
fi

# Implementation archive
if [ ! -f "$TARGET_DIR/docs/implementation_archive.md" ]; then
    if [ -f "$SCRIPT_DIR/templates/implementation_archive.template.md" ]; then
        cp "$SCRIPT_DIR/templates/implementation_archive.template.md" "$TARGET_DIR/docs/implementation_archive.md"
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s/YYYY-MM-DD/$DATE/g" "$TARGET_DIR/docs/implementation_archive.md"
        else
            sed -i "s/YYYY-MM-DD/$DATE/g" "$TARGET_DIR/docs/implementation_archive.md"
        fi
        echo "  - Created docs/implementation_archive.md"
    fi
else
    echo -e "${YELLOW}  docs/implementation_archive.md already exists - skipping${NC}"
fi

# Development guide
if [ ! -f "$TARGET_DIR/docs/development_guide.md" ]; then
    if [ -f "$SCRIPT_DIR/templates/development_guide.template.md" ]; then
        cp "$SCRIPT_DIR/templates/development_guide.template.md" "$TARGET_DIR/docs/development_guide.md"
        echo "  - Created docs/development_guide.md (customize this!)"
    fi
else
    echo -e "${YELLOW}  docs/development_guide.md already exists - skipping${NC}"
fi

# Create logs placeholder
touch "$TARGET_DIR/docs/logs/.gitkeep"
echo "  - Created docs/logs/ directory"

# Append rules to CLAUDE.md
echo -e "${GREEN}[6/7] Updating CLAUDE.md with automation rules...${NC}"
if [ -f "$TARGET_DIR/CLAUDE.md" ]; then
    if [ -f "$SCRIPT_DIR/templates/claude_rules.md" ]; then
        # Check if rules already appended (avoid duplicates)
        if grep -q "# Automated Context Management System" "$TARGET_DIR/CLAUDE.md"; then
            echo -e "${YELLOW}  Automation rules already present in CLAUDE.md - skipping${NC}"
        else
            cat "$SCRIPT_DIR/templates/claude_rules.md" >> "$TARGET_DIR/CLAUDE.md"
            echo "  - Appended automation rules to existing CLAUDE.md"
        fi
    fi
else
    echo -e "${YELLOW}  No CLAUDE.md found - skipping rules append${NC}"
    echo "  - Create a CLAUDE.md and run install again, or manually add rules"
fi

# Verify installation
echo -e "${GREEN}[7/7] Verifying installation...${NC}"
ERRORS=0

if [ ! -x "$TARGET_DIR/.claude/hooks/session-start.sh" ]; then
    echo -e "${RED}  ERROR: session-start.sh not executable${NC}"
    ERRORS=$((ERRORS + 1))
fi

if [ ! -x "$TARGET_DIR/.claude/hooks/pre-compact.sh" ]; then
    echo -e "${RED}  ERROR: pre-compact.sh not executable${NC}"
    ERRORS=$((ERRORS + 1))
fi

if [ ! -x "$TARGET_DIR/.claude/hooks/estimate-tokens.sh" ]; then
    echo -e "${RED}  ERROR: estimate-tokens.sh not executable${NC}"
    ERRORS=$((ERRORS + 1))
fi

if [ ! -f "$TARGET_DIR/.claude/settings.json" ] && [ ! -f "$TARGET_DIR/.claude/settings.json.new" ]; then
    echo -e "${RED}  ERROR: settings.json not created${NC}"
    ERRORS=$((ERRORS + 1))
fi

if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}  All checks passed!${NC}"
fi

# Final instructions
echo ""
echo -e "${BLUE}========================================"
echo -e "${GREEN}  Installation Complete!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "What was installed:"
echo "  - Automation hooks (session-start, pre-compact, estimate-tokens)"
echo "  - Slash commands (/restore, /save-state, /context-status, /archive-week)"
echo "  - State file templates (implementation_tracker, archive, development_guide)"
if [ -f "$TARGET_DIR/CLAUDE.md" ]; then
    echo "  - Automation rules appended to CLAUDE.md"
fi
echo ""
echo -e "${YELLOW}File Size Limits (IMPORTANT):${NC}"
echo ""
echo "  These files are auto-loaded on session start. Keep them slim!"
echo ""
echo "  | File                        | Max Lines | Max Tokens |"
echo "  |-----------------------------|-----------|------------|"
echo "  | implementation_tracker.md   | 100 lines | ~3K tokens |"
echo "  | development_guide.md        | 200 lines | ~6K tokens |"
echo "  | logs/YYYY-MM-DD.md          | 100 lines | ~3K tokens |"
echo ""
echo "  When files grow too large, extract to:"
echo "  - CHANGELOG.md (version history)"
echo "  - docs/detailed/ (full docs, tutorials)"
echo "  - implementation_archive.md (past weeks)"
echo ""
echo "Next steps:"
echo ""
echo "  1. ${YELLOW}Customize your state files:${NC}"
echo "     - Edit docs/implementation_tracker.md with your project info"
echo "     - Edit docs/development_guide.md with your architecture (keep <200 lines!)"
echo ""
if [ -f "$TARGET_DIR/.claude/settings.json.new" ]; then
    echo "  2. ${YELLOW}Merge settings.json:${NC}"
    echo "     - Merge .claude/settings.json.new into your existing settings.json"
    echo ""
fi
echo "  3. ${YELLOW}Test the system:${NC}"
echo "     - Start Claude Code in this project"
echo "     - Context should auto-restore from docs/"
echo "     - Use /save-state before ending sessions"
echo ""
echo "Verify hooks work:"
echo "  CLAUDE_PROJECT_DIR=$TARGET_DIR $TARGET_DIR/.claude/hooks/session-start.sh"
echo ""
echo -e "${GREEN}Happy coding!${NC}"
echo ""
