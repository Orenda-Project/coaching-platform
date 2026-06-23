/**
 * Module 6 seed data — runs in-browser via backend API
 * Triggered from Admin panel → "Seed Module 6" button
 */
import {
  listModules,
  createModule,
  listTrainings,
  createTraining,
  listTrainingContent,
  createTrainingContent,
  deleteTrainingContent,
  listAssessments,
  createAssessment,
  bulkUpsertQuestions,
} from "@/lib/apiClients/adminContentApiClient";

// ─── Slides ───────────────────────────────────────────────────────────────────

const slidesU61 = [
  { title: "Unit 6.1: Closing the Loop", content: "Bridging the Gap Between the Learn and Improve Phases — Turning Conversation Into Classroom Reality", keyPoint: "A coaching cycle that does not close the loop is just conversation. Closing the Loop is what converts insight into student results.", type: "title" },
  { title: "The 'Leaky' Coaching Cycle", content: "In the Pakistan school context, a coaching cycle 'leaks' when a great conversation happens but nothing changes in the classroom.", table: { headers: ["Leaky Cycle (Gap)", "Closed Loop (Success)"], rows: [["Coach and teacher agree on a strategy", "Coach returns to observe whether strategy was used"], ["Teacher passively agrees", "Teacher genuinely commits to a specific, observable action"], ["No follow-up observation", "Follow-up observation within 2 weeks using same metric"], ["Conversation ends the cycle", "Evidence closes the cycle"]] }, keyPoint: "The gap between Learn (conversation) and Improve (classroom reality) is where most coaching impact is lost." },
  { title: "The Coach's Identity Shift: Inspector to Co-Pilot", content: "When closing the loop, the coach's role shifts from data collector to growth co-pilot:", bullets: ["NOT: 'You did not use the transition we planned — why not?'", "YES: 'I noticed the Think-Pair-Share did not happen today — what barrier got in the way?'", "NOT: 'Why is the class still noisy?'", "YES: 'I noticed the signal was not used — what would make it easier to implement?'"], keyPoint: "The Co-Pilot looks for progress, not compliance. The curious opener replaces the compliance check." },
  { title: "The Follow-Up Protocol", bullets: ["STEP 1: Return within 2 weeks of the agreed action step — no exceptions", "STEP 2: Observe using the SAME metric as the baseline (if you counted raised hands, count again)", "STEP 3: Share evidence first: 'Last visit, the count was X. Today, I counted Y.'", "STEP 4: Invite teacher interpretation: 'What do you notice about that change?'", "STEP 5: Teacher chooses next path from the 4 options (Stay the Course, Modify, Switch, Re-identify)"], keyPoint: "Steps 2 and 3 are non-negotiable. Changing the metric between visits destroys the teacher's sense of verifiable progress." },
  { title: "Strong vs. Weak Action Steps", table: { headers: ["Weak Action Step", "Strong Action Step"], rows: [["'Try to engage students more'", "'In the next lesson, use Think-Pair-Share at least once after each explanation'"], ["'Work on classroom management'", "'Use the clap signal within 5 seconds whenever students are off-task during independent work'"], ["'Be more reflective'", "'After each lesson this week, write down one thing you observed about student understanding'"], ["Vague, unmeasurable, coach-imposed", "Bite-sized, observable, teacher-chosen"]] }, keyPoint: "A Strong Action Step is bite-sized, observable, and teacher-chosen. If any of those three are missing, renegotiate." },
  { title: "Pivoting: When the Strategy Does Not Work", content: "When a teacher returns and says: 'I tried it, but it made students anxious.'", bullets: ["WRONG: 'You must keep using it — it is evidence-based'", "WRONG: 'The students are the problem'", "RIGHT: Facilitate a Pivot — ask teacher to choose from the 4 Paths", "'What would you like to adjust about the approach — the timing, the content, or the strategy itself?'", "'Would you like to try a different option from the original menu?'"], keyPoint: "One failed attempt is data, not a verdict. The Pivot is the teacher's choice, not the coach's decision." },
];

const slidesU62 = [
  { title: "Unit 6.2: The Protocol Guardrail", content: "Using Standardized SOPs to Maintain Partnership and Prevent Status Denial — System Fidelity and Protecting the Coaching Space", keyPoint: "A protocol is not a form to complete. It is a structural protection for the coaching relationship — preventing the Partnership Pathway from sliding back into Audit Culture.", type: "title" },
  { title: "High-Fidelity Coaching vs. Audit Drift", table: { headers: ["High-Fidelity (Partnership SOP)", "Audit Drift (Status Denial)"], rows: [["Pre-conference before every observation", "Surprise visit — coach walks in without notice"], ["Teacher voice heard before coach shares data", "Coach delivers verdict before teacher speaks"], ["Teacher chooses next action step", "Coach prescribes the action step"], ["Data shared as a 'Third Party' artifact", "Coach presents data as evidence of failure"], ["Coaching folder is developmental tool", "Coaching notes are shared with principal for evaluation"]] }, keyPoint: "Audit Drift happens one small shortcut at a time. Each shortcut moves the coaching relationship closer to inspection." },
  { title: "The Pre-Conference as a Guardrail", content: "The pre-conference (meeting before the observation) is the first line of defense against Audit Drift.", bullets: ["Without pre-conference: coach walks in as an inspector — teacher performs, not teaches", "With pre-conference: coach and teacher agree on the focus, metric, and observation protocol — teacher teaches authentically", "The 20 minutes saved by skipping the pre-conference costs 20 conversations of trust rebuilding later", "Pre-conference script: 'Today I will observe [focus]. I will track [metric]. We will meet to discuss [time]. Is there anything you want me to notice?'"], keyPoint: "The pre-conference is the step that makes everything else possible. Skipping it makes every subsequent step less effective." },
  { title: "The 'Improve' Phase Guardrail: The 4 Paths", content: "The 4 Paths are not just options — they are a guardrail against the coach prescribing the next action:", bullets: ["STAY THE COURSE: Strategy is working — keep it up", "MODIFY: Partially working — adjust one element of implementation", "SWITCH: Not working — try another option from the menu", "RE-IDENTIFY: Goal itself needs revision — either achieved or wrong"], keyPoint: "The guardrail: if the coach names the path instead of the teacher, the coach has drifted into inspection. The teacher must choose." },
  { title: "Status Confirmation as a Guardrail", content: "Status Confirmation is the practice of using objective evidence to confirm the teacher's professional growth — not the coach's satisfaction.", bullets: ["EVALUATIVE ADJECTIVE (breach): 'That was a bad start to the lesson'", "STATUS CONFIRMATION (guardrail): 'Compare to last visit: student participation moved from 5 to 18 hands raised. The data confirms your strategy is working.'", "The difference: Status Confirmation is objective (count-based) and growth-framed (teacher's growth, not coach's judgment)"], keyPoint: "Status Confirmation protects the teacher's professional identity while providing concrete evidence of progress." },
  { title: "Protecting Data Within the Protocol Guardrail", content: "All data shared within the Protocol Guardrail must be objective student evidence — not coach opinion or evaluative language.", bullets: ["Evidence IN (guardrail): '18 of 40 students were writing at 9:10'", "Opinion OUT (breach): 'Students were not engaged'", "Guardrail test: 'Could this data statement be verified by a video camera?'", "If any coaching data would threaten teacher status — reformulate before sharing"], keyPoint: "The protocol guardrail applies to language as much as to procedure. Every evaluative adjective is a guardrail breach." },
];

const slidesU63 = [
  { title: "Unit 6.3: Responsive Contextualization and Praxis", content: "Adapting Strategies to Reality and Ensuring Action — The Human Filter Applied to Coaching", keyPoint: "A strategy that works in theory but not in this classroom, with these students, under these constraints — is not a strategy. It is a recommendation.", type: "title" },
  { title: "What Is Responsive Contextualization?", content: "Responsive Contextualization is the process of adjusting coaching strategies to fit the actual constraints of the classroom before sharing them with the teacher.", table: { headers: ["Decontextualized Coaching", "Responsive Contextualization"], rows: [["Shares a strategy that requires a projector (school has no electricity)", "Asks about available resources before presenting strategy options"], ["Prescribes 'Think-Pair-Share' for a class of 70+ students", "Adapts the strategy to the class size: 'How would this look with your 70 students?'"], ["Recommends digital tools without checking access", "'Given that students do not have devices, here is a low-tech version...'"], ["Applies AI benchmark without checking classroom context", "Applies the Human Filter before sharing AI data"]] }, keyPoint: "You know the classroom. The strategy does not. You are the bridge between evidence-based practice and this specific context." },
  { title: "Praxis: Learning Happens Through Real Action", content: "PRAXIS (PP-6) is the principle that learning happens through real-world action followed by reflection — not through reading, watching, or discussing.", table: { headers: ["Without Praxis", "With Praxis"], rows: [["Coach and teacher have a great conversation", "Coach and teacher agree on a specific action for the next lesson"], ["Teacher nods and says 'I will try that'", "Teacher articulates: 'In lesson 3 on Thursday, I will use the clap signal during transitions'"], ["No evidence collected", "Coach returns within 2 weeks to observe the specific action"], ["Insight evaporates; practice unchanged", "Reflection on evidence leads to next iteration"]] }, keyPoint: "Praxis converts Reflection into Action. Without the action step, every coaching conversation is incomplete." },
  { title: "The Human Filter in Contextualization", content: "The Human Filter (from Module 1) applies to strategy recommendation just as it applies to AI data:", bullets: ["CONTEXT QUESTION: 'Does this strategy account for the classroom reality I observed — class size, resources, curriculum pressure, teacher experience?'", "BIAS QUESTION: 'Is this strategy drawn from research on classrooms similar to this one?'", "PARTNERSHIP QUESTION: 'Does this strategy preserve teacher choice about how and when to implement it?'"], keyPoint: "A strategy that does not pass the Human Filter should be adapted, not presented. You are the contextualization layer between research and this classroom." },
  { title: "Modeling a Workaround: Responsive Contextualization in Action", content: "A teacher does not have a textbook for a vocabulary lesson. The coach models a workaround:", bullets: ["'Here is what I would do with the words written on the board instead of the book pages'", "Coach models the activity for 3 minutes using available materials", "Coach asks: 'How would you adapt this for your class? What would you change?'", "Teacher owns the adaptation — not the coach's version"], keyPoint: "The Workaround is not a compromise — it is Responsive Contextualization. The constraint becomes a design challenge, not a failure condition." },
  { title: "Reflection Without Action Is a Leaky Cycle", content: "Praxis (PP-6) means that reflection must convert to action before the coaching cycle can be considered complete.", bullets: ["Coach and teacher discuss the lesson in depth", "Teacher says: 'I understand now why the transitions were chaotic'", "Meeting ends without a specific action step", "Result: next lesson, transitions are still chaotic — insight without praxis is forgettable"], keyPoint: "The single most important coaching move at the end of every conversation: 'What is the one specific thing you will try in the next lesson — and how will you know if it is working?'" },
];

const slidesU64 = [
  { title: "Unit 6.4: Reciprocity — The Ethical Defense", content: "Guarding the Sacred Space Against Audit Culture — Professionalism as Integrity", keyPoint: "Reciprocity means both the coach and teacher take risks to maintain the sacred space. The coach takes the professional risk of protecting confidentiality; the teacher takes the professional risk of admitting struggle.", type: "title" },
  { title: "What Is Reciprocity in Unit 6.4?", content: "In Module 6, Reciprocity (PP-7) has a specific meaning: the coach protects the teacher's growth data just as they expect the teacher to be honest and vulnerable in the partnership.", table: { headers: ["Coach's Risk", "Teacher's Risk"], rows: [["Protecting confidentiality from administrative pressure", "Admitting struggles and trying strategies that might fail"], ["Refusing to rank teachers or share evaluative notes", "Sharing authentic challenges rather than performing for the coach"], ["Advocating for teacher growth even under district pressure", "Investing in coaching rather than treating it as inspection"]] }, keyPoint: "The partnership only works if BOTH parties take reciprocal risks. The coach who will not protect data cannot ask teachers to be vulnerable." },
  { title: "Audit Culture as a Threat to Reciprocity", content: "Audit Culture is dangerous to coaching because it triggers Fear and Status Denial, causing teachers to hide their struggles.", bullets: ["Teachers in audit culture: perform for coaches, hide weaknesses, avoid vulnerability", "Result: coaching conversations are performances — not genuine growth partnerships", "The Audit Culture threat is not abstract — it is active in every school in Pakistan", "Your confidentiality protection is the firewall between Audit Culture and Partnership"], keyPoint: "Every time you protect a teacher's data under administrative pressure, you are making reciprocal risk-taking possible for every teacher you coach." },
  { title: "The Reciprocity Defense: Responding to Administrative Pressure", content: "When a principal asks for names of 'failing' teachers, the Reciprocity Defense strategy:", bullets: ["VALIDATE: 'I understand your goal is school improvement — that is exactly what I am working toward.'", "REDIRECT: 'I can share aggregate trends: 70% of teachers are mastering the Planning Loop this month.'", "BOUNDARY: 'My coaching folder is a private developmental space — sharing individual data would end the coaching relationships that produce those trends.'", "OFFER: 'Would a monthly one-page aggregate trend report be useful?'"], keyPoint: "The Reciprocity Defense never just refuses. It validates, redirects, protects, and offers — in that order." },
  { title: "The Sacred Space", content: "The Sacred Space is the professional boundary that ensures coaching remains a developmental tool, not an evaluative one.", bullets: ["Once breached, the Sacred Space requires months of consistent behavior to rebuild", "Teachers who experience Sacred Space violations perform for coaches rather than partnering with them", "Guarding the Sacred Space is not just about confidentiality — it is about the entire coaching climate of the school", "Your professional reputation as a Guardian of Safe Space is the foundation of your impact as a coach"], keyPoint: "The Sacred Space is not a metaphor. It is the specific set of behaviors — confidentiality, partnership language, teacher choice — that creates the conditions for authentic professional growth." },
  { title: "Professionalism as Integrity, Not Compliance", content: "In Unit 6.4, professionalism is redefined:", table: { headers: ["Compliance-Based Professionalism", "Integrity-Based Professionalism"], rows: [["Following every command from administration", "Guarding the integrity of the partnership even under system pressure"], ["Filing required reports on time", "Refusing to file reports that compromise teacher confidentiality"], ["Maintaining good relationships with principals", "Maintaining good relationships while holding the coaching boundary"], ["Doing what is required", "Doing what is right for teacher growth and student outcomes"]] }, keyPoint: "Professionalism as Integrity means: the coaching partnership is the professional standard, not the administrative hierarchy." },
];

// ─── Scenarios ────────────────────────────────────────────────────────────────

const scenarioU61 = {
  steps: [
    {
      id: "s61-1",
      situation: "You had a great 'Learn' session with a teacher about using a 'No-Hands-Up' questioning strategy. However, when you return for the next observation, the teacher has reverted to only calling on students who raise their hands.",
      context: "The teacher had seemed genuinely committed to the strategy in your previous conversation.",
      question: "According to the module, this is a 'Leaky' coaching cycle. What is the most effective way to 'Close the Loop'?",
      branches: [
        { id: "a", text: "Remind the teacher that the Principal is expecting to see this change in their next formal evaluation.", isCorrect: false, rationale: "Invoking the principal converts coaching into compliance monitoring — exactly the status threat the coaching relationship is designed to avoid. This would destroy the trust built in the Learn phase.", principle: "Confidentiality + Status Safety" },
        { id: "b", text: "Mark the teacher as 'Not Proficient' in your weekly report to create accountability.", isCorrect: false, rationale: "Evaluative reports on individual teachers breach confidentiality and turn the coaching program into an audit tool. This is the exact opposite of the Protocol Guardrail.", principle: "Confidentiality + Protocol Guardrail" },
        { id: "c", text: "Use a 'Curious Opener' such as: 'I noticed the No-Hands-Up strategy was not used today — what barrier got in the way of trying that move?'", isCorrect: true, rationale: "This is the Co-Pilot identity in action. The Curious Opener acknowledges the gap without judgment, invites the teacher to explain the barrier (which may be legitimate), and opens a productive conversation about the next step. The loop is being closed — not punished.", principle: "Co-Pilot + Curious Opener + Dialogue" },
        { id: "d", text: "Give the teacher a new, easier strategy since they clearly could not handle the first one.", isCorrect: false, rationale: "Prescribing a new strategy without understanding WHY the first one was not used skips the Curious Opener step and violates Voice (PP-3). The barrier might be logistical, contextual, or confidence-related — and the coach cannot know without asking.", principle: "Voice + Dialogue + Choice" },
      ],
    },
    {
      id: "s61-2",
      situation: "During a follow-up observation, a teacher says: 'I tried the countdown timer for transitions, but it made the students anxious, so I stopped using it.'",
      context: "The teacher chose this strategy themselves from the Micro-skills Menu.",
      question: "A 'Mastery' level coach should respond by:",
      branches: [
        { id: "a", text: "Telling the teacher they must keep using it because it is an evidence-based strategy.", isCorrect: false, rationale: "Mandating that a teacher continue a strategy they found harmful to students violates Choice (PP-2) and ignores real student evidence. Evidence-based does not mean context-universal.", principle: "Choice + Responsive Contextualization" },
        { id: "b", text: "Facilitating a 'Pivot' by asking the teacher if they want to modify the strategy (e.g., visual signal instead of a loud beep) or try a different one from the menu.", isCorrect: true, rationale: "This is the 4 Paths Guardrail applied correctly: the teacher has evidence (students' anxiety reaction), the coach facilitates the Modify or Switch decision, and the teacher owns the pivot. The student evidence is honored.", principle: "4 Paths + Choice + Responsive Contextualization" },
        { id: "c", text: "Agreeing that the students are the problem and moving on to a different topic.", isCorrect: false, rationale: "Blaming students redirects responsibility and abandons the coaching focus. The student response is data — not a reason to abandon the goal.", principle: "Evidence-Based + Praxis" },
        { id: "d", text: "Telling the teacher to ignore the students' anxiety and focus on the clock.", isCorrect: false, rationale: "Ignoring evidence of student harm violates the student-focused goal of the Impact Cycle. If a strategy is creating anxiety, it needs to be modified or replaced — not forced.", principle: "Responsive Contextualization + Student Focus" },
      ],
    },
  ],
};

const scenarioU62 = {
  steps: [
    {
      id: "s62-1",
      situation: "Your Principal calls you into their office and says: 'I am doing a performance audit. Give me the names of the three weakest teachers you are coaching so I can decide whose contracts not to renew.'",
      context: "The principal frames this as being for school improvement purposes.",
      question: "Based on the Module 6 Mastery Rubric, what is the 'Strong Response'?",
      branches: [
        { id: "a", text: "Give the names but ask the Principal to promise not to tell the teachers where the information came from.", isCorrect: false, rationale: "Sharing individual teacher names for contract decisions is a fundamental confidentiality breach — regardless of the promise of anonymity. Teachers in a small school will know the source, and the coaching program will end.", principle: "Confidentiality + Integrity" },
        { id: "b", text: "Refuse to give any information at all and walk out of the room to protect your integrity.", isCorrect: false, rationale: "Total non-engagement abandons the relationship with the principal and misses the opportunity to offer a legitimate alternative. The Reciprocity Defense requires staying in the conversation.", principle: "Dialogue + Advocacy" },
        { id: "c", text: "Validate the Principal's goal of school improvement, but firmly hold the confidentiality boundary and offer to share 'Aggregate Trends' instead of names.", isCorrect: true, rationale: "This is the Reciprocity Defense in full: Validate + Redirect + Boundary + Offer. The coach acknowledges the improvement goal (legitimate), protects individual confidentiality (non-negotiable), and provides aggregate trend data as a genuine alternative that serves the principal's goal.", principle: "Reciprocity Defense + Confidentiality + Advocacy" },
        { id: "d", text: "Provide the names but only for the teachers who have not been nice to you during coaching sessions.", isCorrect: false, rationale: "This uses personal grievances to justify a confidentiality breach — which compounds both ethical and professional failures. There is no scenario in which individual performance data is appropriate to share.", principle: "Confidentiality + Integrity" },
      ],
    },
  ],
};

const scenarioU63 = {
  steps: [
    {
      id: "s63-1",
      situation: "A teacher expresses fear about trying a new, risky student-centered activity while you are observing. You explain: 'I am taking a professional risk by protecting our confidentiality from the administration so that you can feel safe taking a risk with your teaching.'",
      context: "The teacher had been hesitant to try anything new because previous coaches shared their struggles with the principal.",
      question: "This statement is the definition of Reciprocity because:",
      branches: [
        { id: "a", text: "The coach and teacher are becoming best friends.", isCorrect: false, rationale: "Reciprocity in this context is a professional principle, not a social relationship. It describes mutual risk-taking in service of teacher growth and student outcomes.", principle: "Reciprocity + Professionalism" },
        { id: "b", text: "The coach is doing the teacher a favor that the teacher must pay back later.", isCorrect: false, rationale: "Reciprocity is not transactional — it does not create a debt. It is the mutual commitment to the coaching partnership that makes both parties willing to take risks in service of growth.", principle: "Reciprocity + Equality" },
        { id: "c", text: "It recognizes that both the coach and teacher must take risks to maintain the Sacred Space of the coaching partnership.", isCorrect: true, rationale: "This is the precise definition of Reciprocity in Unit 6.4. The coach's risk is professional (protecting confidentiality under administrative pressure). The teacher's risk is pedagogical (trying a new approach that might not work). Both risks are necessary for the partnership to function.", principle: "Reciprocity + Sacred Space + Partnership" },
        { id: "d", text: "It ensures that neither the coach nor the teacher gets in trouble with the District.", isCorrect: false, rationale: "Reciprocity is about enabling growth through mutual risk — not about avoiding institutional consequences. The coach may well face consequences for holding the confidentiality boundary.", principle: "Reciprocity + Integrity" },
      ],
    },
  ],
};

const scenarioU64 = {
  steps: [
    {
      id: "s64-1",
      situation: "You are asked by a district official to share your 'Coaching Journal' notes which contain a teacher's private reflections on their failures and struggles.",
      context: "The official says this is for a district-wide coaching quality review.",
      question: "How does a 'Mastery' coach define Professionalism in this moment?",
      branches: [
        { id: "a", text: "Following the command of the district official because they are higher in the hierarchy.", isCorrect: false, rationale: "Compliance-based professionalism means following commands. Integrity-based professionalism means guarding the partnership even when commanded to breach it. The hierarchy does not override the ethical obligation to the teacher.", principle: "Professionalism as Integrity + Confidentiality" },
        { id: "b", text: "Guarding the integrity of the partnership by explaining that the journal is a developmental tool for the teacher, not an evaluative tool for the system.", isCorrect: true, rationale: "This is Integrity-Based Professionalism: the coaching journal is a private developmental space whose power depends on the teacher knowing it will never be used for evaluation. Sharing it destroys the coaching program, not just the individual relationship.", principle: "Professionalism as Integrity + Sacred Space + Confidentiality" },
        { id: "c", text: "Deleting the notes immediately so that no one can ever see them.", isCorrect: false, rationale: "Deleting records is not the solution — it destroys the coaching artifact that documents the teacher's growth journey. The solution is to hold the boundary while explaining why the data is confidential.", principle: "Integrity + Advocacy" },
        { id: "d", text: "Giving the notes but editing them first to make the teacher look better.", isCorrect: false, rationale: "Editing private journal entries and sharing them with evaluative authorities breaches trust on two levels: sharing what should be confidential, and falsifying the record. Both are integrity failures.", principle: "Integrity + Confidentiality" },
      ],
    },
  ],
};

// ─── Quiz questions ────────────────────────────────────────────────────────────

const quizU61 = [
  { q: "In the Pakistan school context, a coaching cycle 'leaks' when:", options: ["The coach forgets to visit", "A great conversation happens but nothing changes in the classroom", "The students are absent", "The school building is damaged"], correct: 1 },
  { q: "When 'Closing the Loop,' the coach's identity shifts from 'Inspector' to:", options: ["Evaluator", "Co-Pilot looking for progress", "Subject Matter Expert", "Administrative Assistant"], correct: 1 },
  { q: "Closing the Loop is the bridge between which two phases of the Impact Cycle?", options: ["Identify and Learn", "Learn and Improve", "Improve and Identify", "Planning and Audit"], correct: 1 },
  { q: "Which is a 'Curious Opener' designed to replace judgmental statements?", options: ["'You did not use the transition we planned'", "'Why is the class still noisy?'", "'I noticed the Think-Pair-Share did not happen — what barrier got in the way?'", "'The Principal will be unhappy with this lesson'"], correct: 2 },
  { q: "A 'Strong Action Step' in the follow-up protocol must be:", options: ["Broad and complex", "Bite-sized, observable, and teacher-chosen", "Determined solely by the coach", "Based on the annual appraisal form"], correct: 1 },
  { q: "The purpose of returning to the classroom to 'Close the Loop' is to:", options: ["Find faults", "See if the strategy is working and help the teacher 'Pivot' if needed", "Fill out the final report for the District", "Give the students a test"], correct: 1 },
];

const quizU62 = [
  { q: "The 'Protocol Guardrail' is primarily used to ensure the coach:", options: ["Arrives on time", "Does not slip back into 'Inspector Mode' or unsolicited advice", "Follows the school's dress code", "Grades the students accurately"], correct: 1 },
  { q: "'Status Confirmation' serves as a guardrail by:", options: ["Confirming the coach's authority", "Using objective evidence to confirm the teacher's professional growth", "Confirming the teacher's salary", "Confirming the Principal's opinion"], correct: 1 },
  { q: "If a coach uses 'Evaluative Adjectives' (e.g., 'That was a bad start'), they have:", options: ["Provided helpful feedback", "Breached the Protocol Guardrail", "Followed the Impact Cycle", "Demonstrated expertise"], correct: 1 },
  { q: "The 'Improve' phase guardrail requires the teacher to choose one of the '4 Paths.' These paths are:", options: ["Pass, Fail, Retry, Quit", "Modify, Switch, Stay the Course, Re-identify", "Plan, Teach, Observe, Report", "Lecture, Practical, Homework, Test"], correct: 1 },
  { q: "A protocol is considered a 'Guardrail' because it:", options: ["Limits what a teacher can say", "Keeps the conversation partnership-aligned even under pressure", "Slows down the coaching process", "Reports errors to the Principal"], correct: 1 },
  { q: "Data shared within the Protocol Guardrail should always be:", options: ["The coach's opinion", "Objective student evidence (the 'Mirror')", "General impressions", "Subjective judgments"], correct: 1 },
];

const quizU63 = [
  { q: "'Responsive Contextualization' requires a coach to:", options: ["Follow AI suggestions without change", "Adjust strategies to fit constraints like large class sizes or limited resources", "Ignore the classroom environment", "Tell the teacher to buy their own resources"], correct: 1 },
  { q: "'Praxis' (PP-6) is the realization that learning happens through:", options: ["Reading manuals", "Real-world action followed by reflection", "Watching videos of others", "Passing a written test"], correct: 1 },
  { q: "The 'Human Filter' is essential in this unit because:", options: ["AI is always wrong", "The coach must contextualize data to make it realistic for the teacher", "The coach needs to look busy", "It prevents teachers from talking"], correct: 1 },
  { q: "Reflection without action (Praxis) results in:", options: ["Professionalism", "A 'Leaky' coaching cycle", "Excellence", "Hierarchy"], correct: 1 },
  { q: "A coach modeling a 'Workaround' for a missing textbook is an example of:", options: ["Laziness", "Responsive Contextualization", "Audit Culture", "Expertise"], correct: 1 },
  { q: "The goal of Praxis in Module 6 is to turn 'Coaching Conversations' into:", options: ["Written reports", "Observable student results", "Longer meetings", "Principal approvals"], correct: 1 },
];

const quizU64 = [
  { q: "In the context of Unit 6.4, 'Reciprocity' means:", options: ["The teacher giving the coach a gift", "The coach protecting the teacher's growth data just as they expect the teacher to grow", "The coach and teacher swapping roles", "Reporting every detail to the Principal"], correct: 1 },
  { q: "'Audit Culture' is dangerous to coaching because it triggers:", options: ["Rapid growth", "Fear and 'Status Denial,' causing teachers to hide their struggles", "Better student scores", "Increased funding"], correct: 1 },
  { q: "When a Principal asks for names of 'failing' teachers, the Reciprocity Defense suggests:", options: ["Giving the names to avoid trouble", "Redirecting to 'Aggregate Trends' (e.g., '70% of teachers are mastering the Planning Loop')", "Telling the Principal it is none of their business", "Quitting the coaching job"], correct: 1 },
  { q: "The 'Sacred Space' is the professional boundary that ensures:", options: ["The coach has their own office", "Coaching remains a developmental tool, not an evaluative one", "Only religious subjects are taught", "The classroom door is locked"], correct: 1 },
  { q: "A 'Strong' response to administrative pressure involves:", options: ["Total compliance", "Validating the Principal's goal while firmly holding the confidentiality boundary", "Blaming the teacher", "Sharing the teacher's personal journal"], correct: 1 },
  { q: "Professionalism in Unit 6.4 is defined as:", options: ["Following every command", "Guarding the integrity of the partnership even under system pressure", "Finishing paperwork on time", "Keeping secrets from everyone"], correct: 1 },
];

// ─── Open-ended questions ──────────────────────────────────────────────────────

const openEndedU61 = [
  {
    q: "You had a great 'Learn' session with a teacher about using a 'No-Hands-Up' questioning strategy. When you return, the teacher has reverted to only calling on students who raise their hands. This is a 'Leaky' coaching cycle. What is the most effective way to 'Close the Loop'?",
    rubric: "Score 2: Use a Curious Opener — 'I noticed the No-Hands-Up strategy was not used today — what barrier got in the way?' — Co-Pilot identity (looks for progress, not compliance); the barrier may be legitimate; opens productive conversation rather than punishing non-compliance. Score 1: Identifies using a curious question without explaining the Co-Pilot framing or the loop-closure mechanism. Score 0: Invokes principal authority or marks teacher as not proficient.",
  },
  {
    q: "During a follow-up, a teacher says: 'I tried the timer, but it made the students anxious, so I stopped using it.' A 'Mastery' level coach should respond by facilitating a 'Pivot.' What does this mean and how does it preserve teacher choice?",
    rubric: "Score 2: The Pivot uses the 4 Paths — Modify (adjust implementation, e.g., visual signal instead of loud beep) or Switch (try another menu option); teacher has real evidence (student anxiety) that justifies re-evaluating the strategy; teacher chooses the path, not the coach; student evidence is honored, not dismissed. Score 1: Describes offering alternatives without applying the 4 Paths or explaining that the teacher must choose. Score 0: Mandates the teacher keep using the timer because it is evidence-based.",
  },
];

const openEndedU62 = [
  {
    q: "Your Principal calls into their office and says: 'Give me the names of the three weakest teachers you are coaching so I can decide whose contracts not to renew.' Based on the Module 6 Mastery Rubric, what is the Strong Response?",
    rubric: "Score 2: Validate the Principal's improvement goal + Redirect to aggregate trends + Hold the confidentiality boundary + Offer a monthly trend report alternative — explain why individual data would end coaching effectiveness for everyone. Score 1: Holds the boundary without offering an alternative or explaining the mechanism. Score 0: Provides the names or gives data about individuals.",
  },
  {
    q: "Explain the difference between 'Compliance-Based Professionalism' and 'Integrity-Based Professionalism' in Unit 6.2. Give a specific example of each.",
    rubric: "Score 2: Compliance = following administrative commands (sharing notes, ranking teachers) even when it harms coaching; Integrity = guarding the partnership standard even under institutional pressure; example of compliance: sharing coaching notes to avoid conflict with principal; example of integrity: explaining why coaching notes cannot be shared while offering a legitimate alternative. Score 1: Distinguishes the two without specific examples. Score 0: Says integrity means keeping secrets or being uncooperative with administration.",
  },
];

const openEndedU63 = [
  {
    q: "A teacher expresses fear about trying a new risky activity. The coach says: 'I am taking a professional risk by protecting our confidentiality so that you can feel safe taking a risk with your teaching.' Why is this an example of Reciprocity (PP-7)?",
    rubric: "Score 2: Reciprocity = both parties take reciprocal risks in service of the partnership; coach's risk is professional (confidentiality protection); teacher's risk is pedagogical (trying something new that might fail); the Sacred Space is maintained through mutual risk-taking, not just coach protection. Score 1: Identifies that both take risks without explaining the mechanism of mutual risk in service of growth. Score 0: Describes Reciprocity as personal friendship or transactional exchange.",
  },
  {
    q: "Describe what 'Responsive Contextualization' means and give a Pakistan-specific example of when a coach would need to apply it before sharing a strategy with a teacher.",
    rubric: "Score 2: Responsive Contextualization = adjusting strategies to fit actual classroom constraints before presenting them; Pakistan example shows awareness of local reality (class size 60+, no electricity/devices, Urdu-medium, resource constraints); the coach applies the Human Filter (Context question) to the strategy before presenting it. Score 1: Defines contextualization without a specific Pakistan example. Score 0: Says it means using local language or building rapport.",
  },
];

const openEndedU64 = [
  {
    q: "You are asked by a district official to share your Coaching Journal notes which contain a teacher's private reflections. How does a 'Mastery' coach define Professionalism in this moment?",
    rubric: "Score 2: Integrity-Based Professionalism = guarding the partnership even under system pressure; explain that the journal is a developmental tool whose power depends on confidentiality; sharing it destroys coaching effectiveness for every teacher, not just this one; offer an aggregate alternative while holding the boundary. Score 1: Refuses to share without explaining the principle behind the refusal. Score 0: Complies because the official is higher in the hierarchy, or deletes the notes without addressing the request.",
  },
  {
    q: "What is the 'Sacred Space' in partnership coaching, and what happens to coaching effectiveness when it is breached?",
    rubric: "Score 2: Sacred Space = the professional boundary ensuring coaching remains developmental (not evaluative); breach consequences: teachers perform rather than partner, hide struggles, stop being vulnerable, coaching becomes inspection; rebuilding takes months of consistent boundary-holding; every breach affects not just the individual relationship but the entire coaching climate of the school. Score 1: Defines the Sacred Space without explaining the specific consequences of a breach. Score 0: Confuses Sacred Space with a physical location or describes it as keeping secrets.",
  },
];

// ─── Main seed function ────────────────────────────────────────────────────────

export async function seedModule6(): Promise<{ success: boolean; log: string[] }> {
  const log: string[] = [];

  const units = [
    { order: 1, title: "Unit 6.1: Closing the Loop", description: "Bridging the Learn and Improve phases through follow-up protocols and Curious Openers that convert conversation to classroom reality", concepts: "Leaky coaching cycle, Follow-Up Protocol, Co-Pilot identity, Strong Action Steps, Pivot facilitation, 4 Paths", slides: slidesU61, scenario: scenarioU61, quiz: quizU61, openEnded: openEndedU61 },
    { order: 2, title: "Unit 6.2: The Protocol Guardrail", description: "Using standardized coaching SOPs to prevent drift back into inspection mode and protect the coaching space", concepts: "High-Fidelity vs. Audit Drift, Pre-Conference Guardrail, 4 Paths Guardrail, Status Confirmation, data protection within protocol", slides: slidesU62, scenario: scenarioU62, quiz: quizU62, openEnded: openEndedU62 },
    { order: 3, title: "Unit 6.3: Responsive Contextualization and Praxis", description: "Adapting strategies to real classroom constraints and ensuring coaching conversations end in observable action", concepts: "Responsive Contextualization, Praxis (PP-6), Human Filter for strategies, Workaround modeling, Reflection without action = Leaky cycle", slides: slidesU63, scenario: scenarioU63, quiz: quizU63, openEnded: openEndedU63 },
    { order: 4, title: "Unit 6.4: Reciprocity — The Ethical Defense", description: "Guarding the Sacred Space of coaching against audit culture through mutual risk-taking and integrity-based professionalism", concepts: "Reciprocity Defense, Audit Culture threat, Sacred Space, Reciprocity as mutual risk, Integrity vs. Compliance professionalism", slides: slidesU64, scenario: scenarioU64, quiz: quizU64, openEnded: openEndedU64 },
  ];

  try {
    const { modules: allModules } = await listModules();
    type ModuleRow = { id: string; title?: string; order_number?: number };
    let mod = (allModules as ModuleRow[]).find((m) => m.order_number === 6);

    if (mod) {
      log.push(`✅ Module already exists: ${mod.id}`);
    } else {
      mod = (await createModule({
        title: "Module 6: The Excellence Loop",
        description: "Closing coaching loops, applying protocol guardrails, contextualizing strategies to real classroom constraints, and guarding the Sacred Space through Reciprocity and integrity-based professionalism.",
        is_mandatory: false,
        order_number: 6,
        competencies: "Loop Closure, Protocol Fidelity, Responsive Contextualization, Praxis, Reciprocity Defense, Integrity-Based Professionalism",
        desired_outcomes: "Apply follow-up protocols, use guardrails against audit drift, adapt strategies to context, facilitate pivots, defend confidentiality under pressure",
      })) as ModuleRow;
      log.push(`✅ Module created: ${mod.title}`);
    }

    for (const unit of units) {
      type TrainingRow = { id: string; order_number?: number };
      const { trainings: modTrainings } = await listTrainings(mod.id);
      let training = (modTrainings as TrainingRow[]).find((t) => t.order_number === unit.order);

      if (training) {
        log.push(`✅ Unit already exists: ${unit.title}`);
      } else {
        training = (await createTraining({
          title: unit.title,
          description: unit.description,
          main_concepts: unit.concepts,
          is_common: true,
          module_id: mod.id,
          order_number: unit.order,
        })) as TrainingRow;
        log.push(`✅ Unit: ${unit.title}`);
      }

      const { content: oldContent } = await listTrainingContent(training.id);
      for (const c of oldContent as { id: string }[]) {
        await deleteTrainingContent(c.id);
      }

      try {
        await createTrainingContent({
          training_id: training.id,
          format_type: "slides",
          content_url: JSON.stringify(unit.slides),
        });
        log.push(`  📊 Slides: ${unit.slides.length} slides`);
      } catch (e) {
        log.push(`  ❌ Slides error: ${e instanceof Error ? e.message : String(e)}`);
      }

      try {
        await createTrainingContent({
          training_id: training.id,
          format_type: "scenario",
          content_url: JSON.stringify(unit.scenario),
        });
        log.push(`  🎭 Scenario: ${unit.scenario.steps.length} situations`);
      } catch (e) {
        log.push(`  ❌ Scenario error: ${e instanceof Error ? e.message : String(e)}`);
      }

      type AssessmentRow = { id: string };
      const { assessments: existingAssessments } = await listAssessments({
        trainingId: training.id,
        type: "module_quiz",
      });
      let assessment = (existingAssessments as AssessmentRow[])[0];

      if (assessment) {
        log.push(`  📋 Assessment already exists`);
      } else {
        assessment = (await createAssessment({
          title: `${unit.title} — Quiz`,
          type: "module_quiz",
          training_id: training.id,
        })) as AssessmentRow;
        log.push(`  📋 Assessment created`);
      }

      const allQuestions = [
        ...unit.quiz.map((q, i) => ({
          question_text: q.q,
          question_type: "mcq",
          order_number: i + 1,
          max_score: 1,
          options: q.options.map((opt, idx) => ({
            text: opt,
            is_correct: idx === q.correct,
          })),
        })),
        ...unit.openEnded.map((q, i) => ({
          question_text: q.q,
          question_type: "open",
          order_number: unit.quiz.length + i + 1,
          max_score: 2,
          correct_answer: q.rubric,
        })),
      ];
      await bulkUpsertQuestions(assessment.id, allQuestions);
      log.push(`  ❓ Quiz: ${unit.quiz.length} MCQ + ${unit.openEnded.length} open-ended questions`);
    }

    log.push("✅ Module 6 seed complete!");
    return { success: true, log };
  } catch (err: unknown) {
    log.push(`❌ Fatal error: ${err instanceof Error ? err.message : String(err)}`);
    return { success: false, log };
  }
}
