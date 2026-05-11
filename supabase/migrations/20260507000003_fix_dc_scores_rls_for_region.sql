-- Fix RLS on teacher_dc_scores: change from observer-based to region-based filtering
-- Coaches now see teachers in their assigned sub_region, not just teachers they observed

DROP POLICY IF EXISTS "coaches see own dc scores" ON public.teacher_dc_scores;

CREATE POLICY "coaches see teachers in assigned sub_region"
  ON public.teacher_dc_scores
  FOR SELECT
  USING (
    region = (
      SELECT sub_region FROM public.coach_assignments
      WHERE coach_id = auth.uid() LIMIT 1
    )
  );

-- Allow coaches to write their own assignment row at signup
CREATE POLICY "coaches insert own assignment"
  ON public.coach_assignments
  FOR INSERT
  WITH CHECK (coach_id = auth.uid());
