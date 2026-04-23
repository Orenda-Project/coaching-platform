# Autonomous Workflow System — Implementation Complete

**Date:** 2026-04-23  
**Status:** ✅ Live and active

---

## What Was Built

A deterministic, self-improving workflow routing system for Jalal's coaching platform workspace. The system:

- **Routes deterministically** — no NL guessing, explicit trigger words in CLAUDE.md
- **Chains intelligently** — dev → QA → review, all with user confirmation gates
- **Learns continuously** — memory is updated with new patterns, bugs, QA risks, and review findings
- **Stays maintainable** — memory is concise (≤50 entries per file), no transcripts, only distilled learnings

---

## Files Changed / Created

### New Memory Files (5)
```
memory/patterns.md          — Dev patterns, Supabase gotchas, business rules
memory/bugs.md              — Distilled bug root causes & fix patterns
memory/qa-risks.md          — High-risk scenarios, recurring failures
memory/review-findings.md   — Recurring code review anti-patterns
memory/standup-history.md   — Stuck priorities (3+ days only)
```

### Updated Files (7)
```
CLAUDE.md                        — Full router + chaining + memory protocol (110 lines)
MEMORY.md                        — Added 5 new memory file pointers
skills/daily-standup/SKILL.md    — Added memory priming + write steps
~/.claude/skills/coaching-dev/SKILL.md       — Added memory read + write
~/.claude/skills/coaching-bugfix/SKILL.md    — Added memory read + write
~/.claude/skills/coaching-qa/SKILL.md        — Added memory read + write
~/.claude/skills/coaching-review/SKILL.md    — Added memory read + write
```

---

## How It Works

### 1. Session Start (automatic)
```
CLAUDE.md rules execute:
  1. Read daily-standup SKILL
  2. Read MEMORY.md + all indexed files
  3. Read STANDUP.md + domain logs
  4. Greet Jalal with status snapshot
  5. Ask what to focus on
```

### 2. Routing (deterministic dispatch)
When Jalal sends a message, CLAUDE.md checks triggers in order:

| Trigger | Workflow |
|---------|----------|
| `/daily-standup` OR "standup" | Daily Standup |
| `/coaching-dev` OR "implement/build/add feature" | Feature Dev |
| `/coaching-bugfix` OR "fix bug/broken/not working" | Bug Fix |
| `/coaching-qa` OR "test this/QA/verify" | QA |
| `/coaching-review` OR "review this/code review" | Code Review |
| "draft/slack/email/PR" | Comms Helper |
| Everything else | Work Assistant |

Ambiguity rule: more specific trigger wins. Genuinely ambiguous → ask one question.

### 3. Workflow Execution
Each skill (dev/bugfix/qa/review) reads its own memory file at the top:
- `coaching-dev` reads `memory/patterns.md`
- `coaching-bugfix` reads `memory/bugs.md`
- `coaching-qa` reads `memory/qa-risks.md`
- `coaching-review` reads `memory/review-findings.md`

### 4. Chaining (explicit gates)
After workflow completes, user is prompted:
- Dev finishes → "Run QA? (yes/no)" → if yes, run QA → "Code review? (yes/no)" → if yes, run review
- Bugfix finishes → "Run QA to verify? (yes/no)" → if yes, run QA → "Code review? (yes/no)" → if yes, run review
- QA & Review: no chaining, end with memory update

### 5. Memory Update (end-of-workflow)
Each skill appends to its memory file ONLY if something new was learned:
- New pattern? → add to `patterns.md` (≤5 bullets)
- New bug category? → add to `bugs.md`
- New QA failure scenario? → add to `qa-risks.md`
- New anti-pattern? → add to `review-findings.md`

Never write: raw code, transcripts, full error stacks. Save: pattern/rule/why only.

---

## Key Design Decisions

### 1. Deterministic Routing Over NL Matching
**Why:** Claude's NL interpretation varies with context. A trigger table is consistent, auditable, predictable.

### 2. Chaining With Confirmation, Not Auto
**Why:** Auto-chaining can create "noisy" session flows (dev → QA → review with no user choice). One confirmation question per step = user stays in control.

### 3. Memory Write Only On New Learning
**Why:** Not every session discovers something new. Writing empty sessions pollutes memory. Only new ≠ noisy.

### 4. Skill Promotion Threshold: 3 Occurrences
**Why:** One occurrence = anomaly. Two = coincidence. Three = pattern. After 3x with consistent results, promote to permanent skill rule.

### 5. Stuck-Item Tracking (3+ Days Only)
**Why:** Priorities naturally carry over. Tracking only "stuck 3+ days" flags true blockers, not routine carry-overs.

---

## Routing Logic (Decision Tree)

```
Message received from Jalal
    │
    ├─ Exact match: /daily-standup, /coaching-dev, /coaching-bugfix, /coaching-qa, /coaching-review?
    │       → invoke matched skill (highest priority)
    │
    ├─ Contains trigger word(s)?
    │       → find most specific match
    │       → if BUGFIX + REVIEW both match: prefer BUGFIX
    │       → if two equally specific: ask "Which is it?"
    │       → invoke skill
    │
    └─ No match found?
            → invoke work-assistant agent (fallback)
```

---

## Memory Strategy

### Write Rules
- ✅ New learning (pattern, bug type, QA risk, anti-pattern)
- ✅ Unexpected behavior or non-obvious rule
- ❌ Raw code or transcripts
- ❌ Full error stacks or full logs
- ❌ Duplicates (check first, update in place if similar exists)

### Cleanup Rules
- When a file reaches 40+ entries: consolidate duplicates before adding new ones
- When an entry is unused for 1 month: mark `[STALE]`, remove on next cleanup
- Skill promotion: when pattern appears 3+ times → move to skill, remove from memory

### Read Rules
- Daily standup primes all workflows by reading patterns + bugs + qa-risks
- Each skill reads its own memory file (per workflow type)

---

## Improvement Strategy

### Skill Promotion (automatic upgrade)
When same pattern appears in memory 3+ times:
1. Promote from memory into SKILL.md as permanent rule
2. Remove from memory (it's now codified)
3. Note in skill file: `# Promoted from memory: 2026-04-XX`

**Example:** If "Supabase upsert" appears in bugs.md 3+ times, move it to `coaching-bugfix/SKILL.md` as a core check.

### Workflow Promotion (chaining becomes default)
When dev → QA → review chain is run 5+ times with zero user rejections:
1. Update CLAUDE.md: make chaining the default (still with one confirm)
2. Note in CLAUDE.md: `# Default chaining enabled: 2026-04-XX`

### Memory Demotion
If entry unused for 1 month:
1. Mark as `[STALE]`
2. Remove on next file cleanup (when hits 40+ entries)

---

## Guarantees & Guardrails

✅ **Memory will not become noisy** — write-only-when-new policy + deduplication  
✅ **Routing will be consistent** — explicit trigger table, no NL ambiguity  
✅ **Chaining is user-controlled** — one confirmation per step, never fully automatic  
✅ **Skills stay focused** — each reads only its own memory, no context pollution  
✅ **Global skills work in this workspace only** — memory paths are project-relative  

---

## Next Steps for Jalal

1. **Test the routing** in a new session:
   - Say "implement a new feature" → should trigger `/coaching-dev`
   - Say "fix bug: quiz unlock" → should trigger `/coaching-bugfix`
   - Say "run QA on the baseline flow" → should trigger `/coaching-qa`
   - Say "review the certificate module" → should trigger `/coaching-review`

2. **Let memory grow** — first 10–15 workflows will seed patterns, bugs, QA risks, findings

3. **Promote patterns** once you see a pattern 3+ times:
   - Move from memory into the relevant SKILL.md
   - Removes clutter, codifies wisdom

4. **Update CLAUDE.md trigger table** if you discover words that don't route correctly (keep table clean, don't add too many)

---

## File Locations Reference

**Local project memory:**
```
~/personal assistant/
├── CLAUDE.md (router)
├── MEMORY.md (index)
├── memory/
│   ├── patterns.md
│   ├── bugs.md
│   ├── qa-risks.md
│   ├── review-findings.md
│   └── standup-history.md
└── skills/daily-standup/SKILL.md
```

**Global coaching skills (shared across projects):**
```
~/.claude/skills/
├── coaching-dev/SKILL.md
├── coaching-bugfix/SKILL.md
├── coaching-qa/SKILL.md
└── coaching-review/SKILL.md
```

---

## Risks & Mitigations

| Risk | Mitigation |
|------|-----------|
| Trigger words too broad | Explicit preference ordering in CLAUDE.md routing table |
| Memory grows stale | Consolidation trigger at 40 entries, demotion at 1 month unused |
| Global skills affect other projects | Skills use project-relative paths (`memory/...`), only work in this workspace |
| Chaining becomes noisy | One confirmation question per chain step |
| MEMORY.md index bloats | Index capped at 8 entries (one per topic) |

---

## Summary

**You now have:**
- ✅ Deterministic routing (no NL guessing)
- ✅ Intelligent chaining (dev → QA → review with gates)
- ✅ Self-improving memory (new learnings only, concise, organized by topic)
- ✅ Low-noise guardrails (write-only-when-new, dedup, cleanup thresholds)
- ✅ Future-proof promotion policy (patterns → skill rules → permanent knowledge)

**Total implementation:** 12 files changed/created, ~550 lines of configuration (no code, pure markdown + skill definitions).

The system is ready. Next session, it will auto-run standup + routing. Start using trigger words to test routing.
