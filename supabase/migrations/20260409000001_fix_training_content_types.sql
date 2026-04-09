-- Fix training_content format_type constraint to support all content types
-- Allow: slide, audio, video, slides, scenario, quiz

-- Drop existing constraint and recreate with broader values
ALTER TABLE public.training_content
  DROP CONSTRAINT IF EXISTS training_content_format_type_check;

ALTER TABLE public.training_content
  ADD CONSTRAINT training_content_format_type_check
  CHECK (format_type IN ('slide', 'audio', 'video', 'slides', 'scenario', 'quiz'));

-- Fix assessments type constraint to allow module_quiz
ALTER TABLE public.assessments
  DROP CONSTRAINT IF EXISTS assessments_type_check;

ALTER TABLE public.assessments
  ADD CONSTRAINT assessments_type_check
  CHECK (type IN ('baseline', 'endline', 'training', 'module_quiz'));

-- Add unique constraint on (training_id, type) for assessments
ALTER TABLE public.assessments
  ADD CONSTRAINT assessments_training_id_type_unique
  UNIQUE (training_id, type);
