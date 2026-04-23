import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://kddvxrlffafyjvvststh.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtkZHZ4cmxmZmFmeWp2dnN0c3RoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU4MjA0NDQsImV4cCI6MjA5MTM5NjQ0NH0.zJLIoTzQEhoBSlW4nRzKkjue2WR5YAHX8ymtUeJEITY';

const supabase = createClient(supabaseUrl, supabaseAnonKey);

async function deleteOldBaselineAndCreate() {
  console.log('Starting baseline v2 migration...\n');

  try {
    // 1. Get baseline assessment
    const { data: baselineAssessment, error: fetchError } = await supabase
      .from('assessments')
      .select('id')
      .eq('type', 'baseline')
      .single();

    if (fetchError && fetchError.code !== 'PGRST116') {
      console.error('Error fetching baseline assessment:', fetchError);
      return;
    }

    if (baselineAssessment) {
      console.log('Found existing baseline assessment:', baselineAssessment.id);
      console.log('Deleting old baseline questions and options...');

      // Delete options
      const { error: deleteOptionsError } = await supabase
        .from('options')
        .delete()
        .in('question_id', supabase
          .from('questions')
          .select('id')
          .eq('assessment_id', baselineAssessment.id)
        );

      // Delete questions
      const { error: deleteQuestionsError } = await supabase
        .from('questions')
        .delete()
        .eq('assessment_id', baselineAssessment.id);

      // Delete assessment
      const { error: deleteAssessmentError } = await supabase
        .from('assessments')
        .delete()
        .eq('id', baselineAssessment.id);

      if (deleteOptionsError || deleteQuestionsError || deleteAssessmentError) {
        console.log('Note: Some deletions may not have permissions via anon key');
      } else {
        console.log('✓ Deleted old baseline assessment');
      }
    }

    // 2. Create new baseline assessment
    console.log('\nCreating new baseline assessment...');
    const { data: newAssessment, error: insertAssessmentError } = await supabase
      .from('assessments')
      .insert([{ type: 'baseline', title: 'Coach Baseline Assessment V2' }])
      .select()
      .single();

    if (insertAssessmentError) {
      console.error('Error creating assessment:', insertAssessmentError);
      console.log('\nNote: You may need permissions to create records.');
      console.log('Please apply the migration manually via:');
      console.log('1. Supabase dashboard: https://app.supabase.com/');
      console.log('2. Or via CLI: supabase db push --linked');
      return;
    }

    console.log('✓ Created new assessment:', newAssessment.id);

    // 3. Define all baseline v2 questions
    const baselineQuestions = [
      // Module 2: The Partnership Foundation (Trust & Status) - 6 questions
      'According to the SCARF model, a veteran teacher saying they don\'t need a coach is a direct threat to:',
      'When a teacher displays "Flight" behavior (minimal responses), it likely indicates the coach has:',
      'A Principal demands individual teacher engagement scores for "Show Cause" notices. According to the Universal SOP, you should:',
      'Case Study: A veteran teacher reacts with "Freeze" behavior. Which Opening Script best uses Equality and Voice?',
      'Case Study: During feedback, a teacher is defensive. To move to a Side-by-Side mindset, you should:',
      'Case Study: A teacher is struggling with a noisy class. Instead of a "fix," you use Deep Empathy by saying:',
      
      // Module 3: The Mirror Specialist (Shared Reality) - 6 questions
      'What is the primary purpose of capturing "Data at the Edge" (e.g., back-row notebooks)?',
      'If a coach and teacher score the same lesson differently, this "Calibration Gap" is usually caused by:',
      'The Human Filter rule states that a coach should NOT capture an artifact if:',
      'Case Study: Which observation note successfully passes the "Camera Test" by removing judgment?',
      'Case Study: A teacher insists a class was "perfect," but data shows 0% passed the exit ticket. You should:',
      'Case Study: When taking a digital photo of student work, the Voice principle requires you to:',
      
      // Module 4: Digital & Data Intelligence (Collaborative Analytics) - 6 questions
      'Coach Usman had 6 visits. 1 holiday, 1 absent teacher, 1 visit with no artifact, and 1 interrupted. What is his WRER?',
      'What does a "High Fidelity" but "Low Impact" score on a Regional Heatmap suggest?',
      'To avoid the "Administrative After-Burn," a coach should:',
      'Case Study: A Principal displaces your coaching block for duty. Which Advocacy Script is best?',
      'Case Study: An AI dashboard suggests "Use digital tools," but there is no electricity. You:',
      'Case Study: A dashboard shows 100% task completion, but you observe students just copying. You should:',
      
      // Module 5: The Instructional Catalyst (Co-Design) - 6 questions
      'A teacher explains a strategy perfectly but fails to use it in a noisy classroom. This is a:',
      'In Side-by-Side Co-Modeling, the coach\'s goal is to:',
      'If a goal is not met after two visits, the Improve Phase requires one of 4 Paths. Which is NOT a path?',
      'Case Study: A teacher has students copy an entire textbook chapter. You identify the Belief Gap as:',
      'Case Study: A teacher spends 20 minutes on a 5-minute intro. You diagnose this as a Planning Loop failure and:',
      'Case Study: When a teacher has 8 skill gaps, a "Catalyst" coach prioritizes:',
      
      // Module 6: The Excellence Loop (Reciprocity & Praxis) - 6 questions
      '"Responsive Contextualization" is necessary when:',
      'The "Compliance Trap" occurs when:',
      '"Closing the Loop" is only achieved when:',
      'Case Study: A veteran teacher is skeptical of a new strategy. The most Reciprocal move is to:',
      'Case Study: You model a strategy and it fails (chaotic classroom). To maintain Shared Reality, you:',
      'Case Study: Why is Praxis (action-based learning) prioritized over "Abstract Theory"?'
    ];

    console.log(`\nInserting ${baselineQuestions.length} baseline v2 questions...`);

    // Insert questions
    const { data: questionsData, error: insertQuestionsError } = await supabase
      .from('questions')
      .insert(baselineQuestions.map((text, idx) => ({
        assessment_id: newAssessment.id,
        question_type: 'mcq',
        question_text: text,
        order_number: idx + 1
      })))
      .select();

    if (insertQuestionsError) {
      console.error('Error inserting questions:', insertQuestionsError);
      return;
    }

    console.log(`✓ Inserted ${questionsData.length} questions`);

    // 4. Define options for each question
    const optionsMap = {
      1: [ // Q1: SCARF model
        { text: 'Certainty', correct: false },
        { text: 'Status', correct: true },
        { text: 'Autonomy', correct: false },
        { text: 'Relatedness', correct: false }
      ],
      2: [ // Q2: Flight behavior
        { text: 'Triggered a Status Threat by using evaluative language rather than low-inference data.', correct: true },
        { text: 'Failed to provide enough expert advice regarding the specific pedagogical strategies.', correct: false },
        { text: 'Spent too much time listening to the teacher\'s concerns instead of taking notes.', correct: false },
        { text: 'Not followed the NEO-1 checklist strictly enough to ensure a professional visit.', correct: false }
      ],
      3: [ // Q3: Show Cause notices
        { text: 'Share the scores but ask the Principal to keep the individual names confidential.', correct: false },
        { text: 'Provide a list of only the "top-performing" teachers to maintain school morale.', correct: false },
        { text: 'Refuse and offer a "System-Trends" report to protect individual teacher trust.', correct: true },
        { text: 'Tell the Principal you will ask the teachers for their written permission first.', correct: false }
      ],
      4: [ // Q4: Freeze behavior Opening Script
        { text: 'I\'m here to help you improve your classroom management with some expert tips.', correct: false },
        { text: 'I\'m here as a partner to learn alongside you; what is a specific goal you have?', correct: true },
        { text: 'The District Office requires me to audit this lesson for performance tracking.', correct: false },
        { text: 'I will be watching to see if you are following the standard manual correctly.', correct: false }
      ],
      5: [ // Q5: Defensive teacher
        { text: 'Re-read the rubric to show them exactly where their performance failed to meet goals.', correct: false },
        { text: 'Remind them that your role is to give expert advice they must follow for the program.', correct: false },
        { text: 'Physically sit next to them and look at student work together, asking "What do you see?"', correct: true },
        { text: 'Suggest they observe a younger teacher who is more compliant with the modern methods.', correct: false }
      ],
      6: [ // Q6: Noisy class Deep Empathy
        { text: 'It sounds frustrating when you\'ve planned a lesson and the back row isn\'t engaging.', correct: true },
        { text: 'You should use a whistle or a louder clap to get their attention more quickly.', correct: false },
        { text: 'In my day, I handled 80 students by doing specific management techniques.', correct: false },
        { text: 'I will mark this as a practice visit so it doesn\'t hurt your official record.', correct: false }
      ],
      7: [ // Q7: Data at the Edge
        { text: 'To catch the teacher ignoring students who are sitting far away from the podium.', correct: false },
        { text: 'To find the truth of student learning often hidden by activity at the "Center."', correct: true },
        { text: 'To provide documented evidence for administrative "Show Cause" or warning notices.', correct: false },
        { text: 'To satisfy the digital application requirements for capturing multiple artifacts.', correct: false }
      ],
      8: [ // Q8: Calibration Gap
        { text: 'One person is a "mean" grader while the other is trying to be "supportive."', correct: false },
        { text: 'The rubric is too complex for the teacher to understand without prior training.', correct: false },
        { text: 'Using subjective "feelings" instead of a shared mirror of objective classroom facts.', correct: true },
        { text: 'The teacher acts differently toward the coach than they do toward the students.', correct: false }
      ],
      9: [ // Q9: Human Filter rule
        { text: 'The lighting in the room is poor, and the photo will not be clear for the dashboard.', correct: false },
        { text: 'A student is visibly distressed, or the teacher is in an acute emotional crisis.', correct: true },
        { text: 'The coach forgot their tablet and has to rely on memory for the digital entry.', correct: false },
        { text: 'The teacher is using a non-standard strategy that is not mentioned in the manual.', correct: false }
      ],
      10: [ // Q10: Camera Test
        { text: 'The teacher was too lazy to check the homework assigned during the previous day.', correct: false },
        { text: 'The teacher gave a very clear and concise explanation of the complex science topic.', correct: false },
        { text: 'At 11:15 AM, 12 of 68 students were writing; 56 students sat with blank pages.', correct: true },
        { text: 'The classroom was noisy because the teacher lost control of the student behavior.', correct: false }
      ],
      11: [ // Q11: Third Partner
        { text: 'Argue the data points until the teacher admits their assessment of the class was wrong.', correct: false },
        { text: 'Introduce the "Third Partner" by looking at 5 randomly selected student notebooks.', correct: true },
        { text: 'Agree with them to maintain the relationship and try to address the issue next week.', correct: false },
        { text: 'Inform the Principal immediately that the teacher is in denial about student progress.', correct: false }
      ],
      12: [ // Q12: Voice principle with photos
        { text: 'Take it silently to avoid distracting the class or interrupting the teacher\'s flow.', correct: false },
        { text: 'Only take photos of top-performing students to show the potential of the strategy.', correct: false },
        { text: 'Use a permission script that names a specific learning curiosity you want to explore.', correct: true },
        { text: 'Send the photo to the Principal immediately for validation and official record keeping.', correct: false }
      ],
      13: [ // Q13: WRER calculation
        { text: '66%', correct: false },
        { text: '75%', correct: true },
        { text: '50%', correct: false },
        { text: '40%', correct: false }
      ],
      14: [ // Q14: High Fidelity Low Impact
        { text: 'Teachers are following the steps (Compliance) but without deep pedagogical dialogue.', correct: true },
        { text: 'The digital application is not being used frequently enough by the coaching staff.', correct: false },
        { text: 'Students are not participating because the strategy is too difficult for their level.', correct: false },
        { text: 'The coach is not visiting the assigned schools enough to make a lasting difference.', correct: false }
      ],
      15: [ // Q15: Administrative After-Burn
        { text: 'Take paper notes and enter them into the system at home during the evening hours.', correct: false },
        { text: 'Complete 100% of app entries (Evidence and Action Steps) inside the school building.', correct: true },
        { text: 'Ask the teacher to enter the data themselves to ensure they agree with the findings.', correct: false },
        { text: 'Only record successful visits to ensure the regional dashboard remains positive.', correct: false }
      ],
      16: [ // Q16: Principal displaces coaching block
        { text: 'I\'m sorry, but I have too much administrative work to complete for the district today.', correct: false },
        { text: 'I will do the duty if you promise to give me extra time to visit teachers tomorrow.', correct: false },
        { text: 'My WRER is at 50%; if I miss this, Teacher Sara waits 7 days, risking kids.', correct: true },
        { text: 'The District Office says I am not allowed to perform any non-coaching duties today.', correct: false }
      ],
      17: [ // Q17: AI dashboard without electricity
        { text: 'Tell the teacher to follow the AI suggestion anyway to maintain program fidelity.', correct: false },
        { text: 'Co-design a low-tech alternative (e.g., "Turn-and-Talk") that achieves the same intent.', correct: true },
        { text: 'Mark the visit as "Not Applicable" and move to the next teacher on your list.', correct: false },
        { text: 'Report the lack of resources and skip the coaching step until electricity is restored.', correct: false }
      ],
      18: [ // Q18: 100% task completion but just copying
        { text: 'Ignore the observation and celebrate the 100% score to maintain a positive relationship.', correct: false },
        { text: 'Use the "Shared Mirror" to ask: "Data shows 100% completion, but what do we notice?"', correct: true },
        { text: 'Change the dashboard score manually to 0% to reflect the lack of real learning.', correct: false },
        { text: 'Report the teacher for "Robotic Teaching" and request a formal review of their methods.', correct: false }
      ],
      19: [ // Q19: Noisy classroom strategy failure
        { text: 'Planning Loop failure regarding the preparation of the lesson materials and timing.', correct: false },
        { text: 'Observation Loop failure where the coach failed to see the teacher\'s actual intent.', correct: false },
        { text: 'Training Loop failure (Needs rehearsal to build muscle memory for the teacher).', correct: true },
        { text: 'Mindset failure where the teacher does not believe the students are capable of it.', correct: false }
      ],
      20: [ // Q20: Side-by-Side Co-Modeling goal
        { text: 'Show the teacher they are the expert by teaching the most difficult part of the class.', correct: false },
        { text: 'Act as a "Co-Pilot" by "sliding in" for 2 minutes to model a specific micro-skill.', correct: true },
        { text: 'Finish the entire lesson for the teacher so the students stay focused on the task.', correct: false },
        { text: 'Evaluate student behavior and report back to the teacher at the end of the period.', correct: false }
      ],
      21: [ // Q21: Improve Phase Paths
        { text: 'Modify the strategy', correct: false },
        { text: 'Switch to a new strategy', correct: false },
        { text: 'Stay the course', correct: false },
        { text: 'Report failure to administration', correct: true }
      ],
      22: [ // Q22: Belief Gap with copying
        { text: 'The teacher doesn\'t know the subject matter well enough to explain it to students.', correct: false },
        { text: 'The "Silence Myth": believing a quiet class copying text is a learning class.', correct: true },
        { text: 'The teacher is lazy and doesn\'t want to spend time preparing an interactive lesson.', correct: false },
        { text: 'The students are too slow to do any other activity without direct copying of text.', correct: false }
      ],
      23: [ // Q23: Long intro Planning Loop
        { text: 'Tell them to be faster next time and use a stopwatch to monitor their progress.', correct: false },
        { text: 'Co-design a script with specific time-stamps for each individual lesson segment.', correct: true },
        { text: 'Model the entire lesson for them to show how the timing should properly work.', correct: false },
        { text: 'Mark them as "Not Proficient" in time management in the final coaching report.', correct: false }
      ],
      24: [ // Q24: Eight skill gaps prioritization
        { text: 'The easiest gap to fix to build momentum and teacher confidence quickly.', correct: false },
        { text: 'The "High-Leverage" change that the teacher agrees will impact students most.', correct: true },
        { text: 'The gap the Principal is most concerned about based on their recent observations.', correct: false },
        { text: 'All 8 gaps simultaneously to ensure rapid growth across all teaching domains.', correct: false }
      ],
      25: [ // Q25: Responsive Contextualization
        { text: 'The teacher is unwilling to follow the manual despite having the resources to do so.', correct: false },
        { text: 'A strategy is impossible due to local constraints like 60 students and bolted desks.', correct: true },
        { text: 'The coach wants to try a new pedagogical experiment to see if the students like it.', correct: false },
        { text: 'The Principal demands a change in the coaching schedule to accommodate a meeting.', correct: false }
      ],
      26: [ // Q26: Compliance Trap
        { text: 'WRER is 0% but growth is unexpectedly high across the majority of classrooms.', correct: false },
        { text: 'The teacher refuses to sign the coaching notes because they disagree with the data.', correct: false },
        { text: 'WRER is 100% (visits happening) but Growth Rate is 0% (no behavior change).', correct: true },
        { text: 'The Principal takes over the coaching session and dictates the teacher\'s action steps.', correct: false }
      ],
      27: [ // Q27: Closing the Loop
        { text: 'The final coaching report is filed and signed by both the coach and the Principal.', correct: false },
        { text: 'The coach gives a specific compliment about the teacher\'s effort during the visit.', correct: false },
        { text: 'Coach and teacher verify together that the new skill is a mastered habit.', correct: true },
        { text: 'The central office training is completed and the teacher receives their certificate.', correct: false }
      ],
      28: [ // Q28: Skeptical veteran teacher
        { text: 'Remind them that this strategy is the new "Gold Standard" required by the district.', correct: false },
        { text: 'Acknowledge their expertise and ask which part of the strategy fits their classroom.', correct: true },
        { text: 'Suggest they observe a younger teacher who has mastered the new digital tools.', correct: false },
        { text: 'Perform modeling in their classroom without asking for their specific permission.', correct: false }
      ],
      29: [ // Q29: Model fails in chaos
        { text: 'Blame previous student behavior or lack of school-wide discipline for the failure.', correct: false },
        { text: 'Use the "Shared Mirror" to admit failure and ask: "What did you notice I missed?"', correct: true },
        { text: 'Pretend it went well to maintain your "Expert" status and the teacher\'s respect.', correct: false },
        { text: 'Delete the failure recording from the app so it doesn\'t skew your performance data.', correct: false }
      ],
      30: [ // Q30: Praxis over Abstract Theory
        { text: 'Theory is too difficult for most teachers to read and apply in a busy school day.', correct: false },
        { text: 'It is much easier for the coach to grade a physical action than an abstract idea.', correct: false },
        { text: 'It allows the "Human Filter" to adapt the intent of a strategy to fit local reality.', correct: true },
        { text: 'The manual is only a suggestion and should not be followed strictly by teachers.', correct: false }
      ]
    };

    console.log(`\nInserting options for ${Object.keys(optionsMap).length} questions...`);

    // Insert options
    let totalOptions = 0;
    for (const question of questionsData) {
      const qNum = question.order_number;
      const optionsForQuestion = optionsMap[qNum] || [];
      
      if (optionsForQuestion.length > 0) {
        const { error: insertError } = await supabase
          .from('options')
          .insert(optionsForQuestion.map(opt => ({
            question_id: question.id,
            option_text: opt.text,
            is_correct: opt.correct
          })));

        if (insertError) {
          console.error(`Error inserting options for question ${qNum}:`, insertError);
        } else {
          totalOptions += optionsForQuestion.length;
        }
      }
    }

    console.log(`✓ Inserted ${totalOptions} options`);
    console.log('\n✅ Baseline V2 migration completed successfully!');
    console.log(`Total: ${questionsData.length} questions with ${totalOptions} options`);

  } catch (error) {
    console.error('Migration failed:', error);
  }
}

deleteOldBaselineAndCreate();
