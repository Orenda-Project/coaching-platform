-- Fix: Add error handling and safe NULL checking to trigger
-- The issue might be that raw_user_meta_data is JSONB and needs safe extraction

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();

-- Create improved function with explicit NULL handling
CREATE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  v_phone TEXT;
  v_full_name TEXT;
BEGIN
  -- Safely extract phone from metadata, with fallback to email
  -- Handle both JSONB extraction and missing keys
  v_phone := COALESCE(
    NEW.raw_user_meta_data->>'phone',  -- Extract from metadata
    NEW.phone,                           -- Fallback to auth.users.phone if set
    NEW.email                            -- Final fallback to email
  );

  -- Safely extract full_name from metadata (can be NULL)
  v_full_name := NEW.raw_user_meta_data->>'full_name';

  -- Only insert if we have a valid phone and user ID
  -- This prevents NULL phone values which would violate NOT NULL constraint
  IF v_phone IS NOT NULL AND NEW.id IS NOT NULL THEN
    INSERT INTO public.profiles (id, phone, full_name)
    VALUES (NEW.id, v_phone, v_full_name);
  END IF;

  RETURN NEW;
EXCEPTION WHEN OTHERS THEN
  -- Log the error for debugging (will appear in Supabase logs)
  RAISE WARNING 'Error in handle_new_user trigger: % %', SQLSTATE, SQLERRM;
  -- Re-raise the error so signup knows there was a problem
  RAISE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Recreate the trigger
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();
