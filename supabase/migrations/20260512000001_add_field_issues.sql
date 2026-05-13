-- Field Issues table for real-time coach reporting
CREATE TABLE IF NOT EXISTS field_issues (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  coach_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  coach_name TEXT NOT NULL,
  sub_region TEXT NOT NULL,
  issue_type TEXT NOT NULL CHECK (issue_type IN ('app_bug', 'data_issue', 'connectivity', 'other')),
  description TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'in_progress', 'resolved')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  resolved_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Enable RLS
ALTER TABLE field_issues ENABLE ROW LEVEL SECURITY;

-- Coaches can see only their own issues
CREATE POLICY "Coaches see own issues"
  ON field_issues
  FOR SELECT
  USING (auth.uid() = coach_id);

-- Coaches can insert new issues
CREATE POLICY "Coaches can report issues"
  ON field_issues
  FOR INSERT
  WITH CHECK (auth.uid() = coach_id);

-- Service role (admin) can do everything
CREATE POLICY "Admin can manage all issues"
  ON field_issues
  FOR ALL
  USING (auth.jwt() ->> 'role' = 'service_role');

-- Index for lookups
CREATE INDEX idx_field_issues_coach_id ON field_issues(coach_id);
CREATE INDEX idx_field_issues_created_at ON field_issues(created_at DESC);
CREATE INDEX idx_field_issues_status ON field_issues(status);
