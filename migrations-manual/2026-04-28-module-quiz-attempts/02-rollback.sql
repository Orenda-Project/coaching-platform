-- =============================================================================
-- Rollback: Drop module_quiz_attempts table
-- Date: 2026-04-28
--
-- Run this ONLY if you need to revert the forward migration.
-- WARNING: This drops the table and all rows in it (user quiz attempts).
--
-- If real users have already taken quizzes against this table on staging,
-- you may want to back up the data first:
--
--   CREATE TABLE public.backup_module_quiz_attempts_20260428 AS
--     SELECT * FROM public.module_quiz_attempts;
--
-- =============================================================================

BEGIN;

DROP TRIGGER IF EXISTS trg_module_quiz_attempts_updated_at ON public.module_quiz_attempts;
DROP FUNCTION IF EXISTS public.set_updated_at_module_quiz_attempts();
DROP TABLE IF EXISTS public.module_quiz_attempts CASCADE;

NOTIFY pgrst, 'reload schema';

COMMIT;

SELECT 'module_quiz_attempts dropped.' AS status;
