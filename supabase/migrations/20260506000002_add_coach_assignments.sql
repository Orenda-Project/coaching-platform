-- Coach region assignments
CREATE TABLE public.coach_assignments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  coach_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  region TEXT NOT NULL DEFAULT 'ICT',
  sub_region TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(coach_id)
);

ALTER TABLE public.coach_assignments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "coaches see own assignment"
  ON public.coach_assignments
  FOR SELECT
  USING (coach_id = auth.uid());

CREATE POLICY "service role manages"
  ON public.coach_assignments
  FOR ALL
  USING (true)
  WITH CHECK (true);
