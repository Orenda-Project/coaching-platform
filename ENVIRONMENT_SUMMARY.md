# Environment Summary
**Coaching Platform — GitHub, Railway, Supabase**
**Created:** 2026-04-10

---

## Quick Reference

```
GitHub                Railway              Supabase
─────────────────────────────────────────────────────────

main (prod)     ─→   Production           agziuwqpkfmxtospfxns
                      (web service)       (current DB)

staging         ─→   Staging              (create new)
                      (web service)

feature/*       ─→   (no deploy)          (no changes)
                      (PR testing)
```

---

## Current Status

| Component | Status | Details |
|-----------|--------|---------|
| **GitHub Repo** | ✅ Active | `Orenda-Project/coaching-platform` |
| **Main Branch** | ✅ Live | Production code (970f61d) |
| **Staging Branch** | ✅ Created | Feature testing (026037f) |
| **Railway Production** | ✅ Ready | Needs GitHub token in secrets |
| **Railway Staging** | ⏳ To Create | New project needed |
| **Supabase Production** | ✅ Live | `agziuwqpkfmxtospfxns` |
| **Supabase Staging** | ⏳ To Create | New database needed |
| **GitHub Actions** | ✅ Ready | `.github/workflows/deploy.yml` created |
| **Environment Secrets** | ⏳ To Add | `RAILWAY_TOKEN_STAGING` & `RAILWAY_TOKEN_PRODUCTION` |

---

## Deployment Flow

```
1. Feature Development
   └─ git checkout -b feature/xyz
   └─ git push origin feature/xyz
   └─ Create PR: feature/xyz → staging

2. Staging Testing
   └─ Reviewer approves PR
   └─ Merge to staging
   └─ GitHub Actions triggers
   └─ Test at staging.coachingplatform.taleemabad.com

3. Production Release
   └─ git checkout main && git merge staging
   └─ GitHub Actions triggers
   └─ Deploy to production
   └─ Live at coachingplatform.taleemabad.com
```

---

## File Structure

```
coaching-platform/
├── DEPLOYMENT.md              ← Complete deployment guide
├── SETUP_CHECKLIST.md         ← Step-by-step setup tasks
├── ENVIRONMENT_SUMMARY.md     ← This file
├── .env.production            ← Production config (committed, non-secrets)
├── .env.staging               ← Staging config (committed, placeholder)
├── .env.example               ← Template for .env.local
├── .env                       ← Current (production)
├── .env.local                 ← Local dev (not committed)
├── .github/
│   └── workflows/
│       └── deploy.yml         ← Auto-deploy on push to main/staging
└── railway.json               ← Railway build config
```

---

## Key URLs

| Environment | URL | Status | Branch |
|---|---|---|---|
| **Production** | https://coachingplatform.taleemabad.com | 🟡 Needs domain | `main` |
| **Staging** | https://staging.coachingplatform.taleemabad.com | 🟡 Needs domain | `staging` |
| **Local** | http://localhost:5173 | ✅ Ready | (any) |

---

## Commands You'll Use Most

```bash
# Start new feature
git checkout staging && git pull origin staging
git checkout -b feature/module-2-content
git push -u origin feature/module-2-content

# After PR merge to staging (auto-deploys)
# Test on staging...

# Merge to production
git checkout main && git pull origin main
git merge --no-ff staging
git push origin main
# (auto-deploys to production)

# Rollback if needed
git revert <commit-hash>
git push origin main

# Check deploy status
# → Go to GitHub Actions tab → see deploy workflow
```

---

## Branching Strategy (Git Flow)

```
         feature/module-2  ──────┐
                                 │ PR → staging
                                 ↓
main ◄─── staging ◄────────────────────────────┐
 ↑                                             │
 │ merge --no-ff staging                       │
 │                                             │
 └─── merge + auto-deploy                  auto-deploy
      to production                        to staging
```

---

## Railway Secrets Required

Before GitHub Actions can deploy, add these secrets to GitHub:

**Settings → Secrets and variables → Actions**

```
RAILWAY_TOKEN_STAGING=<token from railway token>
RAILWAY_TOKEN_PRODUCTION=<token from railway token>
```

Get tokens:
```bash
railway login
railway token  # for production
railway token  # for staging (different project)
```

---

## Supabase Staging Setup (TODO)

1. Go to https://supabase.com/dashboard
2. Create new project:
   - Name: `coaching-platform-staging`
   - Region: Same as production
   - Database password: Generate secure password
3. Wait for setup (~2 min)
4. Copy:
   - Project ID
   - Publishable Key
   - Service Role Key (for migrations)
5. Update `.env.staging` with keys
6. Apply migrations:
   ```bash
   supabase link --project-ref <staging-project-id>
   supabase db push
   ```

---

## Testing Auto-Deploy

### Test Staging Deploy
```bash
git checkout staging
echo "# Test" >> TEST.md
git add TEST.md
git commit -m "test: trigger staging deploy"
git push origin staging
# → Watch GitHub Actions (Actions tab)
# → Should deploy in ~3-5 min
```

### Test Production Deploy
```bash
git checkout main && git pull origin main
git merge --no-ff staging
git push origin main
# → Watch GitHub Actions
# → Should deploy in ~3-5 min
```

---

## Troubleshooting

### Deploy fails on GitHub Actions
```
Error: RAILWAY_TOKEN not found
→ Solution: Add secrets to GitHub Settings
```

```
Error: Can't find node_modules
→ Solution: Check `npm ci` step in .github/workflows/deploy.yml
```

### Supabase migrations don't apply
```
Error: Migration already applied
→ Solution: Check supabase/migrations/ for conflicts
→ Reset staging: supabase db reset
```

### Can't access staging app
```
Error: 404 or DNS error
→ Solution: Check Railway Staging project → Domains
→ Verify CNAME is pointing to Railway
→ Wait 5-10 min for DNS propagation
```

---

## Next Steps

1. **Create staging Supabase** (5 min)
2. **Create staging Railway** (5 min)
3. **Add GitHub secrets** (3 min)
4. **Test staging deploy** (10 min)
5. **Test production deploy** (10 min)
6. **Document results** (2 min)

**Total:** ~35 minutes to full production readiness

---

## Team Permissions

| Role | Can Deploy | Can Merge to Main | Can Create Branches |
|------|-----------|------------------|-------------------|
| **Jalal** (Owner) | ✅ Yes | ✅ Yes | ✅ Yes |
| **Hammad** (Dev) | ✅ Yes | ⚠️ PR Required | ✅ Yes |
| **Umar** (QA) | ❌ No | ❌ No | ✅ Yes |

---

**Last Updated:** 2026-04-10
**Status:** 🟡 **Ready for staging Supabase/Railway setup**

