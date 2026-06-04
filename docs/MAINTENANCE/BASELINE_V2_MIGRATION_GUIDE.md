# Baseline V2 Questions Migration

## Overview
This migration replaces the existing baseline assessment questions with 30 updated v2 questions covering Modules 2-6:
- Module 2: The Partnership Foundation (Trust & Status) - 6 questions
- Module 3: The Mirror Specialist (Shared Reality) - 6 questions
- Module 4: Digital & Data Intelligence (Collaborative Analytics) - 6 questions
- Module 5: The Instructional Catalyst (Co-Design) - 6 questions
- Module 6: The Excellence Loop (Reciprocity & Praxis) - 6 questions

## How to Apply

### Option 1: Supabase Dashboard (Recommended)
1. Go to [Supabase Console](https://app.supabase.com/)
2. Select project `kddvxrlffafyjvvststh`
3. Go to SQL Editor
4. Open file: `supabase/migrations/20260420_baseline_v2_questions.sql`
5. Copy the entire SQL content
6. Paste into the SQL Editor
7. Click "Run" button
8. Verify execution succeeded

### Option 2: Supabase CLI
```bash
cd /Users/mac/Desktop/data/Taleemabad/coaching-platform
supabase db push --linked
```

**Note:** CLI may have permission issues. Use Option 1 if this fails.

### Option 3: Direct Database Connection
If you have a service role key in `SUPABASE_SERVICE_ROLE_KEY`, run:
```bash
node scripts/apply-baseline-v2.mjs
```

## What Changed
- Deleted old baseline assessment and all associated questions/options
- Created new assessment: "Coach Baseline Assessment V2"
- Inserted 30 new baseline questions with 4 options each
- Each question has exactly 1 correct answer marked

## Testing

### 1. Verify Questions Inserted
```sql
SELECT COUNT(*) FROM public.questions 
WHERE assessment_id IN (SELECT id FROM public.assessments WHERE type = 'baseline');
```
Expected: 30

### 2. Verify Options Inserted
```sql
SELECT COUNT(*) FROM public.options 
WHERE question_id IN (SELECT id FROM public.questions 
  WHERE assessment_id IN (SELECT id FROM public.assessments WHERE type = 'baseline'));
```
Expected: 120 (30 questions × 4 options each)

### 3. Test Baseline Flow
1. Sign up with new coach account
2. Start baseline assessment
3. Verify all 30 baseline v2 questions appear
4. Submit baseline and verify persona assignment works

### 4. Verify Correct Answers
Check a sample question:
```sql
SELECT q.question_text, o.option_text, o.is_correct
FROM public.questions q
LEFT JOIN public.options o ON q.id = o.question_id
WHERE q.order_number = 1
ORDER BY o.is_correct DESC;
```

## Git Info
- Branch: `feature/baseline-v2-questions`
- Commit: The SQL migration + helper scripts
- Migration file: `supabase/migrations/20260420_baseline_v2_questions.sql`

## Next Steps
1. Apply migration to staging database
2. Test baseline flow end-to-end
3. Merge PR to main
4. Apply to production (after staging validation)
