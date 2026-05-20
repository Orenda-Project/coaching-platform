-- Fix: Add SECURITY DEFINER to assign_coach_role_on_signup trigger function
--
-- Issue: The assign_coach_role_on_signup trigger was failing in production with:
-- "ERROR: permission denied for table coach_role_config (SQLSTATE 42501)"
--
-- Root Cause: The trigger function tried to read coach_role_config table without SECURITY DEFINER.
-- When an anon user (new signup) triggered the function, it ran as anon role and couldn't access
-- the table. The trigger is invoked by auth.users INSERT, which happens before user is authenticated.
--
-- Solution: Add SECURITY DEFINER to the trigger function so it runs with elevated privileges
-- and can access coach_role_config regardless of caller's role.
--
-- Impact: Signup will now work correctly and coaches will be auto-assigned the 'coach' role
-- if the feature is active (coach_role_config.is_active = true).

DROP TRIGGER IF EXISTS assign_coach_role_on_signup ON auth.users;
DROP FUNCTION IF EXISTS public.assign_coach_role_on_signup();

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
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Recreate the trigger
CREATE TRIGGER assign_coach_role_on_signup
AFTER INSERT ON auth.users
FOR EACH ROW
EXECUTE FUNCTION public.assign_coach_role_on_signup();
