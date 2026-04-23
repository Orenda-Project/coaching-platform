-- Reduce baseline assessment from 30 questions to 18 questions
-- New structure: 3 concept-based MCQs per module (6 modules = 18 questions total)
-- Based on RM feedback for improved user experience

DELETE FROM public.options WHERE question_id IN (
  SELECT id FROM public.questions WHERE assessment_id IN (
    SELECT id FROM public.assessments WHERE type = 'baseline'
  )
);

DELETE FROM public.questions WHERE assessment_id IN (
  SELECT id FROM public.assessments WHERE type = 'baseline'
);

DELETE FROM public.assessments WHERE type = 'baseline';

-- Recreate baseline assessment
INSERT INTO public.assessments (type, title)
VALUES ('baseline', 'Coach Baseline Assessment');

-- Insert 18 questions (3 per module, from Module 2-6 simplified version)
WITH baseline_assessment AS (
  SELECT id FROM public.assessments WHERE type = 'baseline' LIMIT 1
)
INSERT INTO public.questions (assessment_id, question_type, question_text, order_number)
SELECT
  (SELECT id FROM baseline_assessment),
  'mcq',
  q.question_text,
  q.row_num
FROM (
  -- Module 2: The Partnership Foundation (Trust & Status) - 3 questions
  SELECT 'According to the SCARF model, a veteran teacher who explicitly states they "do not need a coach" is primarily reacting to a perceived threat to their:' AS question_text, 1 AS row_num
  UNION ALL SELECT 'Case Study: A teacher reacts with "Freeze" behavior (passive compliance). Which Opening Script best uses the principles of Equality and Voice?' AS question_text, 2
  UNION ALL SELECT 'Case Study: During a feedback session, a teacher becomes defensive. To move to a "Side-by-Side" mindset, you should:' AS question_text, 3

  -- Module 3: The Mirror Specialist (Shared Reality) - 3 questions
  UNION ALL SELECT 'If a coach and teacher score the same lesson differently, this "Calibration Gap" is most often caused by:' AS question_text, 4
  UNION ALL SELECT 'Case Study: A teacher insists a class was "perfect," but data shows 0% passed the exit ticket. To achieve Calibration, you should:' AS question_text, 5
  UNION ALL SELECT 'Case Study: When taking a digital photo of student work, the "Voice" principle requires you to:' AS question_text, 6

  -- Module 4: Digital & Data Intelligence (Collaborative Analytics) - 3 questions
  UNION ALL SELECT 'Case Study: An AI dashboard suggests "Use digital tools for real-time feedback," but the school has a power outage. Following "Human Override," you should:' AS question_text, 7
  UNION ALL SELECT 'Case Study: A Principal displaces your coaching block with "Protocol Duty." Which Advocacy Script best protects your time and the program''s intent?' AS question_text, 8
  UNION ALL SELECT 'Case Study: A dashboard shows 100% task completion, but you observe students just copying from the board. You should:' AS question_text, 9
  UNION ALL SELECT 'To avoid the "Administrative After-Burn" (work piling up after the school day), a coach should:' AS question_text, 10

  -- Module 5: The Instructional Catalyst (Co-Design) - 4 questions
  UNION ALL SELECT 'A teacher explains a strategy perfectly but fails to use it in a noisy classroom. This indicates a:' AS question_text, 11
  UNION ALL SELECT 'Case Study: A teacher has students copy an entire textbook chapter. You identify the Belief Gap (Internal Rule) as:' AS question_text, 12
  UNION ALL SELECT 'Case Study: When a teacher has 8 distinct skill gaps, a "Catalyst" coach prioritizes:' AS question_text, 13
  UNION ALL SELECT 'In Side-by-Side Co-Modeling, the coach''s primary goal is to:' AS question_text, 14

  -- Module 6: The Excellence Loop (Reciprocity & Praxis) - 4 questions
  UNION ALL SELECT '"Responsive Contextualization" is a necessary coaching skill when:' AS question_text, 15
  UNION ALL SELECT 'The "Compliance Trap" occurs when coaching data shows that:' AS question_text, 16
  UNION ALL SELECT 'Case Study: A veteran teacher is skeptical of a new strategy. The most Reciprocal move is to:' AS question_text, 17
  UNION ALL SELECT 'Case Study: Why is Praxis (action-based learning) prioritized over "Abstract Theory"?' AS question_text, 18
) q;

-- Add options for each question based on the 18-question document
WITH baseline_assessment AS (
  SELECT id FROM public.assessments WHERE type = 'baseline' LIMIT 1
),
q1 AS (
  SELECT id FROM public.questions WHERE assessment_id = (SELECT id FROM baseline_assessment) AND order_number = 1
)
INSERT INTO public.options (question_id, option_text, is_correct, order_number)
SELECT (SELECT id FROM q1), opt.text, opt.correct, opt.ord FROM (
  SELECT 'Certainness and predictability of the professional environment.' AS text, FALSE AS correct, 1 AS ord
  UNION ALL SELECT 'Relatedness and belonging within the school''s peer network.' AS text, FALSE, 2
  UNION ALL SELECT 'Autonomy and the right to make independent classroom choices.' AS text, FALSE, 3
  UNION ALL SELECT 'Status and their standing as an established expert in the building.' AS text, TRUE, 4
) opt;

WITH baseline_assessment AS (
  SELECT id FROM public.assessments WHERE type = 'baseline' LIMIT 1
),
q2 AS (
  SELECT id FROM public.questions WHERE assessment_id = (SELECT id FROM baseline_assessment) AND order_number = 2
)
INSERT INTO public.options (question_id, option_text, is_correct, order_number)
SELECT (SELECT id FROM q2), opt.text, opt.correct, opt.ord FROM (
  SELECT 'I am here to help you improve your classroom management by sharing some expert tips.' AS text, FALSE AS correct, 1 AS ord
  UNION ALL SELECT 'I am here as a partner to learn alongside you; what is a specific goal you have today?' AS text, TRUE, 2
  UNION ALL SELECT 'The District Office requires me to audit this lesson for your annual performance tracking.' AS text, FALSE, 3
  UNION ALL SELECT 'I will be watching to see if you are following the standard manual instructions correctly.' AS text, FALSE, 4
) opt;

WITH baseline_assessment AS (
  SELECT id FROM public.assessments WHERE type = 'baseline' LIMIT 1
),
q3 AS (
  SELECT id FROM public.questions WHERE assessment_id = (SELECT id FROM baseline_assessment) AND order_number = 3
)
INSERT INTO public.options (question_id, option_text, is_correct, order_number)
SELECT (SELECT id FROM q3), opt.text, opt.correct, opt.ord FROM (
  SELECT 'Re-read the rubric to show them exactly where their performance failed to meet the goal.' AS text, FALSE AS correct, 1 AS ord
  UNION ALL SELECT 'Remind them that your role is to give expert advice that they must follow for the program.' AS text, FALSE, 2
  UNION ALL SELECT 'Physically sit next to them and look at student work together, asking "What do you see?"' AS text, TRUE, 3
  UNION ALL SELECT 'Suggest they observe a younger teacher who is more compliant with modern teaching methods.' AS text, FALSE, 4
) opt;

-- Q4: Calibration Gap
WITH baseline_assessment AS (
  SELECT id FROM public.assessments WHERE type = 'baseline' LIMIT 1
),
q4 AS (
  SELECT id FROM public.questions WHERE assessment_id = (SELECT id FROM baseline_assessment) AND order_number = 4
)
INSERT INTO public.options (question_id, option_text, is_correct, order_number)
SELECT (SELECT id FROM q4), opt.text, opt.correct, opt.ord FROM (
  SELECT 'Using subjective "feelings" or personal opinions instead of a shared mirror of objective facts.' AS text, TRUE AS correct, 1 AS ord
  UNION ALL SELECT 'One person being a "mean" grader while the other is trying to be "supportive" of the teacher.' AS text, FALSE, 2
  UNION ALL SELECT 'The rubric being too complex for the teacher to understand without significant prior training.' AS text, FALSE, 3
  UNION ALL SELECT 'The teacher acting differently toward the coach than they do when they are alone with students.' AS text, FALSE, 4
) opt;

-- Q5: Third Partner
WITH baseline_assessment AS (
  SELECT id FROM public.assessments WHERE type = 'baseline' LIMIT 1
),
q5 AS (
  SELECT id FROM public.questions WHERE assessment_id = (SELECT id FROM baseline_assessment) AND order_number = 5
)
INSERT INTO public.options (question_id, option_text, is_correct, order_number)
SELECT (SELECT id FROM q5), opt.text, opt.correct, opt.ord FROM (
  SELECT 'Argue the data points until the teacher admits their assessment of the class was incorrect.' AS text, FALSE AS correct, 1 AS ord
  UNION ALL SELECT 'Inform the Principal immediately that the teacher is in denial about their students'' progress.' AS text, FALSE, 2
  UNION ALL SELECT 'Introduce the "Third Partner" by looking at 5 randomly selected student notebooks together.' AS text, TRUE, 3
  UNION ALL SELECT 'Agree with them to maintain the relationship and try to address the issue during the next visit.' AS text, FALSE, 4
) opt;

-- Q6: Voice principle
WITH baseline_assessment AS (
  SELECT id FROM public.assessments WHERE type = 'baseline' LIMIT 1
),
q6 AS (
  SELECT id FROM public.questions WHERE assessment_id = (SELECT id FROM baseline_assessment) AND order_number = 6
)
INSERT INTO public.options (question_id, option_text, is_correct, order_number)
SELECT (SELECT id FROM q6), opt.text, opt.correct, opt.ord FROM (
  SELECT 'Take the photo silently to avoid distracting the class or interrupting the teacher''s lesson flow.' AS text, FALSE AS correct, 1 AS ord
  UNION ALL SELECT 'Only take photos of top-performing students to show the potential impact of the strategy.' AS text, FALSE, 2
  UNION ALL SELECT 'Send the photo to the Principal immediately for official validation and record keeping for the app.' AS text, FALSE, 3
  UNION ALL SELECT 'Use a permission script that names a specific learning curiosity you want to explore together.' AS text, TRUE, 4
) opt;

-- Q7: Human Override
WITH baseline_assessment AS (
  SELECT id FROM public.assessments WHERE type = 'baseline' LIMIT 1
),
q7 AS (
  SELECT id FROM public.questions WHERE assessment_id = (SELECT id FROM baseline_assessment) AND order_number = 7
)
INSERT INTO public.options (question_id, option_text, is_correct, order_number)
SELECT (SELECT id FROM q7), opt.text, opt.correct, opt.ord FROM (
  SELECT 'Postpone the visit until power is restored to maintain high fidelity to the AI''s recommendation.' AS text, FALSE AS correct, 1 AS ord
  UNION ALL SELECT 'Co-design a low-tech alternative (like "Colored Cards") that achieves the same pedagogical intent.' AS text, TRUE, 2
  UNION ALL SELECT 'Mark the visit as "Not Applicable" and move to the next teacher to avoid skewing the regional data.' AS text, FALSE, 3
  UNION ALL SELECT 'Instruct the teacher to explain the digital tool''s logic theoretically until the electricity returns.' AS text, FALSE, 4
) opt;

-- Q8: Advocacy Script
WITH baseline_assessment AS (
  SELECT id FROM public.assessments WHERE type = 'baseline' LIMIT 1
),
q8 AS (
  SELECT id FROM public.questions WHERE assessment_id = (SELECT id FROM baseline_assessment) AND order_number = 8
)
INSERT INTO public.options (question_id, option_text, is_correct, order_number)
SELECT (SELECT id FROM q8), opt.text, opt.correct, opt.ord FROM (
  SELECT 'My WRER is at 50%; if I miss this, Teacher Sara waits 7 days for feedback, risking kids.' AS text, TRUE AS correct, 1 AS ord
  UNION ALL SELECT 'I''m sorry, but I have too much administrative work to complete for the district office today.' AS text, FALSE, 2
  UNION ALL SELECT 'I will do the duty if you promise to give me extra time to visit teachers in the afternoon.' AS text, FALSE, 3
  UNION ALL SELECT 'The District Office says I am not allowed to perform any non-coaching duties during the day.' AS text, FALSE, 4
) opt;

-- Q9: Shared Mirror
WITH baseline_assessment AS (
  SELECT id FROM public.assessments WHERE type = 'baseline' LIMIT 1
),
q9 AS (
  SELECT id FROM public.questions WHERE assessment_id = (SELECT id FROM baseline_assessment) AND order_number = 9
)
INSERT INTO public.options (question_id, option_text, is_correct, order_number)
SELECT (SELECT id FROM q9), opt.text, opt.correct, opt.ord FROM (
  SELECT 'Ignore the observation and celebrate the 100% score to maintain a positive relationship.' AS text, FALSE AS correct, 1 AS ord
  UNION ALL SELECT 'Change the dashboard score manually to 0% to reflect the lack of real reasoning or learning.' AS text, FALSE, 2
  UNION ALL SELECT 'Use the "Shared Mirror" to ask: "Data shows 100% completion, but what do we notice here?"' AS text, TRUE, 3
  UNION ALL SELECT 'Report the teacher for "Robotic Teaching" and request a formal review of their daily methods.' AS text, FALSE, 4
) opt;

-- Q10: Administrative After-Burn
WITH baseline_assessment AS (
  SELECT id FROM public.assessments WHERE type = 'baseline' LIMIT 1
),
q10 AS (
  SELECT id FROM public.questions WHERE assessment_id = (SELECT id FROM baseline_assessment) AND order_number = 10
)
INSERT INTO public.options (question_id, option_text, is_correct, order_number)
SELECT (SELECT id FROM q10), opt.text, opt.correct, opt.ord FROM (
  SELECT 'Take paper notes during the day and enter them into the system at home during evening hours.' AS text, FALSE AS correct, 1 AS ord
  UNION ALL SELECT 'Ask the teacher to enter their own data to ensure they agree with the findings of the visit.' AS text, FALSE, 2
  UNION ALL SELECT 'Only record successful visits to ensure the regional dashboard remains positive for the district.' AS text, FALSE, 3
  UNION ALL SELECT 'Complete 100% of app entries (Evidence and Action Steps) while still inside the school building.' AS text, TRUE, 4
) opt;

-- Q11: Training Loop
WITH baseline_assessment AS (
  SELECT id FROM public.assessments WHERE type = 'baseline' LIMIT 1
),
q11 AS (
  SELECT id FROM public.questions WHERE assessment_id = (SELECT id FROM baseline_assessment) AND order_number = 11
)
INSERT INTO public.options (question_id, option_text, is_correct, order_number)
SELECT (SELECT id FROM q11), opt.text, opt.correct, opt.ord FROM (
  SELECT 'Planning Loop failure regarding the preparation of the lesson materials and the overall timing.' AS text, FALSE AS correct, 1 AS ord
  UNION ALL SELECT 'Training Loop failure regarding the need for rehearsal to build physical muscle memory.' AS text, TRUE, 2
  UNION ALL SELECT 'Observation Loop failure where the coach failed to see the teacher''s actual pedagogical intent.' AS text, FALSE, 3
  UNION ALL SELECT 'Mindset failure where the teacher does not believe the students are capable of meeting goals.' AS text, FALSE, 4
) opt;

-- Q12: Silence Myth
WITH baseline_assessment AS (
  SELECT id FROM public.assessments WHERE type = 'baseline' LIMIT 1
),
q12 AS (
  SELECT id FROM public.questions WHERE assessment_id = (SELECT id FROM baseline_assessment) AND order_number = 12
)
INSERT INTO public.options (question_id, option_text, is_correct, order_number)
SELECT (SELECT id FROM q12), opt.text, opt.correct, opt.ord FROM (
  SELECT 'The teacher doesn''t know the subject matter well enough to explain it to the students directly.' AS text, FALSE AS correct, 1 AS ord
  UNION ALL SELECT 'The teacher is lazy and doesn''t want to spend time preparing an interactive or engaging lesson.' AS text, FALSE, 2
  UNION ALL SELECT 'The "Silence Myth": believing a quiet class copying text is synonymous with a learning class.' AS text, TRUE, 3
  UNION ALL SELECT 'The students are too slow to do any other activity without the direct copying of textbook text.' AS text, FALSE, 4
) opt;

-- Q13: High-Leverage Change
WITH baseline_assessment AS (
  SELECT id FROM public.assessments WHERE type = 'baseline' LIMIT 1
),
q13 AS (
  SELECT id FROM public.questions WHERE assessment_id = (SELECT id FROM baseline_assessment) AND order_number = 13
)
INSERT INTO public.options (question_id, option_text, is_correct, order_number)
SELECT (SELECT id FROM q13), opt.text, opt.correct, opt.ord FROM (
  SELECT 'The "High-Leverage" change that the teacher agrees will impact the students most significantly.' AS text, TRUE AS correct, 1 AS ord
  UNION ALL SELECT 'The easiest gap to fix in order to build momentum and teacher confidence as quickly as possible.' AS text, FALSE, 2
  UNION ALL SELECT 'The specific gap the Principal is most concerned about based on their recent informal observations.' AS text, FALSE, 3
  UNION ALL SELECT 'All 8 gaps simultaneously to ensure that the teacher grows rapidly across all teaching domains.' AS text, FALSE, 4
) opt;

-- Q14: Co-Pilot
WITH baseline_assessment AS (
  SELECT id FROM public.assessments WHERE type = 'baseline' LIMIT 1
),
q14 AS (
  SELECT id FROM public.questions WHERE assessment_id = (SELECT id FROM baseline_assessment) AND order_number = 14
)
INSERT INTO public.options (question_id, option_text, is_correct, order_number)
SELECT (SELECT id FROM q14), opt.text, opt.correct, opt.ord FROM (
  SELECT 'Show the teacher they are the expert by teaching the most difficult part of the lesson to the class.' AS text, FALSE AS correct, 1 AS ord
  UNION ALL SELECT 'Act as a "Co-Pilot" by "sliding in" for 2 minutes to model a specific, narrow micro-skill.' AS text, TRUE, 2
  UNION ALL SELECT 'Finish the entire lesson for the teacher so the students stay focused on the specific task at hand.' AS text, FALSE, 3
  UNION ALL SELECT 'Evaluate student behavior and report the findings back to the teacher at the end of the period.' AS text, FALSE, 4
) opt;

-- Q15: Responsive Contextualization
WITH baseline_assessment AS (
  SELECT id FROM public.assessments WHERE type = 'baseline' LIMIT 1
),
q15 AS (
  SELECT id FROM public.questions WHERE assessment_id = (SELECT id FROM baseline_assessment) AND order_number = 15
)
INSERT INTO public.options (question_id, option_text, is_correct, order_number)
SELECT (SELECT id FROM q15), opt.text, opt.correct, opt.ord FROM (
  SELECT 'The teacher is unwilling to follow the manual despite having the resources to do so effectively.' AS text, FALSE AS correct, 1 AS ord
  UNION ALL SELECT 'The coach wants to try a new pedagogical experiment to see if the students enjoy the variety.' AS text, FALSE, 2
  UNION ALL SELECT 'The Principal demands a change in the coaching schedule to accommodate a last-minute meeting.' AS text, FALSE, 3
  UNION ALL SELECT 'A strategy is impossible due to local constraints like 60 students and bolted-down desks.' AS text, TRUE, 4
) opt;

-- Q16: Compliance Trap
WITH baseline_assessment AS (
  SELECT id FROM public.assessments WHERE type = 'baseline' LIMIT 1
),
q16 AS (
  SELECT id FROM public.questions WHERE assessment_id = (SELECT id FROM baseline_assessment) AND order_number = 16
)
INSERT INTO public.options (question_id, option_text, is_correct, order_number)
SELECT (SELECT id FROM q16), opt.text, opt.correct, opt.ord FROM (
  SELECT 'The teacher refuses to sign the coaching notes because they disagree with the data captured.' AS text, FALSE AS correct, 1 AS ord
  UNION ALL SELECT 'WRER is 0% but the student engagement scores are unexpectedly very high across the school.' AS text, FALSE, 2
  UNION ALL SELECT 'WRER is 100% (visits happening) but the Growth Rate is 0% (no actual behavior change).' AS text, TRUE, 3
  UNION ALL SELECT 'The Principal takes over the coaching session and dictates the teacher''s next action steps.' AS text, FALSE, 4
) opt;

-- Q17: Reciprocity with Veteran Teacher
WITH baseline_assessment AS (
  SELECT id FROM public.assessments WHERE type = 'baseline' LIMIT 1
),
q17 AS (
  SELECT id FROM public.questions WHERE assessment_id = (SELECT id FROM baseline_assessment) AND order_number = 17
)
INSERT INTO public.options (question_id, option_text, is_correct, order_number)
SELECT (SELECT id FROM q17), opt.text, opt.correct, opt.ord FROM (
  SELECT 'Acknowledge their expertise and ask which part of the strategy fits their specific classroom.' AS text, TRUE AS correct, 1 AS ord
  UNION ALL SELECT 'Remind them that this strategy is the new "Gold Standard" required by the school district.' AS text, FALSE, 2
  UNION ALL SELECT 'Suggest they observe a younger teacher who has mastered the new digital tools and methods.' AS text, FALSE, 3
  UNION ALL SELECT 'Perform modeling in their classroom without asking for their specific permission or input first.' AS text, FALSE, 4
) opt;

-- Q18: Praxis vs. Theory
WITH baseline_assessment AS (
  SELECT id FROM public.assessments WHERE type = 'baseline' LIMIT 1
),
q18 AS (
  SELECT id FROM public.questions WHERE assessment_id = (SELECT id FROM baseline_assessment) AND order_number = 18
)
INSERT INTO public.options (question_id, option_text, is_correct, order_number)
SELECT (SELECT id FROM q18), opt.text, opt.correct, opt.ord FROM (
  SELECT 'Theory is too difficult for most teachers to read and apply in a busy and crowded school day.' AS text, FALSE AS correct, 1 AS ord
  UNION ALL SELECT 'It allows the "Human Filter" to adapt the intent of a strategy to fit local, high-constraint reality.' AS text, TRUE, 2
  UNION ALL SELECT 'It is much easier for the coach to grade a physical action than an abstract or conceptual idea.' AS text, FALSE, 3
  UNION ALL SELECT 'The manual is only a suggestion and should not be followed strictly by teachers or by coaches.' AS text, FALSE, 4
) opt;
