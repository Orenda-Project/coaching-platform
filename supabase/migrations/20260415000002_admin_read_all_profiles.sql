-- Allow admin users (from user_roles table) to read all profiles and training_progress.
-- Without this, Supabase RLS silently filters rows to only the current user's own data.

DROP POLICY IF EXISTS "admin_read_all_profiles" ON profiles;
CREATE POLICY "admin_read_all_profiles"
  ON profiles
  FOR SELECT
  USING (
    auth.uid() IN (
      SELECT user_id FROM user_roles WHERE role = 'admin'
    )
  );

DROP POLICY IF EXISTS "admin_read_all_training_progress" ON training_progress;
CREATE POLICY "admin_read_all_training_progress"
  ON training_progress
  FOR SELECT
  USING (
    auth.uid() IN (
      SELECT user_id FROM user_roles WHERE role = 'admin'
    )
  );
