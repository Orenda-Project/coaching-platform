-- Create teacher_roster table for Smart Coach Visit Scheduler
CREATE TABLE public.teacher_roster (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  coach_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  teacher_name TEXT NOT NULL,
  school_name TEXT NOT NULL,
  region TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(coach_id, teacher_name, school_name)
);

-- Enable RLS
ALTER TABLE public.teacher_roster ENABLE ROW LEVEL SECURITY;

-- RLS: coaches can only see/insert/update their own teachers
CREATE POLICY "Coaches view own teachers"
  ON public.teacher_roster
  FOR SELECT
  USING (auth.uid() = coach_id);

CREATE POLICY "Coaches insert own teachers"
  ON public.teacher_roster
  FOR INSERT
  WITH CHECK (auth.uid() = coach_id);

CREATE POLICY "Coaches update own teachers"
  ON public.teacher_roster
  FOR UPDATE
  USING (auth.uid() = coach_id)
  WITH CHECK (auth.uid() = coach_id);

CREATE POLICY "Coaches delete own teachers"
  ON public.teacher_roster
  FOR DELETE
  USING (auth.uid() = coach_id);

-- Index for quick lookup by coach
CREATE INDEX idx_teacher_roster_coach_id ON public.teacher_roster(coach_id);
