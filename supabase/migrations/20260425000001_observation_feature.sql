-- ─────────────────────────────────────────────────────────────────────────────
-- Observation Feature Migration
-- Academic Coaching & Observation tables
-- ─────────────────────────────────────────────────────────────────────────────

-- 1. COT Observations table
CREATE TABLE IF NOT EXISTS public.cot_observations (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  observer_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  school_name TEXT NOT NULL,
  teacher_name TEXT NOT NULL,
  region TEXT NOT NULL DEFAULT '',
  subject TEXT NOT NULL,
  grade TEXT NOT NULL,
  topic TEXT,
  date TIMESTAMPTZ NOT NULL,
  total_score INTEGER DEFAULT 0,
  proficiency_level TEXT,
  hots_rubric JSONB DEFAULT '{}',
  hots_notes TEXT,
  notes_for_teacher TEXT,
  status TEXT DEFAULT 'Scheduled' CHECK (status IN ('Scheduled', 'Draft', 'Submitted', 'Approved')),
  submitted_at TIMESTAMPTZ,
  approved_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- 2. HOTS Rubric Dimensions lookup table
CREATE TABLE IF NOT EXISTS public.hots_rubric_dimensions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  dimension TEXT NOT NULL,
  description TEXT,
  max_score INTEGER DEFAULT 10,
  order_number INTEGER,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- 3. Seed HOTS dimensions (only if table is empty)
INSERT INTO public.hots_rubric_dimensions (dimension, description, max_score, order_number)
SELECT * FROM (VALUES
  ('Critical Thinking',     'Teacher promotes analysis, evaluation and synthesis of ideas among students',                   10, 1),
  ('Student Engagement',    'Level of student participation, curiosity and active involvement in learning',                  10, 2),
  ('Use of Resources',      'Effective use of teaching materials, technology and classroom tools',                           10, 3),
  ('Classroom Management',  'Maintaining a productive, orderly and supportive learning environment',                         10, 4),
  ('Communication Skills',  'Clarity of instruction, questioning techniques and effective communication',                    10, 5),
  ('Assessment & Feedback', 'Quality and frequency of formative assessment and feedback given to students',                  20, 6)
) AS t(dimension, description, max_score, order_number)
WHERE NOT EXISTS (SELECT 1 FROM public.hots_rubric_dimensions LIMIT 1);

-- 4. Row Level Security
ALTER TABLE public.cot_observations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.hots_rubric_dimensions ENABLE ROW LEVEL SECURITY;

-- Coaches: full access to their own observations
DROP POLICY IF EXISTS "Coaches can select own observations" ON public.cot_observations;
CREATE POLICY "Coaches can select own observations"
  ON public.cot_observations FOR SELECT
  USING (auth.uid() = observer_id);

DROP POLICY IF EXISTS "Coaches can insert own observations" ON public.cot_observations;
CREATE POLICY "Coaches can insert own observations"
  ON public.cot_observations FOR INSERT
  WITH CHECK (auth.uid() = observer_id);

DROP POLICY IF EXISTS "Coaches can update own observations" ON public.cot_observations;
CREATE POLICY "Coaches can update own observations"
  ON public.cot_observations FOR UPDATE
  USING (auth.uid() = observer_id);

-- HOTS dimensions are readable by all authenticated users
DROP POLICY IF EXISTS "Authenticated users can read hots dimensions" ON public.hots_rubric_dimensions;
CREATE POLICY "Authenticated users can read hots dimensions"
  ON public.hots_rubric_dimensions FOR SELECT
  USING (auth.uid() IS NOT NULL);

-- 5. Performance indexes
CREATE INDEX IF NOT EXISTS cot_observations_observer_idx ON public.cot_observations(observer_id);
CREATE INDEX IF NOT EXISTS cot_observations_status_idx   ON public.cot_observations(status);
CREATE INDEX IF NOT EXISTS cot_observations_date_idx     ON public.cot_observations(date DESC);
