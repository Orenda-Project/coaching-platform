-- Create baseline assessment if it doesn't exist
INSERT INTO public.assessments (type, title)
SELECT 'baseline', 'Coach Baseline Assessment'
WHERE NOT EXISTS (SELECT 1 FROM public.assessments WHERE type = 'baseline');

-- Get the baseline assessment ID for the questions
WITH baseline_assessment AS (
  SELECT id FROM public.assessments WHERE type = 'baseline' LIMIT 1
)
INSERT INTO public.questions (assessment_id, question_type, question_text, order_number)
SELECT
  (SELECT id FROM baseline_assessment),
  'mcq',
  question_text,
  ROW_NUMBER() OVER (ORDER BY question_text)
FROM (
  SELECT 'I regularly use data from classroom observations to inform coaching conversations' AS question_text
  UNION ALL SELECT 'I ask coaches targeted questions that help them reflect on their own practice'
  UNION ALL SELECT 'I build strong relationships with teachers before providing coaching feedback'
  UNION ALL SELECT 'I can explain the connection between teaching practices and student learning outcomes'
  UNION ALL SELECT 'I use a systematic approach to track and measure coaching impact'
  UNION ALL SELECT 'I adapt my coaching style based on individual teacher needs and context'
  UNION ALL SELECT 'I provide specific, actionable feedback grounded in classroom evidence'
  UNION ALL SELECT 'I schedule regular follow-up coaching sessions with teachers'
  UNION ALL SELECT 'I involve teachers in co-designing improvement plans'
  UNION ALL SELECT 'I understand and can explain the coaching framework we use at our school'
) questions
WHERE NOT EXISTS (SELECT 1 FROM public.questions WHERE assessment_id = (SELECT id FROM baseline_assessment));

-- Add options for each question (4 options per question)
WITH baseline_assessment AS (
  SELECT id FROM public.assessments WHERE type = 'baseline'
),
questions_with_id AS (
  SELECT id, order_number FROM public.questions
  WHERE assessment_id = (SELECT id FROM baseline_assessment)
)
INSERT INTO public.options (question_id, option_text, is_correct)
SELECT q.id, option_text, is_correct
FROM questions_with_id q
CROSS JOIN (
  SELECT 'Strongly Disagree' AS option_text, false AS is_correct
  UNION ALL SELECT 'Disagree', false
  UNION ALL SELECT 'Agree', true
  UNION ALL SELECT 'Strongly Agree', true
) options
WHERE NOT EXISTS (
  SELECT 1 FROM public.options
  WHERE question_id = q.id
);

-- Make jalal.khan@taleemabad.com an admin
INSERT INTO public.user_roles (user_id, role)
SELECT id, 'admin'
FROM auth.users
WHERE email = 'jalal.khan@taleemabad.com'
AND NOT EXISTS (
  SELECT 1 FROM public.user_roles
  WHERE user_id = auth.users.id AND role = 'admin'
);
