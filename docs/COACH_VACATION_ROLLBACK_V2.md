# Coach Vacation Engagement — Rollback Procedure (V2)

**Feature Period:** 2026-05-15 → 2026-06-15 (exactly one month)

**Key Difference from V1:**
- ✅ Coach role STAYS in user_roles table (permanent)
- ✅ Only vacation mode flag is flipped on 2026-06-15
- ✅ Coaches revert to persona-based filtering without losing their role
- ✅ Coach role can be reused for admin dashboard or other features in the future

---

## How It Works

### Two Separate Systems

| Component | Permanence | Purpose | Controlled By |
|-----------|-----------|---------|---------------|
| **Coach role** | 🟢 Permanent | Identify who is a coach | `user_roles` table |
| **Vacation mode** | 🔴 Temporary (30 days) | Control module visibility | `coach_vacation_config` table |

### Dashboard Filtering Logic

```typescript
if (Persona E) {
  Show all 6 modules  // Always, no matter what
} else if (Coach AND vacation_mode_active) {
  Show all 6 modules  // Temporary: during vacation only
} else {
  Show Module 1 + weak_modules  // Persona-based filtering (default)
}
```

### Timeline

```
2026-05-15 ────────────── 2026-06-15 ────────────── ∞
    ↓                          ↓
    Coach vacation starts      Coach vacation ends
    vacation_mode_active=true  vacation_mode_active=false
    Coaches see all 6 modules  Coaches see weak_modules only
    Coach role assigned        Coach role STAYS
                               (reusable for future features)
```

---

## During Vacation (2026-05-15 → 2026-06-15)

**Coaches see:**
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

**Current config:**
```sql
SELECT vacation_mode_active FROM coach_vacation_config WHERE id = 1;
-- Result: true
```

---

## Rollback Steps (Run on 2026-06-15)

### Step 1: Disable Vacation Mode

Run in Supabase SQL Editor:

```sql
UPDATE public.coach_vacation_config
SET vacation_mode_active = false,
    updated_at = NOW()
WHERE id = 1;

-- Verify
SELECT vacation_mode_active, updated_at
FROM public.coach_vacation_config
WHERE id = 1;
```

**Effect:** New filtering logic takes effect immediately on next page load.

### Step 2: Verify Coach Roles Still Exist

```sql
-- Verify coaches still have their role
SELECT COUNT(*) as coaches_with_role
FROM public.user_roles
WHERE role = 'coach';

-- Should return: 33
```

**Effect:** Coach roles are NOT deleted. They stay in the database.

### Step 3: Clear Browser Cache

All logged-in users must clear cache to see the change:
- **Mac:** `Cmd+Shift+R`
- **Windows:** `Ctrl+Shift+R`
- **Tell users:** "Please refresh your browser with Cmd+Shift+R"

### Step 4: Verify Rollback

Log in as a coach and check Dashboard:

**Before Rollback (now):**
```
vacation_mode_active = true
Coaches see all 6 modules
```

**After Rollback (on 2026-06-15):**
```
vacation_mode_active = false
Coaches see Module 1 + weak_modules only
Coach role still in user_roles table
```

Example: A coach with `weak_modules: ["Module 2", "Module 3"]` will see:
- Module 1 (mandatory)
- Module 2 (weak)
- Module 3 (weak)
- NOT Module 4, 5, 6

---

## After Rollback: Coach Role Stays

### Why Keep the Role?

The coach role now has permanent uses:

1. **Admin Dashboard Access** — Coaches can access admin features to view their assigned teachers
2. **Future Features** — Any feature that needs "is this person a coach?" can use the role
3. **No Cleanup Needed** — The role doesn't harm anything. It's just a marker.
4. **Easy Re-Enable** — If you need vacation mode again, just set `vacation_mode_active = true`

### Can I Delete Coach Roles Later?

Yes, but not necessary. The coach role is harmless:

```sql
-- Only if you truly want to remove all coach roles
DELETE FROM public.user_roles WHERE role = 'coach';
```

But we recommend KEEPING them for future use.

---

## Re-Enable Vacation Mode (If Needed)

If you need to extend the vacation or re-enable it later:

```sql
-- Re-enable vacation mode anytime
UPDATE public.coach_vacation_config
SET vacation_mode_active = true,
    updated_at = NOW()
WHERE id = 1;

-- Coach roles don't need to be re-assigned (they're already there)
-- Coaches will immediately see all 6 modules again
```

**Benefit:** Coach roles are persistent, so you never need to bulk-assign them again.

---

## Rollback Checklist (For 2026-06-15)

Before executing rollback:
- [ ] Have the rollback SQL ready
- [ ] Notify coaches they might see module changes
- [ ] Have the cache-clearing instructions ready

Execute rollback:
- [ ] Run `UPDATE coach_vacation_config SET vacation_mode_active = false`
- [ ] Verify vacation_mode_active is now false
- [ ] Verify coach roles still exist (count = 33)

After rollback:
- [ ] Ask all users to clear cache (Cmd+Shift+R)
- [ ] Test as a coach account
- [ ] Verify Dashboard shows only Module 1 + weak_modules
- [ ] Verify Persona E users still see all 6 modules (unaffected)

---

## FAQ

**Q: Do coaches lose their progress?**
A: No. All quiz attempts, scores, and progress are preserved. Only module visibility changes.

**Q: What about Persona E users?**
A: Persona E users always see all 6 modules. The vacation mode doesn't affect them.

**Q: Can I re-enable vacation mode anytime?**
A: Yes. Just set `vacation_mode_active = true`. Coach roles are already assigned, so no bulk re-enrollment needed.

**Q: Do I need to delete coach roles on 2026-06-15?**
A: No. The role stays in the database and is harmless. Keep it for future use or admin dashboard access.

**Q: What if a coach signs up AFTER 2026-06-15?**
A: They'll still get the 'coach' role (from the auto-assign trigger in the previous migration). But vacation_mode_active will be false, so they'll see persona-filtered modules (not all 6). They can't use the vacation mode because it's already ended.

**Q: Can I update the vacation end date?**
A: Yes. Update the config table anytime:
```sql
UPDATE public.coach_vacation_config
SET vacation_end_date = '2026-07-15'::TIMESTAMP
WHERE id = 1;
```
The end_date is just documentation. The `vacation_mode_active` flag controls the actual feature.

---

## Timeline & Reminders

| Date | Action | Who |
|------|--------|-----|
| 2026-05-15 | Merge PR & apply migration | Dev |
| 2026-05-15 | Bulk enroll 33 coaches | Jalal |
| 2026-05-15 → 2026-06-14 | Coaches see all 6 modules | Users |
| **2026-06-15** | **Run rollback SQL** | Jalal |
| 2026-06-15 | Clear browser cache | All users |
| 2026-06-15 | Verify persona-based filtering | Jalal |

---

**✅ Ready for launch! Coach roles are permanent. Only vacation mode is temporary.**
