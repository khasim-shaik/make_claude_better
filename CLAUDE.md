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
3. Create `docs/implementation_tracker.md` from template
4. Add the automation rules below to your project's `CLAUDE.md`

---

## The 2-File System (Plus Archive)

| File | Audience | Auto-Loaded | Target Size |
|------|----------|-------------|-------------|
| `docs/implementation_tracker.md` | Engineering Leadership | Yes | <100 lines |
| `docs/logs/YYYY-MM-DD.md` | Team Lead | Yes (most recent) | <100 lines |
| `docs/implementation_archive.md` | Reference | No | Unlimited |

### Implementation Tracker (Strategic - KEEP SLIM)
- Executive summary (2-3 sentences)
- Weekly roadmap (brief status per week)
- Current week progress (completed/in-progress/blocked)
- Next week preview
- Active blockers only
- Quick links to archive

**Important**: Keep under 100 lines! Use `/archive-week` to move completed weeks to archive.

### Daily Log (Tactical)
- Completed tasks with timestamps
- Current task (file:line, approach, uncommitted changes)
- Decisions made today
- Next steps (immediate resume point)
- Notes (scratchpad, edge cases, links)

### Implementation Archive (Historical - NOT Auto-Loaded)
- Full week-by-week history
- Complete decision log
- Complete bug log
- Technical debt items

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
3. Script reads `docs/implementation_tracker.md`, today's log, git status
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
- `docs/implementation_tracker.md` - Strategic: roadmap, decisions, blockers
- `docs/logs/YYYY-MM-DD.md` - Tactical: daily tasks, session context
- `docs/development_guide.md` - Architecture, patterns, conventions

**RAM** (Active Context - 200K tokens):
- Claude Code's conversation context window

---

## Context Usage Thresholds

**0-70% (Healthy)**: Continue normal operations

**70-85% (Moderate)**: Alert user, include context estimates periodically

**85%+ (Critical - AUTO-SAVE)**:
1. Alert: "Context at ~X% - Auto-saving state now..."
2. Update `docs/implementation_tracker.md` (strategic updates)
3. Update `docs/logs/YYYY-MM-DD.md` (tactical updates)
4. Compact to minimal context (~0-2K tokens)
5. Continue working immediately

---

## Auto-Logging After Task Completion

After completing significant tasks, automatically:
1. Update current week progress in implementation_tracker.md
2. Add entry to docs/logs/YYYY-MM-DD.md with timestamp
3. Brief confirmation: "Task completed. (Auto-logged)"

---

## Slash Commands

- `/restore` - Restore full context from documentation (~3-4K tokens)
- `/save-state` - Manually save current state
- `/context-status` - Check current context usage
- `/archive-week` - Move completed weeks to archive (keeps tracker slim)

---

## Session Start (AUTOMATIC via Hook)

The SessionStart hook automatically runs `.claude/hooks/session-start.sh` which:
1. Reads `docs/implementation_tracker.md` (slim, <100 lines)
2. Reads the **most recent** daily log (handles work gaps gracefully)
3. Shows `git status` and recent commits
4. Shows current context usage

**You don't need to run /restore manually** - it happens automatically!

**Work gaps handled**: If you last worked on Nov 29 and return Dec 26, the Nov 29 log is loaded (most recent), not today's empty log.

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
```

---

## What's Included

```
make_claude_better/
├── .claude/
│   ├── commands/              # Slash commands (manual override)
│   │   ├── restore.md
│   │   ├── save-state.md
│   │   ├── context-status.md
│   │   └── archive-week.md    # Archive completed weeks
│   ├── hooks/                 # TRUE AUTOMATION
│   │   ├── session-start.sh   # Auto-restore on session start
│   │   ├── pre-compact.sh     # Auto-backup before compaction
│   │   └── estimate-tokens.sh # Real token usage from transcript
│   └── settings.json          # Hook configuration
├── docs/                      # State files (the "hard drive")
│   ├── implementation_tracker.md  # Strategic - KEEP SLIM (<100 lines)
│   ├── implementation_archive.md  # Historical - NOT auto-loaded
│   ├── development_guide.md       # Architecture reference
│   └── logs/                      # Daily logs (most recent only)
│       ├── YYYY-MM-DD.md          # Most recent log (auto-loaded)
│       └── archive/               # Old logs (NOT auto-loaded)
├── templates/                 # Templates for new projects
│   ├── implementation_tracker.template.md
│   ├── implementation_archive.template.md
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
- **Efficient restoration**: ~4-6K tokens vs 25-40K from native compact

### Token Efficiency

| Method | Tokens to Restore | Quality |
|--------|-------------------|---------|
| Native auto-compact | 25-40K | Lossy |
| This system | ~3-4K | Lossless |

**Context Budget on Session Start:**
| Component | Target Tokens | Target Lines |
|-----------|---------------|--------------|
| Implementation Tracker | ~1500 | <100 |
| Daily Log (most recent) | ~1500 | <100 |
| Git Status | ~300 | ~20 |
| **Total** | **~3400** | ~220 |

This leaves 196K+ tokens for actual work!

---

## Success Metrics

The system is working when:
- You never hit native auto-compact (always save at 85% first)
- Sessions can build large features without context loss
- `/restore` brings back full context in ~4-6K tokens
- User never has to re-explain context after restart
- Leadership can read implementation_tracker.md for weekly status
- Team leads can read daily logs for daily updates
