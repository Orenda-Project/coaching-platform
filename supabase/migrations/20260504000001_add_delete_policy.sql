-- Allow coaches to delete their own observations
CREATE POLICY "Coaches can delete own observations"
  ON public.cot_observations FOR DELETE
  USING (auth.uid() = observer_id);
