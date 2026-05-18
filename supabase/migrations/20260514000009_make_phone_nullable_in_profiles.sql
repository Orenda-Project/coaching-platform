-- Fix: Make phone column nullable so trigger can create profile without phone
-- Root cause: profiles.phone is NOT NULL, trigger fails if it can't extract phone from metadata
-- Solution: Allow NULL phone initially, client updates it after signup confirmation

-- First, simplify the trigger to NOT try to extract metadata (which fails)
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();

-- Create simple trigger that just creates an empty profile
CREATE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id)
  VALUES (NEW.id);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Recreate the trigger
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- Make phone nullable so profile can be created without phone
ALTER TABLE public.profiles
  ALTER COLUMN phone DROP NOT NULL;

-- Add a CHECK to allow NULL or non-empty text (if needed later)
-- For now, just make it nullable
