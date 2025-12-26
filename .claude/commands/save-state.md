# Save Current Session State

**Purpose**: Preserve current development context to documentation files for later restoration.

This command saves to **2 files** with distinct audiences:
- `docs/implementation_tracker.md` - Strategic (for engineering leadership) - **KEEP SLIM**
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

**IMPORTANT: Keep this file under 100 lines!**
- This file is auto-loaded on session start
- Large files defeat the purpose of context management
- Move completed weeks to `docs/implementation_archive.md`

**Update These Sections**:

#### Current Week
- Update completion status (checkboxes)
- Move completed items from "In Progress" to "Completed"
- Add any new blocked items

#### Active Blockers
- Add new blockers encountered
- Update status of existing blockers

#### Next Week Preview (if applicable)
- Update priorities based on progress

**DO NOT add to tracker (put in archive instead)**:
- Detailed decision logs (brief mentions OK)
- Full bug descriptions
- Technical debt items

**Example Update**:
```markdown
## Current Week

### Completed
- [x] SessionStart hook implementation
- [x] Token monitoring system
- [x] File restructuring ← NEW

### In Progress
- [ ] Install script
```

---

### 2. Log Rotation (Before Creating Today's Log)

**Check if switching days:**
```bash
# If there's an existing log that's NOT today's date, archive it first
ls docs/logs/*.md 2>/dev/null | head -1
```

**If old log exists, archive it:**
```bash
# Create archive directory if needed
mkdir -p docs/logs/archive/YYYY-MM

# Move old log to archive
mv docs/logs/OLD-DATE.md docs/logs/archive/YYYY-MM/
```

**Why?** Only ONE log file should exist in `docs/logs/` - the most recent one. This ensures session-start loads the right context regardless of work gaps.

---

### 3. Update Today's Daily Log (Tactical)
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
Consolidating to slim tracker + archive strategy.

**Uncommitted Changes**:
- Modified session-start.sh
- Created new templates

**Next Immediate Action**:
Update save-state.md command
```

#### Decisions Made Today
- Add any decisions with rationale
- These also go in `implementation_archive.md` for permanent record

#### Notes
- Update scratchpad, edge cases, links as needed

---

### 4. Update Archive (If Decisions/Bugs Today)
**File**: `docs/implementation_archive.md`

If you made key decisions or fixed bugs today:
- Add to "Full Decision Log" table
- Add to "Full Bug Log" table

This file is NOT auto-loaded, so it can grow without affecting context.

---

### 5. Size Check
**Run**:
```bash
wc -l docs/implementation_tracker.md
```

**If over 100 lines**, suggest:
```
⚠️ Implementation tracker is X lines (target: <100).
Consider running /archive-week to move completed weeks to archive.
```

---

### 6. Check Git Status
**Run**:
```bash
git status
```

Note uncommitted changes in the daily log's "Current Task" section.

---

### 7. Estimate Context Usage
**Run**:
```bash
./.claude/hooks/estimate-tokens.sh
```

Include result in daily log's "Context Status" section.

---

## Output Format

### Success Message
```markdown
**Session State Saved**

**Updated Files**:
- docs/implementation_tracker.md (X lines)
- docs/logs/YYYY-MM-DD.md

**Summary**:
- [X] tasks completed
- [Y] files modified

**Context Status**: ~X% ([status])

Context preserved. Use `/restore` to reload anytime.
```

### With Size Warning
```markdown
**Session State Saved**

**Updated Files**:
- docs/implementation_tracker.md (125 lines)
- docs/logs/YYYY-MM-DD.md

**Summary**:
- [X] tasks completed

**Context Status**: ~X%

Implementation tracker is over 100 lines. Run `/archive-week` to keep it slim.
```

---

## File Purposes Reminder

| File | Audience | Auto-Loaded | Target Size |
|------|----------|-------------|-------------|
| `implementation_tracker.md` | Leadership | Yes | <100 lines |
| `implementation_archive.md` | Reference | No | Unlimited |
| `docs/logs/YYYY-MM-DD.md` | Team Lead | Yes (most recent) | <100 lines |

---

## Best Practices

### Implementation Tracker (Strategic)
- Keep under 100 lines
- Focus on current week only
- Brief status updates
- Archive completed weeks

### Daily Log (Tactical)
- Be detailed - this is for resume context
- Include file:line references
- Capture current thinking/approach
- Note uncommitted changes

### Archive (Historical)
- Add decisions and bugs here
- Keep full history
- Never auto-loaded

---

## After Saving State

### If 85%+ Context
After saving, if context is critical:
1. Confirm all context is saved
2. Compact conversation
3. Use `/restore` to reload with ~3K tokens

### Normal Context
Continue working. State is safely preserved in docs/.

