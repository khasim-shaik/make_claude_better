# Make Claude Better - Automated Context Management

This repository contains an automated context management system for Claude Code that prevents context loss and enables building large features within single sessions.

## Quick Start

**One-command installation:**
```bash
./install.sh /path/to/your/project
```

**Or manual setup:**
1. Copy `.claude/commands/` and `.claude/hooks/` to your project
2. Copy `.claude/settings.json` to configure hooks
3. Create `docs/current_state.md` from template
4. Add the automation rules below to your project's `CLAUDE.md`

---

## How Automation Works (Hooks)

This system uses Claude Code's **hooks** for TRUE automation:

| Hook | Event | Action |
|------|-------|--------|
| `SessionStart` | Session begins/resumes | Auto-reads docs/ and injects as context |
| `PreCompact` | Before compaction | Auto-backs up transcript |

**SessionStart** is the key innovation - when you start Claude Code, the hook automatically reads your state files and adds them as context. No manual `/restore` needed!

### Real Token Monitoring

The system includes `estimate-tokens.sh` which reads **actual token usage** from Claude's transcript:

```bash
./.claude/hooks/estimate-tokens.sh
# Output: ✅ Context: 54.3K / 200K tokens (~27%) - Status: good

./.claude/hooks/estimate-tokens.sh --json
# Output: {"current_context": 54364, "percentage": 27, "status": "good", ...}
```

This extracts real token counts from Claude's API responses - not rough estimates!

### What Happens When You Start Claude Code

1. SessionStart hook fires automatically
2. `.claude/hooks/session-start.sh` executes
3. Script reads `docs/current_state.md`, today's log, git status
4. Script's stdout becomes Claude's initial context
5. Claude immediately knows where you left off
6. You say "let's continue" and you're productive in seconds

**This eliminates the 30-minute morning context reload problem.**

---

## Automation Rules (Copy to Your Project's CLAUDE.md)

```markdown
# Automated Context Management System

## Core Principle: Memory Hierarchy

**Hard Drive** (Persistent Storage - Lossless):
- `docs/development_guide.md` - Architecture, patterns, conventions
- `docs/current_state.md` - Current focus, active tasks, decisions
- `docs/logs/YYYY-MM-DD.md` - Daily session logs with detailed history

**RAM** (Active Context - 200K tokens):
- Claude Code's conversation context window

**Cache** (Quick Access):
- `.claude/session_state.md` - Immediate session context

---

## Context Usage Thresholds

**0-70% (Healthy)**: Continue normal operations

**70-85% (Moderate)**: Alert user, include context estimates periodically

**85%+ (Critical - AUTO-SAVE)**:
1. Alert: "Context at ~X% - Auto-saving state now..."
2. Update `docs/current_state.md`
3. Update `docs/logs/YYYY-MM-DD.md`
4. Update `.claude/session_state.md`
5. Compact to minimal context (~0-2K tokens)
6. Continue working immediately

---

## Auto-Logging After Task Completion

After completing significant tasks, automatically:
1. Move task from "Active" to "Recent Completions" in current_state.md
2. Append entry to docs/logs/YYYY-MM-DD.md
3. Brief confirmation: "Task completed. (Auto-logged)"

---

## Slash Commands

- `/restore` - Restore full context from documentation (~5-7K tokens)
- `/save-state` - Manually save current state
- `/context-status` - Check current context usage

---

## Session Start (AUTOMATIC via Hook)

The SessionStart hook automatically runs `.claude/hooks/session-start.sh` which:
1. Reads `docs/current_state.md`
2. Reads `docs/logs/YYYY-MM-DD.md` for today (if exists)
3. Reads `.claude/session_state.md` (if exists)
4. Shows `git status` and recent commits

**You don't need to run /restore manually** - it happens automatically!

Use `/restore` only if you need to force a re-read after manually editing docs/.

---

## Proactive Context Monitoring

**On session start**: The SessionStart hook shows current context usage automatically.

**Periodic checks**: Run `/context-status` every 20-30 interactions to check real token usage.

**When context >70%**: Claude should proactively check and report:
```
[Response]

(Context: ~X% - run /save-state if needed)
```

**At 85%+**: Claude should auto-save state before native auto-compact triggers.

---

## What's Included

```
make_claude_better/
├── .claude/
│   ├── commands/              # Slash commands (manual override)
│   │   ├── restore.md
│   │   ├── save-state.md
│   │   └── context-status.md
│   ├── hooks/                 # TRUE AUTOMATION
│   │   ├── session-start.sh   # Auto-restore on session start
│   │   ├── pre-compact.sh     # Auto-backup before compaction
│   │   └── estimate-tokens.sh # Real token usage from transcript
│   └── settings.json          # Hook configuration
├── docs/                      # State files (the "hard drive")
│   ├── current_state.md       # Project state (tactical + strategic)
│   ├── development_guide.md   # Architecture reference
│   └── logs/                  # Daily session logs
│       └── YYYY-MM-DD.md
├── templates/                 # Templates for new projects
│   ├── current_state.template.md
│   ├── session_state.template.md
│   ├── daily_log.template.md
│   └── development_guide.template.md
├── install.sh                 # One-command installation
├── CLAUDE.md                  # This file
└── README.md                  # Full documentation
```

---

## How It Works

### The Problem
Claude Code has a ~200K token context window. When it fills up, native auto-compact triggers and **loses important context**.

### The Solution
Save all context to structured files **before** compacting, enabling:
- **Lossless preservation**: Everything saved to docs
- **Aggressive compacting**: Safe because docs have full context
- **Efficient restoration**: ~5-7K tokens vs 25-40K from native compact

### Token Efficiency

| Method | Tokens to Restore | Quality |
|--------|-------------------|---------|
| Native auto-compact | 25-40K | Lossy |
| This system | 5-7K | Lossless |

---

## Success Metrics

The system is working when:
- You never hit native auto-compact (always save at 85% first)
- Sessions can build large features without context loss
- `/restore` brings back full context in ~5-7K tokens
- User never has to re-explain context after restart
