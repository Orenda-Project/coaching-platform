-- =============================================================================
-- Create public.module_quiz_attempts — Forward Migration
-- Date: 2026-04-28
--
-- Purpose:
--   ModuleQuiz.tsx writes per-(user × module) quiz attempt records into a
--   table called `module_quiz_attempts`. The table was never created in
--   any environment, so the frontend gets a PGRST205 ("table not found")
--   on every load and submit.
--
-- This script:
--   1) Creates the table with the schema the frontend expects
--      (user_id, module_id, score, best_score, passed, attempt_count,
--       completed_at, created_at, updated_at).
--   2) Adds (user_id, module_id) UNIQUE so the upsert pattern works.
--   3) Enables RLS and adds policies so each user can read/write only
--      their own attempts (admins can read all).
--   4) Adds a trigger to auto-bump updated_at on UPDATE.
--
-- Idempotent: uses IF NOT EXISTS / DROP POLICY IF EXISTS so a re-run is safe.
-- Wrapped in a single BEGIN..COMMIT — auto-rolls back on any error.
-- =============================================================================

BEGIN;

-- -----------------------------------------------------------------------------
-- Step 1: Create the table
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.module_quiz_attempts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  module_id uuid NOT NULL REFERENCES public.modules(id) ON DELETE CASCADE,
  score integer NOT NULL DEFAULT 0,
  best_score integer NOT NULL DEFAULT 0,
  passed boolean NOT NULL DEFAULT false,
  attempt_count integer NOT NULL DEFAULT 0,
  completed_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT module_quiz_attempts_user_module_unique UNIQUE (user_id, module_id)
);

CREATE INDEX IF NOT EXISTS idx_module_quiz_attempts_user
  ON public.module_quiz_attempts (user_id);

CREATE INDEX IF NOT EXISTS idx_module_quiz_attempts_module
  ON public.module_quiz_attempts (module_id);

-- -----------------------------------------------------------------------------
-- Step 2: Enable RLS + policies
-- -----------------------------------------------------------------------------
ALTER TABLE public.module_quiz_attempts ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view their own quiz attempts"   ON public.module_quiz_attempts;
DROP POLICY IF EXISTS "Users can insert their own quiz attempts" ON public.module_quiz_attempts;
DROP POLICY IF EXISTS "Users can update their own quiz attempts" ON public.module_quiz_attempts;
DROP POLICY IF EXISTS "Admins can view all quiz attempts"        ON public.module_quiz_attempts;

CREATE POLICY "Users can view their own quiz attempts"
  ON public.module_quiz_attempts
  FOR SELECT TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own quiz attempts"
  ON public.module_quiz_attempts
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own quiz attempts"
  ON public.module_quiz_attempts
  FOR UPDATE TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Admins can view all quiz attempts"
  ON public.module_quiz_attempts
  FOR SELECT TO authenticated
  USING (has_role(auth.uid(), 'admin'::app_role));

-- -----------------------------------------------------------------------------
-- Step 3: updated_at trigger
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.set_updated_at_module_quiz_attempts()
RETURNS trigger AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_module_quiz_attempts_updated_at ON public.module_quiz_attempts;
CREATE TRIGGER trg_module_quiz_attempts_updated_at
  BEFORE UPDATE ON public.module_quiz_attempts
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at_module_quiz_attempts();

-- -----------------------------------------------------------------------------
-- Step 4: Refresh the PostgREST schema cache so the API picks up the new table
-- -----------------------------------------------------------------------------
NOTIFY pgrst, 'reload schema';

COMMIT;

-- Final verification (read-only, runs after commit)
SELECT
  'module_quiz_attempts' AS table_name,
  COUNT(*) AS existing_rows,
  EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'module_quiz_attempts'
  ) AS table_exists,
  (SELECT COUNT(*) FROM pg_policies WHERE tablename = 'module_quiz_attempts') AS rls_policy_count;
