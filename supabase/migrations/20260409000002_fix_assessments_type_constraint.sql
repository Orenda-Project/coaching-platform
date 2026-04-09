-- Fix assessments type constraint to allow module_quiz
ALTER TABLE public.assessments
  DROP CONSTRAINT IF EXISTS assessments_type_check;

ALTER TABLE public.assessments
  ADD CONSTRAINT assessments_type_check
  CHECK (type IN ('baseline', 'endline', 'training', 'module_quiz'));
