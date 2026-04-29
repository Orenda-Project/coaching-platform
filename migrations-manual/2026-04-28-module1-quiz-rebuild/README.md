# Module 1 Quiz Rebuild — Manual Migration

**Date:** 2026-04-28
**Source:** Question Bank Module 1 (Google Doc)
**Target environments:** local → staging → production

## What this migration does

Replaces all existing Module 1 quiz questions with the official Question Bank:

- **42 MCQs** — 6 per unit × 7 units (Unit 1.0 → Unit 1.6), `order_number` 1..6 within each unit
- **7 scenario questions** — `order_number` 17..23, distributed one per unit

Frontend (`ModuleQuiz.tsx`) is already wired to randomly pick **16 MCQs distributed across units + 4 scenarios**.

## Files

| File | Purpose |
|------|---------|
| `01-forward.sql` | Backup → delete old → insert new → verify. Run this. |
| `02-rollback.sql` | Restore from backups. Run only if rollback is needed. |
| `03-cleanup-backups.sql` | Drop backup tables after a few days of confidence. |

## Safety design

- Forward migration runs in a single `BEGIN…COMMIT` transaction.
- Before any deletion, snapshots are written to:
  - `public.backup_module1_questions_20260428`
  - `public.backup_module1_options_20260428`
- Verification block at the end raises an exception (rolling back the txn) if:
  - Final MCQ count ≠ 42
  - Final scenario count ≠ 7
  - Total options ≠ 196 (49 × 4)
  - Correct options ≠ 49 (one per question)
- Rollback restores original `id`s so nothing else in the system breaks.

## How to run

### 1. Pre-flight check (run first, on any environment)

```sql
-- How many Module 1 quiz questions exist right now?
SELECT q.question_type, COUNT(*) AS cnt
FROM public.questions q
JOIN public.assessments a ON a.id = q.assessment_id
JOIN public.trainings t ON t.id = a.training_id
WHERE t.module_id = (SELECT id FROM public.modules WHERE order_number = 1 LIMIT 1)
  AND a.type = 'module_quiz'
GROUP BY q.question_type
ORDER BY q.question_type;

-- Confirm Module 1 has 7 trainings (one per unit_order 1..7)
SELECT order_number, COUNT(*) AS training_count
FROM public.trainings
WHERE module_id = (SELECT id FROM public.modules WHERE order_number = 1 LIMIT 1)
GROUP BY order_number
ORDER BY order_number;
```

Note these numbers. If `training_count > 1` for any `order_number`, the migration will pick the training whose title best matches the doc's unit name (Coaching Catalyst, Partnership Posture, Shared Mirror, Growth Engine, Trust Bridge, Human Filter, Coding the Classroom). Other duplicate trainings will be ignored.

### 2. Apply forward migration

In Supabase Studio → SQL Editor (staging project `kddvxrlffafyjvvststh`):

1. Paste contents of `01-forward.sql`.
2. Run.
3. Watch the "Notices" panel. You should see:
   - `Module 1 quiz: 42 MCQs, 7 scenarios, 196 options (49 correct)`
   - `All checks passed. Committing transaction.`
4. The final two `SELECT` queries print backup row counts and the new per-unit breakdown.

If anything fails, the entire transaction rolls back automatically — no partial state. You can then read the error message, fix, and re-run.

### 3. Smoke-test the app

- Sign in as a coach who has passed all Module 1 units.
- Open `/module-quiz/<module1Id>`.
- Confirm 20 questions load (16 MCQ + 4 scenario), each with 4 options.
- Submit with all-correct answers → should pass at ≥80%.

### 4. If something is wrong → rollback

In Supabase Studio:

1. Paste contents of `02-rollback.sql`.
2. Run.
3. Confirm "Rollback verified. Committing." in the Notices.

### 5. Cleanup (a few days later, after confidence)

Run `03-cleanup-backups.sql` to drop the backup tables. **Do not run this until you're sure no rollback is needed.**

## Mapping reference (doc unit → DB training)

The forward script maps doc Units to trainings by `order_number`. If multiple trainings share an `order_number`, it prefers ones whose title contains the keyword:

| Doc Unit | unit_order | Title keyword (preferred) | Fallback keyword |
|----------|-----------|---------------------------|------------------|
| 1.0 The Coaching Catalyst | 1 | Coaching Catalyst | Partnership Posture / Impact Cycle Overview |
| 1.1 The Partnership Posture | 2 | Partnership Posture | Voice / Observation |
| 1.2 The Shared Mirror | 3 | Shared Mirror | Calibration |
| 1.3 The Growth Engine | 4 | Growth Engine | Feedback |
| 1.4 The Trust Bridge | 5 | Trust Bridge | Action Steps |
| 1.5 The Human Filter | 6 | Human Filter | Documentation |
| 1.6 Coding the Classroom | 7 | Coding the Classroom | Habits |

The keyword lookup is case-insensitive.

## Answer-key reference

- All 42 MCQs: correct answer is **B**.
- Scenarios 1–4 (Q17–Q20): **B**
- Scenario 5 (Q21, Trust Bridge): **C**
- Scenarios 6–7 (Q22–Q23): **B**
