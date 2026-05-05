-- Add Neo integration columns to cot_observations
ALTER TABLE public.cot_observations
  ADD COLUMN IF NOT EXISTS neo_status TEXT CHECK (neo_status IN ('processing','completed','failed')),
  ADD COLUMN IF NOT EXISTS neo_task_id TEXT,
  ADD COLUMN IF NOT EXISTS neo_requested_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS neo_completed_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS neo_results JSONB,
  ADD COLUMN IF NOT EXISTS neo_error TEXT;
