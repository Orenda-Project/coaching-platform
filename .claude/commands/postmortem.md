---
description: Run the postmortem agent on the just-completed task. Appends a structured entry to docs/memory/patterns-log.jsonl, proposes (never auto-applies) harness improvements when patterns recur. Designed to be the LAST thing you run before closing a session.
---

# /postmortem

Run reflection on what just happened. Capture pattern signals. Propose harness improvements when a signal recurs.

## What runs

1. Invoke the **postmortem agent** (`.claude/agents/postmortem.md`).
2. The agent:
   - Reads the conversation transcript and identifies which **signals** from its catalog fired this session
   - Reads `docs/memory/patterns-log.jsonl` to count how many times each signal has been seen across all logged sessions
   - Reads existing memory files (`docs/memory/{patterns,bugs,qa-risks,review-findings}.md`) and agent specs (`.claude/agents/*.md`) so it doesn't propose duplicates
   - **Appends** one structured JSON line to `patterns-log.jsonl` (the only auto-write)
   - **Proposes** harness improvements per the promotion thresholds:
     - Stage 1 (memory bullet) at signal seen 2+ times
     - Stage 2 (agent rule) at signal seen 3+ times AND already in memory
     - Stage 3 (pr-reviewer decision matrix) at deterministic detection + already an agent rule
     - Stage 4 (harness code) when mechanically preventable
   - Waits for the user's decision: `apply P1 P3`, `apply all`, `dismiss`, or `defer`

## When to run this

- **Default:** at the end of every non-trivial task — feature, fix, review, or substantive session.
- **Skip if:** the session was a read-only audit, a quick question, or was less than ~5 minutes of real work.
- **Always run after:** a task where you noticed yourself doing something repetitive, a typecheck/test/lint loop, a user correction, or a non-obvious user validation.

## What this command does NOT do

- It does not modify code, agent rules, the pr-reviewer decision matrix, vitest config, or any memory file other than `patterns-log.jsonl`. Those changes require explicit user approval.
- It does not block the session. If you don't want to run it, don't.
- It does not run automatically. There's no Stop hook (deliberate — too noisy for the value).

## Approving / dismissing proposals

After the agent shows the proposal block, reply:

- `apply P1` — apply just proposal P1
- `apply P1 P3` — apply specific proposals
- `apply all` — apply every proposal
- `dismiss` — drop the proposals; the log entry stays
- `defer` — write to `docs/memory/proposed-harness-changes.md` and re-surface next session

If approved, the agent (or me, the parent) makes the edits in the same session, runs `npm run lint && npm run test` to confirm nothing broke, and reports back.

## Output

A short, structured report:
```
## Postmortem
- 1 entry appended to docs/memory/patterns-log.jsonl
- Signals fired: [list]
- Proposals: [count, or "none — clean session"]

[proposal blocks here, or none]

Decision?
```
