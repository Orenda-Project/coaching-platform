# Coach Vacation Engagement Feature

**Status:** Active ✅
**Duration:** 2026-05-15 to 2026-06-15 (one month)
**Feature ID:** coach-all-modules-vacation-engagement

---

## Overview

During the vacation engagement period, coaches can access and complete **all 6 training modules** without persona-based filtering restrictions. This enables meaningful engagement with coaches during scheduled vacations before persona-based training is re-enabled.

---

## How It Works

### For Coaches
- **Access:** All 6 modules visible in Dashboard (same as Persona E)
- **Quiz Attempts:** Unlimited quiz attempts (same as Persona E)
- **Baseline/Endline:** Standard assessments apply
- **Data Collection:** Full analytics tracking enabled

### For Non-Coaches
- **No Change:** Regular persona-based filtering applies
- **Persona A-D:** See mandatory Module 1 + weak modules from baseline
- **Persona E:** See all 6 modules (unchanged)

---

## Technical Implementation

### 1. Database Layer
**Migration:** `supabase/migrations/20260515000004_add_coach_role.sql`
- Added `'coach'` value to `app_role` enum
- No schema changes to `training_progress`, `trainings`, etc.
- Coaches use existing assessment/quiz infrastructure

### 2. Frontend Layer

#### Hook: `useCoachRole.ts`
```typescript
export function useCoachRole() {
  // Returns { isCoach: boolean, loading: boolean }
  // Queries user_roles table for 'coach' role
}
```

#### Dashboard Logic: `pages/Dashboard.tsx`
```typescript
const { isCoach } = useCoachRole();

let assignedModules = allModules;
if (isCoach || profile.persona === "E") {
  assignedModules = allModules; // Show all modules
} else {
  // Regular filtering for personas A-D
  const weakModules = profile.weak_modules || [];
  assignedModules = allModules.filter(
    (m) => m.is_mandatory || weakModules.some((wm) => m.title.startsWith(wm))
  );
}
```

---

## Role Assignment (for admins)

Coaches are identified by having a `'coach'` role in the `user_roles` table.

### Adding a coach role:
```sql
INSERT INTO public.user_roles (user_id, role)
VALUES ('coach-user-uuid', 'coach')
ON CONFLICT (user_id, role) DO NOTHING;
```

### Listing coaches:
```sql
SELECT user_id FROM public.user_roles WHERE role = 'coach';
```

### Removing coach access (rollback):
```sql
DELETE FROM public.user_roles WHERE role = 'coach';
```

---

## Testing

**Test File:** `src/domain/coach-module-access.test.ts`

Coverage:
- ✅ Coaches see all 6 modules (any persona)
- ✅ Personas A-D see filtered modules only
- ✅ Persona E continues to see all modules
- ✅ Edge cases: null persona, empty modules, etc.
- ✅ Rollback scenario: coaches revert to persona-based filtering

Run tests:
```bash
npm run test -- src/domain/coach-module-access.test.ts
```

---

## Rollback Plan (Post-Vacation)

**Timeline:** 2026-06-15
**Action:** Simple database operation, no code changes

### Option 1: Remove All Coach Roles (Recommended)
```sql
DELETE FROM public.user_roles WHERE role = 'coach';
```
All coaches revert to their assigned persona (assigned during baseline assessment).

### Option 2: Selective Removal
```sql
DELETE FROM public.user_roles
WHERE user_id = 'specific-coach-uuid' AND role = 'coach';
```
Remove specific coaches individually.

### Verification
After rollback, dashboard shows:
- Coaches with Persona A-D: See mandatory + weak modules only
- Coaches with Persona E: Continue to see all modules
- All analytics data preserved

---

## Monitoring

### Check if Feature is Active
```sql
SELECT COUNT(*) FROM public.user_roles WHERE role = 'coach';
```

### View Coach Access Logs
```sql
SELECT user_id, created_at, event_type
FROM public.analytics_events
WHERE event_type IN ('module_start', 'module_complete', 'quiz_attempt')
LIMIT 50;
```

### Dashboard Verification
1. Log in as a coach
2. Verify Dashboard shows all 6 modules
3. Verify quiz has no attempt limits

---

## Known Behaviors

| Scenario | Behavior | Reason |
|----------|----------|--------|
| Coach with Persona A assigned | Sees all 6 modules | isCoach=true overrides persona filter |
| Coach completes baseline | Still sees all 6 modules | Persona assignment does not affect coach flag |
| Coach attempts quiz 4th time | Allowed | Treated like Persona E (unlimited attempts) |
| Coach takes endline | Requires all modules passed first | Existing endline gate unchanged |
| Admin + Coach (both roles) | Sees all 6 modules | isCoach check evaluated first |

---

## Implementation Notes

1. **No Migration Required for Coaches**
   - Coaches are enrolled manually via SQL into `user_roles` table
   - No signup flow changes

2. **Performance**
   - `useCoachRole()` caches result in component state
   - Minimal DB queries (one per component mount)

3. **Analytics**
   - Coaches' activity fully tracked in `training_progress` and `analytics_events`
   - Persona in profile shows their baseline-assigned persona (not affected)

4. **Zero Impact on Production**
   - Non-coach paths unchanged
   - Existing personas A-E unaffected
   - Rollback is 100% data-safe

---

## Timeline

| Date | Event | Action |
|------|-------|--------|
| 2026-05-15 | Vacation engagement starts | Feature activated |
| 2026-05-20 | Mid-vacation checkpoint | Monitor analytics |
| 2026-06-10 | Preparation for rollback | Notify admins |
| 2026-06-15 | Vacation ends | Remove coach roles from user_roles |
| 2026-06-16 | Verification | Confirm coaches see persona-based modules |

---

## Questions?

- **How to enroll coaches?** See "Role Assignment (for admins)" section
- **How to check who's a coach?** `SELECT user_id FROM user_roles WHERE role = 'coach'`
- **Does this affect tests?** Tests added to `src/domain/coach-module-access.test.ts`
- **Will data be lost?** No. All training progress is preserved post-rollback.
