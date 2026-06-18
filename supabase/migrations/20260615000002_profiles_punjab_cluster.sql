-- Add punjab_cluster field to profiles for cluster coordinator assignment
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS punjab_cluster TEXT;

COMMENT ON COLUMN profiles.punjab_cluster IS 'Cluster name for Punjab cluster coordinators. Must match cluster_name in punjab_teacher_scores. Set by admin.';
