-- ─────────────────────────────────────────────────────────────────────────────
-- Coach Vacation Engagement Feature: Auto-Assign Coach Role with Date-Based Rollback
--
-- Purpose:
--   - Automatically assign 'coach' role to new users (coaches only signup)
--   - Feature starts: 2026-05-15
--   - Rollback scheduled: 2026-06-15 (one month)
--   - After rollback: coaches see persona-based trainings again (not all modules)
--
-- Implementation:
--   1. Create coach_role_config table to control feature toggle
--   2. Create trigger function that respects the feature flag
--   3. Trigger runs on auth.users INSERT → assigns 'coach' role if feature is active
--   4. On 2026-06-15: disable feature (coach_role_config.is_active = false)
--   5. Delete existing coach roles to revert to persona-based filtering
-- ─────────────────────────────────────────────────────────────────────────────

-- Step 1: Create config table to control the coach role feature
CREATE TABLE IF NOT EXISTS public.coach_role_config (
  id BIGINT PRIMARY KEY DEFAULT 1,
  is_active BOOLEAN DEFAULT true,
  feature_start_date TIMESTAMP NOT NULL DEFAULT '2026-05-15'::TIMESTAMP,
  feature_end_date TIMESTAMP NOT NULL DEFAULT '2026-06-15'::TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  notes TEXT
);

-- Only allow one row in config table
ALTER TABLE public.coach_role_config ADD CONSTRAINT only_one_config CHECK (id = 1);

-- Insert the initial config
INSERT INTO public.coach_role_config (is_active, feature_start_date, feature_end_date, notes)
VALUES (true, '2026-05-15'::TIMESTAMP, '2026-06-15'::TIMESTAMP, 'Coach vacation engagement: show all modules to coaches')
ON CONFLICT (id) DO NOTHING;

-- Step 2: Create trigger function to auto-assign coach role on signup
CREATE OR REPLACE FUNCTION public.assign_coach_role_on_signup()
RETURNS TRIGGER AS $$
DECLARE
  feature_active BOOLEAN;
BEGIN
  -- Check if the coach role feature is active
  SELECT is_active INTO feature_active
  FROM public.coach_role_config
  WHERE id = 1;

  -- If feature is active, assign coach role to the new user
  IF feature_active THEN
    INSERT INTO public.user_roles (user_id, role)
    VALUES (NEW.id, 'coach')
    ON CONFLICT (user_id, role) DO NOTHING;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Step 3: Create trigger on auth.users insert
DROP TRIGGER IF EXISTS assign_coach_role_on_signup ON auth.users;
CREATE TRIGGER assign_coach_role_on_signup
AFTER INSERT ON auth.users
FOR EACH ROW
EXECUTE FUNCTION public.assign_coach_role_on_signup();

-- Step 4: Grant necessary permissions
GRANT SELECT ON public.coach_role_config TO authenticated;
GRANT SELECT ON public.coach_role_config TO service_role;

-- Step 5: Rollback instructions (run these on 2026-06-15)
-- ─────────────────────────────────────────────────────────────────────────────
-- ROLLBACK PROCEDURE (on 2026-06-15):
--
-- 1. Disable the feature:
--    UPDATE public.coach_role_config SET is_active = false WHERE id = 1;
--
-- 2. Remove all coach roles (revert to persona-based filtering):
--    DELETE FROM public.user_roles WHERE role = 'coach';
--
-- 3. Verify coaches now see persona-based trainings:
--    - Log in as a coach
--    - Dashboard should show filtered modules (based on weak_modules, not all)
--    - Persona E users still see all modules (as before)
--
-- 4. Delete the trigger and config (optional cleanup):
--    DROP TRIGGER IF EXISTS assign_coach_role_on_signup ON auth.users;
--    DROP FUNCTION IF EXISTS public.assign_coach_role_on_signup();
--    DROP TABLE IF EXISTS public.coach_role_config;
-- ─────────────────────────────────────────────────────────────────────────────
