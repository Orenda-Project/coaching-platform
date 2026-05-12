-- Add visit_purpose column to cot_observations
-- Stores the purpose of the coaching visit. Valid values: Classroom Observation, Lesson Plan Review, Coaching Follow-up, Support Visit, Assessment Check
ALTER TABLE cot_observations ADD COLUMN IF NOT EXISTS visit_purpose TEXT;

-- Enforce allowed visit purpose values via CHECK constraint
ALTER TABLE cot_observations
ADD CONSTRAINT check_visit_purpose_values
CHECK (visit_purpose IS NULL OR visit_purpose IN ('Classroom Observation', 'Lesson Plan Review', 'Coaching Follow-up', 'Support Visit', 'Assessment Check'));
