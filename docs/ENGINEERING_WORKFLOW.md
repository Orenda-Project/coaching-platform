# Engineering Workflow — Coaching Platform

This document is the entry point for the **four-agent engineering workflow** that landed in this repo. It is a working system, not a proposal.

## TL;DR

- Four agents in `.claude/agents/` (feature-developer, test-engineer, test-harness-engineer, pr-reviewer).
- Five slash commands in `.claude/commands/` (`/analyze`, `/feature`, `/fix`, `/review`, `/pr`).
- Domain logic lives in `src/domain/`; data access lives in `src/data/`. Pages stay thin.
- Test harness in `src/test/` (fixtures, mocks, helpers). Vitest runs unit/hook by default; integration runs separately.
- CI gate in `.github/workflows/test.yml` runs lint + typecheck (non-blocking) + tests on every PR.

## The four agents

| Agent | Role | When |
|---|---|---|
| **feature-developer** | Builds the feature; extracts business rules to `src/domain/`, queries to `src/data/`. | Every feature, every fix |
| **test-engineer** | Writes unit / hook / integration tests. Pins boundaries. | Immediately after feature-developer |
| **test-harness-engineer** | Owns `src/test/` infrastructure (fixtures, mocks, config). | On demand, when test-engineer is blocked |
| **pr-reviewer** | Deterministic gate before human review. APPROVE / REQUEST CHANGES / REJECT. | Before pushing / before opening PR |

Full specs in `.claude/agents/<name>.md`.

## The five slash commands

| Command | What it does |
|---|---|
| `/analyze` | Read-only audit. Returns Project Analysis / Current Gaps / Risks. |
| `/feature <description>` | Full pipeline: feature-developer → test-engineer → harness (on demand) → pr-reviewer. |
| `/fix <bug description>` | Test-first bug fix. Failing test BEFORE the fix. Coverage non-regression. |
| `/review` | Run pr-reviewer agent on the current branch's diff. |
| `/pr [title]` | Assemble production-ready PR. Lint + typecheck + tests + reviewer gate, then `gh pr create`. |

These wrap the existing `/coaching-dev`, `/coaching-bugfix`, `/coaching-qa`, `/coaching-review` skills — they don't replace them.

## Hard architectural rules

1. **Thresholds in `src/domain/thresholds.ts`.** Never inline numbers like 60 / 70 / 80 / 90 / 30 / 3 in JSX or hooks. Import the constant.
2. **Business logic in `src/domain/<area>.ts`.** Pure functions only. No I/O, no React, no Supabase.
3. **Supabase queries in `src/data/<area>.ts`.** Pages and hooks NEVER call `supabase.from(...)` directly.
4. **Migrations are append-only.** New file with strictly-monotonic timestamp. Never edit one that's been applied to staging or prod.
5. **Every new table has RLS policies in the same migration.**
6. **No service-role key on the client.** Ever.

The pr-reviewer agent enforces all of these.

## Test tiers

| Tier | Location | Speed | Run with |
|---|---|---|---|
| Unit | `src/domain/<area>.test.ts` | <50ms | `npm run test` |
| Hook/Component | `src/hooks/<name>.test.ts`, `src/components/<name>.test.tsx` | <500ms | `npm run test` |
| Integration | `src/data/<area>.integration.test.ts` | <2s | `npm run test:integration` (requires `supabase start`) |

## Test harness

`src/test/` provides:
- **Fixtures:** `makeUser`, `makeProfile`, `makeModule`, `makeModule1`, `makeQuestion`, `makeOption` — import from `@/test/fixtures`. Defaults are the median real user (coach, persona B, baseline 72%); boundaries are explicit overrides.
- **Mocks:** `createSupabaseMock` (chainable, queue-based), `mockUseAuth` + `buildAuthModuleMock`. Import from `@/test/mocks/*`.
- **Helpers:** `renderWithProviders` (QueryClient + MemoryRouter wrapper). Import from `@/test/helpers/render`.

Reuse these. Do NOT invent local mocks per file. If something is missing, invoke the **test-harness-engineer** agent.

## Coverage ratchet

1. **Live thresholds (in `vitest.config.ts`):**
   - `lines: 0.12` / `statements: 0.12` / `functions: 4.17` / `branches: 27.75`
   - Floor = first measured baseline (2026-04-29) minus 1% slack.
2. **CI enforces:** `npm run test:coverage` fails the build if any threshold is breached. See `.github/workflows/test.yml`.
3. **Every PR that raises coverage tightens the floor in the same commit.** Coverage only goes up — see `.claude/agents/pr-reviewer.md` Rule 9.
4. **Why so low?** The codebase had ~0% coverage at adoption. Real ratchet velocity comes from `/feature` and `/fix` enforcing test discipline on new code; the floor rises quickly as features get touched.

## CI gate

`.github/workflows/test.yml` runs on every PR to `main` or `staging`:
- `npm run lint` (blocking)
- `npm run typecheck` (NON-blocking initially — there are 22 pre-existing errors in legacy files; ratchet to blocking once cleaned)
- `npm run test` (blocking)
- `npm run test:coverage` (reports only; threshold not yet enforced)

`.github/workflows/deploy.yml` is **untouched**. Deploys still happen on push to `staging` / `main`. The test gate is orthogonal.

## Example: adding a feature with the pipeline

```
You: /feature add support for module retry tokens (admin-issued, one per coach per module)

→ feature-developer:
   - reads patterns.md
   - plan note: 1 new table, 1 new RLS policy, 1 new domain rule (canRetryWithToken),
     1 new data function (issueRetryToken, consumeRetryToken),
     1 admin UI in AdminModules.tsx
   - migration: 20260430000001_add_retry_tokens.sql with RLS
   - src/domain/retry-tokens.ts (canRetryWithToken pure fn)
   - src/data/retry-tokens.ts (issue, consume)
   - AdminModules.tsx — orchestration only
   - hand-off note for test-engineer

→ test-engineer:
   - reads qa-risks.md
   - src/domain/retry-tokens.test.ts (boundaries: 0 tokens / 1 token / token consumed)
   - src/data/retry-tokens.integration.test.ts (RLS denial: non-admin cannot issue)
   - hook test for new admin button

→ pr-reviewer:
   - all gates pass
   - APPROVE
   - memory update: none

You: /pr "feat(admin): module retry tokens"
   → branch pushed, PR opened against staging, reviewers tagged
```

## Day-by-day improvement (the postmortem loop)

Every non-trivial task ends with `/postmortem`. The agent:

1. Reads the conversation transcript and identifies which **signals** fired (typecheck loop? repeated edits? user correction? missing fixture?).
2. Appends ONE structured JSON line to `docs/memory/patterns-log.jsonl`.
3. **Proposes** harness improvements when a signal recurs across sessions:
   - 2+ occurrences → propose a `docs/memory/<area>.md` bullet
   - 3+ occurrences AND already a memory bullet → propose an agent rule in `.claude/agents/<agent>.md`
   - Has deterministic detection AND already an agent rule → propose a `pr-reviewer.md` decision-matrix row
   - Mechanically preventable → propose a harness code change
4. Waits for the user to `apply P1`, `apply all`, `dismiss`, or `defer`.

**The postmortem agent is proposal-only.** It writes only to `patterns-log.jsonl`. Every other change requires explicit approval — agent files and memory files compound across every future session, so auto-edits would compound mistakes silently.

Operator doc: [`docs/memory/HARNESS_IMPROVEMENT.md`](memory/HARNESS_IMPROVEMENT.md).

## What didn't change

- React + TS + Vite + Supabase + Railway stack — untouched
- Routing, auth context, UI library — untouched
- Existing skill plugins (`/coaching-dev` etc.) — still callable
- `deploy.yml` — untouched
- `pull_request_template.md` — untouched
- All existing pages/components/hooks — untouched (one trivial extraction in `Assessment.tsx` to demonstrate the domain pattern; behavior preserved)

The system is incrementally adoptable. Use the agents and commands when you want them; the codebase still works without them.
