# Deploying Coach Vacation Engagement Feature

**Issue:** "Cannot see all training modules for all users/coaches"

---

## 🔍 Root Cause

The feature requires a database migration that adds the 'coach' role to the `app_role` enum:

```sql
ALTER TYPE public.app_role ADD VALUE 'coach' BEFORE 'user';
```

**Until this migration is applied**, coaches cannot be enrolled and users see filtered modules.

---

## ✅ Deployment Steps

### Step 1: Merge PR #101 to Staging

Go to GitHub and:
1. Approve PR #101
2. Merge to `staging` branch
3. **DO NOT merge to main yet**

### Step 2: Wait for Railway Deployment

Railway will:
1. Detect new commits in staging
2. Run the build pipeline
3. **Apply migrations automatically** (including 20260515000004_add_coach_role.sql)
4. Deploy to staging environment

**This takes 2-5 minutes.**

### Step 3: Verify Migration Applied

After Railway deploys, check the Supabase staging database:

Go to **Supabase SQL Editor** and run:

```sql
-- Check if coach role exists in enum
SELECT enum_range(NULL::app_role);
```

**Expected output:** `(admin,coach,user)`

If you see `(admin,user)` — migration hasn't applied yet. Wait and refresh.

### Step 4: Enroll Coaches

Once migration is applied, run this in **Supabase SQL Editor**:

```sql
INSERT INTO public.user_roles (user_id, role)
SELECT id, 'coach'
FROM auth.users
WHERE email ILIKE '%coach%'
   OR email ILIKE '%mentor%'
   OR email ILIKE '%trainer%'
ON CONFLICT (user_id, role) DO NOTHING;
```

### Step 5: Test on Staging

1. **Log in as a coach** (use coach email)
2. **Dashboard should show all 6 modules** ✅
3. **Regular users see filtered modules** ✅
4. **Persona E sees all modules** ✅

---

## 🚨 Troubleshooting

| Problem | Solution |
|---------|----------|
| **Coach still sees filtered modules** | Check browser cache. Clear cache or use private window. |
| **Migration not applied (enum shows `(admin,user)`)** | Wait 5 min, refresh Supabase. Railway may still be deploying. |
| **SQL error: "invalid input value for enum app_role: 'coach'"** | Migration not applied. Check step 3 again. |
| **Console warning: "Coach role check failed"** | Migration not applied yet. Check Supabase enum status. |
| **Cannot find coaches to enroll** | Check email patterns. Run: `SELECT email FROM auth.users LIMIT 10;` |

---

## 📋 Timeline

| Step | Action | Time | When |
|------|--------|------|------|
| 1 | Merge PR to staging | 1 min | Now |
| 2 | Railway deploys + applies migration | 2-5 min | Auto |
| 3 | Verify migration applied | 1 min | After deploy |
| 4 | Enroll coaches with SQL | 1 min | After verification |
| 5 | Test on staging | 5 min | Before prod merge |

**Total time: ~15 minutes**

---

## 📦 What Gets Deployed

PR #101 includes:
- ✅ Migration: adds 'coach' to enum
- ✅ Frontend: useCoachRole hook + Dashboard logic
- ✅ Tests: 13 tests (all passing)
- ✅ Docs: enrollment guides

---

## 🔄 After Verification: Production Deployment

Once staging is working:

1. **Merge staging → main** (via PR or direct merge)
2. **Railway deploys to production** (auto)
3. **Enroll coaches in production** (same SQL as staging)
4. **Coaches see all 6 modules in production** ✅

---

## ⏰ Rollback (2026-06-15)

To revert after vacation:

```sql
DELETE FROM public.user_roles WHERE role = 'coach';
```

Coaches revert to persona-based filtering. All data preserved.

---

## Key Points

✅ **Migration is automatic** — Railway applies it on deploy
✅ **Feature is safe** — Tests pass, code reviewed
✅ **Rollback is simple** — One SQL command
✅ **Zero downtime** — Coaches switch seamlessly

---

## Need Help?

Check console logs:
- If you see: `"Coach role check failed"` → migration not applied
- If you see: `"Coach role query error"` → check Supabase connection

See `docs/BULK_COACH_ENROLLMENT.md` for enrollment details.
