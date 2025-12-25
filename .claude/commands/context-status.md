# Context Status Check

**Purpose**: Assess current context window usage and provide recommendations for state management.

---

## What This Command Does

1. **Estimates current context usage** (approximate percentage)
2. **Shows what's consuming context** (conversation, file reads, code outputs)
3. **Recommends next action** (continue, save state, compact)
4. **Provides context health metrics**

---

## Execution Steps

### 1. Estimate Context Usage

**Context Window**: 200,000 tokens total

**Assess**:
- Current conversation length (number of interactions)
- Large file reads performed
- Code generation performed
- Tool outputs received

**Estimation Guidelines**:
- **0-50K tokens (0-25%)**: ✅ Healthy - plenty of room
- **50-100K tokens (25-50%)**: ✅ Good - normal operation
- **100-140K tokens (50-70%)**: ⚠️ Moderate - monitor but okay
- **140-170K tokens (70-85%)**: ⚠️ High - consider saving state soon
- **170K+ tokens (85%+)**: 🚨 Critical - save state NOW

**Note**: These are estimates. Claude Code doesn't expose exact token counts, so use interaction count and content size as proxies.

---

### 2. Analyze Context Composition

**Break down what's in context**:

```markdown
## Context Breakdown (Estimated)

**Conversation History**: ~XX interactions
- User messages: ~XK tokens
- Assistant responses: ~XK tokens
- Tool results: ~XK tokens

**File Reads**: ~X files read
- Large files (>500 lines): [file1.ts, file2.ts]
- Medium files (100-500 lines): [file3.ts]
- Total estimated: ~XK tokens

**Code Generation**:
- Files written/edited: X files
- Total code output: ~XK tokens

**Estimated Total**: ~XK tokens (X%)
```

---

### 3. Identify Context Consumers

**Highlight major consumers**:
- **Large file reads** (files > 1000 lines)
- **Repeated reads** (same file read multiple times)
- **Extensive debugging output** (long error traces)
- **Large code generations** (generating 500+ line files)

**Example**:
```markdown
## Top Context Consumers

1. 🔴 Read `src/components/App.tsx` (3 times, ~6K tokens)
2. 🟡 Generated `docs/development_guide.md` (~2K tokens)
3. 🟡 Conversation about authentication flow (~3K tokens)
```

---

### 4. Check State Save Status

**Check**:
- When was state last saved? (check `.claude/session_state.md` timestamp)
- How many tasks completed since last save?
- Any unsaved progress?

**Example**:
```markdown
## State Save Status

**Last Save**: 2025-11-22 10:30 (45 minutes ago)
**Progress Since**:
- 3 tasks completed
- 2 files modified
- 1 key decision made

**Recommendation**: Save state soon to preserve recent progress
```

---

### 5. Provide Recommendation

Based on context level and state save status, recommend:

### If <70% Context
```markdown
✅ **Status: Healthy**

**Context Usage**: ~X% (XK tokens)
**Recommendation**: Continue working normally
**Next Check**: When you notice slower responses or after 5-10 more interactions

No action needed. Context is healthy.
```

### If 70-85% Context
```markdown
⚠️ **Status: Moderate - Monitor**

**Context Usage**: ~X% (XK tokens)
**Recommendation**: Save state soon as a precaution

**Suggested Actions**:
1. Complete current task
2. Run `/save-state` to preserve progress
3. Consider compact if you have more large features ahead

**Time Until Critical**: ~5-15 more interactions (depends on interaction size)
```

### If 85%+ Context
```markdown
🚨 **Status: Critical - Save Now**

**Context Usage**: ~X% (XK tokens)
**Recommendation**: **Save state immediately and compact**

**Required Actions**:
1. ⚠️ Run `/save-state` NOW to preserve all progress
2. ⚠️ Compact aggressively (all context is safely saved)
3. ✅ Use `/restore` to reload from docs with ~5K tokens

**Why This Matters**:
- Native auto-compact is imminent (happens at ~90%)
- Native compact is lossy (loses details)
- Manual save + compact is lossless (everything preserved)

**Don't delay** - save state now before native auto-compact triggers!
```

---

## Output Format

```markdown
📊 **Context Window Status**

**Current Usage**: ~X% (estimated XK / 200K tokens)
**Status**: [Healthy/Moderate/Critical]
**Last State Save**: [Time ago or "Not yet saved"]

---

## Context Breakdown
[Breakdown from step 2]

## Top Consumers
[Top 3-5 consumers from step 3]

## Recommendation
[Recommendation from step 5]

---

**Monitoring**: Auto-save triggers at 85%+ (per CLAUDE.md)
**Manual Save**: Use `/save-state` anytime to preserve progress
**Restore**: Use `/restore` to reload context from docs (~5K tokens)
```

---

## Interaction Count Estimation Guide

**Rough token estimation by interaction count**:

| Interactions | Estimated Context | Status |
|--------------|-------------------|---------|
| 0-20 | 0-30K (0-15%) | ✅ Healthy |
| 20-40 | 30-60K (15-30%) | ✅ Good |
| 40-60 | 60-90K (30-45%) | ✅ Good |
| 60-80 | 90-120K (45-60%) | ⚠️ Moderate |
| 80-100 | 120-150K (60-75%) | ⚠️ High |
| 100-120 | 150-170K (75-85%) | 🚨 Critical |
| 120+ | 170K+ (85%+) | 🚨 Save Now |

**Note**: Interactions with large file reads or code generation count more heavily.

---

## Special Cases

### Just After Restore
```markdown
📊 **Context Window Status**

**Current Usage**: ~5% (estimated 5-7K / 200K tokens)
**Status**: ✅ Healthy - Fresh after restore

**Context Loaded**:
- docs/current_state.md (~500 tokens)
- docs/logs/2025-11-22.md (~2K tokens)
- Development guide (skimmed, ~1.5K tokens)
- Git status (~500 tokens)

**Recommendation**: You have 195K tokens available. Plenty of room for work!
```

### Just After Auto-Compact
```markdown
📊 **Context Window Status**

**Current Usage**: ~2% (estimated 2-4K / 200K tokens)
**Status**: ✅ Healthy - Just compacted

**Context Retained**:
- Current task summary
- Active file references
- Immediate next steps

**Full Context**: Available in docs/logs/2025-11-22.md

**Recommendation**: Context is lean. Use `/restore` if you need full context back.
```

### Multiple Large File Reads
```markdown
⚠️ **High Context Usage Detected**

**Issue**: Multiple large files read (consuming ~30K tokens)
**Files**:
- src/app.tsx (read 2x, ~8K tokens)
- src/utils/helpers.ts (read 3x, ~12K tokens)
- docs/development_guide.md (full read, ~10K tokens)

**Suggestion**:
- Avoid re-reading large files unnecessarily
- Use selective reads (limit + offset) for large files
- Reference line numbers instead of full file reads

**Current Status**: 78% context - recommend save + compact soon
```

---

## When to Use This Command

### Regular Monitoring
- Every 20-30 interactions during active development
- After large file operations (reading 5+ files)
- After generating substantial code (500+ lines)
- When you notice slower response times

### Before Major Operations
- Before starting a new large feature
- Before extensive debugging sessions
- Before reading architecture documentation

### After Certain Events
- After completing a major task
- After significant context buildup
- Before taking a break (check if save needed)

---

## Automation Note

**Per CLAUDE.md**: Claude Code automatically monitors context and triggers save-state at 85%+.

This command is for **manual checking** when you want visibility into current status.

---

**Note**: Context estimation is approximate. Use this as a guide, not exact measurement.
