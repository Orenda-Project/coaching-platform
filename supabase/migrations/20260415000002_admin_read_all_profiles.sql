-- Allow admin users to read all profiles (bypasses user-scoped RLS)
-- Without this, admins only see their own profile row due to the default RLS policy.

CREATE POLICY "admin_read_all_profiles"
  ON profiles
  FOR SELECT
  USING (
    auth.uid() IN (
      SELECT id FROM profiles WHERE role = 'admin'
    )
  );
