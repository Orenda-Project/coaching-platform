-- Delete existing baseline to rebuild with correct option order
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

-- Insert questions in order with their correct answers mapped to A, B, C, D
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
  -- Module 2
  SELECT 'According to the SCARF model, a veteran teacher saying they don''t need a coach is a direct threat to:' AS question_text, 1 AS row_num
  UNION ALL SELECT 'When a teacher displays "Flight" behavior (minimal responses), it likely indicates the coach has:' AS question_text, 2 AS row_num
  UNION ALL SELECT 'A Principal demands the individual engagement scores of all teachers to decide on "Show Cause" notices. According to the Universal SOP, you should:', 3
  UNION ALL SELECT 'Case Study: A veteran teacher reacts with "Freeze" behavior (passive compliance). Which Opening Script best uses Equality and Voice to establish a partnership?', 4
  UNION ALL SELECT 'Case Study: During a feedback session, a teacher is defensive. To move to a Side-by-Side mindset, you should:', 5
  UNION ALL SELECT 'Case Study: You notice a teacher is struggling with a noisy class. Instead of giving a "fix," you use Deep Empathy by saying:', 6
  -- Module 3
  UNION ALL SELECT 'What is the primary purpose of capturing "Data at the Edge" (e.g., back-row notebooks)?', 7
  UNION ALL SELECT 'If a coach and teacher score the same lesson differently, this "Calibration Gap" is usually caused by:', 8
  UNION ALL SELECT 'The Human Filter rule states that a coach should NOT capture an artifact if:', 9
  UNION ALL SELECT 'Case Study: Which observation note successfully passes the "Camera Test" by removing high-inference judgment?', 10
  UNION ALL SELECT 'Case Study: A teacher insists a class was "perfect," but data shows 0% passed the exit ticket. To achieve Calibration, you should:', 11
  UNION ALL SELECT 'Case Study: When taking a digital photo of student work, the Voice principle requires you to:', 12
  -- Module 4
  UNION ALL SELECT 'Coach Usman had 6 visits. 1 holiday, 1 absent teacher (excluded), 1 visit with no artifact, and 1 interrupted by a Principal. What is his WRER?', 13
  UNION ALL SELECT 'What does a "High Fidelity" but "Low Impact" score on a Regional Heatmap suggest?', 14
  UNION ALL SELECT 'To avoid the "Administrative After-Burn," a coach should:', 15
  UNION ALL SELECT 'Case Study: A Principal displaces your coaching block with "Protocol Duty." Which Advocacy Script best protects your time?', 16
  UNION ALL SELECT 'Case Study: An AI dashboard suggests "Use digital tools," but there is no electricity. Following Human Override, you:', 17
  UNION ALL SELECT 'Case Study: A dashboard shows 100% task completion, but you observe students just copying from the board. You should:', 18
  -- Module 5
  UNION ALL SELECT 'A teacher explains a strategy perfectly but fails to use it in a noisy classroom. This is a:', 19
  UNION ALL SELECT 'In Side-by-Side Co-Modeling, the coach''s goal is to:', 20
  UNION ALL SELECT 'If a goal is not met after two visits, the Improve Phase requires one of 4 Paths. Which is NOT a path?', 21
  UNION ALL SELECT 'Case Study: A teacher has students copy an entire textbook chapter. You identify the Belief Gap (Internal Rule) as:', 22
  UNION ALL SELECT 'Case Study: A teacher spends 20 minutes on a 5-minute intro. You diagnose this as a Planning Loop failure and:', 23
  UNION ALL SELECT 'Case Study: When a teacher has 8 skill gaps, a "Catalyst" coach prioritizes:', 24
  -- Module 6
  UNION ALL SELECT '"Responsive Contextualization" is necessary when:', 25
  UNION ALL SELECT 'The "Compliance Trap" occurs when:', 26
  UNION ALL SELECT '"Closing the Loop" is only achieved when:', 27
  UNION ALL SELECT 'Case Study: A veteran teacher is skeptical of a new strategy. The most Reciprocal move is to:', 28
  UNION ALL SELECT 'Case Study: You model a strategy and it fails (chaotic classroom). To maintain Shared Reality, you:', 29
  UNION ALL SELECT 'Case Study: Why is Praxis (action-based learning) prioritized over "Abstract Theory"?', 30
) AS q(question_text, row_num);

-- Now add options in correct order (A, B, C, D) with answer keys from the document
WITH baseline_assessment AS (
  SELECT id FROM public.assessments WHERE type = 'baseline' LIMIT 1
),
questions_with_id AS (
  SELECT id, order_number FROM public.questions
  WHERE assessment_id = (SELECT id FROM baseline_assessment)
  ORDER BY order_number
)
INSERT INTO public.options (question_id, option_text, is_correct)
SELECT q.id, opts.option_text, opts.is_correct
FROM questions_with_id q
CROSS JOIN LATERAL (
  -- Q1: SCARF model answer = B) Status
  SELECT 'Certainty' AS option_text, false AS is_correct WHERE q.order_number = 1
  UNION ALL SELECT 'Status', true WHERE q.order_number = 1
  UNION ALL SELECT 'Autonomy', false WHERE q.order_number = 1
  UNION ALL SELECT 'Relatedness', false WHERE q.order_number = 1
  
  -- Q2: Flight behavior answer = B
  UNION ALL SELECT 'Failed to provide enough expert advice.', false WHERE q.order_number = 2
  UNION ALL SELECT 'Triggered a Status Threat by using evaluative language rather than low-inference data.', true WHERE q.order_number = 2
  UNION ALL SELECT 'Spent too much time listening.', false WHERE q.order_number = 2
  UNION ALL SELECT 'Not followed the NEO-1 checklist strictly enough.', false WHERE q.order_number = 2
  
  -- Q3: Principal scores answer = C
  UNION ALL SELECT 'Share the scores but ask the Principal to keep them confidential.', false WHERE q.order_number = 3
  UNION ALL SELECT 'Provide a list of only the "top-performing" teachers.', false WHERE q.order_number = 3
  UNION ALL SELECT 'Refuse and offer a "System-Trends" report to protect individual trust.', true WHERE q.order_number = 3
  UNION ALL SELECT 'Tell the Principal you will ask the teachers for permission first.', false WHERE q.order_number = 3
  
  -- Q4: Opening Script answer = B
  UNION ALL SELECT 'I''m here to help you improve your classroom management with some tips.', false WHERE q.order_number = 4
  UNION ALL SELECT 'I''m here as a partner to learn alongside you; what is a specific goal you have for your students today that we can look at together?', true WHERE q.order_number = 4
  UNION ALL SELECT 'The District Office requires me to audit this lesson for performance tracking.', false WHERE q.order_number = 4
  UNION ALL SELECT 'I will be watching to see if you are following the standard manual correctly.', false WHERE q.order_number = 4
  
  -- Q5: Defensive teacher answer = B
  UNION ALL SELECT 'Re-read the rubric to show them exactly where they failed.', false WHERE q.order_number = 5
  UNION ALL SELECT 'Physically sit next to them and look at student work together, asking "What do you see here?"', true WHERE q.order_number = 5
  UNION ALL SELECT 'Remind them that your role is to give expert advice they must follow.', false WHERE q.order_number = 5
  UNION ALL SELECT 'Suggest they observe a younger teacher who is more compliant.', false WHERE q.order_number = 5
  
  -- Q6: Deep Empathy answer = B
  UNION ALL SELECT 'You should use a whistle to get their attention.', false WHERE q.order_number = 6
  UNION ALL SELECT 'It sounds frustrating when you''ve planned a lesson and the back row isn''t engaging. What have you noticed about when they do pay attention?', true WHERE q.order_number = 6
  UNION ALL SELECT 'In my day, I handled 80 students by doing X.', false WHERE q.order_number = 6
  UNION ALL SELECT 'I will mark this as a practice visit so it doesn''t hurt your record.', false WHERE q.order_number = 6
  
  -- Q7: Data at Edge answer = B
  UNION ALL SELECT 'To catch the teacher ignoring students.', false WHERE q.order_number = 7
  UNION ALL SELECT 'To find the truth of student learning that is often hidden by teacher activity at the "Center."', true WHERE q.order_number = 7
  UNION ALL SELECT 'To provide evidence for a "Show Cause" notice.', false WHERE q.order_number = 7
  UNION ALL SELECT 'To satisfy digital app requirements.', false WHERE q.order_number = 7
  
  -- Q8: Calibration Gap answer = B
  UNION ALL SELECT 'One person being a "mean" grader.', false WHERE q.order_number = 8
  UNION ALL SELECT 'Using subjective "feelings" instead of a shared mirror of objective facts.', true WHERE q.order_number = 8
  UNION ALL SELECT 'The rubric being too complex to understand.', false WHERE q.order_number = 8
  UNION ALL SELECT 'The teacher acting differently toward each of you.', false WHERE q.order_number = 8
  
  -- Q9: Human Filter answer = B
  UNION ALL SELECT 'The lighting in the room is poor.', false WHERE q.order_number = 9
  UNION ALL SELECT 'A student is visibly distressed or the teacher is in an acute emotional crisis.', true WHERE q.order_number = 9
  UNION ALL SELECT 'The coach forgot their tablet.', false WHERE q.order_number = 9
  UNION ALL SELECT 'The teacher is using a non-standard strategy.', false WHERE q.order_number = 9
  
  -- Q10: Camera Test answer = B
  UNION ALL SELECT 'The teacher was too lazy to check homework.', false WHERE q.order_number = 10
  UNION ALL SELECT 'At 11:15 AM, 12 of 68 students were writing in notebooks; 56 students sat with blank pages.', true WHERE q.order_number = 10
  UNION ALL SELECT 'The teacher gave a very clear explanation of the topic.', false WHERE q.order_number = 10
  UNION ALL SELECT 'The classroom was noisy because the teacher lost control.', false WHERE q.order_number = 10
  
  -- Q11: Third Partner answer = B
  UNION ALL SELECT 'Argue until they admit they were wrong.', false WHERE q.order_number = 11
  UNION ALL SELECT 'Introduce the "Third Partner" by looking at 5 randomly selected student notebooks together.', true WHERE q.order_number = 11
  UNION ALL SELECT 'Agree with them to maintain the relationship and try again next week.', false WHERE q.order_number = 11
  UNION ALL SELECT 'Inform the Principal the teacher is in denial.', false WHERE q.order_number = 11
  
  -- Q12: Voice principle answer = B
  UNION ALL SELECT 'Take it silently to avoid distracting the class.', false WHERE q.order_number = 12
  UNION ALL SELECT 'Use a permission script that names a specific learning curiosity (e.g., "I''m curious how they solved this").', true WHERE q.order_number = 12
  UNION ALL SELECT 'Only take photos of top-performing students.', false WHERE q.order_number = 12
  UNION ALL SELECT 'Send the photo to the Principal immediately for validation.', false WHERE q.order_number = 12
  
  -- Q13: WRER answer = B
  UNION ALL SELECT '66%', false WHERE q.order_number = 13
  UNION ALL SELECT '50% (Missing artifact and interruption count as 0% for those visits).', true WHERE q.order_number = 13
  UNION ALL SELECT '75%', false WHERE q.order_number = 13
  UNION ALL SELECT '40%', false WHERE q.order_number = 13
  
  -- Q14: Heatmap answer = A
  UNION ALL SELECT 'Teachers are following steps (Compliance) but without deep pedagogical dialogue (Praxis).', true WHERE q.order_number = 14
  UNION ALL SELECT 'The app is not being used enough.', false WHERE q.order_number = 14
  UNION ALL SELECT 'Students are not participating.', false WHERE q.order_number = 14
  UNION ALL SELECT 'The coach is not visiting enough.', false WHERE q.order_number = 14
  
  -- Q15: After-Burn answer = B
  UNION ALL SELECT 'Take paper notes and enter them at home.', false WHERE q.order_number = 15
  UNION ALL SELECT 'Complete 100% of app entries (Evidence and Action Steps) inside the school building.', true WHERE q.order_number = 15
  UNION ALL SELECT 'Ask the teacher to enter data.', false WHERE q.order_number = 15
  UNION ALL SELECT 'Only record successful visits.', false WHERE q.order_number = 15
  
  -- Q16: Protocol Duty answer = B
  UNION ALL SELECT 'I''m sorry, but I have too much work to do today.', false WHERE q.order_number = 16
  UNION ALL SELECT 'My WRER is currently at 50%; if I miss this block, Teacher Sara will wait another 7 days for feedback, risking student engagement.', true WHERE q.order_number = 16
  UNION ALL SELECT 'I will do the duty if you promise to give me extra time tomorrow.', false WHERE q.order_number = 16
  UNION ALL SELECT 'The District Office says I am not allowed to do protocol duty.', false WHERE q.order_number = 16
  
  -- Q17: Human Override answer = B
  UNION ALL SELECT 'Tell the teacher to follow the AI suggestion anyway.', false WHERE q.order_number = 17
  UNION ALL SELECT 'Co-design a low-tech alternative (e.g., "Turn-and-Talk") that achieves the same intent.', true WHERE q.order_number = 17
  UNION ALL SELECT 'Mark the visit as "Not Applicable."', false WHERE q.order_number = 17
  UNION ALL SELECT 'Report the lack of resources and skip the coaching step.', false WHERE q.order_number = 17
  
  -- Q18: Robotic Teaching answer = B
  UNION ALL SELECT 'Ignore the observation and celebrate the 100% score.', false WHERE q.order_number = 18
  UNION ALL SELECT 'Use the "Shared Mirror" to ask: "Data shows 100% completion, but looking at these notebooks, what do we notice about actual reasoning?"', true WHERE q.order_number = 18
  UNION ALL SELECT 'Change the dashboard score manually to 0%.', false WHERE q.order_number = 18
  UNION ALL SELECT 'Report the teacher for "Robotic Teaching."', false WHERE q.order_number = 18
  
  -- Q19: Training Loop answer = C
  UNION ALL SELECT 'Planning Loop failure', false WHERE q.order_number = 19
  UNION ALL SELECT 'Observation Loop failure', false WHERE q.order_number = 19
  UNION ALL SELECT 'Training Loop failure (Needs rehearsal to build muscle memory).', true WHERE q.order_number = 19
  UNION ALL SELECT 'Mindset failure', false WHERE q.order_number = 19
  
  -- Q20: Co-Pilot answer = B
  UNION ALL SELECT 'Show the teacher they are the expert.', false WHERE q.order_number = 20
  UNION ALL SELECT 'Act as a "Co-Pilot" by "sliding in" for 2 minutes to model a specific micro-skill.', true WHERE q.order_number = 20
  UNION ALL SELECT 'Finish the lesson for the teacher.', false WHERE q.order_number = 20
  UNION ALL SELECT 'Evaluate students.', false WHERE q.order_number = 20
  
  -- Q21: NOT a path answer = D
  UNION ALL SELECT 'Modify the strategy', false WHERE q.order_number = 21
  UNION ALL SELECT 'Switch to a new strategy', false WHERE q.order_number = 21
  UNION ALL SELECT 'Stay the course', false WHERE q.order_number = 21
  UNION ALL SELECT 'Report failure to administration', true WHERE q.order_number = 21
  
  -- Q22: Silence Myth answer = B
  UNION ALL SELECT 'The teacher doesn''t know the subject matter.', false WHERE q.order_number = 22
  UNION ALL SELECT 'The "Silence Myth": The teacher believes a quiet class copying text is a learning class.', true WHERE q.order_number = 22
  UNION ALL SELECT 'The teacher is lazy and doesn''t want to teach.', false WHERE q.order_number = 22
  UNION ALL SELECT 'The students are too slow to do any other activity.', false WHERE q.order_number = 22
  
  -- Q23: Time stamps answer = B
  UNION ALL SELECT 'Tell them to be faster next time.', false WHERE q.order_number = 23
  UNION ALL SELECT 'Co-design a script with specific time-stamps for each lesson segment.', true WHERE q.order_number = 23
  UNION ALL SELECT 'Model the entire lesson for them.', false WHERE q.order_number = 23
  UNION ALL SELECT 'Mark them as "Not Proficient" in time management.', false WHERE q.order_number = 23
  
  -- Q24: Prioritize answer = B
  UNION ALL SELECT 'The easiest gap to fix.', false WHERE q.order_number = 24
  UNION ALL SELECT 'The "High-Leverage" change that the teacher agrees will impact students most.', true WHERE q.order_number = 24
  UNION ALL SELECT 'The gap the Principal is most concerned about.', false WHERE q.order_number = 24
  UNION ALL SELECT 'All 8 gaps simultaneously to ensure rapid growth.', false WHERE q.order_number = 24
  
  -- Q25: Responsive Contextualization answer = B
  UNION ALL SELECT 'The teacher is unwilling to follow the manual.', false WHERE q.order_number = 25
  UNION ALL SELECT 'A strategy is impossible due to local constraints (60 students, bolted desks).', true WHERE q.order_number = 25
  UNION ALL SELECT 'The coach wants to try a new experiment.', false WHERE q.order_number = 25
  UNION ALL SELECT 'The Principal demands a change.', false WHERE q.order_number = 25
  
  -- Q26: Compliance Trap answer = B
  UNION ALL SELECT 'WRER is 0% but growth is high.', false WHERE q.order_number = 26
  UNION ALL SELECT 'WRER is 100% (visits happening) but Growth Rate is 0% (no behavior change).', true WHERE q.order_number = 26
  UNION ALL SELECT 'Teacher refuses to sign notes.', false WHERE q.order_number = 26
  UNION ALL SELECT 'Principal takes over coaching.', false WHERE q.order_number = 26
  
  -- Q27: Closing the Loop answer = C
  UNION ALL SELECT 'The report is filed.', false WHERE q.order_number = 27
  UNION ALL SELECT 'The coach gives a compliment.', false WHERE q.order_number = 27
  UNION ALL SELECT 'Coach and teacher verify together (Reciprocity) that the new skill is a mastered habit.', true WHERE q.order_number = 27
  UNION ALL SELECT 'Training is completed.', false WHERE q.order_number = 27
  
  -- Q28: Veteran teacher answer = B
  UNION ALL SELECT 'Remind them this is the new "Gold Standard."', false WHERE q.order_number = 28
  UNION ALL SELECT 'Acknowledge their expertise and ask which part of the strategy will work for their community.', true WHERE q.order_number = 28
  UNION ALL SELECT 'Suggest they observe a younger teacher.', false WHERE q.order_number = 28
  UNION ALL SELECT 'Perform modeling without asking permission.', false WHERE q.order_number = 28
  
  -- Q29: Modeling failure answer = B
  UNION ALL SELECT 'Blame previous student behavior.', false WHERE q.order_number = 29
  UNION ALL SELECT 'Use the "Shared Mirror" to admit failure and ask: "What did you notice that I missed?"', true WHERE q.order_number = 29
  UNION ALL SELECT 'Pretend it went well to maintain your "Expert" status.', false WHERE q.order_number = 29
  UNION ALL SELECT 'Delete the failure recording from the app.', false WHERE q.order_number = 29
  
  -- Q30: Praxis answer = B
  UNION ALL SELECT 'Theory is too difficult to read.', false WHERE q.order_number = 30
  UNION ALL SELECT 'It allows the "Human Filter" to adapt the intent of a strategy to fit local high-constraint reality.', true WHERE q.order_number = 30
  UNION ALL SELECT 'It is easier for the coach to grade.', false WHERE q.order_number = 30
  UNION ALL SELECT 'The manual is only a suggestion and not important.', false WHERE q.order_number = 30
) AS opts;
