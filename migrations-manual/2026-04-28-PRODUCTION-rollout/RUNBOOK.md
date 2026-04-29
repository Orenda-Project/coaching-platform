# Module 1 Quiz Rebuild — Production Runbook
**Date:** 2026-04-28  
**Target:** Supabase project `agziuwqpkfmxtospfxns` (production)  
**Impact:** Replace all 37 existing Module 1 quiz questions with 42 MCQs + 7 scenario-based questions. Create `module_quiz_attempts` table for tracking quiz performance.

---

## ⚠️ CRITICAL PREREQUISITES

- [ ] **User traffic window:** Coordinate migration during LOW-traffic window (off-peak hours). Quiz attempts in flight will be unaffected; new attempts will use the new question set.
- [ ] **Backup verification:** Ensure production database backups are current (Supabase auto-backs up; verify in dashboard)
- [ ] **Slack notification:** Alert stakeholders (coaches, admins) that quiz questions are being updated
- [ ] **Staging validation:** Migration has been tested on staging (`agziuwqpkfmxtospfxns` staging instance); zero defects

---

## PHASE 1: PRE-FLIGHT SNAPSHOT (5 minutes)

**Purpose:** Document current production state before ANY changes. Provides a "before" baseline for comparison.

1. **Open Supabase Studio**
   - Project: `agziuwqpkfmxtospfxns` (production)
   - Navigate to: SQL Editor

2. **Run file:** `00-preflight.sql`
   - Copy the entire file content
   - Paste into Supabase Studio SQL Editor
   - Click **Run**
   - **Wait for completion** (should complete in <10 seconds)

3. **Capture output** (click the Results pane)
   - Screenshot or note all output:
     - Current database name and user
     - Does `module_quiz_attempts` table exist? (should be NO)
     - Current `question_type` CHECK constraint definition (should be `IN ('mcq', 'open')`)
     - Module 1 question counts by type (should show existing questions: ~30 MCQ, ~7 open)
     - Training duplicates in Module 1 (if any)
     - User count with Module 1 progress
     - Any backup tables from prior run? (should be NONE)

4. **Save output to file**
   - Create `PRODUCTION_PREFLIGHT_OUTPUT_2026-04-28.txt`
   - Keep this as your "before" snapshot for audit trail

---

## PHASE 2: FORWARD MIGRATION (10–15 minutes)

**Purpose:** Apply the question rebuild and create the `module_quiz_attempts` table.

### ⚠️ WARNING: This step is DESTRUCTIVE

The forward migration will:
- **Delete all 37 existing Module 1 quiz questions** (backups preserved)
- **Delete all related options** (backups preserved)
- **Insert 42 new MCQs + 7 scenario questions**
- **Create `module_quiz_attempts` table** (new, safe)
- **Widen `question_type` CHECK constraint** (non-breaking, backward compatible)

### Steps

1. **Open Supabase Studio** (same project, SQL Editor)

2. **Run file:** `01-forward.sql`
   - Copy entire file content (note: ~600 lines)
   - Paste into Supabase Studio SQL Editor
   - **Carefully review the transaction BEGIN/COMMIT block** — ensure visible
   - Click **Run**
   - **WAIT for completion** (should take 30–60 seconds)

3. **Monitor for errors**
   - Expected: Query runs and completes with 0 errors
   - If error occurs:
     - **STOP immediately** — do NOT proceed to Phase 3
     - Screenshot the error
     - See "Troubleshooting" section below
     - Consider Phase 3 (Rollback) if critical

4. **Verify success** (in Supabase Studio, after forward completes)
   
   Run these verification queries one-by-one in the SQL Editor:

   **Query 1: Verify backup tables exist**
   ```sql
   SELECT table_name
   FROM information_schema.tables
   WHERE table_schema = 'public' AND table_name LIKE 'backup_module1_%_20260428'
   ORDER BY table_name;
   ```
   Expected: 2 rows — `backup_module1_options_20260428`, `backup_module1_questions_20260428`

   **Query 2: Verify new question counts**
   ```sql
   SELECT q.question_type, COUNT(*) AS cnt
   FROM public.questions q
   JOIN public.assessments a ON a.id = q.assessment_id
   JOIN public.trainings t ON t.id = a.training_id
   WHERE t.module_id = (SELECT id FROM public.modules WHERE order_number = 1 LIMIT 1)
     AND a.type = 'module_quiz'
   GROUP BY q.question_type
   ORDER BY q.question_type;
   ```
   Expected: 
   - `mcq` — 42 rows
   - `scenario` — 7 rows
   - **NO `open` rows** (old open-ended removed)

   **Query 3: Verify module_quiz_attempts table exists**
   ```sql
   SELECT EXISTS(
     SELECT 1 FROM information_schema.tables
     WHERE table_schema = 'public' AND table_name = 'module_quiz_attempts'
   ) AS table_exists;
   ```
   Expected: `true`

   **Query 4: Verify RLS policies on module_quiz_attempts**
   ```sql
   SELECT policyname, permissive, qual
   FROM pg_policies
   WHERE tablename = 'module_quiz_attempts'
   ORDER BY policyname;
   ```
   Expected: 4 policies
   - "Users can view their own quiz attempts" (SELECT, FOR authenticated)
   - "Users can insert their own quiz attempts" (INSERT, FOR authenticated)
   - "Users can update their own quiz attempts" (UPDATE, FOR authenticated)
   - "Admins can view all quiz attempts" (SELECT, FOR authenticated)

   **Query 5: Check for any existing module_quiz_attempts data**
   ```sql
   SELECT COUNT(*) AS row_count FROM public.module_quiz_attempts;
   ```
   Expected: 0 rows (table is new, empty)

5. **Record verification results**
   - Create `PRODUCTION_VERIFICATION_2026-04-28.txt`
   - Copy output from each verification query
   - Keep for audit trail

---

## PHASE 3: ROLLBACK (IF NEEDED)

⚠️ **Only run this if Phase 2 failed or if you need to revert the migration.**

1. **Open Supabase Studio** (same project, SQL Editor)

2. **Run file:** `02-rollback.sql`
   - Copy entire file content
   - Paste into Supabase Studio SQL Editor
   - Click **Run**
   - Wait for completion

3. **Verify rollback success**
   ```sql
   SELECT q.question_type, COUNT(*) AS cnt
   FROM public.questions q
   JOIN public.assessments a ON a.id = q.assessment_id
   JOIN public.trainings t ON t.id = a.training_id
   WHERE t.module_id = (SELECT id FROM public.modules WHERE order_number = 1 LIMIT 1)
     AND a.type = 'module_quiz'
   GROUP BY q.question_type
   ORDER BY q.question_type;
   ```
   Expected: Original question types restored (should match preflight output from Phase 1)

4. **Alert stakeholders** — rollback was applied, quiz is reverted to original questions

---

## PHASE 4: VALIDATION (1–2 days after Phase 2)

After the forward migration has run for 1–2 days without issues, perform these checks:

1. **Quiz functionality on production app**
   - Log in as a coach
   - Navigate to a student's dashboard
   - Start Module 1 quiz
   - Verify: 20 questions load (16 MCQ + 4 scenario)
   - Verify: Scenario questions show a context block and "Scenario" badge
   - Verify: MCQ questions show normally
   - Verify: Option positions are randomized (take quiz twice, options shuffle)
   - Submit a completed quiz
   - Verify: Result screen shows score (should be 80%+ to pass)

2. **Database checks**
   ```sql
   SELECT COUNT(*) AS total_quiz_attempts FROM public.module_quiz_attempts;
   ```
   Expected: >0 (coaches have attempted the quiz with the new questions)

3. **Check for any errors in PostgREST logs**
   - Supabase dashboard → Logs → API
   - Filter for 400/500 errors related to `module_quiz_attempts` or `questions`
   - Expected: None related to new tables/fields

4. **Verify backup tables are still present**
   ```sql
   SELECT table_name FROM information_schema.tables
   WHERE table_schema = 'public' AND table_name LIKE 'backup_module1_%_20260428';
   ```
   Expected: 2 rows (do NOT drop yet)

---

## PHASE 5: CLEANUP (After 3+ days of successful operation)

⚠️ **Only run this after you are confident the migration is stable and rollback will NOT be needed.**

1. **Open Supabase Studio** (same project, SQL Editor)

2. **Run file:** `03-cleanup-backups.sql`
   - Copy entire file content
   - Paste into Supabase Studio SQL Editor
   - Click **Run**
   - Wait for completion

3. **Verify backup tables are dropped**
   ```sql
   SELECT table_name FROM information_schema.tables
   WHERE table_schema = 'public' AND table_name LIKE 'backup_module1_%_20260428';
   ```
   Expected: 0 rows (all backup tables removed)

4. **Final audit**
   - Migration is now finalized
   - Backup tables are permanently removed
   - Original questions are no longer recoverable from backup

---

## TIMELINE SUMMARY

| Phase | File | Duration | Notes |
|-------|------|----------|-------|
| 0 | Coordinate off-peak window | — | Slack alert |
| 1 | 00-preflight.sql | 5 min | Snapshot current state |
| 2 | 01-forward.sql | 10–15 min | **DESTRUCTIVE** — backup tables created |
| 2 | Verification queries | 5 min | Confirm counts, table existence, RLS |
| 3 | 02-rollback.sql (optional) | 10 min | Only if Phase 2 fails |
| 4 | Validation checks | 1–2 days | Monitor production app, check db |
| 5 | 03-cleanup-backups.sql | 5 min | After 3+ days of confidence |

**Total execution time:** ~30–40 minutes for Phases 1–2, then 1–2 days monitoring, then 5 min cleanup.

---

## TROUBLESHOOTING

### Error: "relation 'questions' already exists"
**Cause:** Migration was run twice without rollback.  
**Fix:** This is safe — the migration uses `IF NOT EXISTS` guards and `ON CONFLICT` clauses, so re-running is idempotent. Just run 01-forward.sql again.

### Error: "duplicate key value violates unique constraint"
**Cause:** Assessment IDs or question IDs conflict with existing data.  
**Fix:** Likely a schema inconsistency. Check 01-forward.sql verification block output for exact counts. If counts don't match expected (49 questions, 196 options), rollback and investigate question bank data.

### Error: "PGRST205 — table not found"
**Cause:** PostgREST schema cache out of sync with database.  
**Fix:** This is resolved by the `NOTIFY pgrst, 'reload schema'` statement in 01-forward.sql. If error persists:
1. Wait 10 seconds for cache refresh
2. Refresh the app (browser F5)
3. If still failing, restart PostgREST in Supabase dashboard (Settings → API → Force cache invalidation)

### Error: "question_type_check constraint violation"
**Cause:** question_type CHECK constraint not properly widened.  
**Fix:** Run this query to verify current constraint:
```sql
SELECT pg_get_constraintdef(oid) AS constraint_def
FROM pg_constraint
WHERE conname = 'questions_question_type_check';
```
Should show: `CHECK (question_type = ANY (ARRAY['mcq'::text, 'open'::text, 'scenario'::text]))`  
If not, the 01-forward.sql migration didn't apply correctly. Verify no errors in Phase 2 output.

### Quiz shows old questions after migration
**Cause:** Client-side cache not refreshed, or app served old frontend.  
**Fix:** 
1. Hard refresh app: Ctrl+Shift+R (or Cmd+Shift+R on Mac)
2. Clear browser local storage: DevTools → Application → Clear all
3. If using service worker, invalidate cache in browser settings
4. As last resort, use browser's "Disable cache" setting while debugging

### Rollback didn't restore data
**Cause:** Backup tables were dropped before running 02-rollback.sql.  
**Fix:** This cannot be undone. You will need to restore from Supabase database backups (available in dashboard). Contact Supabase support if rollback is critical.

---

## ROLLBACK DECISION TREE

```
Does 01-forward.sql complete without error?
  ├─ YES
  │   └─ Do verification queries all pass?
  │       ├─ YES
  │       │   └─ ✅ PROCEED to Phase 4 (Validation). Rollback not needed unless future issues arise.
  │       └─ NO
  │           └─ ❌ RUN ROLLBACK (Phase 3). Review 01-forward.sql verification block output for count mismatches.
  └─ NO (error during execution)
      └─ ❌ RUN ROLLBACK (Phase 3). Migration is incomplete; restore from backups before retry.
```

---

## FINAL CHECKLIST

- [ ] Supabase project confirmed: `agziuwqpkfmxtospfxns`
- [ ] Off-peak window coordinated with team
- [ ] Production backups current
- [ ] Staging migration validated (zero defects)
- [ ] Phase 1 preflight run, output captured
- [ ] Phase 2 forward run, verification queries all passed
- [ ] All verification results documented
- [ ] 1–2 days monitoring period complete (Phase 4)
- [ ] No errors in production logs
- [ ] Quiz functionality tested on production app
- [ ] Backup tables confirmed present
- [ ] Phase 5 cleanup run (if confident)
- [ ] Backup tables confirmed dropped (if cleanup run)
- [ ] Team alerted of completion

---

## SUPPORT & QUESTIONS

If you encounter issues outside this runbook:
1. Check git history for this migration: `git log --oneline migrations-manual/2026-04-28-*`
2. Review staging migration results in logs/
3. Contact engineering team with: error message, phase number, preflight/verification output
