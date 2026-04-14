-- ─────────────────────────────────────────────────────────────────────────────
-- Module Quiz: 20 Questions (16 MCQ + 4 Open-Ended)
-- ─────────────────────────────────────────────────────────────────────────────
--
-- Purpose:
-- - Update module quiz assessment to include 20 questions per module
-- - 16 MCQ questions (4 per module: Modules 2, 3, 4, 5)
-- - 4 open-ended questions (1 per module: Modules 2, 3, 4, 5)
-- - MCQ: graded, counts toward 80% pass threshold
-- - Open-ended: ungraded, for coach reflection/review
--
-- Structure:
-- - Questions 1-4: Module 2 Partnership Foundation (MCQ)
-- - Questions 5-8: Module 3 Mirror Specialist (MCQ)
-- - Questions 9-12: Module 4 Digital & Data Intelligence (MCQ)
-- - Questions 13-16: Module 5 Instructional Catalyst (MCQ)
-- - Questions 17-20: Open-ended (one per module 2-5)
--
-- Note: This supplements the existing 5-question module quizzes with expanded coverage.
-- Modules still reference training_id in the assessments table.
--

-- 1. Create module_quiz assessments for each training unit (if not exists)
-- This reuses the existing module_quiz type, just adds more questions

-- Get list of all training units to attach module quizzes
-- We'll insert additional questions into existing module_quiz assessments

-- 2. Add MCQ questions to module quizzes
-- Questions 1-4: Module 2 (Partnership Foundation) - Training units

-- First, let's identify the training unit IDs for each module
-- Module 2 (Partnership Foundation) - Units
WITH training_units AS (
  SELECT t.id, t.title, m.order_number
  FROM public.trainings t
  JOIN public.modules m ON t.module_id = m.id
  WHERE m.order_number = 2
),
module_quiz_assessments AS (
  SELECT DISTINCT a.id, a.training_id
  FROM public.assessments a
  WHERE a.type = 'module_quiz'
    AND a.training_id IN (SELECT id FROM training_units)
)

-- Insert 4 MCQ questions for each Module 2 training unit
INSERT INTO public.questions (assessment_id, question_type, question_text, order_number, module_id, created_at)
SELECT
  mqa.id,
  'mcq' as question_type,
  q.question_text,
  ROW_NUMBER() OVER (PARTITION BY mqa.training_id ORDER BY q.order_number) as order_number,
  m.id as module_id,
  now()
FROM module_quiz_assessments mqa,
(VALUES
  ('When establishing a coaching partnership, what is the most critical element to address first?'),
  ('How would you respond if a teacher expresses concern about your observations of their teaching?'),
  ('Which approach best ensures psychological safety in a coaching relationship?'),
  ('What is the primary benefit of co-creating SMART goals with teachers?')
) AS q(question_text),
(SELECT id FROM public.modules WHERE order_number = 2 LIMIT 1) AS m
WHERE NOT EXISTS (
  SELECT 1 FROM public.questions
  WHERE assessment_id = mqa.id AND question_type = 'mcq' AND order_number BETWEEN 1 AND 4
);

-- Module 3 (Mirror Specialist) - MCQ Questions
WITH training_units AS (
  SELECT t.id, t.title, m.order_number
  FROM public.trainings t
  JOIN public.modules m ON t.module_id = m.id
  WHERE m.order_number = 3
),
module_quiz_assessments AS (
  SELECT DISTINCT a.id, a.training_id
  FROM public.assessments a
  WHERE a.type = 'module_quiz'
    AND a.training_id IN (SELECT id FROM training_units)
)
INSERT INTO public.questions (assessment_id, question_type, question_text, order_number, module_id, created_at)
SELECT
  mqa.id,
  'mcq' as question_type,
  q.question_text,
  ROW_NUMBER() OVER (PARTITION BY mqa.training_id ORDER BY q.order_number) + 4 as order_number,
  m.id as module_id,
  now()
FROM module_quiz_assessments mqa,
(VALUES
  ('What is the primary purpose of low-inference observation in coaching?'),
  ('How should a coach present classroom data to maintain teacher ownership of solutions?'),
  ('What makes artifact validation (photos/audio) more effective than verbal feedback?'),
  ('Which technique best supports a teacher in developing their own interpretations?')
) AS q(question_text),
(SELECT id FROM public.modules WHERE order_number = 3 LIMIT 1) AS m
WHERE NOT EXISTS (
  SELECT 1 FROM public.questions
  WHERE assessment_id = mqa.id AND question_type = 'mcq' AND order_number BETWEEN 5 AND 8
);

-- Module 4 (Digital & Data Intelligence) - MCQ Questions
WITH training_units AS (
  SELECT t.id, t.title, m.order_number
  FROM public.trainings t
  JOIN public.modules m ON t.module_id = m.id
  WHERE m.order_number = 4
),
module_quiz_assessments AS (
  SELECT DISTINCT a.id, a.training_id
  FROM public.assessments a
  WHERE a.type = 'module_quiz'
    AND a.training_id IN (SELECT id FROM training_units)
)
INSERT INTO public.questions (assessment_id, question_type, question_text, order_number, module_id, created_at)
SELECT
  mqa.id,
  'mcq' as question_type,
  q.question_text,
  ROW_NUMBER() OVER (PARTITION BY mqa.training_id ORDER BY q.order_number) + 8 as order_number,
  m.id as module_id,
  now()
FROM module_quiz_assessments mqa,
(VALUES
  ('How does WRER tracking enhance the coaching conversation?'),
  ('What is the "data-as-third-person" principle in coaching?'),
  ('Which digital tool integration most effectively supports data-informed teaching?'),
  ('How can dashboards serve as coaching accelerators?')
) AS q(question_text),
(SELECT id FROM public.modules WHERE order_number = 4 LIMIT 1) AS m
WHERE NOT EXISTS (
  SELECT 1 FROM public.questions
  WHERE assessment_id = mqa.id AND question_type = 'mcq' AND order_number BETWEEN 9 AND 12
);

-- Module 5 (Instructional Catalyst) - MCQ Questions
WITH training_units AS (
  SELECT t.id, t.title, m.order_number
  FROM public.trainings t
  JOIN public.modules m ON t.module_id = m.id
  WHERE m.order_number = 5
),
module_quiz_assessments AS (
  SELECT DISTINCT a.id, a.training_id
  FROM public.assessments a
  WHERE a.type = 'module_quiz'
    AND a.training_id IN (SELECT id FROM training_units)
)
INSERT INTO public.questions (assessment_id, question_type, question_text, order_number, module_id, created_at)
SELECT
  mqa.id,
  'mcq' as question_type,
  q.question_text,
  ROW_NUMBER() OVER (PARTITION BY mqa.training_id ORDER BY q.order_number) + 12 as order_number,
  m.id as module_id,
  now()
FROM module_quiz_assessments mqa,
(VALUES
  ('What is the primary benefit of micro-skill isolation in coaching?'),
  ('How does the 3 Loops framework support instructional improvement?'),
  ('When should a coach engage in side-by-side co-modeling?'),
  ('How can pedagogical root-cause analysis improve coaching effectiveness?')
) AS q(question_text),
(SELECT id FROM public.modules WHERE order_number = 5 LIMIT 1) AS m
WHERE NOT EXISTS (
  SELECT 1 FROM public.questions
  WHERE assessment_id = mqa.id AND question_type = 'mcq' AND order_number BETWEEN 13 AND 16
);

-- 3. Add open-ended questions (one per module, ungraded)
-- Module 2 Open-Ended
WITH training_units AS (
  SELECT t.id, t.title, m.order_number
  FROM public.trainings t
  JOIN public.modules m ON t.module_id = m.id
  WHERE m.order_number = 2
),
module_quiz_assessments AS (
  SELECT DISTINCT a.id, a.training_id
  FROM public.assessments a
  WHERE a.type = 'module_quiz'
    AND a.training_id IN (SELECT id FROM training_units)
)
INSERT INTO public.questions (assessment_id, question_type, question_text, correct_answer, order_number, module_id, created_at)
SELECT
  mqa.id,
  'open' as question_type,
  'Describe a time when you had to establish trust with a teacher who was initially skeptical of coaching. What strategies did you use?',
  'Strategies may include: listening without judgment, acknowledging concerns, co-creating goals, demonstrating competence through observations, maintaining psychological safety.',
  17,
  m.id as module_id,
  now()
FROM module_quiz_assessments mqa,
(SELECT id FROM public.modules WHERE order_number = 2 LIMIT 1) AS m
WHERE NOT EXISTS (
  SELECT 1 FROM public.questions
  WHERE assessment_id = mqa.id AND question_type = 'open' AND order_number = 17
);

-- Module 3 Open-Ended
WITH training_units AS (
  SELECT t.id, t.title, m.order_number
  FROM public.trainings t
  JOIN public.modules m ON t.module_id = m.id
  WHERE m.order_number = 3
),
module_quiz_assessments AS (
  SELECT DISTINCT a.id, a.training_id
  FROM public.assessments a
  WHERE a.type = 'module_quiz'
    AND a.training_id IN (SELECT id FROM training_units)
)
INSERT INTO public.questions (assessment_id, question_type, question_text, correct_answer, order_number, module_id, created_at)
SELECT
  mqa.id,
  'open' as question_type,
  'How would you use artifacts (photos, videos, student work samples) to support a teacher in self-identifying an area for growth?',
  'Effective response includes: selecting relevant artifacts, presenting neutrally without inference, asking reflective questions, allowing teacher to interpret, supporting self-directed solution development.',
  18,
  m.id as module_id,
  now()
FROM module_quiz_assessments mqa,
(SELECT id FROM public.modules WHERE order_number = 3 LIMIT 1) AS m
WHERE NOT EXISTS (
  SELECT 1 FROM public.questions
  WHERE assessment_id = mqa.id AND question_type = 'open' AND order_number = 18
);

-- Module 4 Open-Ended
WITH training_units AS (
  SELECT t.id, t.title, m.order_number
  FROM public.trainings t
  JOIN public.modules m ON t.module_id = m.id
  WHERE m.order_number = 4
),
module_quiz_assessments AS (
  SELECT DISTINCT a.id, a.training_id
  FROM public.assessments a
  WHERE a.type = 'module_quiz'
    AND a.training_id IN (SELECT id FROM training_units)
)
INSERT INTO public.questions (assessment_id, question_type, question_text, correct_answer, order_number, module_id, created_at)
SELECT
  mqa.id,
  'open' as question_type,
  'Explain how you would use classroom data (WRER, student work, attendance) to accelerate a teacher''s instructional improvement journey.',
  'Strong response includes: data selection relevant to teacher goals, dashboard visualization, data-as-third-person approach, collaborative interpretation, action planning, progress monitoring.',
  19,
  m.id as module_id,
  now()
FROM module_quiz_assessments mqa,
(SELECT id FROM public.modules WHERE order_number = 4 LIMIT 1) AS m
WHERE NOT EXISTS (
  SELECT 1 FROM public.questions
  WHERE assessment_id = mqa.id AND question_type = 'open' AND order_number = 19
);

-- Module 5 Open-Ended
WITH training_units AS (
  SELECT t.id, t.title, m.order_number
  FROM public.trainings t
  JOIN public.modules m ON t.module_id = m.id
  WHERE m.order_number = 5
),
module_quiz_assessments AS (
  SELECT DISTINCT a.id, a.training_id
  FROM public.assessments a
  WHERE a.type = 'module_quiz'
    AND a.training_id IN (SELECT id FROM training_units)
)
INSERT INTO public.questions (assessment_id, question_type, question_text, correct_answer, order_number, module_id, created_at)
SELECT
  mqa.id,
  'open' as question_type,
  'Describe how you would guide a teacher through co-modeling and practice to master a specific micro-skill in their classroom context.',
  'Complete response includes: micro-skill definition, modeling with explanation, guided practice opportunities, feedback loops, independent application, verification of mastery, celebration of progress.',
  20,
  m.id as module_id,
  now()
FROM module_quiz_assessments mqa,
(SELECT id FROM public.modules WHERE order_number = 5 LIMIT 1) AS m
WHERE NOT EXISTS (
  SELECT 1 FROM public.questions
  WHERE assessment_id = mqa.id AND question_type = 'open' AND order_number = 20
);

-- 4. Add MCQ options (A/B/C/D for questions 1-16)
-- This follows the same structure as the endline questions but for module quiz

-- Module 2, Question 1 Options
WITH mcq_q AS (
  SELECT q.id FROM public.questions q
  WHERE q.question_type = 'mcq'
    AND q.question_text = 'When establishing a coaching partnership, what is the most critical element to address first?'
    LIMIT 1
)
INSERT INTO public.options (question_id, option_letter, option_text, is_correct, rationale, principle_tag)
SELECT q.id, o.letter, o.text, o.correct, o.rationale, o.principle
FROM mcq_q q,
(VALUES
  ('A', 'Establish psychological safety and discuss expectations', true, 'Trust and safety form the foundation of effective coaching relationships.', 'Trust & Safety'),
  ('B', 'Immediately observe the teacher''s practice and provide feedback', false, 'Jumping to feedback without relationship-building undermines coaching effectiveness.', 'Partnership'),
  ('C', 'Review student achievement data', false, 'While important, data review comes after establishing trust and partnership.', 'Data'),
  ('D', 'Provide training on the latest teaching strategies', false, 'Training is reactive; partnership creates conditions for sustainable improvement.', 'Coaching')
) AS o(letter, text, correct, rationale, principle)
WHERE NOT EXISTS (SELECT 1 FROM public.options WHERE question_id = q.id);

-- Module 2, Question 2 Options
WITH mcq_q AS (
  SELECT q.id FROM public.questions q
  WHERE q.question_type = 'mcq'
    AND q.question_text = 'How would you respond if a teacher expresses concern about your observations of their teaching?'
    LIMIT 1
)
INSERT INTO public.options (question_id, option_letter, option_text, is_correct, rationale, principle_tag)
SELECT q.id, o.letter, o.text, o.correct, o.rationale, o.principle
FROM mcq_q q,
(VALUES
  ('A', 'Defend your observations as objective truth', false, 'Defensive posturing erodes trust and psychological safety.', 'Partnership'),
  ('B', 'Listen deeply, acknowledge their concerns, and explore together', true, 'Deep listening and collaborative exploration maintain partnership and ownership.', 'Trust & Safety'),
  ('C', 'Explain why your observations are correct', false, 'Top-down explanation diminishes teacher ownership and voice.', 'Partnership'),
  ('D', 'Apologize and agree with their concern regardless of accuracy', false, 'Abandoning accuracy undermines credibility and coaching integrity.', 'Integrity')
) AS o(letter, text, correct, rationale, principle)
WHERE NOT EXISTS (SELECT 1 FROM public.options WHERE question_id = q.id);

-- Module 2, Question 3 Options
WITH mcq_q AS (
  SELECT q.id FROM public.questions q
  WHERE q.question_type = 'mcq'
    AND q.question_text = 'Which approach best ensures psychological safety in a coaching relationship?'
    LIMIT 1
)
INSERT INTO public.options (question_id, option_letter, option_text, is_correct, rationale, principle_tag)
SELECT q.id, o.letter, o.text, o.correct, o.rationale, o.principle
FROM mcq_q q,
(VALUES
  ('A', 'Maintain high-frequency observations without explanation', false, 'Unexplained observations can feel threatening and erode safety.', 'Safety'),
  ('B', 'Ensure teachers have choice, voice, and equal status in decisions', true, 'Choice, voice, and equality counter status threat and build safety.', 'Status Threat'),
  ('C', 'Provide frequent positive feedback', false, 'Feedback without partnership does not ensure psychological safety.', 'Partnership'),
  ('D', 'Avoid discussing sensitive instructional practices', false, 'Avoidance prevents growth; safety enables candid conversations.', 'Growth')
) AS o(letter, text, correct, rationale, principle)
WHERE NOT EXISTS (SELECT 1 FROM public.options WHERE question_id = q.id);

-- Module 2, Question 4 Options
WITH mcq_q AS (
  SELECT q.id FROM public.questions q
  WHERE q.question_type = 'mcq'
    AND q.question_text = 'What is the primary benefit of co-creating SMART goals with teachers?'
    LIMIT 1
)
INSERT INTO public.options (question_id, option_letter, option_text, is_correct, rationale, principle_tag)
SELECT q.id, o.letter, o.text, o.correct, o.rationale, o.principle
FROM mcq_q q,
(VALUES
  ('A', 'Coaches can impose goals they believe are important for the teacher', false, 'Imposed goals reduce teacher ownership and motivation.', 'Ownership'),
  ('B', 'Teachers feel ownership and are more likely to achieve goals they helped create', true, 'Co-creation ensures alignment, buy-in, and sustainable improvement.', 'Co-Design'),
  ('C', 'SMART goals are only useful for administrative compliance', false, 'SMART goals drive meaningful, measurable teacher growth.', 'Clarity'),
  ('D', 'Goal-setting should focus only on student outcomes', false, 'Teacher growth goals often precede improved student outcomes.', 'Growth')
) AS o(letter, text, correct, rationale, principle)
WHERE NOT EXISTS (SELECT 1 FROM public.options WHERE question_id = q.id);

-- Module 3 Questions (5-8)
WITH mcq_q AS (
  SELECT q.id FROM public.questions q
  WHERE q.question_type = 'mcq'
    AND q.question_text = 'What is the primary purpose of low-inference observation in coaching?'
    LIMIT 1
)
INSERT INTO public.options (question_id, option_letter, option_text, is_correct, rationale, principle_tag)
SELECT q.id, o.letter, o.text, o.correct, o.rationale, o.principle
FROM mcq_q q,
(VALUES
  ('A', 'Record everything the teacher does without filters', false, 'Unfiltered observation lacks focus and structure.', 'Observation'),
  ('B', 'Collect objective, inference-free data on specific teaching behaviors', true, 'Low-inference observation reveals patterns and supports evidence-based reflection.', 'Objectivity'),
  ('C', 'Make judgments about teacher effectiveness', false, 'Judgment-free observation maintains safety and focus on evidence.', 'Safety'),
  ('D', 'Provide immediate feedback during the lesson', false, 'In-the-moment feedback interrupts teaching and learning.', 'Timing')
) AS o(letter, text, correct, rationale, principle)
WHERE NOT EXISTS (SELECT 1 FROM public.options WHERE question_id = q.id);

WITH mcq_q AS (
  SELECT q.id FROM public.questions q
  WHERE q.question_type = 'mcq'
    AND q.question_text = 'How should a coach present classroom data to maintain teacher ownership of solutions?'
    LIMIT 1
)
INSERT INTO public.options (question_id, option_letter, option_text, is_correct, rationale, principle_tag)
SELECT q.id, o.letter, o.text, o.correct, o.rationale, o.principle
FROM mcq_q q,
(VALUES
  ('A', 'Share data neutrally and ask reflective questions to support self-discovery', true, 'Neutral presentation and reflection enable teacher-owned interpretation.', 'Ownership'),
  ('B', 'Interpret the data for the teacher to ensure they understand correctly', false, 'Coach interpretation reduces teacher agency and self-direction.', 'Agency'),
  ('C', 'Focus on areas where the teacher is struggling', false, 'Deficit-focused feedback can erode confidence and engagement.', 'Strength'),
  ('D', 'Present conclusions rather than raw data', false, 'Raw data supports more robust and collaborative interpretation.', 'Transparency')
) AS o(letter, text, correct, rationale, principle)
WHERE NOT EXISTS (SELECT 1 FROM public.options WHERE question_id = q.id);

WITH mcq_q AS (
  SELECT q.id FROM public.questions q
  WHERE q.question_type = 'mcq'
    AND q.question_text = 'What makes artifact validation (photos/audio) more effective than verbal feedback?'
    LIMIT 1
)
INSERT INTO public.options (question_id, option_letter, option_text, is_correct, rationale, principle_tag)
SELECT q.id, o.letter, o.text, o.correct, o.rationale, o.principle
FROM mcq_q q,
(VALUES
  ('A', 'Verbal feedback is more personal and engaging', false, 'Verbal feedback is subject to memory limitations and interpretation.', 'Reliability'),
  ('B', 'Artifacts provide objective evidence that teachers can review repeatedly', true, 'Artifacts enable calibration, reflection, and evidence-based growth.', 'Objectivity'),
  ('C', 'Verbal feedback is easier for coaches to deliver', false, 'Efficiency should not override coaching effectiveness.', 'Effectiveness'),
  ('D', 'Teachers prefer feedback without documentation', false, 'Documentation supports accountability and growth tracking.', 'Documentation')
) AS o(letter, text, correct, rationale, principle)
WHERE NOT EXISTS (SELECT 1 FROM public.options WHERE question_id = q.id);

WITH mcq_q AS (
  SELECT q.id FROM public.questions q
  WHERE q.question_type = 'mcq'
    AND q.question_text = 'Which technique best supports a teacher in developing their own interpretations?'
    LIMIT 1
)
INSERT INTO public.options (question_id, option_letter, option_text, is_correct, rationale, principle_tag)
SELECT q.id, o.letter, o.text, o.correct, o.rationale, o.principle
FROM mcq_q q,
(VALUES
  ('A', 'Ask open-ended questions and listen for teacher-generated insights', true, 'Guided discovery honors teacher expertise and builds agency.', 'Agency'),
  ('B', 'Tell the teacher what interpretations they should make', false, 'Telling reduces teacher reflection and ownership.', 'Reflection'),
  ('C', 'Suggest multiple interpretations for the teacher to choose from', false, 'Suggestions still position the coach as the expert.', 'Expertise'),
  ('D', 'Present data without any guidance', false, 'Complete lack of structure may overwhelm or confuse.', 'Structure')
) AS o(letter, text, correct, rationale, principle)
WHERE NOT EXISTS (SELECT 1 FROM public.options WHERE question_id = q.id);

-- Module 4 Questions (9-12)
WITH mcq_q AS (
  SELECT q.id FROM public.questions q
  WHERE q.question_type = 'mcq'
    AND q.question_text = 'How does WRER tracking enhance the coaching conversation?'
    LIMIT 1
)
INSERT INTO public.options (question_id, option_letter, option_text, is_correct, rationale, principle_tag)
SELECT q.id, o.letter, o.text, o.correct, o.rationale, o.principle
FROM mcq_q q,
(VALUES
  ('A', 'It replaces the need for coaching observations', false, 'Data supports but does not replace human coaching.', 'Balance'),
  ('B', 'It provides objective patterns teachers can use to guide their own solutions', true, 'WRER enables data-informed, teacher-owned improvement strategies.', 'Data'),
  ('C', 'It should be used only for administrative evaluation', false, 'Data is most powerful when used collaboratively for improvement.', 'Purpose'),
  ('D', 'It focuses only on student outcomes without context', false, 'WRER captures process and context alongside outcomes.', 'Context')
) AS o(letter, text, correct, rationale, principle)
WHERE NOT EXISTS (SELECT 1 FROM public.options WHERE question_id = q.id);

WITH mcq_q AS (
  SELECT q.id FROM public.questions q
  WHERE q.question_type = 'mcq'
    AND q.question_text = 'What is the "data-as-third-person" principle in coaching?'
    LIMIT 1
)
INSERT INTO public.options (question_id, option_letter, option_text, is_correct, rationale, principle_tag)
SELECT q.id, o.letter, o.text, o.correct, o.rationale, o.principle
FROM mcq_q q,
(VALUES
  ('A', 'The coach interprets data and presents conclusions', false, 'Coach interpretation reduces teacher agency.', 'Agency'),
  ('B', 'Data is presented as the "objective third person" to support collaborative interpretation', true, 'Third-person framing removes threat and enables open inquiry.', 'Safety'),
  ('C', 'Teachers are expected to find meaning without coach support', false, 'Support structures help teachers develop interpretation skills.', 'Support'),
  ('D', 'Data is shared only when it shows improvement', false, 'Honest data sharing maintains credibility and enables real growth.', 'Honesty')
) AS o(letter, text, correct, rationale, principle)
WHERE NOT EXISTS (SELECT 1 FROM public.options WHERE question_id = q.id);

WITH mcq_q AS (
  SELECT q.id FROM public.questions q
  WHERE q.question_type = 'mcq'
    AND q.question_text = 'Which digital tool integration most effectively supports data-informed teaching?'
    LIMIT 1
)
INSERT INTO public.options (question_id, option_letter, option_text, is_correct, rationale, principle_tag)
SELECT q.id, o.letter, o.text, o.correct, o.rationale, o.principle
FROM mcq_q q,
(VALUES
  ('A', 'Learning management systems to track completion', false, 'Completion tracking alone does not accelerate improvement.', 'Measurement'),
  ('B', 'Dashboards that make student progress visible and actionable for teachers', true, 'Dashboards enable rapid cycles of data-informed teaching refinement.', 'Digital'),
  ('C', 'Email systems for distributing assessment results', false, 'One-way distribution lacks the interactivity needed for acceleration.', 'Interaction'),
  ('D', 'Software that replaces teacher judgment with automated recommendations', false, 'Tools should augment teacher wisdom, not replace it.', 'Partnership')
) AS o(letter, text, correct, rationale, principle)
WHERE NOT EXISTS (SELECT 1 FROM public.options WHERE question_id = q.id);

WITH mcq_q AS (
  SELECT q.id FROM public.questions q
  WHERE q.question_type = 'mcq'
    AND q.question_text = 'How can dashboards serve as coaching accelerators?'
    LIMIT 1
)
INSERT INTO public.options (question_id, option_letter, option_text, is_correct, rationale, principle_tag)
SELECT q.id, o.letter, o.text, o.correct, o.rationale, o.principle
FROM mcq_q q,
(VALUES
  ('A', 'They replace the need for observational coaching', false, 'Digital tools support but do not replace human coaching relationships.', 'Balance'),
  ('B', 'They provide coaches with quick access to data to inform conversations', true, 'Data dashboards accelerate coaching cycles and depth of inquiry.', 'Acceleration'),
  ('C', 'They should be used instead of direct teacher observation', false, 'Direct observation remains central to coaching.', 'Observation'),
  ('D', 'They focus only on compliance rather than growth', false, 'Modern dashboards target growth, not compliance.', 'Growth')
) AS o(letter, text, correct, rationale, principle)
WHERE NOT EXISTS (SELECT 1 FROM public.options WHERE question_id = q.id);

-- Module 5 Questions (13-16)
WITH mcq_q AS (
  SELECT q.id FROM public.questions q
  WHERE q.question_type = 'mcq'
    AND q.question_text = 'What is the primary benefit of micro-skill isolation in coaching?'
    LIMIT 1
)
INSERT INTO public.options (question_id, option_letter, option_text, is_correct, rationale, principle_tag)
SELECT q.id, o.letter, o.text, o.correct, o.rationale, o.principle
FROM mcq_q q,
(VALUES
  ('A', 'It allows teachers to practice many skills at once', false, 'Simultaneous practice of multiple skills creates cognitive overload.', 'Learning'),
  ('B', 'It focuses coaching on discrete, observable behaviors that teachers can master independently', true, 'Micro-skill isolation enables focused practice and mastery.', 'Mastery'),
  ('C', 'It simplifies lessons to make them less rigorous', false, 'Micro-skills support sophisticated, nuanced teaching.', 'Rigor'),
  ('D', 'It reduces the need for ongoing professional development', false, 'Micro-skills are building blocks within continuous improvement systems.', 'Development')
) AS o(letter, text, correct, rationale, principle)
WHERE NOT EXISTS (SELECT 1 FROM public.options WHERE question_id = q.id);

WITH mcq_q AS (
  SELECT q.id FROM public.questions q
  WHERE q.question_type = 'mcq'
    AND q.question_text = 'How does the 3 Loops framework support instructional improvement?'
    LIMIT 1
)
INSERT INTO public.options (question_id, option_letter, option_text, is_correct, rationale, principle_tag)
SELECT q.id, o.letter, o.text, o.correct, o.rationale, o.principle
FROM mcq_q q,
(VALUES
  ('A', 'It ensures the coach maintains control of the improvement process', false, 'The coach facilitates; the teacher owns the process.', 'Agency'),
  ('B', 'Loop 1 (Observe) → Loop 2 (Analyze) → Loop 3 (Plan) creates systematic improvement cycles', true, '3 Loops provide structure for observation, analysis, and action planning.', 'Structure'),
  ('C', 'It requires coaches to tell teachers what to do', false, 'Loops support inquiry and teacher-led decision-making.', 'Agency'),
  ('D', 'It bypasses the need for partnership', false, '3 Loops only work when embedded in strong partnerships.', 'Partnership')
) AS o(letter, text, correct, rationale, principle)
WHERE NOT EXISTS (SELECT 1 FROM public.options WHERE question_id = q.id);

WITH mcq_q AS (
  SELECT q.id FROM public.questions q
  WHERE q.question_type = 'mcq'
    AND q.question_text = 'When should a coach engage in side-by-side co-modeling?'
    LIMIT 1
)
INSERT INTO public.options (question_id, option_letter, option_text, is_correct, rationale, principle_tag)
SELECT q.id, o.letter, o.text, o.correct, o.rationale, o.principle
FROM mcq_q q,
(VALUES
  ('A', 'When the teacher is not confident or skilled in a technique', true, 'Side-by-side modeling provides the teacher with a live reference and scaffold.', 'Support'),
  ('B', 'Only during formal professional development sessions', false, 'Co-modeling is most powerful when embedded in real classroom contexts.', 'Context'),
  ('C', 'When coaches have more experience than teachers', false, 'Co-modeling is about supporting skill-building, not demonstrating superiority.', 'Humility'),
  ('D', 'Never, because it disrupts classroom instruction', false, 'Well-timed co-modeling enriches classroom learning.', 'Classroom')
) AS o(letter, text, correct, rationale, principle)
WHERE NOT EXISTS (SELECT 1 FROM public.options WHERE question_id = q.id);

WITH mcq_q AS (
  SELECT q.id FROM public.questions q
  WHERE q.question_type = 'mcq'
    AND q.question_text = 'How can pedagogical root-cause analysis improve coaching effectiveness?'
    LIMIT 1
)
INSERT INTO public.options (question_id, option_letter, option_text, is_correct, rationale, principle_tag)
SELECT q.id, o.letter, o.text, o.correct, o.rationale, o.principle
FROM mcq_q q,
(VALUES
  ('A', 'It identifies what teaching practices cause student learning gaps', true, 'Root-cause analysis pinpoints specific instructional levers for improvement.', 'Analysis'),
  ('B', 'It focuses blame on teachers for student underperformance', false, 'RCA is solutions-focused, not blame-focused.', 'Solutions'),
  ('C', 'It replaces the need for professional development', false, 'RCA often reveals specific PD needs.', 'Development'),
  ('D', 'It only works for struggling students', false, 'RCA applies to all levels of student and teacher performance.', 'Universal')
) AS o(letter, text, correct, rationale, principle)
WHERE NOT EXISTS (SELECT 1 FROM public.options WHERE question_id = q.id);

-- Verification
SELECT 'Module Quiz 20-Question Setup Complete' as status;
SELECT COUNT(*) as total_mcq_questions FROM public.questions
WHERE question_type = 'mcq' AND question_text IN (
  'When establishing a coaching partnership, what is the most critical element to address first?',
  'How would you respond if a teacher expresses concern about your observations of their teaching?',
  'Which approach best ensures psychological safety in a coaching relationship?',
  'What is the primary benefit of co-creating SMART goals with teachers?',
  'What is the primary purpose of low-inference observation in coaching?',
  'How should a coach present classroom data to maintain teacher ownership of solutions?',
  'What makes artifact validation (photos/audio) more effective than verbal feedback?',
  'Which technique best supports a teacher in developing their own interpretations?',
  'How does WRER tracking enhance the coaching conversation?',
  'What is the "data-as-third-person" principle in coaching?',
  'Which digital tool integration most effectively supports data-informed teaching?',
  'How can dashboards serve as coaching accelerators?',
  'What is the primary benefit of micro-skill isolation in coaching?',
  'How does the 3 Loops framework support instructional improvement?',
  'When should a coach engage in side-by-side co-modeling?',
  'How can pedagogical root-cause analysis improve coaching effectiveness?'
);
SELECT COUNT(*) as total_open_ended_questions FROM public.questions
WHERE question_type = 'open' AND question_text LIKE '%trust%' OR question_text LIKE '%artifacts%' OR question_text LIKE '%data%' OR question_text LIKE '%co-modeling%';
