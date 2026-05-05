/**
 * Module 5 seed data — runs in-browser via Supabase client
 * Triggered from Admin panel → "Seed Module 5" button
 */
import { supabase } from "@/integrations/supabase/client";

// ─── Slides ───────────────────────────────────────────────────────────────────

const slidesU51 = [
  { title: "Unit 5.1: The Power of Choice Within the Impact Cycle", content: "Integrating Choice at Every Phase — Moving from Managing to Partnering", keyPoint: "When a teacher chooses the goal, strategy, and pivot, that teacher is coaching themselves. Your role is to design the conditions for self-directed growth.", type: "title" },
  { title: "The Fatal Flaw of the Manager Mindset", content: "Most coaches entered the role with a mental model shaped by how they were taught — expert tells learner what to do. Applied to coaching: coach identifies problem, selects strategy, models it, expects implementation.", table: { headers: ["Manager Mindset", "Partner Mindset"], rows: [["Coach chooses goal", "Teacher chooses goal"], ["Coach selects strategy", "Teacher selects from menu"], ["Coach evaluates implementation", "Teacher reads own evidence"], ["Motivation: please coach", "Motivation: reach own goal"], ["Change lasts while coach is present", "Change outlasts the coaching relationship"]] }, keyPoint: "The moment the coach leaves, motivation evaporates — unless the teacher chose the plan." },
  { title: "Choice at Every Phase of the Impact Cycle", table: { headers: ["Phase", "Teacher's Choice", "Coach's Role"], rows: [["IDENTIFY", "Teacher names the focus area and articulates the PEERS Goal", "Coach shares evidence; asks 'What area do you want to strengthen?'"], ["LEARN", "Teacher selects from a Micro-skills Menu of 2–3 strategies", "Coach offers genuine alternatives with rationale; never prescribes"], ["IMPROVE", "Teacher reads evidence and chooses one of 4 Paths: Stay the Course / Modify / Switch / Re-identify", "Coach presents data; asks 'What does the evidence tell you?'"]] }, keyPoint: "Choice is not optional in any phase. Remove it in any one phase and the teacher loses ownership of the whole cycle." },
  { title: "The PEERS Goal Framework", content: "In the IDENTIFY phase, the teacher articulates a PEERS Goal — a goal that is:", bullets: ["POWERFUL: Connects to something the teacher genuinely cares about", "EASY: Small enough to be achievable in 2 weeks (not overwhelming)", "EMOTIONALLY PEAKING: The teacher rates ownership at 8+ on a 1–10 scale", "REACHABLE: Realistic for the class size, resources, and context", "STUDENT-FOCUSED: Explicitly tied to observable student behavior or outcomes"], keyPoint: "If the teacher cannot rate the goal at 8+, it is not their goal. Return to the evidence and start the co-creation sequence again." },
  { title: "The Micro-skills Menu: Choice in the LEARN Phase", content: "When a teacher is ready to try a new strategy, the coach does NOT prescribe one strategy. The coach offers a Menu of Two or Three:", bullets: ["Both/all options must be genuinely distinct (not the same strategy reworded)", "Each option should have a rationale: 'Some teachers in similar contexts have found X useful because...'", "Coach presents: 'Here are two approaches that have worked in classrooms like yours — which one fits?'", "Teacher selects — and the selection is final unless new evidence changes it"], keyPoint: "A menu with only one real option is not a menu — it is a polite mandate." },
  { title: "The 4 Paths in the IMPROVE Phase", table: { headers: ["Path", "When to Choose It", "Coach Move"], rows: [["STAY THE COURSE", "Evidence shows progress; strategy is working", "'The data shows movement — what does your gut say?'"], ["MODIFY", "Strategy is partially working; one adjustment could improve it", "'What would you change about how you implemented this?'"], ["SWITCH", "Evidence shows strategy is not working; try another menu option", "'What does the evidence suggest about this approach? Would you like to try something different?'"], ["RE-IDENTIFY", "Goal itself needs revision (wrong goal, or goal already achieved)", "'Given what we now know — is this still the right goal?'"]] }, keyPoint: "The teacher chooses the path. The coach presents the evidence. This is the complete IMPROVE phase sequence." },
  { title: "Control vs. Partnership: The Ultimate Comparison", table: { headers: ["Dimension", "Control Posture", "Partnership Posture"], rows: [["Goal", "Compliance with coach's assessment", "Teacher-owned growth and student outcomes"], ["Mechanism", "Coach tells, teacher does", "Teacher discovers, coach facilitates"], ["Motivation", "External (pleasing coach)", "Internal (reaching own goal)"], ["Durability", "Lasts while coach is present", "Outlasts the coaching relationship"], ["End state", "Teacher needs coach forever", "Teacher coaches themselves"]] }, keyPoint: "The end goal of Partnership is its own obsolescence: the teacher no longer needs you because they have internalized the process." },
];

const slidesU52 = [
  { title: "Unit 5.2: Finding the 'Why' — Identifying Intellectual Gaps", content: "Moving from Fixing Symptoms to Solving Root Causes — From Inspector to Instructional Catalyst", keyPoint: "Every persistent classroom struggle has a root cause. Coaching that addresses symptoms leaves the root untouched and the problem recurring.", type: "title" },
  { title: "The Identity Shift: Inspector to Instructional Catalyst", table: { headers: ["Inspector", "Instructional Catalyst"], rows: [["Sees behaviors to correct", "Sees gaps to diagnose"], ["'Students are off-task — you need to manage better'", "'What is the thinking behind how you structured this activity?'"], ["Fixes the symptom", "Finds the root cause (mental model)"], ["Change requires coach presence", "Change outlasts the coaching relationship"], ["Teacher becomes dependent", "Teacher develops diagnostic capacity"]] }, keyPoint: "An Instructional Catalyst changes HOW the teacher thinks about their teaching — not just WHAT they do in the classroom." },
  { title: "What Is an Intellectual Gap?", content: "An Intellectual Gap is the mental model or root cause behind a persistent teaching behavior.", table: { headers: ["Observable Symptom", "Intellectual Gap (Root Cause)"], rows: [["Students rarely respond to questions", "Teacher believes silence means students are thinking (not disengaged)"], ["Transitions take 8–10 minutes", "Teacher has not planned transition cues — assumes students know the procedure"], ["Group work is chaotic", "Teacher believes assigning groups is the same as designing group roles"], ["CFU questions reveal no insight", "Teacher asks 'Did everyone understand?' (yes/no) rather than diagnostic questions"]] }, keyPoint: "If you address the symptom without the gap, the problem returns — because the mental model that created it is unchanged." },
  { title: "The Curious Opener: Finding the Why Without Status Denial", content: "Status Denial is triggered when the coach delivers an evaluation as a fact: 'Students are disengaged because you do not use higher-order questions.'", bullets: ["CURIOUS OPENER: 'Looking at these 10 students who did not finish — what do you think was the biggest barrier for them?'", "CURIOUS OPENER: 'When you planned the group work activity, what role did you imagine each student playing?'", "CURIOUS OPENER: 'What were you hoping to find out when you asked that comprehension question?'"], keyPoint: "A Curious Opener is not a soft criticism — it is a diagnostic question that surfaces the teacher's mental model without triggering defensiveness." },
  { title: "Diagnosing the Intellectual Gap", content: "Once you have asked a Curious Opener and the teacher has responded, listen for the mental model behind the answer:", bullets: ["Teacher says: 'I ask a question and wait for hands' → Mental Model: participation = willingness to volunteer → Gap: no strategy for reaching non-volunteers", "Teacher says: 'I explained it clearly — they should have understood' → Mental Model: explanation = learning → Gap: no CFU mechanism to confirm understanding", "Teacher says: 'Group work means they work together' → Mental Model: proximity = collaboration → Gap: no role structure or task design for genuine interdependence"], keyPoint: "Name the gap — not the symptom. 'I think we might be designing group work as proximity rather than interdependence. What do you think?'" },
  { title: "Pakistan Context: Status Denial Triggers", content: "In Pakistan's public school system, coaches must be especially vigilant. Status Denial is often triggered when coaches:", bullets: ["Deliver an evaluation as a fact: 'Your lesson was ineffective'", "Reference the principal's assessment: 'The principal mentioned your pacing is slow'", "Use Western assessment language that does not match local classroom realities", "Compare the teacher to an idealized standard that ignores class size and resource constraints"], keyPoint: "Finding the Why requires that the teacher feels safe enough to admit their own uncertainty. Every Curious Opener must protect that safety." },
];

const slidesU53 = [
  { title: "Unit 5.3: Closing the Loop — Side-by-Side Modeling and the IMPROVE Phase", content: "Turning the 'Learn' Phase Into Lasting Student Results", keyPoint: "Side-by-Side modeling is a bridge — not a takeover. The teacher watches you model one move, then tries it immediately. The lesson belongs to the teacher.", type: "title" },
  { title: "What Is Side-by-Side Modeling?", content: "Side-by-Side Modeling is a coaching technique used in the LEARN phase where the coach briefly demonstrates one specific teaching move while the teacher observes and then immediately tries it.", table: { headers: ["Class Takeover (Avoid)", "Side-by-Side Modeling (Use)"], rows: [["Coach teaches the whole lesson for the teacher", "Coach models one specific move (2–5 minutes)"], ["Teacher watches passively", "Teacher is next to coach, observes specific move"], ["Teacher feels replaced and deskilled", "Teacher tries the same move immediately after"], ["Coach is the expert; teacher is the recipient", "Coach is the bridge; teacher is the practitioner"]] }, keyPoint: "The measure of good modeling: did the teacher try the move themselves in the same lesson?" },
  { title: "The IMPROVE Phase Meeting Agenda", bullets: ["STEP 1: Share evidence — 'Last visit, you set a goal of X. Here is what the data shows from this visit.'", "STEP 2: Invite teacher interpretation — 'What do you notice about the progress?'", "STEP 3: Present the 4 Paths — 'Given this data, here are the four options: Stay the Course, Modify, Switch, or Re-identify'", "STEP 4: Teacher chooses the path — 'Which of these feels right given what you are seeing?'", "STEP 5: Set next action step — teacher articulates a specific, bite-sized action before the next visit"], keyPoint: "Every IMPROVE meeting ends with a question: 'What should we try next?' — never a conclusion." },
  { title: "Evidence Thresholds: When to Pivot", content: "How much progress is enough to Stay the Course? When should you Switch?", table: { headers: ["Progress Level", "Suggested Path", "Coach Question"], rows: [["Goal exceeded (e.g., target 15 hands, got 22)", "Re-identify: set a new, more ambitious goal", "'This goal is achieved. What is the next frontier?'"], ["Strong progress (target 15 hands, got 12)", "Stay the Course: strategy is working", "'You are at 12 of 15. What would help close the gap?'"], ["Partial progress (target 15 hands, got 8)", "Modify: adjust implementation", "'What would you change about how you tried this?'"], ["No progress (target 15 hands, still at 3)", "Switch: try another menu option", "'The evidence suggests this strategy is not working here. Which other option from our menu would you like to try?'"]] } },
  { title: "Co-Modeling Scripts", content: "Before modeling a teaching move, the coach uses a Co-Modeling Script to explain what they are going to do and invite observation:", bullets: ["'In the next 3 minutes, I am going to try [specific move]. I want you to watch what I do with the [specific group/area]. After, tell me what you noticed.'", "After modeling: 'What did you notice? What would you like to try in the next activity?'", "After teacher tries: 'What did you notice about how students responded when you tried that?'"], keyPoint: "Co-Modeling Scripts end with questions — never with verdicts about how well the coach modeled or how well the teacher tried." },
  { title: "Closing the Loop: The Follow-Through Commitment", content: "Closing the Loop means the coach returns to observe whether the teacher's chosen strategy produced student results — using the same metric as the baseline.", bullets: ["The loop is closed when: new evidence is collected using the same metric, teacher interprets the new data, teacher chooses the next path", "The loop is NOT closed when: the coach prescribes the next action without teacher choice, the coach changes the metric between visits, the coach does not return within 2 weeks"], keyPoint: "If the coach does not return to close the loop, the teacher learns that coaching conversations are not connected to classroom reality — and stops investing in them." },
];

const slidesU54 = [
  { title: "Unit 5.4: Diagnosing the 3 Loops — Precision Coaching", content: "Identifying the Specific Point of Intervention — From Blaming Effort to Diagnosing the System", keyPoint: "Precision Coaching means diagnosing which loop is broken before naming the move. The right intervention in the wrong loop wastes both the coach's and teacher's time.", type: "title" },
  { title: "The 3 Loops Framework", table: { headers: ["Loop", "Where the Gap Is", "Signs of a Gap"], rows: [["PLANNING LOOP", "The plan is a teacher-behavior script, not a student-response map", "Teacher has no anticipation of student confusion; lesson collapses when students respond unexpectedly"], ["OBSERVATION LOOP", "Teacher cannot monitor all students simultaneously (structural constraint)", "Teacher delivers and monitors — but the class is too large to do both effectively"], ["TRAINING LOOP", "Teacher lacks a specific micro-move that would make the lesson run smoothly", "Teacher has the right plan and can observe, but lacks the specific skill to execute (e.g., transition signal, specific question type)"]] } },
  { title: "Loop 1: The Planning Gap — Student-Response Map", content: "A Planning Loop gap occurs when the lesson plan focuses entirely on what the TEACHER will do, with no anticipation of how STUDENTS will respond.", table: { headers: ["Teacher-Behavior Script (Gap)", "Student-Response Map (Correct)"], rows: [["'I will explain photosynthesis for 10 minutes'", "'After 10-minute explanation, I expect: students who understand — hands up; students confused — blank faces. If confused: I will ask a diagnostic CFU question.'"], ["'I will assign group work'", "'Students will need: roles (reader, writer, reporter), task clarity, and a 5-minute warning for presentations. I will circulate in the first 2 minutes.'"]] }, keyPoint: "A plan that only describes teacher behavior cannot anticipate student confusion — because student confusion is not in the plan." },
  { title: "Loop 2: The Observation Gap — Structural Constraints", content: "An Observation Loop gap occurs when the class size or physical environment makes simultaneous delivery and monitoring structurally impossible.", bullets: ["75 students in a small room: delivering instruction AND monitoring all students simultaneously is physically impossible", "Coaching response: acknowledge the structural constraint (PP-7 Reciprocity)", "'With 75 students, simultaneous delivery and monitoring is structurally challenging. Let us think about a strategy that reduces the monitoring load — like a designated 'checkpoint row' you always check during explanations.'", "Do NOT blame the teacher for not monitoring when monitoring is structurally impossible"], keyPoint: "Reciprocity (PP-7) means the coach recognizes that systemic issues — like class size — are not teacher failures." },
  { title: "Loop 3: The Training Gap — Micro-Moves", content: "A Training Loop gap occurs when the teacher has a good plan and adequate observation capacity, but lacks a specific micro-move that would make the lesson run smoothly.", bullets: ["Examples of micro-moves: attention signal ('clap once if you hear me'), cold-call system, specific wait-time technique, transition cue", "Coaching intervention: Rehearsal or Role-play — teacher practices the specific micro-move with the coach before implementing it with students", "NOT a long lecture about classroom management theory — a 5-minute rehearsal of one specific move"], keyPoint: "Training Loop gaps require practice, not explanation. Role-play the move before the teacher tries it in the classroom." },
  { title: "Precision Diagnosis Sequence", content: "BEFORE naming the coaching intervention, always diagnose the loop:", bullets: ["STEP 1: Observe the classroom for the symptom (e.g., transitions taking 8 minutes)", "STEP 2: Ask a Curious Opener: 'When you planned the transition, what did you expect students to do?'", "STEP 3: Listen for which loop the answer reveals: Planning Gap (no anticipation) / Observation Gap (structural constraint) / Training Gap (lacks micro-move)", "STEP 4: NAME the loop — 'I think this might be a planning gap — the transition was not scripted in the lesson plan. Would you like to co-plan it together?'", "STEP 5: Offer the correct intervention for that loop"], keyPoint: "Diagnosing first prevents prescribing the wrong solution. Planning interventions for a Training gap wastes time — and vice versa." },
];

// ─── Scenarios ────────────────────────────────────────────────────────────────

const scenarioU51 = {
  steps: [
    {
      id: "s51-1",
      situation: "During the 'Learn' phase, a teacher is struggling with student transitions. Instead of telling the teacher which method to use, the coach presents a 'Micro-skills Menu' featuring three different evidence-based strategies: a countdown timer, a musical cue, or a call-and-response.",
      context: "The teacher has been resistant to coaching in the past because previous coaches prescribed solutions without giving her any say.",
      question: "Why is providing this 'Menu' essential for Partnership?",
      branches: [
        { id: "a", text: "It allows the coach to avoid being responsible if the strategy fails.", isCorrect: false, rationale: "The Menu is not an abdication of coaching responsibility. The coach has already curated genuinely useful options. The choice step preserves teacher agency — it does not remove coach accountability.", principle: "Choice + Integrity" },
        { id: "b", text: "It ensures the teacher spends more time reading than teaching.", isCorrect: false, rationale: "The Menu is presented in a brief coaching conversation — not a reading assignment. Its purpose is to offer genuine choice, not to increase workload.", principle: "Choice + Praxis" },
        { id: "c", text: "It honors the Choice Principle, ensuring the teacher remains the primary decision-maker and is more likely to implement the strategy.", isCorrect: true, rationale: "The Menu activates Choice (PP-2): by offering genuinely distinct options, the coach ensures the teacher owns the strategy selection. Research consistently shows that strategies teachers choose are implemented more faithfully than strategies teachers are assigned.", principle: "Choice + PRAXIS + Voice" },
        { id: "d", text: "It proves that the coach knows more strategies than the teacher.", isCorrect: false, rationale: "Demonstrating superior knowledge is a Judge mindset move. The Menu's purpose is to offer genuine choice — not to display coach expertise.", principle: "Equality + Choice" },
      ],
    },
    {
      id: "s51-2",
      situation: "A teacher's class has not met their PEERS goal during the 'Improve' phase. The coach asks: 'Now that we see the data, do you want to stick with this strategy but practice it more, or pivot to a different strategy from our menu?'",
      context: "The teacher was invested in the original strategy but the data shows it is not working.",
      question: "This approach is designed to:",
      branches: [
        { id: "a", text: "Force the teacher to admit they chose the wrong goal.", isCorrect: false, rationale: "The coach is not leveraging the data for admission — they are presenting the 4 Paths (Modify vs. Switch) to keep the teacher in a learning state rather than a failure state.", principle: "Equality + Choice" },
        { id: "b", text: "Foster 'Voice' and 'Agency,' keeping the teacher in a learning state rather than a failure state.", isCorrect: true, rationale: "This is the IMPROVE phase sequence executed correctly. The teacher reads the evidence (Voice), chooses the path (Agency), and moves forward without shame. The coach's framing ('stick with or pivot') offers two genuine options — preserving choice at the most vulnerable moment.", principle: "Voice + Agency + Choice" },
        { id: "c", text: "Extend the coaching cycle indefinitely so the coach stays busy.", isCorrect: false, rationale: "The purpose of the IMPROVE phase is to reach the teacher's chosen goal — not to perpetuate the coaching relationship. Closing the loop means tracking evidence until the goal is achieved or re-identified.", principle: "Praxis + Reciprocity" },
        { id: "d", text: "Let the students decide what they want to learn next.", isCorrect: false, rationale: "The 4 Paths are teacher decisions informed by student evidence — not student decisions. The teacher remains the decision-maker in the IMPROVE phase.", principle: "Choice + Voice" },
      ],
    },
  ],
};

const scenarioU52 = {
  steps: [
    {
      id: "s52-1",
      situation: "You observe a lesson where the teacher has a good plan, but students are confused because the instructions for the group activity were delivered too quickly and without a visual aid. You diagnose this as a 'Training Loop' gap.",
      context: "The teacher's plan was solid — the issue was in the delivery of specific instructions.",
      question: "According to the Precision Coaching framework, what is your next move?",
      branches: [
        { id: "a", text: "Co-plan a new lesson from scratch to fix the design.", isCorrect: false, rationale: "Co-planning addresses a Planning Loop gap (where the plan itself is the problem). This is a Training Loop gap — the plan is fine. The teacher needs to practice delivering instructions clearly, not redesign the plan.", principle: "3 Loops Diagnosis" },
        { id: "b", text: "Lead a 'Rehearsal' or 'Role-play' where the teacher practices delivering instructions clearly and at a slower pace.", isCorrect: true, rationale: "Training Loop gaps require micro-move practice — not explanation or planning. A 5-minute rehearsal of the specific instruction-delivery move will be more effective than any amount of theory about classroom management.", principle: "Training Loop + Praxis" },
        { id: "c", text: "Tell the teacher to read a book on classroom management.", isCorrect: false, rationale: "Reading transfers declarative knowledge — not procedural skill. A Training Loop gap is about a missing micro-move, which requires practice to develop, not reading.", principle: "Training Loop + Praxis" },
        { id: "d", text: "Report to the Principal that the teacher does not know how to talk to students.", isCorrect: false, rationale: "This violates confidentiality, misdiagnoses a skill gap as a character problem, and turns a Training Loop gap (solvable through coaching) into an evaluative judgment.", principle: "Confidentiality + Equality" },
      ],
    },
    {
      id: "s52-2",
      situation: "A teacher is frustrated because students are not participating in group work. Upon looking at the lesson plan, the coach realizes there is no individual 'Task' or 'Role' assigned to each student — students are put in groups but given no structure for how to work.",
      context: "This is a consistent pattern across three observed lessons.",
      question: "This is a 'Planning Loop' gap. What is the most effective intervention?",
      branches: [
        { id: "a", text: "Modeling a lecture for the teacher.", isCorrect: false, rationale: "Modeling a lecture addresses a Training Loop gap in explanation delivery. This is a Planning Loop gap — the problem is in the lesson design (no roles, no task structure), not in how the teacher talks.", principle: "3 Loops Diagnosis" },
        { id: "b", text: "Giving the teacher a 'Warning' for poor performance.", isCorrect: false, rationale: "This converts a diagnosable Planning Loop gap into a punitive evaluation. The gap has a specific, fixable root cause — the teacher has not designed interdependence into the group task.", principle: "Equality + Diagnosis" },
        { id: "c", text: "A 'Co-Planning' session to bridge the design gap by adding specific student roles to the lesson plan.", isCorrect: true, rationale: "Co-Planning directly addresses the Planning Loop gap (teacher-behavior script without student-response map). Adding specific roles (reader, writer, reporter) and task structure converts the plan from proximity to genuine interdependence.", principle: "Planning Loop + Co-Planning" },
        { id: "d", text: "Watching a video of a different teacher who is good at group work.", isCorrect: false, rationale: "While video modeling can be a useful LEARN phase tool, the immediate intervention for a Planning Loop gap is co-planning the specific lesson that needs redesign — not observing an abstract example.", principle: "Planning Loop + Praxis" },
      ],
    },
  ],
};

const scenarioU53 = {
  steps: [
    {
      id: "s53-1",
      situation: "A teacher has 50 students in a tiny classroom with broken furniture. The coach realizes that the teacher's struggle with 'Simultaneous Monitoring' during instruction is actually a systemic constraint, not a skill gap.",
      context: "The teacher has been trying hard but physically cannot monitor all students while also delivering instruction.",
      question: "In this case, a 'Mastery' level coach should:",
      branches: [
        { id: "a", text: "Blame the teacher for not being 'tough' enough with the students.", isCorrect: false, rationale: "Toughness is irrelevant when the constraint is structural. With 50 students in a tiny room with broken furniture, simultaneous delivery and monitoring is physically impossible for anyone.", principle: "Reciprocity (PP-7) + Equality" },
        { id: "b", text: "Ignore the physical environment and focus only on the teacher's personality.", isCorrect: false, rationale: "Ignoring structural constraints violates PP-7 (Reciprocity) — the coach's job includes acknowledging what the system makes impossible, not pretending teacher effort can overcome structural barriers.", principle: "Reciprocity (PP-7)" },
        { id: "c", text: "Acknowledge that the systemic environment makes certain moves 'structurally impossible' and advocate for resources or environmental shifts.", isCorrect: true, rationale: "This is Reciprocity (PP-7) in action. The coach first acknowledges the structural constraint, then works with the teacher to find strategies that reduce the monitoring load (e.g., checkpoint row, peer monitoring). Systemic advocacy (documenting the constraint and raising it with administration) is the next step.", principle: "Reciprocity (PP-7) + Advocacy" },
        { id: "d", text: "Tell the teacher to just work harder despite the classroom conditions.", isCorrect: false, rationale: "This is the antithesis of Reciprocity. Pretending that effort can overcome structural impossibility damages trust and shows the coach has not genuinely engaged with the teacher's context.", principle: "Reciprocity (PP-7) + Equality" },
      ],
    },
  ],
};

const scenarioU54 = {
  steps: [
    {
      id: "s54-1",
      situation: "After six months of coaching, you notice that the teacher has started using the '3 Loops' logic to diagnose their own lessons without you present. Before the next coaching visit, she sends you a message: 'I think I have a Training Loop gap in my transition routine — I am going to rehearse it with my team on Friday. Can we talk about what I find?'",
      context: "This teacher started the coaching cycle passively agreeing with coach prescriptions.",
      question: "This represents the goal of 'Obsolescence' in coaching. What does Obsolescence mean?",
      branches: [
        { id: "a", text: "The coach is no longer useful and should be fired.", isCorrect: false, rationale: "Obsolescence is the highest measure of coaching success, not a failure. The coaching framework has become the teacher's own internal habit — which is the explicit goal of Partnership Coaching.", principle: "Praxis + Reciprocity" },
        { id: "b", text: "The coaching framework has become an 'internal habit' for the teacher, leading to long-term sustainable growth.", isCorrect: true, rationale: "This is the precise definition of coaching Obsolescence. The teacher now uses the 3 Loops, diagnoses her own gaps, plans her own interventions, and seeks collaborative input rather than waiting for coach prescriptions. The Impact Cycle is now running inside the teacher's professional identity.", principle: "Praxis + Reciprocity + Choice" },
        { id: "c", text: "The teacher has memorized the coach's scripts and is just repeating them.", isCorrect: false, rationale: "The teacher is not repeating scripts — she is applying a diagnostic framework to a novel situation. Memorization is declarative; what she is demonstrating is the application of a procedural framework.", principle: "Praxis + Reflection" },
        { id: "d", text: "The school has decided to stop using the coaching program.", isCorrect: false, rationale: "Obsolescence refers to the coaching framework becoming self-sustaining within the teacher — not the termination of the program.", principle: "Praxis + Reciprocity" },
      ],
    },
  ],
};

// ─── Quiz questions ────────────────────────────────────────────────────────────

const quizU51 = [
  { q: "The 'Choice Principle' (PP-2) ensures that:", options: ["The Principal approves every coaching goal", "The teacher remains the primary decision-maker during the coaching process", "The coach decides which strategy is 'best' for the classroom", "Students choose their own grades"], correct: 1 },
  { q: "In the 'LEARN' phase, a coach should offer a 'Micro-skills Menu' consisting of:", options: ["A single mandatory instruction", "2–3 evidence-based strategies for the teacher to choose from", "A list of all teaching theories from the last decade", "A choice of which day to be observed"], correct: 1 },
  { q: "What does the teacher choose during the 'IDENTIFY' phase?", options: ["The coach's salary", "The PEERS Goal (Powerful, Easy, Emotionally Peaking, Reachable, Student-Focused)", "The textbook for the next year", "The school's lunch menu"], correct: 1 },
  { q: "When students haven't met the goal in the 'IMPROVE' phase, which of these is a valid 'Pivot' option for the teacher?", options: ["Reporting the students to the office", "Switching to another strategy from the menu", "Quitting the coaching cycle", "Giving the students a lower grade"], correct: 1 },
  { q: "According to the 'Control vs. Partnership' comparison, the end goal of Partnership is:", options: ["Compliance", "Improved Student Outcomes", "Teacher silence", "Following every coach's command"], correct: 1 },
  { q: "'Voice' (PP-3) in this unit means:", options: ["Speaking louder than the teacher", "The teacher's ideas are as valuable as the coach's", "Only the coach speaks during the 'Improve' phase", "Recording the teacher's voice for an audit"], correct: 1 },
];

const quizU52 = [
  { q: "The identity shift in this unit is moving from an 'Inspector' to an:", options: ["Administrator", "Instructional Catalyst", "Evaluator", "Expert with an Opinion"], correct: 1 },
  { q: "To find the 'Why' behind a classroom struggle without triggering 'Status Denial,' a coach should use:", options: ["Directive commands", "Curious Openers", "Evaluative adjectives (e.g., 'That was bad')", "Strict deadlines for improvement"], correct: 1 },
  { q: "An 'Intellectual Gap' refers to:", options: ["A student failing a test", "The mental model or root cause behind a teaching behavior", "Not having enough textbooks", "A teacher being late to class"], correct: 1 },
  { q: "Which of these is a 'Curious Opener' designed to find the root cause?", options: ["'You need to use more visual aids'", "'Looking at these 10 students who did not finish, what do you think was the biggest barrier for them?'", "'Your lesson was messy'", "'Why did you not follow the plan I gave you?'"], correct: 1 },
  { q: "In the Pakistan public school context, 'Status Denial' is often triggered when a coach:", options: ["Asks a question", "Delivers an evaluation as a fact", "Offers a choice", "Listens to the teacher"], correct: 1 },
  { q: "A 'Weak Sample Answer' for diagnosing a gap would be:", options: ["Naming a specific missing skill", "Restating the symptom (e.g., 'Teacher does not know how to engage students')", "Identifying a specific mental model", "Citing student data"], correct: 1 },
];

const quizU53 = [
  { q: "Side-by-Side Modeling is intended to be a:", options: ["Way for the coach to take over the class", "Bridge for the teacher to move from watching to doing with support", "Method for the coach to rest", "Test for the students"], correct: 1 },
  { q: "During an 'Improve' phase meeting, if engagement moved from 40% to 55% against a target of 80%, the teacher must choose:", options: ["To quit", "One of the 4 Paths (Stay the Course, Modify, Switch, Re-Identify)", "To blame the coach", "To ignore the data"], correct: 1 },
  { q: "In 'Side-by-Side' coaching, the coach should describe:", options: ["How well they taught compared to the teacher", "Specifically when they stepped in and what they modeled", "What the students were wearing", "The mistakes the teacher made"], correct: 1 },
  { q: "Co-modeling scripts and Improve meeting agendas should end with:", options: ["Conclusions", "Questions (e.g., 'What should we try next?')", "Verdicts", "Instructions"], correct: 1 },
  { q: "The teacher's selection of one of the 4 Paths should be based on:", options: ["The coach's recommendation", "The teacher's reading of student evidence", "The Principal's mood", "The easiest option available"], correct: 1 },
  { q: "'Closing the Loop' focuses on whether:", options: ["The teacher liked the session", "The strategy actually led to student results", "The coach finished their paperwork", "The bell rang on time"], correct: 1 },
];

const quizU54 = [
  { q: "The shift in this unit is from 'Blaming Effort' to:", options: ["Increasing Audit Pressure", "Diagnosing the System", "Judging Personality", "Ignoring Problems"], correct: 1 },
  { q: "A 'Planning Loop' gap occurs when the plan is:", options: ["Too long", "A teacher-behavior script instead of an anticipatory student-response map", "Handwritten instead of typed", "Not approved by the Principal"], correct: 1 },
  { q: "The 'Training Loop' involves mastering:", options: ["Large pedagogical theories", "Micro-moves that make a lesson run smoothly (e.g., signals, specific questions)", "Using a new computer system", "Student name memorization"], correct: 1 },
  { q: "According to PP-7 (Reciprocity), a coach recognizes that systemic issues like class size can make:", options: ["Coaching unnecessary", "Simultaneous delivery and monitoring structurally impossible", "Teachers lazy", "Data collection easy"], correct: 1 },
  { q: "The goal of the 3 Loops framework is its own:", options: ["Complexity", "Obsolescence as an external tool (becoming an internal habit for the teacher)", "Use in annual performance reviews", "Expansion into 10 loops"], correct: 1 },
  { q: "In Precision Coaching, you should always:", options: ["Name the move first", "Diagnose the loop first, then name the move", "Tell the Principal about the gap", "Give the teacher a generic strategy"], correct: 1 },
];

// ─── Open-ended questions ──────────────────────────────────────────────────────

const openEndedU51 = [
  {
    q: "During the 'Learn' phase, a teacher is struggling with student transitions. Instead of telling the teacher which method to use, the coach presents a 'Micro-skills Menu' featuring three different evidence-based strategies. Why is providing this 'Menu' essential for Partnership?",
    rubric: "Score 2: Honors the Choice Principle (PP-2) — teacher is more likely to implement a strategy they chose; a menu with only one real option is a polite mandate; strategies teachers choose are implemented more faithfully than strategies assigned. Score 1: Says choice is good for buy-in without explaining the implementation mechanism. Score 0: Says the menu is useful because it proves the coach knows multiple strategies.",
  },
  {
    q: "A teacher's class has not met their PEERS goal during the 'Improve' phase. The coach asks: 'Do you want to stick with this strategy but practice it more, or pivot to a different strategy from our menu?' Why does this approach keep the teacher in a learning state rather than a failure state?",
    rubric: "Score 2: Teacher reads own evidence and chooses the path (Voice + Agency); framing as 'two genuine options' preserves choice at the most vulnerable moment; teacher does not experience the unmet goal as personal failure but as data to inform a decision. Score 1: Says choice reduces shame without explaining the mechanism. Score 0: Says the question forces the teacher to admit they chose the wrong goal.",
  },
];

const openEndedU52 = [
  {
    q: "You observe a lesson where the teacher has a great plan, but students are confused because the instructions were delivered too quickly and without a visual aid. You diagnose this as a 'Training Loop' gap. According to the Precision Coaching framework, what is your next move and why?",
    rubric: "Score 2: Training Loop = missing micro-move; intervention = Rehearsal or Role-play of the specific instruction-delivery move; NOT co-planning (that addresses Planning Loop) and NOT explanation (Training needs practice, not theory). Score 1: Identifies the need for practice without connecting to the specific Loop diagnosis. Score 0: Prescribes co-planning or a new lesson design when the plan itself is not the problem.",
  },
  {
    q: "A teacher is frustrated because students are not participating in group work. The lesson plan shows students are put in groups but given no roles or task structure. This is a 'Planning Loop' gap. What is the most effective intervention and why?",
    rubric: "Score 2: Co-Planning session to add specific student roles and task structure to the lesson plan; explains that this is a DESIGN gap (teacher-behavior script without student-response map), not a delivery gap; modeling or videos would address wrong loop. Score 1: Identifies co-planning without explaining why other interventions are wrong for this loop. Score 0: Recommends a lecture on collaborative learning theory or watching a video of a different teacher.",
  },
];

const openEndedU53 = [
  {
    q: "A teacher has 50 students in a tiny classroom with broken furniture. The coach realizes the teacher's struggle with 'Simultaneous Monitoring' is a systemic issue. In this case, what should a 'Mastery' level coach do?",
    rubric: "Score 2: Acknowledge the structural constraint (PP-7 Reciprocity); work with teacher to find strategies that reduce monitoring load for this context; advocate for resources or environmental shifts with administration; do NOT blame teacher for inability to overcome a structural impossibility. Score 1: Acknowledges constraint without naming PP-7 or explaining the advocacy step. Score 0: Tells teacher to work harder or ignores the physical environment.",
  },
  {
    q: "After six months of coaching, a teacher starts using the '3 Loops' logic to diagnose their own lessons before the coaching visit. This represents 'Obsolescence.' What does coaching Obsolescence mean and why is it the highest measure of coaching success?",
    rubric: "Score 2: Obsolescence = coaching framework becomes an internal habit for the teacher; teacher coaches themselves; this is the highest measure because change now outlasts the coaching relationship; the teacher no longer needs the coach to diagnose problems — they have internalized the process. Score 1: Describes the teacher being self-sufficient without explaining why this is the measure of coaching success. Score 0: Confuses Obsolescence with the coaching program ending or the teacher no longer needing to grow.",
  },
];

const openEndedU54 = [
  {
    q: "Explain the difference between a 'Planning Loop' gap and a 'Training Loop' gap, and give a specific example of each from a Pakistan classroom context.",
    rubric: "Score 2: Planning Gap = lesson plan does not anticipate student responses (teacher-behavior script); Training Gap = teacher has good plan but lacks a specific micro-move for execution; Pakistan examples show awareness of local constraints (large classes, limited resources, Urdu-medium instruction). Score 1: Distinguishes the two loops without Pakistan-specific examples. Score 0: Confuses the two loops or describes both as teacher personality problems.",
  },
  {
    q: "Why is it important to diagnose the loop BEFORE naming the coaching intervention? What happens if the coach names the wrong intervention for the wrong loop?",
    rubric: "Score 2: Wrong intervention for wrong loop wastes time — co-planning for a Training gap does not develop the missing micro-move; role-play for a Planning gap does not fix the design; precision means matching the exact intervention to the exact root cause. Score 1: States that diagnosing first is better without explaining the consequence of misdiagnosis. Score 0: Says all interventions are equivalent or that the teacher should choose any intervention they prefer.",
  },
];

// ─── Main seed function ────────────────────────────────────────────────────────

export async function seedModule5(): Promise<{ success: boolean; log: string[] }> {
  const log: string[] = [];

  const units = [
    { order: 1, title: "Unit 5.1: The Power of Choice Within the Impact Cycle", description: "Integrating Choice at every phase of coaching from goal identification to IMPROVE phase pivots", concepts: "Choice Principle, PEERS Goal, Micro-skills Menu, 4 Paths (IMPROVE), Control vs. Partnership, coaching Obsolescence", slides: slidesU51, scenario: scenarioU51, quiz: quizU51, openEnded: openEndedU51 },
    { order: 2, title: "Unit 5.2: Finding the 'Why' — Identifying Intellectual Gaps", description: "Moving from symptom-fixing to root cause diagnosis using Curious Openers and mental model identification", concepts: "Intellectual Gap, Instructional Catalyst identity, Curious Openers, mental model diagnosis, Status Denial triggers, Pakistan context", slides: slidesU52, scenario: scenarioU52, quiz: quizU52, openEnded: openEndedU52 },
    { order: 3, title: "Unit 5.3: Closing the Loop — Side-by-Side Modeling", description: "Turning the Learn phase into lasting student results through side-by-side modeling and IMPROVE phase meeting protocol", concepts: "Side-by-Side Modeling, IMPROVE phase agenda, 4 Paths, evidence thresholds, Co-Modeling Scripts, loop closure", slides: slidesU53, scenario: scenarioU53, quiz: quizU53, openEnded: openEndedU53 },
    { order: 4, title: "Unit 5.4: Diagnosing the 3 Loops — Precision Coaching", description: "Identifying Planning, Observation, or Training Loop gaps to prescribe the exact right coaching intervention", concepts: "3 Loops framework, Planning Loop, Observation Loop, Training Loop, Precision Diagnosis Sequence, coaching Obsolescence", slides: slidesU54, scenario: scenarioU54, quiz: quizU54, openEnded: openEndedU54 },
  ];

  try {
    let mod;
    const { data: existing } = await supabase
      .from("modules")
      .select("id")
      .eq("order_number", 5)
      .single();

    if (existing) {
      mod = existing;
      log.push(`✅ Module already exists: ${existing.id}`);
    } else {
      const { data: created, error: modErr } = await supabase
        .from("modules")
        .insert({
          title: "Module 5: The Instructional Catalyst",
          description: "Integrating Choice across the Impact Cycle, diagnosing intellectual gaps, closing coaching loops with Side-by-Side modeling, and achieving Precision Coaching through 3 Loops diagnosis.",
          is_mandatory: false,
          order_number: 5,
          competencies: "Choice Integration, Intellectual Gap Diagnosis, Side-by-Side Modeling, Precision Coaching, Loop Diagnosis, Coaching Obsolescence",
          desired_outcomes: "Apply Choice at every Impact Cycle phase, diagnose mental models behind teaching patterns, use Side-by-Side modeling, distinguish and address 3 Loop types",
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

    log.push("✅ Module 5 seed complete!");
    return { success: true, log };
  } catch (err: unknown) {
    log.push(`❌ Fatal error: ${err instanceof Error ? err.message : String(err)}`);
    return { success: false, log };
  }
}
