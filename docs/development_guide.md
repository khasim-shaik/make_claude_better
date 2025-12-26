# Development Guide

**Last Updated**: 2025-12-24

## Project Overview

**Name**: make_claude_better
**Type**: Claude Code Automation System
**Purpose**: Eliminate the 30-minute morning context reload problem through true automation

## Architecture

### System Components

```
                    ┌─────────────────────────────────────────┐
                    │         HOOKS (True Automation)         │
                    ├─────────────────────────────────────────┤
                    │ SessionStart  →  Auto-restore context   │
                    │ PreCompact    →  Auto-backup transcript │
                    └─────────────────────────────────────────┘
                                       │
                                       ▼
                    ┌─────────────────────────────────────────┐
                    │        COMMANDS (Manual Override)       │
                    ├─────────────────────────────────────────┤
                    │ /restore       →  Force restore         │
                    │ /save-state    →  Force save to docs/   │
                    │ /context-status→  Check context usage   │
                    └─────────────────────────────────────────┘
                                       │
                                       ▼
                    ┌─────────────────────────────────────────┐
                    │         STATE FILES (Persistence)       │
                    ├─────────────────────────────────────────┤
                    │ docs/current_state.md  →  Project state │
                    │ docs/development_guide.md  →  This file │
                    │ docs/logs/YYYY-MM-DD.md  →  Daily logs  │
                    └─────────────────────────────────────────┘
```

### Directory Structure

```
make_claude_better/
├── .claude/
│   ├── commands/           # Slash commands (prompt injections)
│   │   ├── restore.md
│   │   ├── save-state.md
│   │   └── context-status.md
│   ├── hooks/              # Shell scripts for TRUE automation
│   │   ├── session-start.sh
│   │   └── pre-compact.sh
│   ├── settings.json       # Hook configuration
│   └── settings.local.json # Permission overrides
├── docs/
│   ├── current_state.md    # Primary state file
│   ├── development_guide.md # This file
│   └── logs/               # Daily session logs
│       └── YYYY-MM-DD.md
├── templates/              # Templates for new projects
│   ├── current_state.template.md
│   ├── session_state.template.md
│   ├── daily_log.template.md
│   └── development_guide.template.md
├── install.sh              # One-command installation
├── CLAUDE.md               # Claude's instructions
└── README.md               # User documentation
```

## Tech Stack

- **Hooks**: Bash scripts executed by Claude Code
- **Config**: JSON settings files
- **State**: Markdown documentation files
- **Portability**: Bash install script

## How It Works

### SessionStart Hook (Key Innovation)

When Claude Code starts, resumes, or recovers from compaction:

1. `SessionStart` hook fires
2. `.claude/hooks/session-start.sh` executes
3. Script reads `docs/current_state.md`, today's log, git status
4. **Script's stdout is added as context to Claude**
5. Claude instantly knows where you left off

This is TRUE automation - no manual `/restore` needed.

### PreCompact Hook (Safety Net)

When context is about to be compacted:

1. `PreCompact` hook fires
2. `.claude/hooks/pre-compact.sh` executes
3. Script backs up the transcript to `docs/logs/`
4. Logs the compaction event
5. Output goes to stderr (not added as context)

### Manual Commands (Override)

- `/restore` - Force re-read of docs/ (useful after manual edits)
- `/save-state` - Force save current state (before risky changes)
- `/context-status` - Check estimated context usage

## Coding Conventions

### Shell Scripts

```bash
#!/bin/bash
set -e  # Exit on error

# Use environment variables with defaults
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"

# Limit output to prevent context bloat
head -n 100 file.md

# Handle missing commands gracefully
if command -v jq &> /dev/null; then
    # Use jq
else
    # Fallback to grep
fi
```

### Markdown Files

- Use consistent heading hierarchy (# > ## > ###)
- Include timestamps for updates
- Use tables for structured data
- Keep tactical context at top, strategic below
- Include file paths with line numbers for navigation

### Hook Configuration

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "./.claude/hooks/session-start.sh",
            "timeout": 15000
          }
        ]
      }
    ]
  }
}
```

## Development Workflow

### Testing Hooks

```bash
# Test session-start.sh
CLAUDE_PROJECT_DIR=/path/to/project ./.claude/hooks/session-start.sh

# Test pre-compact.sh with mock input
echo '{"transcript_path":"/tmp/test.jsonl","trigger":"manual"}' | \
CLAUDE_PROJECT_DIR=/path/to/project ./.claude/hooks/pre-compact.sh
```

### Installing to Another Project

```bash
./install.sh /path/to/target/project
```

### Updating State

Claude follows CLAUDE.md rules to update state files:
- At 85%+ context, auto-save to docs/
- After completing tasks, log to daily log
- Before session end, run /save-state

## Troubleshooting

### Hook Not Running

**Issue**: SessionStart hook doesn't execute
**Solution**:
1. Check `.claude/settings.json` is valid JSON
2. Verify hook file is executable: `chmod +x .claude/hooks/*.sh`
3. Check hook path is correct (relative to project root)

### Context Not Restored

**Issue**: Session starts without restored context
**Solution**:
1. Ensure `docs/current_state.md` exists
2. Check hook script outputs to stdout (not stderr)
3. Run hook manually to test: `./.claude/hooks/session-start.sh`

### Hook Timeout

**Issue**: Hook takes too long (>15s default)
**Solution**:
1. Limit file reads with `head -n 100`
2. Avoid slow commands (network calls, large searches)
3. Increase timeout in settings.json if needed

## Resources

- [Claude Code Hooks Documentation](https://docs.anthropic.com/claude-code/hooks)
- [Claude Code Slash Commands](https://docs.anthropic.com/claude-code/slash-commands)

---

**Note**: This guide evolves with the project. Update when architecture changes.
