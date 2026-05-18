-- Fix: Update handle_new_user trigger to read phone from auth metadata
-- Root cause: Client passes phone in auth metadata, but trigger was reading from auth.users.phone column
-- This migration updates the trigger to read phone from metadata like full_name
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, phone, full_name)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'phone', NEW.email),
    NEW.raw_user_meta_data->>'full_name'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;
