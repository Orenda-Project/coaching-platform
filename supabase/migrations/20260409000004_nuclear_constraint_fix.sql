-- NUCLEAR FIX: Drop everything and rebuild constraints from scratch

-- Step 1: Drop all dependent constraints and indexes
ALTER TABLE public.training_content DROP CONSTRAINT IF EXISTS training_content_format_type_check CASCADE;
ALTER TABLE public.assessments DROP CONSTRAINT IF EXISTS assessments_type_check CASCADE;
ALTER TABLE public.assessments DROP CONSTRAINT IF EXISTS assessments_training_id_type_unique CASCADE;

-- Step 2: Verify tables exist and add constraints cleanly
DO $$
BEGIN
  -- Add training_content constraint
  ALTER TABLE public.training_content
    ADD CONSTRAINT training_content_format_type_check
    CHECK (format_type IN ('slide', 'audio', 'video', 'slides', 'scenario', 'quiz', 'module_quiz'));

  -- Add assessments type constraint
  ALTER TABLE public.assessments
    ADD CONSTRAINT assessments_type_check
    CHECK (type IN ('baseline', 'endline', 'training', 'module_quiz'));

  -- Add unique constraint for (training_id, type)
  ALTER TABLE public.assessments
    ADD CONSTRAINT assessments_training_id_type_unique
    UNIQUE (training_id, type);

EXCEPTION WHEN OTHERS THEN
  -- If constraints already exist, that's fine - this is idempotent
  NULL;
END $$;
