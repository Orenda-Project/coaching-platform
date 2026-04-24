-- Create baseline and endline training records for tab switch tracking
-- These trainings are special - they don't have content but allow tracking in training_progress

-- Get or create baseline training
INSERT INTO public.trainings (id, title, description, order_number, is_common)
VALUES (
  'f47ac10b-58cc-4372-a567-0e02b2c3d479'::UUID,
  'Coach Baseline Assessment',
  'Baseline assessment for coaching program',
  0,
  true
)
ON CONFLICT (id) DO NOTHING;

-- Get or create endline training
INSERT INTO public.trainings (id, title, description, order_number, is_common)
VALUES (
  'f47ac10b-58cc-4372-a567-0e02b2c3d480'::UUID,
  'Coach Endline Assessment',
  'Endline assessment for coaching program',
  999,
  true
)
ON CONFLICT (id) DO NOTHING;

-- Link baseline assessment to baseline training
UPDATE public.assessments
SET training_id = 'f47ac10b-58cc-4372-a567-0e02b2c3d479'::UUID
WHERE type = 'baseline' AND training_id IS NULL;

-- Link endline assessment to endline training
UPDATE public.assessments
SET training_id = 'f47ac10b-58cc-4372-a567-0e02b2c3d480'::UUID
WHERE type = 'endline' AND training_id IS NULL;
