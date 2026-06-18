-- Migration: Add missing columns to cot_observations for full frontend compatibility
-- Run on both staging and production Railway Postgres

ALTER TABLE cot_observations
  ADD COLUMN IF NOT EXISTS fico_rubric jsonb,
  ADD COLUMN IF NOT EXISTS hots_rubric jsonb,
  ADD COLUMN IF NOT EXISTS proficiency_level varchar,
  ADD COLUMN IF NOT EXISTS notes_for_teacher text,
  ADD COLUMN IF NOT EXISTS hots_notes text,
  ADD COLUMN IF NOT EXISTS neo_status varchar,
  ADD COLUMN IF NOT EXISTS neo_task_id varchar,
  ADD COLUMN IF NOT EXISTS neo_requested_at timestamptz,
  ADD COLUMN IF NOT EXISTS neo_completed_at timestamptz,
  ADD COLUMN IF NOT EXISTS neo_results jsonb,
  ADD COLUMN IF NOT EXISTS neo_error text,
  ADD COLUMN IF NOT EXISTS neo_audio_url text,
  ADD COLUMN IF NOT EXISTS dc_status varchar,
  ADD COLUMN IF NOT EXISTS dc_task_id varchar,
  ADD COLUMN IF NOT EXISTS dc_requested_at timestamptz,
  ADD COLUMN IF NOT EXISTS dc_completed_at timestamptz,
  ADD COLUMN IF NOT EXISTS dc_results jsonb,
  ADD COLUMN IF NOT EXISTS dc_error text,
  ADD COLUMN IF NOT EXISTS dc_audio_s3_key varchar;
