# Save Current Session State

**Purpose**: Preserve current development context to documentation files for later restoration.

This command saves to **2 files** with distinct audiences:
- `docs/implementation_tracker.md` - Strategic (for engineering leadership)
- `docs/logs/YYYY-MM-DD.md` - Tactical (for team lead daily review)

---

## When to Use This Command

### Automatic Triggers (per CLAUDE.md)
- Context usage reaches 85%+ (auto-triggered)
- After completing a significant task

### Manual Use Cases
- Before taking a break
- Before switching features
- Before risky changes
- Before ending a session

---

## Execution Steps

### 1. Update Implementation Tracker (Strategic)
**File**: `docs/implementation_tracker.md`

**Update These Sections**:

#### Current Week
- Update completion status (checkboxes)
- Move completed items from "In Progress" to "Completed"
- Add any new blocked items

#### Key Decisions Log
- Add any new architectural/technical decisions made
- Include date, decision, rationale, impact

#### Bugs Fixed
- Add any bugs fixed today
- Include root cause and resolution

#### Current Blockers
- Add new blockers encountered
- Update status of existing blockers

#### Next Week (if applicable)
- Update priorities based on progress
- Note any new dependencies

**Example Update**:
```markdown
## Current Week (Week 1: 12/24 - 12/29) 🔄

**Status**: 90% complete

### Completed
- [x] SessionStart hook implementation
- [x] Token monitoring system
- [x] File restructuring ← NEW

### In Progress
- [ ] Install script
```

---

### 2. Update Today's Daily Log (Tactical)
**File**: `docs/logs/YYYY-MM-DD.md`

**Update These Sections**:

#### Completed Tasks
Add new entries with timestamps:
```markdown
### [14:30] Implemented token estimation
**Files**: .claude/hooks/estimate-tokens.sh
**Details**:
- Created script to read transcript JSONL
- Extracts real token counts from API usage data
**Code Changes**:
- `.claude/hooks/estimate-tokens.sh:1-120` - New file
```

#### Current Task
Update with current work state:
```markdown
## Current Task

**Working On**: File restructuring
**Status**: In Progress
**Files Being Modified**:
- `.claude/hooks/session-start.sh` (lines 26-44)

**Approach/Thinking**:
Consolidating current_state and session_state into implementation_tracker.
Daily log will handle all tactical/session context.

**Uncommitted Changes**:
- Modified session-start.sh to read implementation_tracker
- Created new templates

**Next Immediate Action**:
Update save-state.md command to use new file structure
```

#### Decisions Made Today
- Add any decisions with rationale

#### Notes
- Update scratchpad, edge cases, links as needed

---

### 3. Check Git Status
**Run**:
```bash
git status
```

Note uncommitted changes in the daily log's "Current Task" section.

---

### 4. Estimate Context Usage
Run the token estimation script:
```bash
./.claude/hooks/estimate-tokens.sh
```

Include result in daily log's "Context Status" section.

---

## Output Format

### Success Message
```markdown
💾 **Session State Saved Successfully**

**Updated Files**:
- ✅ docs/implementation_tracker.md (strategic: decisions, blockers, progress)
- ✅ docs/logs/YYYY-MM-DD.md (tactical: tasks, code changes, session context)

**Summary**:
- [X] tasks completed
- [Y] new decisions documented
- [Z] files modified

**Context Status**: ~X% ([status])

All context safely preserved. Use `/restore` to reload anytime.
```

---

## File Purposes Reminder

| File | Audience | Contains |
|------|----------|----------|
| `implementation_tracker.md` | Engineering Leadership | Weekly roadmap, decisions, bugs, blockers, next steps |
| `daily_log.md` | Team Lead | Daily tasks, code changes, current work, session context, notes |

---

## Best Practices

### Implementation Tracker (Strategic)
- Keep high-level, leadership-readable
- Focus on milestones, not details
- Update weekly roadmap status
- Document decisions that affect project direction

### Daily Log (Tactical)
- Be detailed - this is for resume context
- Include file:line references
- Capture current thinking/approach
- Note uncommitted changes
- Update scratchpad with temp notes

---

## After Saving State

### If 85%+ Context
After saving, if context is critical:
1. Confirm all context is saved
2. Compact conversation
3. Use `/restore` to reload with ~5K tokens

### Normal Context
Continue working. State is safely preserved in docs/.
