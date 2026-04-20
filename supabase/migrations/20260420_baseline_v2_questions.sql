-- Migration: Update baseline questions to Baseline V2
-- Date: 2026-04-20
-- Description: Replace existing baseline questions with updated v2 questions covering Modules 2-6

-- Delete existing baseline questions and assessment
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
VALUES ('baseline', 'Coach Baseline Assessment V2');

-- Get assessment ID for reference and insert all questions
WITH baseline_assessment AS (
  SELECT id FROM public.assessments WHERE type = 'baseline' LIMIT 1
)
INSERT INTO public.questions (assessment_id, question_type, question_text, order_number)
SELECT
  (SELECT id FROM baseline_assessment),
  'mcq',
  question_text,
  ROW_NUMBER() OVER (ORDER BY order_seq)
FROM (
  -- Module 2: The Partnership Foundation (Trust & Status) - 6 questions
  SELECT 1 as order_seq, 'According to the SCARF model, a veteran teacher saying they don''t need a coach is a direct threat to:' AS question_text
  UNION ALL SELECT 2, 'When a teacher displays "Flight" behavior (minimal responses), it likely indicates the coach has:'
  UNION ALL SELECT 3, 'A Principal demands individual teacher engagement scores for "Show Cause" notices. According to the Universal SOP, you should:'
  UNION ALL SELECT 4, 'Case Study: A veteran teacher reacts with "Freeze" behavior. Which Opening Script best uses Equality and Voice?'
  UNION ALL SELECT 5, 'Case Study: During feedback, a teacher is defensive. To move to a Side-by-Side mindset, you should:'
  UNION ALL SELECT 6, 'Case Study: A teacher is struggling with a noisy class. Instead of a "fix," you use Deep Empathy by saying:'
  
  -- Module 3: The Mirror Specialist (Shared Reality) - 6 questions
  UNION ALL SELECT 7, 'What is the primary purpose of capturing "Data at the Edge" (e.g., back-row notebooks)?'
  UNION ALL SELECT 8, 'If a coach and teacher score the same lesson differently, this "Calibration Gap" is usually caused by:'
  UNION ALL SELECT 9, 'The Human Filter rule states that a coach should NOT capture an artifact if:'
  UNION ALL SELECT 10, 'Case Study: Which observation note successfully passes the "Camera Test" by removing judgment?'
  UNION ALL SELECT 11, 'Case Study: A teacher insists a class was "perfect," but data shows 0% passed the exit ticket. You should:'
  UNION ALL SELECT 12, 'Case Study: When taking a digital photo of student work, the Voice principle requires you to:'
  
  -- Module 4: Digital & Data Intelligence (Collaborative Analytics) - 6 questions
  UNION ALL SELECT 13, 'Coach Usman had 6 visits. 1 holiday, 1 absent teacher, 1 visit with no artifact, and 1 interrupted. What is his WRER?'
  UNION ALL SELECT 14, 'What does a "High Fidelity" but "Low Impact" score on a Regional Heatmap suggest?'
  UNION ALL SELECT 15, 'To avoid the "Administrative After-Burn," a coach should:'
  UNION ALL SELECT 16, 'Case Study: A Principal displaces your coaching block for duty. Which Advocacy Script is best?'
  UNION ALL SELECT 17, 'Case Study: An AI dashboard suggests "Use digital tools," but there is no electricity. You:'
  UNION ALL SELECT 18, 'Case Study: A dashboard shows 100% task completion, but you observe students just copying. You should:'
  
  -- Module 5: The Instructional Catalyst (Co-Design) - 6 questions
  UNION ALL SELECT 19, 'A teacher explains a strategy perfectly but fails to use it in a noisy classroom. This is a:'
  UNION ALL SELECT 20, 'In Side-by-Side Co-Modeling, the coach''s goal is to:'
  UNION ALL SELECT 21, 'If a goal is not met after two visits, the Improve Phase requires one of 4 Paths. Which is NOT a path?'
  UNION ALL SELECT 22, 'Case Study: A teacher has students copy an entire textbook chapter. You identify the Belief Gap as:'
  UNION ALL SELECT 23, 'Case Study: A teacher spends 20 minutes on a 5-minute intro. You diagnose this as a Planning Loop failure and:'
  UNION ALL SELECT 24, 'Case Study: When a teacher has 8 skill gaps, a "Catalyst" coach prioritizes:'
  
  -- Module 6: The Excellence Loop (Reciprocity & Praxis) - 6 questions
  UNION ALL SELECT 25, '"Responsive Contextualization" is necessary when:'
  UNION ALL SELECT 26, 'The "Compliance Trap" occurs when:'
  UNION ALL SELECT 27, '"Closing the Loop" is only achieved when:'
  UNION ALL SELECT 28, 'Case Study: A veteran teacher is skeptical of a new strategy. The most Reciprocal move is to:'
  UNION ALL SELECT 29, 'Case Study: You model a strategy and it fails (chaotic classroom). To maintain Shared Reality, you:'
  UNION ALL SELECT 30, 'Case Study: Why is Praxis (action-based learning) prioritized over "Abstract Theory"?'
) q;

-- Now add options for each question
WITH baseline_assessment AS (
  SELECT id FROM public.assessments WHERE type = 'baseline'
),
questions_map AS (
  SELECT id, question_text, order_number as q_num
  FROM public.questions
  WHERE assessment_id = (SELECT id FROM baseline_assessment)
)
INSERT INTO public.options (question_id, option_text, is_correct)
SELECT q.id, option_text, is_correct
FROM questions_map q
CROSS JOIN LATERAL (
  -- Module 2, Q1: SCARF model threat
  SELECT * FROM (
    SELECT 'Certainty' AS option_text, false AS is_correct WHERE q.q_num = 1
    UNION ALL SELECT 'Status' AS option_text, true AS is_correct WHERE q.q_num = 1
    UNION ALL SELECT 'Autonomy' AS option_text, false AS is_correct WHERE q.q_num = 1
    UNION ALL SELECT 'Relatedness' AS option_text, false AS is_correct WHERE q.q_num = 1
  ) AS opts
  
  -- Module 2, Q2: Flight behavior
  UNION ALL SELECT * FROM (
    SELECT 'Triggered a Status Threat by using evaluative language rather than low-inference data.' AS option_text, true AS is_correct WHERE q.q_num = 2
    UNION ALL SELECT 'Failed to provide enough expert advice regarding the specific pedagogical strategies.' AS option_text, false AS is_correct WHERE q.q_num = 2
    UNION ALL SELECT 'Spent too much time listening to the teacher''s concerns instead of taking notes.' AS option_text, false AS is_correct WHERE q.q_num = 2
    UNION ALL SELECT 'Not followed the NEO-1 checklist strictly enough to ensure a professional visit.' AS option_text, false AS is_correct WHERE q.q_num = 2
  ) AS opts
  
  -- Module 2, Q3: Show Cause notices
  UNION ALL SELECT * FROM (
    SELECT 'Share the scores but ask the Principal to keep the individual names confidential.' AS option_text, false AS is_correct WHERE q.q_num = 3
    UNION ALL SELECT 'Provide a list of only the "top-performing" teachers to maintain school morale.' AS option_text, false AS is_correct WHERE q.q_num = 3
    UNION ALL SELECT 'Refuse and offer a "System-Trends" report to protect individual teacher trust.' AS option_text, true AS is_correct WHERE q.q_num = 3
    UNION ALL SELECT 'Tell the Principal you will ask the teachers for their written permission first.' AS option_text, false AS is_correct WHERE q.q_num = 3
  ) AS opts
  
  -- Module 2, Q4: Freeze behavior Opening Script
  UNION ALL SELECT * FROM (
    SELECT 'I''m here to help you improve your classroom management with some expert tips.' AS option_text, false AS is_correct WHERE q.q_num = 4
    UNION ALL SELECT 'I''m here as a partner to learn alongside you; what is a specific goal you have?' AS option_text, true AS is_correct WHERE q.q_num = 4
    UNION ALL SELECT 'The District Office requires me to audit this lesson for performance tracking.' AS option_text, false AS is_correct WHERE q.q_num = 4
    UNION ALL SELECT 'I will be watching to see if you are following the standard manual correctly.' AS option_text, false AS is_correct WHERE q.q_num = 4
  ) AS opts
  
  -- Module 2, Q5: Defensive teacher
  UNION ALL SELECT * FROM (
    SELECT 'Re-read the rubric to show them exactly where their performance failed to meet goals.' AS option_text, false AS is_correct WHERE q.q_num = 5
    UNION ALL SELECT 'Remind them that your role is to give expert advice they must follow for the program.' AS option_text, false AS is_correct WHERE q.q_num = 5
    UNION ALL SELECT 'Physically sit next to them and look at student work together, asking "What do you see?"' AS option_text, true AS is_correct WHERE q.q_num = 5
    UNION ALL SELECT 'Suggest they observe a younger teacher who is more compliant with the modern methods.' AS option_text, false AS is_correct WHERE q.q_num = 5
  ) AS opts
  
  -- Module 2, Q6: Noisy class Deep Empathy
  UNION ALL SELECT * FROM (
    SELECT 'It sounds frustrating when you''ve planned a lesson and the back row isn''t engaging.' AS option_text, true AS is_correct WHERE q.q_num = 6
    UNION ALL SELECT 'You should use a whistle or a louder clap to get their attention more quickly.' AS option_text, false AS is_correct WHERE q.q_num = 6
    UNION ALL SELECT 'In my day, I handled 80 students by doing specific management techniques.' AS option_text, false AS is_correct WHERE q.q_num = 6
    UNION ALL SELECT 'I will mark this as a practice visit so it doesn''t hurt your official record.' AS option_text, false AS is_correct WHERE q.q_num = 6
  ) AS opts
  
  -- Module 3, Q1: Data at the Edge
  UNION ALL SELECT * FROM (
    SELECT 'To catch the teacher ignoring students who are sitting far away from the podium.' AS option_text, false AS is_correct WHERE q.q_num = 7
    UNION ALL SELECT 'To find the truth of student learning often hidden by activity at the "Center."' AS option_text, true AS is_correct WHERE q.q_num = 7
    UNION ALL SELECT 'To provide documented evidence for administrative "Show Cause" or warning notices.' AS option_text, false AS is_correct WHERE q.q_num = 7
    UNION ALL SELECT 'To satisfy the digital application requirements for capturing multiple artifacts.' AS option_text, false AS is_correct WHERE q.q_num = 7
  ) AS opts
  
  -- Module 3, Q2: Calibration Gap
  UNION ALL SELECT * FROM (
    SELECT 'One person is a "mean" grader while the other is trying to be "supportive."' AS option_text, false AS is_correct WHERE q.q_num = 8
    UNION ALL SELECT 'The rubric is too complex for the teacher to understand without prior training.' AS option_text, false AS is_correct WHERE q.q_num = 8
    UNION ALL SELECT 'Using subjective "feelings" instead of a shared mirror of objective classroom facts.' AS option_text, true AS is_correct WHERE q.q_num = 8
    UNION ALL SELECT 'The teacher acts differently toward the coach than they do toward the students.' AS option_text, false AS is_correct WHERE q.q_num = 8
  ) AS opts
  
  -- Module 3, Q3: Human Filter rule
  UNION ALL SELECT * FROM (
    SELECT 'The lighting in the room is poor, and the photo will not be clear for the dashboard.' AS option_text, false AS is_correct WHERE q.q_num = 9
    UNION ALL SELECT 'A student is visibly distressed, or the teacher is in an acute emotional crisis.' AS option_text, true AS is_correct WHERE q.q_num = 9
    UNION ALL SELECT 'The coach forgot their tablet and has to rely on memory for the digital entry.' AS option_text, false AS is_correct WHERE q.q_num = 9
    UNION ALL SELECT 'The teacher is using a non-standard strategy that is not mentioned in the manual.' AS option_text, false AS is_correct WHERE q.q_num = 9
  ) AS opts
  
  -- Module 3, Q4: Camera Test
  UNION ALL SELECT * FROM (
    SELECT 'The teacher was too lazy to check the homework assigned during the previous day.' AS option_text, false AS is_correct WHERE q.q_num = 10
    UNION ALL SELECT 'The teacher gave a very clear and concise explanation of the complex science topic.' AS option_text, false AS is_correct WHERE q.q_num = 10
    UNION ALL SELECT 'At 11:15 AM, 12 of 68 students were writing; 56 students sat with blank pages.' AS option_text, true AS is_correct WHERE q.q_num = 10
    UNION ALL SELECT 'The classroom was noisy because the teacher lost control of the student behavior.' AS option_text, false AS is_correct WHERE q.q_num = 10
  ) AS opts
  
  -- Module 3, Q5: Third Partner
  UNION ALL SELECT * FROM (
    SELECT 'Argue the data points until the teacher admits their assessment of the class was wrong.' AS option_text, false AS is_correct WHERE q.q_num = 11
    UNION ALL SELECT 'Introduce the "Third Partner" by looking at 5 randomly selected student notebooks.' AS option_text, true AS is_correct WHERE q.q_num = 11
    UNION ALL SELECT 'Agree with them to maintain the relationship and try to address the issue next week.' AS option_text, false AS is_correct WHERE q.q_num = 11
    UNION ALL SELECT 'Inform the Principal immediately that the teacher is in denial about student progress.' AS option_text, false AS is_correct WHERE q.q_num = 11
  ) AS opts
  
  -- Module 3, Q6: Voice principle with photos
  UNION ALL SELECT * FROM (
    SELECT 'Take it silently to avoid distracting the class or interrupting the teacher''s flow.' AS option_text, false AS is_correct WHERE q.q_num = 12
    UNION ALL SELECT 'Only take photos of top-performing students to show the potential of the strategy.' AS option_text, false AS is_correct WHERE q.q_num = 12
    UNION ALL SELECT 'Use a permission script that names a specific learning curiosity you want to explore.' AS option_text, true AS is_correct WHERE q.q_num = 12
    UNION ALL SELECT 'Send the photo to the Principal immediately for validation and official record keeping.' AS option_text, false AS is_correct WHERE q.q_num = 12
  ) AS opts
  
  -- Module 4, Q1: WRER calculation
  UNION ALL SELECT * FROM (
    SELECT '66%' AS option_text, false AS is_correct WHERE q.q_num = 13
    UNION ALL SELECT '75%' AS option_text, true AS is_correct WHERE q.q_num = 13
    UNION ALL SELECT '50%' AS option_text, false AS is_correct WHERE q.q_num = 13
    UNION ALL SELECT '40%' AS option_text, false AS is_correct WHERE q.q_num = 13
  ) AS opts
  
  -- Module 4, Q2: High Fidelity Low Impact
  UNION ALL SELECT * FROM (
    SELECT 'Teachers are following the steps (Compliance) but without deep pedagogical dialogue.' AS option_text, true AS is_correct WHERE q.q_num = 14
    UNION ALL SELECT 'The digital application is not being used frequently enough by the coaching staff.' AS option_text, false AS is_correct WHERE q.q_num = 14
    UNION ALL SELECT 'Students are not participating because the strategy is too difficult for their level.' AS option_text, false AS is_correct WHERE q.q_num = 14
    UNION ALL SELECT 'The coach is not visiting the assigned schools enough to make a lasting difference.' AS option_text, false AS is_correct WHERE q.q_num = 14
  ) AS opts
  
  -- Module 4, Q3: Administrative After-Burn
  UNION ALL SELECT * FROM (
    SELECT 'Take paper notes and enter them into the system at home during the evening hours.' AS option_text, false AS is_correct WHERE q.q_num = 15
    UNION ALL SELECT 'Complete 100% of app entries (Evidence and Action Steps) inside the school building.' AS option_text, true AS is_correct WHERE q.q_num = 15
    UNION ALL SELECT 'Ask the teacher to enter the data themselves to ensure they agree with the findings.' AS option_text, false AS is_correct WHERE q.q_num = 15
    UNION ALL SELECT 'Only record successful visits to ensure the regional dashboard remains positive.' AS option_text, false AS is_correct WHERE q.q_num = 15
  ) AS opts
  
  -- Module 4, Q4: Principal displaces coaching block
  UNION ALL SELECT * FROM (
    SELECT 'I''m sorry, but I have too much administrative work to complete for the district today.' AS option_text, false AS is_correct WHERE q.q_num = 16
    UNION ALL SELECT 'I will do the duty if you promise to give me extra time to visit teachers tomorrow.' AS option_text, false AS is_correct WHERE q.q_num = 16
    UNION ALL SELECT 'My WRER is at 50%; if I miss this, Teacher Sara waits 7 days, risking kids.' AS option_text, true AS is_correct WHERE q.q_num = 16
    UNION ALL SELECT 'The District Office says I am not allowed to perform any non-coaching duties today.' AS option_text, false AS is_correct WHERE q.q_num = 16
  ) AS opts
  
  -- Module 4, Q5: AI dashboard without electricity
  UNION ALL SELECT * FROM (
    SELECT 'Tell the teacher to follow the AI suggestion anyway to maintain program fidelity.' AS option_text, false AS is_correct WHERE q.q_num = 17
    UNION ALL SELECT 'Co-design a low-tech alternative (e.g., "Turn-and-Talk") that achieves the same intent.' AS option_text, true AS is_correct WHERE q.q_num = 17
    UNION ALL SELECT 'Mark the visit as "Not Applicable" and move to the next teacher on your list.' AS option_text, false AS is_correct WHERE q.q_num = 17
    UNION ALL SELECT 'Report the lack of resources and skip the coaching step until electricity is restored.' AS option_text, false AS is_correct WHERE q.q_num = 17
  ) AS opts
  
  -- Module 4, Q6: 100% task completion but just copying
  UNION ALL SELECT * FROM (
    SELECT 'Ignore the observation and celebrate the 100% score to maintain a positive relationship.' AS option_text, false AS is_correct WHERE q.q_num = 18
    UNION ALL SELECT 'Use the "Shared Mirror" to ask: "Data shows 100% completion, but what do we notice?"' AS option_text, true AS is_correct WHERE q.q_num = 18
    UNION ALL SELECT 'Change the dashboard score manually to 0% to reflect the lack of real learning.' AS option_text, false AS is_correct WHERE q.q_num = 18
    UNION ALL SELECT 'Report the teacher for "Robotic Teaching" and request a formal review of their methods.' AS option_text, false AS is_correct WHERE q.q_num = 18
  ) AS opts
  
  -- Module 5, Q1: Noisy classroom strategy failure
  UNION ALL SELECT * FROM (
    SELECT 'Planning Loop failure regarding the preparation of the lesson materials and timing.' AS option_text, false AS is_correct WHERE q.q_num = 19
    UNION ALL SELECT 'Observation Loop failure where the coach failed to see the teacher''s actual intent.' AS option_text, false AS is_correct WHERE q.q_num = 19
    UNION ALL SELECT 'Training Loop failure (Needs rehearsal to build muscle memory for the teacher).' AS option_text, true AS is_correct WHERE q.q_num = 19
    UNION ALL SELECT 'Mindset failure where the teacher does not believe the students are capable of it.' AS option_text, false AS is_correct WHERE q.q_num = 19
  ) AS opts
  
  -- Module 5, Q2: Side-by-Side Co-Modeling goal
  UNION ALL SELECT * FROM (
    SELECT 'Show the teacher they are the expert by teaching the most difficult part of the class.' AS option_text, false AS is_correct WHERE q.q_num = 20
    UNION ALL SELECT 'Act as a "Co-Pilot" by "sliding in" for 2 minutes to model a specific micro-skill.' AS option_text, true AS is_correct WHERE q.q_num = 20
    UNION ALL SELECT 'Finish the entire lesson for the teacher so the students stay focused on the task.' AS option_text, false AS is_correct WHERE q.q_num = 20
    UNION ALL SELECT 'Evaluate student behavior and report back to the teacher at the end of the period.' AS option_text, false AS is_correct WHERE q.q_num = 20
  ) AS opts
  
  -- Module 5, Q3: Improve Phase Paths
  UNION ALL SELECT * FROM (
    SELECT 'Modify the strategy' AS option_text, false AS is_correct WHERE q.q_num = 21
    UNION ALL SELECT 'Switch to a new strategy' AS option_text, false AS is_correct WHERE q.q_num = 21
    UNION ALL SELECT 'Stay the course' AS option_text, false AS is_correct WHERE q.q_num = 21
    UNION ALL SELECT 'Report failure to administration' AS option_text, true AS is_correct WHERE q.q_num = 21
  ) AS opts
  
  -- Module 5, Q4: Belief Gap with copying
  UNION ALL SELECT * FROM (
    SELECT 'The teacher doesn''t know the subject matter well enough to explain it to students.' AS option_text, false AS is_correct WHERE q.q_num = 22
    UNION ALL SELECT 'The "Silence Myth": believing a quiet class copying text is a learning class.' AS option_text, true AS is_correct WHERE q.q_num = 22
    UNION ALL SELECT 'The teacher is lazy and doesn''t want to spend time preparing an interactive lesson.' AS option_text, false AS is_correct WHERE q.q_num = 22
    UNION ALL SELECT 'The students are too slow to do any other activity without direct copying of text.' AS option_text, false AS is_correct WHERE q.q_num = 22
  ) AS opts
  
  -- Module 5, Q5: Long intro Planning Loop
  UNION ALL SELECT * FROM (
    SELECT 'Tell them to be faster next time and use a stopwatch to monitor their progress.' AS option_text, false AS is_correct WHERE q.q_num = 23
    UNION ALL SELECT 'Co-design a script with specific time-stamps for each individual lesson segment.' AS option_text, true AS is_correct WHERE q.q_num = 23
    UNION ALL SELECT 'Model the entire lesson for them to show how the timing should properly work.' AS option_text, false AS is_correct WHERE q.q_num = 23
    UNION ALL SELECT 'Mark them as "Not Proficient" in time management in the final coaching report.' AS option_text, false AS is_correct WHERE q.q_num = 23
  ) AS opts
  
  -- Module 5, Q6: Eight skill gaps prioritization
  UNION ALL SELECT * FROM (
    SELECT 'The easiest gap to fix to build momentum and teacher confidence quickly.' AS option_text, false AS is_correct WHERE q.q_num = 24
    UNION ALL SELECT 'The "High-Leverage" change that the teacher agrees will impact students most.' AS option_text, true AS is_correct WHERE q.q_num = 24
    UNION ALL SELECT 'The gap the Principal is most concerned about based on their recent observations.' AS option_text, false AS is_correct WHERE q.q_num = 24
    UNION ALL SELECT 'All 8 gaps simultaneously to ensure rapid growth across all teaching domains.' AS option_text, false AS is_correct WHERE q.q_num = 24
  ) AS opts
  
  -- Module 6, Q1: Responsive Contextualization
  UNION ALL SELECT * FROM (
    SELECT 'The teacher is unwilling to follow the manual despite having the resources to do so.' AS option_text, false AS is_correct WHERE q.q_num = 25
    UNION ALL SELECT 'A strategy is impossible due to local constraints like 60 students and bolted desks.' AS option_text, true AS is_correct WHERE q.q_num = 25
    UNION ALL SELECT 'The coach wants to try a new pedagogical experiment to see if the students like it.' AS option_text, false AS is_correct WHERE q.q_num = 25
    UNION ALL SELECT 'The Principal demands a change in the coaching schedule to accommodate a meeting.' AS option_text, false AS is_correct WHERE q.q_num = 25
  ) AS opts
  
  -- Module 6, Q2: Compliance Trap
  UNION ALL SELECT * FROM (
    SELECT 'WRER is 0% but growth is unexpectedly high across the majority of classrooms.' AS option_text, false AS is_correct WHERE q.q_num = 26
    UNION ALL SELECT 'The teacher refuses to sign the coaching notes because they disagree with the data.' AS option_text, false AS is_correct WHERE q.q_num = 26
    UNION ALL SELECT 'WRER is 100% (visits happening) but Growth Rate is 0% (no behavior change).' AS option_text, true AS is_correct WHERE q.q_num = 26
    UNION ALL SELECT 'The Principal takes over the coaching session and dictates the teacher''s action steps.' AS option_text, false AS is_correct WHERE q.q_num = 26
  ) AS opts
  
  -- Module 6, Q3: Closing the Loop
  UNION ALL SELECT * FROM (
    SELECT 'The final coaching report is filed and signed by both the coach and the Principal.' AS option_text, false AS is_correct WHERE q.q_num = 27
    UNION ALL SELECT 'The coach gives a specific compliment about the teacher''s effort during the visit.' AS option_text, false AS is_correct WHERE q.q_num = 27
    UNION ALL SELECT 'Coach and teacher verify together that the new skill is a mastered habit.' AS option_text, true AS is_correct WHERE q.q_num = 27
    UNION ALL SELECT 'The central office training is completed and the teacher receives their certificate.' AS option_text, false AS is_correct WHERE q.q_num = 27
  ) AS opts
  
  -- Module 6, Q4: Skeptical veteran teacher
  UNION ALL SELECT * FROM (
    SELECT 'Remind them that this strategy is the new "Gold Standard" required by the district.' AS option_text, false AS is_correct WHERE q.q_num = 28
    UNION ALL SELECT 'Acknowledge their expertise and ask which part of the strategy fits their classroom.' AS option_text, true AS is_correct WHERE q.q_num = 28
    UNION ALL SELECT 'Suggest they observe a younger teacher who has mastered the new digital tools.' AS option_text, false AS is_correct WHERE q.q_num = 28
    UNION ALL SELECT 'Perform modeling in their classroom without asking for their specific permission.' AS option_text, false AS is_correct WHERE q.q_num = 28
  ) AS opts
  
  -- Module 6, Q5: Model fails in chaos
  UNION ALL SELECT * FROM (
    SELECT 'Blame previous student behavior or lack of school-wide discipline for the failure.' AS option_text, false AS is_correct WHERE q.q_num = 29
    UNION ALL SELECT 'Use the "Shared Mirror" to admit failure and ask: "What did you notice I missed?"' AS option_text, true AS is_correct WHERE q.q_num = 29
    UNION ALL SELECT 'Pretend it went well to maintain your "Expert" status and the teacher''s respect.' AS option_text, false AS is_correct WHERE q.q_num = 29
    UNION ALL SELECT 'Delete the failure recording from the app so it doesn''t skew your performance data.' AS option_text, false AS is_correct WHERE q.q_num = 29
  ) AS opts
  
  -- Module 6, Q6: Praxis over Abstract Theory
  UNION ALL SELECT * FROM (
    SELECT 'Theory is too difficult for most teachers to read and apply in a busy school day.' AS option_text, false AS is_correct WHERE q.q_num = 30
    UNION ALL SELECT 'It is much easier for the coach to grade a physical action than an abstract idea.' AS option_text, false AS is_correct WHERE q.q_num = 30
    UNION ALL SELECT 'It allows the "Human Filter" to adapt the intent of a strategy to fit local reality.' AS option_text, true AS is_correct WHERE q.q_num = 30
    UNION ALL SELECT 'The manual is only a suggestion and should not be followed strictly by teachers.' AS option_text, false AS is_correct WHERE q.q_num = 30
  ) AS opts
) AS options_data;
