# QA Risk Patterns

Last updated: 2026-04-23

## High-Risk Scenarios (always test these)
- **Fresh user signup → baseline redirect** — has broken before (baseline_completed not written)
- **Persona assignment at boundary scores** — exactly 60%, 70%, 75% (off-by-one errors)
- **Content gate: video at 89% completion** — below 90% gate, quiz should NOT unlock yet
- **Quiz retry: passed=true preservation** — retaking quiz must keep best score, passed flag unchanged
- **Endline gate enforcement** — attempting endline before all modules passed must fail
- **Certificate duplicate on retry** — retaking endline must NOT create duplicate certificate row
- **Anti-cheat: tab switch mid-quiz** — tab switch during quiz must be flagged correctly
- **Admin route access control** — non-admin user must be blocked from admin routes

## Medium-Risk (test when relevant)
- Mobile responsiveness on quiz screen (touch, keyboard, viewport)
- Refresh mid-quiz (progress saved? quiz state preserved?)
- Empty question bank (graceful error, not crash)
- Network failure during quiz submit (toast shown, retry available)
- Module unlock cascade (passing Module N unlocks Module N+1 correctly)

## Regression: Persona E Constraint Violation (2026-04-30)
- **profiles_persona_check** — production DB constraint only allowed ('A','B','C','D'); writing 'E' for score < 60% crashes baseline submission with a check-constraint violation
- Fix requires: `ALTER TABLE profiles DROP CONSTRAINT profiles_persona_check; ALTER TABLE profiles ADD CONSTRAINT profiles_persona_check CHECK (persona IN ('A','B','C','D','E'));`
- Regression test: `src/domain/persona-e-constraint.test.ts` — intentionally fails until migration applied; test title: "succeeds when persona is E (fails on old DB with missing E in constraint)"

## Regression: Baseline Training RLS Violation (2026-04-30)
- **Root cause:** Assessment.tsx::saveAssessmentProgress() does SELECT then INSERT on `trainings` when the seeded row is missing; coach role is blocked by RLS (error 42501) on INSERT
- **Trigger:** migration 20260505000001 not applied to target environment — "Coach Baseline Assessment" row absent
- **Silent failure:** INSERT denied, function returns early, baseline progress is never written; no toast/error shown to coach
- **Regression test:** `src/data/baseline-training-rls.test.ts` — all 4 tests pass; the test named "fails with RLS 42501 when migration not applied" models the exact production failure path
- **Fix:** apply migration 20260505000001 to production; the seeded row means the INSERT branch is never reached

## Edge Cases Rarely Tested
- User with no modules assigned (dashboard shows "no modules")
- Persona score exactly at threshold (75.0 = A, 74.9 = B)
- Content in multiple formats (video, slides, scenario) all gate correctly
- Endline retake after passing (certificate reissue without duplicate)
