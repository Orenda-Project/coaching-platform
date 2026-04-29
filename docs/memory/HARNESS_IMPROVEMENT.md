# Day-by-Day Harness Improvement

This is the operator doc for the postmortem loop. Read once; refer back when patterns surface.

## The loop

```
Task ends
   │
   ▼
/postmortem  ← user-triggered (intentionally not a Stop hook — too noisy)
   │
   ▼
postmortem agent reads:
   - the conversation transcript
   - docs/memory/patterns-log.jsonl  (signal frequency)
   - docs/memory/{patterns,bugs,qa-risks,review-findings}.md
   - .claude/agents/*.md
   │
   ▼
agent appends ONE JSON line to patterns-log.jsonl  ← only auto-write
   │
   ▼
agent proposes (≤1 per pattern):
   - Stage 1: append a memory bullet
   - Stage 2: add an agent rule
   - Stage 3: add a pr-reviewer decision-matrix row
   - Stage 4: write harness code (fixture / mock / lint rule)
   │
   ▼
user replies: apply P1 P3 / apply all / dismiss / defer
   │
   ▼
agent (or me) makes the edit, runs lint + tests, reports
```

## Promotion thresholds

A signal moves through 4 stages as evidence accumulates:

| Stage | Lives in | Promotion trigger |
|---|---|---|
| 0 — novel | `patterns-log.jsonl` | Always — every postmortem appends |
| 1 — bullet | `docs/memory/<area>.md` | Same signal seen **2+** times across distinct sessions |
| 2 — agent rule | `.claude/agents/<agent>.md` Hard rules | Seen **3+** times AND already a memory bullet |
| 3 — gate | `.claude/agents/pr-reviewer.md` decision matrix | Has deterministic detection (file:line check) AND already an agent rule |
| 4 — code | `src/test/`, lint rule, vitest config | Mechanically preventable (one-shot fix eliminates the class) |

**Always escalate the LOWEST-IMPACT change that addresses the pattern.** A memory bullet beats an agent rule beats a CI gate beats a code change. Only escalate when the previous stage hasn't worked (i.e. the pattern recurred *after* it was already in memory).

## What counts as a "signal"

The postmortem agent uses a fixed catalog of signals (see `.claude/agents/postmortem.md` for the full list). Examples:

- `s_typecheck_loop` — `npm run typecheck` ran 2+ times with errors
- `s_supabase_type_dance` — multiple `as never` / `// @ts-expect-error` added in one task (indicates `types.ts` is stale)
- `s_business_threshold_inline` — a literal threshold (60/70/80/90/30/3) was found inline in JSX or a hook
- `s_stacked_pr_base_drift` — a stacked PR's base became invalid because the parent merged
- `s_user_correction` — user explicitly told the agent to stop / change direction
- `s_user_validation` — user explicitly approved a non-obvious choice

The list is long deliberately. Each signal is one bit of "I noticed this happened" — many signals fire in a busy session, that's fine.

## Reading the log

The log is append-only JSONL. One entry per session. To answer "have we seen X N times?":

```bash
grep -c '"s_typecheck_loop"' docs/memory/patterns-log.jsonl
```

To see the most recent N entries pretty-printed:

```bash
tail -n 5 docs/memory/patterns-log.jsonl | jq .
```

To find all sessions that touched a specific file:

```bash
grep '"src/pages/ModuleQuiz.tsx"' docs/memory/patterns-log.jsonl | jq -r '.task_summary'
```

## What happens to dismissed proposals

- `dismiss` — proposal disappears. The log entry remains. If the signal recurs, the proposal will surface again with a higher count behind it (which is informative).
- `defer` — proposal is appended to `docs/memory/proposed-harness-changes.md` with the date. The next postmortem reads that file and re-surfaces.

## What CANNOT be auto-done

The postmortem agent has exactly ONE write permission: append to `patterns-log.jsonl`. Every other change — memory bullet, agent rule, decision-matrix row, harness code — requires you to type `apply P1` or equivalent. This is intentional. Memory files and agent rules influence every subsequent task; auto-edits to them would compound mistakes silently.

## When NOT to run /postmortem

- Read-only sessions (`/analyze`, simple questions).
- Sessions <5 min of real work.
- When you've explicitly told the agent "skip postmortem."

## Bootstrap state (2026-04-29)

The log was seeded with 3 real entries from this session's work (PR #44 / #46 / #47). All 10 signals captured already have a count of ≥1, with `s_user_validation` at 2. The first real `/postmortem` invocation in the next session will be against this seed data.
