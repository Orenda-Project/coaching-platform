# 📑 Deployment Documentation Index

## Quick Navigation

### 🎯 Start Here
- **[DEPLOYMENT_README.md](DEPLOYMENT_README.md)** — Master guide explaining all options

### 📚 Choose Your Path

#### I want to just get it done (5 min)
→ [PRODUCTION_DEPLOYMENT_QUICK_START.md](PRODUCTION_DEPLOYMENT_QUICK_START.md)

**Contains:**
- Essential 5-step process
- Copy-paste commands
- Success checklist

---

#### I want guided, step-by-step help (55 min)
→ Run: `./DEPLOYMENT_COMMANDS.sh`

**Contains:**
- Interactive prompts after each phase
- All commands ready to copy/paste
- Pauses for verification
- Data checks built in

---

#### I want full details and context (15 min)
→ [PRODUCTION_DEPLOYMENT_CHECKLIST.md](PRODUCTION_DEPLOYMENT_CHECKLIST.md)

**Contains:**
- 5 detailed phases with sub-steps
- Rollback procedures
- Troubleshooting guide
- Success criteria
- Support contacts

---

#### I want a visual overview (3 min)
→ [DEPLOYMENT_SUMMARY.txt](DEPLOYMENT_SUMMARY.txt)

**Contains:**
- Process flow diagram
- What gets deployed
- Critical warnings
- Timeline
- Quick command reference

---

## 📊 File Reference

| File | Size | Purpose | Read Time |
|------|------|---------|-----------|
| DEPLOYMENT_README.md | 6.7K | Master guide & path selector | 5 min |
| PRODUCTION_DEPLOYMENT_QUICK_START.md | 1.7K | Essential commands only | 5 min |
| PRODUCTION_DEPLOYMENT_CHECKLIST.md | 9.0K | Full step-by-step guide | 15 min |
| DEPLOYMENT_COMMANDS.sh | 6.7K | Interactive script (executable) | 55 min |
| DEPLOYMENT_SUMMARY.txt | 5.3K | Visual process overview | 3 min |
| DEPLOYMENT_INDEX.md | This file | Navigation guide | 2 min |

---

## 🚀 The 5-Phase Deployment

```
Phase 1: CODE → MAIN (GitHub)
    ├─ Create PR
    ├─ Wait for review
    └─ Merge to main

Phase 2: APP → PRODUCTION (Railway)
    ├─ Verify app tracks main
    ├─ Trigger deployment
    └─ Confirm live

Phase 3: MIGRATIONS → PRODUCTION DB (Supabase)
    ├─ Link to production
    ├─ Review with dry-run
    ├─ Apply migrations
    └─ Verify data

Phase 4: SMOKE TEST (App)
    ├─ Test signup
    ├─ Test SmartSchedule (56 teachers)
    ├─ Test core flows
    └─ Check logs

Phase 5: VERIFICATION (Final)
    ├─ Verify git history
    ├─ Verify DB status
    └─ Document deployment

Total Time: ~55 minutes
```

---

## ⚡ TL;DR Quick Commands

```bash
# Phase 1: Merge code
gh pr create --title "Merge staging: Restore 56 DC teachers"
# Then merge in GitHub UI

# Phase 2: Deploy app
railway deploy --service app --environment production

# Phase 3: Apply migrations
supabase link --project-ref agziuwqpkfmxtospfxns
supabase db push --dry-run
supabase db push --yes

# Phase 4: Verify
SELECT COUNT(*) FROM public.teacher_dc_scores;
-- Expected: 56

# Phase 5: Test app
# Signup → SmartSchedule → Verify 56 teachers
```

---

## ✅ Success Criteria

After deployment, all of these should be true:

```
✅ Code merged to main
✅ App deployed to production  
✅ Migrations applied
✅ Exactly 56 teachers (no duplicates)
✅ All regions: B.K, Nilore, Sihala, Tarnol, Urban-I, Urban-II
✅ SmartSchedule NEO working
✅ Signup flow working
✅ Baseline assessment working
✅ Module quiz working
✅ Certificate working
✅ No errors in logs
```

---

## 🚨 Emergency Contacts

- **Code issues:** Check GitHub PR
- **Database issues:** Supabase SQL Editor
- **App deployment:** Railway dashboard logs
- **App errors:** Browser DevTools
- **General:** Contact team lead

---

## 📖 Reading Guide

**Completely new to this?**
1. Read: DEPLOYMENT_README.md (explains concepts)
2. Read: DEPLOYMENT_SUMMARY.txt (visual overview)
3. Choose: One of the guides below

**Experienced with deployments?**
1. Skim: PRODUCTION_DEPLOYMENT_QUICK_START.md
2. Run: ./DEPLOYMENT_COMMANDS.sh

**Want all context?**
1. Read: PRODUCTION_DEPLOYMENT_CHECKLIST.md (full details)

**Prefer interactive?**
1. Run: `chmod +x DEPLOYMENT_COMMANDS.sh && ./DEPLOYMENT_COMMANDS.sh`

---

## 🎯 What Gets Deployed

**Code:**
- `20260515000001_seed_all_56_dc_teachers.sql`
- `20260515000002_deduplicate_staging_teachers.sql`

**Data:**
- ✅ 56 DC teachers (no duplicates)
- ✅ All regions: B.K, Nilore, Sihala, Tarnol, Urban-I, Urban-II
- ✅ All baseline questions and options
- ✅ All 6 training modules
- ✅ All module quizzes
- ✅ Certificate system

**Expected Results:**
- SmartSchedule NEO shows 56 teachers
- All onboarding flows work
- No "table not found" errors

---

## 💾 How to Use This Index

1. Read this file first (you're here!)
2. Choose your preferred guide from the options above
3. Follow that guide start to finish
4. Don't skip phases
5. Verify after each phase

---

## 🔄 Related Documentation

Also see:
- `DEPLOYMENT_STATUS.md` — Current deployment status
- `DEPLOYMENT_ISSUE_ANALYSIS.md` — Issues encountered during prep
- Main project docs in `DEVELOPMENT_STANDARDS.md`

---

**Ready? Pick your guide above and get started! 🚀**

