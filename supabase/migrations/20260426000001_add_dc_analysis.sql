-- DC (Digital Coach) integration tables and columns

-- ── 1. New columns on cot_observations (fast status read without join) ────────
ALTER TABLE public.cot_observations
  ADD COLUMN IF NOT EXISTS dc_task_id       TEXT,
  ADD COLUMN IF NOT EXISTS dc_status        TEXT CHECK (dc_status IN ('processing','completed','failed')),
  ADD COLUMN IF NOT EXISTS dc_requested_at  TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS dc_completed_at  TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS dc_results       JSONB,
  ADD COLUMN IF NOT EXISTS dc_error         TEXT,
  ADD COLUMN IF NOT EXISTS dc_audio_s3_key  TEXT;

-- ── 2. dc_analyses — mutable progress tracker, Realtime target ───────────────
CREATE TABLE IF NOT EXISTS public.dc_analyses (
  id             UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  observation_id UUID NOT NULL REFERENCES public.cot_observations(id) ON DELETE CASCADE,
  task_id        TEXT NOT NULL UNIQUE,
  status         TEXT NOT NULL DEFAULT 'processing'
                   CHECK (status IN ('processing','completed','failed')),
  progress       INTEGER DEFAULT 0,
  current_step   TEXT,
  message        TEXT,
  error          TEXT,
  results        JSONB,
  created_at     TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at     TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

ALTER TABLE public.dc_analyses ENABLE ROW LEVEL SECURITY;

-- Coaches can read their own analysis rows
CREATE POLICY "Coaches can read own dc_analyses"
  ON public.dc_analyses FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.cot_observations o
      WHERE o.id = dc_analyses.observation_id
        AND o.observer_id = auth.uid()
    )
  );

CREATE INDEX IF NOT EXISTS dc_analyses_observation_idx ON public.dc_analyses(observation_id);
CREATE INDEX IF NOT EXISTS dc_analyses_task_idx        ON public.dc_analyses(task_id);

-- ── 3. Enable Realtime so frontend subscription fires on UPDATE ───────────────
ALTER PUBLICATION supabase_realtime ADD TABLE public.dc_analyses;
