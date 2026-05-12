-- Trigger PostgREST schema introspection refresh
-- by making a schema change that forces recompilation

-- Add and immediately drop a temporary column to force schema rebuild
ALTER TABLE public.teacher_dc_scores ADD COLUMN _temp_refresh BOOLEAN DEFAULT true;
ALTER TABLE public.teacher_dc_scores DROP COLUMN _temp_refresh;

ALTER TABLE public.cot_observations ADD COLUMN _temp_refresh BOOLEAN DEFAULT true;
ALTER TABLE public.cot_observations DROP COLUMN _temp_refresh;
