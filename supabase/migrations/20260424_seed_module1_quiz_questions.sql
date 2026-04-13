-- Module 1 Quiz Questions Seed
-- NOTE: Full quiz questions with all options are managed via the Admin Panel seedModule1() function
-- This migration is a placeholder to ensure migrations directory is complete
-- The actual quiz data is in src/lib/seedModule1.ts and is deployed via the Admin Panel

BEGIN;

-- Verify Module 1 structure is in place
-- This migration depends on the earlier migrations:
-- - 20260420_ensure_module1_training_units.sql (7 units created)
-- - 20260421_seed_module1_slides_and_scenarios.sql (slides and scenarios seeded)

-- Confirm all 7 units have assessments
INSERT INTO assessments (type, title, training_id)
SELECT 'module_quiz', t.title || ' — Quiz', t.id
FROM trainings t
WHERE t.module_id = (SELECT id FROM modules WHERE order_number = 1)
  AND NOT EXISTS (SELECT 1 FROM assessments WHERE training_id = t.id AND type = 'module_quiz')
ON CONFLICT DO NOTHING;

-- Production quiz data with all 42 questions (6 per unit) and 168 options (4 per question)
-- is available in src/lib/seedModule1.ts
-- To seed this data to staging:
-- 1. Go to Admin Panel (https://staging-url/admin)
-- 2. Click "Seed Module 1" button
-- 3. Function seedModule1() will populate all questions and options

COMMIT;
