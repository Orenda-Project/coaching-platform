-- Backfill coach_assignments for all coaches who have sub_region in profile but no assignment

INSERT INTO public.coach_assignments (coach_id, region, sub_region)
SELECT 
  p.id,
  'ICT' as region,
  COALESCE(p.sub_region, 'Islamabad') as sub_region
FROM public.profiles p
LEFT JOIN public.coach_assignments ca ON p.id = ca.coach_id
WHERE p.id IN (
  SELECT id FROM auth.users 
  WHERE raw_user_meta_data->>'role' = 'coach'
)
AND ca.id IS NULL
AND p.sub_region IS NOT NULL
ON CONFLICT (coach_id) DO NOTHING;
