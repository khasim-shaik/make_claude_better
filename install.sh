#!/bin/bash
# install.sh - Install make_claude_better to any project
#
# Usage: ./install.sh [target_directory]
#
# This script copies the context management system to another project.

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
echo -e "${GREEN}[1/5] Creating directory structure...${NC}"
mkdir -p "$TARGET_DIR/.claude/commands"
mkdir -p "$TARGET_DIR/docs/logs"

# Copy slash commands
echo -e "${GREEN}[2/5] Installing slash commands...${NC}"
cp "$SCRIPT_DIR/.claude/commands/"*.md "$TARGET_DIR/.claude/commands/"
echo "  - restore.md"
echo "  - save-state.md"
echo "  - context-status.md"

# Copy/merge settings
echo -e "${GREEN}[3/5] Configuring Claude Code settings...${NC}"
if [ -f "$TARGET_DIR/.claude/settings.json" ]; then
    echo -e "${YELLOW}  Existing settings.json found - skipping${NC}"
else
    cp "$SCRIPT_DIR/.claude/settings.json" "$TARGET_DIR/.claude/settings.json"
    echo "  - Created settings.json with permissions"
fi

# Initialize state files from templates (don't overwrite existing)
echo -e "${GREEN}[4/5] Initializing state files...${NC}"
DATE=$(date +%Y-%m-%d)

# Implementation tracker
if [ ! -f "$TARGET_DIR/docs/implementation_tracker.md" ]; then
    if [ -f "$SCRIPT_DIR/templates/implementation_tracker.template.md" ]; then
        cp "$SCRIPT_DIR/templates/implementation_tracker.template.md" "$TARGET_DIR/docs/implementation_tracker.md"
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s/YYYY-MM-DD/$DATE/g" "$TARGET_DIR/docs/implementation_tracker.md"
        else
            sed -i "s/YYYY-MM-DD/$DATE/g" "$TARGET_DIR/docs/implementation_tracker.md"
        fi
        echo "  - Created docs/implementation_tracker.md"
    fi
else
    echo -e "${YELLOW}  docs/implementation_tracker.md already exists - skipping${NC}"
fi

# Development guide
if [ ! -f "$TARGET_DIR/docs/development_guide.md" ]; then
    if [ -f "$SCRIPT_DIR/templates/development_guide.template.md" ]; then
        cp "$SCRIPT_DIR/templates/development_guide.template.md" "$TARGET_DIR/docs/development_guide.md"
        echo "  - Created docs/development_guide.md"
    fi
else
    echo -e "${YELLOW}  docs/development_guide.md already exists - skipping${NC}"
fi

# Create logs placeholder
touch "$TARGET_DIR/docs/logs/.gitkeep"
echo "  - Created docs/logs/ directory"

# Append rules to CLAUDE.md
echo -e "${GREEN}[5/5] Updating CLAUDE.md...${NC}"
if [ -f "$TARGET_DIR/CLAUDE.md" ]; then
    if [ -f "$SCRIPT_DIR/templates/claude_rules.md" ]; then
        if grep -q "# Context Management" "$TARGET_DIR/CLAUDE.md"; then
            echo -e "${YELLOW}  Context rules already present in CLAUDE.md - skipping${NC}"
        else
            cat "$SCRIPT_DIR/templates/claude_rules.md" >> "$TARGET_DIR/CLAUDE.md"
            echo "  - Appended context rules to existing CLAUDE.md"
        fi
    fi
else
    echo -e "${YELLOW}  No CLAUDE.md found - skipping${NC}"
fi

# Final instructions
echo ""
echo -e "${BLUE}========================================"
echo -e "${GREEN}  Installation Complete!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "What was installed:"
echo "  - Slash commands (/restore, /save-state, /context-status)"
echo "  - State file templates"
echo ""
echo "Next steps:"
echo ""
echo "  1. Customize your state files:"
echo "     - Edit docs/implementation_tracker.md"
echo "     - Edit docs/development_guide.md"
echo ""
echo "  2. Use the commands:"
echo "     - /restore     - Load context from docs/"
echo "     - /save-state  - Save progress to docs/"
echo "     - /context-status - Check token usage"
echo ""
echo -e "${GREEN}Happy coding!${NC}"
echo ""
