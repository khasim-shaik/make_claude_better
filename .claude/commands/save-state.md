# Save Current Session State

**Purpose**: Preserve current development context to documentation files for later restoration.

This command saves to **3 files** with distinct audiences:
- `docs/implementation_tracker.md` - Strategic (for engineering leadership) - **KEEP <100 LINES**
- `docs/development_guide.md` - Architectural (for developers) - **KEEP <200 LINES**
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

### 4.5. Update Development Guide (If Architectural Changes)
**File**: `docs/development_guide.md`

**Review the session and update the guide if ANY of these occurred:**

| Change Type | What to Update |
|-------------|----------------|
| New dependency/library added | Tech Stack section |
| New API endpoint created | Key Patterns → API Routes |
| Database table added/modified | Key Patterns → Database Tables |
| New environment variable | Environment Variables section |
| Authentication flow changed | Key Patterns → Authentication |
| New coding pattern established | Key Patterns section |
| Directory structure changed | Directory Structure section |
| Deployment process changed | Deployment section |
| New external service integrated | Tech Stack + Architecture |

**How to Update:**

1. **Read the current guide first**:
   ```bash
   cat docs/development_guide.md
   ```

2. **Update existing sections** (don't just append):
   - Find the relevant section
   - Modify/add content in place
   - Keep entries concise (1-2 lines each)

3. **Add new sections only if needed** (rare)

4. **Update the "Last Updated" date** at the top

**What to Write (Concise Essentials Only):**

```markdown
# GOOD - Concise, scannable
| `STRIPE_SECRET_KEY` | Payment processing |

# BAD - Too verbose
| `STRIPE_SECRET_KEY` | This is the secret key for Stripe payment
processing. You can get it from the Stripe dashboard under
Developers > API Keys. Make sure to use the test key for development. |
```

```markdown
# GOOD - Brief pattern
### Authentication
- Firebase Auth handles Google OAuth in browser
- JWT token verified on backend via Firebase public keys

# BAD - Tutorial-style
### Authentication
First, the user clicks the login button. This triggers Firebase Auth
which opens a popup for Google OAuth. The user selects their Google
account and authorizes the app. Firebase then returns a JWT token...
```

**What Does NOT Go in Development Guide:**
- Bug fixes (unless they reveal a new pattern)
- Progress updates (→ tracker)
- Task details (→ daily log)
- Decision rationale (→ archive)
- Version history (→ CHANGELOG.md)
- Full API documentation (→ docs/detailed/)

**Example Session Changes → Guide Updates:**

| What You Did | Guide Update |
|--------------|--------------|
| Added Stripe payments | Tech Stack: add `Stripe (Hosted Checkout)` |
| Created `/api/webhooks/stripe` | Key Patterns → API Routes: add row |
| Added `STRIPE_SECRET_KEY` | Environment Variables: add row |
| Changed auth to use sessions | Key Patterns → Authentication: modify |

---

### 5. Implementation Tracker Size Check
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

### 5.5. Development Guide Size Check
**Run**:
```bash
wc -l docs/development_guide.md
```

**If over 200 lines**, auto-trim:

1. **Create detailed directory if needed**:
   ```bash
   mkdir -p docs/detailed
   ```

2. **Identify sections to extract** (move verbose content):
   - Changelog / version history sections
   - Detailed API documentation
   - Full database schema details
   - Extended troubleshooting guides
   - Feature deep-dives and tutorials

3. **Append extracted content to full guide**:
   - Read `docs/detailed/full_development_guide.md` (create if missing)
   - Add timestamp header: `## Extracted on YYYY-MM-DD`
   - Append extracted sections below the header

4. **Remove extracted sections from main guide**

5. **Verify main guide is now ≤200 lines**

6. **Report**:
   ```
   ✂️ Development guide trimmed: X → Y lines
   Extracted sections moved to: docs/detailed/full_development_guide.md
   ```

**What to KEEP in main guide** (essential architectural context):
- Project overview (name, version, business model)
- Tech stack table
- Architecture diagram
- Directory structure
- Key patterns (auth, API routes, database tables)
- Quick start commands
- Deployment commands
- Environment variables summary
- Brief troubleshooting (1-liners only)

**What to EXTRACT** (detailed reference, not needed on session start):
- Changelogs, version history, release notes
- Full API endpoint documentation
- Complete database schema with field descriptions
- Extended troubleshooting with examples
- Feature implementation details
- Tutorials and walkthroughs

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

### Success Message (No Architectural Changes)
```markdown
**Session State Saved**

**Updated Files**:
- docs/implementation_tracker.md (X lines)
- docs/development_guide.md (Y lines) - no changes
- docs/logs/YYYY-MM-DD.md

**Summary**:
- [X] tasks completed
- [Y] files modified

**Context Status**: ~X% ([status])

Context preserved. Use `/restore` to reload anytime.
```

### With Development Guide Updates
```markdown
**Session State Saved**

**Updated Files**:
- docs/implementation_tracker.md (85 lines)
- docs/development_guide.md (192 lines) 📝 updated
- docs/logs/YYYY-MM-DD.md

**Development Guide Updates**:
- Tech Stack: Added Redis for caching
- Environment Variables: Added REDIS_URL
- Key Patterns: Added caching pattern

**Summary**:
- [X] tasks completed
- [Y] files modified

**Context Status**: ~X% ([status])
```

### With Size Warning (Tracker)
```markdown
**Session State Saved**

**Updated Files**:
- docs/implementation_tracker.md (125 lines) ⚠️
- docs/development_guide.md (180 lines)
- docs/logs/YYYY-MM-DD.md

**Summary**:
- [X] tasks completed

**Context Status**: ~X%

⚠️ Implementation tracker is over 100 lines. Run `/archive-week` to keep it slim.
```

### With Auto-Trim (Development Guide)
```markdown
**Session State Saved**

**Updated Files**:
- docs/implementation_tracker.md (85 lines)
- docs/development_guide.md (195 lines) ✂️ trimmed from 450
- docs/logs/YYYY-MM-DD.md

**Summary**:
- [X] tasks completed
- [Y] files modified

**Context Status**: ~X%

✂️ Development guide auto-trimmed. Extracted sections moved to:
   docs/detailed/full_development_guide.md
```

---

## File Purposes Reminder

| File | Audience | Auto-Loaded | Target Size |
|------|----------|-------------|-------------|
| `implementation_tracker.md` | Leadership | Yes | <100 lines |
| `development_guide.md` | Developers | Yes | <200 lines |
| `docs/logs/YYYY-MM-DD.md` | Team Lead | Yes (most recent) | <100 lines |
| `implementation_archive.md` | Reference | No | Unlimited |
| `docs/detailed/full_development_guide.md` | Reference | No | Unlimited |

---

## Best Practices

### Implementation Tracker (Strategic)
- Keep under 100 lines
- Focus on current week only
- Brief status updates
- Archive completed weeks

### Development Guide (Architectural)
- Keep under 200 lines
- Focus on essentials: tech stack, architecture, key patterns
- Extract verbose sections to `docs/detailed/full_development_guide.md`
- Update only when architecture changes (not daily)
- No changelogs or version history (use CHANGELOG.md)

### Daily Log (Tactical)
- Be detailed - this is for resume context
- Include file:line references
- Capture current thinking/approach
- Note uncommitted changes

### Archive (Historical)
- Add decisions and bugs here
- Keep full history
- Never auto-loaded

### Full Development Guide (Reference)
- Lives in `docs/detailed/full_development_guide.md`
- Contains extracted verbose sections
- Organized by extraction date
- Never auto-loaded - only for reference

---

## After Saving State

### If 85%+ Context
After saving, if context is critical:
1. Confirm all context is saved
2. Compact conversation
3. Use `/restore` to reload with ~3K tokens

### Normal Context
Continue working. State is safely preserved in docs/.

