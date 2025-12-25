# Context Restoration Protocol

You're starting a new Claude Code session or restoring context after a compact. Follow this protocol to restore full development context efficiently.

## Execution Steps

### 1. Read Current State (Tactical + Strategic)
**File**: `docs/current_state.md`

**Extract ALL Sections**:

**⚡ Right Now (Tactical):**
- What file/lines are being worked on?
- What's the in-progress thought/approach?
- What are uncommitted changes?
- What's the immediate next action?

**🎯 Current Focus (Strategic):**
- What phase/feature is active?
- What tasks are in progress vs completed?
- What's the overall priority?

**📋 Recent Completions:**
- What was completed recently (last 1-2 days)?
- File references and line numbers

**🔑 Key Decisions:**
- Recent decisions with rationale
- Why certain approaches were chosen

**🚀 Next Steps:**
- Immediate (today)
- Short-term (this week)
- Medium-term

**🚧 Blockers:**
- Any current blockers or issues

**Purpose**: Understand BOTH what's happening now (tactical) AND where the project is overall (strategic)

**Token Budget**: ~1000-1500 tokens (all context in one file now)

---

### 2. Read Today's Log
**File**: `docs/logs/YYYY-MM-DD.md` (use today's date)

**Extract**:
- Sessions today (morning, afternoon, etc.)
- Completed tasks with file references
- Decisions made today with rationale
- Code changes (file paths and line numbers)
- Current task status

**Purpose**: Understand what happened TODAY in detail

**Note**: If today's log doesn't exist, this is a fresh day - skip this step and note it in your summary

**Token Budget**: ~1500-2000 tokens

---

### 3. Read Yesterday's Log (Conditional)
**File**: `docs/logs/YYYY-MM-DD.md` (yesterday's date)

**When to read**:
- If current_state.md references yesterday's work
- If today's log mentions continuing from yesterday
- If current task started yesterday

**When to skip**:
- If today's log is comprehensive on its own
- If current_state.md is self-contained
- If working on a brand new feature today

**Purpose**: Understand recent history and continuity

**Token Budget**: Skim for key points only (~1000-1500 tokens)

---

### 4. Skim Development Guide
**File**: `docs/development_guide.md`

**Read These Sections Only**:
- Project Overview (30 seconds)
- Architecture (understand structure)
- Tech Stack (what we're using)
- Coding Conventions (key patterns to follow)

**Skip These Sections** (unless specifically relevant):
- Detailed API documentation
- Full troubleshooting guide
- Extensive setup instructions

**Purpose**: Understand project architecture and patterns

**Token Budget**: ~1000-1500 tokens (skim, don't deep read)

---

### 5. Check Git Status
**Commands to Run**:
```bash
# Recent commits (last 10)
git log --oneline -10

# Current working directory status
git status

# If there are uncommitted changes, show summary
git diff --stat
```

**Extract**:
- Recent commit messages (understand recent work)
- Uncommitted changes (what's in progress)
- Current branch name

**Purpose**: Understand code state and recent history

**Token Budget**: ~300-500 tokens

---

## Output Format

After reading all relevant files, provide a **concise summary** in this format:

```markdown
📋 **Context Restored**

**Project**: [Project name]
**Phase**: [Current phase - e.g., "Authentication System Implementation"]

**Right Now** (Tactical):
- 🔄 [What file/line you were working on]
- 💭 [In-progress thought or approach]
- 📝 [Uncommitted changes or next immediate action]

**Recent Progress** (Last 1-2 days):
- [Key completion 1 with file reference]
- [Key completion 2 with file reference]

**Active Tasks**:
- 🔄 [Current task 1]
- 🔄 [Current task 2]

**Next Steps** (Priority order):
1. [Immediate next action]
2. [Following task]
3. [Subsequent task]

**Key Decisions** (Recent):
- [Decision 1]: [Why]
- [Decision 2]: [Why]

**Blockers**: [Any blockers or "None"]

**Context Size**: Estimated [X]K tokens loaded

---

Ready to continue. What would you like to work on?
```

---

## Best Practices

### Token Efficiency
- **current_state.md is now your primary source** - both tactical AND strategic
- **Don't read entire files** - extract key information only
- **Skip irrelevant sections** - development guide is reference material
- **Conditional reading** - only read yesterday's log if needed
- **Skim, don't deep read** - you need context, not memorization

### Target Token Usage (Updated for Simplified System)
- Current state (tactical + strategic): ~1000-1500 tokens
- Today's log: ~1500-2000 tokens
- Yesterday's log (conditional): ~1000-1500 tokens
- Development guide (skim): ~1000-1500 tokens
- Git context: ~300-500 tokens

**Total**: ~5-7K tokens for full context restoration (same as before, but simpler!)

### Quality Over Quantity
- Focus on **what**, **why**, and **next**
- Extract **decisions and rationale** (critical for continuity)
- Note **file paths and line numbers** (quick navigation)
- Capture **blockers or open questions** (resume smoothly)
- **Tactical context** tells you the immediate next step
- **Strategic context** tells you the big picture

---

## Special Cases

### Fresh Project (No Previous Work)
```markdown
📋 **Context Restored**

**Status**: Fresh project, no previous work detected

**Project**: Claude Learning
**Phase**: Initial setup

**Available Resources**:
- Development guide: docs/development_guide.md
- Current state: docs/current_state.md

Ready to start. What would you like to build?
```

### After Auto-Compact (Mid-Session)
```markdown
📋 **Context Restored After Auto-Compact**

**Right Now** (from current_state.md):
- 🔄 [Active task]
- 📝 [Currently editing file:lines]
- 💭 [In-progress thought]

**Next Immediate Action**: [from tactical section]

Full context available in:
- Current state: docs/current_state.md
- Today's log: docs/logs/YYYY-MM-DD.md

Ready to continue where we left off.
```

### Multiple Days Inactive
If logs show gap of 3+ days:
- Read last session's log (most recent)
- Read current_state.md for high-level status
- Note the gap in your summary
- Ask user if they want to continue previous work or start something new

---

## Error Handling

### File Not Found
- If `docs/current_state.md` missing: **Critical error** - this is the core file
- If today's log missing: Fresh day, skip gracefully
- If development_guide.md missing: Note it, ask user for context

### Git Not Initialized
- If git commands fail: Skip git context, note in summary
- Continue with file-based context

### Empty or Minimal Content
- If files exist but are sparse: Note it, work with what's available
- Don't hallucinate missing information

---

## Key Improvement: Simplified System

**Old System** (3 files to read):
1. current_state.md (strategic) - 500 tokens
2. session_state.md (tactical) - 500 tokens
3. logs/today.md - 2000 tokens
**Total effort**: Read 3 files, merge mental model

**New System** (2 files to read):
1. current_state.md (tactical + strategic) - 1000-1500 tokens
2. logs/today.md - 2000 tokens
**Total effort**: Read 2 files, clear structure

**Benefits**:
- ✅ Simpler: One source of truth for current state
- ✅ Faster: One less file to read
- ✅ Clearer: Tactical at top, strategic below - natural flow
- ✅ Same token cost: ~5-7K total (just reorganized)

---

**Note**: This command is designed for efficiency. The new merged current_state.md gives you BOTH immediate tactical context (what file, what line, what thought) AND strategic context (what feature, what progress, what decisions) in one convenient place. Read strategically, extract key information, and provide actionable summary.
