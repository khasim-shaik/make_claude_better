# Make Claude Better - Automated Context Management

This repository contains an automated context management system for Claude Code that prevents context loss and enables building large features within single sessions.

## Quick Start

1. Copy the `.claude/commands/` folder to your project
2. Copy the `templates/` contents to your `docs/` folder (rename `.template.md` to `.md`)
3. Copy the automation rules below to your project's `CLAUDE.md`

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

## Session Start: Use `/restore`

1. Read `docs/current_state.md`
2. Read `docs/logs/YYYY-MM-DD.md` for today
3. Skim `docs/development_guide.md`
4. Run `git log --oneline -10` and `git status`

---

## Proactive Context Reporting

Every 20-30 interactions (if >50%):
```
[Response]
(Context: ~X% - [Healthy/Monitor/Critical])
```
```

---

## What's Included

```
make_claude_better/
├── .claude/
│   └── commands/
│       ├── restore.md         # Context restoration protocol
│       ├── save-state.md      # State preservation workflow
│       └── context-status.md  # Context monitoring
├── templates/
│   ├── current_state.template.md    # Project state tracker
│   ├── session_state.template.md    # Immediate context cache
│   ├── daily_log.template.md        # Daily session log format
│   └── development_guide.template.md # Architecture documentation
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
