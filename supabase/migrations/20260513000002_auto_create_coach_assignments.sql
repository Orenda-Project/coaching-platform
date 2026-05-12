-- Update handle_new_user function to auto-create coach_assignments

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  -- Insert profile
  INSERT INTO public.profiles (id, email, role, first_name, last_name, school_name)
  VALUES (
    new.id,
    new.email,
    COALESCE(new.raw_user_meta_data->>'role', 'coach'),
    new.raw_user_meta_data->>'first_name',
    new.raw_user_meta_data->>'last_name',
    new.raw_user_meta_data->>'school_name'
  );

  -- Auto-create coach_assignments for coaches (default to ICT region)
  IF COALESCE(new.raw_user_meta_data->>'role', 'coach') = 'coach' THEN
    INSERT INTO public.coach_assignments (coach_id, region, sub_region)
    VALUES (
      new.id,
      'ICT',
      COALESCE(new.raw_user_meta_data->>'sub_region', 'Islamabad')
    )
    ON CONFLICT (coach_id) DO NOTHING;
  END IF;

  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
