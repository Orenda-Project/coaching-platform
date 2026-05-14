-- Fix: Correct the trigger to only use columns that actually exist
-- Error was: column "email" of relation "profiles" does not exist
-- The issue: trigger was confusing NEW.email (from auth.users) with profiles.email (doesn't exist)

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();

-- Create corrected function
-- Only insert the columns that actually exist in profiles table:
-- id, phone, full_name (and optionals: persona, baseline_completed, etc.)
CREATE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  v_phone TEXT;
  v_full_name TEXT;
BEGIN
  -- Extract phone from auth metadata
  -- Fallback: if phone not in metadata, use email from auth.users
  v_phone := COALESCE(
    NEW.raw_user_meta_data->>'phone',  -- Get phone from signup metadata
    NEW.email                            -- Fallback to email if phone missing
  );

  -- Extract full_name from auth metadata (can be NULL)
  v_full_name := NEW.raw_user_meta_data->>'full_name';

  -- Insert only if we have a valid phone
  -- profiles table columns: id, phone, full_name, persona, baseline_completed, endline_completed, created_at, updated_at
  IF v_phone IS NOT NULL AND NEW.id IS NOT NULL THEN
    INSERT INTO public.profiles (id, phone, full_name)
    VALUES (NEW.id, v_phone, v_full_name);
  END IF;

  RETURN NEW;
EXCEPTION WHEN OTHERS THEN
  -- Log the error (will appear in Supabase logs)
  RAISE WARNING 'Error in handle_new_user trigger: % %', SQLSTATE, SQLERRM;
  RAISE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Recreate the trigger
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();
