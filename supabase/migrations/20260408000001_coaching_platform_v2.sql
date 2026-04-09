-- ─────────────────────────────────────────────────────────────────────────────
-- Coaching Platform v2 — Prototype Improvements
-- ─────────────────────────────────────────────────────────────────────────────

-- 1. Add attempt_count to training_progress (max 3 attempts per module)
ALTER TABLE public.training_progress
  ADD COLUMN IF NOT EXISTS attempt_count INTEGER NOT NULL DEFAULT 1;

-- 2. Add anti-cheat violation tracking
ALTER TABLE public.training_progress
  ADD COLUMN IF NOT EXISTS tab_switch_count INTEGER NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS fullscreen_violations INTEGER NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS flagged_for_review BOOLEAN NOT NULL DEFAULT false;

-- 3. Add scenario content type to training_content
-- format_type already supports arbitrary strings — just document 'scenario' as valid
-- Add scenario_data JSON column for scenario-based content
ALTER TABLE public.training_content
  ADD COLUMN IF NOT EXISTS scenario_data JSONB;

-- 4. Fix certificate upsert — add ON CONFLICT policy
-- The unique constraint on user_id already exists; we'll handle upsert in app layer
-- But add a last_issued_at for tracking retakes
ALTER TABLE public.certificates
  ADD COLUMN IF NOT EXISTS last_issued_at TIMESTAMPTZ;

-- 5. Add max_attempts config to trainings (default 3)
ALTER TABLE public.trainings
  ADD COLUMN IF NOT EXISTS max_attempts INTEGER NOT NULL DEFAULT 3;

-- 6. Add endline_attempts tracking to profiles
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS endline_attempt_count INTEGER NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS baseline_attempt_count INTEGER NOT NULL DEFAULT 0;

-- 7. Add quiz_unlock_requires_content boolean to trainings (default true)
ALTER TABLE public.trainings
  ADD COLUMN IF NOT EXISTS quiz_unlock_requires_content BOOLEAN NOT NULL DEFAULT true;

-- 8. Session tracking for analytics
CREATE TABLE IF NOT EXISTS public.session_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  event_type TEXT NOT NULL,  -- 'login', 'module_start', 'module_complete', 'quiz_attempt', 'tab_switch', 'fullscreen_exit'
  training_id UUID REFERENCES public.trainings(id) ON DELETE SET NULL,
  properties JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS for session_events
ALTER TABLE public.session_events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can insert own events"
  ON public.session_events FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can read own events"
  ON public.session_events FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Admins can read all events"
  ON public.session_events FOR SELECT
  USING (has_role(auth.uid(), 'admin'));

-- 9. Update training_progress to track content completion separately
ALTER TABLE public.training_progress
  ADD COLUMN IF NOT EXISTS content_completed BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS content_completed_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS started_at TIMESTAMPTZ DEFAULT NOW();

-- 10. Index for performance
CREATE INDEX IF NOT EXISTS idx_session_events_user ON public.session_events(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_training_progress_user ON public.training_progress(user_id, training_id);
