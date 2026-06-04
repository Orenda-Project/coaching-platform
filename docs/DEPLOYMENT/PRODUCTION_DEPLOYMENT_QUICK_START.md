# Production Deployment — Quick Start Guide

**TL;DR:** 5-step process to deploy staging → production

---

## ⚡ Quick Steps

### 1️⃣ Merge Code to Main
```bash
# Create PR and merge (wait for approval)
gh pr create --title "Merge staging: Restore 56 DC teachers"
# Then merge in GitHub UI
```

### 2️⃣ Deploy App to Production
```bash
# Railway auto-deploys from main, OR manually:
railway deploy --service app --environment production
```

### 3️⃣ Apply Migrations to Production DB
```bash
# Switch to production
supabase link --project-ref agziuwqpkfmxtospfxns

# Review what will be applied
supabase db push --dry-run

# Apply migrations
supabase db push --yes
```

### 4️⃣ Verify Data
```sql
-- Run in Supabase SQL Editor
SELECT COUNT(*) FROM public.teacher_dc_scores;
-- Should return: 56
```

### 5️⃣ Test the App
- Signup at production URL
- View SmartSchedule → Neo Dashboard
- Verify 56 teachers appear with no duplicates
- Test baseline assessment

---

## ✅ Success Checklist

- [ ] Code merged to `main`
- [ ] App deployed to production
- [ ] Migrations applied to production DB
- [ ] Production has exactly 56 teachers
- [ ] SmartSchedule NEO shows all teachers
- [ ] No duplicate entries
- [ ] Signup flow works
- [ ] Baseline assessment works

---

## 🚨 If Something Goes Wrong

**Step 1:** Check the error message carefully
**Step 2:** Look in logs: `railway logs --service app --environment production --follow`
**Step 3:** Check database: Supabase dashboard → SQL Editor
**Step 4:** Do NOT retry without understanding the error
**Step 5:** Contact team lead for rollback if needed

---

## 📚 Full Details

See `PRODUCTION_DEPLOYMENT_CHECKLIST.md` for complete step-by-step instructions

