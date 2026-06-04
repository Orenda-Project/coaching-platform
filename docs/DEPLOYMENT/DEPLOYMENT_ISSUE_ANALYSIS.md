# Deployment Issue Analysis

**Date:** 2026-04-23 08:00+  
**Status:** ⚠️ Deployments failing, but migration is in the branch

---

## What We Know

### ✅ Staging Branch
- Migration file `20260423_reduce_baseline_to_18_questions.sql` is in staging branch ✅
- PR #15 merged successfully to staging ✅
- CI/CD triggered correctly ✅

### ❌ Deployment Failures
- **Staging deployments:** Failing (multiple attempts)
- **Production deployments:** Failing (PR #19 from staging → main)
- **Error type:** Deploy jobs failing (not test jobs)

### 🔍 Possible Causes
1. **Railway secrets missing or expired**
   - `RAILWAY_TOKEN_STAGING` 
   - `RAILWAY_TOKEN_PRODUCTION`
   - `RAILWAY_SERVICE_STAGING`
   - `RAILWAY_SERVICE_PRODUCTION`

2. **Railway service IDs incorrect**
   - Environment variables may have wrong service IDs

3. **Build failure**
   - npm run build might be failing
   - Node version issue
   - Dependency conflict

4. **No runners available**
   - GitHub Actions quota issue
   - GitHub hosted runner unavailable

---

## What This Means for Migration

**Good News:** The migration file is safely in both branches (staging and main) and will apply automatically once deployment succeeds.

**Important:** The migration ONLY applies when the app successfully deploys, because:
1. Supabase migrations run during deployment
2. If Railway deployment fails, migration doesn't apply

---

## Solutions

### Option 1: Check Railway Secrets (Recommended)
1. Go to GitHub Settings → Secrets & variables → Actions
2. Verify these secrets exist and aren't expired:
   - `RAILWAY_TOKEN_STAGING`
   - `RAILWAY_TOKEN_PRODUCTION`
   - `RAILWAY_SERVICE_STAGING`
   - `RAILWAY_SERVICE_PRODUCTION`
3. If expired, regenerate from Railway dashboard

### Option 2: Check Railway Dashboard
1. Go to https://dashboard.railway.app
2. Look for "coaching-platform-staging" project
3. Check recent deployments and logs
4. Look for:
   - Build errors
   - Missing environment variables
   - Service connection issues

### Option 3: Manual Migration Application
If GitHub Actions continues to fail, manually apply migration in Supabase:

1. Go to Supabase Studio → staging project
2. SQL Editor → New Query
3. Copy entire contents of `20260423_reduce_baseline_to_18_questions.sql`
4. Run it
5. Verify: `SELECT COUNT(*) FROM questions WHERE assessment_id IN (SELECT id FROM assessments WHERE type='baseline');` → should return 18

### Option 4: Skip to Manual Testing
Even without Railway deployment, you can test the migration locally:

```bash
# 1. Ensure Docker is running
docker ps

# 2. Start Supabase
supabase start

# 3. Reset DB with new migration
supabase db reset

# 4. Run dev server
npm run dev

# 5. Signup and test baseline → should see 18 questions
```

---

## Next Steps

1. **Check Railway Secrets** (5 min)
   - Verify `RAILWAY_TOKEN_*` secrets exist
   - Check expiration dates
   - Regenerate if needed

2. **If secrets are OK:**
   - Trigger a new deploy manually
   - Monitor Railway dashboard

3. **If secrets don't exist:**
   - Generate new Railway API token
   - Add to GitHub Actions secrets
   - Retry deployment

4. **If Railway is unavailable:**
   - Use Option 3 (manual SQL)
   - Or Option 4 (local testing)

---

## Questions to Ask

- Are the Railway secrets still valid?
- Has the Railway service ID changed?
- Is there a GitHub Actions quota issue?
- Is the Node.js build failing for another reason?

**Recommendation:** Check Railway dashboard first, then GitHub secrets.
