-- Migration: Add visit metadata columns to cot_observations
-- Purpose: Store visit type, dates, times, and week information for scheduler

ALTER TABLE public.cot_observations
ADD COLUMN IF NOT EXISTS week VARCHAR(100),
ADD COLUMN IF NOT EXISTS visit_type VARCHAR(100),
ADD COLUMN IF NOT EXISTS planned_date DATE,
ADD COLUMN IF NOT EXISTS arrival_time TIME,
ADD COLUMN IF NOT EXISTS departure_time TIME;

-- Create index for faster filtering by visit type
CREATE INDEX IF NOT EXISTS idx_cot_observations_visit_type
ON public.cot_observations(visit_type);

-- Create index for faster filtering by planned date
CREATE INDEX IF NOT EXISTS idx_cot_observations_planned_date
ON public.cot_observations(planned_date);

COMMENT ON COLUMN public.cot_observations.week IS 'Week identifier (e.g., "Week 1", "Week 2")';
COMMENT ON COLUMN public.cot_observations.visit_type IS 'Type of visit: FICO, Head-Co Observation, M&H, General Visit, RM Visit';
COMMENT ON COLUMN public.cot_observations.planned_date IS 'Date when the visit was planned';
COMMENT ON COLUMN public.cot_observations.arrival_time IS 'Time coach arrived at school (HH:00 format)';
COMMENT ON COLUMN public.cot_observations.departure_time IS 'Time coach departed from school (HH:00 format)';
