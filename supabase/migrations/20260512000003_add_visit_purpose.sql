-- Add visit_purpose column to cot_observations
-- Stores the purpose of the coaching visit (e.g., Classroom Observation, Lesson Plan Review, etc.)
ALTER TABLE cot_observations ADD COLUMN IF NOT EXISTS visit_purpose TEXT;
