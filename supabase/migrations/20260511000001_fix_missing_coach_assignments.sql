-- Create coach_assignments table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.coach_assignments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  coach_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  region TEXT NOT NULL DEFAULT 'ICT',
  sub_region TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(coach_id)
);

-- Enable RLS
ALTER TABLE public.coach_assignments ENABLE ROW LEVEL SECURITY;

-- Create or replace policies
DROP POLICY IF EXISTS "coaches see own assignment" ON public.coach_assignments;
DROP POLICY IF EXISTS "service role manages" ON public.coach_assignments;

CREATE POLICY "coaches see own assignment"
  ON public.coach_assignments
  FOR SELECT
  USING (coach_id = auth.uid());

CREATE POLICY "service role manages"
  ON public.coach_assignments
  FOR ALL
  USING (true)
  WITH CHECK (true);

-- Also add other missing columns/tables
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS sub_region TEXT;
