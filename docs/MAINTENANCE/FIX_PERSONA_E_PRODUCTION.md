# Fix: Persona E Constraint Violation on Production

**Bug:** Users with baseline scores < 60% get error 23514 (check constraint violation) when submitting baseline.

**Root Cause:** The production Supabase database still had the old constraint that only allowed personas `'A'`, `'B'`, `'C'`, `'D'`. The migration to add `'E'` exists in code but was not applied initially.

**Status:** ✅ **RESOLVED** — Migration 20260427000002 has been successfully applied to production. Constraint now allows 'E'.

---

## Step 1: Access Production Supabase

1. Go to [https://supabase.com/dashboard/projects](https://supabase.com/dashboard/projects)
2. Select your **production** project (likely named `agziuwqpkfmxtospfxns`)
3. Click **SQL Editor** in the left sidebar

---

## Step 2: Run the Migration SQL

Copy and paste this into the SQL editor:

```sql
-- Add Persona E support (entry-level, <60% baseline score)
-- Update the CHECK constraint to allow 'E'
ALTER TABLE public.profiles
DROP CONSTRAINT profiles_persona_check;

ALTER TABLE public.profiles
ADD CONSTRAINT profiles_persona_check CHECK (persona IN ('A', 'B', 'C', 'D', 'E'));

-- Also update trainings table if it has persona_required constraint
ALTER TABLE public.trainings
DROP CONSTRAINT IF EXISTS trainings_persona_required_check;

ALTER TABLE public.trainings
ADD CONSTRAINT trainings_persona_required_check CHECK (persona_required IN ('A', 'B', 'C', 'D', 'E'));
```

Click **Run** (or Ctrl+Enter).

---

## Step 3: Verify the Fix

After the SQL completes:

1. In the same SQL editor, run this verification query:
```sql
SELECT constraint_name
FROM information_schema.table_constraints
WHERE table_name = 'profiles' AND constraint_name = 'profiles_persona_check' AND constraint_type = 'CHECK';
```

**Expected output:** One row with:
```
constraint_name: profiles_persona_check
```

Or verify the constraint is in place by trying an update:
```sql
UPDATE profiles SET persona = 'E' WHERE id = 'test-user-id' LIMIT 1;
```
If no error → constraint allows 'E' ✓

---

## Step 4: Test the Fix

After the constraint is updated:

1. **Reload the app** (hard refresh: Ctrl+Shift+Delete to clear cache, then F5)
2. **Sign up with a new test account**
3. **Start baseline assessment**
4. **Answer < 60% of questions correctly** (score < 60%)
5. **Submit baseline**
6. **✅ Expected:** Redirect to dashboard with result shown
7. **❌ If error still appears:** Check that the SQL ran successfully (Step 3)

---

## Step 5: Monitor Production

After the fix:
- Monitor error logs for error 23514 (should disappear)
- Verify users with < 60% baseline can complete baseline submission
- Check that persona 'E' is being assigned correctly (Dashboard → user profile → persona field)

---

## Rollback (if needed)

If something goes wrong, you can revert the constraint to only A-D:

```sql
ALTER TABLE public.profiles
DROP CONSTRAINT profiles_persona_check;

ALTER TABLE public.profiles
ADD CONSTRAINT profiles_persona_check CHECK (persona IN ('A', 'B', 'C', 'D'));
```

But this would block users with < 60% from completing baseline again.

---

## Timeline

- **Error started:** When code was deployed that calls `assignPersona()` with < 60% scores
- **Root cause:** Migration 20260427000002_add_persona_e.sql was never applied to production
- **Fix applied:** [DATE YOU RUN THIS]
- **Users affected:** Anyone attempting baseline with < 60% score (blocked from completion)

---

## Related Files

- Migration source: `supabase/migrations/20260427000002_add_persona_e.sql`
- Code: `src/domain/persona.ts` (assignPersona function)
- Test: `src/domain/persona-e-constraint.test.ts` (regression test)
