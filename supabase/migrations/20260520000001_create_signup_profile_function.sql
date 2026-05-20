-- Migration: Create profile creation function with admin context
-- Purpose: Allow profile creation immediately after signup without RLS blocking
-- Issue: RLS policy requires auth.uid() = id, but new users aren't fully authenticated yet

CREATE OR REPLACE FUNCTION public.create_profile_after_signup(
  user_id UUID,
  phone_value TEXT,
  full_name_value TEXT DEFAULT NULL
)
RETURNS TABLE(id UUID, phone TEXT, full_name TEXT, created_at TIMESTAMP)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (id, phone, full_name)
  VALUES (user_id, phone_value, full_name_value)
  ON CONFLICT (id) DO UPDATE
  SET phone = EXCLUDED.phone,
      full_name = COALESCE(EXCLUDED.full_name, public.profiles.full_name)
  RETURNING public.profiles.id, public.profiles.phone, public.profiles.full_name, public.profiles.created_at
  INTO id, phone, full_name, created_at;

  RETURN NEXT;
END;
$$;

-- Grant access to authenticated users (they can call this RPC after signup)
GRANT EXECUTE ON FUNCTION public.create_profile_after_signup(UUID, TEXT, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.create_profile_after_signup(UUID, TEXT, TEXT) TO anon;

-- Comment for clarity
COMMENT ON FUNCTION public.create_profile_after_signup(UUID, TEXT, TEXT) IS
'Creates a user profile after signup. Uses SECURITY DEFINER to bypass RLS since newly-created users may not have active sessions yet.';
