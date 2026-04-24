# Setup Baseline/Endline Trainings for Tab Switch Tracking

## Problem
The admin dashboard needs to track tab switches from baseline and endline assessments. This requires baseline/endline trainings in the `trainings` table.

## Solution
Run the SQL below in Supabase Studio (as admin) to create these trainings.

## SQL to Run

Go to: **Supabase Dashboard → SQL Editor → New Query**

Paste and execute:

```sql
-- Create baseline training
INSERT INTO public.trainings (id, title, description, order_number, is_common)
VALUES (
  'f47ac10b-58cc-4372-a567-0e02b2c3d479'::UUID,
  'Coach Baseline Assessment',
  'Baseline assessment for coaching program',
  0,
  true
)
ON CONFLICT (id) DO NOTHING;

-- Create endline training
INSERT INTO public.trainings (id, title, description, order_number, is_common)
VALUES (
  'f47ac10b-58cc-4372-a567-0e02b2c3d480'::UUID,
  'Coach Endline Assessment',
  'Endline assessment for coaching program',
  999,
  true
)
ON CONFLICT (id) DO NOTHING;

-- Verify they were created
SELECT id, title FROM public.trainings 
WHERE title ILIKE '%Baseline%' OR title ILIKE '%Endline%';
```

## Verification

After running, you should see 2 rows:
```
f47ac10b-58cc-4372-a567-0e02b2c3d479 | Coach Baseline Assessment
f47ac10b-58cc-4372-a567-0e02b2c3d480 | Coach Endline Assessment
```

## Testing

Once trainings are created:
1. Take baseline assessment, switch tabs 4+ times
2. Submit baseline
3. Go to admin analytics dashboard
4. Find the coach - should see expand button (▶)
5. Click expand - should see "Baseline: 4 | Module: 0 | Endline: 0"
