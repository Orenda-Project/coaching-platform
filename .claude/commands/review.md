---
description: Run the pr-reviewer agent locally on the current branch's diff. Returns APPROVE / REQUEST CHANGES / REJECT with specific findings. Wraps the existing /coaching-review workflow.
---

# /review

Run a senior-engineer review of the current branch's changes.

## What runs

1. **Compute the diff:** `git diff main...HEAD` (or against the staging branch if that's the merge target).
2. **Invoke pr-reviewer agent** with:
   - The diff
   - The current state of the repo (read-only)
   - `docs/memory/review-findings.md`
3. **Apply the decision matrix** from `.claude/agents/pr-reviewer.md`.
4. **Output the verdict** in the canonical format:
   - APPROVE / REQUEST CHANGES / REJECT
   - Gate-by-gate checklist (✓ / ✗)
   - Specific findings with file:line citations
   - Memory update suggestion for `docs/memory/review-findings.md`

## When to run this

- BEFORE pushing to remote
- BEFORE opening a PR
- AFTER receiving feedback and re-pushing (re-runs the gate)

## What this is NOT

- Not a replacement for `@jalal.khan` and `@hammad.sarfraz`'s review
- Not a stylistic linter (Prettier / ESLint own that)
- Not an architectural decision-maker (`/analyze` does that)

## Hard rules

- The agent must NEVER REJECT for tech debt that pre-existed this PR. It only flags what THIS diff introduces or makes worse.
- The agent must cite file:line for every finding. "Tests are weak" is not acceptable; "src/hooks/useFoo.test.ts:42 only asserts `.toBeInTheDocument()`" is.
- If any REJECT condition fires, the verdict is REJECT — even if the rest of the PR is excellent.

## Wraps existing workflow

Supersedes `/coaching-review` for this codebase. The existing skill is still callable; `/review` invokes the deterministic-gate pr-reviewer agent on top.
