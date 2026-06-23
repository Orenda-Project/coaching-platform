/**
 * Module 4 seed data — runs in-browser via backend API
 * Triggered from Admin panel → "Seed Module 4" button
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

const slidesU41 = [
  { title: "Unit 4.1: The Digital Journal", content: "Adding the Human Heart to Data Through Annotation — From Data Collector to Biographer of Growth", keyPoint: "A photo is a snapshot. A Digital Journal is a story of professional growth across the full Impact Cycle.", type: "title" },
  { title: "The Identity Shift: Data Collector to Biographer of Growth", content: "In Units 3.1–3.3 you learned to collect low-inference facts and anchor ratings to artifacts. In this unit you add the layer that transforms raw data into a coaching narrative.", table: { headers: ["Data Collector", "Biographer of Growth"], rows: [["Stores photos and T-Charts", "Adds Human Annotation — insights, questions, PP references"], ["Evidence is a record of what happened", "Evidence becomes a story of how the teacher grew"], ["Journal tracks compliance", "Journal tracks professional journey"], ["Used for evaluation", "Used for partnership conversation"]] }, keyPoint: "The Digital Journal is not a performance record — it is a private thinking space that belongs to the coaching partnership." },
  { title: "The 7 Partnership Principles in the Digital Journal", table: { headers: ["Principle", "In the Journal"], rows: [["EQUALITY", "Use 'We noticed…' and 'We agreed…' — not 'Teacher failed to…'"], ["CHOICE", "Note when teacher chose an artifact or direction: 'Teacher chose to include the back-row notebook'"], ["VOICE", "Quote the teacher directly: 'Teacher said: I didn't realise they had stopped writing'"], ["DIALOGUE", "End annotations with an open question for the next visit"], ["REFLECTION", "Reference the baseline when writing progress: 'Compare to Identify entry [Date]: 40% → 78%'"], ["PRAXIS", "Every annotation connects reflection to a classroom action taken or planned"], ["RECIPROCITY", "Write a Reciprocity Note — one thing the coach learned from this teacher"]] } },
  { title: "Three Types of Journal Entries Across the Impact Cycle", table: { headers: ["Phase", "Purpose", "Sample Language"], rows: [["IDENTIFY (Baseline)", "Establish undisputed current reality; end with teacher-chosen goal", "'We noticed 18/40 students off-task in back rows. Teacher's response: I had no idea.'"], ["LEARN (Pivot)", "Document teacher experimenting with new strategy; normalize imperfection", "'First attempt at Think-Pair-Share: 22/40 engaged. Timing needs adjustment — expected in first trial.'"], ["IMPROVE (Growth)", "Confirm progress using same metric as baseline; include Reciprocity Note", "'Compare to Identify: 45% → 87.5% on-task. Goal exceeded. Reciprocity Note: teacher's warm-up technique is worth sharing.'"]] } },
  { title: "What Is a Partnership Annotation?", content: "A Partnership Annotation transforms a photo into a coaching tool by adding three elements:", bullets: ["1. THE OBSERVATION: A low-inference, specific description of what the artifact shows", "2. THE PRINCIPLE REFERENCE: Which Partnership Principle is activated or protected in this moment", "3. THE NEXT QUESTION: An open question for the next coaching conversation based on this artifact"], keyPoint: "Without the annotation, the artifact is just evidence. With it, it becomes a mirror the teacher can use to guide their own growth." },
  { title: "Defending Confidentiality: The Digital Journal Under Pressure", content: "A principal says: 'Show me your Digital Journal for Teacher X. I want to see how they are progressing.'", bullets: ["Frame the journal as a 'Developmental Tool' for the teacher, not the school", "'My coaching folder is a private developmental space for the teacher and coach. If I share it for evaluation, teachers will stop being honest.'", "'I can share a school-wide growth trend report — without individual names or journals — to show overall progress.'", "Never share individual journal entries for performance audit purposes"], keyPoint: "The Digital Journal's power depends entirely on the teacher knowing it will not be used against them. One breach permanently ends trust." },
  { title: "Sequencing Artifacts in the Digital Journal", content: "The Journal timeline must follow the Impact Cycle arc from first observation to lasting change.", bullets: ["IDENTIFY artifacts come first — wide-shot baseline photos, T-Charts with low engagement counts", "LEARN artifacts show the first attempt at a new strategy — new seating, new CFU approach", "IMPROVE artifacts show the 'After' — same angle as baseline, updated T-Chart with higher counts", "Final annotation: Compare to baseline and write the Reciprocity Note"], keyPoint: "A journal that documents only one phase is incomplete. Coaching impact is only visible when the full arc is documented in one place." },
];

const slidesU42 = [
  { title: "Unit 4.2: The Adaptive Facilitator", content: "Reading the Room and Adjusting Your Coaching Stance — From Fixed Expert to Responsive Partner", keyPoint: "An Adaptive Facilitator does not have a fixed style. They read the teacher's current needs and adjust in real time.", type: "title" },
  { title: "The Three Coaching Stances", table: { headers: ["Stance", "When to Use", "What It Looks Like"], rows: [["DIRECTIVE", "Teacher overwhelmed, safety crisis, complete novice", "Coach provides clear, specific instructions. 'Do this now to ensure students are safe.'"], ["FACILITATIVE", "Teacher has capacity to reflect and choose", "Coach asks powerful questions. 'What do you notice? What would you like to try?'"], ["CONSULTATIVE", "Teacher has expertise and wants a thought partner", "Coach offers options and rationale. 'Here are two approaches — what fits your context?'"]] }, keyPoint: "Directive coaching is NOT partnership failure. It is what you do when the teacher cannot yet access reflective choice." },
  { title: "Reading the Room: Signals for Stance Adjustment", bullets: ["Teacher is overwhelmed or anxious → Directive: reduce cognitive load, give clear next step", "Teacher is curious and engaged → Facilitative: ask questions, wait, let teacher discover", "Teacher is resistant or shut down → Consultative: offer choices, reduce threat, build trust through small wins", "Teacher is expert and collaborative → Consultative: share options with rationale, invite co-design", "Teacher faces safety or crisis → Directive immediately: partnership can resume after the crisis"], keyPoint: "The wrong stance at the wrong moment costs trust. Reading the room accurately is the master coaching skill." },
  { title: "The 'Coaching Heavy' vs. 'Coaching Light' Spectrum", table: { headers: ["Coaching Heavy", "Coaching Light"], rows: [["Deep systemic changes in teacher practice and student learning", "Surface-level behavior adjustments and quick tips"], ["Full Impact Cycle engagement (IDENTIFY → LEARN → IMPROVE)", "Single visit observations with no follow-up cycle"], ["Teacher owns goal, strategy, and pivot", "Coach prescribes action and checks compliance"], ["Change outlasts the coaching relationship", "Change stops when coaching stops"]] }, keyPoint: "Coaching Light creates dependent teachers. Coaching Heavy creates self-directing professionals." },
  { title: "Handling Resistance: The Quick Win Strategy", content: "A resistant teacher is not failing — they are protecting themselves from a history of evaluative inspection. The Adaptive Facilitator's response:", bullets: ["Do not escalate: do not increase pressure or involve the principal", "Empathize first: 'I understand these conversations can feel evaluative — that is not what I am here for'", "Offer a Quick Win Choice: 'Would you prefer to focus on one small thing that would make your day easier?'", "Use the smallest possible intervention to build trust before attempting deeper work"], keyPoint: "Trust is built one small consistent action at a time. Resistant teachers need Quick Wins before they can access deep coaching." },
  { title: "Reciprocity in Facilitation", content: "RECIPROCITY (PP-7) means the coach is willing to be influenced by the teacher's classroom reality — not just influence the teacher.", bullets: ["After every visit, ask yourself: 'What did I learn from this teacher that I did not know before?'", "Document this in the Reciprocity Note in the Digital Journal", "If a teacher's approach works better than the 'textbook' strategy — say so", "The coach who cannot be influenced cannot be trusted as an equal"], keyPoint: "Coaches who learn from teachers build more trust than coaches who only teach teachers." },
];

const slidesU43 = [
  { title: "Unit 4.3: The Partnership Advocate", content: "Protecting the Coaching Space Under Systemic Pressure — Becoming a Guardian of the Safe Space", keyPoint: "A Partnership Advocate does not just coach teachers. They actively protect the conditions that make coaching possible.", type: "title" },
  { title: "When Advocacy Is Needed", content: "The Partnership Advocate identity activates when systemic pressures threaten coaching integrity:", bullets: ["Principal requests coaching notes for performance audit", "Coach is asked to rank teachers or identify 'weak' teachers", "Coaching time is repeatedly taken by non-coaching duties", "Administrative calendar treats coaching as inspection", "Teacher is warned that coaching data will affect their evaluation"], keyPoint: "Advocacy is not confrontation. It is the systematic protection of the conditions that allow growth." },
  { title: "The Advocacy Script", content: "When the principal asks: 'Give me your evaluative notes on the bottom 5 teachers for a performance audit.'", bullets: ["Validate: 'I understand your goal is school improvement — that is exactly what I am working toward.'", "Boundary: 'My coaching folder is a private developmental space for the teacher and coach. If I share individual notes for evaluation, teachers will close off and coaching ends.'", "Alternative: 'I can offer a School Growth Map showing anonymous trends — for example, 70% of teachers are mastering the Planning Loop.'", "Offer: 'If you have performance concerns about specific teachers, you can conduct your own formal observation. I cannot provide my coaching data for that purpose.'"], keyPoint: "The Advocacy Script: Validate + Boundary + Alternative + Offer. Never just refuse — always provide a path forward." },
  { title: "The School Growth Map as an Alternative", content: "Instead of individual teacher data, offer aggregate school-level patterns:", bullets: ["'Across Grade 4, average student engagement moved from 52% to 68% in one term'", "'70% of teachers I am working with have strengthened Check for Understanding frequency'", "'The most common growth area across all teachers this month is transition management'"], table: { headers: ["What You CANNOT Share", "What You CAN Share"], rows: [["Individual teacher coaching notes", "School-wide growth patterns by grade or area"], ["Teacher performance ratings from coaching", "Aggregate percentage changes in student outcomes"], ["Which teachers are 'weakest' or 'strongest'", "Distribution of growth areas without teacher names"]] } },
  { title: "Praxis in Advocacy", content: "PRAXIS (PP-6) in advocacy means taking brave, data-informed action to protect the coaching space — not just thinking about the problems.", bullets: ["Document every request that threatens confidentiality in writing", "Report coaching displacement (non-coaching duties) with WRER data as evidence", "Communicate the coaching model to principals at the start of each school year", "Build principal relationships proactively — not only when there is a conflict"], keyPoint: "Advocates who wait until the crisis occurs have already lost. Proactive relationship-building is the best defense." },
  { title: "Guarding the Safe Space", content: "The 'Sacred Space' of coaching is the psychological safety that allows teachers to admit struggles, try new strategies, and grow authentically.", bullets: ["Once breached, it takes 3–5 visits to rebuild basic trust", "Teachers in schools where coaching data is shared with principals perform for coaches — they do not partner with them", "Your professional identity as a coach IS the safe space — how you hold it under pressure defines you"], keyPoint: "Guarding the safe space is not about protecting secrets. It is about protecting the conditions under which genuine professional growth is possible." },
];

const slidesU44 = [
  { title: "Unit 4.4: The Consistency Guardian (WRER)", content: "Tracking Coaching Frequency and Protecting Against Systemic Displacement", keyPoint: "Consistency — not intensity — is what drives lasting teacher change. The WRER is your consistency diagnostic.", type: "title" },
  { title: "Why Consistency Matters More Than Intensity", content: "Research on skill development consistently shows that coaching frequency drives lasting change more than any single intensive session.", table: { headers: ["Infrequent / Intense", "Frequent / Consistent"], rows: [["One deep coaching visit per month", "Regular 2-week cycles"], ["Teacher forgets context, starts over", "Teacher builds on momentum from previous cycle"], ["Coach as occasional expert", "Coach as ongoing partner"], ["Change fades between visits", "New habits solidify through repeated feedback loops"]] }, keyPoint: "The 2-week coaching cycle is not arbitrary — it is the minimum frequency for habit solidification." },
  { title: "The WRER: Weekly Record of Engagement and Results", content: "WRER = Actual coaching visits completed ÷ Scheduled coaching visits × 100%", bullets: ["Purpose: Measures coaching consistency ('Pulse Check') — not teacher performance", "Target: 80%+ WRER indicates a healthy coaching program", "Below 60%: Signals systemic displacement — coach is being assigned non-coaching duties", "How to calculate: Each week, count scheduled visits vs. completed visits"], keyPoint: "A low WRER is not evidence that the coach is lazy. It is evidence that the system needs a stronger Guardian." },
  { title: "Systemic Displacement: The Root Cause of Low WRER", content: "Coaches in Pakistan public schools frequently face displacement — being asked to cover absent teachers, prepare reports, attend non-coaching meetings.", bullets: ["Displacement is the single most common reason coaching programs fail", "Teachers experience it as inconsistency or abandonment", "Using WRER data: 'I completed 40% of scheduled visits because I was asked to cover 8 absent teacher periods'", "The data makes the systemic cause visible without personalizing it"], keyPoint: "WRER data is the tool for making invisible systemic displacement visible to administration." },
  { title: "Creating a Response Plan from WRER Data", bullets: ["STEP 1: Calculate your WRER for the week — actual/scheduled × 100", "STEP 2: If below 80%, identify the cause — displacement, scheduling, absence", "STEP 3: Document the cause with specifics — '3 of 4 missing visits were due to assigned class coverage'", "STEP 4: Create a Response Plan for the following week — reschedule missed visits, communicate constraints", "STEP 5: Share aggregate WRER data with principal proactively — not defensively"], keyPoint: "The Response Plan converts WRER data from a complaint into a systems conversation with administration." },
  { title: "Reciprocity in Consistency", content: "RECIPROCITY (PP-7) applies to consistency: coaches must show up reliably if they expect teachers to be prepared, open, and invested.", bullets: ["Teachers who experience inconsistent coaching stop preparing for visits", "Teachers who trust the coach will appear start investing in the coaching relationship", "'If I want the teacher to commit to a 2-week action step, I must commit to returning in 2 weeks'"], keyPoint: "Reciprocity in frequency means: coaches earn the trust of consistent teachers by being consistently present." },
];

// ─── Scenarios ────────────────────────────────────────────────────────────────

const scenarioU41 = {
  steps: [
    {
      id: "s41-1",
      situation: "A coach is creating a Digital Journal entry for a teacher's growth journey. They include a photo of a student's improved essay and add the note: 'Notice the shift in student engagement and clarity when you moved to the back row to support the Shadow students.'",
      context: "The coach has been working with this teacher for 3 months across 6 coaching cycles.",
      question: "This note is an example of which type of annotation?",
      branches: [
        { id: "a", text: "A technical correction of the teacher's mistakes.", isCorrect: false, rationale: "The note celebrates a specific teacher decision (moving to the back row) and its observable impact. There is no correction — only a Growth-focused observation tied to a specific action.", principle: "PRAXIS + EQUALITY" },
        { id: "b", text: "A 'Human Annotation' that highlights professional agency and growth.", isCorrect: true, rationale: "This is a Partnership Annotation with all three elements: the observation (shift in student engagement), the principle reference (implied — teacher's proactive movement = PRAXIS), and the growth connection (the 'Shadow' strategy is paying off). It belongs to the IMPROVE phase narrative.", principle: "PRAXIS + EQUALITY" },
        { id: "c", text: "A 'Deficit Frame' focusing on what was missing earlier.", isCorrect: false, rationale: "'Deficit Frame' looks backward to document failure. This annotation looks forward to celebrate growth — it is an IMPROVE phase entry, not an IDENTIFY baseline complaint.", principle: "PRAXIS + REFLECTION" },
        { id: "d", text: "An administrative report for the principal to use in a salary review.", isCorrect: false, rationale: "The Digital Journal is explicitly a confidential developmental tool between coach and teacher — not an administrative record or evaluation instrument.", principle: "Confidentiality + EQUALITY" },
      ],
    },
    {
      id: "s41-2",
      situation: "You have worked with a teacher for 3 months. You show them a sequence of artifacts from their Digital Journal — from the first IDENTIFY phase observation to the most recent IMPROVE phase evidence.",
      context: "The teacher has not seen these artifacts side by side before.",
      question: "Why are you acting as a 'Biographer of Growth' in this moment?",
      branches: [
        { id: "a", text: "To prove to the district that you have been working consistently every week.", isCorrect: false, rationale: "The Biographer of Growth identity is teacher-facing, not administratively motivated. The purpose is to make the teacher's own journey visible to themselves — not to validate the coach's work for external review.", principle: "EQUALITY + REFLECTION" },
        { id: "b", text: "To keep a record of every error the teacher made so they do not repeat them.", isCorrect: false, rationale: "This is the Deficit Frame — the opposite of the Biographer of Growth. The Journal documents the arc from baseline to growth, not an error log.", principle: "EQUALITY + REFLECTION" },
        { id: "c", text: "To document the teacher's success and professional journey over time rather than just counting errors.", isCorrect: true, rationale: "This is the Biographer of Growth function: making the full arc of change visible in one place so the teacher can see how far they have come. Research shows that seeing your own progress is a powerful motivator for continued growth.", principle: "REFLECTION + PRAXIS + EQUALITY" },
        { id: "d", text: "To write a story that makes the school's test scores look better than they are.", isCorrect: false, rationale: "The Digital Journal documents real, observable classroom change — it is not a marketing document or a fabrication.", principle: "Integrity + Equality" },
      ],
    },
  ],
};

const scenarioU42 = {
  steps: [
    {
      id: "s42-1",
      situation: "You are coaching a teacher who is currently facing a classroom safety crisis — two students are in a physical altercation and she is completely overwhelmed and freezing at the front of the room.",
      context: "This is the most unusual situation you have encountered in your coaching career.",
      question: "In this specific moment, which coaching stance is most appropriate?",
      branches: [
        { id: "a", text: "Facilitative: Asking powerful questions to help them reflect on the crisis.", isCorrect: false, rationale: "A teacher in a safety crisis cannot access reflective capacity. Asking 'What do you notice?' when two students are fighting is inappropriate and potentially dangerous.", principle: "Adaptive Facilitation — Directive Moment" },
        { id: "b", text: "Directive: Providing immediate, clear instructions to ensure safety and clarity.", isCorrect: true, rationale: "Directive coaching is exactly right when the teacher is overwhelmed or facing a safety issue. 'Call for the principal now. I will speak to the class. We can debrief after.' Partnership resumes when the crisis is resolved.", principle: "Adaptive Facilitation — Directive Moment" },
        { id: "c", text: "Silent: Observing from the back to see how they handle it alone.", isCorrect: false, rationale: "A physical altercation is a safety crisis, not a growth opportunity for observation. The coaching role expands to include active support when safety is threatened.", principle: "Adaptive Facilitation + Reciprocity" },
        { id: "d", text: "Evaluative: Taking notes on their lack of crisis management skills.", isCorrect: false, rationale: "Evaluative note-taking during a crisis abandons the teacher at their most vulnerable moment. This destroys trust permanently and is the opposite of Partnership.", principle: "Equality + Trust" },
      ],
    },
    {
      id: "s42-2",
      situation: "A teacher is showing resistance to changing their lesson structure. The Adaptive Facilitator offers the teacher a choice: 'Would you prefer to focus on improving your Check for Understanding questions or your Wait Time transitions first?'",
      context: "The teacher has been resistant in the last two coaching visits.",
      question: "Why is offering this choice effective for a resistant teacher?",
      branches: [
        { id: "a", text: "It allows the coach to avoid making a difficult decision.", isCorrect: false, rationale: "Offering a choice is a strategic partnership move, not an avoidance of responsibility. The coach has already identified two valid growth areas — they are offering genuine alternatives.", principle: "Choice + Adaptive Facilitation" },
        { id: "b", text: "It tricks the teacher into doing what the coach wanted all along.", isCorrect: false, rationale: "Both options are genuine — this is not manipulation. The Choice Principle requires that both options represent real alternatives that fit the teacher's context.", principle: "Choice + Integrity" },
        { id: "c", text: "It increases buy-in and agency by allowing the teacher to select a path that fits their current capacity.", isCorrect: true, rationale: "For resistant teachers, choice is the most powerful tool available. By offering two genuine alternatives, the coach restores autonomy (SCARF), which reduces the resistance that comes from feeling controlled. The teacher now owns the direction.", principle: "Choice + SCARF + Adaptive Facilitation" },
        { id: "d", text: "It follows the school's policy that teachers should always be happy.", isCorrect: false, rationale: "Partnership coaching is not about teacher happiness — it is about building professional capacity through evidence-based partnership. Choice serves agency, not comfort.", principle: "Choice + Praxis" },
      ],
    },
  ],
};

const scenarioU43 = {
  steps: [
    {
      id: "s43-1",
      situation: "The Principal asks you for your 'evaluative notes' on the 'bottom 5' teachers in the building to help with a performance audit.",
      context: "The Principal frames this as being for school improvement purposes.",
      question: "Which response shows 'Mastery' as a Partnership Advocate?",
      branches: [
        { id: "a", text: "Give the notes but ask the Principal to be 'nice' when they talk to the teachers.", isCorrect: false, rationale: "Sharing individual coaching notes with a principal for evaluation purposes destroys the coaching relationship with every teacher named — regardless of tone. This is a fundamental breach.", principle: "Confidentiality + Trust" },
        { id: "b", text: "Refuse to speak to the Principal at all to protect your personal integrity.", isCorrect: false, rationale: "Total non-engagement is not advocacy — it is avoidance. A Partnership Advocate holds the boundary while providing an alternative and maintaining the working relationship.", principle: "Integrity + Dialogue" },
        { id: "c", text: "Redirect the Principal to school-wide growth patterns and trends while firmly protecting individual confidentiality.", isCorrect: true, rationale: "This is the Advocacy Script: Validate the Principal's improvement goal, set the boundary on individual data, offer the School Growth Map alternative. The coach maintains the relationship while protecting the coaching partnership.", principle: "Confidentiality + Advocacy + Dialogue" },
        { id: "d", text: "Hand over the notes immediately to maintain a good relationship with leadership.", isCorrect: false, rationale: "Maintaining leadership relationships at the cost of teacher confidentiality destroys the coaching program's effectiveness for everyone. Short-term compliance creates long-term damage.", principle: "Confidentiality + Integrity" },
      ],
    },
  ],
};

const scenarioU44 = {
  steps: [
    {
      id: "s44-1",
      situation: "Your WRER data shows you completed only 40% of scheduled coaching visits this month because you were repeatedly asked to cover absent teachers' classes.",
      context: "Your principal has not noticed the low completion rate yet.",
      question: "How should you use this WRER data?",
      branches: [
        { id: "a", text: "Hide the data so the Principal does not think you are being lazy.", isCorrect: false, rationale: "Hiding data contradicts the evidence-based approach. WRER data is the tool for making systemic displacement visible — concealing it perpetuates the displacement.", principle: "Integrity + Evidence-Based" },
        { id: "b", text: "Use it to complain to the teachers about how busy you are.", isCorrect: false, rationale: "Sharing your workload struggles with teachers inverts the partnership — the coach is not the person who needs support in this conversation.", principle: "Equality + Professionalism" },
        { id: "c", text: "Use it as objective evidence to show the Principal how 'displaced time' is preventing teacher growth.", isCorrect: true, rationale: "This is the Consistency Guardian move: WRER data converts an invisible systemic problem (displacement) into a visible, specific, non-personal conversation with administration. 'I completed 40% of visits because I covered 8 class periods — here is the data.'", principle: "WRER + Evidence-Based + Advocacy" },
        { id: "d", text: "Accept that inconsistency is a normal part of school life and stop tracking it.", isCorrect: false, rationale: "Accepting displacement without naming it allows the systemic problem to continue. Tracking WRER is the tool that makes the problem actionable.", principle: "Consistency + Advocacy" },
      ],
    },
  ],
};

// ─── Quiz questions ────────────────────────────────────────────────────────────

const quizU41 = [
  { q: "In Unit 4.1, the coach's identity shifts from 'Data Collector' to:", options: ["Data Entry Clerk", "Biographer of Growth", "Digital Assistant", "Technical Inspector"], correct: 1 },
  { q: "What is the primary purpose of 'Human Annotation' in a Digital Journal?", options: ["To correct the teacher's spelling", "To turn raw artifacts into a narrative of professional excellence", "To provide a secret grade for the principal", "To describe what the students are wearing"], correct: 1 },
  { q: "Which of the following is a 'Partnership Annotation'?", options: ["'The teacher struggled with the math problem'", "'Notice the shift in student engagement when you moved to the back row'", "'The lesson was 10 minutes too long'", "'The whiteboard was not erased properly'"], correct: 1 },
  { q: "The 'Digital Journal' is a tool for which phase of the Impact Cycle?", options: ["Identify only", "Learn only", "The full cycle (Identify, Learn, and Improve)", "Evaluation only"], correct: 2 },
  { q: "How does the Digital Journal protect confidentiality?", options: ["By using passwords that only the principal knows", "By framing the folder as a 'Developmental Tool' for the teacher, not the school", "By deleting photos after 24 hours", "By only using student names, not teacher names"], correct: 1 },
  { q: "When sequencing artifacts in a Digital Journal, 'Improve' evidence shows:", options: ["The very first lesson observed", "The 'After' photo showing the result of a specific action step", "A video of the coach teaching the class", "The teacher's original lesson plan"], correct: 1 },
];

const quizU42 = [
  { q: "An 'Adaptive Facilitator' adjusts their coaching style based on:", options: ["The weather", "The teacher's current needs, experience level, and context", "The principal's mood", "The time of day"], correct: 1 },
  { q: "'Directive' coaching is most appropriate when:", options: ["The teacher is a high-performer", "A teacher is overwhelmed or facing a safety/crisis issue", "The coach wants to show off their knowledge", "The teacher asks for no help"], correct: 1 },
  { q: "The 'Facilitative' stance focuses on:", options: ["Telling the teacher exactly what to do", "Asking powerful questions to ignite the teacher's own reflection", "Writing the lesson plan for the teacher", "Observing from outside the classroom"], correct: 1 },
  { q: "What is the 'Coaching Heavy' approach?", options: ["Staying in the classroom for 4 hours", "Focusing on deep, systemic changes in teacher practice and student learning", "Giving the teacher a lot of homework", "Carrying a heavy laptop to the school"], correct: 1 },
  { q: "In the 'Adaptive' framework, if a teacher is resistant, a coach should first:", options: ["Report them to the principal", "Empathize and offer 'Quick Win' choices to build trust", "Stop coaching them", "Force them to follow the rubric"], correct: 1 },
  { q: "'Reciprocity' in facilitation means:", options: ["Both people talk for exactly 30 minutes", "The coach is willing to be influenced by the teacher's classroom reality", "The teacher pays for the coach's tea", "The coach teaches the lesson for the teacher"], correct: 1 },
];

const quizU43 = [
  { q: "The 'Partnership Advocate' identity is needed when:", options: ["The teacher is doing a great job", "Systemic pressures (like audit culture) threaten coaching integrity", "The coach wants a promotion", "The school holds a sports day"], correct: 1 },
  { q: "An 'Advocacy Script' is used to:", options: ["Complain about the school's facilities", "Protect coaching time and confidentiality when talking to administrators", "Request more students for the classroom", "Ask the teacher for a favor"], correct: 1 },
  { q: "How does an Advocate handle a request to share 'Top 5 Worst Teachers' with a principal?", options: ["Provides the list to keep the principal happy", "Offers a 'School Growth Map' showing anonymous trends instead", "Quits the job", "Tells the teachers to hide from the principal"], correct: 1 },
  { q: "'Praxis' in advocacy means:", options: ["Thinking about the problems but doing nothing", "Taking brave, data-informed action to protect the coaching space", "Writing a long email to the district", "Practicing a lesson alone"], correct: 1 },
  { q: "The 'Coaching Folder' keyword is used to emphasize that data is:", options: ["For the principal's eyes only", "A private developmental space for the teacher and coach", "Public property of the school", "A grading rubric for salary"], correct: 1 },
  { q: "A 'Guardian of the Safe Space' protects:", options: ["The physical classroom door", "The psychological safety required for a teacher to admit struggles and grow", "The principal's office", "The school's reputation only"], correct: 1 },
];

const quizU44 = [
  { q: "What does 'WRER' stand for?", options: ["Weekly Rate of Educational Results", "Weekly Record of Engagement and Results", "Whole Room Evidence Review", "Weekly Report to Education Registry"], correct: 1 },
  { q: "The 'Pulse Check' of coaching consistency is:", options: ["The teacher's test scores", "The WRER calculation (actual visits vs. scheduled visits)", "The principal's satisfaction survey", "The coach's attendance at the office"], correct: 1 },
  { q: "If a coach has a low WRER score, it usually indicates:", options: ["The coach is lazy", "Systemic displacement (being assigned non-coaching duties)", "The teachers do not like the coach", "The coaching app is broken"], correct: 1 },
  { q: "'Reciprocity' in Unit 4.4 means:", options: ["If the coach is late, the teacher can be late", "Coaches must show up consistently if they expect teachers to be prepared", "The school provides a desk for the coach", "The coach and teacher trade notes"], correct: 1 },
  { q: "What is the final step after calculating a weekly WRER?", options: ["Closing the laptop", "Creating a 'Response Plan' for the following week", "Reporting the low score to the district", "Deleting the data"], correct: 1 },
  { q: "Inconsistency is viewed in this module as:", options: ["A personal failure of the coach", "A signal that the system needs a stronger 'Guardian'", "A normal part of school life that cannot be changed", "A reason to stop coaching"], correct: 1 },
];

// ─── Open-ended questions ──────────────────────────────────────────────────────

const openEndedU41 = [
  {
    q: "A coach is creating a Digital Journal entry for a teacher's growth journey. They include a photo of a student's improved essay and add the note: 'Notice the shift in student engagement and clarity when you moved to the back row to support the Shadow students.' This note is an example of a 'Human Annotation.' Explain what makes it a Human Annotation and not just a data record.",
    rubric: "Score 2: A Human Annotation adds three elements — observation (shift in student engagement), principle reference (PRAXIS — teacher's proactive movement), and a growth framing rather than an error framing; it transforms raw evidence into a story of professional agency. Score 1: Identifies that the annotation highlights growth without explaining what makes it 'human' (the partnership principles reference and the growth narrative arc). Score 0: Says it is a Human Annotation because it is encouraging or positive — without connecting to the specific structural elements.",
  },
  {
    q: "You have been working with a teacher for three months. You decide to show them a sequence of artifacts from their Digital Journal, from the first IDENTIFY phase to the most recent IMPROVE phase. Why are you acting as a 'Biographer of Growth'?",
    rubric: "Score 2: Biographer of Growth = documenting the teacher's professional journey over time rather than counting errors; making the arc from baseline to growth visible in one place so the teacher can see how far they have come; this is motivating and confirms coaching partnership worked. Score 1: Describes showing progress without explaining the 'biographer' identity or its motivational purpose. Score 0: Says the purpose is to prove to the district that the coach has been working consistently.",
  },
];

const openEndedU42 = [
  {
    q: "You are coaching a teacher who is currently facing a classroom safety crisis and feels completely overwhelmed. In this specific moment, which coaching stance is most appropriate and why?",
    rubric: "Score 2: Directive — teacher cannot access reflective capacity in a crisis; clear, specific instructions ensure safety first; partnership resumes after the crisis. Explains that Directive is not a partnership failure — it is the right tool for the right moment. Score 1: Identifies Directive as correct without explaining why facilitative would be inappropriate in a crisis moment. Score 0: Argues for Facilitative even in a safety crisis, or says the coach should only observe.",
  },
  {
    q: "A teacher is showing resistance to coaching. An Adaptive Facilitator offers: 'Would you prefer to focus on your Check for Understanding questions or your Wait Time transitions first?' Why is this effective for a resistant teacher?",
    rubric: "Score 2: Choice restores autonomy (SCARF), which reduces the resistance that comes from feeling controlled; both options are genuine; teacher now owns the direction; Quick Win choices build trust before deeper coaching is possible. Score 1: Says choice is good for buy-in without explaining the SCARF autonomy mechanism or Quick Win strategy. Score 0: Says it lets the coach avoid a difficult decision or 'tricks' the teacher into compliance.",
  },
];

const openEndedU43 = [
  {
    q: "The Principal asks you for your 'evaluative notes' on the 'bottom 5' teachers in the building to help with a performance audit. Based on the Module 4 Mastery Rubric, what is the 'Strong Response'?",
    rubric: "Score 2: Validate the Principal's improvement goal + set the confidentiality boundary + offer the School Growth Map alternative + explain why teacher choice and confidentiality matter for coaching effectiveness. Does not just refuse — provides a path forward. Score 1: Sets the boundary without offering an alternative or explaining the partnership principle. Score 0: Provides the names or gives the notes to maintain a good relationship with leadership.",
  },
  {
    q: "Your WRER data shows you completed only 40% of your scheduled coaching visits this month because you were asked to cover absent teacher classes. How should you use this data?",
    rubric: "Score 2: Use it as objective evidence in a conversation with the principal to name 'displaced time' as a systemic issue (not a personal failing); WRER converts the invisible to visible; present a Response Plan for the following week. Score 1: Identifies the data should be shared with the principal without explaining the mechanism (systemic displacement vs. personal failure framing). Score 0: Hides the data to avoid appearing lazy, or accepts the displacement as normal without documenting it.",
  },
];

const openEndedU44 = [
  {
    q: "Explain why coaching consistency (frequency) matters more than coaching intensity (depth of single sessions) for long-term teacher development.",
    rubric: "Score 2: Regular 2-week cycles create feedback loops that solidify new habits; single intense sessions fade without consistent follow-up; the IMPROVE phase requires a follow-up visit to confirm strategy impact; teachers who experience consistent coaching build trust and investment that enables deeper work over time. Score 1: States that frequency matters without explaining the mechanism (habit solidification via feedback loops). Score 0: Argues that one deep session per term is sufficient, or confuses frequency with workload.",
  },
  {
    q: "A colleague coach says: 'I only completed 2 of 5 scheduled coaching visits this week — I must not be committed enough.' Using the WRER framework, how would you respond?",
    rubric: "Score 2: Low WRER signals a systemic issue (displacement), not personal failing; coach should calculate WRER, document the specific causes, and use data to name systemic displacement to administration; the Consistency Guardian role is about advocating for coaching time, not self-blame. Score 1: Says the issue may be systemic without applying the WRER framework or Response Plan. Score 0: Agrees the coach needs to be more committed or suggests working harder without addressing the systemic cause.",
  },
];

// ─── Main seed function ────────────────────────────────────────────────────────

export async function seedModule4(): Promise<{ success: boolean; log: string[] }> {
  const log: string[] = [];

  const units = [
    { order: 1, title: "Unit 4.1: The Digital Journal", description: "Adding human annotation to transform data into a biography of professional growth across the full Impact Cycle", concepts: "Biographer of Growth identity, Human Annotation, Partnership Principles in journaling, Impact Cycle sequencing, confidentiality defence", slides: slidesU41, scenario: scenarioU41, quiz: quizU41, openEnded: openEndedU41 },
    { order: 2, title: "Unit 4.2: The Adaptive Facilitator", description: "Reading teacher needs and adjusting coaching stance between directive, facilitative, and consultative modes", concepts: "Three coaching stances, reading resistance, Quick Win strategy, Coaching Heavy vs. Light, Reciprocity in facilitation", slides: slidesU42, scenario: scenarioU42, quiz: quizU42, openEnded: openEndedU42 },
    { order: 3, title: "Unit 4.3: The Partnership Advocate", description: "Protecting coaching integrity against systemic pressures using the Advocacy Script and School Growth Map", concepts: "Advocacy Script, School Growth Map, Guardian of Safe Space, Praxis in advocacy, confidentiality boundary", slides: slidesU43, scenario: scenarioU43, quiz: quizU43, openEnded: openEndedU43 },
    { order: 4, title: "Unit 4.4: The Consistency Guardian (WRER)", description: "Tracking coaching frequency and using the Weekly Record of Engagement and Results to address systemic displacement", concepts: "WRER formula, systemic displacement, coaching consistency vs. intensity, Response Plan, Reciprocity in frequency", slides: slidesU44, scenario: scenarioU44, quiz: quizU44, openEnded: openEndedU44 },
  ];

  try {
    const { modules: allModules } = await listModules();
    type ModuleRow = { id: string; title?: string; order_number?: number };
    let mod = (allModules as ModuleRow[]).find((m) => m.order_number === 4);

    if (mod) {
      log.push(`✅ Module already exists: ${mod.id}`);
    } else {
      mod = (await createModule({
        title: "Module 4: Digital & Data Intelligence",
        description: "Building the digital coaching toolkit through journal annotation, adaptive facilitation, partnership advocacy, and consistency tracking.",
        is_mandatory: false,
        order_number: 4,
        competencies: "Digital Journaling, Adaptive Facilitation, Partnership Advocacy, Consistency Tracking, Confidentiality Defence",
        desired_outcomes: "Create annotated Digital Journals, adjust coaching stance to teacher needs, advocate for coaching integrity, track and respond to WRER data",
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

    log.push("✅ Module 4 seed complete!");
    return { success: true, log };
  } catch (err: unknown) {
    log.push(`❌ Fatal error: ${err instanceof Error ? err.message : String(err)}`);
    return { success: false, log };
  }
}
