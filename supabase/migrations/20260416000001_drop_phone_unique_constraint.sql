-- Drop unique constraint on phone — phone numbers are not globally unique
-- (multiple coaches in same household, shared numbers) and it blocks signup
-- when a partial/failed signup leaves a ghost profile with that phone.
ALTER TABLE profiles DROP CONSTRAINT IF EXISTS profiles_phone_key;
