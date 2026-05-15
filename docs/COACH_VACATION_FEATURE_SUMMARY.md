# Coach Vacation Engagement — Complete Implementation Summary

**Status:** Ready to deploy
**Period:** 2026-05-15 → 2026-06-15
**Coaches affected:** 33

---

## What Changed

### 1. Database Layer
- **Migration:** `20260515000005_add_coach_vacation_trigger_with_rollback.sql`
  - Adds `coach_role_config` table (feature flag with dates)
  - Creates `assign_coach_role_on_signup()` trigger function
  - Auto-assigns 'coach' role to new users if feature is active
  - Fully reversible on 2026-06-15

### 2. Code Layer
- **Dashboard.tsx** (line 103): Modified module filtering
  ```typescript
  // OLD: if (profile.persona !== "E") { ... }
  // NEW: if (isCoach || profile.persona === "E") { ... }
  ```
- **useCoachRole.ts**: Hook to detect coach role from user_roles table

### 3. Data Layer
- 33 coaches will be bulk-enrolled via SQL:
  ```sql
  INSERT INTO public.user_roles (user_id, role)
  SELECT u.id, 'coach'
  FROM auth.users u
  WHERE u.id NOT IN (SELECT user_id FROM public.user_roles WHERE role = 'admin')
  ON CONFLICT (user_id, role) DO NOTHING;
  ```

---

## Implementation Timeline

### Now (2026-05-15)
1. **Apply migration 20260515000005** (auto-deploying with PR #101 merge)
   - Adds feature flag table
   - Activates trigger
   - Feature starts automatically
2. **Run bulk enrollment SQL** (one query, 33 coaches)
   - Coaches can now see all 6 modules
   - Dashboard shows all trainings
3. **Clear cache & test**
   - Log in as a coach
   - Verify all 6 modules visible

### On 2026-06-15 (Exactly One Month)
1. **Disable feature flag:**
   ```sql
   UPDATE public.coach_role_config SET is_active = false WHERE id = 1;
   ```
2. **Remove all coach roles:**
   ```sql
   DELETE FROM public.user_roles WHERE role = 'coach';
   ```
3. **Clear user browsers**
   - Users see persona-based trainings again
   - Feature completely reversed

---

## Key Design Decisions

### ✅ Why this approach is reversible:

1. **Feature flag in database** → Can flip without code deploy
2. **Trigger respects the flag** → Future signups follow the flag state
3. **Coach role in user_roles** → Easy to bulk delete to revert
4. **No code changes on rollback** → Only SQL executed on 2026-06-15

### ✅ Why this works for new signups:

- Currently: coaches sign up → no role assigned → see persona-filtered trainings
- With feature: coaches sign up → trigger auto-assigns 'coach' role → see all trainings
- After rollback: coaches sign up → trigger skips assignment (flag is false) → see persona-filtered trainings

### ✅ Backward compatible:

- Persona E users unaffected (still see all 6 modules)
- Persona A-D users unaffected (filtered by weak_modules as before)
- Admins have both admin + coach roles (can access both dashboards)

---

## Rollback Checklist (For 2026-06-15)

- [ ] Run `UPDATE coach_role_config SET is_active = false`
- [ ] Run `DELETE FROM user_roles WHERE role = 'coach'`
- [ ] Ask users to clear cache (Cmd+Shift+R or Ctrl+Shift+R)
- [ ] Verify coaches see persona-based trainings
- [ ] Update feature flag in code (optional cleanup)

Full details: See `COACH_VACATION_ROLLBACK_PROCEDURE.md`

---

## What Coaches See

### During Vacation (2026-05-15 → 2026-06-15)

```
┌─────────────────────────────────────┐
│ Dashboard (All 6 Modules)           │
├─────────────────────────────────────┤
│ ✓ Module 1: Foundation              │
│ ✓ Module 2: Partnership             │
│ ✓ Module 3: Mirror                  │
│ ✓ Module 4: Digital                 │
│ ✓ Module 5: Catalyst                │
│ ✓ Module 6: Excellence              │
└─────────────────────────────────────┘
```

All modules visible regardless of weak_modules or attempt count.

### After Rollback (2026-06-16+)

```
┌─────────────────────────────────────┐
│ Dashboard (Persona-Based)           │
├─────────────────────────────────────┤
│ ✓ Module 1: Foundation (mandatory)  │
│ ✓ Module 2: Partnership (weak)      │
│ ✓ Module 3: Mirror (weak)           │
│ ✗ Module 4: Digital                 │
│ ✗ Module 5: Catalyst                │
│ ✗ Module 6: Excellence              │
└─────────────────────────────────────┘
```

Only mandatory modules + weak_modules visible (persona-filtered).

---

## Files & Documentation

| File | Purpose |
|------|---------|
| `20260515000005_add_coach_vacation_trigger_with_rollback.sql` | Migration: feature flag + auto-assign trigger |
| `COACH_VACATION_ROLLBACK_PROCEDURE.md` | Step-by-step rollback instructions |
| `COACH_VACATION_FEATURE_SUMMARY.md` | This file — overview & timeline |
| `BULK_COACH_ENROLLMENT.md` | Bulk SQL to enroll 33 coaches |
| PR #101 | Code changes (Dashboard.tsx, useCoachRole.ts) |

---

## Questions?

- **How do I know if the feature is active?** Check: `SELECT is_active FROM coach_role_config WHERE id = 1;`
- **How do I extend the vacation?** Update: `UPDATE coach_role_config SET feature_end_date = '2026-07-15' WHERE id = 1;`
- **Do coaches lose progress after rollback?** No. Only module visibility changes. All quiz attempts, progress, and scores are preserved.
- **What about new coaches signing up after rollback?** They won't be auto-assigned the 'coach' role (trigger checks flag). They'll see persona-filtered trainings.

---

**Ready to deploy? Run the bulk enrollment SQL and enjoy the coaching vacation! 🎉**
