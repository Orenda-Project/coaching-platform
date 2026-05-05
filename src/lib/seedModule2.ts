/**
 * Module 2 seed data — runs in-browser via Supabase client
 * Triggered from Admin panel → "Seed Module 2" button
 */
import { supabase } from "@/integrations/supabase/client";

// ─── Slides ───────────────────────────────────────────────────────────────────

const slidesU21 = [
  { title: "Unit 2.1: Status & Psychological Safety", content: "The Partnership Foundation — Building the Status-Safe Coaching Environment", keyPoint: "When teachers feel status threat, they fight, flee, or freeze. None of these responses lead to growth.", type: "title" },
  { title: "The Status Threat Problem", content: "In Pakistan's education system, teachers expect to be 'checked' by inspectors and district officers. When a coach walks in, the teacher's brain automatically scans for threat.", bullets: ["Fight: Teacher argues, deflects, justifies", "Flight: Teacher avoids you, gives minimal responses, says 'everything is fine'", "Freeze: Teacher becomes passive, stops thinking creatively, complies without ownership"], keyPoint: "Status threat is biological, not personal. Your goal is to eliminate it — not all discomfort." },
  { title: "The SCARF Model", bullets: ["Status — Perceived relative importance; coach's presence can feel like evaluation", "Certainty — Predictability of what happens next; surprise visits destroy certainty", "Autonomy — Sense of control over choices; imposing goals violates autonomy", "Relatedness — Sense of belonging and safety with another person", "Fairness — Perception of fair exchange; evaluation disguised as coaching feels unfair"], keyPoint: "Each Partnership Principle maps to one or more SCARF dimensions." },
  { title: "The 7 Partnership Principles as Safety Tools", table: { headers: ["Principle", "SCARF Protection", "Coaching Behavior"], rows: [["Equality", "Status + Relatedness", "Sit next to teacher; acknowledge teacher expertise"], ["Choice", "Autonomy", "Ask what the teacher wants to focus on; offer 2–3 options"], ["Voice", "Status + Autonomy", "Ask teacher to speak first; listen without interrupting"], ["Dialogue", "Relatedness + Certainty", "Aim for 50/50 talk time; ask before telling"], ["Reflection", "Certainty", "Share evidence and ask 'What do you notice?' first"], ["Praxis", "Autonomy", "Frame as 'let's try and learn' not 'you must improve'"], ["Reciprocity", "Relatedness", "Ask what the teacher wants you to understand about their context"]] } },
  { title: "Identifying Status Threats in Coaching Language", table: { headers: ["Evaluative (Threatening)", "Partnership (Safe)"], rows: [["'Your classroom management is weak'", "'8 students were talking during explanation — what was driving that?'"], ["'You need to check for understanding more'", "'I counted 2 CFU questions in 30 minutes — what was your thinking?'"], ["'Students were not engaged'", "'18 students had blank worksheets at the 20-min mark — what do you notice?'"], ["'I'll tell you what to fix'", "'What area would you like to focus on?'"]] }, keyPoint: "Rewriting evaluative language into observable evidence + curious question is the core coaching skill." },
  { title: "The Confidentiality Shield", content: "The most difficult boundary to hold — and the most essential. If you share coaching data with principals for evaluation, coaching dies immediately.", bullets: ["Teacher learns data goes to principal → stops being honest", "Teacher performs during observations → shows fake practice", "Teacher avoids vulnerability → coaching becomes inspection", "You lose all partnership trust permanently"], keyPoint: "Coaching data is confidential. It serves growth, not evaluation. The boundary must be held even under pressure." },
  { title: "Field Practice: Selecting Your Partnership Principle", bullets: ["Choose ONE principle to practice in your next visit", "Equality: Position yourself as a thinking partner, not an expert", "Choice: Ask teacher what THEY want to focus on before suggesting anything", "Voice: Ask teacher to speak first before sharing your observations", "Dialogue: Aim for 50/50 talk time — count to check"], keyPoint: "Reflection without commitment is just thinking. Make one specific, observable commitment before your next visit." },
];

const slidesU22 = [
  { title: "Unit 2.2: Evidence-Based Dialogue", content: "Moving from Data to Teacher Agency — the Most Powerful Partnership Tool", keyPoint: "Evidence without partnership = surveillance. Evidence WITH partnership = transformation.", type: "title" },
  { title: "The Core Problem: Verdict vs. Dialogue", content: "You observe a lesson. You see patterns. You have insights. When you share them — the teacher becomes defensive. Why? Because you delivered a VERDICT instead of inviting DIALOGUE.", table: { headers: ["Old Way", "Partnership Way"], rows: [["Coach interprets evidence", "Coach shares evidence"], ["Tells teacher what it means", "Teacher interprets what it means"], ["Prescribes the fix", "Teacher chooses action"]] }, keyPoint: "Evidence-based dialogue shifts power from coach to teacher." },
  { title: "Observable Evidence vs. Coach Interpretation", bullets: ["Observable Evidence: What you saw/heard with your senses. A video camera could verify it.", "Example: 'At 10:15am, teacher asked a question; 3 students raised hands.'", "Coach Interpretation: What you think it means — your inference or conclusion.", "Example: 'Students were not engaged.' (Interpretation — you inferred disengagement from behaviors)"], keyPoint: "When you share interpretation, you position yourself as expert evaluator. When you share evidence, you give teacher data to interpret themselves." },
  { title: "The 3-Step Evidence-Sharing Protocol", bullets: ["STEP 1: Share Observable Evidence — 'Here is what I noticed: At 10:15, you asked about photosynthesis and 3 students raised hands.'", "STEP 2: Ask Curious Question — 'What were you thinking when you saw only 3 hands?' OR 'What do you make of that pattern?'", "STEP 3: Preserve Teacher Choice — 'Based on what you are noticing, is there anything you would like to try?'"], keyPoint: "NEVER skip Step 2. The curious question is what activates teacher Voice and Choice." },
  { title: "Evidence Across the Impact Cycle", table: { headers: ["Impact Cycle Phase", "Evidence Role", "Coach Move"], rows: [["IDENTIFY", "Share baseline evidence — current reality without judgment", "'Here is what I observed' (no interpretation)"], ["LEARN", "Invite teacher interpretation — teacher explains WHY", "'What do you make of this?' — teacher explains context you could not see"], ["IMPROVE", "Track evidence over time — show impact of teacher strategy", "'Last visit: 8 writing. This visit: 42 writing. What do you notice?'"]] }, keyPoint: "Evidence is the thread that runs through the entire cycle. Without it, you have opinions." },
  { title: "Pakistan Classroom Example: Grade 5 Urdu, 65 Students", content: "EVIDENCE COLLECTED: 9:00–9:25am: Teacher reads aloud; 9:25–9:35am: Teacher asks questions, calls on 5 students who raise hands; 9:35–9:45am: 8 students actively writing, 57 with blank pages.", table: { headers: ["Old Way (Judgment)", "Partnership Way (Evidence)"], rows: [["'Students were not engaged — you need to check for understanding more'", "'During 10 minutes of notebook time, 8 students were writing and 57 had blank pages. What was your thinking about that activity?'"], ["Coach interprets, prescribes solution", "Teacher may explain: 'Most students cannot read the board from their seats — classroom is too crowded'"]] }, keyPoint: "Evidence invites teacher context you could not know from observation alone." },
  { title: "Protecting Evidence Confidentiality", content: "Your observation evidence is a COACHING TOOL for teacher growth — not an evaluation report for principals.", bullets: ["When a principal says: 'Show me your observation notes on Teacher X'", "Response: 'My notes are a coaching tool for confidential partnership. If I share them for evaluation, teachers will stop being honest and the coaching relationship ends.'", "'I can share overall THEMES across all teachers without naming individuals.'", "Teachers must know before any observation: 'My notes are for our conversation only — they never go to the principal.'"], keyPoint: "Transparency with teachers about evidence confidentiality is what builds the trust that makes honest coaching possible." },
];

const slidesU23 = [
  { title: "Unit 2.3: Goal-Setting as Co-Creation", content: "From Teacher Compliance to Teacher Ownership — the Entry Point to the Impact Cycle", keyPoint: "Teacher-owned goals create teacher-driven change. Coach-imposed goals create compliance.", type: "title" },
  { title: "What Usually Goes Wrong", bullets: ["SCENARIO 1 — Coach-Imposed Goal: Coach observes, decides 'this teacher needs to work on student talk time,' tells teacher the goal. Result: teacher passively agrees, has no ownership, coaching becomes compliance.", "SCENARIO 2 — Vague Goal: Teacher says 'I want to improve my teaching.' Coach says 'Great!' Result: after 5 visits, neither can tell if progress happened.", "SCENARIO 3 — Principal-Imposed Goal: Principal tells coach to make classroom management the goal. Coach delivers this demand. Result: teacher feels inspected, partnership collapses."], keyPoint: "If coach generates the goal, the entire Impact Cycle foundation crumbles." },
  { title: "The 4-Step Goal Co-Creation Sequence", bullets: ["STEP 1: Invite teacher to identify focus area — 'What is one area you would like to strengthen?' Wait 10+ seconds; resist filling silence.", "STEP 2: Help teacher make goal SMART — Use curious questions for each component: Specific, Measurable, Achievable, Relevant, Time-bound.", "STEP 3: Connect goal to observable student evidence — 'If you reach this goal, what will be different for your STUDENTS?'", "STEP 4: Confirm teacher ownership — 'On a scale of 1–10, how much does this goal matter to you?' If below 8, return to Step 1."], keyPoint: "If teacher rates ownership below 8, it is the wrong goal. Go back." },
  { title: "SMART Goal Questions by Component", table: { headers: ["Component", "Curious Question"], rows: [["Specific", "'When you say [vague word], what would that look like specifically?'"], ["Measurable", "'How will you know if this is working? What could you count or track?'"], ["Achievable", "'Thinking about your 65-student class, what feels realistic to try?'"], ["Relevant", "'Why does this matter for your STUDENTS right now?'"], ["Time-bound", "'When would you like to see this shift happening?'"]] } },
  { title: "Pakistan Classroom Dialogue Example", content: "Teacher: 'I want students to understand better.' → Coach: 'When you say understand better, what would that look like specifically?' → Teacher: 'I want more students to answer questions.' → Coach: 'How will you know if that is happening?' → Teacher: 'I could count raised hands.' → Coach: 'Right now, about how many raise hands?' → Teacher: '3–4 out of 68.'", bullets: ["Coach: 'What feels like a realistic goal for 2 weeks?' → Teacher: 'Maybe 15 students?'", "Coach: 'Why does this matter for your students?' → Teacher: 'If more students answer, more are understanding.'", "Coach: 'On a scale of 1–10, how much does this matter to you?' → Teacher: 'It is a 9.'"], keyPoint: "Notice: Coach asked questions; teacher articulated every SMART component; teacher owns the goal (rated 9/10)." },
  { title: "Protecting Teacher Choice Under Principal Pressure", content: "Principal says: 'Teacher X needs to work on classroom management. Make that the coaching goal.'", bullets: ["Response: 'I can facilitate Teacher X's goal-setting process by sharing observation evidence and asking curious questions.'", "'If Teacher X identifies classroom management as their focus, I will support that goal.'", "'For coaching to be effective, the teacher must own the goal. If I impose it, they will comply but not truly change.'", "'Can I share what goal Teacher X identifies after our conversation?'"], keyPoint: "You are not refusing the principal's concern. You are explaining WHY teacher choice matters for actual improvement." },
];

// ─── Scenarios ────────────────────────────────────────────────────────────────

const scenarioU21 = {
  steps: [
    {
      id: "s21-1",
      situation: "You arrive at a Grade 5 classroom. The teacher, Mr. Ahmed, tenses when he sees you. After the lesson, you start by saying: 'The principal mentioned your pacing is slow, so I am here to tell you that you must use a timer for every activity starting tomorrow.'",
      context: "Mr. Ahmed immediately becomes defensive and stops participating in the conversation.",
      question: "Based on the SCARF model, what happened here and what was the better move?",
      branches: [
        { id: "a", text: "Mr. Ahmed is simply a difficult teacher who does not want to improve.", isCorrect: false, rationale: "Defensiveness is not personality — it is a predictable biological response to status threat. The coach violated Choice (removed autonomy) and Status (signaled superiority via the principal reference).", principle: "Choice + Status (SCARF)" },
        { id: "b", text: "The directive removed Mr. Ahmed's Choice and signaled superiority, triggering a defensive Survival State in his brain.", isCorrect: true, rationale: "This is the precise SCARF analysis. The coach violated Choice (mandatory instruction), signaled principal authority (status hierarchy), and delivered a prescription without evidence or teacher voice — all of which trigger fight/flight/freeze.", principle: "Choice + Status (SCARF)" },
        { id: "c", text: "The advice was given in a friendly tone so the issue must be something else.", isCorrect: false, rationale: "Tone does not override structure. A directive is still a directive regardless of vocal warmth. The SCARF threat came from the content and the authority invoked, not the tone.", principle: "Voice + Equality" },
        { id: "d", text: "The coach should have brought a physical timer to show Mr. Ahmed how to use it.", isCorrect: false, rationale: "The issue is not the absence of a tool. The issue is that the coach skipped evidence, skipped teacher voice, and imposed a solution — a fundamental partnership violation.", principle: "Choice + Dialogue" },
      ],
    },
    {
      id: "s21-2",
      situation: "A new teacher admits during a debrief: 'I really struggled with the transition from lecture to group work — it felt like chaos.'",
      context: "She is being vulnerable and honest, which is exactly what psychological safety enables.",
      question: "What is the mastery-level response from the coach?",
      branches: [
        { id: "a", text: "'Do not worry about it. Just try to be friendlier and more comfortable next time.'", isCorrect: false, rationale: "This dismisses her vulnerability with vague reassurance. It does not honor her honesty or build on the psychological safety she just demonstrated.", principle: "Dialogue + Equality" },
        { id: "b", text: "'I appreciate you sharing that. Let us look at the student data together so we can take risks and find a solution without judgment.'", isCorrect: true, rationale: "This acknowledges the vulnerability (builds safety), then pivots to evidence-based co-analysis (LEARN phase), preserving the trust she extended by being honest. This is the mastery response.", principle: "Equality + Dialogue + Reflection" },
        { id: "c", text: "'It is okay — the school policy says everyone struggles in the first month.'", isCorrect: false, rationale: "Policy reference does not address her specific struggle or honor her reflection. It shuts down growth by normalizing the problem rather than exploring it.", principle: "Praxis + Dialogue" },
        { id: "d", text: "'You should not feel that way. Just follow the instructions I gave you last week.'", isCorrect: false, rationale: "This dismisses her emotional reality and reverts to a directive posture — the opposite of the partnership response this vulnerable moment called for.", principle: "Equality + Choice + Voice" },
      ],
    },
  ],
};

const scenarioU22 = {
  steps: [
    {
      id: "s22-1",
      situation: "While a teacher explains why her lesson struggled, the coach interrupts: 'I had the exact same problem when I taught 5th grade! What I did was change the seating chart immediately. You should do that.'",
      context: "The teacher stops explaining and says 'Okay' without further reflection.",
      question: "This is an example of which coaching pitfall, and why does it harm the partnership?",
      branches: [
        { id: "a", text: "This is Deep Empathy — the coach is connecting by sharing a personal experience.", isCorrect: false, rationale: "Deep Empathy means acknowledging the teacher's feelings and facts. Interrupting with a personal story and a prescription is the opposite — it removes the teacher's voice and choice.", principle: "Voice + Choice" },
        { id: "b", text: "This is Autobiographical Listening — the coach relates everything back to their own experience and prescribes a solution.", isCorrect: true, rationale: "The coach interrupted the teacher's story, redirected to their own experience, and prescribed a solution — bypassing Steps 2 and 3 of the evidence-sharing protocol entirely. The teacher's 'Okay' is compliance, not ownership.", principle: "Voice + Choice + Dialogue" },
        { id: "c", text: "This is Effective Paraphrasing — the coach is summarizing the teacher's concern.", isCorrect: false, rationale: "Paraphrasing means restating the teacher's point in your own words to confirm understanding. This was an interruption followed by a personal story and a mandate.", principle: "Voice + Dialogue" },
        { id: "d", text: "This is Professional Alignment — the coach is sharing relevant experience.", isCorrect: false, rationale: "Sharing experience is not inherently wrong, but INTERRUPTING the teacher before she finishes, then prescribing the solution, violates Voice, Choice, and Dialogue simultaneously.", principle: "Voice + Choice + Dialogue" },
      ],
    },
    {
      id: "s22-2",
      situation: "You observe a Grade 5 Urdu class. During the 10-minute independent writing period, 8 students are actively writing and 57 students sit with blank pages.",
      context: "You are about to start the post-observation conversation.",
      question: "Which opening best demonstrates the 3-step evidence-sharing protocol?",
      branches: [
        { id: "a", text: "'Students were really unfocused during your explanation. Have you thought about using more engaging strategies?'", isCorrect: false, rationale: "'Unfocused' is interpretation, not observable evidence. The question is leading — it implies a deficit and pre-selects the solution direction. Steps 1 and 2 of the protocol are both violated.", principle: "Evidence-Based + Voice" },
        { id: "b", text: "'I noticed during the 10-minute notebook activity, 8 students were actively writing and 57 were sitting with blank pages. What was your thinking about that activity?'", isCorrect: true, rationale: "This is the protocol executed correctly: observable evidence (8 writing, 57 blank pages, time-stamped activity) followed by a genuinely open curious question that invites teacher interpretation. Teacher choice is preserved.", principle: "Evidence-Based + Voice + Choice" },
        { id: "c", text: "'Great lesson overall! A few small things to work on but nothing major.'", isCorrect: false, rationale: "Vague positive framing avoids the real evidence and does not serve the teacher's growth. There is no evidence, no curious question, and no invitation for teacher voice.", principle: "Evidence-Based + Dialogue" },
        { id: "d", text: "'It seemed like students needed clearer instructions. What re-teaching strategy will you use?'", isCorrect: false, rationale: "'Needed clearer instructions' is the coach's interpretation. 'What re-teaching strategy will you use?' skips teacher interpretation entirely and imposes the coach's conclusion.", principle: "Voice + Choice" },
      ],
    },
  ],
};

const scenarioU23 = {
  steps: [
    {
      id: "s23-1",
      situation: "Coach says: 'I noticed only 5 students answered questions during the lesson. I think we should set a goal around increasing participation.' The teacher nods and says 'Okay.'",
      context: "The coach has just finished sharing observation data.",
      question: "Is this a teacher-owned or coach-imposed goal, and why does it matter?",
      branches: [
        { id: "a", text: "Teacher-owned — the teacher agreed with the goal, which shows buy-in.", isCorrect: false, rationale: "'Okay' is compliance, not ownership. The teacher did not identify the focus area, did not articulate the goal, and did not rate its personal relevance. Passive agreement is the hallmark of a coach-imposed goal.", principle: "Choice + Voice" },
        { id: "b", text: "Coach-imposed — the coach identified the focus, diagnosed the problem, and prescribed the goal. Teacher passively agreed.", isCorrect: true, rationale: "The coach violated all 4 goal co-creation steps: they identified the focus (not the teacher), diagnosed the issue (not the teacher), proposed the goal (not the teacher), and the teacher's 'Okay' signals compliance rather than ownership.", principle: "Choice + Voice + Equality" },
        { id: "c", text: "Co-created — the coach used evidence to prompt the conversation, which is the right approach.", isCorrect: false, rationale: "Sharing evidence is the right start. The error was what happened AFTER the evidence was shared: the coach prescribed the goal instead of asking 'What do you make of this?' and letting the teacher identify the focus.", principle: "Voice + Dialogue" },
        { id: "d", text: "It does not matter who generates the goal as long as it is measurable.", isCorrect: false, rationale: "Measurability is only one component of an effective goal. Without teacher ownership (Step 4, rated 8+/10), teachers comply but do not sustain change — the IMPROVE phase collapses.", principle: "Choice + Praxis" },
      ],
    },
    {
      id: "s23-2",
      situation: "Teacher says: 'I want to improve my teaching.' Coach says: 'Great! What specifically about your teaching?' Teacher says: 'I am not sure — what do you think?' Coach says: 'I think you should work on wait time after asking questions.'",
      context: "The teacher is genuinely unsure and has deferred to the coach.",
      question: "What should the coach have done instead of prescribing wait time?",
      branches: [
        { id: "a", text: "Agreed with the teacher's confusion and chosen the wait time goal — after all, it is an evidence-based strategy.", isCorrect: false, rationale: "Prescribing a goal when a teacher defers is the most common goal co-creation failure. The teacher's question ('What do you think?') is an invitation for the coach to take over — partnership coaching means resisting that invitation.", principle: "Choice + Voice" },
        { id: "b", text: "Shared observation evidence from the most recent visit and asked: 'Looking at this data, what do you notice that matters most to you?'", isCorrect: true, rationale: "When a teacher is stuck, evidence is the solution — not prescription. The coach shares neutral data, then re-invites teacher interpretation. This brings the teacher back to their own analysis without the coach imposing a direction.", principle: "Choice + Voice + Evidence-Based" },
        { id: "c", text: "Told the teacher that 'I want to improve' is too vague and asked them to try again with a specific subject area.", isCorrect: false, rationale: "Directing the teacher to 'try again' with more specificity is still coach-directed. The focus area should emerge from evidence, not from the coach redirecting the teacher's framing.", principle: "Equality + Dialogue" },
        { id: "d", text: "Offered two options: 'Would you like to focus on questioning or transitions?' so the teacher still has some choice.", isCorrect: false, rationale: "A false menu — presenting only the coach's pre-selected options — is not genuine teacher choice. The teacher should identify the focus area; the menu comes later in Step 2 (strategy selection), not in Step 1.", principle: "Choice + Voice" },
      ],
    },
  ],
};

// ─── Quiz questions ────────────────────────────────────────────────────────────

const quizU21 = [
  { q: "What does the 'Status' threat in the SCARF model refer to?", options: ["The teacher's salary level", "The perception of being less important than the coach", "The physical location of the school", "The number of students in the class"], correct: 1 },
  { q: "The 'Confidentiality Shield' is used to:", options: ["Hide teacher mistakes from the coach", "Protect the safe space between coach and teacher from administrative judgment", "Keep the school's address private", "Avoid writing any reports at all"], correct: 1 },
  { q: "In a Partnership, 'Equality' means:", options: ["Both the coach and teacher have the same job title", "The coach and teacher have equal say in the professional growth path", "The teacher does not have to listen to the coach", "The Principal is no longer in charge"], correct: 1 },
  { q: "A 'Status-Safe' observation focus should be on:", options: ["The teacher's personality", "Objective student data (e.g., '10 students are off-task')", "The coach's own teaching history", "How the teacher dresses"], correct: 1 },
  { q: "Which is a 'Choice-based' coaching prompt?", options: ["'You must do this'", "'I am telling you to change the seating'", "'Would you prefer to focus on questioning or transitions first?'", "'The Principal wants you to do this'"], correct: 2 },
  { q: "What is the goal of 'Mitigating Threat'?", options: ["To make the teacher afraid so they work harder", "To keep the teacher's brain in a 'Learning State' rather than a 'Survival State'", "To finish the meeting as fast as possible", "To ensure the coach looks like the expert"], correct: 1 },
];

const quizU22 = [
  { q: "'Autobiographical Listening' happens when the coach:", options: ["Listens to the teacher's life story", "Relates everything the teacher says back to the coach's own experience", "Writes a biography of the teacher", "Ignores the teacher completely"], correct: 1 },
  { q: "'Wait Time' in a coaching conversation should be:", options: ["0 seconds", "3–5 seconds after the teacher finishes speaking", "1 minute of total silence", "Only when the coach is tired of talking"], correct: 1 },
  { q: "A 'Deep Empathy' response focuses on:", options: ["Giving the teacher a solution immediately", "Acknowledging the teacher's feelings and the facts of their situation", "Telling the teacher why they are wrong", "Complaining about the school together"], correct: 1 },
  { q: "'Paraphrasing' helps the coach to:", options: ["Talk more than the teacher", "Ensure they have correctly understood the teacher's perspective", "Repeat the textbook word-for-word", "Show off their vocabulary"], correct: 1 },
  { q: "Effective 'Voice Ratio' in a partnership conversation means:", options: ["The coach speaks 80% of the time", "The coach and teacher speak roughly equally, or the teacher speaks more", "No one speaks; it is all written", "The Principal does all the talking"], correct: 1 },
  { q: "Observable Evidence is:", options: ["'The teacher was lazy'", "'Only 5 students out of 40 completed the worksheet'", "'The lesson was boring'", "'The teacher is a natural leader'"], correct: 1 },
];

const quizU23 = [
  { q: "In a Partnership, who chooses the coaching goal?", options: ["The Principal", "The Coach", "The Teacher (with coach guidance)", "The District Office"], correct: 2 },
  { q: "A 'SMART' goal must be 'Measurable,' meaning:", options: ["It is very long", "It can be seen and counted (e.g., student talk time)", "The coach likes it", "It is written in a nice font"], correct: 1 },
  { q: "What happens if a coach imposes a goal on a teacher?", options: ["The teacher works harder", "The teacher complies but does not truly change their practice", "The teacher gets a promotion", "The students learn faster"], correct: 1 },
  { q: "The 'Identify' stage of the Impact Cycle is about:", options: ["Identifying teacher mistakes", "Finding the 'Current Reality' of the classroom", "Identifying who is the boss", "Identifying which students are the loudest"], correct: 1 },
  { q: "'Co-Creation' of a goal means:", options: ["The coach writes it and the teacher signs it", "The teacher and coach build the goal together through dialogue", "The students choose what they want to learn", "There is no goal"], correct: 1 },
  { q: "A 'Small Win' goal is important because:", options: ["It is easy to ignore", "It builds the teacher's confidence and momentum", "It saves the coach time", "It does not require any data"], correct: 1 },
];

// ─── Open-ended questions ──────────────────────────────────────────────────────

const openEndedU21 = [
  {
    q: "Why is 'Psychological Safety' the foundation of the coaching relationship? What specifically happens to teacher behavior when it is present versus absent?",
    rubric: "Score 2: Explains that without safety teachers hide struggles and perform instead of grow; with safety they share authentic challenges, try new strategies, and own growth. Links to SCARF model. Score 1: Mentions that safety is important without distinguishing the behavioral difference. Score 0: Describes safety as comfort or friendliness without connecting to teacher professional behavior.",
  },
  {
    q: "You are conducting a feedback session with Mr. Ahmed. You say: 'The Principal noticed your pacing is slow, so I am here to tell you that you must use a timer for every activity starting tomorrow.' Mr. Ahmed becomes defensive. Using the SCARF model, explain why this directive failed.",
    rubric: "Score 2: Identifies that the directive removed Choice (autonomy), invoked principal authority (status threat from hierarchy), delivered a prescription without evidence or teacher voice — specifically naming SCARF dimensions. Score 1: Notes it was too directive or authoritative without applying the SCARF framework. Score 0: Says the teacher was being difficult or resistant without diagnosing the coaching failure.",
  },
];

const openEndedU22 = [
  {
    q: "A coach uses Paraphrasing after a teacher describes a stressful classroom incident: 'So, if I am hearing you correctly, you felt overwhelmed because only 5 out of 40 students had the prerequisite materials ready. Is that right?' What is the primary benefit of this technique?",
    rubric: "Score 2: Validates the teacher's voice, confirms shared understanding before moving forward, ensures coach is not misinterpreting the situation, creates space for teacher to correct if wrong — all of which preserve the partnership quality of the conversation. Score 1: Says it is useful for understanding without explaining the partnership mechanism. Score 0: Says it lets the coach repeat the facts to remember them — a coach-centered framing that misses the purpose.",
  },
  {
    q: "Describe what 'Observable Evidence' means and give one example of how you would rewrite a judgment-based statement into observable evidence for use in a coaching conversation.",
    rubric: "Score 2: Observable evidence = what a video camera could capture (count, timestamp, specific action, direct quote); gives a specific rewrite (e.g., 'Students weren't engaged' → '57 students had blank pages at the 20-min mark'); explains that the rewrite invites teacher interpretation rather than triggering defensiveness. Score 1: Gives the definition but the rewrite still contains interpretation language. Score 0: Gives examples of evaluation statements without rewriting them, or confuses evidence with interpretation.",
  },
];

const openEndedU23 = [
  {
    q: "A teacher suggests: 'My goal is for my students to learn the material better this week.' According to the SMART framework, why is this goal insufficient, and how should it be changed?",
    rubric: "Score 2: Goal is vague (which material?), unmeasurable (what counts as 'better'?), no timeframe (just 'this week' is not specific enough), no student evidence indicator. Rewrites using specific observable criteria — e.g., '80% of students will answer the exit ticket correctly by Friday.' Score 1: Identifies the goal is vague without addressing all 5 SMART components. Score 0: Says the goal is fine because it mentions student learning, or says it should be longer.",
  },
  {
    q: "A coach wants to ensure 'Teacher Ownership' of a new goal. Instead of telling the teacher what to do, the coach asks: 'Based on the video data we just watched, which area do you feel would have the biggest impact on student engagement if we improved it?' Why is this approach considered the Growth Engine of coaching?",
    rubric: "Score 2: Ownership leads to intrinsic motivation and sustained change; when the teacher identifies the focus, the strategy choice, and the pivot — the teacher is coaching themselves. Coach is no longer necessary for implementation because the teacher has internalized the process. Score 1: Says ownership is good for motivation without explaining the mechanism (self-directed growth). Score 0: Says it allows the coach to avoid making difficult decisions.",
  },
];

// ─── Main seed function ────────────────────────────────────────────────────────

export async function seedModule2(): Promise<{ success: boolean; log: string[] }> {
  const log: string[] = [];

  const units = [
    { order: 1, title: "Unit 2.1: Status & Psychological Safety", description: "Building the partnership foundation through status-safe coaching and the SCARF model", concepts: "SCARF model, status threat, 7 Partnership Principles as safety tools, evaluative vs. partnership language, confidentiality shield", slides: slidesU21, scenario: scenarioU21, quiz: quizU21, openEnded: openEndedU21 },
    { order: 2, title: "Unit 2.2: Evidence-Based Dialogue", description: "Moving from data to teacher agency through observable evidence and curious questioning", concepts: "Observable evidence vs. interpretation, 3-step evidence-sharing protocol, Impact Cycle phases, autobiographical listening, voice ratio", slides: slidesU22, scenario: scenarioU22, quiz: quizU22, openEnded: openEndedU22 },
    { order: 3, title: "Unit 2.3: Goal-Setting as Co-Creation", description: "Facilitating teacher-owned SMART goals through the 4-step co-creation questioning sequence", concepts: "4-step goal co-creation, SMART framework, teacher ownership check (1-10 scale), coach-imposed vs. teacher-owned goals, principal pressure handling", slides: slidesU23, scenario: scenarioU23, quiz: quizU23, openEnded: openEndedU23 },
  ];

  try {
    let mod;
    const { data: existing } = await supabase
      .from("modules")
      .select("id")
      .eq("order_number", 2)
      .single();

    if (existing) {
      mod = existing;
      log.push(`✅ Module already exists: ${existing.id}`);
    } else {
      const { data: created, error: modErr } = await supabase
        .from("modules")
        .insert({
          title: "Module 2: The Partnership Foundation",
          description: "Building psychological safety, evidence-based dialogue, and teacher-owned goal co-creation as the foundation of partnership coaching.",
          is_mandatory: false,
          order_number: 2,
          competencies: "Psychological Safety, Status-Safe Communication, Evidence-Based Dialogue, Goal Co-Creation, Partnership Principles Application",
          desired_outcomes: "Identify SCARF threats, rewrite evaluative language as evidence, facilitate teacher-owned SMART goals, protect evidence confidentiality",
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

    log.push("✅ Module 2 seed complete!");
    return { success: true, log };
  } catch (err: unknown) {
    log.push(`❌ Fatal error: ${err instanceof Error ? err.message : String(err)}`);
    return { success: false, log };
  }
}
