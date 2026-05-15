# Coach Enrollment Checklist

Quick reference for enrolling coaches in the vacation engagement feature.

---

## ⚡ Quick Start: Bulk Enroll All Coaches (Recommended)

If you have many coaches (the common case):

```sql
-- Step 1: See how many coaches you have
SELECT COUNT(*) as total_coaches
FROM auth.users
WHERE email ILIKE '%coach%'
   OR email ILIKE '%mentor%'
   OR email ILIKE '%trainer%';

-- Step 2: Enroll ALL coaches at once
INSERT INTO public.user_roles (user_id, role)
SELECT id, 'coach'
FROM auth.users
WHERE email ILIKE '%coach%'
   OR email ILIKE '%mentor%'
   OR email ILIKE '%trainer%'
ON CONFLICT (user_id, role) DO NOTHING;

-- Step 3: Verify enrollment
SELECT COUNT(*) as enrolled_coaches
FROM public.user_roles
WHERE role = 'coach';

-- Step 4: List all enrolled coaches
SELECT u.email, u.id, ur.created_at
FROM public.user_roles ur
JOIN auth.users u ON ur.user_id = u.id
WHERE ur.role = 'coach'
ORDER BY u.email;
```

Done! ✅ All coaches now see all 6 modules.

---

## Single Coach Enrollment (If Needed)

### Step 1: Get Coach Email/UUID

```bash
# Option A: From coach's Supabase account
# (Admin Dashboard → Authentication → Users → find coach → copy UUID)

# Option B: From database query (if you know email)
SELECT id, email FROM auth.users WHERE email = 'coach@taleemabad.com';
```

### Step 2: Add Coach Role

Run this SQL in Supabase SQL Editor:

```sql
INSERT INTO public.user_roles (user_id, role)
VALUES ('<COACH-UUID>', 'coach')
ON CONFLICT (user_id, role) DO NOTHING;
```

**Replace** `<COACH-UUID>` with the actual UUID from Step 1.

### Step 3: Verify Coach Can See All Modules

```sql
-- Check that the coach role was added
SELECT user_id, role FROM public.user_roles
WHERE user_id = '<COACH-UUID>';

-- Should return: (coach-uuid, 'coach')
```

### Step 4: Coach Login Test

1. Coach logs in to app
2. Completes onboarding (if new user)
3. Takes baseline assessment (if needed)
4. Dashboard shows all 6 modules ✅

---

## Common Bulk Operations

### Add Specific List of Coaches (by email)

```sql
INSERT INTO public.user_roles (user_id, role)
VALUES
  ((SELECT id FROM auth.users WHERE email = 'ahmed.coach@taleemabad.com'), 'coach'),
  ((SELECT id FROM auth.users WHERE email = 'fatima.mentor@taleemabad.com'), 'coach'),
  ((SELECT id FROM auth.users WHERE email = 'hassan.trainer@taleemabad.com'), 'coach')
ON CONFLICT (user_id, role) DO NOTHING;
```

### View All Enrolled Coaches

```sql
SELECT u.email, u.id, ur.role, ur.created_at
FROM public.user_roles ur
JOIN auth.users u ON ur.user_id = u.id
WHERE ur.role = 'coach'
ORDER BY u.email;
```

### Remove One Coach (Emergency)

```sql
DELETE FROM public.user_roles
WHERE user_id = '<COACH-UUID>' AND role = 'coach';
```

### Count Active Coaches

```sql
SELECT COUNT(*) as active_coaches
FROM public.user_roles
WHERE role = 'coach';
```

### Rollback: Disable ALL Coaches (Post-Vacation, 2026-06-15)

```sql
DELETE FROM public.user_roles WHERE role = 'coach';
```

This reverts all coaches to persona-based filtering (original behavior).

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Coach still sees filtered modules | Browser cache. Clear cache or use private/incognito window. |
| Coach UUID not found | Run: `SELECT id, email FROM auth.users WHERE email ILIKE '%coach%';` |
| Role not in user_roles | Check for conflicts: `SELECT * FROM user_roles WHERE user_id = '<UUID>';` |
| Bulk insert not working | Verify migration 20260515000004 applied: `SELECT enum_range(NULL::app_role);` |
| Need to see coaches with specific pattern | `SELECT id, email FROM auth.users WHERE email ILIKE '%pattern%';` |

---

## Dashboard Check

After enrollment, coaches should:
1. ✅ Log in
2. ✅ See Dashboard with all 6 modules (not filtered)
3. ✅ Be able to take baseline/endline assessments
4. ✅ See unlimited quiz attempts
5. ✅ See analytics tracked

---

## Quick SQL Cheatsheet

| Task | SQL |
|------|-----|
| **Bulk enroll all coaches** | `INSERT INTO public.user_roles (user_id, role) SELECT id, 'coach' FROM auth.users WHERE email ILIKE '%coach%' ON CONFLICT (user_id, role) DO NOTHING;` |
| **Count coaches** | `SELECT COUNT(*) FROM public.user_roles WHERE role = 'coach';` |
| **List coaches** | `SELECT u.email FROM public.user_roles ur JOIN auth.users u ON ur.user_id = u.id WHERE ur.role = 'coach';` |
| **Find coaches by pattern** | `SELECT id, email FROM auth.users WHERE email ILIKE '%coach%';` |
| **Remove one coach** | `DELETE FROM public.user_roles WHERE user_id = '<UUID>' AND role = 'coach';` |
| **Remove all coaches** | `DELETE FROM public.user_roles WHERE role = 'coach';` |

---

## Timeline

| Date | Action |
|------|--------|
| 2026-05-15 | Feature released. Enroll coaches using queries above. |
| 2026-05-20 | Check: coaches seeing all modules? ✅ |
| 2026-06-10 | Notify coaches: vacation engagement ends 2026-06-15 |
| 2026-06-15 | **Rollback:** Run `DELETE FROM public.user_roles WHERE role = 'coach';` |
| 2026-06-16 | Verify: coaches see persona-based modules only |

---

## Notes

- **No migration needed** for coaches — they're enrolled via SQL in user_roles table
- **Data preserved** — all training progress saved after rollback
- **Zero downtime** — coaches revert to persona automatically
- **All coaches at once** — bulk SQL handles many coaches efficiently
