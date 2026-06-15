-- Rollback: Remove the 19 columns added by 003_add_observation_columns.sql
-- Run this ONLY if the migration needs to be reverted

ALTER TABLE cot_observations
  DROP COLUMN IF EXISTS fico_rubric,
  DROP COLUMN IF EXISTS hots_rubric,
  DROP COLUMN IF EXISTS proficiency_level,
  DROP COLUMN IF EXISTS notes_for_teacher,
  DROP COLUMN IF EXISTS hots_notes,
  DROP COLUMN IF EXISTS neo_status,
  DROP COLUMN IF EXISTS neo_task_id,
  DROP COLUMN IF EXISTS neo_requested_at,
  DROP COLUMN IF EXISTS neo_completed_at,
  DROP COLUMN IF EXISTS neo_results,
  DROP COLUMN IF EXISTS neo_error,
  DROP COLUMN IF EXISTS neo_audio_url,
  DROP COLUMN IF EXISTS dc_status,
  DROP COLUMN IF EXISTS dc_task_id,
  DROP COLUMN IF EXISTS dc_requested_at,
  DROP COLUMN IF EXISTS dc_completed_at,
  DROP COLUMN IF EXISTS dc_results,
  DROP COLUMN IF EXISTS dc_error,
  DROP COLUMN IF EXISTS dc_audio_s3_key;
