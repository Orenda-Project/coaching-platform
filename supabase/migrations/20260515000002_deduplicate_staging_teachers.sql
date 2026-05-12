-- Remove duplicate teachers on staging
-- Keep only the latest inserted record for each unique teacher (by name, school, region)
-- This removes duplicates created when both 20260507000001 and 20260515000001 ran

DELETE FROM public.teacher_dc_scores
WHERE id IN (
  SELECT id FROM (
    SELECT id, ROW_NUMBER() OVER (PARTITION BY teacher_name, school_name, region ORDER BY created_at DESC) as rn
    FROM public.teacher_dc_scores
  ) t
  WHERE rn > 1
);

-- Verify the cleanup
SELECT COUNT(*) as total_teachers FROM public.teacher_dc_scores;
