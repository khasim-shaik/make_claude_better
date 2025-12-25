# Save Current Session State

**Purpose**: Preserve current development context to documentation files for later restoration.

This command is typically triggered **automatically** at 85%+ context usage, but can be run manually when needed.

---

## When to Use This Command

### Automatic Triggers (per CLAUDE.md)
- Context usage reaches 85%+ (auto-triggered, no user intervention)
- After completing a significant task (auto-update logs)

### Manual Use Cases
- Before taking a break (preserve in-progress work)
- Before switching to a different feature/task
- Before experimenting with risky changes
- When you want to checkpoint current progress
- Before ending a session for the day

---

## Execution Steps

### 1. Update Current State
**File**: `docs/current_state.md`

**Update These Sections**:

#### Current Focus
- What feature/epic is currently active
- Current priority level

#### Active Tasks
- Tasks in progress (from todo list)
- Tasks recently completed but not yet logged
- Update checkboxes: [x] completed, [ ] pending

#### Recent Completions
- Add newly completed tasks
- Include date and brief description
- Add file references (path:line)

#### Key Decisions
- Add any new decisions made since last save
- Include decision, rationale, and impact
- Update decisions table

#### Next Steps
- Update based on current progress
- Re-prioritize if needed
- Add new steps discovered during work

#### Blockers
- Add any new blockers encountered
- Update status of existing blockers

**Example Update**:
```markdown
## Active Tasks
- [x] Create context management system
- [ ] Implement authentication endpoints
- [ ] Write integration tests

## Recent Completions
### Today (2025-11-22)
- ✅ Created `/restore` command (.claude/commands/restore.md)
- ✅ Created `/save-state` command (.claude/commands/save-state.md)
```

---

### 2. Update Today's Log
**File**: `docs/logs/YYYY-MM-DD.md` (use today's date)

**Add New Entry in "Completed Tasks" Section**:

```markdown
### ✅ [Task Name]
**Time**: HH:MM
**Files**: [Modified files with paths]

**Details**:
- [What was done]
- [Key implementation details]

**Decisions** (if any):
- [Decision made]: [Rationale]

**Code Changes**:
- `file/path.ts:line-range` - [What changed]
```

**Update "Current Task" Section**:
```markdown
## Current Task

🔄 **[Task name]**

**Status**: In Progress
**Next File**: [File to work on next]

**Progress**:
- [x] [Completed subtask]
- [ ] [Pending subtask]
```

**Update "Next Steps" Section**:
```markdown
### Immediate (This Session)
1. [Most immediate next task]
2. [Following task]
```

---

### 3. Update Session State
**File**: `.claude/session_state.md`

**Content to Save**:

```markdown
# Session State

**Last Updated**: YYYY-MM-DD HH:MM

## Immediate Context

**Currently Working On**: [Specific task - e.g., "Implementing refresh token endpoint"]

**Files Being Modified**:
- `src/routes/auth.ts` (editing lines 140-180)
- `src/auth/jwt.ts` (reviewing token expiry logic)

**In-Progress Thought/Approach**:
[Your current thinking - e.g., "Debating between token family approach vs rotation strategy. Leaning toward rotation for better security. Need to implement token blacklist in Redis."]

**Uncommitted Changes**:
- Added `POST /api/auth/refresh` endpoint skeleton
- Updated JWT types to include refresh token
- TODO: Implement token validation and rotation logic

## Recent Context (Last 30 Minutes)

**What Led Here**:
- Completed login endpoint implementation
- Decided to use httpOnly cookies for security
- Started on refresh token logic

**Decisions Made**:
- Use RS256 (asymmetric) for JWT signing
- 15-minute access token, 7-day refresh token
- Store refresh tokens in Redis for revocation

**Files Recently Modified**:
- `src/routes/auth.ts` (login endpoint)
- `src/auth/jwt.ts` (token generation)
- `src/middleware/auth.ts` (verification middleware)

## Next Immediate Action

[Very specific next step - e.g., "Implement token validation in refresh endpoint: check if token exists in Redis, verify signature, issue new token pair"]

## Temporary Notes

- [Any scratchpad notes, reminders, or things to remember]
- [Links to resources you're referencing]
- [Edge cases to handle]

---

**Auto-Updated**: This file is automatically updated when context reaches 85% or before manual compacts
```

---

### 4. Check Git Status
**Run**:
```bash
git status
```

**If Uncommitted Changes Exist**:
- Note them in session_state.md
- Consider if they should be committed
- If work-in-progress: Leave uncommitted, note in session state
- If complete feature: Suggest committing

**Don't Auto-Commit**: Only commit when explicitly requested by user

---

### 5. Estimate Context Usage
**Assess**:
- How full is current context (rough estimate: low/medium/high/critical)
- Whether compact is recommended

**If 85%+ Context**:
```markdown
💾 **State Saved** (Context at ~87%)

All important context saved to:
- docs/current_state.md (updated with latest progress)
- docs/logs/2025-11-22.md (new tasks logged)
- .claude/session_state.md (immediate context preserved)

**Recommendation**: Safe to compact aggressively now. All context is preserved in docs.

Ready to compact? (Will reduce to ~0 tokens, can restore with `/restore`)
```

**If <85% Context**:
```markdown
💾 **State Saved** (Context at ~65%)

All progress saved to documentation. Current context level is healthy.

Context can continue without compact. Use `/restore` anytime to refresh from docs.
```

---

## Output Format

### Success Message
```markdown
💾 **Session State Saved Successfully**

**Updated Files**:
- ✅ docs/current_state.md (active tasks, decisions, next steps)
- ✅ docs/logs/2025-11-22.md (completed tasks, code changes)
- ✅ .claude/session_state.md (immediate context)

**Summary**:
- [X] tasks completed since last save
- [Y] new decisions documented
- [Z] files modified

**Context Status**: [Estimated %] - [Recommendation: continue/compact/healthy]

All context safely preserved. Use `/restore` to reload anytime.
```

---

## Best Practices

### Be Comprehensive
- **Capture everything important** - this is your backup
- **Include rationale** - why decisions were made
- **Note file paths** - enable quick navigation on restore
- **Update timestamps** - track when changes occurred

### Be Concise
- **Don't duplicate** - current_state.md is high-level, logs are detailed
- **Structure over prose** - use tables, lists, checkboxes
- **Key points only** - session_state.md is for immediate context

### Be Consistent
- **Use same format** every time (enables easy parsing)
- **Update all three files** (current_state, today's log, session_state)
- **Timestamp updates** (know when state was last saved)

---

## Special Cases

### First Save of the Day
- Create today's log file if it doesn't exist
- Use log template format
- Note it's the first session

### Mid-Task Save (Work in Progress)
- Mark task as "in progress" in current_state.md
- In session_state.md, capture exact point where you stopped
- Note any pending decisions or open questions

### End of Feature
- Mark all related tasks as completed
- Update current_state.md with new focus
- Clear session_state.md or reset for next feature

### Before Risky Changes
- Commit current code first (if stable)
- Save state to docs
- Note in session_state.md: "Before attempting [risky change]"

---

## Error Handling

### File Doesn't Exist
- Create it using template format
- Note that it was created

### Can't Determine Current Task
- Check todo list (if active)
- Check git status (uncommitted changes)
- Check session_state.md (previous context)
- Ask user if still unclear

### Git Not Available
- Skip git status check
- Continue with file-based state save
- Note in output that git context wasn't captured

---

## After Saving State

### Automatic Compact (if at 85%+)
After saving, if context is at 85%+:

1. Confirm all context is saved
2. Compact conversation aggressively
3. Keep only minimal context:
   ```
   Session compacted at [TIME]

   Current task: [from session_state.md]
   Files in progress: [from session_state.md]

   Full context available in docs/
   Use `/restore` to reload complete context
   ```

### Manual Compact Available
If user wants to compact manually, they can now do so safely knowing everything is preserved.

---

**Note**: This command preserves ALL important context in structured files, enabling lossless restoration via `/restore` command.
