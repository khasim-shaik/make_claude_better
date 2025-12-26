# Make Claude Better

An automated context management system for Claude Code that **eliminates the 30-minute morning context reload problem**.

## The Problem

Every morning you start Claude Code:
- Claude has no idea what you were working on yesterday
- You spend 30 minutes explaining context, decisions, and progress
- Large features become impossible to build across sessions
- Native auto-compact at ~90% loses important details

## The Solution

This system uses **Claude Code hooks** for TRUE automation:

| Hook | When It Fires | What It Does |
|------|---------------|--------------|
| `SessionStart` | Session begins/resumes | Auto-reads docs/ and injects as context |
| `PreCompact` | Before compaction | Auto-backs up transcript |

**Key Innovation**: SessionStart hook outputs stdout as Claude context. When you start Claude Code, it automatically reads your state files and knows exactly where you left off.

### Before vs After

**Before (30 minutes):**
```
Developer: *opens Claude Code*
Claude: "Hello! How can I help?"
Developer: "So yesterday I was working on the auth system..."
         *explains for 30 minutes*
```

**After (30 seconds):**
```
Developer: *opens Claude Code*
Claude: "Context restored. You were implementing the refresh token
        endpoint in src/routes/auth.ts:140. The Redis blacklist
        logic is next. Ready to continue?"
Developer: "Let's continue."
```

## Installation

### One-Command Install (Recommended)

```bash
./install.sh /path/to/your/project
```

### Manual Install

```bash
# 1. Copy commands and hooks
mkdir -p .claude/commands .claude/hooks
cp /path/to/make_claude_better/.claude/commands/*.md .claude/commands/
cp /path/to/make_claude_better/.claude/hooks/*.sh .claude/hooks/
chmod +x .claude/hooks/*.sh

# 2. Copy settings
cp /path/to/make_claude_better/.claude/settings.json .claude/

# 3. Create state files
mkdir -p docs/logs
cp /path/to/make_claude_better/templates/current_state.template.md docs/current_state.md
cp /path/to/make_claude_better/templates/development_guide.template.md docs/development_guide.md

# 4. Add automation rules to your CLAUDE.md
```

## Usage

### Starting a Session (AUTOMATIC)

Just start Claude Code. The SessionStart hook automatically:
1. Reads `docs/current_state.md`
2. Reads today's log (if exists)
3. Shows git status
4. Injects all this as Claude's initial context

**You don't need to do anything** - context is restored automatically!

### During Development

Work normally. Follow CLAUDE.md rules to:
- Update `docs/current_state.md` when completing tasks
- Run `/save-state` before ending your session
- Save state when context reaches ~85%

### Manual Commands (Override)

| Command | Purpose |
|---------|---------|
| `/restore` | Force re-read docs/ (after manual edits) |
| `/save-state` | Save current state to docs/ |
| `/context-status` | Check estimated context usage |

## How the Hooks Work

### SessionStart Hook (Auto-Restore)

When Claude Code starts:
1. Hook fires automatically
2. `.claude/hooks/session-start.sh` executes
3. Script reads state files and outputs markdown
4. **Output becomes Claude's initial context**
5. Claude immediately knows where you left off

### PreCompact Hook (Safety Net)

When context is about to compact:
1. Hook fires automatically
2. `.claude/hooks/pre-compact.sh` executes
3. Script backs up transcript to `docs/logs/`
4. Logs the compaction event

This provides a safety net in case you forgot to save state.

## File Structure

After setup, your project will have:

```
your-project/
├── .claude/
│   ├── commands/              # Slash commands (manual override)
│   │   ├── restore.md
│   │   ├── save-state.md
│   │   └── context-status.md
│   ├── hooks/                 # TRUE AUTOMATION
│   │   ├── session-start.sh   # Auto-restore on session start
│   │   └── pre-compact.sh     # Auto-backup before compaction
│   ├── settings.json          # Hook configuration
│   └── session_state.md       # Immediate context cache
├── docs/
│   ├── current_state.md       # Project state (tactical + strategic)
│   ├── development_guide.md   # Architecture reference
│   └── logs/
│       └── YYYY-MM-DD.md      # Daily session logs
└── CLAUDE.md                  # Automation rules
```

## Documentation Files

### `docs/current_state.md`

The "source of truth" for project state:
- **Tactical**: What you're working on RIGHT NOW (file, line, thought)
- **Strategic**: Current phase, active tasks, recent completions
- **Decisions**: Key decisions with rationale
- **Next steps**: Prioritized task list

### `docs/logs/YYYY-MM-DD.md`

Daily session log with:
- Completed tasks with timestamps
- Code changes with file paths
- Decisions made
- Current task status

### `docs/development_guide.md`

Project architecture reference:
- Tech stack
- Coding conventions
- Common patterns
- Troubleshooting

### `.claude/session_state.md`

Immediate context cache (auto-updated):
- Current file/lines being edited
- In-progress thoughts
- Recent context (last 30 min)
- Next immediate action

## Efficiency Comparison

| Metric | Native Auto-Compact | This System |
|--------|---------------------|-------------|
| Tokens to restore | 25-40K | 5-7K |
| Context quality | Lossy | Lossless |
| User intervention | Required | None |
| Large features | Difficult | Easy |

## Best Practices

### Do
- Let the system auto-save (don't fight it)
- Use `/restore` at session start
- Keep `current_state.md` tactical at top, strategic below
- Write concise but complete log entries

### Don't
- Re-read the same large files repeatedly
- Deep-read docs when skimming suffices
- Fight the auto-compact (it's lossless now)
- Forget to update docs when architecture changes

## Troubleshooting

### "Hook not running"
- Check `.claude/settings.json` is valid JSON
- Verify hook file is executable: `chmod +x .claude/hooks/*.sh`
- Test manually: `CLAUDE_PROJECT_DIR=. ./.claude/hooks/session-start.sh`

### "Context not restored on session start"
- Ensure `docs/current_state.md` exists and has content
- Check hook outputs to stdout (not stderr)
- Verify hook path in settings.json is correct

### "Context restored but missing details"
- Check if `docs/logs/YYYY-MM-DD.md` exists for today
- Run `/save-state` more frequently if needed
- Ensure you're updating current_state.md before ending sessions

### "Files not found during restore"
- Ensure `docs/` structure exists
- Check file paths match your project layout
- Create missing files from templates

### Testing Hooks Manually

```bash
# Test session-start.sh
CLAUDE_PROJECT_DIR=/path/to/project ./.claude/hooks/session-start.sh

# Test pre-compact.sh
echo '{"transcript_path":"/tmp/test.jsonl","trigger":"manual"}' | \
  CLAUDE_PROJECT_DIR=/path/to/project ./.claude/hooks/pre-compact.sh
```

## Contributing

Found ways to improve the system? Contributions welcome:
1. Fork the repo
2. Make your changes
3. Submit a PR with clear description

## License

MIT - Use freely in your projects.

---

**Built to make Claude Code sessions more productive by eliminating context loss.**
