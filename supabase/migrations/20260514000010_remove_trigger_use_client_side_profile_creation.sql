-- Fix: Remove the problematic trigger and use client-side profile creation
-- The trigger has consistently failed due to PostgreSQL transaction/metadata issues
-- Solution: Client directly creates profile after signup completes

-- Drop the trigger and function
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();

-- Make sure phone is nullable (allow profile creation without phone initially)
ALTER TABLE public.profiles
  ALTER COLUMN phone DROP NOT NULL;

-- RLS policy already allows INSERT if auth.uid() = id, so client can create their own profile
-- No changes needed to RLS - it already supports this pattern

-- Note: Client will now call:
-- INSERT INTO profiles (id, phone, full_name) VALUES (user_id, phone_value, full_name_value)
-- after signup succeeds. The RLS policy will verify auth.uid() = id.
