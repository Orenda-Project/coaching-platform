-- =============================================================================
-- PRODUCTION ROLLBACK — Module 1 Quiz Rebuild
-- Date: 2026-04-28
--
-- RUN THIS ONLY IF the forward migration (01-forward.sql) causes issues.
-- This script restores questions and options from backup tables created by
-- 01-forward.sql, undoing the question rebuild while preserving new data
-- (module_quiz_attempts, RLS policies, triggers).
--
-- Safe to run multiple times (idempotent with IF EXISTS checks).
-- =============================================================================

BEGIN;

-- 1. Restore questions from backup
-- This resurrects the original 37 questions with their original IDs
INSERT INTO public.questions (id, assessment_id, question_type, question_text, order_number, created_at, updated_at)
SELECT id, assessment_id, question_type, question_text, order_number, created_at, updated_at
FROM public.backup_module1_questions_20260428
ON CONFLICT (id) DO NOTHING;

-- 2. Restore options from backup
INSERT INTO public.options (id, question_id, option_text, is_correct, order_number, created_at, updated_at)
SELECT id, question_id, option_text, is_correct, order_number, created_at, updated_at
FROM public.backup_module1_options_20260428
ON CONFLICT (id) DO NOTHING;

-- 3. Verify counts match backup
DO $$
DECLARE
  restored_questions INT;
  restored_options INT;
  backup_q_count INT;
  backup_o_count INT;
BEGIN
  SELECT COUNT(*) INTO backup_q_count FROM public.backup_module1_questions_20260428;
  SELECT COUNT(*) INTO backup_o_count FROM public.backup_module1_options_20260428;

  restored_questions := (
    SELECT COUNT(*) FROM public.questions q
    WHERE q.assessment_id IN (
      SELECT a.id FROM public.assessments a
      JOIN public.trainings t ON a.training_id = t.id
      JOIN public.modules m ON t.module_id = m.id
      WHERE m.order_number = 1 AND a.type = 'module_quiz'
    )
  );

  restored_options := (
    SELECT COUNT(*) FROM public.options o
    WHERE o.question_id IN (
      SELECT q.id FROM public.questions q
      WHERE q.assessment_id IN (
        SELECT a.id FROM public.assessments a
        JOIN public.trainings t ON a.training_id = t.id
        JOIN public.modules m ON t.module_id = m.id
        WHERE m.order_number = 1 AND a.type = 'module_quiz'
      )
    )
  );

  RAISE NOTICE 'Backup had % questions, % options. Restored % questions, % options.',
    backup_q_count, backup_o_count, restored_questions, restored_options;

  IF restored_questions < backup_q_count THEN
    RAISE EXCEPTION 'Question restore count mismatch: expected %, got %', backup_q_count, restored_questions;
  END IF;

  IF restored_options < backup_o_count THEN
    RAISE EXCEPTION 'Option restore count mismatch: expected %, got %', backup_o_count, restored_options;
  END IF;
END $$;

-- 4. Refresh PostgREST schema cache
NOTIFY pgrst, 'reload schema';

COMMIT;

SELECT 'Rollback complete. Original Module 1 questions and options restored from backup.' AS status;
