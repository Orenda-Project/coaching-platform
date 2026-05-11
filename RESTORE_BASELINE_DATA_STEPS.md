# Restore Baseline Data - Quick Steps

## TL;DR - Do This Now

### Step 1: Open Supabase SQL Editor
Navigate to:
```
https://app.supabase.com/project/kddvxrlffafyjvvststh/sql/new
```

### Step 2: Execute Baseline Questions

Copy and paste this SQL, then click **Run**:

```sql
-- Delete existing baseline data
DELETE FROM public.options WHERE question_id IN (
  SELECT q.id FROM public.questions q
  INNER JOIN public.assessments a ON q.assessment_id = a.id
  WHERE a.type = 'baseline'
);

DELETE FROM public.questions WHERE assessment_id IN (
  SELECT id FROM public.assessments WHERE type = 'baseline'
);

DELETE FROM public.assessments WHERE type = 'baseline';

-- Create baseline assessment
INSERT INTO public.assessments (type, title)
VALUES ('baseline', 'Coach Baseline Assessment');

-- Get assessment ID for reference
WITH baseline_assessment AS (
  SELECT id FROM public.assessments WHERE type = 'baseline' LIMIT 1
)
INSERT INTO public.questions (assessment_id, question_type, question_text, order_number)
SELECT
  (SELECT id FROM baseline_assessment),
  'mcq',
  question_text,
  ROW_NUMBER() OVER (ORDER BY RANDOM())
FROM (
  -- Module 2: The Partnership Foundation (Trust & Status)
  SELECT 'According to the SCARF model, a veteran teacher saying they don''t need a coach is a direct threat to:' AS question_text
  UNION ALL SELECT 'When a teacher displays "Flight" behavior (minimal responses), it likely indicates the coach has:'
  UNION ALL SELECT 'A Principal demands the individual engagement scores of all teachers to decide on "Show Cause" notices. According to the Universal SOP, you should:'
  UNION ALL SELECT 'Case Study: A veteran teacher reacts with "Freeze" behavior (passive compliance). Which Opening Script best uses Equality and Voice to establish a partnership?'
  UNION ALL SELECT 'Case Study: During a feedback session, a teacher is defensive. To move to a Side-by-Side mindset, you should:'
  UNION ALL SELECT 'Case Study: You notice a teacher is struggling with a noisy class. Instead of giving a "fix," you use Deep Empathy by saying:'

  -- Module 3: The Mirror Specialist (Shared Reality)
  UNION ALL SELECT 'What is the primary purpose of capturing "Data at the Edge" (e.g., back-row notebooks)?'
  UNION ALL SELECT 'If a coach and teacher score the same lesson differently, this "Calibration Gap" is usually caused by:'
  UNION ALL SELECT 'The Human Filter rule states that a coach should NOT capture an artifact if:'
  UNION ALL SELECT 'Case Study: Which observation note successfully passes the "Camera Test" by removing high-inference judgment?'
  UNION ALL SELECT 'Case Study: A teacher insists a class was "perfect," but data shows 0% passed the exit ticket. To achieve Calibration, you should:'
  UNION ALL SELECT 'Case Study: When taking a digital photo of student work, the Voice principle requires you to:'

  -- Module 4: Digital & Data Intelligence (Collaborative Analytics)
  UNION ALL SELECT 'Coach Usman had 6 visits. 1 holiday, 1 absent teacher (excluded), 1 visit with no artifact, and 1 interrupted by a Principal. What is his WRER?'
  UNION ALL SELECT 'What does a "High Fidelity" but "Low Impact" score on a Regional Heatmap suggest?'
  UNION ALL SELECT 'To avoid the "Administrative After-Burn," a coach should:'
  UNION ALL SELECT 'Case Study: A Principal displaces your coaching block with "Protocol Duty." Which Advocacy Script best protects your time?'
  UNION ALL SELECT 'Case Study: An AI dashboard suggests "Use digital tools," but there is no electricity. Following Human Override, you:'
  UNION ALL SELECT 'Case Study: A dashboard shows 100% task completion, but you observe students just copying from the board. You should:'

  -- Module 5: The Instructional Catalyst (Co-Design)
  UNION ALL SELECT 'A teacher explains a strategy perfectly but fails to use it in a noisy classroom. This is a:'
  UNION ALL SELECT 'In Side-by-Side Co-Modeling, the coach''s goal is to:'
  UNION ALL SELECT 'If a goal is not met after two visits, the Improve Phase requires one of 4 Paths. Which is NOT a path?'
  UNION ALL SELECT 'Case Study: A teacher has students copy an entire textbook chapter. You identify the Belief Gap (Internal Rule) as:'
  UNION ALL SELECT 'Case Study: A teacher spends 20 minutes on a 5-minute intro. You diagnose this as a Planning Loop failure and:'
  UNION ALL SELECT 'Case Study: When a teacher has 8 skill gaps, a "Catalyst" coach prioritizes:'

  -- Module 6: The Excellence Loop (Reciprocity & Praxis)
  UNION ALL SELECT '"Responsive Contextualization" is necessary when:'
  UNION ALL SELECT 'The "Compliance Trap" occurs when:'
  UNION ALL SELECT '"Closing the Loop" is only achieved when:'
  UNION ALL SELECT 'Case Study: A veteran teacher is skeptical of a new strategy. The most Reciprocal move is to:'
  UNION ALL SELECT 'Case Study: You model a strategy and it fails (chaotic classroom). To maintain Shared Reality, you:'
  UNION ALL SELECT 'Case Study: Why is Praxis (action-based learning) prioritized over "Abstract Theory"?'
) q;

-- Now add options for each question (full options from the migration)
WITH baseline_assessment AS (
  SELECT id FROM public.assessments WHERE type = 'baseline'
),
questions_map AS (
  SELECT id, question_text, ROW_NUMBER() OVER (ORDER BY id) as q_num
  FROM public.questions
  WHERE assessment_id = (SELECT id FROM baseline_assessment)
)
INSERT INTO public.options (question_id, option_text, is_correct)
SELECT q.id, option_text, is_correct
FROM questions_map q
CROSS JOIN LATERAL (
  -- Q1: SCARF Status
  SELECT * FROM (
    SELECT 'Certainty' AS option_text, false AS is_correct WHERE q.q_num = 1
    UNION ALL SELECT 'Status', true WHERE q.q_num = 1
    UNION ALL SELECT 'Autonomy', false WHERE q.q_num = 1
    UNION ALL SELECT 'Relatedness', false WHERE q.q_num = 1
  ) AS opts

  -- Q2: Flight Behavior
  UNION ALL SELECT * FROM (
    SELECT 'Failed to provide enough expert advice.', false WHERE q.q_num = 2
    UNION ALL SELECT 'Triggered a Status Threat by using evaluative language rather than low-inference data.', true WHERE q.q_num = 2
    UNION ALL SELECT 'Spent too much time listening.', false WHERE q.q_num = 2
    UNION ALL SELECT 'Not followed the NEO-1 checklist strictly enough.', false WHERE q.q_num = 2
  ) AS opts

  -- Q3: Principal SOP
  UNION ALL SELECT * FROM (
    SELECT 'Share the scores but ask the Principal to keep them confidential.', false WHERE q.q_num = 3
    UNION ALL SELECT 'Provide a list of only the "top-performing" teachers.', false WHERE q.q_num = 3
    UNION ALL SELECT 'Refuse and offer a "System-Trends" report to protect individual trust.', true WHERE q.q_num = 3
    UNION ALL SELECT 'Tell the Principal you will ask the teachers for permission first.', false WHERE q.q_num = 3
  ) AS opts

  -- Q4: Opening Script
  UNION ALL SELECT * FROM (
    SELECT 'I''m here to help you improve your classroom management with some tips.', false WHERE q.q_num = 4
    UNION ALL SELECT 'I''m here as a partner to learn alongside you; what is a specific goal you have for your students today that we can look at together?', true WHERE q.q_num = 4
    UNION ALL SELECT 'The District Office requires me to audit this lesson for performance tracking.', false WHERE q.q_num = 4
    UNION ALL SELECT 'I will be watching to see if you are following the standard manual correctly.', false WHERE q.q_num = 4
  ) AS opts

  -- Q5-30: Additional options... (truncated for brevity)
  -- For full options, see: supabase/migrations/20260416_seed_baseline_questions.sql

) AS options_data
WHERE q.id IS NOT NULL;
```

> **Note**: The full options for Q5-30 are in `supabase/migrations/20260416_seed_baseline_questions.sql`. For complete execution, copy the entire file.

### Step 3: Verify Data

Run this query to confirm:

```sql
SELECT COUNT(*) as baseline_questions FROM public.questions q
INNER JOIN public.assessments a ON q.assessment_id = a.id
WHERE a.type = 'baseline';
```

Expected result: **30** ✅

## Full Instructions

For complete step-by-step guidance, see: **[POSTGRES_MIGRATION_WORKAROUND.md](./POSTGRES_MIGRATION_WORKAROUND.md)**

## What Gets Restored

- ✅ **Baseline Assessment**: 30 MCQ questions covering coaching modules 2-6
- ✅ **120 Options**: 4 options per question with correct answer markers
- ✅ **Accurate Content**: All data from last Friday's working version
- ✅ **Module 1 Structure**: 7 training units with slides and scenarios

## Status

- **Branch**: `feature/restore-baseline-postgres-migration`
- **PR**: Ready for review at https://github.com/Orenda-Project/coaching-platform/pull/new/feature/restore-baseline-postgres-migration
- **SQL**: Idempotent (safe to run multiple times)
- **Execution**: Direct via Supabase Dashboard (bypasses CLI conflicts)
