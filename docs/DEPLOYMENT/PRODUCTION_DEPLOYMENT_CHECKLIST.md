# Production Deployment Checklist — 2026-05-12

**Objective:** Deploy staging → main → production with data consistency

**Status:** Ready to deploy
- Staging: ✅ Clean (56 teachers, no duplicates)
- Code: ✅ Committed and ready to merge
- Migrations: ✅ Created and tested on staging

---

## Phase 1: Merge Code to Main (GitHub)

### Step 1.1: Create Pull Request (if not exists)

```bash
gh pr create \
  --title "Merge staging: Restore 56 DC teachers + deduplication" \
  --body "## Summary
- Restore all 56 DC teachers from staging to production
- Deduplicate teacher records (fixes 112 → 56)
- Ensure SmartSchedule NEO works with proper data

## Changes
- 20260515000001_seed_all_56_dc_teachers.sql: Add all 56 teachers
- 20260515000002_deduplicate_staging_teachers.sql: Remove duplicates

## Tested
- ✅ Staging: All 56 teachers present, no duplicates
- ✅ App: SmartSchedule NEO shows correct data
- ✅ Regions: Nilore, Urban-I, Urban-II, Tarnol, Sihala, B.K

## Pre-merge
- [ ] Code review approved
- [ ] E2E tests passing (run: npm run test)
- [ ] No TypeScript errors (run: npm run lint)

🤖 Generated with [Claude Code](https://claude.com/claude-code)"
```

### Step 1.2: Wait for Code Review

- [ ] Code review approved by team lead
- [ ] All CI checks passing (GitHub Actions)
- [ ] No merge conflicts

### Step 1.3: Merge to Main

```bash
# Option A: Via GitHub UI
# 1. Go to PR page
# 2. Click "Merge pull request"
# 3. Confirm merge

# Option B: Via CLI
gh pr merge <PR_NUMBER> --merge
```

**Verify merge:**
```bash
git log main -1 --oneline
# Should show: "Merge pull request #XX: Restore 56 DC teachers..."
```

---

## Phase 2: Deploy Code to Production (Railway)

### Step 2.1: Verify Production App Branch

Production Railway service should track `main` branch:
- Go to [Railway Dashboard](https://railway.app)
- Select project: `coaching-platform`
- Select service: `app` (the Node.js service)
- Settings → Source → Should be `main` branch

### Step 2.2: Trigger Production Deployment

```bash
# If auto-deploy is ON (recommended):
# Just push to main, Railway auto-deploys

# If auto-deploy is OFF, manually deploy:
railway deploy --service app --environment production
```

**Monitor deployment:**
```bash
# Watch deployment logs
railway logs --service app --environment production --follow

# Check deployment status
railway status --environment production
```

**Verify app is running:**
- Production URL: Check ENVIRONMENT_SUMMARY.md
- Health check: `GET /` should return 200
- App should load without errors

### Step 2.3: Confirm App is Live

- [ ] Production app loads without errors
- [ ] No TypeScript/build errors in logs
- [ ] API endpoints responding (check Network tab in DevTools)

---

## Phase 3: Apply Migrations to Production Database

### Step 3.1: Link to Production Supabase Project

```bash
cd /Users/mac/Desktop/data/Taleemabad/coaching-platform

supabase link --project-ref agziuwqpkfmxtospfxns
```

**Verify link:**
```bash
# Should show:
# ✓ Linked to project: agziuwqpkfmxtospfxns (production)
```

### Step 3.2: Review Migrations to Apply

```bash
supabase db push --dry-run
```

**Expected output:**
```
Do you want to push these migrations to the remote database?
 • 20260515000001_seed_all_56_dc_teachers.sql
 • 20260515000002_deduplicate_staging_teachers.sql
```

**⚠️ CRITICAL: Verify these are the ONLY migrations pending**
- If other migrations appear, DO NOT PROCEED
- Ask team lead before continuing

### Step 3.3: Apply Migrations to Production

```bash
supabase db push --yes
```

**Expected output:**
```
Applying migration 20260515000001_seed_all_56_dc_teachers.sql...
Applying migration 20260515000002_deduplicate_staging_teachers.sql...
Finished supabase db push.
```

**⚠️ If any errors:**
- Do NOT retry immediately
- Check the error message carefully
- Document the error
- Contact team lead

### Step 3.4: Verify Production Data

After migrations complete, verify data integrity:

**Query 1: Count teachers**
```sql
SELECT COUNT(*) as total_teachers FROM public.teacher_dc_scores;
-- Expected: 56
```

**Query 2: Verify no duplicates**
```sql
SELECT teacher_name, school_name, region, COUNT(*) as cnt
FROM public.teacher_dc_scores
GROUP BY teacher_name, school_name, region
HAVING COUNT(*) > 1;
-- Expected: 0 rows (no duplicates)
```

**Query 3: Verify all regions**
```sql
SELECT DISTINCT region, COUNT(*) as teacher_count
FROM public.teacher_dc_scores
GROUP BY region
ORDER BY region;
-- Expected: B.K, Nilore, Sihala, Tarnol, Urban-I, Urban-II
```

**Query 4: Verify other tables**
```sql
SELECT COUNT(*) as baseline_count FROM public.baseline_assessments;
SELECT COUNT(*) as modules_count FROM public.modules;
SELECT COUNT(*) as coach_count FROM public.coach_assignments;
-- All should have data
```

---

## Phase 4: Smoke Test Production App

### Step 4.1: Test User Signup Flow

1. Go to production app URL
2. Click "Sign Up"
3. Create test account: `test.prod.@taleemabad.com` / `TestPass123!`
4. Complete onboarding

**Expected:**
- ✅ Signup succeeds
- ✅ Onboarding shows correct modules
- ✅ Baseline assessment loads

### Step 4.2: Test SmartSchedule Dashboard

1. Login to production app
2. Go to "SmartSchedule" → "Neo Dashboard"
3. Verify teacher list displays

**Expected:**
- ✅ Teachers load from teacher_dc_scores table
- ✅ Exactly 56 teachers displayed (no duplicates)
- ✅ All regions shown: B.K, Nilore, Sihala, Tarnol, Urban-I, Urban-II
- ✅ Teachers sorted by DC score

### Step 4.3: Test Core User Flows

- [ ] Baseline assessment completes
- [ ] Module 1 loads and quiz works
- [ ] Module unlock logic works (sequential)
- [ ] Certificate generates after endline
- [ ] No "table not found" errors in console

### Step 4.4: Check Production Logs

```bash
# Check for errors in past 15 minutes
railway logs --service app --environment production --since 15m | grep -i error

# Check HTTP error rate
railway http_error_rate --service app --environment production
# Should be < 1%
```

---

## Phase 5: Final Verification

### Step 5.1: Verify Git History

```bash
git log main -5 --oneline
# Should show: feat: seed all 56 DC teachers...
#             fix: deduplicate teacher records...
```

### Step 5.2: Verify Production DB Status

```bash
supabase link --project-ref agziuwqpkfmxtospfxns
supabase db pull

# Check that migrations are marked as applied in _supabase_migrations table
```

### Step 5.3: Document Deployment

Update deployment record:

```markdown
## Deployment: 2026-05-12

**What was deployed:**
- Code: Seed 56 DC teachers + deduplication migrations
- Branch: main
- Commit: [COMMIT_HASH]

**Changes:**
- +56 teachers to teacher_dc_scores
- -56 duplicate records removed
- ✅ SmartSchedule NEO functional
- ✅ All baseline/module/quiz data intact

**Migrations applied:**
- 20260515000001_seed_all_56_dc_teachers.sql
- 20260515000002_deduplicate_staging_teachers.sql

**Status:** ✅ COMPLETE
**Verified:** [DATE/TIME]
**Verified by:** [YOUR_NAME]
```

---

## Rollback Plan (If Needed)

**If production breaks after deployment:**

### Immediate Actions
1. **Notify team lead immediately**
2. **Do NOT attempt to fix without approval**
3. **Stop accepting user signups** (if necessary)

### Rollback Steps (Production DB Only)

```bash
# Connect to production
supabase link --project-ref agziuwqpkfmxtospfxns

# List recent migrations
supabase migration list

# If needed, mark last 2 migrations as reverted:
# supabase migration repair --status reverted 20260515000002
# supabase migration repair --status reverted 20260515000001
```

### Rollback Steps (Production App)

```bash
# Redeploy previous commit from main
railway deploy --service app --environment production --commit <PREVIOUS_COMMIT_HASH>
```

---

## Timeline

| Phase | Task | Estimated Time | Status |
|-------|------|-----------------|--------|
| 1 | Create & merge PR | 15 min | ⏳ Pending |
| 2 | Deploy to production | 5 min | ⏳ Pending |
| 3 | Apply migrations | 10 min | ⏳ Pending |
| 4 | Smoke test app | 15 min | ⏳ Pending |
| 5 | Final verification | 10 min | ⏳ Pending |
| **Total** | **All phases** | **55 minutes** | |

---

## Success Criteria

- ✅ Code merged to `main` branch
- ✅ Production app deployed from `main`
- ✅ All migrations applied to production DB
- ✅ Exactly 56 teachers in production (no duplicates)
- ✅ All regions represented (B.K, Nilore, Sihala, Tarnol, Urban-I, Urban-II)
- ✅ SmartSchedule NEO displays teachers correctly
- ✅ User signup/onboarding flow works
- ✅ Baseline assessment loads
- ✅ Module quiz works
- ✅ No "table not found" errors in logs

---

## Support Contacts

- **Code Issues:** Check GitHub PR comments
- **Database Issues:** Supabase dashboard → SQL Editor → Check _supabase_migrations table
- **Deployment Issues:** Railway dashboard → View logs
- **App Issues:** Check browser DevTools → Network & Console tabs

---

## Notes

- Do NOT skip Phase 3 (migrations) — code alone won't work without DB changes
- Do NOT rush Phase 4 (smoke tests) — catching issues early is critical
- Keep this checklist for future deployments
- Document any issues encountered for the team

