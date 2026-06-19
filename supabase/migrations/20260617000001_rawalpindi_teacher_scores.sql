-- Rawalpindi cluster coordinator scheduler: teacher scores table
CREATE TABLE IF NOT EXISTS rawalpindi_teacher_scores (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  teacher_name TEXT NOT NULL,
  school_name TEXT NOT NULL,
  emis TEXT,
  cluster_name TEXT NOT NULL,
  aeo_name TEXT,
  cc_mobile TEXT,
  grade TEXT,
  subject TEXT,
  -- 6 HOTS observation indicators (raw scores)
  classroom_management FLOAT NOT NULL DEFAULT 0,
  lesson_planning FLOAT NOT NULL DEFAULT 0,
  instructional_strategies FLOAT NOT NULL DEFAULT 0,
  student_engagement FLOAT NOT NULL DEFAULT 0,
  assessment_feedback FLOAT NOT NULL DEFAULT 0,
  multigrade_setup FLOAT NOT NULL DEFAULT 0,
  -- Aggregate
  total_score FLOAT NOT NULL DEFAULT 0,
  max_total_score FLOAT NOT NULL DEFAULT 51,
  overall_percentage FLOAT NOT NULL DEFAULT 0,
  last_observation_date DATE,
  observation_count INTEGER NOT NULL DEFAULT 0,
  synced_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (teacher_name, school_name, cluster_name)
);

ALTER TABLE rawalpindi_teacher_scores ENABLE ROW LEVEL SECURITY;

CREATE POLICY "authenticated_read_rawalpindi_teachers"
  ON rawalpindi_teacher_scores
  FOR SELECT
  TO authenticated
  USING (true);

CREATE INDEX IF NOT EXISTS idx_rawalpindi_teacher_scores_cluster
  ON rawalpindi_teacher_scores (cluster_name);
