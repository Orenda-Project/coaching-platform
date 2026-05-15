# Coach Enrollment Checklist

Quick reference for enrolling coaches in the vacation engagement feature.

---

## Step 1: Get Coach Email/UUID

```bash
# Option A: From coach's Supabase account
# (Admin Dashboard → Authentication → Users → find coach → copy UUID)

# Option B: From database query (if you know email)
SELECT id, email FROM auth.users WHERE email = 'coach@taleemabad.com';
```

---

## Step 2: Add Coach Role

Run this SQL in Supabase SQL Editor:

```sql
INSERT INTO public.user_roles (user_id, role)
VALUES ('<COACH-UUID>', 'coach')
ON CONFLICT (user_id, role) DO NOTHING;
```

**Replace** `<COACH-UUID>` with the actual UUID from Step 1.

---

## Step 3: Verify Coach Can See All Modules

```sql
-- Check that the coach role was added
SELECT user_id, role FROM public.user_roles
WHERE user_id = '<COACH-UUID>';

-- Should return: (coach-uuid, 'coach')
```

---

## Step 4: Coach Login Test

1. Coach logs in to app
2. Completes onboarding (if new user)
3. Takes baseline assessment (if needed)
4. Dashboard shows all 6 modules ✅

---

## Bulk Enrollment (Multiple Coaches)

```sql
INSERT INTO public.user_roles (user_id, role)
VALUES
  ('<UUID-1>', 'coach'),
  ('<UUID-2>', 'coach'),
  ('<UUID-3>', 'coach')
ON CONFLICT (user_id, role) DO NOTHING;
```

---

## View All Enrolled Coaches

```sql
SELECT u.email, u.id, ur.role
FROM public.user_roles ur
JOIN auth.users u ON ur.user_id = u.id
WHERE ur.role = 'coach'
ORDER BY u.email;
```

---

## Remove Coach (Emergency)

```sql
DELETE FROM public.user_roles
WHERE user_id = '<COACH-UUID>' AND role = 'coach';
```

---

## Count Active Coaches

```sql
SELECT COUNT(*) as active_coaches
FROM public.user_roles
WHERE role = 'coach';
```

---

## Rollback: Disable All Coaches (Post-Vacation)

```sql
DELETE FROM public.user_roles WHERE role = 'coach';
```

This reverts all coaches to persona-based filtering (original behavior).

---

## Troubleshooting

**Q: Coach still sees filtered modules after enrollment?**
- A: Browser cache. Have coach clear browser cache or open app in private/incognito window.

**Q: Coach UUID not found?**
- A: Verify email spelling in auth.users table: `SELECT id, email FROM auth.users WHERE email LIKE '%coach%';`

**Q: Role not appearing in user_roles?**
- A: Check for conflicts: `SELECT * FROM user_roles WHERE user_id = '<UUID>';` (should be empty if new)

**Q: Multiple coaches can't access modules?**
- A: Verify migration 20260515000004 applied: `SELECT enum_range(NULL::app_role);` (should show 'admin', 'coach', 'user')

---

## Quick Buttons

| Task | SQL |
|------|-----|
| Add one coach | `INSERT INTO public.user_roles (user_id, role) VALUES ('<UUID>', 'coach');` |
| Add 3 coaches | Use bulk INSERT above |
| List all coaches | `SELECT u.email FROM public.user_roles ur JOIN auth.users u ON ur.user_id = u.id WHERE ur.role = 'coach';` |
| Remove one coach | `DELETE FROM public.user_roles WHERE user_id = '<UUID>' AND role = 'coach';` |
| Disable all coaches | `DELETE FROM public.user_roles WHERE role = 'coach';` |
| Count coaches | `SELECT COUNT(*) FROM public.user_roles WHERE role = 'coach';` |

---

## Deadline Reminder

**Rollback Date:** 2026-06-15

After vacation ends, run the "Remove All Coaches" SQL to restore persona-based filtering.
