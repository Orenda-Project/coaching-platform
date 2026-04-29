---
description: Run a Phase-1-style codebase analysis. Inventories architecture, testing state, harness, PR workflow, and codebase health. Output: Project Analysis / Current Gaps / Risks. No code changes.
---

# /analyze

You are doing a Staff-Engineer-grade audit of this codebase. Read-only.

## What to inventory

1. **Architecture** — frontend stack, routing, state, auth, UI lib, backend (Supabase), deploy target. Identify monolith vs services.
2. **Testing state** — count of test files, framework, coverage measurement (or absence), what's untested. Be specific: name the load-bearing files with no tests.
3. **Test harness** — `vitest.config.ts`, `src/test/setup.ts`, fixtures, mocks, helpers. Note what exists vs what's missing.
4. **CI/CD** — `.github/workflows/`. Is the test job enabled? What gates exist on PRs?
5. **PR & dev workflow** — `.github/pull_request_template.md`, branch protection signals, `DEVELOPMENT_STANDARDS.md`.
6. **Codebase health** — biggest files (LOC), `tsconfig` strictness, `as any`/`as Record<string, unknown>` density, TODO/FIXME count, migration discipline.

## Required output (this format only)

```markdown
### Project Analysis
<numbered or bulleted findings, file paths cited>

### Current Gaps
<numbered list — concrete absences, not opinions>

### Risks
P0 — production-impacting:
  - <specific risk with file:line where possible>
P1 — velocity / quality erosion:
  - ...
P2 — operational:
  - ...
```

## Hard rules

- DO NOT propose solutions in `/analyze`. Save that for `/feature` or planning.
- Cite file paths and line numbers. "Some files are large" is not a finding; "src/pages/Assessment.tsx (737 LOC, 12 hooks) handles 3 distinct flows" is.
- Use the existing tooling: `find`, `grep`, `wc -l`. Do not run anything that mutates state.
- Read `docs/memory/{patterns,bugs,qa-risks,review-findings}.md` for prior learnings.
- This command is **safe and idempotent** — it only reads.
