-- Fix training_content format_type constraint to support all content types
-- Allow: slide, audio, video, slides, scenario, quiz

-- Drop existing constraint and recreate with broader values
ALTER TABLE public.training_content
  DROP CONSTRAINT IF EXISTS training_content_format_type_check;

ALTER TABLE public.training_content
  ADD CONSTRAINT training_content_format_type_check
  CHECK (format_type IN ('slide', 'audio', 'video', 'slides', 'scenario', 'quiz'));

-- Add unique constraint on (training_id, format_type) for assessments upsert
ALTER TABLE public.assessments
  ADD CONSTRAINT assessments_training_id_type_unique
  UNIQUE (training_id, type);
