-- Teacher DC scores imported from DC dashboard
CREATE TABLE IF NOT EXISTS public.teacher_dc_scores (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  observer_id UUID REFERENCES auth.users(id),
  teacher_name TEXT NOT NULL,
  school_name TEXT NOT NULL,
  region TEXT NOT NULL,
  subject TEXT,
  grade TEXT,
  framework TEXT DEFAULT 'FICO',
  total_score INTEGER NOT NULL,
  proficiency_level TEXT,
  scored_at TIMESTAMPTZ NOT NULL,
  raw_results JSONB,
  created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.teacher_dc_scores ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "coaches see own dc scores" ON public.teacher_dc_scores;
CREATE POLICY "coaches see own dc scores"
  ON public.teacher_dc_scores
  FOR SELECT
  USING (observer_id = auth.uid());

DROP POLICY IF EXISTS "service role manages dc scores" ON public.teacher_dc_scores;
CREATE POLICY "service role manages dc scores"
  ON public.teacher_dc_scores
  FOR ALL
  USING (true)
  WITH CHECK (true);

CREATE UNIQUE INDEX IF NOT EXISTS teacher_dc_scores_upsert_idx
  ON public.teacher_dc_scores (observer_id, teacher_name, school_name, scored_at);
