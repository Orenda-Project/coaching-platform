-- Create module_quiz_attempts table used by ModuleQuiz.tsx to track per-(user, module)
-- aggregate quiz attempts (latest score, best score, passed flag, attempt counter).

CREATE TABLE IF NOT EXISTS public.module_quiz_attempts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  module_id uuid NOT NULL REFERENCES public.modules(id) ON DELETE CASCADE,
  score integer NOT NULL DEFAULT 0,
  best_score integer NOT NULL DEFAULT 0,
  passed boolean NOT NULL DEFAULT false,
  attempt_count integer NOT NULL DEFAULT 0,
  completed_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT module_quiz_attempts_user_module_unique UNIQUE (user_id, module_id)
);

CREATE INDEX IF NOT EXISTS idx_module_quiz_attempts_user
  ON public.module_quiz_attempts (user_id);

CREATE INDEX IF NOT EXISTS idx_module_quiz_attempts_module
  ON public.module_quiz_attempts (module_id);

ALTER TABLE public.module_quiz_attempts ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view their own quiz attempts"   ON public.module_quiz_attempts;
DROP POLICY IF EXISTS "Users can insert their own quiz attempts" ON public.module_quiz_attempts;
DROP POLICY IF EXISTS "Users can update their own quiz attempts" ON public.module_quiz_attempts;
DROP POLICY IF EXISTS "Admins can view all quiz attempts"        ON public.module_quiz_attempts;

CREATE POLICY "Users can view their own quiz attempts"
  ON public.module_quiz_attempts
  FOR SELECT TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own quiz attempts"
  ON public.module_quiz_attempts
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own quiz attempts"
  ON public.module_quiz_attempts
  FOR UPDATE TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Admins can view all quiz attempts"
  ON public.module_quiz_attempts
  FOR SELECT TO authenticated
  USING (has_role(auth.uid(), 'admin'::app_role));

CREATE OR REPLACE FUNCTION public.set_updated_at_module_quiz_attempts()
RETURNS trigger AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_module_quiz_attempts_updated_at ON public.module_quiz_attempts;
CREATE TRIGGER trg_module_quiz_attempts_updated_at
  BEFORE UPDATE ON public.module_quiz_attempts
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at_module_quiz_attempts();
