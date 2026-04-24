# Staging Deployment: Tab Switch Tracking

## Step 1: Merge PR to Staging ✅
- **PR:** https://github.com/Orenda-Project/coaching-platform/pull/23
- **Action:** Click "Merge pull request" button on GitHub
- **Result:** Code deploys to staging via GitHub Actions automatically

## Step 2: Create Baseline/Endline Trainings
Once the code is deployed, run this SQL on **Staging Supabase** to create the trainings needed for tab switch tracking.

### How to Run SQL on Staging Supabase

1. Open Supabase: https://app.supabase.com/
2. Select the **staging project** (not production)
3. Navigate to **SQL Editor**
4. Click **New Query**
5. Paste the SQL below
6. Click **Run**

### SQL to Execute

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

### Expected Result

You should see 2 rows returned:
```
f47ac10b-58cc-4372-a567-0e02b2c3d479 | Coach Baseline Assessment
f47ac10b-58cc-4372-a567-0e02b2c3d480 | Coach Endline Assessment
```

## Step 3: Test on Staging

### Test URL
- Staging app: `https://staging.coachingplatform.taleemabad.com` (or similar - check Railway)

### Test Checklist

- [ ] **Create test user** or use existing test account
- [ ] **Take baseline assessment**
  - Switch tabs intentionally 4+ times
  - Continue answering questions normally (should NOT restart)
  - Submit baseline
  
- [ ] **Go to admin analytics** (if logged in as admin on staging)
  - Find the test coach
  - Should see **expand button (▶)** in first column
  - Click expand
  - Should see tab switch breakdown:
    ```
    Baseline: 4 | Module Quiz: 0 | Endline: 0
    ```
  
- [ ] **Verify flagging**
  - If tab switches ≥ 3, coach row should have **red background**
  - Flag column should show **⚠️ icon**
  
- [ ] **Test modules** (optional)
  - Take module quiz with tab switches
  - Verify tab switches tracked separately

## Step 4: Production (After Staging Verified)

Once testing is complete on staging:

1. Create PR: `staging` → `main`
2. Get code review approval
3. Merge to main
4. GitHub Actions deploys to production
5. Run same SQL on **production Supabase**
6. Test on production

## Rollback (If Issues Found)

If problems occur on staging:
1. Revert the merge in GitHub
2. The code automatically redeploys without the change
3. No data cleanup needed (trainings can stay)

## Common Issues

### Issue: "Training not found" error in console
**Solution:** SQL wasn't run on Supabase yet. Run the SQL from Step 2.

### Issue: Tab switches showing as 0 on admin dashboard
**Solution:** Make sure:
1. You switched tabs DURING the assessment (not before/after)
2. You see `📍 Tab switch detected (N)` logs in browser console
3. The trainings were created in Supabase

### Issue: Expand button not showing
**Solution:** 
1. Check that tab_switch_count > 0 in database
2. Verify coach has moduleDetails OR total_tab_switches > 0
3. Check AdminAnalytics.tsx line 404 condition
