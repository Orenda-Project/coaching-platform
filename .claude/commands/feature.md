---
description: Develop a new feature using the mandatory SDLC workflow and four-agent pipeline.
argument-hint: <feature description>
---

# /feature $ARGUMENTS

Use the mandatory SDLC workflow from `.claude/rules/sdlc-workflow.md`.

Before editing files:

1. Analyze requirements.
2. Identify affected files.
3. Explain implementation plan.
4. Explain API, DB, security, deployment, and rollback impact.
5. Provide testing strategy.
6. Wait for approval before implementation unless the user explicitly asks to implement directly.

All work must be done in a feature branch. Create PR to staging. Never merge without user permission.

---

Run the full four-agent pipeline for: **$ARGUMENTS**

## Pipeline

1. **feature-developer agent**
   - Read `docs/memory/patterns.md`
   - Produce a plan note (files touched, business rules, RLS implications, edge cases)
   - Extract business logic to `src/domain/<area>.ts`
   - Extract Supabase queries to `src/data/<area>.ts`
   - Implement page/component changes (orchestration + JSX only)
   - Write migration if needed (with RLS policies)
   - Produce a hand-off note for test-engineer

2. **test-engineer agent**
   - Read `docs/memory/qa-risks.md`
   - Read the hand-off note
   - Write unit tests in `src/domain/<area>.test.ts` (boundary trios)
   - Write hook/component tests using fixtures + canonical Supabase mock
   - Write integration tests in `src/data/<area>.integration.test.ts` (RLS denial covered)
   - Run `npm run test`; if green, also run `npm run test:integration` (requires `supabase start`)

3. **test-harness-engineer agent** (invoked on demand only)
   - Triggered when test-engineer reports a missing fixture, mock, helper, or config
   - Adds the missing piece to `src/test/`
   - Verifies `npm run test` still green

4. **pr-reviewer agent**
   - Apply the decision matrix (see `.claude/agents/pr-reviewer.md`)
   - Verdict: APPROVE / REQUEST CHANGES / REJECT
   - Specific findings with file:line citations
   - Memory update suggestion for `docs/memory/review-findings.md`

## Sequencing rules

- feature-developer runs FIRST, always. No tests without code under test.
- test-engineer runs IN THE SAME SESSION as feature-developer (hand-off note must be in active context).
- test-harness-engineer is on-demand, not sequential — invoked when test-engineer is blocked.
- pr-reviewer runs LAST — automated gate before human review.

## Stop conditions

Stop and ask the user if:
- The feature requires an architectural pivot (extracting a whole page, changing the routing model, etc.)
- A migration would be destructive on production data
- A query genuinely cannot work under RLS
- A new third-party dependency is needed

## Wraps existing workflow

This command supersedes `/coaching-dev` for this codebase but does not delete it. The existing `/coaching-dev` skill is still callable; `/feature` adds the four-agent pipeline on top.

## Output

A PR-ready set of changes:
- Code (domain + data + UI + migration)
- Tests (unit + hook + integration)
- Hand-off note in commit message or PR description
- pr-reviewer verdict

Follow up with `/pr` to assemble the actual GitHub PR.
