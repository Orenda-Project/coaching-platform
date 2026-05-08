-- Add sub_region column to profiles table
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS sub_region TEXT;

-- Create index for common queries on region + sub_region
CREATE INDEX IF NOT EXISTS idx_profiles_region_sub_region
  ON public.profiles(region, sub_region);
