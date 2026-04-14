# Development Standards — Coaching Platform
**Taleemabad | April 10, 2026**

---

## 🎯 Core Rules (Never Break These)

### 1. ✅ ALWAYS Work in Feature Branches
```bash
# ✅ CORRECT
git checkout staging
git pull origin staging
git checkout -b feature/module-2-content
git push -u origin feature/module-2-content

# ❌ WRONG
git checkout main
git push origin main  # Never push directly to main!
```

### 2. ✅ ALWAYS Create Pull Requests (No Direct Merges)
```bash
# ✅ CORRECT
1. Push feature branch
2. Create PR on GitHub: feature/xyz → staging
3. Get code review
4. Merge via GitHub UI (not command line)

# ❌ WRONG
git merge --no-ff feature/xyz  # Without PR review
git push origin staging  # Skipping PR process
```

### 3. ✅ ALWAYS Run E2E Tests Before Merging
```bash
# ✅ BEFORE MARKING PR AS "READY FOR REVIEW"
1. Test on local: npm run dev
2. Test on staging: deploy feature to staging branch
3. Run E2E flow: signup → baseline → modules → endline → certificate
4. Verify no console errors
5. Check database (Supabase): new data created correctly

# ❌ WRONG
"I think it works" → merge
"I didn't test" → merge
```

### 4. ✅ ALWAYS Use Staging Before Production
```bash
# ✅ WORKFLOW
feature/xyz
    ↓ PR → staging
staging (QA tests here)
    ↓ after approval
main (production merge)

# ❌ WRONG
feature/xyz → directly to main
(skipping staging)
```

---

## 📋 Development Checklist

### Before Starting Work
- [ ] Create new branch from `staging` (never from `main`)
- [ ] Branch name follows convention: `feature/description` or `fix/description`
- [ ] Pull latest `staging` code

### While Working
- [ ] Commit frequently with clear messages
- [ ] Test locally: `npm run dev`
- [ ] Push to GitHub: `git push origin feature/xyz`
- [ ] No console errors (open DevTools → Console)

### Before Creating PR
- [ ] Rebase on latest staging: `git pull --rebase origin staging`
- [ ] Code follows project patterns
- [ ] No hardcoded values or secrets
- [ ] Tests added (if applicable)

### PR Creation
- [ ] Create PR on GitHub: `feature/xyz` → `staging`
- [ ] Add descriptive title and description
- [ ] Link to Jira ticket (if applicable)
- [ ] Request reviewer (Jalal or Hammad)
- [ ] **DO NOT MERGE YET** — E2E testing next

### E2E Testing (CRITICAL)
- [ ] Deploy to staging manually or wait for auto-deploy
- [ ] Test signup with new user: `testcoach+staging+random@example.com`
- [ ] Test baseline assessment (answer questions, verify persona)
- [ ] Test module view and quiz (complete Module 1)
- [ ] Test endline (if applicable)
- [ ] Verify certificate PDF generation
- [ ] Check Supabase staging: auth.users table has new user
- [ ] Check console: no JavaScript errors
- [ ] Mobile test: check responsive design (375px viewport)

### After E2E Passes
- [ ] Update PR with testing notes
- [ ] Add comment: "✅ E2E Testing Complete"
- [ ] Get final approval from reviewer
- [ ] Merge to staging via GitHub UI

### After Staging Approval
- [ ] Pull latest main
- [ ] Merge staging → main: `git merge --no-ff staging`
- [ ] Push to main: `git push origin main`
- [ ] Wait for auto-deploy to production
- [ ] Verify production: check live app
- [ ] Delete feature branch (GitHub offers this after merge)

---

## 🚫 What NOT to Do

| ❌ DON'T | ✅ DO INSTEAD |
|---------|--------------|
| Push directly to `main` | Create PR to `staging` first |
| Skip E2E testing | Test full flow before merge |
| Merge without review | Wait for code review + approval |
| Commit secrets to git | Use environment variables |
| Work on `main` branch | Create `feature/*` branch |
| Force push to `main` | Create new commit if needed |
| Merge broken code | Fix locally, test, then merge |
| Work weeks without PR | Create PR every 1-2 days |

---

## 🔄 Git Commands Reference

### Start Feature
```bash
git checkout staging
git pull origin staging
git checkout -b feature/your-feature-name
git push -u origin feature/your-feature-name
```

### During Development
```bash
# Make changes
git add .
git commit -m "feat: description"
git push origin feature/your-feature-name

# Keep in sync with staging
git fetch origin
git rebase origin/staging
git push origin feature/your-feature-name --force-with-lease
```

### After PR Approval
```bash
# Don't merge via command line - use GitHub UI
# After merge via GitHub:
git checkout staging
git pull origin staging
git branch -d feature/your-feature-name  # Delete local
```

### Merge Staging → Main (After Staging Tests Pass)
```bash
git checkout main
git pull origin main
git merge --no-ff staging
git push origin main
# GitHub Actions auto-deploys
```

### Rollback if Needed
```bash
git log --oneline main  # Find problematic commit
git revert <commit-hash>
git push origin main
# This creates new "revert" commit (safe, doesn't lose history)
```

---

## 📊 E2E Testing Checklist Template

Copy this for every feature PR:

```markdown
## E2E Testing Checklist

- [ ] Feature deployed to staging
- [ ] Signup test: created testcoach+staging+[random]@example.com
- [ ] Baseline assessment: answered questions, received persona
- [ ] Module 1: watched video (90%), took quiz, passed (80%+)
- [ ] Dashboard: shows completed module, next module available
- [ ] Endline: took assessment, received score
- [ ] Certificate: PDF generated and downloaded
- [ ] Supabase: auth.users shows new user, profiles shows data
- [ ] Console: no errors or warnings
- [ ] Mobile: responsive on 375px viewport
- [ ] Production-like: tested on staging URL (not localhost)

**Status:** ✅ E2E Testing Complete
```

---

## 🔐 Security Checklist

Before every merge:
- [ ] No API keys in code
- [ ] No passwords in commits
- [ ] No email/personal data hardcoded
- [ ] No `console.log()` debug statements left in
- [ ] No commented-out code
- [ ] Dependencies up to date (no major vulnerabilities)

---

## 📝 Commit Message Standards

### Format
```
type(scope): subject

body (optional)
```

### Types
- `feat:` — new feature
- `fix:` — bug fix
- `docs:` — documentation
- `chore:` — dependencies, config
- `refactor:` — code reorganization (no feature change)
- `test:` — test additions/changes
- `perf:` — performance improvement

### Examples
```
✅ feat(baseline): add baseline assessment with persona assignment
✅ fix(dashboard): fix module locking logic
✅ chore: update dependencies to latest versions
✅ docs: add E2E testing guide

❌ updated stuff
❌ bug fix
❌ WIP
```

---

## 🚨 Critical Rules Summary

| Rule | Reason |
|------|--------|
| **Branch from staging, not main** | Staging is testing ground |
| **Always create PR** | Code review catches issues |
| **Always test E2E before merge** | Catches bugs before production |
| **Never force push main** | Prevents losing history |
| **Never commit secrets** | Privacy & security |
| **Never skip staging** | Testing happens before users see it |

---

## 🎯 Typical Feature Flow

```
Day 1: Create feature branch
  ↓
Days 1-3: Work on feature locally
  ↓
Day 3: Push to GitHub, create PR
  ↓
Day 3-4: Code review, feedback
  ↓
Day 4: Fix review feedback
  ↓
Day 4: Deploy to staging (auto or manual)
  ↓
Day 4-5: Run E2E tests
  ↓
Day 5: Get final approval
  ↓
Day 5: Merge to staging via GitHub UI
  ↓
Day 6: Team tests staging environment
  ↓
Day 7: Merge staging → main
  ↓
Day 7: Auto-deploys to production
  ↓
Day 7: Monitor production logs
  ↓
DONE ✅
```

---

## 🔗 Documentation

- `QUICK_START.md` — Quick commands reference
- `DEPLOYMENT.md` — Full deployment strategy
- `STAGING_VERIFICATION.md` — Testing guide
- `STAGING_READY.md` — Staging environment info

---

## 👥 Team Sign-Off

**Jalal Khan** — Senior Full Stack Dev (implements & reviews)
**Hammad Sarfraz** — Full Stack Dev (implements, creates PRs)
**Umar Raza** — QA Lead (runs E2E tests before production)

**Rule Enforcement:** Every merge to `main` requires:
1. ✅ Code review (Jalal or Hammad)
2. ✅ E2E testing (Umar or developer)
3. ✅ GitHub PR approval

---

## 📌 Remember

> "Move fast, but move safely. Test on staging, not production."

**Every commit to `main` is live to users. Treat it with respect.**

---

**Last Updated:** 2026-04-10
**Status:** 🟢 **Team Standard**

