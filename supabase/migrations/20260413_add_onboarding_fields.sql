-- Add onboarding fields to profiles table
ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS region TEXT,
ADD COLUMN IF NOT EXISTS school_id TEXT,
ADD COLUMN IF NOT EXISTS teacher_ids TEXT[] DEFAULT '{}';

-- Create index on school_id for faster lookups
CREATE INDEX IF NOT EXISTS idx_profiles_school_id ON public.profiles(school_id);
