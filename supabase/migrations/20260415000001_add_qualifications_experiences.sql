-- Add qualifications and experiences JSONB columns to profiles
ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS qualifications JSONB DEFAULT '[]',
  ADD COLUMN IF NOT EXISTS experiences JSONB DEFAULT '[]';
