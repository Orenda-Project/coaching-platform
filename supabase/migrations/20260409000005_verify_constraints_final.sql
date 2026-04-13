-- Verification query (informational only, shows what constraints exist)
-- Run this in SQL Editor to verify constraints are properly set

-- Check training_content constraint
SELECT constraint_name, constraint_type
FROM information_schema.table_constraints
WHERE table_name = 'training_content' AND constraint_type = 'CHECK';

-- Check assessments constraints
SELECT constraint_name, constraint_type
FROM information_schema.table_constraints
WHERE table_name = 'assessments' AND constraint_type IN ('CHECK', 'UNIQUE');
