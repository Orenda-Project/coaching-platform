# Workflow Routing — Quick Reference

## Trigger Words (use any of these)

| Task | Trigger Word | Skill |
|------|-------------|-------|
| **Daily Check-in** | "good morning" / "standup" / `/daily-standup` | Daily Standup |
| **Build Feature** | "implement" / "build feature" / "add feature" / `/coaching-dev` | Feature Dev |
| **Fix Bug** | "fix bug" / "broken" / "bug:" / `/coaching-bugfix` | Bug Fix |
| **Test Code** | "test this" / "QA" / "run tests" / "verify" / `/coaching-qa` | QA |
| **Review Code** | "review this" / "review my code" / "code review" / `/coaching-review` | Code Review |
| **Write** | "draft" / "slack" / "email" / "PR description" | Comms Helper |
| **Everything Else** | (fallback) | Work Assistant |

---

## What Each Workflow Does

### 1. Daily Standup
- Reads all context (memory, STANDUP.md, domain logs)
- Shows your priorities, carry-overs, unread emails, recent updates
- Asks what you want to focus on

### 2. Feature Dev (/coaching-dev)
- Reads patterns.md
- You implement the feature
- At end: asks "Run QA?" → if yes → asks "Code review?" → if yes → review runs

### 3. Bug Fix (/coaching-bugfix)
- Reads bugs.md (shows past bug categories)
- You reproduce & fix the bug
- At end: asks "Run QA to verify?" → if yes → asks "Code review?" → if yes → review runs

### 4. QA (/coaching-qa)
- Reads qa-risks.md (shows what breaks easily)
- You run the full test checklist
- At end: memory updated with any new failure scenarios found

### 5. Code Review (/coaching-review)
- Reads review-findings.md (shows past anti-patterns)
- You review the code against the checklist
- At end: memory updated with any new anti-patterns found

---

## Memory That Updates Automatically

| Workflow | Memory File | Saves |
|----------|-------------|-------|
| Feature Dev | patterns.md | New Supabase patterns, gotchas, non-obvious rules |
| Bug Fix | bugs.md | New bug category, root cause, prevention |
| QA | qa-risks.md | New high-risk scenario, what can break |
| Code Review | review-findings.md | New anti-pattern, why it's bad |
| Daily Standup | standup-history.md | Only if priority stuck 3+ days |

**Rule:** Only writes if something NEW. Never duplicates. Never stores code or transcripts.

---

## Example Session Flow

```
Session start
  → Auto: daily standup runs
  → You: "implement module 2 content"
  → Routes to: /coaching-dev
  → Dev reads patterns.md
  → You: build the feature
  → End of dev:
     → "Run QA? (yes/no)"
     → You: "yes"
     → QA runs (reads qa-risks.md)
     → QA finds no new failures
     → "Code review? (yes/no)"
     → You: "yes"
     → Review runs (reads review-findings.md)
     → Review finds 1 anti-pattern (missing auth check)
     → Memory updated: added new anti-pattern to review-findings.md
     → Session ends, logs updated
```

---

## If Memory Gets Too Big

When a memory file reaches 40+ entries:
1. I consolidate duplicates automatically
2. Remove stale entries (unused 1+ month)
3. Then add new ones

**You don't need to do anything.** It's automatic.

---

## If You Find a Trigger That Doesn't Work

If you say "implement" but it routes to the wrong skill → tell me. I'll update the routing table in CLAUDE.md.

Keep the table clean. Don't add more triggers unless needed.

---

## Your Memory Files (Read Any Time)

- `memory/patterns.md` — Supabase tips, business rules, gotchas
- `memory/bugs.md` — Past bug categories you've hit
- `memory/qa-risks.md` — Scenarios that break easily
- `memory/review-findings.md` — Common code issues
- `memory/standup-history.md` — Priorities stuck 3+ days

---

## To Promote a Pattern to Permanent Skill

When you see a pattern 3+ times:
1. Tell me: "Promote [pattern name]"
2. I move it from memory into the SKILL.md file
3. It becomes a permanent rule in the workflow

Example:
- "Promote: Supabase upsert for progress tables" → it moves to coaching-bugfix SKILL.md
- Next time a bug is fixed, that rule is checked automatically

---

## That's It

1. Use trigger words naturally
2. Let memory grow
3. Tell me when to promote patterns
4. Rest happens automatically

No manual memory updates needed. The system learns as you work.
