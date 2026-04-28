-- Feedback chatbot: stores user-submitted feedback with context.
-- Write-once (no UPDATE/DELETE policies). RLS-gated.

CREATE TABLE IF NOT EXISTS public.feedback (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  module_id    UUID REFERENCES public.modules(id) ON DELETE SET NULL,
  training_id  UUID REFERENCES public.trainings(id) ON DELETE SET NULL,
  context_page TEXT NOT NULL,
  category     TEXT NOT NULL CHECK (category IN ('module','platform','bug','other')),
  rating       INT  NOT NULL CHECK (rating BETWEEN 1 AND 5),
  positive_feedback     TEXT,
  improvement_feedback  TEXT,
  persona      TEXT,
  user_agent   TEXT,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_feedback_created_at ON public.feedback (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_feedback_module_id  ON public.feedback (module_id) WHERE module_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_feedback_user_id    ON public.feedback (user_id);

ALTER TABLE public.feedback ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can insert own feedback"
  ON public.feedback FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can read own feedback"
  ON public.feedback FOR SELECT TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Admins can read all feedback"
  ON public.feedback FOR SELECT TO authenticated
  USING (public.has_role(auth.uid(), 'admin'::app_role));
