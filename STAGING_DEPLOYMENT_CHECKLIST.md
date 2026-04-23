# Staging Deployment Checklist: 18-Question Baseline

**Status:** Ready for staging deployment  
**PR:** #15 (staging branch)  
**Migration:** `20260423_reduce_baseline_to_18_questions.sql`  
**Date:** 2026-04-23

---

## Current Situation

✅ **What's done:**
- Migration file created and tested (syntax valid)
- Answer key verified (18 correct answers)
- PR #15 opened to staging branch
- Your local frontend still sees 30 questions because:
  - You're connected to staging Supabase
  - Migration hasn't been deployed yet
  - Need to merge PR #15 or run migration manually

---

## Option 1: Merge PR #15 to Staging (Recommended)

### Steps:
1. Go to GitHub: https://github.com/Orenda-Project/coaching-platform/pull/15
2. Click **"Merge pull request"** → confirm
3. This triggers automatic deployment to staging
4. **Wait 2-5 minutes** for Supabase migrations to apply
5. Refresh your browser → should see **18 questions** ✅

### What happens:
- PR merges to `staging` branch
- CI/CD pipeline runs migrations
- Migration `20260423_reduce_baseline_to_18_questions.sql` executes
- Old 30 questions deleted, new 18 questions created
- Your app automatically picks up changes

---

## Option 2: Manually Apply Migration to Staging (Faster but requires direct DB access)

If you have Supabase Admin credentials for staging, run directly in Supabase SQL editor:

### Steps:
1. Go to Supabase Studio → staging project
2. Click **SQL Editor**
3. Click **New Query**
4. Copy & paste entire contents of: `supabase/migrations/20260423_reduce_baseline_to_18_questions.sql`
5. Click **Run**
6. Verify:
   ```sql
   SELECT COUNT(*) FROM public.questions 
   WHERE assessment_id IN (SELECT id FROM public.assessments WHERE type='baseline');
   -- Should return: 18
   ```
7. Refresh your app → should see **18 questions** ✅

---

## Option 3: Deploy Locally First (If Docker is running)

### Steps:
1. Ensure Docker Desktop is running
2. Run: `supabase db reset`
3. This applies all migrations including the new one
4. Test locally: `npm run dev`
5. Then merge PR #15 to push to staging

---

## What to Verify After Deployment

### In Supabase Studio (staging):
```sql
-- Should return 18
SELECT COUNT(*) FROM public.questions 
WHERE assessment_id IN (SELECT id FROM public.assessments WHERE type='baseline');

-- Should return 72 (18 × 4 options)
SELECT COUNT(*) FROM public.options 
WHERE question_id IN (
  SELECT id FROM public.questions 
  WHERE assessment_id IN (SELECT id FROM public.assessments WHERE type='baseline')
);

-- Should return 18 (one correct per question)
SELECT COUNT(*) FROM public.options 
WHERE is_correct = TRUE 
AND question_id IN (
  SELECT id FROM public.questions 
  WHERE assessment_id IN (SELECT id FROM public.assessments WHERE type='baseline')
);
```

### In Your App (connected to staging):
1. **Clear browser cache:** Ctrl+Shift+Delete → Clear cached data
2. **Refresh page:** F5 or Cmd+R
3. **Signup & start baseline assessment**
4. **Verify:**
   - [ ] See **18 questions** instead of 30
   - [ ] Questions are from the simplified list (Modules 2-6)
   - [ ] Answer 16+ correctly → "Pass" message
   - [ ] Answer <16 correctly → "Fail, retry" message
   - [ ] Dashboard shows baseline result

---

## Pre-Baseline Instructions Update

**Note:** You also mentioned updating instructions BEFORE baseline. Let me check what instructions you're referring to.

**Current baseline shows:**
- Title: "Coach Baseline Assessment"
- Subtitle: "Welcome to Your Assessment"
- Description: "A quick assessment to understand your coaching profile and identify areas for growth."
- Pass threshold: "60%" (but should be "85%" for 18-question version)

**Need to update:**
1. Pass threshold text: 60% → 85% (since new baseline is harder with better questions)
2. Time estimate: ~10 minutes (was same for 30 Qs, should be ~10-15 min for 18)
3. Questions count: 30 → 18

### Where to find these:
- **File:** `src/pages/Assessment.tsx` (or similar)
- **Search for:** "Pass threshold", "Questions:", "Time needed"
- **Update:**
  ```
  Pass threshold: 85%        (was 60%)
  Questions: 18              (was 30)
  Time needed: ~15 minutes   (was ~10 minutes)
  ```

---

## Quick Summary

| Step | Action | Status |
|------|--------|--------|
| 1 | Create migration | ✅ Done |
| 2 | Verify syntax | ✅ Done |
| 3 | Create PR #15 | ✅ Done |
| **4** | **Merge PR #15 to staging** | ⏳ **WAITING** |
| **5** | **Verify 18 questions in staging** | ⏳ **WAITING** |
| **6** | **Update pre-baseline instructions** | ⏳ **TODO** |
| 7 | Run E2E tests on staging | ⏳ TODO |
| 8 | Create PR #14 to main | ✅ Done (awaiting approval) |
| 9 | Merge to main → prod | ⏳ TODO |

---

## Next Steps

**What I recommend:**
1. Merge PR #15 to staging (takes 2 minutes)
2. Wait 2-5 minutes for deployment
3. Test in your app (refresh, clear cache)
4. Update pre-baseline instructions (10 min coding)
5. Run E2E tests
6. Then we can merge to main

**Ready?** I can help with any of these steps!
