-- =============================================================================
-- Module 1 Quiz Rebuild — Forward Migration
-- Date: 2026-04-28
-- Author: Claude / Jalal
--
-- Purpose:
--   Replace ALL Module 1 quiz questions with the official Question Bank:
--     - 42 MCQs (6 per unit × 7 units, ordered 1..6 within each unit)
--     - 7 scenario questions (ordered 17..23, distributed across units)
--   ModuleQuiz.tsx randomly picks 16 MCQs (distributed across units) + 4
--   scenarios from this bank.
--
-- Strategy:
--   1) Snapshot existing Module 1 questions/options into backup tables
--      (so rollback can restore exactly what was there).
--   2) Delete all existing Module 1 quiz questions (CASCADE deletes options).
--   3) Insert 42 MCQs and 7 scenarios with their options.
--   4) Verify counts match expectations; raise exception if not.
--
-- Mapping (Option B — by order_number, no rename of trainings):
--   doc Unit 1.0 → training.order_number = 1  (Coaching Catalyst MCQs)
--   doc Unit 1.1 → training.order_number = 2  (Partnership Posture MCQs)
--   doc Unit 1.2 → training.order_number = 3  (Shared Mirror MCQs)
--   doc Unit 1.3 → training.order_number = 4  (Growth Engine MCQs)
--   doc Unit 1.4 → training.order_number = 5  (Trust Bridge MCQs)
--   doc Unit 1.5 → training.order_number = 6  (Human Filter MCQs)
--   doc Unit 1.6 → training.order_number = 7  (Coding the Classroom MCQs)
--
--   Some order_numbers have multiple trainings (legacy duplicates). We pick the
--   training whose title matches the doc unit name; if no match, we fall back to
--   the lowest training id at that order_number (stable, deterministic).
--
-- Scenario assessment_id assignment (unchanged from prior design):
--   Q17 → unit order 1, Q18 → unit 2, Q19 → unit 3, Q20 → unit 4,
--   Q21 → unit 5,       Q22 → unit 6, Q23 → unit 7.
--
-- Run this in Supabase Studio SQL Editor on staging.
-- If anything fails, the entire transaction rolls back automatically.
-- =============================================================================

BEGIN;

-- -----------------------------------------------------------------------------
-- Step 0: Resolve module_id for Module 1 (order_number = 1)
-- -----------------------------------------------------------------------------
DO $$
DECLARE
  v_module_id uuid;
BEGIN
  SELECT id INTO v_module_id FROM public.modules WHERE order_number = 1 LIMIT 1;
  IF v_module_id IS NULL THEN
    RAISE EXCEPTION 'Module 1 not found (modules.order_number = 1). Aborting.';
  END IF;
END $$;

-- -----------------------------------------------------------------------------
-- Step 0.5: Ensure questions.question_type CHECK allows 'scenario'.
--   Older environments (e.g. staging) may have only ('mcq','open').
--   Drop and recreate the constraint to include 'scenario'.
-- -----------------------------------------------------------------------------
ALTER TABLE public.questions
  DROP CONSTRAINT IF EXISTS questions_question_type_check;

ALTER TABLE public.questions
  ADD CONSTRAINT questions_question_type_check
  CHECK (question_type IN ('mcq', 'open', 'scenario'));

-- -----------------------------------------------------------------------------
-- Step 1: Create backup tables (snapshot existing state)
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS public.backup_module1_questions_20260428;
DROP TABLE IF EXISTS public.backup_module1_options_20260428;

CREATE TABLE public.backup_module1_questions_20260428 AS
SELECT q.*
FROM public.questions q
JOIN public.assessments a ON a.id = q.assessment_id
JOIN public.trainings t ON t.id = a.training_id
WHERE t.module_id = (SELECT id FROM public.modules WHERE order_number = 1 LIMIT 1)
  AND a.type = 'module_quiz';

CREATE TABLE public.backup_module1_options_20260428 AS
SELECT o.*
FROM public.options o
WHERE o.question_id IN (
  SELECT id FROM public.backup_module1_questions_20260428
);

-- Hide backup tables from the PostgREST API so they aren't exposed to clients.
-- Postgres-owner / service_role can still SELECT for rollback.
REVOKE ALL ON public.backup_module1_questions_20260428 FROM anon, authenticated;
REVOKE ALL ON public.backup_module1_options_20260428   FROM anon, authenticated;

-- -----------------------------------------------------------------------------
-- Step 2: Delete all existing Module 1 quiz questions
--   Options are CASCADE-deleted via FK.
-- -----------------------------------------------------------------------------
DELETE FROM public.questions
WHERE assessment_id IN (
  SELECT a.id
  FROM public.assessments a
  JOIN public.trainings t ON t.id = a.training_id
  WHERE t.module_id = (SELECT id FROM public.modules WHERE order_number = 1 LIMIT 1)
    AND a.type = 'module_quiz'
);

-- -----------------------------------------------------------------------------
-- Step 3: Resolve assessment IDs for each Unit (by order_number)
--   For each order_number 1..7, pick the assessment whose training title contains
--   the canonical doc unit keyword; fallback to the lowest training id.
--   Result stored in a temp table for reuse.
-- -----------------------------------------------------------------------------
CREATE TEMP TABLE temp_unit_assessments (
  unit_order int PRIMARY KEY,
  unit_keyword text,
  training_id uuid,
  assessment_id uuid
) ON COMMIT DROP;

WITH module1 AS (
  SELECT id FROM public.modules WHERE order_number = 1 LIMIT 1
),
unit_targets AS (
  SELECT * FROM (VALUES
    (1, 'Coaching Catalyst'),
    (1, 'Partnership Posture'),
    (1, 'Impact Cycle Overview'),
    (2, 'Partnership Posture'),
    (2, 'Voice'),
    (2, 'Observation'),
    (3, 'Shared Mirror'),
    (3, 'Calibration'),
    (4, 'Growth Engine'),
    (4, 'Feedback'),
    (5, 'Trust Bridge'),
    (5, 'Action Steps'),
    (6, 'Human Filter'),
    (6, 'Documentation'),
    (7, 'Coding the Classroom'),
    (7, 'Habits')
  ) AS t(unit_order, unit_keyword)
),
ranked_trainings AS (
  SELECT
    t.id AS training_id,
    t.title,
    t.order_number AS unit_order,
    ut.unit_keyword,
    -- prefer matching titles in keyword priority order
    ROW_NUMBER() OVER (
      PARTITION BY t.order_number
      ORDER BY
        CASE
          WHEN t.title ILIKE '%' || ut.unit_keyword || '%' THEN 0
          ELSE 1
        END,
        t.id
    ) AS rn
  FROM public.trainings t
  JOIN unit_targets ut ON ut.unit_order = t.order_number
  WHERE t.module_id = (SELECT id FROM module1)
)
INSERT INTO temp_unit_assessments (unit_order, unit_keyword, training_id, assessment_id)
SELECT
  rt.unit_order,
  rt.unit_keyword,
  rt.training_id,
  a.id
FROM ranked_trainings rt
JOIN public.assessments a ON a.training_id = rt.training_id AND a.type = 'module_quiz'
WHERE rt.rn = 1
ON CONFLICT (unit_order) DO NOTHING;

-- Verify all 7 units have an assessment row
DO $$
DECLARE
  v_count int;
BEGIN
  SELECT COUNT(*) INTO v_count FROM temp_unit_assessments;
  IF v_count <> 7 THEN
    RAISE EXCEPTION 'Expected 7 unit assessments, found %. Aborting.', v_count;
  END IF;
END $$;

-- -----------------------------------------------------------------------------
-- Step 4: Helper function to insert one MCQ + 4 options
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pg_temp.insert_mcq(
  p_unit_order int,
  p_order_number int,
  p_question_text text,
  p_opt_a text,
  p_opt_b text,
  p_opt_c text,
  p_opt_d text,
  p_correct char  -- 'A', 'B', 'C', or 'D'
) RETURNS void AS $$
DECLARE
  v_assessment_id uuid;
  v_question_id uuid;
BEGIN
  SELECT assessment_id INTO v_assessment_id
  FROM temp_unit_assessments WHERE unit_order = p_unit_order;

  INSERT INTO public.questions (assessment_id, question_type, question_text, correct_answer, order_number)
  VALUES (v_assessment_id, 'mcq', p_question_text, p_correct, p_order_number)
  RETURNING id INTO v_question_id;

  INSERT INTO public.options (question_id, option_text, is_correct) VALUES
    (v_question_id, p_opt_a, p_correct = 'A'),
    (v_question_id, p_opt_b, p_correct = 'B'),
    (v_question_id, p_opt_c, p_correct = 'C'),
    (v_question_id, p_opt_d, p_correct = 'D');
END;
$$ LANGUAGE plpgsql;

-- Helper for scenarios (same structure, different question_type)
CREATE OR REPLACE FUNCTION pg_temp.insert_scenario(
  p_unit_order int,
  p_order_number int,
  p_question_text text,
  p_opt_a text,
  p_opt_b text,
  p_opt_c text,
  p_opt_d text,
  p_correct char
) RETURNS void AS $$
DECLARE
  v_assessment_id uuid;
  v_question_id uuid;
BEGIN
  SELECT assessment_id INTO v_assessment_id
  FROM temp_unit_assessments WHERE unit_order = p_unit_order;

  INSERT INTO public.questions (assessment_id, question_type, question_text, correct_answer, order_number)
  VALUES (v_assessment_id, 'scenario', p_question_text, p_correct, p_order_number)
  RETURNING id INTO v_question_id;

  INSERT INTO public.options (question_id, option_text, is_correct) VALUES
    (v_question_id, p_opt_a, p_correct = 'A'),
    (v_question_id, p_opt_b, p_correct = 'B'),
    (v_question_id, p_opt_c, p_correct = 'C'),
    (v_question_id, p_opt_d, p_correct = 'D');
END;
$$ LANGUAGE plpgsql;

-- =============================================================================
-- Step 5: INSERT MCQs (42 total: 6 per unit × 7 units)
-- =============================================================================

-- ----- UNIT 1.0: THE COACHING CATALYST (unit_order=1, MCQ order 1..6) -----

SELECT pg_temp.insert_mcq(1, 1,
  'What is the primary definition of coaching in this module?',
  'A formal audit',
  'A supportive partnership',
  'An inspection',
  'A salary review',
  'B');

SELECT pg_temp.insert_mcq(1, 2,
  'The "Implementation Gap" refers to:',
  'The distance between the school and the district office.',
  'The gap between learning a theory and applying it in the classroom.',
  'A lack of textbooks for students.',
  'Teachers being absent from work.',
  'B');

SELECT pg_temp.insert_mcq(1, 3,
  'How is the coaching relationship different from Inspection?',
  'Coaching is hierarchical.',
  'Coaching is a partnership of equals.',
  'Inspection is growth-focused.',
  'There is no difference.',
  'B');

SELECT pg_temp.insert_mcq(1, 4,
  'In the "Co-Pilot" mindset, who navigates the path toward growth?',
  'Coach alone',
  'Coach and Teacher together',
  'Principal alone',
  'Students',
  'B');

SELECT pg_temp.insert_mcq(1, 5,
  'Why is coaching frequency more important than intensity?',
  'To complete paperwork faster.',
  'To solidify new habits through consistent support.',
  'To ensure the teacher is always afraid of a visit.',
  'To meet a monthly quota for the principal.',
  'B');

SELECT pg_temp.insert_mcq(1, 6,
  'What is the "Tone" of a Catalyst coach?',
  'Evaluative and strict',
  'Supportive and constructive',
  'Critical and loud',
  'Silent and mysterious',
  'B');

-- ----- UNIT 1.1: THE PARTNERSHIP POSTURE (unit_order=2, MCQ order 1..6) -----

SELECT pg_temp.insert_mcq(2, 1,
  'What is the first step in the 4-step observation-to-conversation flow?',
  'Ask',
  'Observe',
  'Co-interpret',
  'Set Steps',
  'B');

SELECT pg_temp.insert_mcq(2, 2,
  'The "Choice" principle means:',
  'Teachers can choose not to be coached at all.',
  'Teachers have a say in their professional goals and actions.',
  'The coach chooses the teacher''s desk arrangement.',
  'The principal chooses the lesson plan for the coach.',
  'B');

SELECT pg_temp.insert_mcq(2, 3,
  'What is the "Expert Trap"?',
  'Being too smart for the classroom.',
  'Dominating the conversation and giving answers instead of listening.',
  'Falling for a teacher''s excuse.',
  'Using too much technology.',
  'B');

SELECT pg_temp.insert_mcq(2, 4,
  '"Reciprocity" in partnership means:',
  'The teacher pays the coach.',
  'The coach learns from the teacher just as the teacher learns from the coach.',
  'Both people arrive at the same time.',
  'Swapping classrooms for a day.',
  'B');

SELECT pg_temp.insert_mcq(2, 5,
  'Which behavior is a hallmark of "Equality" in coaching?',
  'Telling the teacher what they did wrong immediately.',
  'Sitting side-by-side to review data.',
  'Standing at the back of the room with a clipboard.',
  'Sending a report to the principal before talking to the teacher.',
  'B');

SELECT pg_temp.insert_mcq(2, 6,
  'In the 4-step flow, what happens during "Co-interpretation"?',
  'The coach gives a grade.',
  'Both partners look at evidence to find meaning together.',
  'The teacher remains silent.',
  'The coach writes the final report.',
  'B');

-- ----- UNIT 1.2: THE SHARED MIRROR (unit_order=3, MCQ order 1..6) -----

SELECT pg_temp.insert_mcq(3, 1,
  'The Shared Mirror technique aims to present data as:',
  'A final verdict',
  'A neutral starting point for discovery',
  'A list of teacher mistakes',
  'A report for the district',
  'B');

SELECT pg_temp.insert_mcq(3, 2,
  'Which is a "Low-Inference" statement?',
  '"You were very energetic today."',
  '"You asked 4 open-ended questions in the first 10 minutes."',
  '"The students seemed to love the lesson."',
  '"The classroom was a bit messy."',
  'B');

SELECT pg_temp.insert_mcq(3, 3,
  'What is the danger of "High-Inference" feedback?',
  'It is too specific.',
  'It triggers defensiveness because it is subjective.',
  'It takes too long to write.',
  'It uses too many numbers.',
  'B');

SELECT pg_temp.insert_mcq(3, 4,
  'A "Neutral Third Party" in a coaching conversation is:',
  'The Principal',
  'The Data/Evidence',
  'A student',
  'Another coach',
  'B');

SELECT pg_temp.insert_mcq(3, 5,
  '"Time-stamping" data helps by:',
  'Proving the coach stayed for the whole lesson.',
  'Providing an objective timeline for the teacher to reflect on.',
  'Helping the school track attendance.',
  'Making the notes look professional.',
  'B');

SELECT pg_temp.insert_mcq(3, 6,
  'When using the Shared Mirror, where should the coach sit?',
  'Directly across from the teacher.',
  'Side-by-side with the teacher.',
  'Behind the teacher.',
  'In the teacher''s chair.',
  'B');

-- ----- UNIT 1.3: THE GROWTH ENGINE (unit_order=4, MCQ order 1..6) -----

SELECT pg_temp.insert_mcq(4, 1,
  'The Growth Engine (4-step cycle) is designed to operationalize:',
  'The teacher''s contract',
  'The Impact Cycle (Identify/Learn/Improve)',
  'The school''s annual plan',
  'The district''s audit',
  'B');

SELECT pg_temp.insert_mcq(4, 2,
  'What makes an Action Step "bite-sized"?',
  'It can be done in one minute.',
  'It is a small, specific change that can be mastered in 1-2 weeks.',
  'It is written in small font.',
  'It only involves one student.',
  'B');

SELECT pg_temp.insert_mcq(4, 3,
  '"Closing the Loop" means:',
  'Finishing the conversation.',
  'Returning in 2 weeks to see the progress of the agreed action step.',
  'Turning off the coaching app.',
  'Ending the coaching relationship.',
  'B');

SELECT pg_temp.insert_mcq(4, 4,
  'Who should ideally choose the final action step?',
  'The Coach',
  'The Teacher',
  'The Principal',
  'The Students',
  'B');

SELECT pg_temp.insert_mcq(4, 5,
  'In the Growth Engine, "Evidence" serves as:',
  'Proof for a punishment.',
  'The foundation for the next action step.',
  'A way to fill up the coaching notebook.',
  'A secret for the principal.',
  'B');

SELECT pg_temp.insert_mcq(4, 6,
  'The "Improve" phase of the cycle focuses on:',
  'Finding new teachers.',
  'Iterating and adjusting based on the previous action step.',
  'Increasing the teacher''s salary.',
  'Testing students again.',
  'B');

-- ----- UNIT 1.4: THE TRUST BRIDGE (unit_order=5, MCQ order 1..6) -----

SELECT pg_temp.insert_mcq(5, 1,
  'What are the 4 Pillars of the ethical coaching framework?',
  'Fast, Free, Firm, Fair',
  'Trust, Confidentiality, Accountability, Integrity',
  'Watch, Write, Talk, Teach',
  'Record, Report, Review, Reset',
  'B');

SELECT pg_temp.insert_mcq(5, 2,
  'If confidentiality is broken, what is the result?',
  'The teacher works harder.',
  'The coaching relationship "dies" and teachers close off.',
  'The principal gets better data.',
  'Nothing happens.',
  'B');

SELECT pg_temp.insert_mcq(5, 3,
  'What is "Implicit" trust?',
  'Trust built through a contract.',
  'Trust built through consistent, predictable actions over time.',
  'Trust you have because you are a coach.',
  'Trust based on a friendship.',
  'B');

SELECT pg_temp.insert_mcq(5, 4,
  'Accountability in partnership coaching means:',
  'Teachers are punished for low scores.',
  'Both coach and teacher are accountable to the agreed-upon growth goals.',
  'The coach reports the teacher to the principal.',
  'The district tracks every word said in a session.',
  'B');

SELECT pg_temp.insert_mcq(5, 5,
  'When a principal asks for specific coaching notes, a coach should:',
  'Hand them over immediately.',
  'Hold the boundary and offer school-wide trends instead.',
  'Lie and say there are no notes.',
  'Tell the teacher to give the notes.',
  'B');

SELECT pg_temp.insert_mcq(5, 6,
  'Integrity in coaching is defined as:',
  'Being the smartest person in the room.',
  'Consistently following through on partnership principles even under pressure.',
  'Making sure the teacher likes you.',
  'Following the school''s dress code.',
  'B');

-- ----- UNIT 1.5: THE HUMAN FILTER (unit_order=6, MCQ order 1..6) -----

SELECT pg_temp.insert_mcq(6, 1,
  'The "Human Filter" concept means:',
  'Replacing the coach with a better computer.',
  'The coach must validate and contextualize AI suggestions before using them.',
  'Using a filter to make coaching videos look better.',
  'Only using AI for grammar checks.',
  'B');

SELECT pg_temp.insert_mcq(6, 2,
  'What are the 3 questions in the AI validation framework?',
  'Is it right? Is it fast? Is it easy?',
  'Context? Bias? Partnership?',
  'How much? Where from? Who said?',
  'AI or Human? Teacher or Coach? Yes or No?',
  'B');

SELECT pg_temp.insert_mcq(6, 3,
  '"Cultural Blindness" in AI can lead to:',
  'Faster coaching reports.',
  'Suggestions that don''t fit the local classroom context or values.',
  'Better student grades.',
  'The computer crashing.',
  'B');

SELECT pg_temp.insert_mcq(6, 4,
  'AI provides "Data Patterns," but the human coach provides:',
  'More data.',
  'Context and meaning.',
  'The final grade.',
  'Permission to work.',
  'B');

SELECT pg_temp.insert_mcq(6, 5,
  'Why should you check AI for "Deficit Framing"?',
  'AI likes to talk about strengths too much.',
  'AI often focuses only on what is wrong rather than growth opportunities.',
  'To save money.',
  'To make the report longer.',
  'B');

SELECT pg_temp.insert_mcq(6, 6,
  'If an AI suggests a teacher is "unprofessional" based on data, the coach should:',
  'Tell the teacher they are unprofessional.',
  'Override the AI and look for the human context behind the data.',
  'Report it to the district.',
  'Delete the AI.',
  'B');

-- ----- UNIT 1.6: CODING THE CLASSROOM (unit_order=7, MCQ order 1..6) -----

SELECT pg_temp.insert_mcq(7, 1,
  'In the schema, "I Do" refers to:',
  'Student practice.',
  'Teacher modeling and direct instruction.',
  'Peer review.',
  'The coach teaching.',
  'B');

SELECT pg_temp.insert_mcq(7, 2,
  '"We Do" is also known as:',
  'Lecture',
  'Guided Practice',
  'Homework',
  'Final Exam',
  'B');

SELECT pg_temp.insert_mcq(7, 3,
  'What is the primary purpose of CFU (Check for Understanding)?',
  'To give a grade.',
  'To gather real-time data to decide whether to pivot or proceed.',
  'To see who is sleeping.',
  'To end the lesson early.',
  'B');

SELECT pg_temp.insert_mcq(7, 4,
  '"You Do" is the phase where:',
  'The teacher works alone.',
  'Students practice independently to demonstrate mastery.',
  'The principal visits.',
  'The class watches a video.',
  'B');

SELECT pg_temp.insert_mcq(7, 5,
  'The Schema is a tool for:',
  'Judging lesson quality.',
  'Describing lesson structure to spark dialogue.',
  'Filling out the annual review.',
  'Telling a teacher they are bad at timing.',
  'B');

SELECT pg_temp.insert_mcq(7, 6,
  'A "Pivot" in a lesson occurs when:',
  'The teacher turns around.',
  'The teacher changes instruction based on student feedback/CFU.',
  'The bell rings.',
  'The students go to lunch.',
  'B');

-- =============================================================================
-- Step 6: INSERT Scenarios (7 total, order_number 17..23)
-- =============================================================================

-- Scenario 1 (Unit 1.0 & 1.1) → unit_order=1
SELECT pg_temp.insert_scenario(1, 17,
  E'Unit 1.0 & 1.1: The Partnership Posture\n\nScenario: You are coaching a veteran teacher, Mr. Khan, who is hesitant about your visit. He says, "I''ve been teaching for 20 years; I don''t need an auditor telling me what I''m doing wrong." Which response best demonstrates the shift from "Judge" to "Co-Pilot"?',
  'I''m not here to audit; I''m here to give you a list of modern techniques to improve your job.',
  'I''m not here to find faults. I want to sit side-by-side with you so we can look at classroom data together and work toward goals you care about.',
  'The district requires these visits, but I promise to be a ''nice'' judge and only give positive feedback.',
  'Think of me as a friend who is going to tell you exactly how to fix your classroom management.',
  'B');

-- Scenario 2 (Unit 1.0 & 1.1 — Voice) → unit_order=2
SELECT pg_temp.insert_scenario(2, 18,
  E'Unit 1.0 & 1.1: The Partnership Posture\n\nScenario: During a debrief, a coach notices the teacher is being very quiet. The coach decides to stop talking and asks the teacher, "What did you notice about the students'' reactions during the group work?" This best illustrates the importance of "Voice" because:',
  'It saves the coach''s voice from getting tired during a busy day.',
  'It empowers the teacher to take ownership of their own growth and perspective.',
  'It forces the teacher to prove they were paying attention during the lesson.',
  'It allows the coach to see if the teacher knows the "correct" answer.',
  'B');

-- Scenario 3 (Unit 1.2: The Shared Mirror) → unit_order=3
SELECT pg_temp.insert_scenario(3, 19,
  E'Unit 1.2: The Shared Mirror\n\nScenario: You are sitting with a teacher to review a lesson. You have a choice of how to present your notes. Which approach best utilizes the "Shared Mirror" technique?',
  'Standing at the front of the room while the teacher sits, reading your summary of their mistakes.',
  'Sitting side-by-side at a table, placing a sheet of objective, low-inference data between both of you.',
  'Sending an email with "High-Inference" adjectives like "The lesson was a bit messy."',
  'Keeping your notes private and only telling the teacher what the Principal needs to see.',
  'B');

-- Scenario 4 (Unit 1.3: The Growth Engine) → unit_order=4
SELECT pg_temp.insert_scenario(4, 20,
  E'Unit 1.3: The Growth Engine\n\nScenario: A teacher is feeling overwhelmed by low test scores. To build "Momentum and Trust," the coach suggests focusing on one "bite-sized" action step: "Greeting every student at the door by name for one week." Why is this considered a "Quick Win"?',
  'Because it is a fast way for the coach to finish the meeting and leave the school.',
  'It builds immediate confidence and success, proving that small changes lead to growth.',
  'It ensures the teacher is following the school''s administrative rules perfectly.',
  'It is the only thing the teacher is currently capable of doing correctly.',
  'B');

-- Scenario 5 (Unit 1.4: The Trust Bridge) → unit_order=5  (correct answer = C)
SELECT pg_temp.insert_scenario(5, 21,
  E'Unit 1.4: The Trust Bridge\n\nScenario: The Principal asks you, "So, how is Ms. Sarah doing? I need to know if I should put her on a performance plan." According to the "Trust Bridge," how should you handle this boundary of confidentiality?',
  'Share Sarah''s specific struggles so the Principal can help "fix" her.',
  'Tell the Principal you can''t talk because it''s a secret, which creates a wall between you and leadership.',
  'Frame the coaching space as a professional safe space and offer to share school-wide trends instead of individual notes.',
  'Show the Principal the notes but ask them not to tell Sarah that you shared them.',
  'C');

-- Scenario 6 (Unit 1.5: The Human Filter) → unit_order=6
SELECT pg_temp.insert_scenario(6, 22,
  E'Unit 1.5: The Human Filter\n\nScenario: An AI coaching tool analyzes a video of a classroom and flags "5 minutes of student silence" as a negative "lack of engagement." As the "Human Filter," you know the teacher was intentionally using "Wait Time" for a complex math problem. Your best action is:',
  'Accept the AI''s data and tell the teacher to speed up the lesson.',
  'Override the AI''s suggestion by applying context and recognizing the intentionality of the teacher''s silence.',
  'Report the AI''s finding to the district as a sign of poor classroom management.',
  'Delete the AI tool because it is clearly broken and doesn''t understand data.',
  'B');

-- Scenario 7 (Unit 1.6: Coding the Classroom) → unit_order=7
SELECT pg_temp.insert_scenario(7, 23,
  E'Unit 1.6: Coding the Classroom\n\nScenario: A teacher moves directly from a 20-minute lecture ("I Do") to an independent worksheet ("You Do"). The students immediately become confused and stop working. In the follow-up, you use the Schema data to show the teacher that the "We Do" phase was missing. Why is this phase a "critical bridge"?',
  'It is the time when the teacher can sit down and grade papers.',
  'It provides the scaffolding and safe-to-fail practice students need before working alone.',
  'It is the fastest part of the lesson and should always be skipped if time is short.',
  'It is only used for students who are failing the class.',
  'B');

-- =============================================================================
-- Step 7: Verification — fail the transaction if counts are wrong
-- =============================================================================
DO $$
DECLARE
  v_module_id uuid := (SELECT id FROM public.modules WHERE order_number = 1 LIMIT 1);
  v_mcq_count int;
  v_scenario_count int;
  v_option_count int;
  v_correct_count int;
BEGIN
  SELECT COUNT(*) INTO v_mcq_count
  FROM public.questions q
  JOIN public.assessments a ON a.id = q.assessment_id
  JOIN public.trainings t ON t.id = a.training_id
  WHERE t.module_id = v_module_id
    AND a.type = 'module_quiz'
    AND q.question_type = 'mcq';

  SELECT COUNT(*) INTO v_scenario_count
  FROM public.questions q
  JOIN public.assessments a ON a.id = q.assessment_id
  JOIN public.trainings t ON t.id = a.training_id
  WHERE t.module_id = v_module_id
    AND a.type = 'module_quiz'
    AND q.question_type = 'scenario';

  SELECT COUNT(*) INTO v_option_count
  FROM public.options o
  JOIN public.questions q ON q.id = o.question_id
  JOIN public.assessments a ON a.id = q.assessment_id
  JOIN public.trainings t ON t.id = a.training_id
  WHERE t.module_id = v_module_id
    AND a.type = 'module_quiz';

  SELECT COUNT(*) INTO v_correct_count
  FROM public.options o
  JOIN public.questions q ON q.id = o.question_id
  JOIN public.assessments a ON a.id = q.assessment_id
  JOIN public.trainings t ON t.id = a.training_id
  WHERE t.module_id = v_module_id
    AND a.type = 'module_quiz'
    AND o.is_correct = true;

  RAISE NOTICE 'Module 1 quiz: % MCQs, % scenarios, % options (% correct)',
    v_mcq_count, v_scenario_count, v_option_count, v_correct_count;

  IF v_mcq_count <> 42 THEN
    RAISE EXCEPTION 'Expected 42 MCQs, found %. Aborting.', v_mcq_count;
  END IF;
  IF v_scenario_count <> 7 THEN
    RAISE EXCEPTION 'Expected 7 scenarios, found %. Aborting.', v_scenario_count;
  END IF;
  IF v_option_count <> (42 + 7) * 4 THEN
    RAISE EXCEPTION 'Expected % options, found %. Aborting.', (42 + 7) * 4, v_option_count;
  END IF;
  IF v_correct_count <> (42 + 7) THEN
    RAISE EXCEPTION 'Expected % correct options (one per question), found %. Aborting.',
      (42 + 7), v_correct_count;
  END IF;

  RAISE NOTICE 'All checks passed. Committing transaction.';
END $$;

COMMIT;

-- -----------------------------------------------------------------------------
-- Final summary (read-only, runs after commit)
-- -----------------------------------------------------------------------------
SELECT 'BACKUP TABLES' AS info;
SELECT 'backup_module1_questions_20260428' AS table_name, COUNT(*) AS row_count
FROM public.backup_module1_questions_20260428
UNION ALL
SELECT 'backup_module1_options_20260428', COUNT(*)
FROM public.backup_module1_options_20260428;

SELECT 'NEW STATE — questions per unit' AS info;
SELECT
  t.order_number AS unit_order,
  t.title AS unit_title,
  COUNT(*) FILTER (WHERE q.question_type = 'mcq') AS mcq_count,
  COUNT(*) FILTER (WHERE q.question_type = 'scenario') AS scenario_count
FROM public.questions q
JOIN public.assessments a ON a.id = q.assessment_id
JOIN public.trainings t ON t.id = a.training_id
WHERE t.module_id = (SELECT id FROM public.modules WHERE order_number = 1 LIMIT 1)
  AND a.type = 'module_quiz'
GROUP BY t.id, t.order_number, t.title
ORDER BY t.order_number, t.title;
