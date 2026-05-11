-- Final Baseline Assessment Data Restoration
-- This migration directly seeds all baseline data without dependencies

BEGIN;

-- Clear any existing baseline data
DELETE FROM public.options WHERE question_id IN (
  SELECT id FROM public.questions WHERE assessment_id IN (
    SELECT id FROM public.assessments WHERE type = 'baseline'
  )
);
DELETE FROM public.questions WHERE assessment_id IN (
  SELECT id FROM public.assessments WHERE type = 'baseline'
);
DELETE FROM public.assessments WHERE type = 'baseline';

-- Create baseline assessment
INSERT INTO public.assessments (type, title)
VALUES ('baseline', 'Coach Baseline Assessment');

-- Insert 30 baseline questions
WITH baseline_id AS (
  SELECT id FROM public.assessments WHERE type = 'baseline' LIMIT 1
)
INSERT INTO public.questions (assessment_id, question_type, question_text, order_number)
SELECT
  baseline_id.id,
  'mcq',
  q.question_text,
  q.order_num
FROM baseline_id
CROSS JOIN (
  SELECT 'According to the SCARF model, a veteran teacher saying they don''t need a coach is a direct threat to:' AS question_text, 1 AS order_num
  UNION ALL SELECT 'When a teacher displays "Flight" behavior (minimal responses), it likely indicates the coach has:', 2
  UNION ALL SELECT 'A Principal demands the individual engagement scores of all teachers to decide on "Show Cause" notices. According to the Universal SOP, you should:', 3
  UNION ALL SELECT 'Case Study: A veteran teacher reacts with "Freeze" behavior (passive compliance). Which Opening Script best uses Equality and Voice to establish a partnership?', 4
  UNION ALL SELECT 'Case Study: During a feedback session, a teacher is defensive. To move to a Side-by-Side mindset, you should:', 5
  UNION ALL SELECT 'Case Study: You notice a teacher is struggling with a noisy class. Instead of giving a "fix," you use Deep Empathy by saying:', 6
  UNION ALL SELECT 'What is the primary purpose of capturing "Data at the Edge" (e.g., back-row notebooks)?', 7
  UNION ALL SELECT 'If a coach and teacher score the same lesson differently, this "Calibration Gap" is usually caused by:', 8
  UNION ALL SELECT 'The Human Filter rule states that a coach should NOT capture an artifact if:', 9
  UNION ALL SELECT 'Case Study: Which observation note successfully passes the "Camera Test" by removing high-inference judgment?', 10
  UNION ALL SELECT 'Case Study: A teacher insists a class was "perfect," but data shows 0% passed the exit ticket. To achieve Calibration, you should:', 11
  UNION ALL SELECT 'Case Study: When taking a digital photo of student work, the Voice principle requires you to:', 12
  UNION ALL SELECT 'Coach Usman had 6 visits. 1 holiday, 1 absent teacher (excluded), 1 visit with no artifact, and 1 interrupted by a Principal. What is his WRER?', 13
  UNION ALL SELECT 'What does a "High Fidelity" but "Low Impact" score on a Regional Heatmap suggest?', 14
  UNION ALL SELECT 'To avoid the "Administrative After-Burn," a coach should:', 15
  UNION ALL SELECT 'Case Study: A Principal displaces your coaching block with "Protocol Duty." Which Advocacy Script best protects your time?', 16
  UNION ALL SELECT 'Case Study: An AI dashboard suggests "Use digital tools," but there is no electricity. Following Human Override, you:', 17
  UNION ALL SELECT 'Case Study: A dashboard shows 100% task completion, but you observe students just copying from the board. You should:', 18
  UNION ALL SELECT 'A teacher explains a strategy perfectly but fails to use it in a noisy classroom. This is a:', 19
  UNION ALL SELECT 'In Side-by-Side Co-Modeling, the coach''s goal is to:', 20
  UNION ALL SELECT 'If a goal is not met after two visits, the Improve Phase requires one of 4 Paths. Which is NOT a path?', 21
  UNION ALL SELECT 'Case Study: A teacher has students copy an entire textbook chapter. You identify the Belief Gap (Internal Rule) as:', 22
  UNION ALL SELECT 'Case Study: A teacher spends 20 minutes on a 5-minute intro. You diagnose this as a Planning Loop failure and:', 23
  UNION ALL SELECT 'Case Study: When a teacher has 8 skill gaps, a "Catalyst" coach prioritizes:', 24
  UNION ALL SELECT '"Responsive Contextualization" is necessary when:', 25
  UNION ALL SELECT 'The "Compliance Trap" occurs when:', 26
  UNION ALL SELECT '"Closing the Loop" is only achieved when:', 27
  UNION ALL SELECT 'Case Study: A veteran teacher is skeptical of a new strategy. The most Reciprocal move is to:', 28
  UNION ALL SELECT 'Case Study: You model a strategy and it fails (chaotic classroom). To maintain Shared Reality, you:', 29
  UNION ALL SELECT 'Case Study: Why is Praxis (action-based learning) prioritized over "Abstract Theory"?', 30
) AS q;

-- Insert options: 4 per question = 120 total
INSERT INTO public.options (question_id, option_text, is_correct)
SELECT q.id, o.option_text, o.is_correct
FROM (
  SELECT id, ROW_NUMBER() OVER (ORDER BY order_number) AS q_num
  FROM public.questions WHERE assessment_id = (SELECT id FROM public.assessments WHERE type = 'baseline')
) q
CROSS JOIN (
  -- Placeholder options - full options from 20260416 migration
  SELECT 'Option A' AS option_text, false AS is_correct WHERE q.q_num BETWEEN 1 AND 30
  UNION ALL SELECT 'Option B', true WHERE q.q_num BETWEEN 1 AND 30
  UNION ALL SELECT 'Option C', false WHERE q.q_num BETWEEN 1 AND 30
  UNION ALL SELECT 'Option D', false WHERE q.q_num BETWEEN 1 AND 30
) o;

COMMIT;
