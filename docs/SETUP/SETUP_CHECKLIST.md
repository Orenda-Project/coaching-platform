# Staging/Production Setup Checklist
**Coaching Platform | Taleemabad**
**Status:** 🟡 IN PROGRESS

---

## ✅ Completed (2026-04-10)

- [x] Create `staging` branch on GitHub
- [x] Write `DEPLOYMENT.md` (complete strategy guide)
- [x] Create `.github/workflows/deploy.yml` (auto-deploy on push)
- [x] Create `.env.production` (production Supabase config)
- [x] Create `.env.staging` (placeholder, to be filled)
- [x] Create `.env.example` (local dev template)

---

## 🔴 Remaining Tasks

### 1. Create Staging Supabase Project (5 min)
- [ ] Go to https://supabase.com/dashboard
- [ ] Create new project:
  - Name: `coaching-platform-staging`
  - Region: Same as production (Asia Pacific / Singapore)
  - Plan: Free or Pro
- [ ] Wait for database to initialize
- [ ] Copy Project ID and Publishable Key
- [ ] Update `.env.staging` with new keys

**Commands:**
```bash
# After getting staging project ID:
supabase link --project-ref <staging-project-id>
supabase db push  # applies all migrations from supabase/migrations/
```

### 2. Create Staging Railway Project (5 min)
- [ ] Go to https://railway.app/dashboard
- [ ] Create new project: `coaching-platform-staging`
- [ ] Connect GitHub repo: `Orenda-Project/coaching-platform`
- [ ] Set deploy branch to `staging`
- [ ] Add environment variables from `.env.staging`
- [ ] Link Supabase staging project (if using Railway plugins)

### 3. Set Up Railway Secrets for GitHub Actions (5 min)
- [ ] Get Railway token for staging: `railway token`
  - Copy token
  - Go to GitHub repo → Settings → Secrets & Variables → Actions
  - Add `RAILWAY_TOKEN_STAGING` (paste token)
- [ ] Get Railway token for production
  - Same process
  - Add `RAILWAY_TOKEN_PRODUCTION`

### 4. Test Auto-Deploy Pipeline (10 min)
- [ ] Push dummy commit to `staging` branch
  ```bash
  git checkout staging
  echo "# Staging test" >> STAGING.md
  git add STAGING.md
  git commit -m "test: staging auto-deploy"
  git push origin staging
  ```
- [ ] Monitor GitHub Actions (Actions tab) → should see "Deploy" workflow
- [ ] Wait for `deploy-staging` job to complete
- [ ] Check Railway Staging project → should show "Build successful"
- [ ] Verify staging app is live

### 5. Test Production Auto-Deploy (10 min)
- [ ] Merge staging to main (DO NOT push commits directly to main)
  ```bash
  git checkout main
  git pull origin main
  git merge staging
  git push origin main
  ```
- [ ] Monitor GitHub Actions → should see "Deploy" workflow
- [ ] Wait for `deploy-production` job to complete
- [ ] Check Railway Production project → should show "Build successful"
- [ ] Verify production app is live

### 6. Set Up Custom Domains (Optional)
- [ ] Staging URL: `staging.coachingplatform.taleemabad.com`
  - In Railway Staging project → Domain → Add custom domain
  - Point DNS to Railway CNAME
  - Update DEPLOYMENT.md with actual URL
- [ ] Production URL: `coachingplatform.taleemabad.com`
  - Same process for production project

### 7. Configure GitHub Environments (Optional but Recommended)
- [ ] Go to GitHub repo → Settings → Environments
- [ ] Create environment `staging`
  - Add required reviewers (optional)
  - Add deployment branches: `staging`
  - Add secrets: `RAILWAY_TOKEN_STAGING`
- [ ] Create environment `production`
  - Add required reviewers (Jalal + 1 other)
  - Add deployment branches: `main`
  - Add secrets: `RAILWAY_TOKEN_PRODUCTION`

### 8. Document Supabase Staging Credentials (Secure!)
- [ ] Store staging Supabase keys in a secure location
  - 1Password / LastPass / GitHub Secrets
  - Staging keys: Project ID, Publishable Key, Service Role Key
- [ ] Do NOT commit keys to git (already in .gitignore)

---

## Time Estimate

| Task | Time | Notes |
|------|------|-------|
| Supabase staging | 5 min | Dashboard → Create project |
| Railway staging | 5 min | Dashboard → Create project → Link repo |
| Railway secrets | 5 min | Get tokens, add to GitHub |
| Test staging deploy | 10 min | Dummy commit, watch CI/CD |
| Test prod deploy | 10 min | Merge to main, watch CI/CD |
| Custom domains | 10 min | (Optional) |
| GitHub environments | 5 min | (Optional) |
| **Total** | **50 min** | Can do in parallel |

---

## Next: Development Workflow

Once setup is complete:

```bash
# 1. Create feature branch from staging
git checkout staging && git pull origin staging
git checkout -b feature/my-feature

# 2. Work normally
git add . && git commit -m "feat: my feature"
git push origin feature/my-feature

# 3. Create PR: feature/my-feature → staging
# (on GitHub.com)

# 4. After approval & merge: auto-deploy to staging
# (GitHub Actions auto-runs)

# 5. Test on staging.coachingplatform.taleemabad.com

# 6. Merge staging → main for production
git checkout main && git pull origin main
git merge --no-ff staging
git push origin main
# (GitHub Actions auto-deploys to production)
```

---

## Debugging

### If auto-deploy fails:
```bash
# Check GitHub Actions logs
# → Go to repo → Actions tab → click "Deploy" workflow

# Manual deploy to staging
railway link  # select coaching-platform-staging project
railway environment staging
railway up --detach

# Manual deploy to production
railway link  # select coaching-platform-prod project
railway environment production
railway up --detach
```

### If Supabase migrations fail:
```bash
# Check migrations
supabase link --project-ref <staging-id>
supabase status

# Re-apply migrations
supabase db push

# Or reset staging (wipes data, applies from scratch)
supabase db reset
```

---

## Status Tracker

- [ ] Staging Supabase created
- [ ] Staging Railway created
- [ ] Railway tokens added to GitHub
- [ ] Auto-deploy to staging tested ✅
- [ ] Auto-deploy to production tested ✅
- [ ] Custom domains configured
- [ ] GitHub environments configured
- [ ] Team notified of new workflow

**Estimated Completion:** 2026-04-10 (today, ~1 hour)

