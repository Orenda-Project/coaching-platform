# Staging Environment Verification
**Coaching Platform — April 10, 2026**

---

## ✅ Staging Setup Status

### Supabase
- ✅ **Staging Project Created:** `coaching-platform-staging` (kddvxrlffafyjvvststh)
- ✅ **All 11 Migrations Applied** (2026-02-11 through 2026-04-09)
- ✅ **Database Schema Synced:** Identical to production
- ✅ **.env.staging Updated:** New credentials in place

**Staging Supabase Details:**
```
Project ID: kddvxrlffafyjvvststh
URL: https://kddvxrlffafyjvvststh.supabase.co
Publishable Key: sb_publishable_lAkKpshDRWd1YExhmNUG1w_09JhQb6s
```

### Railway
- ✅ **Staging Environment Created** (needs verification of live link)
- ⏳ **GitHub Actions Auto-Deploy:** Waiting for test

---

## 📊 Data Migration Verification

### What Was Migrated
All 11 migrations have been applied to staging database:

1. ✅ `20260211195115_0cf914ca...` — Initial schema setup
2. ✅ `20260218113125_c0477dae...` — Profile enhancements
3. ✅ `20260219061142_d94e1c16...` — Training module structure
4. ✅ `20260220060108_8e5d543c...` — Assessment setup
5. ✅ `20260408000001_coaching_platform_v2.sql` — V2 fixes (attempt counts, anti-cheat)
6. ✅ `20260409000001_fix_training_content_types.sql` — Content type validation
7. ✅ `20260409000002_fix_assessments_type_constraint.sql` — Assessment constraints
8. ✅ `20260409000003_verify_and_fix_constraints.sql` — Constraint verification
9. ✅ `20260409000004_nuclear_constraint_fix.sql` — Aggressive constraint cleanup
10. ✅ `20260409000005_verify_constraints_final.sql` — Final verification
11. ✅ `20260409000006_aggressive_constraint_cleanup.sql` — Cleanup finalization

**Result:** ✅ Schema is 100% synchronized between production and staging

### Production Data NOT Migrated (By Design)
⚠️ **Important:** We did NOT copy production user data (coaches, assessments, etc.) to staging.

This is **intentional and correct** because:
- Staging is for **testing new features**, not for running with live data
- Coaches should test on staging with clean databases
- Production data is safe and untouched
- Staging can be reset anytime without affecting users

---

## 🔍 How to Verify Staging Deployment

### Option 1: Check Railway Dashboard
```
1. Go to https://railway.app/dashboard
2. Select "coaching-platform-staging" project
3. Look for:
   - Build status: "Build successful" (green)
   - Domain: Should show assigned domain or IP
   - Deployment logs: Should show npm build succeeded
```

### Option 2: Check via CLI
```bash
# Check Railway staging logs
railway logs --service web

# Check deployment status
railway status
```

### Option 3: Access the Live App
**Find your staging URL:**
```bash
# Option A: Railway dashboard → Domains tab
# Option B: Run this command:
railway domains
```

This will show either:
- `*.railway.app` subdomain (auto-generated)
- Custom domain you configured (if set up)

**Example URLs:**
```
https://coaching-platform-staging-production.up.railway.app/
OR
https://staging.coachingplatform.taleemabad.com  (if custom domain configured)
```

---

## 🧪 Testing Staging Deployment

### Step 1: Verify Frontend Loads
```bash
# In browser, visit staging URL:
https://<your-railway-staging-url>/

# Should see:
# ✅ Landing page loads
# ✅ Login form appears
# ✅ No console errors (open DevTools → Console tab)
```

### Step 2: Test Signup on Staging
```bash
1. Go to staging URL
2. Click "Sign Up"
3. Create test account:
   Email: testcoach+staging@example.com
   Password: Test123!
4. Submit form → should redirect to login
5. Login with new credentials
6. Should see empty dashboard
```

### Step 3: Verify Environment
```bash
# In browser console:
console.log(import.meta.env.VITE_ENVIRONMENT)
// Should print: "staging"

console.log(import.meta.env.VITE_SUPABASE_PROJECT_ID)
// Should print: "kddvxrlffafyjvvststh"
```

### Step 4: Check Database Connection
```bash
# Attempt baseline assessment:
1. Click "Start Assessment"
2. Answer baseline questions
3. Submit → should save to staging database
4. Check Supabase staging → auth.users table (new user created)
```

---

## 🔗 Important URLs

| Environment | URL | Supabase Project |
|---|---|---|
| **Production** | TBD (configure custom domain) | agziuwqpkfmxtospfxns |
| **Staging** | Check Railway dashboard | kddvxrlffafyjvvststh |
| **Local** | http://localhost:5173 | http://127.0.0.1:54321 |

---

## ⚠️ IMPORTANT: Do NOT Copy Production Data to Staging

**Why:**
- Production has real coach user data (privacy concern)
- Staging is for **testing features**, not for live data
- Data backup/restore is manual and requires care

**If you need test data on staging:**
```bash
# Option 1: Create manually via signup/login
# Test a complete flow: signup → baseline → modules → endline

# Option 2: Use seeded data (if we add it)
# Could add fixtures for baseline questions, modules, etc.
```

---

## 🚀 Next Steps

### 1. Find Your Staging Live URL
```bash
cd /Users/mac/Desktop/data/Taleemabad/coaching-platform
railway domains
# This will show your staging app's public URL
```

### 2. Test Staging E2E Flow
- [ ] Open staging URL in browser
- [ ] Signup as test user
- [ ] Take baseline assessment
- [ ] Verify persona assigned
- [ ] Check dashboard shows Module 1
- [ ] Complete Module 1
- [ ] Verify Endline unlocked
- [ ] Complete Endline
- [ ] Download Certificate PDF

### 3. Verify GitHub Actions Auto-Deploy
```bash
# Make a small change to staging branch
git checkout staging
echo "# Test" >> TEST_STAGING.md
git add TEST_STAGING.md
git commit -m "test: staging auto-deploy"
git push origin staging

# Go to GitHub Actions → should see Deploy workflow running
# Wait for completion → check staging app (should still work)
```

### 4. Configure Railway Environment Variables (if not done)
```bash
railway env list
# Should show: VITE_SUPABASE_PROJECT_ID=kddvxrlffafyjvvststh

# If missing, add:
railway env add VITE_ENVIRONMENT staging
railway env add VITE_SUPABASE_PROJECT_ID kddvxrlffafyjvvststh
railway env add VITE_SUPABASE_URL https://kddvxrlffafyjvvststh.supabase.co
railway env add VITE_SUPABASE_PUBLISHABLE_KEY sb_publishable_lAkKpshDRWd1YExhmNUG1w_09JhQb6s
```

### 5. Monitor Staging (Daily)
```bash
# Check logs for errors
railway logs --service web

# Check deployment status
railway status
```

---

## 🐛 Troubleshooting

### "Cannot connect to staging database"
```
Error in browser: "error: RelationalError: SSL error"
Solution:
1. Verify VITE_SUPABASE_URL in Railway env variables
2. Check Supabase staging project is active
3. Restart Railway service
```

### "Page shows production data"
```
Error: Seeing production coach accounts on staging
Solution:
1. Verify VITE_SUPABASE_PROJECT_ID is "kddvxrlffafyjvvststh" (not production ID)
2. Hard refresh browser (Cmd+Shift+R)
3. Check env variables: console.log(import.meta.env)
```

### "Staging deploy fails"
```
Check GitHub Actions logs:
1. Go to repo → Actions tab
2. Click "Deploy" workflow
3. Check "deploy-staging" step
4. Common issues:
   - Missing Railway token in GitHub secrets
   - Build errors (check npm run build locally)
   - Migration errors (check Supabase logs)
```

---

## 📋 Checklist

- [x] Staging Supabase project created
- [x] All migrations applied to staging
- [x] .env.staging updated with correct credentials
- [x] Railway staging environment created
- [ ] Test staging URL is accessible (TBD: verify link)
- [ ] E2E flow tested on staging (TBD)
- [ ] GitHub Actions auto-deploy tested (TBD)
- [ ] Production data confirmed NOT copied (✅ By design)

---

## 🎯 Summary

| Aspect | Status | Details |
|--------|--------|---------|
| **Schema Sync** | ✅ DONE | 11 migrations applied, 100% match |
| **Data Migration** | ⏳ N/A | Clean staging, no production data (by design) |
| **Environment Variables** | ✅ DONE | .env.staging updated |
| **Railway Deployment** | ✅ DONE | Environment created (verify URL) |
| **Live URL** | ⏳ TBD | Check Railway dashboard for link |
| **E2E Testing** | ⏳ TODO | Test signup → baseline → modules → endline |

---

**Next Action:** Find your staging live URL and test the E2E flow!

