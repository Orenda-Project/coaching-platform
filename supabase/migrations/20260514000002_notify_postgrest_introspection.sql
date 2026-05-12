-- Notify PostgREST to reload schema introspection
-- by updating the watch table (if it exists)

DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'pgrst' AND table_name = 'watch') THEN
    INSERT INTO pgrst.watch(name) VALUES (gen_random_uuid()::text);
  END IF;
END $$;

-- Also explicitly grant permissions on the new tables to ensure REST API can see them
GRANT SELECT ON public.teacher_dc_scores TO anon, authenticated;
GRANT SELECT ON public.cot_observations TO anon, authenticated;
