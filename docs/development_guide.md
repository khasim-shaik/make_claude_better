# Development Guide

**Last Updated**: 2026-01-05

## Project Overview

**Name**: make_claude_better
**Purpose**: Simple context management for Claude Code using slash commands

## How It Works

Three slash commands save and restore context to/from markdown files:

| Command | Action |
|---------|--------|
| `/restore` | Read docs/ and load as context |
| `/save-state` | Write current state to docs/ |
| `/context-status` | Check token usage |

## Directory Structure

```
make_claude_better/
├── .claude/
│   ├── commands/
│   │   ├── restore.md
│   │   ├── save-state.md
│   │   └── context-status.md
│   └── settings.json
├── docs/
│   ├── implementation_tracker.md
│   ├── development_guide.md
│   └── logs/
├── templates/
├── install.sh
├── CLAUDE.md
└── README.md
```

## The 3-File System

| File | Purpose |
|------|---------|
| `implementation_tracker.md` | Project roadmap, progress |
| `development_guide.md` | Architecture, conventions |
| `logs/YYYY-MM-DD.md` | Daily work, where you left off |

## Installation

```bash
./install.sh /path/to/your/project
```

Copies commands, settings, and templates to target project.

## Coding Conventions

### Markdown Files
- Keep implementation_tracker.md under 100 lines
- Keep development_guide.md under 200 lines
- Include timestamps for updates

### Slash Commands
- Commands are markdown files in `.claude/commands/`
- They contain prompts that Claude executes
