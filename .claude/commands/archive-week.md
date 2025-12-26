# Archive Completed Week

**Purpose**: Move completed week data from `implementation_tracker.md` to `implementation_archive.md` to keep the tracker slim and context-efficient.

---

## When to Use This Command

- Implementation tracker exceeds 100 lines
- A week is marked as complete (moved to "Previous Weeks")
- Starting a new week
- Claude suggests it after save-state

---

## Execution Steps

### 1. Identify Week to Archive

Read `docs/implementation_tracker.md` and identify:
- Which week(s) are marked as complete (✅)
- What decisions were made that week
- What bugs were fixed that week

---

### 2. Move Week to Archive

**File**: `docs/implementation_archive.md`

Add a new week section under "## Archived Weeks":

```markdown
### Week X (MM/DD - MM/DD) ✅

**Summary**: [Brief description of what was accomplished]

**Milestones Completed**:
- [Milestone 1]
- [Milestone 2]

**Key Decisions**:
| Date | Decision | Rationale | Impact |
|------|----------|-----------|--------|
| MM/DD | [Decision] | [Why] | [Effect] |

**Bugs Fixed**:
| Date | Bug | Root Cause | Resolution |
|------|-----|------------|------------|
| MM/DD | [Bug] | [Cause] | [Fix] |

**Notes**:
- [Any important notes from this week]
```

Also update:
- "Full Decision Log" table with this week's decisions
- "Full Bug Log" table with this week's bugs

---

### 3. Update Implementation Tracker

**File**: `docs/implementation_tracker.md`

After archiving:

1. **Update Weekly Roadmap** - Mark archived week as ✅
2. **Remove archived week details** - Keep only current and next week
3. **Update "Current Week"** to the new active week
4. **Verify file is under 100 lines**

---

### 4. Verify Line Count

```bash
wc -l docs/implementation_tracker.md
```

Target: Under 100 lines.

---

## Output Format

```markdown
**Week Archived Successfully**

**Moved to Archive**:
- Week X (MM/DD - MM/DD)
- X decisions
- X bugs fixed

**Implementation Tracker**:
- Before: 125 lines
- After: 68 lines

**Files Updated**:
- docs/implementation_tracker.md (slimmed)
- docs/implementation_archive.md (week added)
```

---

## Example

### Before (tracker too large)

```markdown
# Implementation Tracker

## Weekly Roadmap
| Week 1 | Core hooks | ✅ |
| Week 2 | Testing | 🔄 |

## Previous Weeks

### Week 1 (12/24 - 12/29) ✅
[Lots of details...]

## Current Week (Week 2)
[Current work...]
```

### After (slim tracker)

```markdown
# Implementation Tracker

## Weekly Roadmap
| Week 1 | Core hooks | ✅ |
| Week 2 | Testing | 🔄 |

## Current Week (Week 2)
[Current work...]

## Quick Links
- Full history: docs/implementation_archive.md
```

Week 1 details moved to `implementation_archive.md`.

---

## Best Practices

- Archive at the END of a week, not the beginning
- Include all decisions and bugs in archive
- Keep tracker focused on current + next week only
- Reference archive for historical lookups

