# Coach Vacation Engagement — Rollback Procedure

**Feature Period:** 2026-05-15 → 2026-06-15 (exactly one month)

**After 2026-06-15:** Coaches see persona-based trainings again (not all modules).

---

## Automatic Rollback System

The feature is controlled by a **reversible, date-based flag** in the `coach_role_config` table:

```
┌─────────────────────────────────────┐
│  coach_role_config (id=1)           │
├─────────────────────────────────────┤
│ is_active: true                     │  ← Controls the feature
│ feature_start_date: 2026-05-15      │
│ feature_end_date: 2026-06-15        │
│ created_at: [timestamp]             │
│ updated_at: [timestamp]             │
└─────────────────────────────────────┘
```

## How the Trigger Works

**When a new user signs up:**
1. Auth.users INSERT fires the `assign_coach_role_on_signup` trigger
2. Trigger checks: `SELECT is_active FROM coach_role_config WHERE id = 1`
3. If `is_active = true` → Automatically assign 'coach' role to user_roles
4. If `is_active = false` → Skip assignment (future signups won't be coaches)

**Result:**
- Users signed up between 2026-05-15 and end of feature → have 'coach' role
- Users signed up after rollback → no 'coach' role (see persona-based trainings)

---

## Rollback Steps (Run on 2026-06-15)

### Step 1: Disable Feature Flag

Run in Supabase SQL Editor:

```sql
UPDATE public.coach_role_config
SET is_active = false
WHERE id = 1;

-- Verify
SELECT is_active, feature_end_date FROM public.coach_role_config WHERE id = 1;
```

**Effect:** New users will no longer be auto-assigned the 'coach' role.

### Step 2: Remove Existing Coach Roles

```sql
-- Count how many coach roles will be deleted
SELECT COUNT(*) as coaches_to_remove FROM public.user_roles WHERE role = 'coach';

-- Delete all coach roles
DELETE FROM public.user_roles WHERE role = 'coach';

-- Verify deletion
SELECT COUNT(*) as remaining_coaches FROM public.user_roles WHERE role = 'coach';
```

**Effect:** All 33+ coaches are now removed from coach role. Dashboard filtering reverts to persona-based.

### Step 3: Clear Browser Cache

All logged-in users must clear cache to see the change:
- **Mac:** `Cmd+Shift+R`
- **Windows:** `Ctrl+Shift+R`

### Step 4: Verify Rollback

Log in as a coach and check Dashboard:

**Before Rollback (now):**
- See all 6 modules (Modules 1-6)
- Quiz allows unlimited attempts

**After Rollback (on 2026-06-15):**
- See Module 1 (is_mandatory=true) + weak_modules only
- Quiz allows max 3 attempts per module
- Persona-based filtering restored

Example: If a coach has `weak_modules: ["Module 2", "Module 3"]`:
- Before: See all 6 modules
- After: See Module 1 + Module 2 + Module 3 only

---

## Optional: Full Cleanup

After rollback, you can optionally remove the trigger and config table:

```sql
-- Drop the trigger
DROP TRIGGER IF EXISTS assign_coach_role_on_signup ON auth.users;

-- Drop the trigger function
DROP FUNCTION IF EXISTS public.assign_coach_role_on_signup();

-- Drop the config table
DROP TABLE IF EXISTS public.coach_role_config;
```

**⚠️ Warning:** Only do this if you're 100% sure you won't need coaches to have the role again in the future.

---

## Timeline & Reminders

| Date | Action | Responsibility |
|------|--------|-----------------|
| 2026-05-15 | Merge PR #101 (coach vacation feature) | Dev |
| 2026-05-15 | Bulk enroll 33 coaches with `INSERT INTO user_roles` | Jalal |
| 2026-05-15 → 2026-06-15 | Coaches see all 6 modules | Users |
| 2026-06-15 | **Run rollback SQL (Steps 1-2 above)** | Jalal |
| 2026-06-15 | Clear browser cache | All coaches |
| 2026-06-15 | Verify persona-based filtering restored | Jalal |

---

## FAQ

**Q: What if I need to extend the feature past 2026-06-15?**

A: Update the config table:

```sql
UPDATE public.coach_role_config
SET feature_end_date = '2026-07-15'::TIMESTAMP,
    updated_at = NOW()
WHERE id = 1;
```

The feature stays active as long as `is_active = true`.

**Q: What if I need to re-enable the feature later?**

A: Flip the flag and re-enroll coaches:

```sql
-- Re-enable feature
UPDATE public.coach_role_config SET is_active = true WHERE id = 1;

-- Re-enroll coaches (same bulk SQL as before)
INSERT INTO public.user_roles (user_id, role)
SELECT u.id, 'coach'
FROM auth.users u
WHERE u.id NOT IN (
  SELECT user_id FROM public.user_roles WHERE role = 'admin'
)
ON CONFLICT (user_id, role) DO NOTHING;
```

**Q: Do existing coaches lose access to their progress?**

A: No. Their trainings, quiz attempts, and progress are preserved. Only the **module visibility** changes based on persona/weak_modules.

**Q: What about Persona E users?**

A: Persona E users always see all 6 modules (in Dashboard.tsx line 103: `if (isCoach || profile.persona === "E")`). The rollback doesn't affect them.

---

## Confirmation Checklist

Before going live with the coach vacation feature:

- [ ] New migration applied (20260515000005)
- [ ] 33 coaches bulk-enrolled with `INSERT INTO user_roles`
- [ ] Dashboard shows all 6 modules for coaches
- [ ] Feature flag is `is_active = true` in coach_role_config
- [ ] Calendar reminder set for 2026-06-15
- [ ] Rollback SQL saved in Slack/docs

✅ **Ready to launch the one-month coach vacation engagement!**
