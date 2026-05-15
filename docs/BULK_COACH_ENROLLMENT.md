# Bulk Coach Enrollment — Quick Reference

**For Jalal:** You have many coaches to enroll, not just one. Use this guide.

---

## 🚀 One Command: Enroll All Coaches

Go to Supabase SQL Editor and run this:

```sql
INSERT INTO public.user_roles (user_id, role)
SELECT id, 'coach'
FROM auth.users
WHERE email ILIKE '%coach%'
   OR email ILIKE '%mentor%'
   OR email ILIKE '%trainer%'
ON CONFLICT (user_id, role) DO NOTHING;
```

**That's it.** All coaches now see all 6 modules.

---

## ✅ Verify It Worked

```sql
-- How many coaches enrolled?
SELECT COUNT(*) as total_coaches
FROM public.user_roles
WHERE role = 'coach';

-- List them all
SELECT u.email, u.id
FROM public.user_roles ur
JOIN auth.users u ON ur.user_id = u.id
WHERE ur.role = 'coach'
ORDER BY u.email;
```

---

## 📊 Check Coach Activity

```sql
-- See coaches accessing modules
SELECT DISTINCT user_id, event_type, COUNT(*) as count
FROM public.analytics_events
WHERE event_type IN ('module_start', 'module_complete', 'quiz_attempt')
GROUP BY user_id, event_type
ORDER BY count DESC;
```

---

## 🔄 Rollback (2026-06-15)

```sql
-- One command restores persona-based filtering
DELETE FROM public.user_roles WHERE role = 'coach';
```

Coaches revert to their baseline-assigned persona. All data stays.

---

## Custom Patterns (If Needed)

**Only coaches with 'lead' in email:**
```sql
INSERT INTO public.user_roles (user_id, role)
SELECT id, 'coach'
FROM auth.users
WHERE email ILIKE '%lead%'
ON CONFLICT (user_id, role) DO NOTHING;
```

**Only coaches from specific domain:**
```sql
INSERT INTO public.user_roles (user_id, role)
SELECT id, 'coach'
FROM auth.users
WHERE email ILIKE '%@taleemabad.com'
  AND (email ILIKE '%coach%' OR email ILIKE '%mentor%')
ON CONFLICT (user_id, role) DO NOTHING;
```

**Specific list by email:**
```sql
INSERT INTO public.user_roles (user_id, role)
VALUES
  ((SELECT id FROM auth.users WHERE email = 'ahmed@taleemabad.com'), 'coach'),
  ((SELECT id FROM auth.users WHERE email = 'fatima@taleemabad.com'), 'coach'),
  ((SELECT id FROM auth.users WHERE email = 'hassan@taleemabad.com'), 'coach')
ON CONFLICT (user_id, role) DO NOTHING;
```

---

## Timeline

| When | What | Command |
|------|------|---------|
| **Now (2026-05-15)** | Enroll coaches | Run bulk INSERT above |
| **2026-05-20** | Verify | Run `SELECT COUNT(*)` verification |
| **2026-06-10** | Notify coaches | Email: vacation engagement ends 2026-06-15 |
| **2026-06-15** | Rollback | Run `DELETE FROM public.user_roles...` |

---

## That's All

- No code changes needed
- No downtime
- Coaches see all 6 modules immediately after enrollment
- Reversible with one SQL command in one month

Done! ✅
