-- Add framework column to cot_observations table
-- Allows tracking which observation framework (HOTS, FICO, etc) was used

ALTER TABLE public.cot_observations
ADD COLUMN framework TEXT DEFAULT 'HOTS';

-- Verify column was added
SELECT column_name FROM information_schema.columns 
WHERE table_name = 'cot_observations' AND column_name = 'framework';
