# Make Claude Better

A simple context management system for Claude Code with 3 slash commands.

## The Problem

- Claude loses context when sessions end or context compacts
- You spend time re-explaining what you were working on
- Large features are hard to build across sessions

## The Solution

Three slash commands to save and restore context:

| Command | What it does |
|---------|--------------|
| `/restore` | Load context from docs/ |
| `/save-state` | Save progress to docs/ |
| `/context-status` | Check token usage |

---

## Installation

```bash
git clone https://github.com/khasim-shaik/make_claude_better.git
./make_claude_better/install.sh /path/to/your/project
```

### What Gets Installed

```
your-project/
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
└── CLAUDE.md  (rules appended)
```

---

## Daily Usage

### Starting a Session
```
/restore
```
Loads your project context (~5K tokens).

### During Work
```
/context-status
```
Check token usage periodically.

### Ending a Session
```
/save-state
```
Saves progress so next session can pick up where you left off.

---

## The 3-File System

| File | Purpose |
|------|---------|
| `implementation_tracker.md` | Roadmap, current progress, blockers |
| `development_guide.md` | Architecture, tech stack, conventions |
| `logs/YYYY-MM-DD.md` | Daily work, where you left off |

**Token budget:** ~5K tokens to restore, leaving 195K for work.

---

## Customizing

After installation, edit:

1. `docs/implementation_tracker.md` - Your project roadmap
2. `docs/development_guide.md` - Your architecture
3. `docs/logs/` - Created when you run `/save-state`

---

## License

MIT
