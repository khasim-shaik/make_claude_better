# Context Status Check

**Purpose**: Show real context window usage from transcript data and provide recommendations.

---

## What This Command Does

1. **Reads actual token usage** from the transcript file (not estimates!)
2. **Shows current context percentage** and status
3. **Recommends next action** based on usage level
4. **Provides actionable guidance** for state management

---

## Execution Steps

### 1. Run Token Estimation Script

Execute the token estimation utility to get real data:

```bash
./.claude/hooks/estimate-tokens.sh --json
```

This reads the transcript JSONL file and extracts actual token counts from Claude's usage data.

### 2. Parse and Display Results

The script returns JSON with:
- `current_context`: Total tokens in context window
- `percentage`: Percentage of 200K context used
- `status`: healthy | good | moderate | high | critical
- `message_count`: Number of messages in session

### 3. Format Output

Display the results in this format:

```markdown
📊 **Context Window Status**

**Current Usage**: [X]K / 200K tokens (~[X]%)
**Status**: [emoji] [status]
**Session Messages**: [X]

---

## Recommendation

[Based on percentage, provide appropriate recommendation]
```

---

## Status Thresholds

| Percentage | Status | Emoji | Action |
|------------|--------|-------|--------|
| 0-25% | Healthy | ✅ | Continue working |
| 25-50% | Good | ✅ | Normal operation |
| 50-70% | Moderate | ⚠️ | Monitor, consider saving soon |
| 70-85% | High | ⚠️ | Save state soon |
| 85%+ | Critical | 🚨 | Save state NOW, compact |

---

## Recommendations by Status

### ✅ Healthy / Good (0-50%)
```markdown
✅ **Status: Healthy**

Context is well within limits. Continue working normally.

**Next check**: After 20-30 more interactions or large file operations.
```

### ⚠️ Moderate (50-70%)
```markdown
⚠️ **Status: Moderate - Monitor**

Context is building up. Consider saving state as a precaution.

**Suggested Actions**:
1. Complete current task
2. Consider running `/save-state` to preserve progress
3. Monitor for slower responses

**Estimated runway**: ~30-50 more interactions
```

### ⚠️ High (70-85%)
```markdown
⚠️ **Status: High - Save Soon**

Context is getting full. Save state before it becomes critical.

**Recommended Actions**:
1. Finish current task quickly
2. Run `/save-state` to preserve all progress
3. Consider compacting after save

**Estimated runway**: ~10-20 more interactions before critical
```

### 🚨 Critical (85%+)
```markdown
🚨 **Status: CRITICAL - Save Now**

Context window is nearly full. Native auto-compact may trigger soon.

**REQUIRED Actions**:
1. ⚠️ Run `/save-state` IMMEDIATELY
2. ⚠️ Compact after saving (all context safely preserved in docs/)
3. ✅ Use `/restore` to reload with ~5K tokens

**Why this matters**:
- Native auto-compact at ~90% is LOSSY
- Manual save + compact is LOSSLESS
- Don't lose your progress!
```

---

## Example Output

```markdown
📊 **Context Window Status**

**Current Usage**: 54.3K / 200K tokens (~27%)
**Status**: ✅ Good
**Session Messages**: 45

---

## Recommendation

✅ **Status: Healthy**

Context is well within limits. Continue working normally.

**Next check**: After 20-30 more interactions or large file operations.

---

*Real token data from transcript. Use `/save-state` anytime to preserve progress.*
```

---

## How It Works

The estimation script:
1. Finds the current session's transcript file in `~/.claude/projects/`
2. Reads the JSONL transcript data
3. Extracts the **last message's usage data** (which shows current context size)
4. Context = `input_tokens + cache_creation_input_tokens + cache_read_input_tokens`

This gives us **actual token counts** from Claude's API response, not rough estimates!

---

## When to Use This Command

- **Regular monitoring**: Every 20-30 interactions
- **After large operations**: Reading many files, generating lots of code
- **Before breaks**: Check if you should save state first
- **When responses slow down**: May indicate high context usage

---

## Note on Accuracy

This uses **real token data** embedded in Claude's responses, not character-based estimates.
The data comes directly from the API usage field in each message.
