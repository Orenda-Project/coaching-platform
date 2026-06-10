-- Migration: Add is_multi_grade flag to cot_observations
-- Purpose: Track whether a visit involves a multi-grade classroom

ALTER TABLE public.cot_observations
ADD COLUMN IF NOT EXISTS is_multi_grade BOOLEAN DEFAULT FALSE;

COMMENT ON COLUMN public.cot_observations.is_multi_grade IS 'Flag indicating if the teacher teaches multiple grades in the same classroom (applies MG-B1/B2/C1/C2 standards)';
