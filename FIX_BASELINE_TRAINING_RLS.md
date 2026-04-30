# Fix: Baseline Training RLS Violation on Production

**Bug:** Coach users get error 42501 (RLS violation) after submitting baseline assessment.

**Root Cause:** The production Supabase database is missing the seeded baseline/endline training records. Migration 20260505000001_add_baseline_endline_trainings.sql exists in code but was never applied to production.

When a coach submits baseline:
1. Code queries for "Coach Baseline Assessment" training → finds nothing (migration not applied)
2. Code tries to INSERT the training as a fallback
3. INSERT fails with error 42501 because coach doesn't have `admin` role (only admins can insert trainings)

**Status:** 🔧 **NEEDS FIX** — Apply migration 20260505000001 to production Supabase.

---

## Step 1: Access Production Supabase

1. Go to [https://supabase.com/dashboard/projects](https://supabase.com/dashboard/projects)
2. Select your **production** project (likely named `agziuwqpkfmxtospfxns`)
3. Click **SQL Editor** in the left sidebar

---

## Step 2: Run the Migration SQL

Copy and paste this into the SQL editor:

```sql
-- Create baseline and endline training records for tab switch tracking
-- These trainings are special - they don't have content but allow tracking in training_progress

-- Get or create baseline training
INSERT INTO public.trainings (id, title, description, order_number, is_common)
VALUES (
  'f47ac10b-58cc-4372-a567-0e02b2c3d479'::UUID,
  'Coach Baseline Assessment',
  'Baseline assessment for coaching program',
  0,
  true
)
ON CONFLICT (id) DO NOTHING;

-- Get or create endline training
INSERT INTO public.trainings (id, title, description, order_number, is_common)
VALUES (
  'f47ac10b-58cc-4372-a567-0e02b2c3d480'::UUID,
  'Coach Endline Assessment',
  'Endline assessment for coaching program',
  999,
  true
)
ON CONFLICT (id) DO NOTHING;

-- Link baseline assessment to baseline training
UPDATE public.assessments
SET training_id = 'f47ac10b-58cc-4372-a567-0e02b2c3d479'::UUID
WHERE type = 'baseline' AND training_id IS NULL;

-- Link endline assessment to endline training
UPDATE public.assessments
SET training_id = 'f47ac10b-58cc-4372-a567-0e02b2c3d480'::UUID
WHERE type = 'endline' AND training_id IS NULL;
```

Click **Run** (or Ctrl+Enter).

---

## Step 3: Verify the Fix

After the SQL completes successfully, verify:

```sql
SELECT id, title, order_number, is_common
FROM public.trainings
WHERE title IN ('Coach Baseline Assessment', 'Coach Endline Assessment')
ORDER BY title;
```

**Expected output:** Two rows:
```
id: f47ac10b-58cc-4372-a567-0e02b2c3d479, title: Coach Baseline Assessment, order_number: 0, is_common: true
id: f47ac10b-58cc-4372-a567-0e02b2c3d480, title: Coach Endline Assessment, order_number: 999, is_common: true
```

---

## Step 4: Test the Fix

After the trainings are seeded:

1. **Reload the app** (hard refresh: Ctrl+Shift+Delete, then F5)
2. **Sign up or login as a coach** (non-admin user)
3. **Start baseline assessment**
4. **Answer questions and submit baseline**
5. **✅ Expected:** Redirect to dashboard with baseline result shown
6. **❌ If error still appears:** Check Step 3 verification — trainings must exist

---

## Step 5: Monitor Production

After the fix:
- Monitor error logs for error 42501 (should disappear)
- Verify coaches can complete baseline submissions
- Check training_progress table — records should be created for each coach's baseline attempt

---

## Root Cause Analysis

**Why this happened:**
- Migration 20260505000001 seeds the baseline/endline trainings
- Migration exists in the code repository
- But it was never applied to the production Supabase database
- Baseline submission code assumes these trainings exist (they should be seeded)
- When they don't exist, code tries to CREATE them as a fallback
- The CREATE attempt fails because coaches don't have admin role
- RLS policy correctly prevents non-admin inserts → error 42501

**Prevention:**
- Migrations should be auto-applied by CI/CD on deploy
- If not auto-applied, manually apply via Supabase console before code deployment that depends on the schema
- Always verify new migrations are in production before code using them ships

---

## Related Files

- Migration source: `supabase/migrations/20260505000001_add_baseline_endline_trainings.sql`
- Code: `src/pages/Assessment.tsx` (saveAssessmentProgress function)
- Test: `src/data/baseline-training-rls.test.ts` (regression test)
- Bug tracking: `docs/memory/bugs.md`
- QA risks: `docs/memory/qa-risks.md`

---

## Timeline

- **Bug report:** Coach gets 42501 error after baseline submission
- **Root cause:** Migration 20260505000001 not applied to production
- **Fix:** Apply migration via Supabase SQL console
- **Applied:** [DATE YOU RUN THIS]
- **Verified:** [DATE YOU TEST]
