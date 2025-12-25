# Make Claude Better

An automated context management system for Claude Code that prevents context loss and enables building large features within single sessions.

## The Problem

Claude Code has a ~200K token context window. During long development sessions:
- Context fills up with file reads, code generation, and conversation
- Native auto-compact triggers at ~90% and **loses important details**
- You have to re-explain context, losing productivity
- Large features become impossible to build in one session

## The Solution

This system treats Claude Code's context like computer memory:

| Layer | Analogy | Purpose |
|-------|---------|---------|
| `docs/` files | Hard Drive | Persistent, lossless storage |
| Context window | RAM | Active working memory (200K tokens) |
| `session_state.md` | Cache | Quick access to immediate context |

**Key Innovation**: Auto-save at 85% context → compact aggressively → restore losslessly from docs

## Installation

### 1. Copy Commands to Your Project

```bash
# From your project root
mkdir -p .claude/commands
cp /path/to/make_claude_better/.claude/commands/*.md .claude/commands/
```

### 2. Set Up Documentation Structure

```bash
mkdir -p docs/logs

# Copy and customize templates
cp /path/to/make_claude_better/templates/current_state.template.md docs/current_state.md
cp /path/to/make_claude_better/templates/development_guide.template.md docs/development_guide.md
```

### 3. Add Automation Rules to Your CLAUDE.md

Copy the automation rules from `CLAUDE.md` in this repo to your project's `CLAUDE.md`.

## Usage

### Starting a Session

```
/restore
```

This loads context from your docs (~5-7K tokens) and gives you a summary of:
- Current task and progress
- Recent completions
- Key decisions
- Next steps

### During Development

Just work normally. The system:
- **Monitors context** continuously
- **Auto-saves at 85%** without interrupting you
- **Auto-logs completed tasks** to daily logs
- **Reports context status** every 20-30 interactions

### Manual Commands

| Command | Purpose |
|---------|---------|
| `/restore` | Load context from docs |
| `/save-state` | Force save before auto-save |
| `/context-status` | Check current context usage |

## How Auto-Save Works

When context reaches 85%:

1. **Alert**: "Context at ~87% - Auto-saving state now..."
2. **Save**: Updates all three doc files
3. **Compact**: Reduces to ~0-2K tokens
4. **Continue**: Resumes work immediately

You don't have to do anything - it's fully automatic.

## File Structure

After setup, your project will have:

```
your-project/
├── .claude/
│   ├── commands/
│   │   ├── restore.md         # Context restoration
│   │   ├── save-state.md      # State preservation
│   │   └── context-status.md  # Context monitoring
│   └── session_state.md       # Immediate context (auto-generated)
├── docs/
│   ├── development_guide.md   # Architecture & conventions
│   ├── current_state.md       # Current focus & tasks
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

### "Context restored but missing details"
- Check if `docs/logs/YYYY-MM-DD.md` exists for today
- Run `/save-state` more frequently if needed

### "Auto-save didn't trigger"
- Context estimation is approximate
- Use `/context-status` to check manually
- Run `/save-state` if concerned

### "Files not found during restore"
- Ensure `docs/` structure exists
- Check file paths match your project layout
- Create missing files from templates

## Contributing

Found ways to improve the system? Contributions welcome:
1. Fork the repo
2. Make your changes
3. Submit a PR with clear description

## License

MIT - Use freely in your projects.

---

**Built to make Claude Code sessions more productive by eliminating context loss.**
