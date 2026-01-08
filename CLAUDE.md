# Make Claude Better - Context Management

A simple context management system for Claude Code using 3 slash commands.

## Slash Commands

| Command | Purpose |
|---------|---------|
| `/restore` | Load context from docs/ into the conversation |
| `/save-state` | Save current progress to docs/ |
| `/context-status` | Check current token usage |

---

## The 3-File System

| File | Purpose |
|------|---------|
| `docs/implementation_tracker.md` | Strategic: roadmap, progress, blockers |
| `docs/development_guide.md` | Architectural: how the project works |
| `docs/logs/YYYY-MM-DD.md` | Tactical: daily work, where you left off |

---

## Usage

### Starting a Session
Run `/restore` to load your project context.

### During Work
Work normally. Run `/context-status` periodically to check token usage.

### Ending a Session
Run `/save-state` to save progress before closing.

### If Context Gets High (85%+)
Run `/save-state` then `/compact` to safely reduce context.

---

## Installation

```bash
./install.sh /path/to/your/project
```

This copies:
- `.claude/commands/` (3 slash commands)
- `.claude/settings.json` (permissions)
- `docs/` templates
- Appends rules to your CLAUDE.md

---

## What's Included

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
