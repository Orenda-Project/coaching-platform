---
description: Fix a bug using root-cause analysis and the mandatory SDLC workflow.
argument-hint: <bug description or error message>
---

# /fix $ARGUMENTS

Use the mandatory SDLC workflow from `.claude/rules/sdlc-workflow.md`.

Before editing files:

1. Reproduce or explain how to reproduce the issue.
2. Identify root cause.
3. Explain why it happened.
4. Explain fix approach.
5. Identify affected files.
6. Explain test coverage.
7. Explain prevention strategy.
8. Wait for approval before implementation unless the user explicitly asks to implement directly.

All work must be done in a feature branch. Create PR to staging. Never merge without user permission.

---

Fix this bug: **$ARGUMENTS**

## Pipeline (test-driven bug fix)

1. **Reproduce — test-engineer agent FIRST**
   - Read `docs/memory/bugs.md` (similar past categories)
   - Write a **failing** test that reproduces the bug
   - Confirm it fails: `npm run test`
   - The failing test IS the regression test — do not delete it after the fix

2. **Diagnose — feature-developer agent**
   - Read the failing test
   - Identify root cause (NOT just a symptom patch — see `docs/memory/review-findings.md`)
   - If the bug is in a business rule with no `src/domain/` extraction, EXTRACT first, then fix in the extracted module
   - If the bug is in a Supabase query with no `src/data/` extraction, EXTRACT first
   - Apply the minimal fix

3. **Verify — back to test-engineer**
   - The original failing test now passes: `npm run test`
   - Coverage is the same or higher: `npm run test:coverage`
   - If the bug exposed a new failure mode, append to `docs/memory/qa-risks.md` (≤5 bullets, novel only)
   - If it exposed a new bug category, append to `docs/memory/bugs.md` (Bug type / Root cause / Fix pattern / Prevention)

4. **Gate — pr-reviewer agent**
   - Apply the decision matrix
   - Special attention: was the fix the ROOT CAUSE or a symptom patch? If symptom-only, REQUEST CHANGES.

## Hard rules

- The failing test goes in BEFORE the fix. No exceptions. This is the regression bar.
- Do not delete the failing test after the fix — it is the regression test.
- Do not patch a symptom (e.g., adding a null-check around a value that should never be null) — find the root cause.
- A bug fix that touches `Assessment.tsx`, `Dashboard.tsx`, `ModuleQuiz.tsx`, or any of the 500+LOC pages is also an opportunity to extract one piece of logic to `src/domain/` — small migration, not a rewrite.

## Stop conditions

Stop and ask if:
- The fix would require changing a constant in `src/domain/thresholds.ts` (that's a product decision, not a bug fix)
- The fix would require a destructive migration
- Reproducing the bug requires production data access

## Wraps existing workflow

Supersedes `/coaching-bugfix` for this codebase. The existing skill is still callable; `/fix` adds the test-first discipline + four-agent gate on top.

Follow up with `/pr` to assemble the GitHub PR.
