-- ─────────────────────────────────────────────────────────────────────────────
-- Coach Vacation Engagement Feature Flag
--
-- Purpose:
--   - Coaches always have the 'coach' role (permanent)
--   - BUT: Vacation mode controls whether they see ALL modules or persona-filtered
--   - Feature period: 2026-05-15 → 2026-06-15
--   - After 2026-06-15: coaches revert to persona-based filtering (ONLY)
--   - Coach role stays in database (never deleted)
--
-- Key difference from previous approach:
--   - OLD: Coach role = 'coach' in user_roles, triggers auto-assign on signup
--   - NEW: Coach role = 'coach' (permanent), but vacation_mode flag controls filtering
--   - On rollback: flip the flag, coaches revert to weak_modules filtering
--   - Coach role remains for future use (admin dashboard, etc.)
-- ─────────────────────────────────────────────────────────────────────────────

-- Step 1: Create coach_vacation_config table to control vacation mode
CREATE TABLE IF NOT EXISTS public.coach_vacation_config (
  id BIGINT PRIMARY KEY DEFAULT 1,
  vacation_mode_active BOOLEAN DEFAULT true,
  vacation_start_date TIMESTAMP NOT NULL DEFAULT '2026-05-15'::TIMESTAMP,
  vacation_end_date TIMESTAMP NOT NULL DEFAULT '2026-06-15'::TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  notes TEXT
);

-- Only allow one row in config table
ALTER TABLE public.coach_vacation_config ADD CONSTRAINT only_one_vacation_config CHECK (id = 1);

-- Insert the initial config
INSERT INTO public.coach_vacation_config (vacation_mode_active, vacation_start_date, vacation_end_date, notes)
VALUES (true, '2026-05-15'::TIMESTAMP, '2026-06-15'::TIMESTAMP, 'Coach vacation mode: show all modules. After 2026-06-15, revert to persona-based filtering.')
ON CONFLICT (id) DO NOTHING;

-- Step 2: Grant necessary permissions
GRANT SELECT ON public.coach_vacation_config TO authenticated;
GRANT SELECT ON public.coach_vacation_config TO service_role;

-- ─────────────────────────────────────────────────────────────────────────────
-- IMPORTANT: Coach Role Assignment
-- ─────────────────────────────────────────────────────────────────────────────
-- Coaches are identified by having 'coach' role in user_roles table.
-- This role is PERMANENT and not linked to vacation mode.
--
-- The coach role is assigned:
--   1. Manually (bulk SQL) to existing coaches
--   2. Automatically on signup (via trigger in previous migration)
--
-- The vacation_mode_active flag controls ONLY the Dashboard filtering logic:
--   - vacation_mode_active = true  → coaches see ALL modules (all 6)
--   - vacation_mode_active = false → coaches see persona-filtered modules only
--
-- Coach role stays in user_roles table regardless of vacation mode.
-- ─────────────────────────────────────────────────────────────────────────────

-- Step 3: Rollback instructions (run these on 2026-06-15)
-- ─────────────────────────────────────────────────────────────────────────────
-- ROLLBACK PROCEDURE (on 2026-06-15):
--
-- 1. Disable vacation mode (coaches revert to persona-based filtering):
--    UPDATE public.coach_vacation_config SET vacation_mode_active = false WHERE id = 1;
--
-- 2. Verify coaches now see persona-based trainings:
--    - Log in as a coach
--    - Dashboard should show filtered modules (Module 1 + weak_modules only)
--    - Coach role still exists in user_roles table (not deleted)
--
-- 3. Coach role remains for future use:
--    - Can re-enable vacation mode anytime by setting vacation_mode_active = true
--    - Coach role can be used for admin dashboard access or other features
--
-- ─────────────────────────────────────────────────────────────────────────────
