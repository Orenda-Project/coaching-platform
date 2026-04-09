/**
 * Seed Script — Module 1: Universal Core Refresher
 * Run with: npx tsx scripts/seed-module1.ts
 *
 * Creates:
 *  - Module 1 row
 *  - 7 training units (1.0 – 1.6)
 *  - slides + scenario content for each unit
 *  - quiz questions (6 MCQ per unit from question bank)
 */

import { createClient } from "@supabase/supabase-js";

const SUPABASE_URL = process.env.SUPABASE_URL ?? "https://agziuwqpkfmxtospfxns.supabase.co";
const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_KEY ?? "";

if (!SUPABASE_SERVICE_KEY) {
  console.error("Set SUPABASE_SERVICE_KEY env variable");
  process.exit(1);
}

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);

// ─── Slide data ───────────────────────────────────────────────────────────────

const slidesU10 = [
  {
    title: "Unit 1.0: The Coaching Catalyst",
    content: "Building the Foundation for Partnership Coaching",
    keyPoint: "Coaching = CATALYZING teacher growth, not CONTROLLING behavior",
    type: "title",
  },
  {
    title: "What is Coaching?",
    bullets: [
      "Supportive Partnership: Working WITH teachers as co-pilots in their growth journey",
      "Evidence-Based: Grounded in classroom observation data",
      "Growth-Focused: Builds capacity and celebrates progress",
      "Cyclical and Ongoing: Regular, sustained engagement — not a one-time visit",
    ],
    keyPoint: "Coaching is not about fixing teachers — it is about unlocking their potential.",
  },
  {
    title: "The Impact Cycle: 3 Phases",
    bullets: [
      "IDENTIFY — Co-select observable focus, establish baseline, set SMART goal",
      "LEARN — Gather evidence, co-analyze patterns, explore strategies together",
      "IMPROVE — Teacher tries chosen strategy, gathers new evidence, reflects and adjusts",
    ],
    keyPoint: "Every coaching conversation should map to one of these three phases.",
  },
  {
    title: "Coaching vs. Inspection",
    table: {
      headers: ["Feature", "Partnership Coaching", "Evaluative Inspection"],
      rows: [
        ["Tone", "Supportive, growth-focused", "Judgmental, fault-finding"],
        ["Purpose", "Build teacher capacity", "Assess/judge performance"],
        ["Relationship", "Equals working together", "Hierarchical (top-down)"],
        ["Confidentiality", "Stays between coach-teacher", "Reported to principal"],
        ["Frequency", "Regular (every 2 weeks)", "One-time or sporadic"],
        ["Feedback", "Specific, actionable, chosen by teacher", "Corrective, prescribed by evaluator"],
        ["Outcome", "Teacher empowerment and skill growth", "Compliance or consequences"],
      ],
    },
    content: "Understanding this distinction is the first step to becoming a true Coaching Catalyst.",
  },
  {
    title: "The 7 Partnership Principles",
    bullets: [
      "1. Equality — Coach is a co-learner, not an expert authority",
      "2. Choice — Teacher picks their own focus and strategies",
      "3. Voice — Teacher speaks first; coach listens deeply",
      "4. Dialogue — Conversation, not monologue",
      "5. Reflection — Teacher reflects on their own practice",
      "6. Praxis — Try, learn, and adjust together",
      "7. Reciprocity — Coach learns from the teacher too",
    ],
    keyPoint: "These 7 principles are the soul of the coaching relationship.",
  },
  {
    title: "Why Coaching Frequency Matters",
    content: "Research consistently shows that coaching frequency — not intensity — drives lasting change. Regular 2-week cycles create the feedback loops that solidify new habits.",
    bullets: [
      "Skill Development: Repeated practice in context",
      "Confidence Building: Teacher sees their own progress",
      "Reflective Practice: Systematic self-examination",
      "Student Learning Gains: The ultimate outcome",
    ],
  },
  {
    title: "Confidentiality: The Non-Negotiable",
    content: "Coaching notes must NEVER be shared with principals, DEOs, or any evaluative authority. You are the guardian of a professional safe space.",
    bullets: [
      "Explicit agreement at the start of every coaching relationship",
      "Secure storage: locked cabinet or password-protected files only",
      "Anonymous reporting: cohort-level trends only, never individual names",
      "If confidentiality is breached, the coaching relationship collapses",
    ],
    keyPoint: "Holding this boundary — even under pressure — is what makes you a trustworthy coach.",
  },
  {
    title: "The Identity Shift",
    content: "Becoming a Coaching Catalyst requires a fundamental identity shift. You are no longer an inspector, evaluator, or expert. You are a growth partner.",
    bullets: [
      "From: 'I will tell you what to improve'",
      "To: 'We will discover together what to focus on'",
      "From: 'I observe and report'",
      "To: 'I observe and co-explore'",
    ],
    keyPoint: "The hardest part of this shift is resisting the urge to give answers.",
  },
];

const slidesU11 = [
  {
    title: "Unit 1.1: The Partnership Posture",
    content: "Shifting from a judging stance to equality-based, side-by-side partnership",
    type: "title",
  },
  {
    title: "Judge vs. Co-Pilot Mindset",
    table: {
      headers: ["Dimension", "Judge Mindset", "Co-Pilot Mindset"],
      rows: [
        ["Role", "Expert evaluating performance", "Equal partner in growth"],
        ["Data Use", "Evidence of failure", "Fuel for dialogue"],
        ["Questions", "Why didn't you do X?", "What were you aiming for?"],
        ["Next Steps", "Coach prescribes solution", "Teacher chooses action"],
        ["Success", "Compliance with advice", "Teacher owns their growth"],
      ],
    },
    keyPoint: "The Co-Pilot mindset means YOU navigate TOGETHER — the teacher steers.",
  },
  {
    title: "The 3 Competency Pillars",
    bullets: [
      "Developmental Stance — Growth-focused; believe capacity is expandable",
      "Evidence-Based Approach — Observable evidence as the fuel for dialogue",
      "Equality Principle — Honor teacher knowledge; co-create goals as equals",
    ],
    keyPoint: "Confidentiality is embedded in all three pillars.",
  },
  {
    title: "The 4-Step Observation-to-Conversation Flow",
    bullets: [
      "1. OBSERVE — Collect observable behaviors (IDENTIFY phase)",
      "2. ASK — Curious opener to invite teacher ownership (LEARN phase)",
      "3. CO-INTERPRET — Share evidence; teacher interprets it first (LEARN phase)",
      "4. SET STEPS — Teacher chooses action + follow-up date (IMPROVE phase)",
    ],
    keyPoint: "Never skip step 2. Asking before telling is the heart of partnership.",
  },
  {
    title: "Partnership Language Toolkit",
    bullets: [
      "Curious Opener: 'I noticed [X] — can you tell me what you were aiming for?'",
      "Co-Interpretation: 'Here is what I observed. How does this align with your goals?'",
      "Co-Planning: 'Would you like to try strategy A or B? Let us decide together.'",
    ],
    keyPoint: "Practice these phrases until they feel natural — tone matters as much as words.",
  },
  {
    title: "Pakistan Context: Applying Partnership Posture",
    content: "Real scenarios from Pakistani classrooms:",
    bullets: [
      "Urban Govt Primary, Grade 4, 78 students, no textbooks: Share what you observed about student participation before asking about resources",
      "Rural Middle School, Grade 7 Science, broken equipment, principal watching: Maintain partnership posture even under observation pressure",
      "Multi-grade, 65 students, time-pressed: Bite-sized focus; teacher chooses one manageable area",
    ],
  },
  {
    title: "Structured Reflection Practice",
    bullets: [
      "Step 1: Write one exact partnership phrase you will use this week",
      "Step 2: Ask a partner to assess your TONE (not just words)",
      "Step 3: Identify one Judge habit you want to break",
      "Step 4: Make a public commitment to your accountability partner",
    ],
    keyPoint: "Reflection without action is just thinking. Make the commitment specific and observable.",
  },
];

const slidesU12 = [
  {
    title: "Unit 1.2: The Shared Mirror",
    content: "Presenting classroom data as a neutral starting point for collaborative discovery",
    type: "title",
  },
  {
    title: "What is the Shared Mirror?",
    content: "The Shared Mirror is a coaching practice where the coach presents observation data in a way that allows both coach and teacher to explore teaching and learning together — without judgment.",
    table: {
      headers: ["Approach", "Description"],
      rows: [
        ["Old Way (Audit)", "Coach observes → decides → prescribes → teacher complies"],
        ["New Way (Shared Mirror)", "Coach observes → shares neutral data → both interpret → teacher chooses → coach supports"],
      ],
    },
    keyPoint: "A mirror reflects reality without judgment. A SHARED mirror means we look at the reflection TOGETHER.",
  },
  {
    title: "4 Steps of the Shared Mirror Process",
    bullets: [
      "1. Collect Observations — raw data, time-stamped, no interpretation",
      "2. Organize Patterns — group related observations to find themes",
      "3. Share Neutrally — facts + timestamps, zero judgment language",
      "4. Co-Interpret & Agree — teacher selects focus and action",
    ],
    keyPoint: "Steps 3 and 4 are where the Shared Mirror actually happens.",
  },
  {
    title: "Do vs. Avoid",
    table: {
      headers: ["Action", "Do (Shared Mirror)", "Avoid (Judging Stance)"],
      rows: [
        ["Data Sharing", "Time-stamped facts", "Labels and judgments"],
        ["Questioning", "Curious, reflective questions", "Immediate prescriptions"],
        ["Tone", "Exploratory — 'Let us look at this together'", "Deficit language"],
        ["Interpretation", "Invite teacher to interpret first", "Lead with coach's opinion"],
        ["Next Steps", "Teacher selects focus and strategy", "Coach prescribes solution"],
      ],
    },
  },
  {
    title: "Low-Inference vs. High-Inference Language",
    bullets: [
      "LOW-INFERENCE (Use this): 'At 10:15, you asked 4 questions. 3 of the same students responded each time.'",
      "HIGH-INFERENCE (Avoid this): 'Most students were not engaged with your lesson.'",
      "LOW-INFERENCE: 'In 20 minutes of group work, I counted 7 blank worksheets.'",
      "HIGH-INFERENCE: 'Students did not understand the task you gave them.'",
    ],
    keyPoint: "Low-inference language invites curiosity. High-inference language triggers defensiveness.",
  },
  {
    title: "Shared Mirror + Impact Cycle",
    bullets: [
      "IDENTIFY: Neutral data reveals the current reality of the classroom",
      "LEARN: Co-interpretation surfaces insights and informs strategy selection",
      "IMPROVE: Collaborative next steps are measured using the same neutral approach",
    ],
    content: "The Shared Mirror is the tool that makes the Impact Cycle feel collaborative rather than evaluative.",
  },
  {
    title: "Audit Culture in Pakistan: The Real Challenge",
    content: "In Pakistan, teachers often expect judgment. They have experienced AEOs and DEOs using observations to evaluate and punish.",
    bullets: [
      "When teachers expect judgment → they hide struggles, blame students, implement superficially",
      "When they experience shared exploration → they share authentic challenges and own their growth",
      "Your job is to break the audit culture pattern — one conversation at a time",
    ],
    keyPoint: "The Shared Mirror is an act of resistance against audit culture.",
  },
];

const slidesU13 = [
  {
    title: "Unit 1.3: The Growth Engine",
    content: "The Coaching Cycle in Action — Operationalizing the Impact Cycle through a 4-step evidence-based partnership process",
    type: "title",
  },
  {
    title: "The 4-Step Coaching Cycle",
    bullets: [
      "1. PLAN — Co-select observable focus, set SMART goal (IDENTIFY phase)",
      "2. OBSERVE — Collect focused, concrete evidence with timestamps (IDENTIFY phase)",
      "3. CO-ANALYSE — Share evidence neutrally, invite teacher to interpret, co-identify growth area (LEARN phase)",
      "4. SUPPORT — Invite teacher solutions, offer options, teacher chooses, set 2-week revisit (IMPROVE phase)",
    ],
    keyPoint: "Teacher choice is not optional — it is the engine of the whole cycle.",
  },
  {
    title: "Evidence vs. Interpretation",
    table: {
      headers: ["Evidence (Use This)", "Interpretation (Avoid This)"],
      rows: [
        ["'10:15am — Teacher asks: Yeh kahani kis baray mein hai? 12 students raise hands'", "'Students weren't engaged with the lesson'"],
        ["'In 20 minutes, 4 students answered all 8 questions asked'", "'Only a few students understand the content'"],
        ["'Teacher modeled 3 problems, then gave 5 independent practice problems'", "'Teacher did not give enough practice time'"],
        ["'7 worksheets were blank at the end of group work'", "'Students did not understand the task'"],
      ],
    },
    keyPoint: "Evidence is observable and specific. Interpretation is subjective and triggering.",
  },
  {
    title: "Step 3: Co-Analysis — The 3-Step Process",
    bullets: [
      "1. Share Evidence — neutral, descriptive language with timestamps",
      "2. Ask — curious opener with minimum 5-second wait time (let silence work)",
      "3. Co-Identify Growth Area — teacher names the area; coach does not impose it",
    ],
    content: "Example: 'I noticed that 4 students answered 80% of the questions. What is your reading of that pattern?'",
    keyPoint: "The teacher naming the growth area is 10x more powerful than the coach naming it.",
  },
  {
    title: "Step 4: Co-Creating the Action Plan",
    bullets: [
      "Old Way: 'Here is what you need to do this week'",
      "Partnership Way: 'What strategy would you like to try?'",
      "4-Step: Invite → Offer options if stuck → Teacher chooses → Co-plan follow-up",
      "Action must be: bite-sized, observable, and achievable in 2 weeks",
    ],
    keyPoint: "If the teacher did not choose the action, they will not own its implementation.",
  },
  {
    title: "Partnership Principles in Each Step",
    table: {
      headers: ["Cycle Step", "Partnership Principles in Action"],
      rows: [
        ["PLAN", "Choice + Voice — teacher defines the focus"],
        ["OBSERVE", "Reflection — data collected to enable teacher reflection"],
        ["CO-ANALYSE", "Dialogue + Equality — mutual interpretation as partners"],
        ["SUPPORT", "Praxis + Reciprocity — teacher tries, coach learns too"],
      ],
    },
  },
  {
    title: "Handling Resistance: 4 Real Cases",
    bullets: [
      "Case 1: 'I am too busy. Just tell me what to fix.' → Acknowledge time pressure. Offer to focus on just one thing.",
      "Case 2: Principal demands coaching notes → Hold the boundary. Offer school-wide trends instead.",
      "Case 3: You are coaching 18 teachers — how to prioritize? → Focus on highest leverage, lowest performing with most willingness.",
      "Case 4: Teacher chooses an ineffective strategy → Let them try it. The next cycle reveals the evidence together.",
    ],
    keyPoint: "Resistance is information. Approach it with curiosity, not pressure.",
  },
];

const slidesU14 = [
  {
    title: "Unit 1.4: The Trust Bridge",
    content: "Building the Foundation of Ethical Partnership Coaching through confidentiality and trust",
    type: "title",
  },
  {
    title: "Why Trust is the Foundation",
    table: {
      headers: ["Without Trust", "With Trust"],
      rows: [
        ["Teacher hides struggles, sugar-coats reality (IDENTIFY fails)", "Teacher shares authentic challenges"],
        ["Teacher becomes defensive, blames students (LEARN fails)", "Teacher reflects openly on their practice"],
        ["Teacher complies but reverts when coach leaves (IMPROVE fails)", "Teacher owns and sustains change"],
      ],
    },
    keyPoint: "No trust → No Impact Cycle → No student learning gains.",
  },
  {
    title: "The 4-Pillar Ethical Framework",
    bullets: [
      "1. TRUST — Does this action build or undermine trust? Red flag: teacher feels judged, exposed, or controlled",
      "2. CONFIDENTIALITY — Am I protecting coaching data from evaluative use? Red flag: sharing notes, staffroom talk",
      "3. ACCOUNTABILITY — Am I clear about role boundaries? Red flag: becoming the principal's informant",
      "4. INTEGRITY — Does this align with Partnership Principles? Red flag: imposing solutions or telling teachers what to fix",
    ],
    keyPoint: "Run every ethical decision through all 4 pillars before acting.",
  },
  {
    title: "5 Types of Confidentiality Breaches",
    bullets: [
      "1. Undefined Boundaries — no explicit confidentiality conversation at the start",
      "2. Unprotected Access — notebook visible, shared passwords, open files",
      "3. Casual Mentions — staffroom conversation about a teacher's struggles",
      "4. Principal Reporting — sharing coaching notes for evaluation",
      "5. Comparing Teachers — naming who is strong or weak to others",
    ],
    keyPoint: "Any of these five breaches can destroy a coaching relationship permanently.",
  },
  {
    title: "The Confidentiality Agreement",
    content: "Every coaching relationship must begin with an explicit confidentiality agreement covering:",
    bullets: [
      "What data will be collected and how it is stored",
      "Who has access (answer: only the teacher and coach)",
      "How reporting works (anonymous, cohort-level trends only)",
      "Exceptions: legal obligations only (child safety, serious harm)",
    ],
    keyPoint: "Have this conversation in the first meeting. Do not assume confidentiality is understood.",
  },
  {
    title: "4 Trust-Building Behaviors",
    bullets: [
      "1. Share evidence, not judgment (Reflection Principle) — 'I observed X' not 'You did not do Y well'",
      "2. Ask before telling (Voice Principle) — teacher speaks first, always",
      "3. Honor teacher choice (Choice Principle) — even if you disagree with their strategy",
      "4. Acknowledge what is working (Equality Principle) — start with strengths, not gaps",
    ],
    keyPoint: "Trust is built slowly through 100 small consistent actions, and destroyed quickly by one breach.",
  },
  {
    title: "Handling Principal Pressure",
    content: "Scenario: A head teacher requests your coaching notes on 5 teachers for performance reviews. What do you say?",
    bullets: [
      "Response: 'I appreciate your interest in teacher development. My role is coaching support, not evaluation.'",
      "'I can share school-wide trends: areas where multiple teachers are working on similar goals.'",
      "'Sharing individual coaching notes would breach confidentiality and undermine the trust that makes coaching effective.'",
      "Offer alternative: aggregate themes, not individual data",
    ],
    keyPoint: "You are the guardian of the professional safe space. Hold this boundary — it is not optional.",
  },
];

const slidesU15 = [
  {
    title: "Unit 1.5: The Human Filter",
    content: "Using AI as a partnership tool, not a replacement for human professional judgment",
    type: "title",
  },
  {
    title: "AI: Opportunity and Risk",
    table: {
      headers: ["AI Opportunity", "AI Risk"],
      rows: [
        ["Tracks patterns over time humans miss", "Misses classroom context entirely"],
        ["Provides objective frequency data", "Reinforces Western dataset bias"],
        ["Identifies trends across many teachers", "Undermines partnership if misused"],
        ["Reduces observer memory errors", "Audit Culture 2.0 — new inspector"],
      ],
    },
    keyPoint: "AI provides DATA PATTERNS → Human adds CONTEXT → Together = PARTNERSHIP-ALIGNED FEEDBACK",
  },
  {
    title: "AI in the Impact Cycle",
    bullets: [
      "IDENTIFY: AI tracks patterns + human adds 'why' context from knowing the teacher",
      "LEARN: AI data is a conversation starter, not a conclusion — human facilitates co-interpretation",
      "IMPROVE: AI tracks what teacher tried + human ensures teacher owns the strategy selection",
    ],
    keyPoint: "AI should accelerate the Impact Cycle, not replace human judgment in it.",
  },
  {
    title: "The 3-Question AI Validation Framework",
    bullets: [
      "1. CONTEXT — Does this suggestion account for the classroom reality I observed? (class size, resources, curriculum pressure, teacher intent, student needs)",
      "2. BIAS — Could this reflect algorithm bias or cultural assumptions? (Western dataset, penalizes Pakistan realities, deficit framing)",
      "3. PARTNERSHIP — Does this preserve teacher choice, voice, and agency?",
    ],
    keyPoint: "If ANY of the 3 questions raises a concern → ADD CONTEXT or OVERRIDE the AI suggestion.",
  },
  {
    title: "Pakistan-Specific AI Override Examples",
    bullets: [
      "AI says 'use digital tools' → School has no electricity. Human context: teacher uses stones and sticks creatively. OVERRIDE.",
      "AI flags 40-min review as 'below pacing benchmark' → Teacher intentionally slowed for comprehension. ADD CONTEXT.",
      "AI flags 'no differentiation' → 75 students, no teaching assistant, no materials. OVERRIDE.",
      "AI flags 'below benchmark' repeatedly for teacher with 90 students → Teacher doing exceptional work. OVERRIDE.",
    ],
    keyPoint: "You know the classroom. The AI does not.",
  },
  {
    title: "AI Limitations You Must Know",
    bullets: [
      "Training Bias — AI models trained on Western classroom data; penalizes Pakistan classroom realities",
      "Cultural Blindness — misinterprets teacher authority, collective learning styles, Urdu-medium instruction",
      "Deficit Framing — AI often focuses on what is wrong rather than identifying growth opportunities",
      "Technical Errors — AI is not infallible; anomalous data produces anomalous suggestions",
    ],
    keyPoint: "Professional judgment always supersedes AI output. You are the Human Filter.",
  },
  {
    title: "When AI Becomes the New Inspector",
    content: "The greatest risk: AI data used for evaluation → teachers close off → trust destroyed → coaching fails.",
    bullets: [
      "Prevention 1: Establish clear boundaries with principals before introducing AI tools",
      "Prevention 2: Clarify explicitly — AI data is a coaching tool only, never an evaluation input",
      "Prevention 3: Share AI data WITH the teacher first, not with administrators",
      "Prevention 4: Apply the 3-Question Framework before sharing any AI output",
    ],
    keyPoint: "Your role is to be the Human Filter that prevents AI from becoming Audit Culture 2.0.",
  },
];

const slidesU16 = [
  {
    title: "Unit 1.6: Coding the Classroom",
    content: "Using the I Do/We Do/You Do Observation Schema as a Partnership Tool",
    type: "title",
  },
  {
    title: "The Observation Schema",
    table: {
      headers: ["Phase", "Description", "Coach Observes"],
      rows: [
        ["I DO (Teacher Models)", "Teacher demonstrates; students observe", "Time, clarity, think-aloud quality"],
        ["WE DO (Guided Practice)", "Students practice WITH teacher support; real-time feedback", "Teacher circulation, feedback quality"],
        ["YOU DO (Independent Practice)", "Students apply independently; teacher monitors", "Student engagement, teacher monitoring"],
        ["CFU (Check for Understanding)", "Can happen in ANY phase — exit tickets, polls, cold calling, slates", "Question type, student response spread"],
      ],
    },
    keyPoint: "Schema describes lesson structure — it does NOT judge teaching quality.",
  },
  {
    title: "Schema → Impact Cycle",
    bullets: [
      "IDENTIFY: Code current lesson structure (e.g., 25 min I Do, 5 min You Do = baseline pattern)",
      "LEARN: Schema data becomes the conversation starter — teacher explains their intent",
      "IMPROVE: Track what the teacher tries next cycle, compare schema across lessons over time",
    ],
    keyPoint: "Two lessons with identical schema codes can be completely different in quality.",
  },
  {
    title: "Pakistan Example: Grade 4 Maths, 68 Students",
    bullets: [
      "9:00–9:20: I DO — Teacher models 12×4, thinks aloud in Urdu (20 min)",
      "9:20–9:30: WE DO — Students in pairs: 15×3, teacher circulates (10 min)",
      "9:30–9:40: YOU DO — 5 textbook problems independently on slates (10 min)",
      "9:40–9:45: CFU — Students show slates for problem #3 (5 min)",
    ],
    keyPoint: "Total: 20/10/10/5 — a reasonable starting baseline for this class size.",
  },
  {
    title: "The Partnership Way: Sharing Schema Data",
    bullets: [
      "Step 1: Share Data — 'I coded 20 min I Do, 5 min We Do, 10 min You Do, 5 min CFU'",
      "Step 2: Invite Interpretation — 'What was your thinking about the lesson structure today?'",
      "Step 3: Co-Explore — Teacher explains intent; together decide if adjustment is wanted",
    ],
    table: {
      headers: ["Old Way", "Partnership Way"],
      rows: [
        ["'You talked too much'", "'I coded 20 min I Do. What was driving that structure today?'"],
        ["'Students needed more practice'", "'The You Do was 5 minutes. Is that what you intended?'"],
      ],
    },
  },
  {
    title: "What Schema Can and Cannot Tell You",
    table: {
      headers: ["Schema CAN Show", "Schema CANNOT Show"],
      rows: [
        ["Time allocation across phases", "Teaching quality within a phase"],
        ["Presence or absence of phases", "Student engagement or understanding"],
        ["Patterns across multiple lessons", "Cultural responsiveness"],
        ["Changes in structure over time", "Whether structure matched student needs"],
      ],
    },
    keyPoint: "Use schema to open dialogue, not to render verdicts.",
  },
  {
    title: "Audit Culture Risk with Schema",
    content: "Be vigilant about how schema data gets used outside the coaching relationship.",
    bullets: [
      "Risk: Principal mandates a 25/25/50 split — coaches must 'check compliance'. This is audit culture.",
      "Risk: Schema reports demanded for teacher performance evaluations.",
      "Prevention: Establish boundaries with principals before using schema",
      "Boundary language: 'Schema data supports coaching conversations only — it is not a compliance measure.'",
    ],
    keyPoint: "Schema is a mirror for dialogue. The moment it becomes a compliance checklist, it loses all value.",
  },
];

// ─── Scenario data ─────────────────────────────────────────────────────────────

const scenarioU10 = {
  steps: [
    {
      id: "s10-1",
      situation: "You arrive at a school and the head teacher says: 'Go observe Mr. Kamran and give me a report on his weaknesses so I can include it in his annual evaluation.'",
      context: "You are starting your first week as a coach at this school.",
      question: "How do you respond to maintain your coaching role?",
      branches: [
        {
          id: "a",
          text: "Agree to observe and give the head teacher a full report — you want to make a good first impression.",
          isCorrect: false,
          rationale: "This immediately establishes you as an evaluative inspector, destroys any chance of a coaching relationship with Mr. Kamran, and violates the confidentiality principle.",
          principle: "Confidentiality + Accountability",
        },
        {
          id: "b",
          text: "Explain that your role is coaching support, not evaluation. Offer to share school-wide themes after working with teachers.",
          isCorrect: true,
          rationale: "This correctly positions your role, holds the boundary, and offers an alternative that serves the head teacher's interest in improvement without violating confidentiality.",
          principle: "Confidentiality + Accountability",
        },
        {
          id: "c",
          text: "Observe Mr. Kamran but write a softer version of the report that does not reveal too much.",
          isCorrect: false,
          rationale: "This still breaches the coaching-evaluation boundary and deceives both the teacher and the head teacher. It compromises your integrity.",
          principle: "Integrity + Confidentiality",
        },
        {
          id: "d",
          text: "Refuse to observe at all until the head teacher agrees to all partnership principles in writing.",
          isCorrect: false,
          rationale: "While protecting the principles is right, refusing to engage is counterproductive. A constructive conversation that clarifies your role is far more effective.",
          principle: "Equality + Dialogue",
        },
      ],
    },
    {
      id: "s10-2",
      situation: "During your first coaching conversation with Ms. Ayesha, she says: 'Just tell me what I did wrong and what to fix. I don't have time for discussions.'",
      context: "Ms. Ayesha is a 12-year experienced teacher who has only experienced inspection-style feedback.",
      question: "What is the most effective coaching response?",
      branches: [
        {
          id: "a",
          text: "List the three main things she did wrong and give specific prescriptions for each.",
          isCorrect: false,
          rationale: "This gives her what she asked for but reinforces the compliance mindset and makes her dependent on you for answers. It does not build her capacity.",
          principle: "Choice + Praxis",
        },
        {
          id: "b",
          text: "Insist that partnership coaching takes time and she must engage with the process properly.",
          isCorrect: false,
          rationale: "This dismisses her legitimate concern about time and creates resistance. You lose the relationship before it starts.",
          principle: "Equality + Dialogue",
        },
        {
          id: "c",
          text: "Acknowledge her time pressure, share one piece of evidence, and ask one curious question — demonstrate partnership coaching in miniature.",
          isCorrect: true,
          rationale: "This respects her constraint, starts demonstrating the coaching approach immediately, and creates a micro-experience of partnership that can shift her mindset over time.",
          principle: "Equality + Voice + Choice",
        },
        {
          id: "d",
          text: "Skip the coaching conversation and just send her written feedback via WhatsApp.",
          isCorrect: false,
          rationale: "Written feedback without dialogue cannot establish the coaching relationship or build her reflective capacity. It is the least impactful option.",
          principle: "Dialogue + Praxis",
        },
      ],
    },
    {
      id: "s10-3",
      situation: "After your coaching session with Mr. Hassan, a colleague asks you: 'How is Hassan doing? He has been struggling for years — is he improving?'",
      context: "Your colleague genuinely seems to want to help Mr. Hassan.",
      question: "What do you say?",
      branches: [
        {
          id: "a",
          text: "Share some general observations since the colleague seems supportive and means well.",
          isCorrect: false,
          rationale: "Casual mentions — even with good intent — are a confidentiality breach. The coaching relationship depends on absolute discretion.",
          principle: "Confidentiality",
        },
        {
          id: "b",
          text: "Say: 'I appreciate your interest. I keep all coaching conversations confidential. If you want to support Hassan, I would encourage a direct conversation with him.'",
          isCorrect: true,
          rationale: "This holds the confidentiality boundary while being respectful, and redirects in a way that could genuinely help Mr. Hassan.",
          principle: "Confidentiality + Integrity",
        },
        {
          id: "c",
          text: "Say nothing at all and walk away to avoid the conversation.",
          isCorrect: false,
          rationale: "Silence without explanation is awkward and misses an opportunity to educate your colleague about the coaching model.",
          principle: "Dialogue",
        },
        {
          id: "d",
          text: "Tell the colleague that you cannot share specifics but confirm that yes, he is struggling.",
          isCorrect: false,
          rationale: "Even a vague confirmation is a confidentiality breach that can undermine trust if Mr. Hassan hears about it.",
          principle: "Confidentiality",
        },
      ],
    },
  ],
};

const scenarioU11 = {
  steps: [
    {
      id: "s11-1",
      situation: "You observe a Grade 6 lesson. The same 5 students answer every question for 45 minutes. 15 students have blank worksheets.",
      context: "This is your first post-observation conversation with Mr. Ali.",
      question: "Which opening best demonstrates the Partnership Posture?",
      branches: [
        {
          id: "a",
          text: "'I noticed you only called on 5 students today. You need to use cold-calling to engage the rest.'",
          isCorrect: false,
          rationale: "This is a direct prescription — the judge mindset. It tells him what is wrong and what to fix, bypassing his voice and choice entirely.",
          principle: "Voice + Choice",
        },
        {
          id: "b",
          text: "'I recorded that 5 students responded to all 12 questions. What was your intention for student participation today?'",
          isCorrect: true,
          rationale: "This shares neutral evidence and opens with a curious question that invites the teacher to reflect and interpret. This is the co-pilot posture.",
          principle: "Equality + Voice + Reflection",
        },
        {
          id: "c",
          text: "'Great lesson overall! There were a few small things to work on but nothing major.'",
          isCorrect: false,
          rationale: "Vague positivity without evidence avoids the real issue and does not serve the teacher's growth. It is not honest partnership.",
          principle: "Evidence-Based + Equality",
        },
        {
          id: "d",
          text: "'The students seemed disengaged. What do you think about your teaching style?'",
          isCorrect: false,
          rationale: "'Disengaged' is an interpretation, not evidence. Asking about 'teaching style' is too broad and vague to support focused growth.",
          principle: "Evidence-Based",
        },
      ],
    },
    {
      id: "s11-2",
      situation: "A teacher responds to your curious opener by saying: 'Honestly, I do not know why only those 5 students answer. I have been teaching this way for 10 years.'",
      context: "She does not seem defensive — she seems genuinely puzzled.",
      question: "What is your next move in the 4-step flow?",
      branches: [
        {
          id: "a",
          text: "Explain that the research shows cold-calling increases engagement and recommend she try it.",
          isCorrect: false,
          rationale: "Jumping to prescription skips Step 3 (co-interpretation). She has not yet interpreted the data — you are imposing your reading on her.",
          principle: "Choice + Dialogue",
        },
        {
          id: "b",
          text: "Show her the participation data you recorded and ask: 'Looking at this, what do you notice about the pattern?'",
          isCorrect: true,
          rationale: "This moves to Step 3 — co-interpretation. You share the evidence and invite her to make meaning from it. Her insight will be more powerful than yours.",
          principle: "Equality + Reflection + Dialogue",
        },
        {
          id: "c",
          text: "Tell her that 10 years of this pattern is why students are struggling, and now she needs to change.",
          isCorrect: false,
          rationale: "This is judgmental, shaming, and backward-looking. It will create defensiveness and destroy the coaching relationship.",
          principle: "Equality + Trust",
        },
        {
          id: "d",
          text: "Move to Step 4 and suggest that she try a new participation strategy next lesson.",
          isCorrect: false,
          rationale: "Skipping co-interpretation means the action plan will be yours, not hers. Without her owning the insight, she will not own the action.",
          principle: "Choice + Praxis",
        },
      ],
    },
  ],
};

const scenarioU12 = {
  steps: [
    {
      id: "s12-1",
      situation: "You observed a Grade 4 literacy class. You have this data: 47 teacher prompts in 20 minutes, only 4 of 30 students spoken to, 7 blank worksheets at the end.",
      context: "You are about to start the post-observation conversation with Ms. Nadia.",
      question: "Which opening correctly uses the Shared Mirror?",
      branches: [
        {
          id: "a",
          text: "'Ms. Nadia, most students were not engaged in today's lesson. We need to fix that.'",
          isCorrect: false,
          rationale: "This is high-inference language (engagement is interpreted, not observed) and a prescription. It is the audit approach, not the Shared Mirror.",
          principle: "Evidence-Based",
        },
        {
          id: "b",
          text: "'I recorded 47 teacher prompts in 20 minutes and noted that 4 students received all 12 direct questions. Here is the data — what do you notice?'",
          isCorrect: true,
          rationale: "Specific, time-stamped, low-inference data shared neutrally, followed by an invitation to the teacher to interpret it first. This is the Shared Mirror perfectly applied.",
          principle: "Shared Mirror + Equality",
        },
        {
          id: "c",
          text: "'You did a lot of prompting today. That can sometimes reduce student independence.'",
          isCorrect: false,
          rationale: "While less harsh than option A, 'a lot' is still interpretive and the second sentence moves to prescription. It is not neutral data sharing.",
          principle: "Evidence-Based",
        },
        {
          id: "d",
          text: "'What did you think of the lesson today?' (start with teacher's view before sharing any data)",
          isCorrect: false,
          rationale: "While asking first is good (it honours Voice), the Shared Mirror protocol calls for sharing neutral data first so the teacher can reflect on objective evidence, not just impressions.",
          principle: "Shared Mirror Process",
        },
      ],
    },
    {
      id: "s12-2",
      situation: "After seeing the data, Ms. Nadia says: 'Those 4 students always answer. I know the others are not engaging but I do not know why.'",
      context: "She is being honest and open.",
      question: "What is your next step in the Shared Mirror process?",
      branches: [
        {
          id: "a",
          text: "Suggest she use popsicle sticks for random cold-calling — it is proven to work.",
          isCorrect: false,
          rationale: "This is a premature prescription. She has just named the pattern — now is the moment for co-exploration, not solution delivery.",
          principle: "Choice + Dialogue",
        },
        {
          id: "b",
          text: "'What else do you notice in this data that might help us understand why?' (continue co-interpretation before moving to action)",
          isCorrect: true,
          rationale: "She is in the LEARN phase. Deepening the co-interpretation builds her understanding of the root cause, which will make any action she chooses more grounded and owned.",
          principle: "Equality + Reflection",
        },
        {
          id: "c",
          text: "Move to action: 'Great self-awareness. Now, what would you like to try differently next lesson?'",
          isCorrect: false,
          rationale: "Moving to action too quickly misses the depth of the LEARN phase. She has named a symptom but not yet explored the root cause.",
          principle: "Dialogue + Praxis",
        },
        {
          id: "d",
          text: "Share your own interpretation: 'I think the worksheet was too hard for most students, which is why they did not engage.'",
          isCorrect: false,
          rationale: "This imposes your interpretation on her. The Shared Mirror principle requires the teacher to interpret first — your reading should complement, not replace, hers.",
          principle: "Equality + Voice",
        },
      ],
    },
  ],
};

const scenarioU13 = {
  steps: [
    {
      id: "s13-1",
      situation: "During a coaching cycle, a teacher tells you: 'I tried the strategy you suggested but it did not work. The students were chaotic.'",
      context: "You are now in the IMPROVE phase of the cycle.",
      question: "What is the most important thing to notice about this situation?",
      branches: [
        {
          id: "a",
          text: "Apologize for suggesting the wrong strategy and give her a better one to try this week.",
          isCorrect: false,
          rationale: "Wait — you may have made the error in the previous cycle. Did the teacher CHOOSE this strategy, or did you SUGGEST it? If you suggested it, the teacher did not own it, which is why it failed.",
          principle: "Choice + Praxis",
        },
        {
          id: "b",
          text: "Ask: 'Tell me more about what happened. What did you observe when you tried it?' — gather evidence before interpreting.",
          isCorrect: true,
          rationale: "Before any evaluation or next step, return to the IDENTIFY phase. Gather specific evidence about what happened. The Growth Engine starts with observation, not prescription.",
          principle: "Evidence-Based + Dialogue",
        },
        {
          id: "c",
          text: "Tell her that the strategy definitely works and she must have implemented it incorrectly.",
          isCorrect: false,
          rationale: "This is dismissive, evaluative, and destroys trust. It blames the teacher without any evidence.",
          principle: "Equality + Trust",
        },
        {
          id: "d",
          text: "Suggest she return to her previous approach since the new strategy did not work.",
          isCorrect: false,
          rationale: "One failed attempt is data, not a verdict. The Growth Engine iterates — gather evidence, analyze, adjust. Going back is giving up on the cycle.",
          principle: "Praxis + Reciprocity",
        },
      ],
    },
    {
      id: "s13-2",
      situation: "A teacher you coach asks: 'You have 18 teachers to coach. How do you decide who gets more of your time?'",
      context: "This is a genuine, curious question from a reflective teacher.",
      question: "What is the honest and ethical answer?",
      branches: [
        {
          id: "a",
          text: "Tell her that everyone gets equal time — it would not be fair otherwise.",
          isCorrect: false,
          rationale: "Equal time does not mean equitable support. Teachers with different needs require different levels of engagement. Rigidly equal time is not good coaching.",
          principle: "Equality (correctly understood)",
        },
        {
          id: "b",
          text: "Tell her that you focus on teachers who have the most willing attitude and are showing growth.",
          isCorrect: false,
          rationale: "While willingness matters, this approach abandons teachers who most need support. Equity means prioritizing need, not just rewarding the easiest to coach.",
          principle: "Accountability",
        },
        {
          id: "c",
          text: "Explain that you balance several factors: teachers with lowest student outcomes, highest willingness to engage, and most growth potential — and that all teachers are in a coaching cycle.",
          isCorrect: true,
          rationale: "This is an honest, principled answer that balances equity with impact. It respects her intelligence and models reflective, accountable coaching practice.",
          principle: "Accountability + Integrity",
        },
        {
          id: "d",
          text: "Say that you can not share that information — it would breach confidentiality between you and other teachers.",
          isCorrect: false,
          rationale: "Explaining your prioritization framework does not breach confidentiality. This is evasive and misuses the confidentiality principle.",
          principle: "Integrity + Dialogue",
        },
      ],
    },
  ],
};

const scenarioU14 = {
  steps: [
    {
      id: "s14-1",
      situation: "A head teacher says: 'I heard you were coaching Mr. Tariq this week. He has been resistant for years. Is he finally improving?'",
      context: "The head teacher seems genuinely invested in Mr. Tariq's growth.",
      question: "Which response best protects the coaching relationship and maintains your integrity?",
      branches: [
        {
          id: "a",
          text: "Share that Mr. Tariq is showing some positive signs — you think the head teacher deserves to know.",
          isCorrect: false,
          rationale: "Even positive information shared without the teacher's consent is a confidentiality breach. Mr. Tariq has not agreed for his coaching progress to be shared.",
          principle: "Confidentiality",
        },
        {
          id: "b",
          text: "'I keep all coaching conversations confidential. What I can say is that I am working with all teachers on growth areas relevant to student outcomes. Would a school-level summary be useful?'",
          isCorrect: true,
          rationale: "This holds the boundary firmly, explains why, and offers an alternative that serves the head teacher's legitimate interest. It is transparent without breaching confidentiality.",
          principle: "Confidentiality + Accountability + Integrity",
        },
        {
          id: "c",
          text: "Say nothing and change the subject to avoid an uncomfortable conversation.",
          isCorrect: false,
          rationale: "Avoidance does not establish your professional boundary. The head teacher will continue to expect this information from you.",
          principle: "Integrity + Dialogue",
        },
        {
          id: "d",
          text: "Ask Mr. Tariq first if it is okay to share, and if he agrees, then tell the head teacher.",
          isCorrect: false,
          rationale: "While getting consent is better, asking a teacher to agree to share coaching data with the head teacher puts him in an awkward position and blurs the coaching-evaluation boundary.",
          principle: "Confidentiality + Trust",
        },
      ],
    },
    {
      id: "s14-2",
      situation: "You discover that another coach at your school has been sharing coaching notes with the principal. Teachers are now afraid to be honest in coaching sessions.",
      context: "You are a senior coach and this is affecting your coaching relationships too.",
      question: "What is the most ethical and effective course of action?",
      branches: [
        {
          id: "a",
          text: "Do nothing — it is not your responsibility and you do not want to create conflict.",
          isCorrect: false,
          rationale: "Silence makes you complicit in a practice that is destroying the coaching culture at the school. The 4-pillar framework requires integrity — acting consistently with principles even under pressure.",
          principle: "Integrity + Accountability",
        },
        {
          id: "b",
          text: "Talk to the other coach privately, share the 4-pillar framework, and explain how this practice is damaging trust across all coaching relationships at the school.",
          isCorrect: true,
          rationale: "This is the integrity move. Address it directly with the colleague, using the framework rather than personal judgment, and focus on the impact on the whole coaching culture.",
          principle: "Integrity + Accountability + Trust",
        },
        {
          id: "c",
          text: "Report the other coach to management immediately to protect your own coaching relationships.",
          isCorrect: false,
          rationale: "Escalating without first attempting peer dialogue is premature and may damage the collegial relationship unnecessarily. Try the direct conversation first.",
          principle: "Dialogue + Accountability",
        },
        {
          id: "d",
          text: "Start telling teachers privately that you do not share notes — to differentiate yourself from the other coach.",
          isCorrect: false,
          rationale: "This creates a competitive dynamic and does not address the systemic problem. It may also come across as disloyal to your colleague.",
          principle: "Integrity + Accountability",
        },
      ],
    },
  ],
};

const scenarioU15 = {
  steps: [
    {
      id: "s15-1",
      situation: "The AI coaching app flags Ms. Sana as 'Below Benchmark' on student participation (measured at 12%). She teaches 88 students with no teaching assistant.",
      context: "You observe that Ms. Sana is doing exceptional work given her constraints — creative grouping, clear instructions, high student motivation.",
      question: "How do you apply the 3-Question AI Validation Framework?",
      branches: [
        {
          id: "a",
          text: "Share the AI flag with Ms. Sana exactly as it appears and ask her to address the participation benchmark.",
          isCorrect: false,
          rationale: "Using AI output without applying the 3-Question Framework ignores context, may reflect algorithm bias, and puts an unfair burden on the teacher. The Human Filter has not been applied.",
          principle: "Context + Partnership",
        },
        {
          id: "b",
          text: "Dismiss the AI flag entirely — you know she is doing great work and the AI is wrong.",
          isCorrect: false,
          rationale: "Complete dismissal is also wrong. The AI data might still surface a useful conversation, even if the benchmark is not appropriate for her context.",
          principle: "Evidence-Based",
        },
        {
          id: "c",
          text: "Apply the 3 questions: CONTEXT (88 students, no TA) + BIAS (benchmark built on smaller class data) + PARTNERSHIP (frame as exploration, not failure). Override the raw flag and add full human context before any conversation.",
          isCorrect: true,
          rationale: "This is the Human Filter at work. All 3 questions reveal the AI flag needs significant contextualisation before use. The partnership-aligned version of this conversation is very different from the raw AI output.",
          principle: "Context + Bias + Partnership",
        },
        {
          id: "d",
          text: "Ask Ms. Sana whether she thinks the AI feedback is accurate — let her decide.",
          isCorrect: false,
          rationale: "Sharing raw AI output and asking the teacher to evaluate its accuracy is unfair and unhelpful. The coach should have applied the 3-Question Framework first.",
          principle: "Human Filter responsibility",
        },
      ],
    },
    {
      id: "s15-2",
      situation: "The principal asks you to share the AI coaching reports for all teachers you work with so that the school can identify 'underperforming' staff.",
      context: "The principal frames it as being in the interest of school improvement.",
      question: "What do you do?",
      branches: [
        {
          id: "a",
          text: "Share the reports — the principal has a legitimate interest in school improvement.",
          isCorrect: false,
          rationale: "This turns AI coaching data into an evaluation tool, which breaches confidentiality and transforms coaching into Audit Culture 2.0. Once teachers know this is possible, all coaching relationships are damaged.",
          principle: "Confidentiality + Trust",
        },
        {
          id: "b",
          text: "Decline clearly, explain that AI coaching data is a coaching tool only, and offer school-level aggregate themes instead.",
          isCorrect: true,
          rationale: "This holds the boundary, explains the principle, and provides an alternative. It protects the coaching culture while still serving the principal's legitimate interest in school improvement.",
          principle: "Confidentiality + Integrity + Accountability",
        },
        {
          id: "c",
          text: "Share anonymised versions of the reports to protect individual teachers.",
          isCorrect: false,
          rationale: "In a small school, anonymised data is often identifiable. This partial solution still risks breaching trust and does not resolve the fundamental boundary issue.",
          principle: "Confidentiality",
        },
        {
          id: "d",
          text: "Ask each teacher for consent before sharing their AI report with the principal.",
          isCorrect: false,
          rationale: "Asking teachers to consent to sharing coaching data with evaluative authorities puts them in an impossible position and normalises the blurring of coaching and evaluation.",
          principle: "Trust + Confidentiality",
        },
      ],
    },
  ],
};

const scenarioU16 = {
  steps: [
    {
      id: "s16-1",
      situation: "You observe a Grade 7 Science class. Your schema coding shows: 35 min I Do, 5 min We Do, 0 min You Do, 5 min CFU (total 45 min).",
      context: "The teacher explains afterwards that students had an important exam coming up and needed full coverage of content.",
      question: "How do you share this schema data using the Partnership Way?",
      branches: [
        {
          id: "a",
          text: "'Your lesson was 78% I Do — research shows students need at least 40% independent practice. You need to restructure your lessons.'",
          isCorrect: false,
          rationale: "Prescribing a formula based on schema percentages is exactly what schema should NOT be used for. It ignores teacher intent, student context, and uses schema as a compliance measure.",
          principle: "Partnership + Context",
        },
        {
          id: "b",
          text: "'I coded 35 min I Do, 5 min We Do, 0 min You Do, 5 min CFU. What was driving the lesson structure today?'",
          isCorrect: true,
          rationale: "Share the neutral data, then invite interpretation. The teacher's context (exam preparation) is a legitimate reason for this structure. This opens the dialogue without judgment.",
          principle: "Shared Mirror + Voice + Equality",
        },
        {
          id: "c",
          text: "Do not share the schema data — the teacher's explanation makes it irrelevant.",
          isCorrect: false,
          rationale: "The data is still valuable for the coaching conversation. The teacher's intent should inform the co-interpretation, not replace the evidence.",
          principle: "Evidence-Based",
        },
        {
          id: "d",
          text: "'Great lesson! The students seemed to be learning a lot during your explanation.'",
          isCorrect: false,
          rationale: "Vague positive feedback without the schema data misses the coaching opportunity. Growth requires honest, specific evidence — not just encouragement.",
          principle: "Evidence-Based + Partnership",
        },
      ],
    },
    {
      id: "s16-2",
      situation: "A teacher says: 'Now that I understand the schema, can you tell me the right percentage for each phase? I want to do it correctly.'",
      context: "He is enthusiastic and genuinely wants to improve.",
      question: "How do you respond?",
      branches: [
        {
          id: "a",
          text: "Give him a 25/25/50 guideline as a starting target — it is better than having no goal.",
          isCorrect: false,
          rationale: "A fixed formula turns schema into a compliance checklist and removes teacher judgment from the equation. There is no one right ratio — it depends on the lesson goal, student needs, and context.",
          principle: "Choice + Context",
        },
        {
          id: "b",
          text: "'The schema does not prescribe percentages — it is a tool to describe what you observe and start conversations. What does your data tell you about your students' needs right now?'",
          isCorrect: true,
          rationale: "This correctly repositions schema as a mirror for reflection, not a formula for compliance, and turns his question back into a coaching inquiry about his students.",
          principle: "Partnership + Voice + Reflection",
        },
        {
          id: "c",
          text: "'I do not have an answer to that — it depends on too many factors.' (Leave it at that.)",
          isCorrect: false,
          rationale: "While the content is partially correct, this response is incomplete. He deserves a fuller explanation of why schema has no formula and how to use it well.",
          principle: "Dialogue + Equality",
        },
        {
          id: "d",
          text: "Tell him that what matters most is just that all 4 phases appear in every lesson.",
          isCorrect: false,
          rationale: "Requiring all 4 phases in every lesson is another prescription that ignores context. A rich I Do lesson might not need a We Do; a CFU-heavy lesson might revisit I Do. Context drives structure.",
          principle: "Context + Choice",
        },
      ],
    },
  ],
};

// ─── Quiz questions ─────────────────────────────────────────────────────────────

const quizU10 = [
  { q: "What is the primary definition of coaching?", options: ["Inspecting teachers and reporting to management", "A supportive partnership that builds teacher capacity", "Giving teachers prescriptive feedback on their weaknesses", "Evaluating teachers for annual performance reviews"], correct: 1 },
  { q: "What does the 'Implementation Gap' refer to in coaching?", options: ["The gap between school management and classroom teachers", "The gap between learning theory and applying it in the classroom", "The gap between strong and weak teachers", "The gap between coaching visits and teacher availability"], correct: 1 },
  { q: "How is coaching fundamentally different from inspection?", options: ["Coaching is shorter and less formal than inspection", "Coaching is a partnership of equals; inspection is top-down judgment", "Coaching happens more frequently than inspection", "Coaching only focuses on positive feedback"], correct: 1 },
  { q: "In the 'Co-Pilot' mindset, who navigates the growth journey?", options: ["The coach, who knows the destination", "The coach and teacher together, as equal partners", "The head teacher, who sets the direction", "The teacher alone, once the coach has explained the goal"], correct: 1 },
  { q: "Why is coaching frequency more important than coaching intensity?", options: ["Because more visits mean more accountability for the teacher", "Because regular cycles solidify new habits through consistent feedback loops", "Because frequent visits allow the coach to catch more mistakes", "Because teachers prefer more visits to fewer, longer sessions"], correct: 1 },
  { q: "Which of the following best describes the tone of a Coaching Catalyst?", options: ["Authoritative and directive, to ensure teachers take action", "Supportive and constructive, building confidence and capacity", "Critical and challenging, to push teachers out of comfort zones", "Neutral and distant, to maintain professional objectivity"], correct: 1 },
];

const quizU11 = [
  { q: "What is the first step in the 4-step Observation-to-Conversation Flow?", options: ["Ask a curious opener to invite teacher ownership", "Observe and collect observable behaviors", "Co-interpret evidence with the teacher", "Set next steps with a follow-up date"], correct: 1 },
  { q: "The 'Choice' Partnership Principle means:", options: ["The coach chooses the most important improvement area for the teacher", "Teachers have a say in their own professional goals and the actions they take", "Both the coach and teacher share equal input in all decisions", "Teachers choose whether to participate in coaching or not"], correct: 1 },
  { q: "The 'Expert Trap' in coaching refers to:", options: ["Coaches who are too knowledgeable about pedagogy to relate to teachers", "Dominating the conversation by giving answers instead of facilitating inquiry", "Setting goals that are too ambitious for the teacher's current level", "Using research evidence to justify coaching recommendations"], correct: 1 },
  { q: "What does 'Reciprocity' mean in partnership coaching?", options: ["The coach and teacher must take turns leading the coaching conversation", "The coach learns from the teacher just as the teacher learns from the coach", "Both the coach and teacher must evaluate each other's performance", "Teachers reciprocate by implementing every suggestion the coach offers"], correct: 1 },
  { q: "What is the hallmark of the 'Equality' Partnership Principle in practice?", options: ["The coach and teacher receive the same salary and status in the school", "Sitting side-by-side to review data and co-create solutions together", "Treating all teachers as equally capable regardless of their experience", "The coach avoiding all evaluative language in coaching conversations"], correct: 1 },
  { q: "What happens in 'Co-interpretation' (Step 3 of the 4-step flow)?", options: ["The coach interprets the evidence and shares the meaning with the teacher", "Both partners examine the observation evidence to find meaning together", "The teacher interprets alone and the coach validates their analysis", "The coach and teacher discuss research studies that explain the evidence"], correct: 1 },
];

const quizU12 = [
  { q: "The Shared Mirror presents classroom data as:", options: ["Evidence of teacher failure that must be addressed", "A neutral starting point for collaborative discovery", "Objective proof of areas where the teacher needs to improve", "A report to share with school management for accountability"], correct: 1 },
  { q: "Which of the following is a 'Low-Inference' observation statement?", options: ["'Students were not engaged with the lesson activity'", "'You asked 4 open-ended questions in the first 10 minutes'", "'The teacher did not manage classroom behavior effectively'", "'Students seemed confused by the instructions given'"], correct: 1 },
  { q: "Why is 'High-Inference' feedback dangerous in coaching conversations?", options: ["It takes too long to explain and reduces coaching efficiency", "It triggers defensiveness because it is subjective, not based on facts", "It is too positive and does not help teachers identify real weaknesses", "It relies on the coach's expertise rather than the teacher's knowledge"], correct: 1 },
  { q: "In the Shared Mirror protocol, what is the role of the 'Neutral Third Party'?", options: ["A school supervisor who observes coaching sessions for quality", "The observation data or evidence that both coach and teacher examine together", "An external coach who mediates disagreements between coach and teacher", "The classroom students whose learning outcomes guide the conversation"], correct: 1 },
  { q: "How does 'time-stamping' observation data support the Shared Mirror?", options: ["It proves the coach was present for the full lesson", "It provides an objective, verifiable timeline for teacher reflection", "It demonstrates that the coach is thorough and detail-oriented", "It helps calculate the percentage of time spent in each lesson phase"], correct: 1 },
  { q: "Where should the coach sit when using the Shared Mirror protocol?", options: ["Opposite the teacher to maintain a professional, formal distance", "Side-by-side with the teacher to examine data together as equals", "At the head of the table to establish a leadership posture", "At the back of the room during the lesson, then at the front for debrief"], correct: 1 },
];

const quizU13 = [
  { q: "The Growth Engine coaching cycle operationalizes which framework?", options: ["The 7 Partnership Principles", "The Impact Cycle (Identify, Learn, Improve)", "The PEERS Goal framework", "The Observation Schema (I Do, We Do, You Do)"], correct: 1 },
  { q: "A 'bite-sized' action step in the Growth Engine is best described as:", options: ["An action that requires significant effort and produces major change quickly", "A small, specific change that is masterable in 1 to 2 weeks", "An action that the coach believes will have the highest impact", "A multi-step improvement plan developed jointly by coach and teacher"], correct: 1 },
  { q: "'Closing the Loop' in the Growth Engine means:", options: ["Completing all the paperwork for the coaching cycle", "Returning in 2 weeks to observe evidence of the agreed action step", "Ending the coaching relationship once the teacher has improved", "Writing a final report summarizing the coaching cycle outcomes"], correct: 1 },
  { q: "Who should ideally choose the final action step in the SUPPORT phase?", options: ["The coach, based on what the evidence shows is most needed", "The teacher, based on their own interpretation of the data", "The head teacher, based on school improvement priorities", "Both coach and teacher together, with equal input into the decision"], correct: 1 },
  { q: "In the Growth Engine, evidence serves as:", options: ["Proof of teacher failure that justifies coaching intervention", "The foundation for co-creating the next action step", "Documentation to share with school management after each cycle", "A benchmark to compare teachers' performance against each other"], correct: 1 },
  { q: "The IMPROVE phase of the Growth Engine focuses on:", options: ["The coach improving their observation and feedback skills", "Iterating and adjusting the action step based on new evidence from the classroom", "Improving the teacher's attitude and motivation toward change", "Improving test scores through targeted exam preparation strategies"], correct: 1 },
];

const quizU14 = [
  { q: "What are the 4 pillars of the ethical coaching framework in Unit 1.4?", options: ["Observation, Feedback, Action, Reflection", "Trust, Confidentiality, Accountability, Integrity", "Equality, Choice, Voice, Dialogue", "Planning, Observing, Analysing, Supporting"], correct: 1 },
  { q: "If confidentiality is broken in a coaching relationship, what typically happens?", options: ["The teacher becomes more open because the pressure is released", "The coaching relationship 'dies' and teachers close off from honest dialogue", "The head teacher can use the information to support the teacher's growth", "The coach becomes more trusted because they were transparent"], correct: 1 },
  { q: "'Implicit' trust in coaching is built through:", options: ["Signing a formal agreement at the start of the coaching relationship", "Consistent, predictable actions that align with the partnership principles over time", "Sharing positive feedback that builds the teacher's confidence", "Explaining the coaching model in full detail at the first meeting"], correct: 1 },
  { q: "What does 'Accountability' mean in partnership coaching?", options: ["The coach being accountable to the principal for teacher improvement", "Both coach and teacher being accountable to their agreed growth goals", "Teachers being accountable to complete all assigned coaching tasks", "The coach being accountable to report accurate data to school management"], correct: 1 },
  { q: "When a principal asks for individual coaching notes, the coach should:", options: ["Share a summary while removing the teacher's name for anonymity", "Hold the confidentiality boundary and offer school-wide aggregate trends instead", "Ask the teacher for permission before sharing anything with the principal", "Share the notes only if the principal has a legitimate improvement goal"], correct: 1 },
  { q: "Integrity in partnership coaching means:", options: ["Being honest with teachers even when the feedback is difficult to hear", "Consistently following through on partnership principles even under institutional pressure", "Maintaining accurate and complete records of all coaching interactions", "Ensuring all coaching activities align with the school's strategic improvement plan"], correct: 1 },
];

const quizU15 = [
  { q: "The 'Human Filter' concept in Unit 1.5 means:", options: ["Filtering out negative AI suggestions before sharing them with teachers", "The coach must validate and contextualise AI suggestions before using them", "Using human observation data instead of AI data wherever possible", "Filtering AI reports through school management before coaches access them"], correct: 1 },
  { q: "What are the 3 questions in the AI Validation Framework?", options: ["Accuracy? Reliability? Evidence?", "Context? Bias? Partnership?", "Data? Pattern? Trend?", "Observation? Analysis? Action?"], correct: 1 },
  { q: "'Cultural Blindness' in AI tools leads to:", options: ["AI tools that cannot be translated into local languages like Urdu", "Suggestions that do not fit the local classroom context or cultural values", "AI systems that ignore the cultural background of individual students", "Coaching tools that work better in urban settings than rural ones"], correct: 1 },
  { q: "AI provides 'Data Patterns' — what does the human coach provide?", options: ["Technology expertise to interpret the AI's algorithms correctly", "Context and meaning based on direct classroom observation", "Emotional support for teachers who find AI feedback threatening", "Independent verification that the AI's data collection was accurate"], correct: 1 },
  { q: "Why should the coach check AI output for 'Deficit Framing'?", options: ["Because deficit framing leads to overly positive feedback that masks real problems", "Because AI often focuses only on what is wrong rather than identifying growth opportunities", "Because deficit framing makes the AI more likely to produce inaccurate results", "Because teachers prefer positive framing and will disengage from negative AI feedback"], correct: 1 },
  { q: "If AI labels a teacher's behaviour as 'unprofessional', the coach should:", options: ["Share it with the teacher exactly as the AI stated and ask for an explanation", "Override the AI label and seek to understand the human context behind the data", "Report the AI finding to the head teacher since professionalism is a serious concern", "Ask the teacher to respond in writing to the AI's assessment"], correct: 1 },
];

const quizU16 = [
  { q: "'I Do' in the observation schema refers to:", options: ["Students working independently to demonstrate mastery", "Teacher modeling and direct instruction for students to observe", "Guided practice where both teacher and students participate together", "Check for Understanding activities to assess student learning"], correct: 1 },
  { q: "'We Do' in the observation schema is also known as:", options: ["Independent Practice", "Guided Practice", "Direct Instruction", "Formative Assessment"], correct: 1 },
  { q: "What is the primary purpose of 'CFU' (Check for Understanding)?", options: ["To give students a grade at the end of each lesson activity", "To gather real-time data that allows the teacher to decide whether to pivot or proceed", "To provide evidence for coaching reports shared with school management", "To measure how much time was spent on independent practice in the lesson"], correct: 1 },
  { q: "'You Do' is the phase where:", options: ["The teacher demonstrates the skill or concept to the class", "Students practice independently to demonstrate mastery without teacher support", "Both teacher and students collaborate on a shared task", "The teacher checks whether students understood the previous explanation"], correct: 1 },
  { q: "The observation schema is best described as a tool for:", options: ["Measuring teacher quality and performance objectively", "Describing lesson structure to spark reflective dialogue", "Prescribing the correct ratio of teaching phases for each lesson", "Comparing lesson structure across teachers for management reports"], correct: 1 },
  { q: "A 'Pivot' in a lesson occurs when:", options: ["The teacher moves from I Do to We Do at the planned time", "The teacher changes instruction based on student feedback from a CFU", "A student asks an unexpected question that changes the lesson direction", "The coach suggests a change in lesson structure during post-observation dialogue"], correct: 1 },
];

// ─── Seeder ──────────────────────────────────────────────────────────────────────

async function seed() {
  console.log("🌱 Starting Module 1 seed...\n");

  // 1. Upsert Module 1
  const { data: mod, error: modErr } = await supabase
    .from("modules")
    .upsert({
      title: "Module 1: Universal Core Refresher",
      description: "Mandatory foundation for all coaches. Aligns with the Taleemabad Coaching OS and redefines coaching as a catalyst for teacher growth.",
      is_mandatory: true,
      order_number: 1,
      competencies: "Strategic Vision, Developmental Stance, Evidence-Based Observation, Ethical Professionalism, Context-Aware Data Validation, Universal Instructional Language",
      desired_outcomes: "Distinguish coaching from inspection, apply Impact Cycle, use Partnership Principles, maintain confidentiality, apply Human Filter to AI data, code classroom observations",
    }, { onConflict: "title" })
    .select()
    .single();

  if (modErr) { console.error("Module error:", modErr); process.exit(1); }
  console.log(`✅ Module: ${mod.title} (${mod.id})`);

  const units = [
    { order: 1, title: "Unit 1.0: The Coaching Catalyst", description: "Understanding coaching as a partnership-driven growth engine that honors teacher agency", concepts: "Coaching vs inspection, Impact Cycle, 7 Partnership Principles, confidentiality, identity shift", slides: slidesU10, scenario: scenarioU10, quiz: quizU10 },
    { order: 2, title: "Unit 1.1: The Partnership Posture", description: "Shifting from a judging stance to equality-based, side-by-side partnership", concepts: "Judge vs Co-Pilot, 3 competency pillars, 4-step flow, partnership language toolkit", slides: slidesU11, scenario: scenarioU11, quiz: quizU11 },
    { order: 3, title: "Unit 1.2: The Shared Mirror", description: "Presenting classroom data as a neutral starting point for collaborative discovery", concepts: "Shared Mirror protocol, low-inference vs high-inference, audit culture, 4-step Shared Mirror process", slides: slidesU12, scenario: scenarioU12, quiz: quizU12 },
    { order: 4, title: "Unit 1.3: The Growth Engine", description: "Operationalizing the Impact Cycle through a 4-step evidence-based partnership process", concepts: "4-step coaching cycle, evidence vs interpretation, co-analysis, bite-sized action plans", slides: slidesU13, scenario: scenarioU13, quiz: quizU13 },
    { order: 5, title: "Unit 1.4: The Trust Bridge", description: "Building ethical partnership coaching through confidentiality and trust-building practices", concepts: "4-pillar ethical framework, 5 confidentiality breach types, trust-building behaviors, principal pressure", slides: slidesU14, scenario: scenarioU14, quiz: quizU14 },
    { order: 6, title: "Unit 1.5: The Human Filter", description: "Using AI as a partnership tool, not a replacement for human professional judgment", concepts: "AI opportunity vs risk, 3-question validation framework, Pakistan-specific overrides, AI limitations", slides: slidesU15, scenario: scenarioU15, quiz: quizU15 },
    { order: 7, title: "Unit 1.6: Coding the Classroom", description: "Mastering the I Do/We Do/You Do/CFU schema as a partnership coaching tool", concepts: "Observation schema, schema + Impact Cycle, sharing schema data, audit culture risk", slides: slidesU16, scenario: scenarioU16, quiz: quizU16 },
  ];

  for (const unit of units) {
    // Insert training unit
    const { data: training, error: tErr } = await supabase
      .from("trainings")
      .upsert({
        title: unit.title,
        description: unit.description,
        main_concepts: unit.concepts,
        is_common: true,
        module_id: mod.id,
        order_number: unit.order,
      }, { onConflict: "title" })
      .select()
      .single();

    if (tErr) { console.error(`Training error (${unit.title}):`, tErr); continue; }
    console.log(`  ✅ Unit: ${training.title} (${training.id})`);

    // Delete old content for this training
    await supabase.from("training_content").delete().eq("training_id", training.id);

    // Insert slides content
    const { error: slidesErr } = await supabase.from("training_content").insert({
      training_id: training.id,
      format_type: "slides",
      content_url: JSON.stringify(unit.slides),
    });
    if (slidesErr) console.error(`    Slides error:`, slidesErr);
    else console.log(`    📊 Slides: ${unit.slides.length} slides`);

    // Insert scenario content
    const { error: scErr } = await supabase.from("training_content").insert({
      training_id: training.id,
      format_type: "scenario",
      content_url: JSON.stringify(unit.scenario),
    });
    if (scErr) console.error(`    Scenario error:`, scErr);
    else console.log(`    🎭 Scenario: ${unit.scenario.steps.length} situations`);

    // Insert quiz questions
    // First find or create an assessment for this training
    const { data: assessment, error: aErr } = await supabase
      .from("assessments")
      .upsert({
        title: `${unit.title} — Quiz`,
        type: "module_quiz",
        training_id: training.id,
      }, { onConflict: "training_id" })
      .select()
      .single();

    if (aErr) { console.error(`    Assessment error:`, aErr); continue; }

    // Delete old questions
    const { data: oldQs } = await supabase.from("questions").select("id").eq("assessment_id", assessment.id);
    if (oldQs?.length) {
      const ids = oldQs.map((q) => q.id);
      await supabase.from("options").delete().in("question_id", ids);
      await supabase.from("questions").delete().eq("assessment_id", assessment.id);
    }

    // Insert new questions
    for (let i = 0; i < unit.quiz.length; i++) {
      const q = unit.quiz[i];
      const { data: question, error: qErr } = await supabase
        .from("questions")
        .insert({
          assessment_id: assessment.id,
          question_text: q.q,
          question_type: "mcq",
          order_number: i + 1,
          max_score: 1,
        })
        .select()
        .single();

      if (qErr) { console.error(`    Question error:`, qErr); continue; }

      const optionRows = q.options.map((opt, idx) => ({
        question_id: question.id,
        option_text: opt,
        is_correct: idx === q.correct,
      }));

      const { error: optErr } = await supabase.from("options").insert(optionRows);
      if (optErr) console.error(`    Options error:`, optErr);
    }

    console.log(`    ❓ Quiz: ${unit.quiz.length} questions`);
  }

  console.log("\n✅ Module 1 seed complete!");
}

seed().catch(console.error);
