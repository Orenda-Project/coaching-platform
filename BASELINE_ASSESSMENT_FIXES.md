# Baseline Assessment Bug Fixes — Complete

## Summary

Fixed 4 critical bugs in the baseline assessment flow that prevented users from viewing their results on the dashboard and caused assessment attempts to resume from the wrong question.

## Bugs Fixed

### 1. **Dashboard shows "Attempt Baseline" again after passing** ❌ FIXED

**Root Cause:**
- `weak_modules` column didn't exist in `profiles` table
- Profile UPDATE at Assessment.tsx:240-250 returned 400 error (silently caught by try/catch)
- Since UPDATE failed, `baseline_completed` stayed `false`
- Dashboard checked `baseline_completed` and showed CTA instead of results

**Fix:**
- Added `weak_modules TEXT[] NOT NULL DEFAULT '{}'` to profiles table (migration)
- Added error handling for UPDATE: check return value and show toast if error (Assessment.tsx:252-257)

**Verification:**
```bash
1. Sign in as jalal.khan@taleemabad.com
2. Complete baseline assessment → Submit
3. Check network tab — no 400 errors
4. Dashboard shows BaselineResultsCard with score, persona, weak modules
```

---

### 2. **Assessment resumes from wrong question on retry** ❌ FIXED

**Root Cause:**
- localStorage auto-saved every 5 seconds (Assessment.tsx:51-66)
- After failed attempt (pct < 60%), localStorage was never cleared
- On retry, `loadQuestions()` found old `currentIndex: 29` and restored it
- User had to start from Q29 instead of Q1

**Fix:**
- Clear localStorage on failed attempt: `localStorage.removeItem()` (Assessment.tsx:229)
- Clear localStorage on failed endline attempt (Assessment.tsx:272)
- Clear localStorage on successful baseline submission (Assessment.tsx:259)
- Clear localStorage on successful endline submission (Assessment.tsx:314)

**Verification:**
```bash
1. Complete baseline but answer <60% → Submit (fails)
2. Dashboard shows error toast
3. Re-open assessment
4. Should start from Q1, not Q29
5. Repeat with endline flow
```

---

### 3. **Weak modules never matched in Dashboard** ❌ FIXED

**Root Cause:**
- Assessment.tsx saves `"Module 2"`, `"Module 3"` etc. to `weak_modules` array
- Dashboard.tsx:63 filters: `weakModules.includes(m.title)`
- DB module titles are full: `"Module 2: The Partnership Foundation"`, `"Module 3: The Mirror Specialist"`
- String equality comparison failed — no weak modules ever matched
- Dashboard only showed Module 1 (mandatory)

**Fix:**
- Changed exact match to **prefix match**: `weakModules.some(wm => m.title.startsWith(wm))`
- `"Module 2".startsWith("Module 2")` → matches `"Module 2: The Partnership Foundation"` ✓
- Applied in Dashboard.tsx:63 AND Assessment.tsx:93 (checkEndlineEligibility)

**Verification:**
```bash
1. Complete baseline with <70% on Module 2 questions (Q1-6)
2. weak_modules array contains ["Module 2"]
3. Dashboard loads modules
4. Should show: Module 1 (mandatory) + Module 2 (weak) + any other weak modules
```

---

### 4. **Production data not on staging — Modules 2-6 missing** ❌ FIXED

**Root Cause:**
- Only Module 1 was seeded on staging
- Assessment questions reference Modules 2-6 in order_number bands (1-6=M2, 7-12=M3, etc.)
- No way to assign or track weak modules when M2-6 don't exist

**Fix:**
- Migration `20260419_fix_profiles_schema_and_seed_modules.sql` seeds:
  - Module 2: The Partnership Foundation (order_number: 2)
  - Module 3: The Mirror Specialist (order_number: 3)
  - Module 4: Digital & Data Intelligence (order_number: 4)
  - Module 5: The Instructional Catalyst (order_number: 5)
  - Module 6: The Excellence Loop (order_number: 6)
- All titles match Assessment.tsx moduleBands keys

**Verification:**
```bash
1. Query: SELECT * FROM modules WHERE order_number IN (2,3,4,5,6)
2. Should return 5 rows with correct titles
3. run: supabase db push (already done)
```

---

## Files Modified

### Code Changes
1. **src/pages/Assessment.tsx**
   - Line 93: `checkEndlineEligibility()` — prefix match weak_modules
   - Line 229: Clear localStorage on baseline fail
   - Lines 241-257: Add error handling for profile UPDATE
   - Line 259: Clear localStorage on baseline success
   - Line 272: Clear localStorage on endline fail
   - Line 314: Clear localStorage on endline success

2. **src/pages/Dashboard.tsx**
   - Line 63: Prefix match weak_modules in filter

### Database Migration
3. **supabase/migrations/20260419_fix_profiles_schema_and_seed_modules.sql**
   - ADD COLUMN weak_modules to profiles
   - INSERT Modules 2-6 with full titles
   - Columns already existed (added in previous migration): school_id, region, teacher_ids

---

## Testing Checklist

- [ ] Sign in as jalal.khan@taleemabad.com
- [ ] Reset `baseline_completed = false` in DB if needed
- [ ] Clear browser localStorage for user
- [ ] Start baseline assessment
- [ ] Answer ~70% on Module 2 questions (Q1-6), ~50% on M3 (Q7-12) to test weak module detection
- [ ] Answer ≥60% total to pass
- [ ] Submit → should show success toast (no 400 error)
- [ ] Dashboard should display:
  - [ ] BaselineResultsCard with score + persona
  - [ ] Module 1 in training list (mandatory)
  - [ ] Module 2 in training list (weak modules)
  - [ ] Module 3 in training list (weak modules)
- [ ] Navigate back to assessment → restart → should start from Q1, not Q29
- [ ] Test endline flow: same process for endline assessment
- [ ] Verify certificate is issued on endline pass (≥70%)

---

## Deployment

**Branch:** `feature/ui-improvements-week1`

**Commit:** a131f9f (includes migration push)

**Migration Status:** ✅ Applied to staging

**Next Steps:**
1. Test on localhost with fresh baseline (clear profile data)
2. Verify on staging: https://coaching-platform-staging.vercel.app
3. Merge to main + deploy to production

---

## Technical Notes

- localStorage key format: `assessment_${type}_${user?.id}` (e.g., `assessment_baseline_abc-123-def`)
- weak_modules stored as string array: `["Module 2", "Module 3"]`
- Module title matching is now prefix-safe — handles full title suffixes
- Error handling is explicit — no silent failures on profile UPDATE
- All 4 assessment end-states now clear localStorage:
  1. Baseline fail (< 60%)
  2. Baseline pass (≥ 60%)
  3. Endline fail (< 70%)
  4. Endline pass (≥ 70%)
