-- Verify and fix constraints - FORCE version

-- First, completely drop and recreate training_content constraint
ALTER TABLE public.training_content
  DROP CONSTRAINT IF EXISTS training_content_format_type_check CASCADE;

ALTER TABLE public.training_content
  ADD CONSTRAINT training_content_format_type_check
  CHECK (format_type IN ('slide', 'audio', 'video', 'slides', 'scenario', 'quiz', 'module_quiz'));

-- Next, completely drop and recreate assessments type constraint
ALTER TABLE public.assessments
  DROP CONSTRAINT IF EXISTS assessments_type_check CASCADE;

ALTER TABLE public.assessments
  ADD CONSTRAINT assessments_type_check
  CHECK (type IN ('baseline', 'endline', 'training', 'module_quiz'));

-- Ensure unique constraint exists
ALTER TABLE public.assessments
  DROP CONSTRAINT IF EXISTS assessments_training_id_type_unique;

ALTER TABLE public.assessments
  ADD CONSTRAINT assessments_training_id_type_unique
  UNIQUE (training_id, type);
