# Context Restoration Protocol

You're starting a new Claude Code session or restoring context after a compact. Follow this protocol to restore full development context efficiently.

## The 2-File System

| File | Audience | Purpose |
|------|----------|---------|
| `docs/implementation_tracker.md` | Engineering Leadership | Strategic: roadmap, decisions, blockers, weekly progress |
| `docs/logs/YYYY-MM-DD.md` | Team Lead | Tactical: daily tasks, code changes, session context |

---

## Execution Steps

### 1. Read Implementation Tracker (Strategic)
**File**: `docs/implementation_tracker.md`

**Extract**:

**📊 Executive Summary:**
- Overall project status
- Current week and progress %

**🗓️ Weekly Roadmap:**
- What week are we on?
- What's planned vs completed?

**📅 Current Week:**
- What's completed this week?
- What's in progress?
- What's blocked?

**🔮 Next Week:**
- What's coming up?
- Any dependencies?

**🔑 Key Decisions:**
- Recent architectural decisions
- Why certain approaches were chosen

**🚧 Current Blockers:**
- Any blockers or issues

**Purpose**: Understand WHERE the project is and WHERE it's going

**Token Budget**: ~1000-1500 tokens

---

### 2. Read Today's Daily Log (Tactical)
**File**: `docs/logs/YYYY-MM-DD.md` (use today's date)

**Extract**:

**📋 Completed Tasks:**
- What was done today?
- File references and code changes

**🔄 Current Task:**
- What file/lines are being worked on?
- What's the approach/thinking?
- What are uncommitted changes?
- What's the immediate next action?

**📝 Decisions Made Today:**
- Today's decisions with rationale

**📌 Notes:**
- Scratchpad items
- Edge cases to handle
- Resource links

**Purpose**: Understand WHAT was done today and WHERE to resume

**Token Budget**: ~1500-2000 tokens

**Note**: If today's log doesn't exist, this is a fresh day - skip this step

---

### 3. Read Yesterday's Log (Conditional)
**File**: `docs/logs/YYYY-MM-DD.md` (yesterday's date)

**When to read**:
- If today's log is empty or minimal
- If implementation tracker references yesterday's work
- If current task started yesterday

**When to skip**:
- If today's log is comprehensive
- If working on something new today

**Purpose**: Understand recent continuity

**Token Budget**: Skim for key points (~1000-1500 tokens)

---

### 4. Check Git Status
**Commands to Run**:
```bash
git log --oneline -5
git status
git diff --stat
```

**Extract**:
- Recent commit messages
- Uncommitted changes
- Current branch

**Purpose**: Understand code state

**Token Budget**: ~300-500 tokens

---

## Output Format

After reading files, provide a **concise summary**:

```markdown
📋 **Context Restored**

**Project**: [Project name]
**Week**: [Current week of Y] - [Status: On Track/At Risk/Blocked]
**Phase**: [Current phase from roadmap]

---

**This Week's Progress**:
- ✅ [Completed item 1]
- ✅ [Completed item 2]
- 🔄 [In progress item]
- ⏳ [Upcoming item]

**Current Task** (from today's log):
- 📁 [File being worked on]
- 💭 [Approach/thinking]
- ➡️ [Next immediate action]

**Recent Decisions**:
- [Decision 1]: [Why]
- [Decision 2]: [Why]

**Blockers**: [Any blockers or "None"]

**Context Size**: ~[X]K tokens loaded

---

Ready to continue. What would you like to work on?
```

---

## Best Practices

### Token Efficiency
- **implementation_tracker.md** = Strategic overview (don't need every detail)
- **daily_log.md** = Tactical resume point (focus on Current Task section)
- **Conditional reading** - only read yesterday if needed
- **Skim, don't deep read** - extract key information only

### Target Token Usage
- Implementation tracker (strategic): ~1000-1500 tokens
- Today's log (tactical): ~1500-2000 tokens
- Yesterday's log (conditional): ~1000-1500 tokens
- Git context: ~300-500 tokens

**Total**: ~4-6K tokens for full context restoration

---

## Special Cases

### Fresh Project (No Previous Work)
```markdown
📋 **Context Restored**

**Status**: Fresh project, no previous work detected

**Project**: [Project name]
**Phase**: Initial setup

**Available Resources**:
- Implementation tracker: docs/implementation_tracker.md
- Development guide: docs/development_guide.md

Ready to start. What would you like to build?
```

### After Auto-Compact (Mid-Session)
```markdown
📋 **Context Restored After Auto-Compact**

**Current Task** (from today's log):
- 📁 [File:lines being edited]
- 💭 [In-progress thought]
- ➡️ [Next immediate action]

**This Week**: [Week X] - [Progress]%

Full context in:
- Strategic: docs/implementation_tracker.md
- Tactical: docs/logs/YYYY-MM-DD.md

Ready to continue where we left off.
```

### Multiple Days Inactive
If logs show gap of 3+ days:
- Read implementation tracker for current state
- Read most recent daily log
- Note the gap in summary
- Ask user if they want to continue or start fresh

---

## Error Handling

### File Not Found
- If `implementation_tracker.md` missing: Create from template
- If today's log missing: Fresh day, create if needed
- If development_guide.md missing: Note it, ask for context

### Git Not Initialized
- Skip git context, note in summary
- Continue with file-based context

---

## The 2-File Advantage

**Old System (3 files)**:
1. current_state.md (mixed tactical/strategic)
2. session_state.md (immediate context)
3. daily_log.md (history)

**New System (2 files)**:
1. implementation_tracker.md (strategic - for leadership)
2. daily_log.md (tactical - all session context here)

**Benefits**:
- ✅ Clearer audience separation
- ✅ Simpler mental model
- ✅ Leadership can read one file for status
- ✅ Team lead can read daily log for details
- ✅ Same total information, better organized

---

**Note**: This command restores context efficiently. The implementation tracker tells you the big picture (where the project is), while the daily log tells you exactly where to resume (what file, what thought, what next).
