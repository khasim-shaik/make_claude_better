
---

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

- `/restore` - Restore full context from documentation
- `/save-state` - Manually save current state
- `/context-status` - Check current context usage
- `/archive-week` - Move completed weeks to archive

---

## Session Start (AUTOMATIC via Hook)

The SessionStart hook automatically runs `.claude/hooks/session-start.sh` which:
1. Reads `docs/implementation_tracker.md` - Strategic context
2. Reads `docs/development_guide.md` - Architectural context
3. Reads the **most recent** daily log - Tactical context
4. Shows `git status` and recent commits

**You don't need to run /restore manually** - it happens automatically!

---

## Proactive Context Monitoring

**On session start**: The SessionStart hook shows current context usage automatically.

**Periodic checks**: Run `/context-status` to check real token usage.

**At 85%+**: Auto-save state before native auto-compact triggers.

