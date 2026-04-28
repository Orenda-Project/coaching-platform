-- =============================================================================
-- Module 1 Quiz Rebuild — ROLLBACK
-- Date: 2026-04-28
--
-- Run this ONLY if you need to revert the forward migration.
-- It restores Module 1 quiz questions/options exactly as they were
-- before 01-forward.sql ran, using the backup tables.
--
-- Preconditions:
--   - Tables `public.backup_module1_questions_20260428` and
--     `public.backup_module1_options_20260428` must still exist.
--   - These were created by 01-forward.sql.
--
-- After successful rollback you may DROP the backup tables manually
-- using 03-cleanup-backups.sql.
-- =============================================================================

BEGIN;

-- -----------------------------------------------------------------------------
-- Step 0: Verify backup tables exist
-- -----------------------------------------------------------------------------
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public'
      AND table_name = 'backup_module1_questions_20260428'
  ) THEN
    RAISE EXCEPTION 'Backup table backup_module1_questions_20260428 not found. Cannot rollback.';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public'
      AND table_name = 'backup_module1_options_20260428'
  ) THEN
    RAISE EXCEPTION 'Backup table backup_module1_options_20260428 not found. Cannot rollback.';
  END IF;
END $$;

-- -----------------------------------------------------------------------------
-- Step 1: Delete the new (rebuilt) Module 1 quiz questions
--   Options are CASCADE-deleted via FK.
-- -----------------------------------------------------------------------------
DELETE FROM public.questions
WHERE assessment_id IN (
  SELECT a.id
  FROM public.assessments a
  JOIN public.trainings t ON t.id = a.training_id
  WHERE t.module_id = (SELECT id FROM public.modules WHERE order_number = 1 LIMIT 1)
    AND a.type = 'module_quiz'
);

-- -----------------------------------------------------------------------------
-- Step 2: Restore questions from backup (preserve original ids)
-- -----------------------------------------------------------------------------
INSERT INTO public.questions
  (id, assessment_id, question_type, question_text, correct_answer, max_score, order_number, created_at)
SELECT id, assessment_id, question_type, question_text, correct_answer, max_score, order_number, created_at
FROM public.backup_module1_questions_20260428;

-- -----------------------------------------------------------------------------
-- Step 3: Restore options from backup (preserve original ids)
-- -----------------------------------------------------------------------------
INSERT INTO public.options
  (id, question_id, option_text, is_correct, created_at)
SELECT id, question_id, option_text, is_correct, created_at
FROM public.backup_module1_options_20260428;

-- -----------------------------------------------------------------------------
-- Step 4: Verify restoration matches backup row counts
-- -----------------------------------------------------------------------------
DO $$
DECLARE
  v_module_id uuid := (SELECT id FROM public.modules WHERE order_number = 1 LIMIT 1);
  v_q_now int;
  v_q_backup int;
  v_o_now int;
  v_o_backup int;
BEGIN
  SELECT COUNT(*) INTO v_q_now
  FROM public.questions q
  JOIN public.assessments a ON a.id = q.assessment_id
  JOIN public.trainings t ON t.id = a.training_id
  WHERE t.module_id = v_module_id
    AND a.type = 'module_quiz';

  SELECT COUNT(*) INTO v_q_backup FROM public.backup_module1_questions_20260428;

  SELECT COUNT(*) INTO v_o_now
  FROM public.options o
  JOIN public.questions q ON q.id = o.question_id
  JOIN public.assessments a ON a.id = q.assessment_id
  JOIN public.trainings t ON t.id = a.training_id
  WHERE t.module_id = v_module_id
    AND a.type = 'module_quiz';

  SELECT COUNT(*) INTO v_o_backup FROM public.backup_module1_options_20260428;

  RAISE NOTICE 'Restored % questions (backup had %), % options (backup had %)',
    v_q_now, v_q_backup, v_o_now, v_o_backup;

  IF v_q_now <> v_q_backup THEN
    RAISE EXCEPTION 'Question count mismatch after rollback. Aborting.';
  END IF;
  IF v_o_now <> v_o_backup THEN
    RAISE EXCEPTION 'Option count mismatch after rollback. Aborting.';
  END IF;

  RAISE NOTICE 'Rollback verified. Committing.';
END $$;

COMMIT;
