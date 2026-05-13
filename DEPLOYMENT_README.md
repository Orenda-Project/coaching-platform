# 🚀 Production Deployment Guide

## Overview

This guide walks you through deploying the staging environment (with 56 DC teachers) to production. The deployment has **5 phases** and takes approximately **55 minutes**.

---

## 📚 Documentation Files

Choose your preferred level of detail:

| Document | Level | When to Use | Time |
|----------|-------|-------------|------|
| **DEPLOYMENT_COMMANDS.sh** | Interactive | You prefer hands-on, guided steps | 55 min |
| **PRODUCTION_DEPLOYMENT_QUICK_START.md** | Quick Ref | You just need the essential commands | 5 min |
| **PRODUCTION_DEPLOYMENT_CHECKLIST.md** | Detailed | You need full context and explanations | 15 min |
| **DEPLOYMENT_SUMMARY.txt** | Overview | You want a visual summary | 3 min |

---

## ⚡ Quick Start (5 Minutes)

If you're familiar with deployments, start here:

```bash
# Phase 1: Merge code
gh pr create --title "Merge staging: Restore 56 DC teachers"
# Then merge in GitHub UI

# Phase 2: Deploy app
railway deploy --service app --environment production

# Phase 3: Apply migrations
supabase link --project-ref agziuwqpkfmxtospfxns
supabase db push --dry-run      # VERIFY output
supabase db push --yes           # APPLY

# Phase 4: Verify data
# Run in Supabase SQL Editor:
SELECT COUNT(*) FROM public.teacher_dc_scores;
-- Expected: 56

# Phase 5: Test app
# - Signup at production URL
# - View SmartSchedule → Neo Dashboard
# - Verify 56 teachers appear
```

---

## 🎯 Full Step-by-Step (55 Minutes)

For detailed instructions with all context, see:

**[PRODUCTION_DEPLOYMENT_CHECKLIST.md](PRODUCTION_DEPLOYMENT_CHECKLIST.md)**

5 phases with full details:
1. ✅ Merge code to main (GitHub)
2. ✅ Deploy app to production (Railway)
3. ✅ Apply migrations to production DB (Supabase)
4. ✅ Smoke test production app
5. ✅ Final verification

---

## 🤖 Interactive Script (Recommended)

If you want a guided, step-by-step walk-through:

```bash
chmod +x DEPLOYMENT_COMMANDS.sh
./DEPLOYMENT_COMMANDS.sh
```

The script:
- Prints each phase with clear instructions
- Pauses after each phase for verification
- Includes all commands to copy/paste
- Confirms data integrity
- Has success checklist

---

## 🚀 The 5 Phases

### Phase 1: Code → Main (GitHub)
- Create PR from staging → main
- Wait for code review approval
- Merge to main branch

### Phase 2: App → Production (Railway)
- Verify production app service tracks "main" branch
- Trigger deployment (auto or manual)
- Confirm app is live with no errors

### Phase 3: Migrations → Production DB (Supabase)
- Link to production Supabase project
- Review migrations with dry-run (SAFE)
- Apply migrations to production DB
- Verify data integrity (count, duplicates, regions)

### Phase 4: Smoke Test (App)
- Test user signup flow
- Test SmartSchedule dashboard (verify 56 teachers)
- Test core flows (baseline, modules, certificate)
- Check logs for errors

### Phase 5: Verification (Final)
- Verify git commit history
- Verify production DB status
- Document deployment

---

## ✅ Success Criteria

After deployment, verify all of these:

```
✅ Code merged to main
✅ App deployed to production
✅ Migrations applied to production DB
✅ Production has exactly 56 teachers (no duplicates)
✅ SmartSchedule NEO displays all teachers
✅ All regions present: B.K, Nilore, Sihala, Tarnol, Urban-I, Urban-II
✅ User signup/onboarding works
✅ Baseline assessment loads and functions
✅ Module quiz works
✅ Certificate generates after endline pass
✅ No "table not found" errors in logs
✅ No HTTP 5xx errors in production
```

---

## 🚨 If Something Goes Wrong

### I see an error during migration

**Don't panic.** Follow these steps:

1. **Read the error message carefully** — it usually tells you what's wrong
2. **Don't retry immediately** — fix the root cause first
3. **Check the logs:** `railway logs --service app --environment production --follow`
4. **Check the database:** Supabase dashboard → SQL Editor
5. **Contact team lead** — show them the exact error message

### I need to rollback

**Rollback is a last resort.** Only after consulting team lead.

See "Rollback Plan" section in PRODUCTION_DEPLOYMENT_CHECKLIST.md

---

## 📋 Pre-Deployment Checklist

Before starting, make sure:

- [ ] Staging tested and working
- [ ] All code committed to staging branch
- [ ] You've reviewed the deployment guide
- [ ] Team lead is aware and available
- [ ] You have 1 hour of uninterrupted time
- [ ] You understand the 5 phases
- [ ] You know how to check logs and data

---

## 📞 Support

- **Code issues:** Check GitHub PR comments
- **Database issues:** Supabase dashboard → SQL Editor
- **Deployment issues:** Railway dashboard → Logs
- **App issues:** Browser DevTools → Network & Console tabs
- **General questions:** Contact team lead

---

## 🎓 Key Concepts

**Why can't I just merge and have it work?**

Git merging only updates **code files**. Migrations are separate **database schema changes** that must be explicitly applied to each database:

```
Staging DB (kddvxrlffafyjvvststh):
  ✅ Migrations already applied
  ✅ 56 teachers in database
  ✅ App working

Production DB (agziuwqpkfmxtospfxns):
  ❌ Migrations NOT applied yet
  ❌ No teachers in database (yet)
  ❌ App will error until migrations run
```

**Merging = Deploy Code**
**Migrations = Deploy Database Changes**

Both are needed for full deployment.

---

## 📊 Deployment Timeline

| Phase | Task | Time | Status |
|-------|------|------|--------|
| 1 | Merge code to main | 15 min | ⏳ Pending |
| 2 | Deploy app to production | 5 min | ⏳ Pending |
| 3 | Apply migrations | 10 min | ⏳ Pending |
| 4 | Smoke test | 15 min | ⏳ Pending |
| 5 | Verify & document | 10 min | ⏳ Pending |
| **Total** | **Full deployment** | **55 min** | |

---

## 🎯 What Gets Deployed

**Code Changes:**
- `20260515000001_seed_all_56_dc_teachers.sql` — Seeds 56 teachers
- `20260515000002_deduplicate_staging_teachers.sql` — Removes duplicates

**Expected Results:**
- ✅ Production: Exactly 56 teachers (no duplicates)
- ✅ Regions: B.K, Nilore, Sihala, Tarnol, Urban-I, Urban-II
- ✅ SmartSchedule NEO: All teachers display correctly
- ✅ Baseline: Questions, options, data intact
- ✅ Modules: All 6 modules load, sequential unlock works
- ✅ Certificate: Generates after endline pass

---

## 🏃 Ready? Let's Go

**Choose your path:**

1. **I want interactive guidance:**
   ```bash
   ./DEPLOYMENT_COMMANDS.sh
   ```

2. **I want quick reference:**
   - Open: `PRODUCTION_DEPLOYMENT_QUICK_START.md`

3. **I want detailed instructions:**
   - Open: `PRODUCTION_DEPLOYMENT_CHECKLIST.md`

4. **I want a visual summary:**
   - Open: `DEPLOYMENT_SUMMARY.txt`

---

**Good luck! 🚀**

Document any issues and share learnings with the team.

