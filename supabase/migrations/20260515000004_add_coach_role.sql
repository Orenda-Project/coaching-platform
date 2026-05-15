-- ─────────────────────────────────────────────────────────────────────────────
-- Add coach role support for vacation engagement
-- Allows coaches to access all modules without persona-based filtering
-- Rollback scheduled: 2026-06-15 (one month)
-- ─────────────────────────────────────────────────────────────────────────────

-- 1. Extend app_role enum to include 'coach'
ALTER TYPE public.app_role ADD VALUE 'coach' BEFORE 'user';

-- 2. No other schema changes needed — coaches use the same trainings/progress tables
-- They are treated like Persona E (see all modules, unlimited quiz attempts)

-- Migration notes:
-- - Coaches are identified by having 'coach' role in user_roles table
-- - Frontend Dashboard.tsx filters logic: if profile.role == 'coach', show all modules
-- - Baseline/Endline assessments work normally for coaches
-- - Quiz allows unlimited attempts (like Persona E)
