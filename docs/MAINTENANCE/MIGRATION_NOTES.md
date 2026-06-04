# Autonomous Workflow System — Migration to coaching-platform

**Date:** 2026-04-23  
**Status:** ✅ Complete

## Summary

The autonomous workflow system has been moved from `/Users/mac/Desktop/data/personal assistant/` to the coaching-platform project at `/Users/mac/Desktop/data/Taleemabad/coaching-platform/`.

All files are now project-local and integrated into the coaching-platform development workflow.

---

## What Moved

### Memory Files (5)
Moved to: `/Users/mac/Desktop/data/Taleemabad/coaching-platform/docs/memory/`
- `patterns.md` — dev patterns, Supabase gotchas, business rules
- `bugs.md` — bug root causes & prevention
- `qa-risks.md` — QA failure scenarios
- `review-findings.md` — code review anti-patterns
- `standup-history.md` — stuck priority tracking

### Documentation (2)
Moved to: `/Users/mac/Desktop/data/Taleemabad/coaching-platform/`
- `AUTONOMOUS_WORKFLOW_SYSTEM.md` — full architecture & design
- `WORKFLOW_QUICK_REFERENCE.md` — daily quick reference

### CLAUDE.md Integration
Updated: `/Users/mac/Desktop/data/Taleemabad/coaching-platform/CLAUDE.md`
- Added autonomous workflow system section at top
- Integrated routing table into project CLAUDE.md
- Added memory update protocol
- All paths now point to coaching-platform locations

---

## Global Skills Updated

All coaching skills at `~/.claude/skills/` now reference coaching-platform paths:

| Skill | Memory File Path |
|-------|-----------------|
| `/coaching-dev` | `coaching-platform/docs/memory/patterns.md` |
| `/coaching-bugfix` | `coaching-platform/docs/memory/bugs.md` |
| `/coaching-qa` | `coaching-platform/docs/memory/qa-risks.md` |
| `/coaching-review` | `coaching-platform/docs/memory/review-findings.md` |

**Result:** When working in coaching-platform, all skills read/write from project-local memory. When working in other projects, skills still function (with their own memory if needed).

---

## How to Use

### In coaching-platform workspace:
```
1. Open /Users/mac/Desktop/data/Taleemabad/coaching-platform
2. Session auto-runs: reads CLAUDE.md + memory files
3. Use trigger words: "implement", "fix bug", "test this", "review this"
4. Memory auto-updates after workflows complete
```

### Trigger Words (from CLAUDE.md routing table):
```
/coaching-dev         — Feature development
/coaching-bugfix      — Bug fixing
/coaching-qa          — QA testing
/coaching-review      — Code review
```

---

## Files Still in personal assistant

**Kept for reference (non-coaching work):**
- `/Users/mac/Desktop/data/personal assistant/CLAUDE.md` — global workspace routing
- `/Users/mac/Desktop/data/personal assistant/memory/` — personal assistant memory (if any)
- `/Users/mac/Desktop/data/personal assistant/AUTONOMOUS_WORKFLOW_SYSTEM.md` (copy) — still there as backup
- `/Users/mac/Desktop/data/personal assistant/WORKFLOW_QUICK_REFERENCE.md` (copy) — still there as backup

These are not used for coaching-platform work, only as archives.

---

## Key Integration Points

### 1. CLAUDE.md in coaching-platform
- Lines 3–23: Autonomous workflow system section
- Lines 25–35: Routing table
- Lines 37–47: Memory update protocol

### 2. Memory files are project-local
- Kept in `docs/memory/` alongside other coaching docs
- Each workflow reads from coaching-platform paths
- No cross-project contamination

### 3. Global skills point to coaching-platform
When running `/coaching-dev` (or any coaching skill) in this workspace, the skill:
1. Reads from `docs/memory/patterns.md` (coaching-platform)
2. Executes work in `/src` (coaching-platform)
3. Writes back to `docs/memory/patterns.md` (coaching-platform)

---

## Testing the System

To verify everything works:

1. **Navigate to coaching-platform:**
   ```
   cd /Users/mac/Desktop/data/Taleemabad/coaching-platform
   ```

2. **Open in Claude Code:** (will auto-read new CLAUDE.md)

3. **Test routing:**
   - Say "implement a new feature" → should invoke `/coaching-dev`
   - Say "fix bug: X" → should invoke `/coaching-bugfix`
   - Say "test the baseline flow" → should invoke `/coaching-qa`
   - Say "review the quiz component" → should invoke `/coaching-review`

4. **Check memory:** After any workflow, verify memory file was updated (if something new was learned)

---

## No Code Changes Required

✅ No Python/TypeScript/React changes
✅ No dependency updates
✅ No .env changes
✅ No migrations required

Only configuration (CLAUDE.md + memory paths) moved. The system integrates with existing coaching-platform codebase as-is.

---

## Next Steps

1. **Next session:** Open coaching-platform workspace (not personal assistant)
2. **Use trigger words** to invoke workflows
3. **Memory will grow** — first 10–15 workflows seed all memory files
4. **Promote patterns** when you see one 3+ times: tell me "promote [pattern name]"

The system is live and ready to use in the coaching-platform workspace.
