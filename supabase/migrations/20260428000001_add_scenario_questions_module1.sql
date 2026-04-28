-- Add scenario questions to Module 1 quiz and remove open-ended questions
-- Widen question_type CHECK constraint to support 'scenario'

-- Step 1: Widen CHECK constraint on question_type
ALTER TABLE public.questions DROP CONSTRAINT IF EXISTS questions_question_type_check;
ALTER TABLE public.questions ADD CONSTRAINT questions_question_type_check
  CHECK (question_type IN ('mcq', 'open', 'scenario'));

-- Step 2: Delete open-ended questions for Module 1
DELETE FROM public.questions
WHERE question_type = 'open'
  AND assessment_id IN (
    SELECT a.id FROM public.assessments a
    JOIN public.trainings t ON a.training_id = t.id
    JOIN public.modules m ON t.module_id = m.id
    WHERE m.order_number = 1 AND a.type = 'module_quiz'
  );

-- Step 3: Insert 7 scenario questions for Module 1
-- Using CTE pattern to find Module 1 quiz assessments

WITH module1_assessments AS (
  SELECT a.id FROM public.assessments a
  JOIN public.trainings t ON a.training_id = t.id
  JOIN public.modules m ON t.module_id = m.id
  WHERE m.order_number = 1 AND a.type = 'module_quiz'
)

-- Scenario 1: The Partnership Posture
INSERT INTO public.questions (assessment_id, question_type, question_text, correct_answer, order_number, module_id)
SELECT id, 'scenario',
  'Unit 1.0 & 1.1: The Partnership Posture

Scenario: You are coaching a veteran teacher, Mr. Khan, who is hesitant about your visit. He says, "I''ve been teaching for 20 years; I don''t need an auditor telling me what I''m doing wrong." Which response best demonstrates the shift from "Judge" to "Co-Pilot"?',
  'B', 17, (SELECT id FROM public.modules WHERE order_number = 1)
FROM module1_assessments
WHERE NOT EXISTS (
  SELECT 1 FROM public.questions q
  WHERE q.question_type = 'scenario' AND q.order_number = 17
    AND q.assessment_id IN (SELECT id FROM module1_assessments)
);

-- Scenario 1 Options
WITH scenario1_q AS (
  SELECT q.id FROM public.questions q
  WHERE q.question_type = 'scenario' AND q.question_text LIKE 'Unit 1.0 & 1.1%'
    AND q.question_text LIKE '%Mr. Khan%'
  LIMIT 1
)
INSERT INTO public.options (question_id, option_text, is_correct)
VALUES
  ((SELECT id FROM scenario1_q), 'I''m not here to audit; I''m here to give you a list of modern techniques to improve your job.', false),
  ((SELECT id FROM scenario1_q), 'I''m not here to find faults. I want to sit side-by-side with you so we can look at classroom data together and work toward goals you care about.', true),
  ((SELECT id FROM scenario1_q), 'The district requires these visits, but I promise to be a ''nice'' judge and only give positive feedback.', false),
  ((SELECT id FROM scenario1_q), 'Think of me as a friend who is going to tell you exactly how to fix your classroom management.', false);

-- Scenario 2: Voice (The Partnership Posture)
INSERT INTO public.questions (assessment_id, question_type, question_text, correct_answer, order_number, module_id)
SELECT id, 'scenario',
  'Unit 1.0 & 1.1: The Partnership Posture

Scenario: During a debrief, a coach notices the teacher is being very quiet. The coach decides to stop talking and asks the teacher, "What did you notice about the students'' reactions during the group work?" This best illustrates the importance of "Voice" because:',
  'B', 18, (SELECT id FROM public.modules WHERE order_number = 1)
FROM module1_assessments
WHERE NOT EXISTS (
  SELECT 1 FROM public.questions q
  WHERE q.question_type = 'scenario' AND q.order_number = 18
    AND q.assessment_id IN (SELECT id FROM module1_assessments)
);

WITH scenario2_q AS (
  SELECT q.id FROM public.questions q
  WHERE q.question_type = 'scenario' AND q.question_text LIKE '%What did you notice about the students%'
  LIMIT 1
)
INSERT INTO public.options (question_id, option_text, is_correct)
VALUES
  ((SELECT id FROM scenario2_q), 'It saves the coach''s voice from getting tired during a busy day.', false),
  ((SELECT id FROM scenario2_q), 'It empowers the teacher to take ownership of their own growth and perspective.', true),
  ((SELECT id FROM scenario2_q), 'It forces the teacher to prove they were paying attention during the lesson.', false),
  ((SELECT id FROM scenario2_q), 'It allows the coach to see if the teacher knows the "correct" answer.', false);

-- Scenario 3: The Shared Mirror
INSERT INTO public.questions (assessment_id, question_type, question_text, correct_answer, order_number, module_id)
SELECT id, 'scenario',
  'Unit 1.2: The Shared Mirror

Scenario: You are sitting with a teacher to review a lesson. You have a choice of how to present your notes. Which approach best utilizes the "Shared Mirror" technique?',
  'B', 19, (SELECT id FROM public.modules WHERE order_number = 1)
FROM module1_assessments
WHERE NOT EXISTS (
  SELECT 1 FROM public.questions q
  WHERE q.question_type = 'scenario' AND q.order_number = 19
    AND q.assessment_id IN (SELECT id FROM module1_assessments)
);

WITH scenario3_q AS (
  SELECT q.id FROM public.questions q
  WHERE q.question_type = 'scenario' AND q.question_text LIKE '%Shared Mirror%'
    AND q.question_text LIKE '%review a lesson%'
  LIMIT 1
)
INSERT INTO public.options (question_id, option_text, is_correct)
VALUES
  ((SELECT id FROM scenario3_q), 'Standing at the front of the room while the teacher sits, reading your summary of their mistakes.', false),
  ((SELECT id FROM scenario3_q), 'Sitting side-by-side at a table, placing a sheet of objective, low-inference data between both of you.', true),
  ((SELECT id FROM scenario3_q), 'Sending an email with "High-Inference" adjectives like "The lesson was a bit messy."', false),
  ((SELECT id FROM scenario3_q), 'Keeping your notes private and only telling the teacher what the Principal needs to see.', false);

-- Scenario 4: The Growth Engine
INSERT INTO public.questions (assessment_id, question_type, question_text, correct_answer, order_number, module_id)
SELECT id, 'scenario',
  'Unit 1.3: The Growth Engine

Scenario: A teacher is feeling overwhelmed by low test scores. To build "Momentum and Trust," the coach suggests focusing on one "bite-sized" action step: "Greeting every student at the door by name for one week." Why is this considered a "Quick Win"?',
  'B', 20, (SELECT id FROM public.modules WHERE order_number = 1)
FROM module1_assessments
WHERE NOT EXISTS (
  SELECT 1 FROM public.questions q
  WHERE q.question_type = 'scenario' AND q.order_number = 20
    AND q.assessment_id IN (SELECT id FROM module1_assessments)
);

WITH scenario4_q AS (
  SELECT q.id FROM public.questions q
  WHERE q.question_type = 'scenario' AND q.question_text LIKE '%Growth Engine%'
    AND q.question_text LIKE '%Greeting every student%'
  LIMIT 1
)
INSERT INTO public.options (question_id, option_text, is_correct)
VALUES
  ((SELECT id FROM scenario4_q), 'Because it is a fast way for the coach to finish the meeting and leave the school.', false),
  ((SELECT id FROM scenario4_q), 'It builds immediate confidence and success, proving that small changes lead to growth.', true),
  ((SELECT id FROM scenario4_q), 'It ensures the teacher is following the school''s administrative rules perfectly.', false),
  ((SELECT id FROM scenario4_q), 'It is the only thing the teacher is currently capable of doing correctly.', false);

-- Scenario 5: The Trust Bridge
INSERT INTO public.questions (assessment_id, question_type, question_text, correct_answer, order_number, module_id)
SELECT id, 'scenario',
  'Unit 1.4: The Trust Bridge

Scenario: The Principal asks you, "So, how is Ms. Sarah doing? I need to know if I should put her on a performance plan." According to the "Trust Bridge," how should you handle this boundary of confidentiality?',
  'C', 21, (SELECT id FROM public.modules WHERE order_number = 1)
FROM module1_assessments
WHERE NOT EXISTS (
  SELECT 1 FROM public.questions q
  WHERE q.question_type = 'scenario' AND q.order_number = 21
    AND q.assessment_id IN (SELECT id FROM module1_assessments)
);

WITH scenario5_q AS (
  SELECT q.id FROM public.questions q
  WHERE q.question_type = 'scenario' AND q.question_text LIKE '%Trust Bridge%'
    AND q.question_text LIKE '%Ms. Sarah%'
  LIMIT 1
)
INSERT INTO public.options (question_id, option_text, is_correct)
VALUES
  ((SELECT id FROM scenario5_q), 'Share Sarah''s specific struggles so the Principal can help "fix" her.', false),
  ((SELECT id FROM scenario5_q), 'Tell the Principal you can''t talk because it''s a secret, which creates a wall between you and leadership.', false),
  ((SELECT id FROM scenario5_q), 'Frame the coaching space as a professional safe space and offer to share school-wide trends instead of individual notes.', true),
  ((SELECT id FROM scenario5_q), 'Show the Principal the notes but ask them not to tell Sarah that you shared them.', false);

-- Scenario 6: The Human Filter
INSERT INTO public.questions (assessment_id, question_type, question_text, correct_answer, order_number, module_id)
SELECT id, 'scenario',
  'Unit 1.5: The Human Filter

Scenario: An AI coaching tool analyzes a video of a classroom and flags "5 minutes of student silence" as a negative "lack of engagement." As the "Human Filter," you know the teacher was intentionally using "Wait Time" for a complex math problem. Your best action is:',
  'B', 22, (SELECT id FROM public.modules WHERE order_number = 1)
FROM module1_assessments
WHERE NOT EXISTS (
  SELECT 1 FROM public.questions q
  WHERE q.question_type = 'scenario' AND q.order_number = 22
    AND q.assessment_id IN (SELECT id FROM module1_assessments)
);

WITH scenario6_q AS (
  SELECT q.id FROM public.questions q
  WHERE q.question_type = 'scenario' AND q.question_text LIKE '%Human Filter%'
    AND q.question_text LIKE '%student silence%'
  LIMIT 1
)
INSERT INTO public.options (question_id, option_text, is_correct)
VALUES
  ((SELECT id FROM scenario6_q), 'Accept the AI''s data and tell the teacher to speed up the lesson.', false),
  ((SELECT id FROM scenario6_q), 'Override the AI''s suggestion by applying context and recognizing the intentionality of the teacher''s silence.', true),
  ((SELECT id FROM scenario6_q), 'Report the AI''s finding to the district as a sign of poor classroom management.', false),
  ((SELECT id FROM scenario6_q), 'Delete the AI tool because it is clearly broken and doesn''t understand data.', false);

-- Scenario 7: Coding the Classroom
INSERT INTO public.questions (assessment_id, question_type, question_text, correct_answer, order_number, module_id)
SELECT id, 'scenario',
  'Unit 1.6: Coding the Classroom

Scenario: A teacher moves directly from a 20-minute lecture ("I Do") to an independent worksheet ("You Do"). The students immediately become confused and stop working. In the follow-up, you use the Schema data to show the teacher that the "We Do" phase was missing. Why is this phase a "critical bridge"?',
  'B', 23, (SELECT id FROM public.modules WHERE order_number = 1)
FROM module1_assessments
WHERE NOT EXISTS (
  SELECT 1 FROM public.questions q
  WHERE q.question_type = 'scenario' AND q.order_number = 23
    AND q.assessment_id IN (SELECT id FROM module1_assessments)
);

WITH scenario7_q AS (
  SELECT q.id FROM public.questions q
  WHERE q.question_type = 'scenario' AND q.question_text LIKE '%Coding the Classroom%'
    AND q.question_text LIKE '%We Do%'
  LIMIT 1
)
INSERT INTO public.options (question_id, option_text, is_correct)
VALUES
  ((SELECT id FROM scenario7_q), 'It is the time when the teacher can sit down and grade papers.', false),
  ((SELECT id FROM scenario7_q), 'It provides the scaffolding and safe-to-fail practice students need before working alone.', true),
  ((SELECT id FROM scenario7_q), 'It is the fastest part of the lesson and should always be skipped if time is short.', false),
  ((SELECT id FROM scenario7_q), 'It is only used for students who are failing the class.', false);
