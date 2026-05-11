# PostgreSQL Migration Workaround

## Problem

After migrating from Supabase-hosted to PostgreSQL on Railway, the Supabase CLI migration system enters an inconsistent state when migrations have both:
- Timestamped versions (e.g., `20260416000001_migration.sql`)
- Unversioned versions (e.g., `20260416_migration.sql`)

The CLI cannot reconcile which version to apply and blocks all subsequent pushes.

### Error Message
```
Remote migration versions not found in local migrations directory.
Make sure your local git repo is up-to-date. If the error persists, try repairing the migration history table:
supabase migration repair --status reverted 20260416
```

## Root Cause

The PostgreSQL migration created unversioned migration IDs in the remote database:
- `20260415`, `20260416`, `20260425000001` (duplicated with timestamp), `20260505000001` (duplicated with timestamp)

When these mix with timestamped versions in local files, the CLI's version matching fails.

## Solution: Direct SQL Execution

Instead of using `supabase db push`, manually execute seed migrations directly on the database.

### Step 1: Access Supabase SQL Editor

```
https://app.supabase.com/project/[PROJECT_ID]/sql/new
```

For this project:
```
https://app.supabase.com/project/kddvxrlffafyjvvststh/sql/new
```

### Step 2: Copy and Execute Baseline Questions

Open: `supabase/migrations/20260416_seed_baseline_questions.sql`

Copy the entire SQL and paste into the Supabase SQL Editor. Click **Run**.

Expected output:
```
Query returned 0 rows
```

This creates:
- 1 baseline assessment
- 30 questions
- 120 options (4 per question)

### Step 3: Copy and Execute Module 1 Content

Open: `supabase/migrations/20260417_seed_module1_content.sql`

Copy the entire SQL and paste into the Supabase SQL Editor. Click **Run**.

Expected output:
```
Query returned 0 rows
```

This creates:
- Module 1 structure
- 7 training units

### Step 4: Copy and Execute Module 1 Slides & Scenarios

Open: `supabase/migrations/20260421_seed_module1_slides_and_scenarios.sql`

Copy the entire SQL and paste into the Supabase SQL Editor. Click **Run**.

Expected output:
```
Query returned 0 rows
```

This populates:
- Slide content URLs for each unit
- Scenario-based coaching situations (7 total)

### Step 5: (Optional) Verify Data Seeded

Run this query in the SQL Editor:

```sql
SELECT COUNT(*) as baseline_questions FROM public.questions q
INNER JOIN public.assessments a ON q.assessment_id = a.id
WHERE a.type = 'baseline';
```

Expected result: **30**

```sql
SELECT COUNT(*) as module_1_trainings FROM public.trainings t
INNER JOIN public.modules m ON t.module_id = m.id
WHERE m.order_number = 1;
```

Expected result: **7**

## Why This Workaround?

1. **Bypasses CLI limitations** - Direct SQL execution doesn't care about version history
2. **Guarantees execution** - SQL runs immediately on the remote database
3. **Safe** - Idempotent migrations (use `WHERE NOT EXISTS` checks)
4. **Future-proof** - Works regardless of CLI version or database backend

## Prevention for Future Migrations

When migrating away from Supabase-hosted (or between backends):

### ✅ DO THIS:
- Always use **timestamped migration filenames**: `20260512000001_description.sql`
- Make all migrations **idempotent** with `IF NOT EXISTS` / `ON CONFLICT DO NOTHING`
- Export remote migration history before switching backends:
  ```bash
  supabase migration list > migration_history.txt
  ```

### ❌ DON'T DO THIS:
- Use unversioned migration IDs (e.g., `20260416_migration.sql`)
- Create migrations that assume a clean slate
- Skip backing up the migration history before major infrastructure changes

## Checklist for Future PostgreSQL Migrations

- [ ] Document the migration plan in this file
- [ ] Ensure all seed migrations have `DROP IF EXISTS` / `ON CONFLICT DO NOTHING`
- [ ] Use CTEs with `LIMIT 1` to prevent "more than one row returned" errors
- [ ] Export migration history from current database
- [ ] Test migrations locally with `supabase db reset` first
- [ ] If CLI conflicts occur, use direct SQL execution (this workaround)
- [ ] Update migration history in remote if needed:
  ```bash
  supabase migration repair --status applied [MIGRATION_ID]
  ```

## Related Migrations

This workaround was applied to restore baseline and module data after the 2026-05-11 PostgreSQL migration:

- Feature branch: `feature/restore-baseline-postgres-migration`
- Migrations:
  - `20260415000002_admin_read_all_profiles.sql` (fixed RLS policies)
  - `20260416_seed_baseline_questions.sql` (30 baseline questions)
  - `20260417_seed_module1_content.sql` (Module 1 structure)
  - `20260421_seed_module1_slides_and_scenarios.sql` (Unit slides & scenarios)
  - `20260512_baseline_questions_final.sql` (final restoration)

## References

- Supabase CLI docs: https://supabase.com/docs/guides/cli
- PostgreSQL migration issues: See commit history for 2026-05-11
