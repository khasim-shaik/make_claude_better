# Development Guide

**Last Updated**: 2025-12-26

## Project Overview

**Name**: make_claude_better
**Type**: Claude Code Automation System
**Purpose**: Prevent context loss and enable building large features within single sessions

**Key Insight**: Claude Code's SessionStart hook stdout becomes context automatically. We use this to restore project state on every session start.

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
                    │ /archive-week  →  Archive old weeks     │
                    └─────────────────────────────────────────┘
                                       │
                                       ▼
                    ┌─────────────────────────────────────────┐
                    │         STATE FILES (Persistence)       │
                    ├─────────────────────────────────────────┤
                    │ implementation_tracker.md → Strategic   │
                    │ implementation_archive.md → History     │
                    │ development_guide.md      → This file   │
                    │ logs/YYYY-MM-DD.md        → Daily logs  │
                    └─────────────────────────────────────────┘
```

### The 2-File System (Plus Archive)

| File | Audience | Auto-Loaded | Target Size |
|------|----------|-------------|-------------|
| `implementation_tracker.md` | Leadership | Yes | <100 lines |
| `logs/YYYY-MM-DD.md` | Team Lead | Yes (most recent) | <100 lines |
| `development_guide.md` | Developers | Yes | Stable |
| `implementation_archive.md` | Reference | No | Unlimited |

### Directory Structure

```
make_claude_better/
├── .claude/
│   ├── commands/              # Slash commands
│   │   ├── restore.md
│   │   ├── save-state.md
│   │   ├── context-status.md
│   │   └── archive-week.md
│   ├── hooks/                 # TRUE automation
│   │   ├── session-start.sh   # Auto-restore on start
│   │   ├── pre-compact.sh     # Backup before compact
│   │   └── estimate-tokens.sh # Real token monitoring
│   └── settings.json          # Hook configuration
├── docs/
│   ├── implementation_tracker.md  # Strategic (<100 lines)
│   ├── implementation_archive.md  # Historical (unlimited)
│   ├── development_guide.md       # This file
│   └── logs/
│       ├── YYYY-MM-DD.md          # Most recent (auto-loaded)
│       └── archive/               # Old logs
├── templates/                 # For new projects
├── install.sh                 # One-command install
├── CLAUDE.md                  # Claude's instructions
└── README.md                  # User documentation
```

## Tech Stack

- **Hooks**: Bash scripts executed by Claude Code
- **Config**: JSON settings files
- **State**: Markdown documentation files
- **Token Monitoring**: jq for parsing transcript JSONL

## How It Works

### SessionStart Hook (Key Innovation)

When Claude Code starts, resumes, or recovers from compaction:

1. `SessionStart` hook fires automatically
2. `.claude/hooks/session-start.sh` executes
3. Script reads: implementation_tracker, most recent log, development_guide, git status
4. **Script's stdout is added as context to Claude**
5. Claude instantly knows: project vision, architecture, where you left off

**Token Budget**: ~5-6K tokens on start, leaving 194K+ for work.

### PreCompact Hook (Safety Net)

Before context compaction:
1. Backs up transcript to `docs/logs/`
2. Logs the compaction event
3. Output goes to stderr (not added as context)

### Token Monitoring

`estimate-tokens.sh` reads **real token usage** from Claude's transcript:
```bash
./.claude/hooks/estimate-tokens.sh
# Output: ✅ Context: 54.3K / 200K tokens (~27%) - Status: good
```

## Coding Conventions

### Shell Scripts
- Use `set -e` for exit on error
- Use `${VAR:-default}` for environment variables
- Limit output with `head -n` to prevent context bloat
- Handle missing commands gracefully

### Markdown Files
- Use consistent heading hierarchy
- Include timestamps for updates
- Keep files under 100 lines when auto-loaded
- Archive old content, don't delete

### Hook Configuration
```json
{
  "hooks": {
    "SessionStart": [{
      "matcher": "",
      "hooks": [{
        "type": "command",
        "command": "./.claude/hooks/session-start.sh",
        "timeout": 15000
      }]
    }]
  }
}
```

## Development Workflow

### Testing Hooks
```bash
# Test session-start.sh
CLAUDE_PROJECT_DIR=$(pwd) ./.claude/hooks/session-start.sh

# Test token estimation
./.claude/hooks/estimate-tokens.sh --json
```

### Installing to Another Project
```bash
./install.sh /path/to/target/project
```

## Troubleshooting

### Hook Not Running
1. Check `.claude/settings.json` is valid JSON
2. Verify scripts are executable: `chmod +x .claude/hooks/*.sh`
3. Check path is relative to project root

### Context Not Restored
1. Ensure `docs/implementation_tracker.md` exists
2. Check hook outputs to stdout (not stderr)
3. Run hook manually: `./.claude/hooks/session-start.sh`

### Hook Timeout (>15s)
1. Limit file reads with `head -n 100`
2. Avoid slow commands (network, large searches)
3. Increase timeout in settings.json if needed

---

**Note**: This guide evolves with the project. Update when architecture changes.
