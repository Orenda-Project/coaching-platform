# Bug Learnings

Last updated: 2026-04-23

## Format
- **Bug type**: [category]
- **Root cause**: [why it happened]
- **Fix pattern**: [how to fix]
- **Prevention**: [how to avoid next time]

## Known Categories

**Supabase schema cache mismatch**
- Symptom: PGRST204 "Could not find column X"
- Root cause: Code references new column before migration runs, or migration hadn't propagated
- Fix: Write + run migration first on staging + prod, wait 30s for cache, then deploy code
- Prevention: Always follow pattern — migration SQL before code that uses it

**RLS cross-user data leak**
- Symptom: Silent failure or unexpected empty `data`, no error returned
- Root cause: RLS policy too permissive or incorrect filtering (missing row-level check)
- Fix: Verify RLS policy in Supabase → check where clause filters by `auth.uid()` or user_id
- Prevention: Test RLS on each sensitive table, write test with different user

**Quiz threshold bug (70 vs 80)**
- Symptom: Quiz passes at 70% when it should require 80%
- Root cause: Hardcoded 70 in code instead of using threshold constant
- Fix: Use constant, check all quiz pass/fail logic
- Prevention: Define threshold constants at module level, never hardcode

**Baseline redirect loop**
- Symptom: Baseline → submit → redirect loops back to baseline instead of dashboard
- Root cause: `baseline_completed` not written correctly to profiles table (insert fails silently)
- Fix: Verify upsert after baseline submit — check return value, ensure row exists
- Prevention: Use upsert, not insert; verify success before redirecting

**Certificate duplicate on retake**
- Symptom: Running endline again creates duplicate certificate rows
- Root cause: Insert instead of upsert on certificates table
- Fix: Use unique constraint on (user_id, assignment_id), upsert on insert conflict
- Prevention: Always upsert for user progress-tracking tables

**Persona E constraint violation on baseline <60% — RESOLVED**
- Symptom: PATCH /profiles fails with error 23514 "violates check constraint 'profiles_persona_check'" when baseline score < 60%
- Root cause: Code sends persona='E' but production Supabase had old constraint (A-D only); migration 20260427000002 existed in code but was not auto-applied to production DB initially
- Fix applied: Migration 20260427000002_add_persona_e.sql was manually applied to production; constraint now allows 'E'
- Prevention: Database migrations should be auto-applied by CI/CD on deploy; if not, manually apply via Supabase SQL console immediately after code deploy that requires new schema

**Baseline training RLS violation (coach can't insert training) — NEEDS FIX**
- Symptom: POST /trainings fails with error 42501 "violates row-level security policy" after coach submits baseline
- Root cause: Code queries for "Coach Baseline Assessment" training (should be seeded by migration 20260505000001); if not found, tries to INSERT as fallback; INSERT fails because coach lacks admin role and RLS policy requires admin to insert trainings
- Root cause detail: Migration 20260505000001_add_baseline_endline_trainings.sql exists in code but was not applied to production Supabase
- Fix: Apply migration 20260505000001 to production via Supabase SQL console (see FIX_BASELINE_TRAINING_RLS.md)
- Prevention: Same as persona E — auto-apply migrations in CI/CD, or manually apply via Supabase before code deploy that depends on the schema
