-- Add FICO framework support to cot_observations
ALTER TABLE public.cot_observations
  ADD COLUMN IF NOT EXISTS framework TEXT DEFAULT 'HOTS' CHECK (framework IN ('HOTS', 'FICO')),
  ADD COLUMN IF NOT EXISTS fico_rubric JSONB DEFAULT '{}';
