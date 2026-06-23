-- Migration: Ensure visit scheduling columns exist in cot_observations
-- Safe to run multiple times (IF NOT EXISTS)
-- Run on both staging and production Railway Postgres

ALTER TABLE cot_observations
  ADD COLUMN IF NOT EXISTS arrival_time varchar,
  ADD COLUMN IF NOT EXISTS departure_time varchar,
  ADD COLUMN IF NOT EXISTS planned_date varchar,
  ADD COLUMN IF NOT EXISTS visit_type varchar;
