-- Sync coach assignments from profiles.sub_region
-- This trigger ensures that whenever a coach sets or updates their sub_region in the profiles table,
-- a corresponding row is automatically created/updated in coach_assignments.

-- Part 1: Create the trigger function
CREATE OR REPLACE FUNCTION sync_coach_assignment_from_profile()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.sub_region IS NOT NULL AND NEW.sub_region <> '' THEN
    INSERT INTO coach_assignments (coach_id, sub_region, region)
    VALUES (NEW.id, NEW.sub_region, COALESCE(NEW.region, 'ICT'))
    ON CONFLICT (coach_id) DO UPDATE SET
      sub_region = EXCLUDED.sub_region,
      region = EXCLUDED.region;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Part 2: Attach trigger to profiles table
CREATE TRIGGER trg_sync_coach_assignment
  AFTER INSERT OR UPDATE OF sub_region ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION sync_coach_assignment_from_profile();

-- Part 3: Backfill existing coaches who already have sub_region set
INSERT INTO coach_assignments (coach_id, sub_region, region)
SELECT id, sub_region, COALESCE(region, 'ICT')
FROM profiles
WHERE sub_region IS NOT NULL AND sub_region <> ''
ON CONFLICT (coach_id) DO UPDATE SET
  sub_region = EXCLUDED.sub_region,
  region = EXCLUDED.region;
