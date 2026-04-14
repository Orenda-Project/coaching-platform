# Quick Verification Guide — Module 1 + Assessment Fixes

## 2-Minute Verification Checklist

### Step 1: Check Baseline Assessment (2 min)
```
1. Sign in: jalal.khan@taleemabad.com
2. Go to assessment (if not auto-redirected)
3. Complete baseline (~1-2 min, answer ~60%+ to pass)
4. Click Submit
→ Should see BaselineResultsCard with score, persona, weak modules
   ❌ If you see "Attempt Baseline" again = Error (check network tab for 400)
```

### Step 2: Verify localStorage Clear (30 sec)
```
1. In assessment, fail attempt (<60%)
2. Refresh or go back to assessment
→ Should start from Q1, not last question
   ❌ If resuming from middle = localStorage not cleared
```

### Step 3: Check Module 1 Units (1 min)
```
1. From dashboard, expand Module 1
→ Should see "7/7 Units":
   - Unit 1.0: The Coaching Catalyst
   - Unit 1.1: Observation & Data Collection
   - Unit 1.2: The Calibration Process
   - Unit 1.3: Feedback with Empathy
   - Unit 1.4: Co-Designing Action Steps
   - Unit 1.5: Documentation & Follow-up
   - Unit 1.6: Building Habits & Mastery
   ❌ If seeing "No training units" = Migration not applied
```

### Step 4: Check Slides + Scenarios (30 sec)
```
1. Click Unit 1.0
→ Should see sections:
   - Slides (with Google Docs link)
   - Scenario (coaching dilemma)
   - Quiz (6 questions)
   ❌ If empty = Slides/scenarios not seeded
```

### Step 5: Run Admin Seed (Optional, 1 min)
```
1. Go to Admin Panel
2. Find "Seed Module 1" button
3. Click it
→ Should log completion
→ All units now have full production content
```

---

## Database Queries (if you need to debug)

### Check weak_modules column exists
```sql
SELECT column_name FROM information_schema.columns
WHERE table_name = 'profiles' AND column_name = 'weak_modules';
-- Should return 1 row
```

### Check Modules 2-6 exist
```sql
SELECT count(*) FROM modules WHERE order_number BETWEEN 2 AND 6;
-- Should return 5 rows
```

### Check training units exist
```sql
SELECT count(*) FROM trainings WHERE module_id = (
  SELECT id FROM modules WHERE title LIKE 'Module 1:%' LIMIT 1
);
-- Should return 7 rows
```

### Check slides + scenarios seeded
```sql
SELECT format_type, count(*) FROM training_content
WHERE training_id IN (
  SELECT id FROM trainings WHERE module_id = (
    SELECT id FROM modules WHERE title LIKE 'Module 1:%'
  )
)
GROUP BY format_type;
-- Should show: slide=7, scenario=7
```

---

## Common Issues & Fixes

| Issue | Cause | Fix |
|-------|-------|-----|
| "Attempt Baseline" after passing | Profile UPDATE failed (400 error) | Check browser network tab, migrate 20260419 |
| Resume from Q29 instead of Q1 | localStorage not cleared | Clear browser localStorage, submit > check fail() |
| Module 1 shows "No units" | Migration not applied | Run: `supabase db push` |
| Slides/scenarios empty | Production data not seeded | Click Admin "Seed Module 1" button |
| Weak modules not in dashboard | Prefix matching not working | Check Dashboard.tsx line 63 |

---

## Files Modified (for reference)

```
src/pages/Assessment.tsx
  Line 93: checkEndlineEligibility() — prefix match weak_modules
  Line 229: Clear localStorage on baseline fail
  Line 259: Clear localStorage on baseline pass
  Line 272: Clear localStorage on endline fail
  Line 314: Clear localStorage on endline pass
  Lines 252-257: Error handling for profile UPDATE

src/pages/Dashboard.tsx
  Line 63: Prefix matching: m.title.startsWith(wm)

supabase/migrations/
  20260419_fix_profiles_schema_and_seed_modules.sql
  20260420_ensure_module1_training_units.sql
  20260421_seed_module1_slides_and_scenarios.sql
```

---

## Support

**If something is broken:**

1. Check the git commits:
   ```bash
   git log --oneline | head -5
   # Should show: a131f9f edbb982 f40be8c e7f6292
   ```

2. Check migrations were applied:
   ```bash
   supabase migration list
   # Should show all 3 new migrations as "Applied"
   ```

3. Read the detailed docs:
   - `BASELINE_ASSESSMENT_FIXES.md` — Full bug explanation + fixes
   - `SEED_MODULE1_PRODUCTION_DATA.md` — How to seed production content

---

**Everything is committed, tested, and ready. Good luck!** ✅
