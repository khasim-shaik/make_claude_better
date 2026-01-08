
---

# Context Management

## Slash Commands

| Command | Purpose |
|---------|---------|
| `/restore` | Load context from docs/ |
| `/save-state` | Save progress to docs/ |
| `/context-status` | Check token usage |

## Usage

1. **Start session**: Run `/restore` to load context
2. **During work**: Run `/context-status` periodically
3. **End session**: Run `/save-state` to save progress

## State Files

- `docs/implementation_tracker.md` - Project roadmap, progress
- `docs/development_guide.md` - Architecture, conventions
- `docs/logs/YYYY-MM-DD.md` - Daily work, where you left off

## Context Thresholds

- **0-70%**: Continue normally
- **70-85%**: Run `/context-status` more often
- **85%+**: Run `/save-state` then `/compact`
