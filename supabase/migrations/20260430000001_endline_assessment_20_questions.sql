-- ─────────────────────────────────────────────────────────────────────────────
-- Endline Assessment: 20 Questions (16 MCQ + 4 Open-Ended)
-- ─────────────────────────────────────────────────────────────────────────────
--
-- Purpose:
-- - Create endline assessment record if not exists
-- - Seed 20 endline questions: 4 MCQ per module (16 total) + 1 open-ended per module (4 total)
-- - MCQ questions have 4 options each (A/B/C/D)
-- - Open-ended questions have no options (ungraded text entry)
-- - Pass threshold: 70% (MCQ only)
--
-- Question Distribution:
--   Questions 1-4: Module 2 MCQ
--   Questions 5-8: Module 3 MCQ
--   Questions 9-12: Module 4 MCQ
--   Questions 13-16: Module 5 MCQ
--   Questions 17: Module 2 Open-Ended
--   Questions 18: Module 3 Open-Ended
--   Questions 19: Module 4 Open-Ended
--   Questions 20: Module 5 Open-Ended
--

-- 1. Create endline assessment record (if not exists)
INSERT INTO public.assessments (type, title)
SELECT 'endline', 'Endline Assessment: Coaching Certification'
WHERE NOT EXISTS (SELECT 1 FROM public.assessments WHERE type = 'endline')
LIMIT 1;

-- Get the endline assessment ID for the inserts below
WITH endline_assess AS (
  SELECT id FROM public.assessments WHERE type = 'endline' LIMIT 1
)

-- 2. Seed MCQ Questions (1-16)
-- Questions 1-4: Module 2 (Partnership Foundation)
INSERT INTO public.questions (assessment_id, question_type, question_text, order_number, module_id, created_at)
SELECT
  ea.id,
  'mcq' as question_type,
  q.question_text,
  q.order_number,
  m.id as module_id,
  now()
FROM endline_assess ea,
(VALUES
  ('When establishing a coaching partnership, what is the most critical element to address first?', 1),
  ('How would you respond if a teacher expresses concern about your observations of their teaching?', 2),
  ('Which approach best ensures psychological safety in a coaching relationship?', 3),
  ('What is the primary benefit of co-creating SMART goals with teachers?', 4)
) AS q(question_text, order_number),
(SELECT id FROM public.modules WHERE order_number = 2 LIMIT 1) AS m
WHERE NOT EXISTS (
  SELECT 1 FROM public.questions
  WHERE assessment_id = ea.id AND question_type = 'mcq' AND order_number BETWEEN 1 AND 4
);

-- Questions 5-8: Module 3 (Mirror Specialist)
INSERT INTO public.questions (assessment_id, question_type, question_text, order_number, module_id, created_at)
SELECT
  ea.id,
  'mcq' as question_type,
  q.question_text,
  q.order_number,
  m.id as module_id,
  now()
FROM endline_assess ea,
(VALUES
  ('What is the primary purpose of low-inference observation in coaching?', 5),
  ('How should a coach present classroom data to maintain teacher ownership of solutions?', 6),
  ('What makes artifact validation (photos/audio) more effective than verbal feedback?', 7),
  ('Which technique best supports a teacher in developing their own interpretations?', 8)
) AS q(question_text, order_number),
(SELECT id FROM public.modules WHERE order_number = 3 LIMIT 1) AS m
WHERE NOT EXISTS (
  SELECT 1 FROM public.questions
  WHERE assessment_id = ea.id AND question_type = 'mcq' AND order_number BETWEEN 5 AND 8
);

-- Questions 9-12: Module 4 (Digital & Data Intelligence)
INSERT INTO public.questions (assessment_id, question_type, question_text, order_number, module_id, created_at)
SELECT
  ea.id,
  'mcq' as question_type,
  q.question_text,
  q.order_number,
  m.id as module_id,
  now()
FROM endline_assess ea,
(VALUES
  ('How does WRER tracking enhance the coaching conversation?', 9),
  ('What is the "data-as-third-person" principle in coaching?', 10),
  ('Which digital tool integration most effectively supports data-informed teaching?', 11),
  ('How can dashboards serve as coaching accelerators?', 12)
) AS q(question_text, order_number),
(SELECT id FROM public.modules WHERE order_number = 4 LIMIT 1) AS m
WHERE NOT EXISTS (
  SELECT 1 FROM public.questions
  WHERE assessment_id = ea.id AND question_type = 'mcq' AND order_number BETWEEN 9 AND 12
);

-- Questions 13-16: Module 5 (Instructional Catalyst)
INSERT INTO public.questions (assessment_id, question_type, question_text, order_number, module_id, created_at)
SELECT
  ea.id,
  'mcq' as question_type,
  q.question_text,
  q.order_number,
  m.id as module_id,
  now()
FROM endline_assess ea,
(VALUES
  ('What is the primary benefit of micro-skill isolation in coaching?', 13),
  ('How does the 3 Loops framework support instructional improvement?', 14),
  ('When should a coach engage in side-by-side co-modeling?', 15),
  ('How can pedagogical root-cause analysis improve coaching effectiveness?', 16)
) AS q(question_text, order_number),
(SELECT id FROM public.modules WHERE order_number = 5 LIMIT 1) AS m
WHERE NOT EXISTS (
  SELECT 1 FROM public.questions
  WHERE assessment_id = ea.id AND question_type = 'mcq' AND order_number BETWEEN 13 AND 16
);

-- 3. Seed Open-Ended Questions (17-20)
-- Question 17: Module 2 Open-Ended
INSERT INTO public.questions (assessment_id, question_type, question_text, correct_answer, order_number, module_id, created_at)
SELECT
  ea.id,
  'open' as question_type,
  'Describe a time when you had to establish trust with a teacher who was initially skeptical of coaching. What strategies did you use?',
  'Strategies may include: listening without judgment, acknowledging concerns, co-creating goals, demonstrating competence through observations, maintaining psychological safety.',
  17,
  m.id as module_id,
  now()
FROM endline_assess ea,
(SELECT id FROM public.modules WHERE order_number = 2 LIMIT 1) AS m
WHERE NOT EXISTS (
  SELECT 1 FROM public.questions
  WHERE assessment_id = ea.id AND question_type = 'open' AND order_number = 17
);

-- Question 18: Module 3 Open-Ended
INSERT INTO public.questions (assessment_id, question_type, question_text, correct_answer, order_number, module_id, created_at)
SELECT
  ea.id,
  'open' as question_type,
  'How would you use artifacts (photos, videos, student work samples) to support a teacher in self-identifying an area for growth?',
  'Effective response includes: selecting relevant artifacts, presenting neutrally without inference, asking reflective questions, allowing teacher to interpret, supporting self-directed solution development.',
  18,
  m.id as module_id,
  now()
FROM endline_assess ea,
(SELECT id FROM public.modules WHERE order_number = 3 LIMIT 1) AS m
WHERE NOT EXISTS (
  SELECT 1 FROM public.questions
  WHERE assessment_id = ea.id AND question_type = 'open' AND order_number = 18
);

-- Question 19: Module 4 Open-Ended
INSERT INTO public.questions (assessment_id, question_type, question_text, correct_answer, order_number, module_id, created_at)
SELECT
  ea.id,
  'open' as question_type,
  'Explain how you would use classroom data (WRER, student work, attendance) to accelerate a teacher''s instructional improvement journey.',
  'Strong response includes: data selection relevant to teacher goals, dashboard visualization, data-as-third-person approach, collaborative interpretation, action planning, progress monitoring.',
  19,
  m.id as module_id,
  now()
FROM endline_assess ea,
(SELECT id FROM public.modules WHERE order_number = 4 LIMIT 1) AS m
WHERE NOT EXISTS (
  SELECT 1 FROM public.questions
  WHERE assessment_id = ea.id AND question_type = 'open' AND order_number = 19
);

-- Question 20: Module 5 Open-Ended
INSERT INTO public.questions (assessment_id, question_type, question_text, correct_answer, order_number, module_id, created_at)
SELECT
  ea.id,
  'open' as question_type,
  'Describe how you would guide a teacher through co-modeling and practice to master a specific micro-skill in their classroom context.',
  'Complete response includes: micro-skill definition, modeling with explanation, guided practice opportunities, feedback loops, independent application, verification of mastery, celebration of progress.',
  20,
  m.id as module_id,
  now()
FROM endline_assess ea,
(SELECT id FROM public.modules WHERE order_number = 5 LIMIT 1) AS m
WHERE NOT EXISTS (
  SELECT 1 FROM public.questions
  WHERE assessment_id = ea.id AND question_type = 'open' AND order_number = 20
);

-- 4. Seed MCQ Options (A/B/C/D for questions 1-16)
WITH endline_assess AS (
  SELECT id FROM public.assessments WHERE type = 'endline' LIMIT 1
),
mcq_questions AS (
  SELECT id, order_number FROM public.questions
  WHERE assessment_id = (SELECT id FROM endline_assess)
    AND question_type = 'mcq'
    AND order_number BETWEEN 1 AND 16
)

-- Question 1 Options (Order 1)
INSERT INTO public.options (question_id, option_letter, option_text, is_correct, rationale, principle_tag)
SELECT q.id, o.letter, o.text, o.correct, o.rationale, o.principle
FROM mcq_questions q,
(VALUES
  ('A', 'Establish psychological safety and discuss expectations', true, 'Trust and safety form the foundation of effective coaching relationships.', 'Trust & Safety'),
  ('B', 'Immediately observe the teacher''s practice and provide feedback', false, 'Jumping to feedback without relationship-building undermines coaching effectiveness.', 'Partnership'),
  ('C', 'Review student achievement data', false, 'While important, data review comes after establishing trust and partnership.', 'Data'),
  ('D', 'Provide training on the latest teaching strategies', false, 'Training is reactive; partnership creates conditions for sustainable improvement.', 'Coaching')
) AS o(letter, text, correct, rationale, principle)
WHERE q.order_number = 1;

-- Question 2 Options (Order 2)
INSERT INTO public.options (question_id, option_letter, option_text, is_correct, rationale, principle_tag)
SELECT q.id, o.letter, o.text, o.correct, o.rationale, o.principle
FROM mcq_questions q,
(VALUES
  ('A', 'Defend your observations as objective truth', false, 'Defensive posturing erodes trust and psychological safety.', 'Partnership'),
  ('B', 'Listen deeply, acknowledge their concerns, and explore together', true, 'Deep listening and collaborative exploration maintain partnership and ownership.', 'Trust & Safety'),
  ('C', 'Explain why your observations are correct', false, 'Top-down explanation diminishes teacher ownership and voice.', 'Partnership'),
  ('D', 'Apologize and agree with their concern regardless of accuracy', false, 'Abandoning accuracy undermines credibility and coaching integrity.', 'Integrity')
) AS o(letter, text, correct, rationale, principle)
WHERE q.order_number = 2;

-- Question 3 Options (Order 3)
INSERT INTO public.options (question_id, option_letter, option_text, is_correct, rationale, principle_tag)
SELECT q.id, o.letter, o.text, o.correct, o.rationale, o.principle
FROM mcq_questions q,
(VALUES
  ('A', 'Maintain high-frequency observations without explanation', false, 'Unexplained observations can feel threatening and erode safety.', 'Safety'),
  ('B', 'Ensure teachers have choice, voice, and equal status in decisions', true, 'Choice, voice, and equality counter status threat and build safety.', 'Status Threat'),
  ('C', 'Provide frequent positive feedback', false, 'Feedback without partnership does not ensure psychological safety.', 'Partnership'),
  ('D', 'Avoid discussing sensitive instructional practices', false, 'Avoidance prevents growth; safety enables candid conversations.', 'Growth')
) AS o(letter, text, correct, rationale, principle)
WHERE q.order_number = 3;

-- Question 4 Options (Order 4)
INSERT INTO public.options (question_id, option_letter, option_text, is_correct, rationale, principle_tag)
SELECT q.id, o.letter, o.text, o.correct, o.rationale, o.principle
FROM mcq_questions q,
(VALUES
  ('A', 'Coaches can impose goals they believe are important for the teacher', false, 'Imposed goals reduce teacher ownership and motivation.', 'Ownership'),
  ('B', 'Teachers feel ownership and are more likely to achieve goals they helped create', true, 'Co-creation ensures alignment, buy-in, and sustainable improvement.', 'Co-Design'),
  ('C', 'SMART goals are only useful for administrative compliance', false, 'SMART goals drive meaningful, measurable teacher growth.', 'Clarity'),
  ('D', 'Goal-setting should focus only on student outcomes', false, 'Teacher growth goals often precede improved student outcomes.', 'Growth')
) AS o(letter, text, correct, rationale, principle)
WHERE q.order_number = 4;

-- Question 5 Options (Order 5 - Module 3)
INSERT INTO public.options (question_id, option_letter, option_text, is_correct, rationale, principle_tag)
SELECT q.id, o.letter, o.text, o.correct, o.rationale, o.principle
FROM mcq_questions q,
(VALUES
  ('A', 'Record everything the teacher does without filters', false, 'Unfiltered observation lacks focus and structure.', 'Observation'),
  ('B', 'Collect objective, inference-free data on specific teaching behaviors', true, 'Low-inference observation reveals patterns and supports evidence-based reflection.', 'Objectivity'),
  ('C', 'Make judgments about teacher effectiveness', false, 'Judgment-free observation maintains safety and focus on evidence.', 'Safety'),
  ('D', 'Provide immediate feedback during the lesson', false, 'In-the-moment feedback interrupts teaching and learning.', 'Timing')
) AS o(letter, text, correct, rationale, principle)
WHERE q.order_number = 5;

-- Question 6 Options (Order 6)
INSERT INTO public.options (question_id, option_letter, option_text, is_correct, rationale, principle_tag)
SELECT q.id, o.letter, o.text, o.correct, o.rationale, o.principle
FROM mcq_questions q,
(VALUES
  ('A', 'Share data neutrally and ask reflective questions to support self-discovery', true, 'Neutral presentation and reflection enable teacher-owned interpretation.', 'Ownership'),
  ('B', 'Interpret the data for the teacher to ensure they understand correctly', false, 'Coach interpretation reduces teacher agency and self-direction.', 'Agency'),
  ('C', 'Focus on areas where the teacher is struggling', false, 'Deficit-focused feedback can erode confidence and engagement.', 'Strength'),
  ('D', 'Present conclusions rather than raw data', false, 'Raw data supports more robust and collaborative interpretation.', 'Transparency')
) AS o(letter, text, correct, rationale, principle)
WHERE q.order_number = 6;

-- Question 7 Options (Order 7)
INSERT INTO public.options (question_id, option_letter, option_text, is_correct, rationale, principle_tag)
SELECT q.id, o.letter, o.text, o.correct, o.rationale, o.principle
FROM mcq_questions q,
(VALUES
  ('A', 'Verbal feedback is more personal and engaging', false, 'Verbal feedback is subject to memory limitations and interpretation.', 'Reliability'),
  ('B', 'Artifacts provide objective evidence that teachers can review repeatedly', true, 'Artifacts enable calibration, reflection, and evidence-based growth.', 'Objectivity'),
  ('C', 'Verbal feedback is easier for coaches to deliver', false, 'Efficiency should not override coaching effectiveness.', 'Effectiveness'),
  ('D', 'Teachers prefer feedback without documentation', false, 'Documentation supports accountability and growth tracking.', 'Documentation')
) AS o(letter, text, correct, rationale, principle)
WHERE q.order_number = 7;

-- Question 8 Options (Order 8)
INSERT INTO public.options (question_id, option_letter, option_text, is_correct, rationale, principle_tag)
SELECT q.id, o.letter, o.text, o.correct, o.rationale, o.principle
FROM mcq_questions q,
(VALUES
  ('A', 'Ask open-ended questions and listen for teacher-generated insights', true, 'Guided discovery honors teacher expertise and builds agency.', 'Agency'),
  ('B', 'Tell the teacher what interpretations they should make', false, 'Telling reduces teacher reflection and ownership.', 'Reflection'),
  ('C', 'Suggest multiple interpretations for the teacher to choose from', false, 'Suggestions still position the coach as the expert.', 'Expertise'),
  ('D', 'Present data without any guidance', false, 'Complete lack of structure may overwhelm or confuse.', 'Structure')
) AS o(letter, text, correct, rationale, principle)
WHERE q.order_number = 8;

-- Question 9 Options (Order 9 - Module 4)
INSERT INTO public.options (question_id, option_letter, option_text, is_correct, rationale, principle_tag)
SELECT q.id, o.letter, o.text, o.correct, o.rationale, o.principle
FROM mcq_questions q,
(VALUES
  ('A', 'It replaces the need for coaching observations', false, 'Data supports but does not replace human coaching.', 'Balance'),
  ('B', 'It provides objective patterns teachers can use to guide their own solutions', true, 'WRER enables data-informed, teacher-owned improvement strategies.', 'Data'),
  ('C', 'It should be used only for administrative evaluation', false, 'Data is most powerful when used collaboratively for improvement.', 'Purpose'),
  ('D', 'It focuses only on student outcomes without context', false, 'WRER captures process and context alongside outcomes.', 'Context')
) AS o(letter, text, correct, rationale, principle)
WHERE q.order_number = 9;

-- Question 10 Options (Order 10)
INSERT INTO public.options (question_id, option_letter, option_text, is_correct, rationale, principle_tag)
SELECT q.id, o.letter, o.text, o.correct, o.rationale, o.principle
FROM mcq_questions q,
(VALUES
  ('A', 'The coach interprets data and presents conclusions', false, 'Coach interpretation reduces teacher agency.', 'Agency'),
  ('B', 'Data is presented as the "objective third person" to support collaborative interpretation', true, 'Third-person framing removes threat and enables open inquiry.', 'Safety'),
  ('C', 'Teachers are expected to find meaning without coach support', false, 'Support structures help teachers develop interpretation skills.', 'Support'),
  ('D', 'Data is shared only when it shows improvement', false, 'Honest data sharing maintains credibility and enables real growth.', 'Honesty')
) AS o(letter, text, correct, rationale, principle)
WHERE q.order_number = 10;

-- Question 11 Options (Order 11)
INSERT INTO public.options (question_id, option_letter, option_text, is_correct, rationale, principle_tag)
SELECT q.id, o.letter, o.text, o.correct, o.rationale, o.principle
FROM mcq_questions q,
(VALUES
  ('A', 'Learning management systems to track completion', false, 'Completion tracking alone does not accelerate improvement.', 'Measurement'),
  ('B', 'Dashboards that make student progress visible and actionable for teachers', true, 'Dashboards enable rapid cycles of data-informed teaching refinement.', 'Digital'),
  ('C', 'Email systems for distributing assessment results', false, 'One-way distribution lacks the interactivity needed for acceleration.', 'Interaction'),
  ('D', 'Software that replaces teacher judgment with automated recommendations', false, 'Tools should augment teacher wisdom, not replace it.', 'Partnership')
) AS o(letter, text, correct, rationale, principle)
WHERE q.order_number = 11;

-- Question 12 Options (Order 12)
INSERT INTO public.options (question_id, option_letter, option_text, is_correct, rationale, principle_tag)
SELECT q.id, o.letter, o.text, o.correct, o.rationale, o.principle
FROM mcq_questions q,
(VALUES
  ('A', 'They replace the need for observational coaching', false, 'Digital tools support but do not replace human coaching relationships.', 'Balance'),
  ('B', 'They provide coaches with quick access to data to inform conversations', true, 'Data dashboards accelerate coaching cycles and depth of inquiry.', 'Acceleration'),
  ('C', 'They should be used instead of direct teacher observation', false, 'Direct observation remains central to coaching.', 'Observation'),
  ('D', 'They focus only on compliance rather than growth', false, 'Modern dashboards target growth, not compliance.', 'Growth')
) AS o(letter, text, correct, rationale, principle)
WHERE q.order_number = 12;

-- Question 13 Options (Order 13 - Module 5)
INSERT INTO public.options (question_id, option_letter, option_text, is_correct, rationale, principle_tag)
SELECT q.id, o.letter, o.text, o.correct, o.rationale, o.principle
FROM mcq_questions q,
(VALUES
  ('A', 'It allows teachers to practice many skills at once', false, 'Simultaneous practice of multiple skills creates cognitive overload.', 'Learning'),
  ('B', 'It focuses coaching on discrete, observable behaviors that teachers can master independently', true, 'Micro-skill isolation enables focused practice and mastery.', 'Mastery'),
  ('C', 'It simplifies lessons to make them less rigorous', false, 'Micro-skills support sophisticated, nuanced teaching.', 'Rigor'),
  ('D', 'It reduces the need for ongoing professional development', false, 'Micro-skills are building blocks within continuous improvement systems.', 'Development')
) AS o(letter, text, correct, rationale, principle)
WHERE q.order_number = 13;

-- Question 14 Options (Order 14)
INSERT INTO public.options (question_id, option_letter, option_text, is_correct, rationale, principle_tag)
SELECT q.id, o.letter, o.text, o.correct, o.rationale, o.principle
FROM mcq_questions q,
(VALUES
  ('A', 'It ensures the coach maintains control of the improvement process', false, 'The coach facilitates; the teacher owns the process.', 'Agency'),
  ('B', 'Loop 1 (Observe) → Loop 2 (Analyze) → Loop 3 (Plan) creates systematic improvement cycles', true, '3 Loops provide structure for observation, analysis, and action planning.', 'Structure'),
  ('C', 'It requires coaches to tell teachers what to do', false, 'Loops support inquiry and teacher-led decision-making.', 'Agency'),
  ('D', 'It bypasses the need for partnership', false, '3 Loops only work when embedded in strong partnerships.', 'Partnership')
) AS o(letter, text, correct, rationale, principle)
WHERE q.order_number = 14;

-- Question 15 Options (Order 15)
INSERT INTO public.options (question_id, option_letter, option_text, is_correct, rationale, principle_tag)
SELECT q.id, o.letter, o.text, o.correct, o.rationale, o.principle
FROM mcq_questions q,
(VALUES
  ('A', 'When the teacher is not confident or skilled in a technique', true, 'Side-by-side modeling provides the teacher with a live reference and scaffold.', 'Support'),
  ('B', 'Only during formal professional development sessions', false, 'Co-modeling is most powerful when embedded in real classroom contexts.', 'Context'),
  ('C', 'When coaches have more experience than teachers', false, 'Co-modeling is about supporting skill-building, not demonstrating superiority.', 'Humility'),
  ('D', 'Never, because it disrupts classroom instruction', false, 'Well-timed co-modeling enriches classroom learning.', 'Classroom')
) AS o(letter, text, correct, rationale, principle)
WHERE q.order_number = 15;

-- Question 16 Options (Order 16)
INSERT INTO public.options (question_id, option_letter, option_text, is_correct, rationale, principle_tag)
SELECT q.id, o.letter, o.text, o.correct, o.rationale, o.principle
FROM mcq_questions q,
(VALUES
  ('A', 'It identifies what teaching practices cause student learning gaps', true, 'Root-cause analysis pinpoints specific instructional levers for improvement.', 'Analysis'),
  ('B', 'It focuses blame on teachers for student underperformance', false, 'RCA is solutions-focused, not blame-focused.', 'Solutions'),
  ('C', 'It replaces the need for professional development', false, 'RCA often reveals specific PD needs.', 'Development'),
  ('D', 'It only works for struggling students', false, 'RCA applies to all levels of student and teacher performance.', 'Universal')
) AS o(letter, text, correct, rationale, principle)
WHERE q.order_number = 16;

-- Verify: Count questions and options
SELECT 'Endline Assessment Setup Complete' as status;
SELECT COUNT(*) as total_questions FROM public.questions
WHERE assessment_id = (SELECT id FROM public.assessments WHERE type = 'endline');
SELECT COUNT(*) as total_options FROM public.options
WHERE question_id IN (
  SELECT id FROM public.questions
  WHERE assessment_id = (SELECT id FROM public.assessments WHERE type = 'endline')
);
