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
echo -e "${GREEN}[1/6] Creating directory structure...${NC}"
mkdir -p "$TARGET_DIR/.claude/commands"
mkdir -p "$TARGET_DIR/.claude/hooks"
mkdir -p "$TARGET_DIR/docs/logs"

# Copy slash commands
echo -e "${GREEN}[2/6] Installing slash commands...${NC}"
cp "$SCRIPT_DIR/.claude/commands/"*.md "$TARGET_DIR/.claude/commands/"
echo "  - restore.md"
echo "  - save-state.md"
echo "  - context-status.md"

# Copy and enable hooks
echo -e "${GREEN}[3/6] Installing automation hooks...${NC}"
cp "$SCRIPT_DIR/.claude/hooks/"*.sh "$TARGET_DIR/.claude/hooks/"
chmod +x "$TARGET_DIR/.claude/hooks/"*.sh
echo "  - session-start.sh (auto-restore on session start)"
echo "  - pre-compact.sh (auto-backup before compaction)"

# Copy/merge settings
echo -e "${GREEN}[4/6] Configuring Claude Code settings...${NC}"
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
echo -e "${GREEN}[5/6] Initializing state files...${NC}"
DATE=$(date +%Y-%m-%d)

if [ ! -f "$TARGET_DIR/docs/current_state.md" ]; then
    if [ -f "$SCRIPT_DIR/templates/current_state.template.md" ]; then
        cp "$SCRIPT_DIR/templates/current_state.template.md" "$TARGET_DIR/docs/current_state.md"
        # Replace placeholder dates (works on both macOS and Linux)
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s/YYYY-MM-DD/$DATE/g" "$TARGET_DIR/docs/current_state.md"
        else
            sed -i "s/YYYY-MM-DD/$DATE/g" "$TARGET_DIR/docs/current_state.md"
        fi
        echo "  - Created docs/current_state.md (customize this!)"
    fi
else
    echo -e "${YELLOW}  docs/current_state.md already exists - skipping${NC}"
fi

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

# Verify installation
echo -e "${GREEN}[6/6] Verifying installation...${NC}"
ERRORS=0

if [ ! -x "$TARGET_DIR/.claude/hooks/session-start.sh" ]; then
    echo -e "${RED}  ERROR: session-start.sh not executable${NC}"
    ERRORS=$((ERRORS + 1))
fi

if [ ! -x "$TARGET_DIR/.claude/hooks/pre-compact.sh" ]; then
    echo -e "${RED}  ERROR: pre-compact.sh not executable${NC}"
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
echo "  - Automation hooks (session-start.sh, pre-compact.sh)"
echo "  - Slash commands (/restore, /save-state, /context-status)"
echo "  - State file templates (docs/current_state.md, development_guide.md)"
echo ""
echo "Next steps:"
echo ""
echo "  1. ${YELLOW}Customize your state files:${NC}"
echo "     - Edit docs/current_state.md with your project info"
echo "     - Edit docs/development_guide.md with your architecture"
echo ""
echo "  2. ${YELLOW}Add automation rules to your CLAUDE.md:${NC}"
echo "     - Copy the rules from $SCRIPT_DIR/CLAUDE.md"
echo "     - Or add these minimal rules:"
echo ""
echo '     # Auto-Save at 85% Context'
echo '     When context reaches 85%+, update docs/current_state.md'
echo '     and docs/logs/YYYY-MM-DD.md before compacting.'
echo ""
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
