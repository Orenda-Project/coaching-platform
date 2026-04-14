# Deployment Strategy — Staging → Production
**Coaching Platform | Taleemabad**
**Created:** 2026-04-10

---

## Overview

Multi-environment setup with **GitHub branches**, **Railway projects**, and **Supabase projects**.

```
┌─────────────────────┐
│   GitHub (Code)     │
├─────────────────────┤
│ main (production)   │
│ staging             │ ← feature branches merge here
│ feature/*           │ ← individual features
└─────────────────────┘
        │
        ├──→ [Railway: Production] ← main branch
        └──→ [Railway: Staging]    ← staging branch

        Each Railway env has its own:
        - Supabase project (prod DB vs staging DB)
        - Environment variables
        - Build/deploy pipeline
```

---

## GitHub Branches

### Main Branches

| Branch | Purpose | Deploy To | Merge Policy |
|--------|---------|-----------|--------------|
| `main` | Production code | Railway: **Production** | Only merge from `staging` after QA |
| `staging` | Testing/QA environment | Railway: **Staging** | Merge feature branches here |

### Feature Branches

```bash
git checkout -b feature/module-2-content
git checkout -b fix/baseline-redirect-loop
git checkout -b chore/update-dependencies
```

**Naming convention:**
- `feature/*` — new features
- `fix/*` — bug fixes
- `chore/*` — dependencies, configs
- `docs/*` — documentation

---

## Git Workflow

### Step 1: Create Feature Branch from Staging
```bash
cd /Users/mac/Desktop/data/Taleemabad/coaching-platform
git checkout staging
git pull origin staging
git checkout -b feature/your-feature-name
```

### Step 2: Work & Commit
```bash
# Make changes...
git add .
git commit -m "feat: your feature description"
git push origin feature/your-feature-name
```

### Step 3: Create Pull Request
On GitHub:
1. Push branch to GitHub
2. Create PR: `feature/your-feature-name` → `staging`
3. Add description, link to Jira if applicable
4. Request review

### Step 4: Merge to Staging (QA Testing)
```bash
# After PR approved:
git checkout staging
git pull origin staging
git merge --no-ff feature/your-feature-name
git push origin staging
# Railway auto-deploys to Staging
```

### Step 5: Test on Staging
- Test full flow on staging.coachingplatform.taleemabad.com
- Verify Supabase staging database
- Check logs for errors

### Step 6: Merge to Main (Production)
```bash
git checkout main
git pull origin main
git merge --no-ff staging
git push origin main
# Railway auto-deploys to Production
```

---

## Railway Setup

### Production Environment

**Railway Project:** `coaching-platform-prod`

- **Frontend service:** `web` → serves `dist/` on port 8080
- **Database:** Supabase production project
- **Environment variables:** see `.env.production` below

**Connect main branch:**
```bash
railway link  # link project to repo
railway env pull  # pull prod env vars
# GitHub trigger: on push to main → auto-deploy
```

### Staging Environment

**Railway Project:** `coaching-platform-staging`

- **Frontend service:** `web` → serves `dist/` on port 8080
- **Database:** Supabase staging project
- **Environment variables:** see `.env.staging` below

**Connect staging branch:**
```bash
railway link  # link project to repo
railway env pull  # pull staging env vars
# GitHub trigger: on push to staging → auto-deploy
```

---

## Supabase Setup

### Production Project

**ID:** `agziuwqpkfmxtospfxns` (current)

```
URL: https://agziuwqpkfmxtospfxns.supabase.co
Publishable Key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Service Role Key: (store in Railway prod env vars)
```

**Migrations:** All migrations in `supabase/migrations/` apply here

### Staging Project

**Create new Supabase project:**
```bash
# Via Supabase dashboard:
# 1. Go to https://supabase.com/dashboard
# 2. Create new project: name="coaching-platform-staging", region=same as prod
# 3. Copy Project ID and keys
```

**Copy schema from production:**
```bash
# Export prod schema
supabase db dump --db-url postgresql://... > production_schema.sql

# Import to staging
psql -h staging-db.supabase.co -U postgres -d postgres -f production_schema.sql
```

**OR use Supabase CLI to sync:**
```bash
supabase link --project-ref staging-project-id
supabase db push  # applies all migrations from supabase/migrations/
```

---

## Environment Variables

### `.env.production` (Production)
```bash
# Frontend
VITE_SUPABASE_PROJECT_ID=agziuwqpkfmxtospfxns
VITE_SUPABASE_URL=https://agziuwqpkfmxtospfxns.supabase.co
VITE_SUPABASE_PUBLISHABLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# Analytics (optional)
VITE_SENTRY_DSN=https://...

# Feature flags (if used)
VITE_ENVIRONMENT=production
```

**Store in Railway Production:**
```bash
railway env add VITE_SUPABASE_PROJECT_ID agziuwqpkfmxtospfxns
railway env add VITE_SUPABASE_URL https://agziuwqpkfmxtospfxns.supabase.co
railway env add VITE_SUPABASE_PUBLISHABLE_KEY eyJ...
railway env add VITE_ENVIRONMENT production
```

### `.env.staging` (Staging)
```bash
# Frontend (pointing to staging Supabase)
VITE_SUPABASE_PROJECT_ID=your-staging-project-id
VITE_SUPABASE_URL=https://your-staging-project-id.supabase.co
VITE_SUPABASE_PUBLISHABLE_KEY=your-staging-key

# Feature flags
VITE_ENVIRONMENT=staging
```

**Store in Railway Staging:**
```bash
railway env add VITE_SUPABASE_PROJECT_ID your-staging-project-id
railway env add VITE_SUPABASE_URL https://your-staging-project-id.supabase.co
railway env add VITE_SUPABASE_PUBLISHABLE_KEY your-staging-key
railway env add VITE_ENVIRONMENT staging
```

---

## Auto-Deploy Configuration

### GitHub Actions CI/CD

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy

on:
  push:
    branches:
      - main
      - staging

jobs:
  deploy-staging:
    if: github.ref == 'refs/heads/staging'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Deploy to Railway Staging
        run: |
          npm install -g @railway/cli
          railway up
        env:
          RAILWAY_TOKEN: ${{ secrets.RAILWAY_TOKEN_STAGING }}

  deploy-production:
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Deploy to Railway Production
        run: |
          npm install -g @railway/cli
          railway up
        env:
          RAILWAY_TOKEN: ${{ secrets.RAILWAY_TOKEN_PRODUCTION }}
```

### Manual Deploy (if auto-deploy fails)

```bash
# Deploy staging
railway environment staging
railway up --detach

# Deploy production
railway environment production
railway up --detach
```

---

## Data Management

### Syncing Data (Staging → Production)

⚠️ **NEVER sync production data to staging** (reverse is safe)

```bash
# Export staging data (for testing with realistic data)
supabase db dump --db-url postgresql://... > staging_backup.sql

# Reset staging to clean state
supabase db reset  # Wipes and re-applies migrations
```

### Backups

**Production:** Supabase auto-backups daily. Retention = 7 days.

**Staging:** Not critical, can reset anytime.

---

## Testing Checklist Before Merge to Main

- [ ] Feature works on staging environment
- [ ] No console errors in browser
- [ ] Database queries execute (check Network tab in DevTools)
- [ ] Mobile responsive (test on 375px viewport)
- [ ] All links work
- [ ] Forms submit correctly
- [ ] No sensitive data in logs or Network tab

---

## Troubleshooting

### Build Fails on Railway

```bash
# Check Railway logs
railway logs  # shows build & runtime logs

# Rebuild
railway up --detach

# Check environment variables
railway env list
```

### Database Connection Issues

```bash
# Test Supabase connection locally
supabase status  # shows connection URLs
```

### Rollback to Previous Version

```bash
# If production is broken:
git log --oneline main  # find last working commit
git revert <commit-hash>
git push origin main
# Railway auto-deploys reverted code
```

---

## Quick Reference

### Create & Merge a Feature
```bash
# 1. Create branch
git checkout staging && git pull origin staging
git checkout -b feature/my-feature

# 2. Work & push
git add . && git commit -m "feat: description"
git push origin feature/my-feature

# 3. Merge to staging (after PR approval)
git checkout staging && git pull
git merge --no-ff feature/my-feature
git push origin staging
# → Railway stages auto-deploys

# 4. Test on staging
# (verify at staging.coachingplatform.taleemabad.com)

# 5. Merge to main (after QA passes)
git checkout main && git pull
git merge --no-ff staging
git push origin main
# → Railway production auto-deploys
```

### Emergency Production Hotfix

```bash
# Only for critical bugs in production
git checkout main
git checkout -b hotfix/critical-bug-name
# Fix the bug
git add . && git commit -m "fix: description"
git push origin hotfix/critical-bug-name
# Create PR → main
# Merge to main after quick review
git push origin main
# → Railway deploys immediately

# Also merge back to staging
git checkout staging && git pull
git merge hotfix/critical-bug-name
git push origin staging
```

---

## URLs

| Environment | URL | Supabase | Railway |
|---|---|---|---|
| **Production** | https://coachingplatform.taleemabad.com | agziuwqpkfmxtospfxns | coaching-platform-prod |
| **Staging** | https://staging.coachingplatform.taleemabad.com | (create new) | coaching-platform-staging |
| **Local** | http://localhost:5173 | (local via supabase start) | N/A |

---

## Next Steps

1. **Create staging Supabase project** (5 min)
2. **Create staging Railway project** (5 min)
3. **Create staging branch** (1 min)
4. **Set up GitHub Actions** (5 min)
5. **Test auto-deploy:** push to staging → verify on Railway
6. **Test auto-deploy:** merge staging → main → verify production

Total setup time: **~20 minutes**

