-- Add visit_purpose column to cot_observations
-- Stores the purpose of the coaching visit as free text entered by the coach
ALTER TABLE cot_observations ADD COLUMN IF NOT EXISTS visit_purpose TEXT;
