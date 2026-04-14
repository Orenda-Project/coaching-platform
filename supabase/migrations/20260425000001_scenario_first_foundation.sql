-- ─────────────────────────────────────────────────────────────────────────────
-- Phase 1: Scenario-First Foundation
-- Date: 2026-04-13
-- ─────────────────────────────────────────────────────────────────────────────

-- 1. Extend app_role enum to include regional_admin
ALTER TYPE public.app_role ADD VALUE IF NOT EXISTS 'regional_admin';

-- 2. regions table (hierarchical for region-wise tracking)
CREATE TABLE IF NOT EXISTS public.regions (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name          TEXT NOT NULL,
  code          TEXT NOT NULL UNIQUE,
  coordinates   JSONB,
  parent_id     UUID REFERENCES public.regions(id) ON DELETE SET NULL,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3. user_regions junction table (many-to-many)
CREATE TABLE IF NOT EXISTS public.user_regions (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  region_id   UUID NOT NULL REFERENCES public.regions(id) ON DELETE CASCADE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, region_id)
);

-- 4. scenarios table (scenario-first learning content, hangs off trainings/units)
CREATE TABLE IF NOT EXISTS public.scenarios (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  unit_id          UUID NOT NULL REFERENCES public.trainings(id) ON DELETE CASCADE,
  order_number     INTEGER NOT NULL DEFAULT 1,
  situation        TEXT NOT NULL,
  question         TEXT NOT NULL,
  difficulty       TEXT NOT NULL DEFAULT 'medium' CHECK (difficulty IN ('easy', 'medium', 'hard')),
  feedback_slides  JSONB DEFAULT '[]',
  reveal_content   TEXT,
  deep_content     TEXT,
  is_active        BOOLEAN NOT NULL DEFAULT true,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 5. scenario_options table (A/B/C/D choices per scenario)
CREATE TABLE IF NOT EXISTS public.scenario_options (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  scenario_id    UUID NOT NULL REFERENCES public.scenarios(id) ON DELETE CASCADE,
  option_letter  CHAR(1) NOT NULL CHECK (option_letter IN ('A','B','C','D')),
  option_text    TEXT NOT NULL,
  is_correct     BOOLEAN NOT NULL DEFAULT false,
  rationale      TEXT NOT NULL DEFAULT '',
  principle_tag  TEXT,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(scenario_id, option_letter)
);

-- 6. scenario_responses table (user decision tracking)
CREATE TABLE IF NOT EXISTS public.scenario_responses (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id             UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  scenario_id         UUID NOT NULL REFERENCES public.scenarios(id) ON DELETE CASCADE,
  chosen_option       CHAR(1) NOT NULL CHECK (chosen_option IN ('A','B','C','D')),
  is_correct          BOOLEAN NOT NULL,
  time_spent_seconds  INTEGER,
  attempt_number      INTEGER NOT NULL DEFAULT 1,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 7. analytics_events table (scenario-aware event stream, append-only)
CREATE TABLE IF NOT EXISTS public.analytics_events (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  event_type   TEXT NOT NULL,
  scenario_id  UUID REFERENCES public.scenarios(id) ON DELETE SET NULL,
  unit_id      UUID REFERENCES public.trainings(id) ON DELETE SET NULL,
  metadata     JSONB DEFAULT '{}',
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ─── Indexes for performance ────────────────────────────────────────────────

CREATE INDEX IF NOT EXISTS idx_scenarios_unit_id
  ON public.scenarios(unit_id, order_number);

CREATE INDEX IF NOT EXISTS idx_scenario_options_scenario_id
  ON public.scenario_options(scenario_id);

CREATE INDEX IF NOT EXISTS idx_scenario_responses_user_id
  ON public.scenario_responses(user_id, scenario_id);

CREATE INDEX IF NOT EXISTS idx_scenario_responses_created_at
  ON public.scenario_responses(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_analytics_events_user_id
  ON public.analytics_events(user_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_analytics_events_created_at
  ON public.analytics_events(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_user_regions_user_id
  ON public.user_regions(user_id);

-- ─── RLS: regions ───────────────────────────────────────────────────────────

ALTER TABLE public.regions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone authenticated can read regions"
  ON public.regions FOR SELECT
  USING (auth.uid() IS NOT NULL);

CREATE POLICY "Admins can manage regions"
  ON public.regions FOR ALL
  USING (has_role(auth.uid(), 'admin'));

-- ─── RLS: user_regions ──────────────────────────────────────────────────────

ALTER TABLE public.user_regions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own region assignments"
  ON public.user_regions FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Admins can manage user_regions"
  ON public.user_regions FOR ALL
  USING (has_role(auth.uid(), 'admin'));

-- ─── RLS: scenarios ─────────────────────────────────────────────────────────

ALTER TABLE public.scenarios ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can read active scenarios"
  ON public.scenarios FOR SELECT
  USING (auth.uid() IS NOT NULL AND is_active = true);

CREATE POLICY "Admins can manage all scenarios"
  ON public.scenarios FOR ALL
  USING (has_role(auth.uid(), 'admin'));

-- ─── RLS: scenario_options ──────────────────────────────────────────────────

ALTER TABLE public.scenario_options ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can read scenario options"
  ON public.scenario_options FOR SELECT
  USING (auth.uid() IS NOT NULL);

CREATE POLICY "Admins can manage scenario options"
  ON public.scenario_options FOR ALL
  USING (has_role(auth.uid(), 'admin'));

-- ─── RLS: scenario_responses ────────────────────────────────────────────────

ALTER TABLE public.scenario_responses ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can insert own responses"
  ON public.scenario_responses FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can read own responses"
  ON public.scenario_responses FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Admins can read all responses"
  ON public.scenario_responses FOR SELECT
  USING (has_role(auth.uid(), 'admin'));

-- ─── RLS: analytics_events ──────────────────────────────────────────────────

ALTER TABLE public.analytics_events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can insert own events"
  ON public.analytics_events FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can read own events"
  ON public.analytics_events FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Admins can read all analytics"
  ON public.analytics_events FOR SELECT
  USING (has_role(auth.uid(), 'admin'));
