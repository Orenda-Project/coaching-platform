# 🚀 Quick Start — Staging/Production

---

## Find Your Staging Live URL

```
1. Go to: https://railway.app/dashboard
2. Click: "coaching-platform-staging" project
3. Look: Deployments → green ✓ (successful build)
4. Copy: The domain URL
5. Open: In browser (should see landing page)
```

---

## Test Staging

```bash
# Signup
URL: https://your-staging-url/signup
Email: testcoach+staging@example.com
Password: Test123!

# Test baseline → modules → endline → certificate
# Should complete full flow in <10 minutes
```

---

## Development Workflow

```bash
# 1. Create feature from staging
git checkout staging && git pull origin staging
git checkout -b feature/your-feature-name

# 2. Work, commit, push
git add . && git commit -m "feat: description"
git push origin feature/your-feature-name

# 3. Create PR on GitHub: feature/* → staging
# (After approval & merge, auto-deploys to staging)

# 4. Test on staging environment

# 5. Merge to production
git checkout main && git pull origin main
git merge --no-ff staging
git push origin main
# (Auto-deploys to production)
```

---

## Key URLs

| Env | URL | Supabase |
|---|---|---|
| **Staging** | Find in Railway dashboard | kddvxrlffafyjvvststh |
| **Production** | TBD (after main deploy) | agziuwqpkfmxtospfxns |
| **Local** | http://localhost:5173 | http://127.0.0.1:54321 |

---

## Important

- ✅ Test all features on staging before production
- ✅ Create test users with +staging in email: testcoach+staging@example.com
- ✅ Use `feature/*` branches for all work
- ❌ Do NOT copy production data to staging
- ❌ Do NOT push directly to `main`

---

## If Something Breaks

```bash
# Check Railway logs
railway logs

# Check migrations
supabase status

# Reset staging database (wipes & re-applies migrations)
supabase db reset
```

---

## Documentation

- `STAGING_READY.md` — Complete checklist
- `FIND_STAGING_URL.md` — How to find live link
- `STAGING_VERIFICATION.md` — Detailed testing guide
- `DEPLOYMENT.md` — Full branching strategy

---

**Status:** 🟢 Ready to test!

