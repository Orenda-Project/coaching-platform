-- Add rawalpindi_cluster field to profiles for Rawalpindi cluster coordinator assignment
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS rawalpindi_cluster TEXT;

COMMENT ON COLUMN profiles.rawalpindi_cluster IS 'Cluster (markaz) name for Rawalpindi CCs. Must match cluster_name in rawalpindi_teacher_scores. Set by admin.';
