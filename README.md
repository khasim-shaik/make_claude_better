# Make Claude Better

An automated context management system for Claude Code that prevents context loss and eliminates the "morning reload" problem.

## The Problem

Every time you start Claude Code:
- Claude has no idea what you were working on
- You spend 30 minutes re-explaining context
- Large features become impossible across sessions
- Native auto-compact loses important details

## The Solution

**Automatic context restoration via Claude Code hooks.**

When you start Claude Code, it automatically knows:
- What the project is about (architecture, tech stack)
- Where you are in the roadmap (current week, progress)
- Exactly where you left off (file, line, approach)

**Before:** "So yesterday I was working on..." *(30 min explaining)*

**After:** "Context restored. Ready to continue?" *(30 seconds)*

---

## Installation

### For New Projects

```bash
# Clone this repo
git clone https://github.com/khasim-shaik/make_claude_better.git

# Install to your project
./make_claude_better/install.sh /path/to/your/project
```

### For Existing Projects (with CLAUDE.md)

```bash
# Same command - it will:
# - Append automation rules to your existing CLAUDE.md
# - Skip files that already exist
# - Create settings.json.new if you have existing settings

./install.sh /path/to/your/project
```

### What Gets Installed

```
your-project/
├── .claude/
│   ├── commands/           # Slash commands
│   │   ├── restore.md
│   │   ├── save-state.md
│   │   ├── context-status.md
│   │   └── archive-week.md
│   ├── hooks/              # Automation (the magic)
│   │   ├── session-start.sh
│   │   ├── pre-compact.sh
│   │   └── estimate-tokens.sh
│   └── settings.json       # Hook configuration
├── docs/
│   ├── implementation_tracker.md   # Strategic (roadmap, progress)
│   ├── implementation_archive.md   # Historical (past weeks)
│   ├── development_guide.md        # Architectural (how it works)
│   └── logs/
│       └── YYYY-MM-DD.md           # Tactical (daily work)
└── CLAUDE.md               # Automation rules (appended)
```

---

## Daily Usage

### Starting a Session

Just open Claude Code. That's it.

The SessionStart hook automatically:
1. Reads your implementation tracker (where the project is)
2. Reads the development guide (how it works)
3. Reads the most recent daily log (where you left off)
4. Shows git status and context usage

**You don't need to do anything** - context is restored automatically.

### During Work

Work normally. Claude follows the rules in CLAUDE.md to:
- Log completed tasks with timestamps
- Track current work (file, line, approach)
- Monitor context usage

### Ending a Session

Run `/save-state` before closing Claude Code.

This saves your current progress to the docs, so next session starts right where you left off.

### If Context Gets High (85%+)

Claude will auto-save state before compacting. You can also:
1. Run `/save-state` manually
2. Use `/compact` to trigger compaction
3. Continue working - state is preserved

---

## Slash Commands

| Command | What it does |
|---------|--------------|
| `/restore` | Re-read all docs (after manual edits) |
| `/save-state` | Save current progress to docs |
| `/context-status` | Check token usage (~X% of 200K) |
| `/archive-week` | Move completed weeks to archive |

---

## The 3-File System

| File | Purpose | Auto-Loaded |
|------|---------|-------------|
| `implementation_tracker.md` | Strategic: roadmap, current week, blockers | Yes |
| `development_guide.md` | Architectural: how the project works | Yes |
| `logs/YYYY-MM-DD.md` | Tactical: today's work, where you left off | Yes (most recent) |
| `implementation_archive.md` | Historical: past weeks, all decisions | No |

**Token budget:** ~5-6K tokens on session start, leaving 194K+ for work.

---

## Customizing for Your Project

After installation, edit these files:

### `docs/implementation_tracker.md`
- Add your project name
- Set current week and roadmap
- Update completed/in-progress items

### `docs/development_guide.md`
- Describe your architecture
- List your tech stack
- Document coding conventions

### `docs/logs/YYYY-MM-DD.md`
- Created automatically when you run `/save-state`
- Tracks daily work with timestamps

---

## How the Hooks Work

### SessionStart (Auto-Restore)

When Claude Code starts:
1. Hook fires automatically
2. `session-start.sh` reads your docs
3. Output becomes Claude's initial context
4. Claude knows everything instantly

### PreCompact (Safety Net)

Before context compacts:
1. Hook fires automatically
2. `pre-compact.sh` backs up the transcript
3. Logs the compaction event

### Token Estimation

Real-time token monitoring:
```bash
./.claude/hooks/estimate-tokens.sh
# Output: ✅ Context: 54.3K / 200K tokens (~27%) - Status: good
```

---

## Troubleshooting

### Hook not running?

```bash
# Check hook is executable
chmod +x .claude/hooks/*.sh

# Test manually
CLAUDE_PROJECT_DIR=$(pwd) ./.claude/hooks/session-start.sh
```

### Context not restored?

1. Check `docs/implementation_tracker.md` exists
2. Verify `.claude/settings.json` is valid JSON
3. Run hook manually to see output

### Need to merge settings?

If you had existing settings, the installer created `.claude/settings.json.new`. Add this to your existing settings:

```json
"hooks": {
  "SessionStart": [{"matcher": "", "hooks": [{"type": "command", "command": "./.claude/hooks/session-start.sh", "timeout": 15000}]}],
  "PreCompact": [{"matcher": "", "hooks": [{"type": "command", "command": "./.claude/hooks/pre-compact.sh", "timeout": 10000}]}]
}
```

---

## Why This Works

| Metric | Native Auto-Compact | This System |
|--------|---------------------|-------------|
| Tokens to restore | 25-40K (lossy) | 5-6K (lossless) |
| Morning reload time | 30 minutes | 30 seconds |
| Large features | Difficult | Easy |
| User intervention | Required | None |

---

## License

MIT - Use freely in your projects.

---

**Built to make Claude Code sessions productive from the first message.**
