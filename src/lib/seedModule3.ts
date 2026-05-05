/**
 * Module 3 seed data — runs in-browser via Supabase client
 * Triggered from Admin panel → "Seed Module 3" button
 */
import { supabase } from "@/integrations/supabase/client";

// ─── Slides ───────────────────────────────────────────────────────────────────

const slidesU31 = [
  { title: "Unit 3.1: The Mirror Specialist", content: "Mastering Objective Observation and Data Protection — Moving from Subjective Evaluation to Low-Inference Facts", keyPoint: "A mirror reflects reality without judgment. A Mirror Specialist gives teachers data to examine without triggering defensiveness.", type: "title" },
  { title: "The Identity Shift: Expert to Mirror", content: "In Pakistan's public school context, teachers are frequently 'inspected' and 'judged.' To build a true Partnership, you must shift identity.", table: { headers: ["Expert with an Opinion", "Mirror Specialist"], rows: [["Delivers verdicts: 'Your lesson was messy'", "Reflects facts: '8 students were talking at 9:10'"], ["Triggers defensive response", "Triggers curiosity and reflection"], ["Positions coach as superior judge", "Positions data as the neutral third party"], ["Teacher argues or complies", "Teacher analyzes and chooses"]] }, keyPoint: "You are no longer an expert with an opinion. You are a Mirror — reality reflected without judgment." },
  { title: "Why Opinion Destroys Partnership", bullets: ["THREAT RESPONSE: 'Your lesson was messy' → brain registers status threat → cortisol spikes → fight/flight/freeze activates", "EQUALITY LOST: Coach moves from co-learner to judge → Partnership Principle 1 violated → teacher is no longer a peer", "DIALOGUE STOPS: Teacher in defensive mode composes a defense, not processing feedback → Reflection and Dialogue both collapse"], keyPoint: "The solution is LOW-INFERENCE DATA — facts that teachers can examine without feeling personally attacked." },
  { title: "The Camera Test", content: "THE RULE: 'If a video camera cannot capture it, it is an inference (your opinion), not a fact.'", table: { headers: ["Camera CANNOT Capture (Opinion)", "Camera CAN Capture (Fact)"], rows: [["'The teacher was angry'", "'Teacher raised voice and slammed book on desk at 10:14am'"], ["'Students were confused'", "'6 students asked the same question: Where do we write the answer? in a 3-minute window'"], ["'It was a good lesson'", "'38 of 40 students completed the task correctly within 5 minutes'"], ["'The teacher was not prepared'", "'Teacher arrived 4 minutes after students. No materials on desks at 9:00am'"]] }, keyPoint: "Before writing any observation note: 'Could I show this to a judge as evidence without my personal testimony?'" },
  { title: "Low-Inference vs. High-Inference Data", table: { headers: ["Domain", "High-Inference (Avoid)", "Low-Inference (Use)"], rows: [["Classroom Management", "'Poor classroom discipline'", "'8 students were talking while teacher explained. 3 left seats between 9:05–9:10.'"], ["Instruction Quality", "'The lecture was too long'", "'Teacher spoke for 22 minutes without asking a question. First student question at 22-min mark.'"], ["Student Engagement", "'Students seemed disinterested'", "'At 15-minute mark: 12/40 students had pens down and were not writing. 5 heads on desks.'"], ["Teacher Preparation", "'The teacher was well-prepared'", "'All materials on desks before students entered. Teacher reviewed notes for 3 minutes before start.'"]] } },
  { title: "The T-Chart: Your Primary Observation Tool", content: "Divide your notebook page into two columns: LEFT = Teacher Says/Does | RIGHT = Students Say/Do. Every entry must have a timestamp, a count, and zero adjectives.", table: { headers: ["Teacher Says/Does", "Students Say/Do"], rows: [["9:00 — Writes 3 problems on board", "9:00 — 40/45 students looking at board. 5 students talking."], ["9:05 — Says 'Solve these now'", "9:05 — 10 students ask: 'Which page?'"], ["9:10 — Walks to window, looks out 4 minutes", "9:10 — 20 students stop writing. 5 begin talking."], ["9:14 — Returns to front, writes next problem", "9:14 — 30 students resume. 8 still off task."]] }, keyPoint: "No adjectives. Only timestamps, numbers, and specific actions — everything a video camera would record." },
  { title: "The Confidentiality Shield: Data Protection in Audit Culture", content: "A principal asks: 'Which two teachers in this school are underperforming? I need them for my report.'", bullets: ["STEP 1 — THE BOUNDARY: 'I keep individual coaching notes confidential to ensure teachers feel safe to grow.'", "STEP 2 — THE ALTERNATIVE: 'However, I can share school-wide or grade-level trends. Across Grade 4, average student engagement is currently 50%.'", "STEP 3 — REDIRECT TO SCHOOL GOAL: 'I can share a monthly one-page school-wide trend report — without individual names.'"], keyPoint: "One breach of confidentiality can permanently destroy a coaching relationship and make every teacher in the school guarded." },
];

const slidesU32 = [
  { title: "Unit 3.2: The Artifact Architect", content: "Collecting and Using Physical Evidence as a Neutral Third Party in Partnership Conversations", keyPoint: "An artifact is a 'slice of classroom reality' that both coach and teacher can examine together — without judgment entering the picture.", type: "title" },
  { title: "What Is a Coaching Artifact?", content: "A Coaching Artifact is a physical or digital 'slice' of classroom reality: a photo, student work sample, audio clip, or video excerpt.", table: { headers: ["Handwritten Notes", "Coaching Artifact"], rows: [["Coach's memory + selection bias", "Objective record — camera/device captured it"], ["Teacher argues: 'That is not what happened'", "Hard to dispute what is in the photo"], ["Coach is the 'third party' — unsafe", "Artifact is the 'third party' — neutral"], ["Status threat: teacher vs. coach", "Status safety: both examine the same object"]] }, keyPoint: "Artifacts act as a 'Third Party' that both partners can look at together — removing the coach from the position of judge." },
  { title: "The Permission Script: Protecting Teacher Agency", content: "BEFORE capturing any photo or video, always ask:", bullets: ["'Is it okay if I capture a quick photo of this student's work sample to use in our conversation later?'", "'I want to make sure you are comfortable with what I collect — these notes are for our coaching conversation only.'", "'You can see everything I capture anytime — nothing goes to the principal.'"], keyPoint: "The Permission Script protects teacher agency and ensures the teacher feels in control of what is being captured. It also signals that this is partnership, not surveillance." },
  { title: "The Edge Artifact: Seeing the Invisible", content: "An 'Edge Artifact' focuses specifically on students in the 'shadows' — back rows, quiet students, the students the teacher cannot easily see.", bullets: ["Why the Edge matters: teachers naturally focus on students who participate; 'shadow' students are educationally invisible", "Artifact captures: photo of back two rows during independent work showing 12 of 15 with blank pages", "In conversation: 'What do you notice in this photo of the back row?'", "Result: teacher sees something they genuinely could not see from the front — no status threat, pure discovery"], keyPoint: "The Edge Artifact makes the invisible visible — creating aha moments that prescriptive feedback never can." },
  { title: "How to Introduce an Artifact", table: { headers: ["Avoid (Evaluative)", "Use (Partnership)"], rows: [["'Look at this mistake you made'", "'What do you notice in this photo of the back row?'"], ["'I took this to show the Principal'", "'I captured this for our coaching conversation — let us look at it together'"], ["'This is why your lesson failed'", "'Here is what the photo shows — what do you make of this?'"], ["Coach points to the artifact as evidence of failure", "Both partners look at artifact together as a shared mirror"]] }, keyPoint: "Artifacts lower defensiveness because the focus shifts from the teacher's personality to the neutral object." },
  { title: "Artifact Protection: The Non-Negotiable Boundary", content: "Coaching artifacts — photos, student work samples, T-charts — are a COACHING TOOL, not an evaluation report.", bullets: ["Coach refuses to share individual artifacts with administration to preserve trust", "Before any observation: 'Photos and notes are for our conversation only — they never go to the principal or your file.'", "If principal requests: 'I can share school-level themes across all teachers — for example, average engagement in Grade 5 is 60%.'", "Never share individual teacher artifacts for performance audits or evaluations"], keyPoint: "Artifact protection is what makes teachers willing to be observed authentically rather than performing for the camera." },
];

const slidesU33 = [
  { title: "Unit 3.3: Data Into Dialogue", content: "Transforming Evidence Into Partnership Conversation — Moving from Coach Monologue to Teacher-Led Discovery", keyPoint: "Data shared as a monologue is a verdict. Data shared as an invitation is the start of partnership.", type: "title" },
  { title: "The Core Goal: Coach Monologue to Partnership Dialogue", content: "OLD WAY: Coach presents data, interprets it, delivers conclusion, prescribes action. Teacher listens, agrees (or defends), tries to comply.", table: { headers: ["Coach Monologue", "Partnership Dialogue"], rows: [["Coach explains what the data means", "Teacher interprets the artifact first"], ["Coach prescribes next steps", "Teacher chooses action based on own interpretation"], ["Teacher is passive recipient", "Teacher is active co-analyzer"], ["Trust: teacher feels evaluated", "Trust: teacher feels supported"]] }, keyPoint: "The single most important move: share the data, then wait for the teacher to interpret it first." },
  { title: "The Data-Dialogue Flow", bullets: ["STEP 1: Place artifact on the table between you — side by side, not across a desk", "STEP 2: 'What do you notice first when you look at this?' (Teacher-First interpretation rule)", "STEP 3: WAIT — give 5+ seconds for teacher to examine; resist interpreting before they speak", "STEP 4: Coach offers additional observations ONLY after teacher has interpreted first", "STEP 5: Co-identify next action — teacher chooses from options"], keyPoint: "Steps 2 and 3 are where most coaches fail. Asking and then immediately answering is not teacher-first — it is coach monologue disguised as a question." },
  { title: "Dialogue Sparkers: Opening Evidence Conversations", table: { headers: ["Context", "Dialogue Sparker"], rows: [["Sharing T-Chart data", "'Looking at this T-Chart, what do you notice about the pattern between 9:00 and 9:20?'"], ["Sharing photo of back row", "'What do you notice in this photo of the back row during independent work?'"], ["Sharing student work sample", "'Looking at these 3 work samples from students in row 4, what do you see?'"], ["Sharing participation counts", "'I counted 5 students answering 11 of 12 questions. What do you make of that pattern?'"]] }, keyPoint: "A Dialogue Sparker is an open-ended question about a specific piece of evidence — it ignites teacher reflection, not coach commentary." },
  { title: "When a Teacher Becomes Self-Critical", content: "Teacher sees a photo and says: 'Oh no, I look terrible in this. I had no idea how much time I wasted at the front.'", bullets: ["Do NOT: 'Yes, I noticed that too — you need to change this.'", "Do NOT: 'It is fine, do not be so hard on yourself.'", "DO: Redirect to curiosity — 'That is a powerful observation. What does the data suggest you might try?'", "The moment of self-criticism is the coaching breakthrough — the teacher is ready to change. Redirect to action."], keyPoint: "Self-critical insight is the most powerful force in coaching. Your job is to redirect it from shame to strategy." },
  { title: "Wait Time and Voice Ratio", bullets: ["WAIT TIME: After asking a Dialogue Sparker, count 5 seconds silently before saying anything", "Why: Teacher needs thinking space — silence is productive, not awkward", "VOICE RATIO: Target 60% teacher talk, 40% coach talk in any debriefing conversation", "Why: If the coach is talking more than the teacher, the coach is doing the learning, not the teacher", "RECIPROCITY: Both partners open to learning and changing their minds based on data", "Test: After each visit — 'What did I learn from this teacher that I did not know before?'"], keyPoint: "If you spoke more than the teacher during the debrief, revisit the Dialogue Sparkers. Something went wrong." },
  { title: "Praxis: The Intersection of Reflection and Action", content: "PRAXIS (PP-6) = Learning happens through real-world action followed by reflection. It is not enough to have insight — insight must lead to a specific, observable action.", bullets: ["After teacher interprets artifact and identifies a pattern → 'What would you like to try in the next lesson?'", "Teacher + Coach look at seating chart together → plan new arrangement → teacher tries it → both examine new artifact next visit", "The coaching cycle is not complete until reflection converts to action and action converts to new evidence"], keyPoint: "Praxis is the intersection of Reflection (seeing what is) and Action (trying something new). Without it, coaching is just conversation." },
];

// ─── Scenarios ────────────────────────────────────────────────────────────────

const scenarioU31 = {
  steps: [
    {
      id: "s31-1",
      situation: "You are observing a classroom where Ms. Bano moves around frequently. After the lesson you want to provide feedback. You have two options for your opening statement.",
      context: "Ms. Bano is experienced but sensitive to criticism. Your opening framing will set the tone for the entire conversation.",
      question: "Which observation note passes the 'Camera Test'?",
      branches: [
        { id: "a", text: "'Ms. Bano, you seemed very enthusiastic and energetic during the introduction.'", isCorrect: false, rationale: "'Enthusiastic' and 'energetic' are emotional states that cannot be filmed. A camera records physical actions (gesturing, moving, vocal variation) but cannot capture internal emotional qualities.", principle: "Camera Test + Low-Inference Data" },
        { id: "b", text: "'The students appeared confused when you explained the instructions for the group work.'", isCorrect: false, rationale: "'Appeared confused' is inference — it is your interpretation of observable behaviors. Low-inference rewrite: '6 students raised hands during instructions. 3 students asked their neighbors what to do.'", principle: "Camera Test + Low-Inference Data" },
        { id: "c", text: "'Ms. Bano walked to the back of the room three times and stood by the quietest group for 2 minutes.'", isCorrect: true, rationale: "This passes the Camera Test perfectly: counts (3 times), specific location (back of room), specific group (quietest group), duration (2 minutes). No adjectives, no inference — only observable facts.", principle: "Camera Test + Low-Inference Data" },
        { id: "d", text: "'The lesson was highly effective because the classroom environment felt very positive.'", isCorrect: false, rationale: "'Highly effective' and 'felt very positive' are both value judgments that a camera cannot record. Neither term is observable or measurable.", principle: "Camera Test + Low-Inference Data" },
      ],
    },
    {
      id: "s31-2",
      situation: "During a debrief, a coach tells a teacher: 'Your transition between the lecture and the activity was quite messy and weak.'",
      context: "The teacher immediately becomes quiet and stops contributing to the conversation.",
      question: "What is the likely impact of using evaluative adjectives like 'messy' and 'weak'?",
      branches: [
        { id: "a", text: "It motivates the teacher to work harder to impress the coach.", isCorrect: false, rationale: "Research on feedback and SCARF consistently shows that status threat triggers defensiveness and compliance motivation — not intrinsic growth motivation. The teacher stops processing and starts defending.", principle: "Status + Equality" },
        { id: "b", text: "It triggers a status threat and stops the teacher's self-reflection by creating a hierarchy of judgment.", isCorrect: true, rationale: "This is the precise mechanism. 'Messy' and 'weak' are evaluative labels that position the coach as judge and the teacher as subject — violating Equality (PP-1). The teacher enters defensive mode and stops listening, which collapses Dialogue and Reflection simultaneously.", principle: "Status + Equality + Dialogue" },
        { id: "c", text: "It provides the 'tough love' necessary for professional growth.", isCorrect: false, rationale: "Research on partnership coaching contradicts this. Tough feedback without psychological safety produces compliance or defensiveness — neither of which leads to sustainable skill development.", principle: "Equality + Dialogue" },
        { id: "d", text: "It helps the teacher understand exactly how to fix the problem.", isCorrect: false, rationale: "Evaluative labels ('messy') tell the teacher how the coach perceives them but give no actionable data. Low-inference data ('the transition took 8 minutes and 15 students were off-task during it') gives the teacher something specific to examine and act on.", principle: "Evidence-Based + Dialogue" },
      ],
    },
  ],
};

const scenarioU32 = {
  steps: [
    {
      id: "s32-1",
      situation: "A coach wants to capture a photo of a student's work sample to use as a 'Third Party' artifact in a later conversation. Before taking the photo, the coach says: 'Is it okay if I capture a quick photo of this student's response to use for our discussion later?'",
      context: "The teacher is initially unsure but agrees.",
      question: "What is the purpose of this 'Permission Script'?",
      branches: [
        { id: "a", text: "To follow school rules regarding the use of mobile phones in the classroom.", isCorrect: false, rationale: "While following school rules is relevant, the primary coaching purpose of the Permission Script is about the teacher's professional agency and trust — not rule compliance.", principle: "Choice + Trust" },
        { id: "b", text: "To ensure the Principal knows the coach is working hard.", isCorrect: false, rationale: "The Permission Script is not about principal visibility. It is a teacher-facing protection that preserves the coaching confidentiality and signals partnership.", principle: "Confidentiality + Trust" },
        { id: "c", text: "To protect teacher agency and ensure the teacher feels in control of what is being captured.", isCorrect: true, rationale: "The Permission Script serves Partnership Principle 2 (Choice) — the teacher participates in deciding what evidence is collected. It also signals transparency and confidentiality, which builds the trust that makes authentic coaching possible.", principle: "Choice + Trust + Confidentiality" },
        { id: "d", text: "To let the students know they are being monitored by the coach.", isCorrect: false, rationale: "The Permission Script is directed at the teacher, not the students. Its purpose is to preserve teacher agency within the coaching relationship.", principle: "Choice + Trust" },
      ],
    },
    {
      id: "s32-2",
      situation: "A teacher is defensive about her classroom management. The coach places a photo on the table showing students in the very back row on their phones while the teacher is at the front.",
      context: "The teacher had been arguing that 'all students are engaged.'",
      question: "How does this artifact lower defensiveness compared to the coach stating what she observed?",
      branches: [
        { id: "a", text: "It proves to the teacher that the coach was right all along.", isCorrect: false, rationale: "Using an artifact to prove the coach was right is still a verdict-delivery approach. The artifact's power comes from being a neutral third party, not from winning an argument.", principle: "Equality + Dialogue" },
        { id: "b", text: "It shifts the focus from the teacher's personality to the neutral 'Third Party' object, making the problem something they can solve together.", isCorrect: true, rationale: "This is the key mechanism. When the artifact is on the table between two partners, the teacher is no longer defending against the coach — both are looking at the same object. Status threat decreases because the 'judge' is no longer the coach; it is the photo itself.", principle: "Equality + Dialogue + Status Safety" },
        { id: "c", text: "It makes the meeting more interesting because there are visuals to look at.", isCorrect: false, rationale: "Engagement is a secondary benefit. The primary mechanism is the reduction of status threat through the 'Third Party' positioning of the artifact.", principle: "Equality + Status Safety" },
        { id: "d", text: "It provides evidence that the coach can send to the Principal if needed.", isCorrect: false, rationale: "This is the exact opposite of the Artifact Protection principle. Using coaching artifacts for evaluation destroys trust permanently.", principle: "Confidentiality + Trust" },
      ],
    },
  ],
};

const scenarioU33 = {
  steps: [
    {
      id: "s33-1",
      situation: "At the start of a debrief, the coach places a T-Chart of student evidence on the table. The T-Chart shows that 20 of 40 students stopped writing at 9:10 — the same moment the teacher turned to write on the board.",
      context: "The coach is following the 'Teacher-First' interpretation rule.",
      question: "What should the coach do next?",
      branches: [
        { id: "a", text: "Immediately point out the three most important patterns in the data.", isCorrect: false, rationale: "Pointing out patterns before the teacher has a chance to speak violates Voice (PP-3). The teacher's first interpretation is the most valuable coaching data — it reveals their mental model and opens the door to genuine co-analysis.", principle: "Voice + Dialogue" },
        { id: "b", text: "Ask the teacher: 'What do you notice first when you look at these student actions?' and then wait for their response.", isCorrect: true, rationale: "This is the Teacher-First rule in action. The open question invites teacher interpretation; the wait time creates space for genuine reflection. This is the start of Partnership Dialogue, not coach monologue.", principle: "Voice + Dialogue + Reflection" },
        { id: "c", text: "Explain how the data compares to the school's overall performance goals.", isCorrect: false, rationale: "Contextualizing data relative to school goals before the teacher has interpreted it turns the conversation into a performance evaluation — violating Equality and triggering status threat.", principle: "Equality + Voice" },
        { id: "d", text: "Give the teacher a written summary of the data and move to setting new goals.", isCorrect: false, rationale: "Skipping the teacher's interpretation step and moving directly to goal-setting removes the most important phase of the LEARN cycle — teacher-led sense-making of evidence.", principle: "Voice + Dialogue + Praxis" },
      ],
    },
    {
      id: "s33-2",
      situation: "A coach and teacher are looking at a T-Chart artifact together. The teacher says: 'Wow — I did not realize I only called on students on the left side of the room.' The teacher and coach then work together to plan a new seating arrangement.",
      context: "The teacher identified the pattern themselves — the coach did not point it out.",
      question: "What Partnership Principle describes this process of using evidence to plan new actions?",
      branches: [
        { id: "a", text: "Compliance and Reporting — the teacher is following the coach's direction.", isCorrect: false, rationale: "The teacher discovered the pattern independently and chose the action — there was no compliance or direction from the coach. This is the opposite of compliance.", principle: "Choice + Voice" },
        { id: "b", text: "Direct Instruction — the coach is teaching the teacher a new technique.", isCorrect: false, rationale: "Direct Instruction would involve the coach explaining what to do. Here, the teacher identified the issue and co-planned the action — the coach facilitated, not instructed.", principle: "Equality + Choice" },
        { id: "c", text: "Praxis — the intersection of Reflection and Action.", isCorrect: true, rationale: "Praxis (PP-6) is exactly this: the teacher reflected on evidence (saw the pattern), which produced insight, which converted to a specific real-world action (new seating arrangement). This is the Growth Engine at work.", principle: "Praxis + Reflection" },
        { id: "d", text: "Evaluative Feedback — the coach is using the data to grade the teacher.", isCorrect: false, rationale: "Evaluative feedback is what the coach is NOT doing. The coach used evidence to facilitate teacher self-reflection, which is the partnership alternative to evaluation.", principle: "Equality + Dialogue" },
      ],
    },
  ],
};

// ─── Quiz questions ────────────────────────────────────────────────────────────

const quizU31 = [
  { q: "What is the primary identity shift required in Unit 3.1?", options: ["From Partner to Expert", "From Expert with an Opinion to Mirror Specialist", "From Coach to Principal", "From Observer to Teacher"], correct: 1 },
  { q: "According to the 'Camera Test,' which of these is an objective observation?", options: ["The teacher was very enthusiastic", "The students were behaving poorly", "The teacher walked to the back of the room three times", "The lesson was highly effective"], correct: 2 },
  { q: "What happens to the 'Status' of a teacher when a coach uses evaluative adjectives like 'messy' or 'weak'?", options: ["Status is increased", "Status is denied, triggering defensiveness", "Status remains neutral", "Status is irrelevant to coaching"], correct: 1 },
  { q: "The goal of a 'Mirror Specialist' is to:", options: ["Tell the teacher how they look", "Reflect reality so the teacher can choose to adjust themselves", "Hide the teacher's mistakes", "Praise the teacher's personality"], correct: 1 },
  { q: "In the 'T-Chart' method, what is recorded on the right side?", options: ["Teacher Actions", "Student Evidence (what students say/do)", "Coach's Opinions", "The Principal's comments"], correct: 1 },
  { q: "When a Principal asks for specific teacher data for an audit, the Mirror Specialist should:", options: ["Provide the specific name and data", "Redirect the Principal to school-wide patterns without naming individuals", "Ignore the Principal's request", "Ask the teacher to give the data themselves"], correct: 1 },
];

const quizU32 = [
  { q: "What is a 'Coaching Artifact' in the context of Unit 3.2?", options: ["An ancient historical object", "A physical or digital 'slice' of classroom reality (photo, work sample)", "A certificate given to the teacher", "The coach's personal diary"], correct: 1 },
  { q: "Why are artifacts better than handwritten notes for partnership?", options: ["They are easier to carry", "They act as a 'Third Party' that both partners can look at together", "They prove the coach was actually in the room", "They are required by the government"], correct: 1 },
  { q: "The 'Permission Script' is used to:", options: ["Ask the Principal for permission to visit", "Protect teacher agency before capturing a photo or video", "Get student signatures for a survey", "Allow the coach to take a break"], correct: 1 },
  { q: "An 'Edge Artifact' focuses on:", options: ["The teacher standing at the front", "The students in the 'shadows' (back rows, quiet students)", "The decorations on the classroom walls", "The school's front gate"], correct: 1 },
  { q: "How should an artifact be introduced in a conversation?", options: ["'Look at this mistake you made'", "'What do you notice in this photo of the back row?'", "'I took this to show the Principal'", "'This is why your lesson failed'"], correct: 1 },
  { q: "'Artifact Protection' means the coach:", options: ["Never lets the teacher see the photos", "Refuses to share individual artifacts with administration to preserve trust", "Keeps the artifacts on a public school website", "Deletes everything immediately after the lesson"], correct: 1 },
];

const quizU33 = [
  { q: "The core goal of Unit 3.3 is to move from 'Coach Monologue' to:", options: ["Teacher Monologue", "Partnership Dialogue", "Silent Observation", "Principal Interview"], correct: 1 },
  { q: "In the 'Data-Dialogue Flow,' what should happen first?", options: ["The coach explains the data", "The teacher interprets the artifact/data first", "The coach sets the next goal", "The teacher signs the report"], correct: 1 },
  { q: "What is a 'Dialogue Sparker'?", options: ["A sharp criticism of the lesson", "An open-ended question about a specific piece of evidence", "A timer used to end the meeting", "A compliment about the teacher's clothes"], correct: 1 },
  { q: "If a teacher sees an artifact and becomes self-critical, the coach should:", options: ["Agree with the criticism to be honest", "Redirect to 'Curiosity' and ask what the data suggests for next steps", "Stop the meeting immediately", "Tell the teacher not to worry"], correct: 1 },
  { q: "The 'Wait Time' in a coaching dialogue is used to:", options: ["Wait for the bell to ring", "Allow the teacher space to think and reflect before the coach speaks", "Check the coach's phone for messages", "Make the teacher feel uncomfortable"], correct: 1 },
  { q: "What defines 'Reciprocity' in a coaching dialogue?", options: ["The teacher and coach talking for the same amount of time", "Both partners being open to learning and changing their minds based on data", "The coach giving the teacher a gift", "The teacher doing exactly what the coach says"], correct: 1 },
];

// ─── Open-ended questions ──────────────────────────────────────────────────────

const openEndedU31 = [
  {
    q: "You are observing a classroom where Ms. Bano is moving around frequently. You want to provide objective feedback. Write a low-inference observation note about what you see, and explain why your note passes the Camera Test.",
    rubric: "Score 2: Observation uses counts, timestamps, specific locations, and direct quotes — no adjectives or interpretive language; Camera Test explanation says 'a video camera could capture this exactly.' Score 1: Observation is mostly factual but includes one interpretation word. Score 0: Observation contains subjective adjectives ('enthusiastic,' 'confused,' 'effective') without any factual counts or timestamps.",
  },
  {
    q: "During a debrief, a coach tells a teacher: 'Your transition between the lecture and the activity was quite messy and weak.' According to the module, what is the likely impact of using these evaluative adjectives?",
    rubric: "Score 2: Triggers status threat (SCARF) and stops the teacher's self-reflection by creating a hierarchy of judgment; explains mechanism (brain in defensive mode, stops listening, composes defense rather than processing). Score 1: Says it creates defensiveness without connecting to the SCARF mechanism or Equality principle. Score 0: Defends the use of evaluative language as 'honest feedback' or misattributes the teacher's reaction to personality.",
  },
];

const openEndedU32 = [
  {
    q: "A coach wants to capture a photo of a student's work sample. Before taking the photo, the coach asks the teacher: 'Is it okay if I capture a quick photo of this student's response to use for our discussion later?' What is the purpose of this Permission Script?",
    rubric: "Score 2: Protects teacher agency (Choice principle), ensures teacher feels in control of what is captured, signals confidentiality (not for the principal), builds the trust that makes authentic evidence-collection possible. Score 1: Mentions following rules or getting consent without connecting to the partnership mechanism. Score 0: Says the Permission Script is to make the meeting seem more formal or official.",
  },
  {
    q: "A teacher is defensive about classroom management. The coach places a photo showing back-row students on their phones. How does this artifact lower defensiveness compared to the coach stating what they observed verbally?",
    rubric: "Score 2: Artifact shifts focus from teacher personality to neutral 'Third Party' object — both partners look at the same thing; status threat decreases because the 'judge' is now the photo, not the coach; Equality is restored. Score 1: Says visuals are easier to understand without explaining the status-safety mechanism. Score 0: Says the photo proves the coach was right, treating the artifact as evidence for evaluation rather than a partnership tool.",
  },
];

const openEndedU33 = [
  {
    q: "At the start of a debrief, the coach places a T-Chart on the table. Following the 'Teacher-First' interpretation rule, what should the coach do next and why does this matter?",
    rubric: "Score 2: Ask an open question about what the teacher notices first, then wait (5+ seconds) for teacher to speak; explain that teacher interpretation reveals their mental model, builds ownership, and makes the subsequent co-analysis genuine rather than coached compliance. Score 1: Asks a question but skips explaining why teacher-first interpretation is essential. Score 0: The coach explains the data first before asking for the teacher's view.",
  },
  {
    q: "A coach and teacher look at a T-Chart together. The teacher says: 'I did not realize I only called on students on the left side of the room.' They then plan a new seating arrangement together. Which Partnership Principle does this process represent, and why?",
    rubric: "Score 2: Praxis (PP-6) — the intersection of Reflection and Action; teacher reflected on evidence (saw the pattern), produced insight, which converted to a specific real-world action; explains that without Praxis, coaching is just conversation that does not change classroom reality. Score 1: Names Praxis or Reflection without explaining the mechanism (reflection → insight → action). Score 0: Names a different principle or confuses the scenario with compliance or instruction.",
  },
];

// ─── Main seed function ────────────────────────────────────────────────────────

export async function seedModule3(): Promise<{ success: boolean; log: string[] }> {
  const log: string[] = [];

  const units = [
    { order: 1, title: "Unit 3.1: The Mirror Specialist", description: "Mastering objective observation and the Camera Test to provide low-inference data that protects teacher status", concepts: "Mirror Specialist identity, Camera Test, low-inference vs. high-inference data, T-Chart tool, confidentiality shield, audit culture", slides: slidesU31, scenario: scenarioU31, quiz: quizU31, openEnded: openEndedU31 },
    { order: 2, title: "Unit 3.2: The Artifact Architect", description: "Collecting and using physical evidence as a neutral third party to lower defensiveness in coaching conversations", concepts: "Coaching artifacts, Third Party effect, Permission Script, Edge Artifact, Artifact Protection, partnership vs. audit use of evidence", slides: slidesU32, scenario: scenarioU32, quiz: quizU32, openEnded: openEndedU32 },
    { order: 3, title: "Unit 3.3: Data Into Dialogue", description: "Transforming evidence into teacher-led discovery through Dialogue Sparkers and the Teacher-First interpretation rule", concepts: "Teacher-First interpretation, Data-Dialogue Flow, Dialogue Sparkers, Wait Time, Voice Ratio, Praxis, self-critical redirection", slides: slidesU33, scenario: scenarioU33, quiz: quizU33, openEnded: openEndedU33 },
  ];

  try {
    let mod;
    const { data: existing } = await supabase
      .from("modules")
      .select("id")
      .eq("order_number", 3)
      .single();

    if (existing) {
      mod = existing;
      log.push(`✅ Module already exists: ${existing.id}`);
    } else {
      const { data: created, error: modErr } = await supabase
        .from("modules")
        .insert({
          title: "Module 3: The Mirror Specialist",
          description: "Mastering objective observation, artifact collection, and data-to-dialogue conversion as the core tools of partnership coaching.",
          is_mandatory: false,
          order_number: 3,
          competencies: "Objective Observation, Low-Inference Documentation, Artifact Architecture, Evidence-Based Dialogue, Data Protection",
          desired_outcomes: "Apply Camera Test, create T-Chart observations, use artifacts as Third Party tools, facilitate Teacher-First data interpretation",
        })
        .select()
        .single();

      if (modErr) throw new Error(`Module error: ${modErr.message}`);
      mod = created;
      log.push(`✅ Module created: ${mod.title}`);
    }

    for (const unit of units) {
      let training;
      const { data: existingTraining } = await supabase
        .from("trainings")
        .select("id, created_at")
        .eq("module_id", mod.id)
        .eq("order_number", unit.order)
        .single();

      if (existingTraining) {
        training = existingTraining;
        log.push(`✅ Unit already exists: ${unit.title}`);
      } else {
        const { data: created, error: tErr } = await supabase
          .from("trainings")
          .insert({
            title: unit.title,
            description: unit.description,
            main_concepts: unit.concepts,
            is_common: true,
            module_id: mod.id,
            order_number: unit.order,
          })
          .select()
          .single();

        if (tErr) { log.push(`❌ Unit error (${unit.title}): ${tErr.message}`); continue; }
        training = created;
        log.push(`✅ Unit: ${unit.title}`);
      }

      await supabase.from("training_content").delete().eq("training_id", training.id);

      const { error: slidesErr } = await supabase.from("training_content").insert({
        training_id: training.id,
        format_type: "slides",
        content_url: JSON.stringify(unit.slides),
      });
      if (slidesErr) log.push(`  ❌ Slides error: ${slidesErr.message}`);
      else log.push(`  📊 Slides: ${unit.slides.length} slides`);

      const { error: scErr } = await supabase.from("training_content").insert({
        training_id: training.id,
        format_type: "scenario",
        content_url: JSON.stringify(unit.scenario),
      });
      if (scErr) log.push(`  ❌ Scenario error: ${scErr.message}`);
      else log.push(`  🎭 Scenario: ${unit.scenario.steps.length} situations`);

      const { data: existingAssessment } = await supabase
        .from("assessments")
        .select("id")
        .eq("training_id", training.id)
        .eq("type", "module_quiz")
        .single();

      let assessment;
      if (existingAssessment) {
        assessment = existingAssessment;
        log.push(`  📋 Assessment already exists`);
      } else {
        const { data: created, error: aErr } = await supabase
          .from("assessments")
          .insert({
            title: `${unit.title} — Quiz`,
            type: "module_quiz",
            training_id: training.id,
          })
          .select()
          .single();

        if (aErr) { log.push(`  ❌ Assessment error: ${aErr.message}`); continue; }
        assessment = created;
        log.push(`  📋 Assessment created`);
      }

      const { data: oldQs } = await supabase.from("questions").select("id").eq("assessment_id", assessment.id);
      if (oldQs?.length) {
        const ids = oldQs.map((q: { id: string }) => q.id);
        await supabase.from("options").delete().in("question_id", ids);
        await supabase.from("questions").delete().eq("assessment_id", assessment.id);
      }

      for (let i = 0; i < unit.quiz.length; i++) {
        const q = unit.quiz[i];
        const { data: question, error: qErr } = await supabase
          .from("questions")
          .insert({ assessment_id: assessment.id, question_text: q.q, question_type: "mcq", order_number: i + 1, max_score: 1 })
          .select()
          .single();

        if (qErr) { log.push(`  ❌ Question error: ${qErr.message}`); continue; }

        const optionRows = q.options.map((opt, idx) => ({
          question_id: question.id,
          option_text: opt,
          is_correct: idx === q.correct,
        }));
        await supabase.from("options").insert(optionRows);
      }

      for (let i = 0; i < unit.openEnded.length; i++) {
        const q = unit.openEnded[i];
        await supabase
          .from("questions")
          .insert({
            assessment_id: assessment.id,
            question_text: q.q,
            question_type: "open",
            order_number: unit.quiz.length + i + 1,
            max_score: 2,
            correct_answer: q.rubric,
          });
      }

      log.push(`  ❓ Quiz: ${unit.quiz.length} MCQ + ${unit.openEnded.length} open-ended questions`);
    }

    log.push("✅ Module 3 seed complete!");
    return { success: true, log };
  } catch (err: unknown) {
    log.push(`❌ Fatal error: ${err instanceof Error ? err.message : String(err)}`);
    return { success: false, log };
  }
}
