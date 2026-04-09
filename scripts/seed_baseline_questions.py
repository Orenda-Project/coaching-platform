"""
Seed baseline assessment questions into Supabase.
Run: python scripts/seed_baseline_questions.py
Requires: pip install requests python-dotenv
"""

import os
import requests
import json
from dotenv import load_dotenv

load_dotenv(dotenv_path=".env.local")
load_dotenv(dotenv_path=".env")

SUPABASE_URL = os.environ["VITE_SUPABASE_URL"]
SUPABASE_KEY = os.environ["VITE_SUPABASE_PUBLISHABLE_KEY"]

# Need service_role key for inserts bypassing RLS.
# Override with SUPABASE_SERVICE_KEY env var if available.
SERVICE_KEY = os.environ.get("SUPABASE_SERVICE_KEY", SUPABASE_KEY)

HEADERS = {
    "apikey": SERVICE_KEY,
    "Authorization": f"Bearer {SERVICE_KEY}",
    "Content-Type": "application/json",
    "Prefer": "return=representation",
}

BASE = f"{SUPABASE_URL}/rest/v1"


def post(endpoint, data):
    r = requests.post(f"{BASE}/{endpoint}", headers=HEADERS, json=data)
    if not r.ok:
        raise Exception(f"POST {endpoint} failed: {r.status_code} {r.text}")
    return r.json()


# ---------------------------------------------------------------------------
# Question bank
# Format: (question_text, [optionA, optionB, optionC, optionD], correct_letter, order)
# ---------------------------------------------------------------------------

MODULES = [
    {
        "module": "Module 2: The Partnership Foundation (Trust & Status)",
        "questions": [
            # Concept-Based
            (
                "According to the SCARF model, a veteran teacher saying they don't need a coach is a direct threat to:",
                ["Certainty", "Status", "Autonomy", "Relatedness"],
                "B", 1,
            ),
            (
                "When a teacher displays 'Flight' behavior (minimal responses), it likely indicates the coach has:",
                [
                    "Failed to provide enough expert advice.",
                    "Triggered a Status Threat by using evaluative language rather than low-inference data.",
                    "Spent too much time listening.",
                    "Not followed the NEO-1 checklist strictly enough.",
                ],
                "B", 2,
            ),
            (
                "A Principal demands the individual engagement scores of all teachers to decide on 'Show Cause' notices. According to the Universal SOP, you should:",
                [
                    "Share the scores but ask the Principal to keep them confidential.",
                    "Provide a list of only the 'top-performing' teachers.",
                    "Refuse and offer a 'System-Trends' report to protect individual trust.",
                    "Tell the Principal you will ask the teachers for permission first.",
                ],
                "C", 3,
            ),
            # Situation-Based
            (
                "Case Study: A veteran teacher reacts with 'Freeze' behavior (passive compliance). Which Opening Script best uses Equality and Voice to establish a partnership?",
                [
                    "I'm here to help you improve your classroom management with some tips.",
                    "I'm here as a partner to learn alongside you; what is a specific goal you have for your students today that we can look at together?",
                    "The District Office requires me to audit this lesson for performance tracking.",
                    "I will be watching to see if you are following the standard manual correctly.",
                ],
                "B", 4,
            ),
            (
                "Case Study: During a feedback session, a teacher is defensive. To move to a Side-by-Side mindset, you should:",
                [
                    "Re-read the rubric to show them exactly where they failed.",
                    "Physically sit next to them and look at student work together, asking 'What do you see here?'",
                    "Remind them that your role is to give expert advice they must follow.",
                    "Suggest they observe a younger teacher who is more compliant.",
                ],
                "B", 5,
            ),
            (
                "Case Study: You notice a teacher is struggling with a noisy class. Instead of giving a 'fix,' you use Deep Empathy by saying:",
                [
                    "You should use a whistle to get their attention.",
                    "It sounds frustrating when you've planned a lesson and the back row isn't engaging. What have you noticed about when they do pay attention?",
                    "In my day, I handled 80 students by doing X.",
                    "I will mark this as a practice visit so it doesn't hurt your record.",
                ],
                "B", 6,
            ),
        ],
    },
    {
        "module": "Module 3: The Mirror Specialist (Shared Reality)",
        "questions": [
            (
                "What is the primary purpose of capturing 'Data at the Edge' (e.g., back-row notebooks)?",
                [
                    "To catch the teacher ignoring students.",
                    "To find the truth of student learning that is often hidden by teacher activity at the 'Center.'",
                    "To provide evidence for a 'Show Cause' notice.",
                    "To satisfy digital app requirements.",
                ],
                "B", 7,
            ),
            (
                "If a coach and teacher score the same lesson differently, this 'Calibration Gap' is usually caused by:",
                [
                    "One person being a 'mean' grader.",
                    "Using subjective 'feelings' instead of a shared mirror of objective facts.",
                    "The rubric being too complex to understand.",
                    "The teacher acting differently toward each of you.",
                ],
                "B", 8,
            ),
            (
                "The Human Filter rule states that a coach should NOT capture an artifact if:",
                [
                    "The lighting in the room is poor.",
                    "A student is visibly distressed or the teacher is in an acute emotional crisis.",
                    "The coach forgot their tablet.",
                    "The teacher is using a non-standard strategy.",
                ],
                "B", 9,
            ),
            (
                "Case Study: Which observation note successfully passes the 'Camera Test' by removing high-inference judgment?",
                [
                    "The teacher was too lazy to check homework.",
                    "At 11:15 AM, 12 of 68 students were writing in notebooks; 56 students sat with blank pages.",
                    "The teacher gave a very clear explanation of the topic.",
                    "The classroom was noisy because the teacher lost control.",
                ],
                "B", 10,
            ),
            (
                "Case Study: A teacher insists a class was 'perfect,' but data shows 0% passed the exit ticket. To achieve Calibration, you should:",
                [
                    "Argue until they admit they were wrong.",
                    "Introduce the 'Third Partner' by looking at 5 randomly selected student notebooks together.",
                    "Agree with them to maintain the relationship and try again next week.",
                    "Inform the Principal the teacher is in denial.",
                ],
                "C", 11,
            ),
            (
                "Case Study: When taking a digital photo of student work, the Voice principle requires you to:",
                [
                    "Take it silently to avoid distracting the class.",
                    "Use a permission script that names a specific learning curiosity (e.g., 'I'm curious how they solved this').",
                    "Only take photos of top-performing students.",
                    "Send the photo to the Principal immediately for validation.",
                ],
                "B", 12,
            ),
        ],
    },
    {
        "module": "Module 4: Digital & Data Intelligence (Collaborative Analytics)",
        "questions": [
            (
                "Coach Usman had 6 visits. 1 holiday, 1 absent teacher (excluded), 1 visit with no artifact, and 1 interrupted by a Principal. What is his WRER?",
                [
                    "66%",
                    "50% (Missing artifact and interruption count as 0% for those visits).",
                    "75%",
                    "40%",
                ],
                "B", 13,
            ),
            (
                "What does a 'High Fidelity' but 'Low Impact' score on a Regional Heatmap suggest?",
                [
                    "Teachers are following steps (Compliance) but without deep pedagogical dialogue (Praxis).",
                    "The app is not being used enough.",
                    "Students are not participating.",
                    "The coach is not visiting enough.",
                ],
                "A", 14,
            ),
            (
                "To avoid the 'Administrative After-Burn,' a coach should:",
                [
                    "Take paper notes and enter them at home.",
                    "Complete 100% of app entries (Evidence and Action Steps) inside the school building.",
                    "Ask the teacher to enter data.",
                    "Only record successful visits.",
                ],
                "B", 15,
            ),
            (
                "Case Study: A Principal displaces your coaching block with 'Protocol Duty.' Which Advocacy Script best protects your time?",
                [
                    "I'm sorry, but I have too much work to do today.",
                    "My WRER is currently at 50%; if I miss this block, Teacher Sara will wait another 7 days for feedback, risking student engagement.",
                    "I will do the duty if you promise to give me extra time tomorrow.",
                    "The District Office says I am not allowed to do protocol duty.",
                ],
                "B", 16,
            ),
            (
                "Case Study: An AI dashboard suggests 'Use digital tools,' but there is no electricity. Following Human Override, you:",
                [
                    "Tell the teacher to follow the AI suggestion anyway.",
                    "Co-design a low-tech alternative (e.g., 'Turn-and-Talk') that achieves the same intent.",
                    "Mark the visit as 'Not Applicable.'",
                    "Report the lack of resources and skip the coaching step.",
                ],
                "B", 17,
            ),
            (
                "Case Study: A dashboard shows 100% task completion, but you observe students just copying from the board. You should:",
                [
                    "Ignore the observation and celebrate the 100% score.",
                    "Use the 'Shared Mirror' to ask: 'Data shows 100% completion, but looking at these notebooks, what do we notice about actual reasoning?'",
                    "Change the dashboard score manually to 0%.",
                    "Report the teacher for 'Robotic Teaching.'",
                ],
                "B", 18,
            ),
        ],
    },
    {
        "module": "Module 5: The Instructional Catalyst (Co-Design)",
        "questions": [
            (
                "A teacher explains a strategy perfectly but fails to use it in a noisy classroom. This is a:",
                [
                    "Planning Loop failure",
                    "Observation Loop failure",
                    "Training Loop failure (Needs rehearsal to build muscle memory).",
                    "Mindset failure",
                ],
                "C", 19,
            ),
            (
                "In Side-by-Side Co-Modeling, the coach's goal is to:",
                [
                    "Show the teacher they are the expert.",
                    "Act as a 'Co-Pilot' by 'sliding in' for 2 minutes to model a specific micro-skill.",
                    "Finish the lesson for the teacher.",
                    "Evaluate students.",
                ],
                "B", 20,
            ),
            (
                "If a goal is not met after two visits, the Improve Phase requires one of 4 Paths. Which is NOT a path?",
                [
                    "Modify the strategy",
                    "Switch to a new strategy",
                    "Stay the course",
                    "Report failure to administration",
                ],
                "D", 21,
            ),
            (
                "Case Study: A teacher has students copy an entire textbook chapter. You identify the Belief Gap (Internal Rule) as:",
                [
                    "The teacher doesn't know the subject matter.",
                    "The 'Silence Myth': The teacher believes a quiet class copying text is a learning class.",
                    "The teacher is lazy and doesn't want to teach.",
                    "The students are too slow to do any other activity.",
                ],
                "B", 22,
            ),
            (
                "Case Study: A teacher spends 20 minutes on a 5-minute intro. You diagnose this as a Planning Loop failure and:",
                [
                    "Tell them to be faster next time.",
                    "Co-design a script with specific time-stamps for each lesson segment.",
                    "Model the entire lesson for them.",
                    "Mark them as 'Not Proficient' in time management.",
                ],
                "B", 23,
            ),
            (
                "Case Study: When a teacher has 8 skill gaps, a 'Catalyst' coach prioritizes:",
                [
                    "The easiest gap to fix.",
                    "The 'High-Leverage' change that the teacher agrees will impact students most.",
                    "The gap the Principal is most concerned about.",
                    "All 8 gaps simultaneously to ensure rapid growth.",
                ],
                "B", 24,
            ),
        ],
    },
    {
        "module": "Module 6: The Excellence Loop (Reciprocity & Praxis)",
        "questions": [
            (
                "'Responsive Contextualization' is necessary when:",
                [
                    "The teacher is unwilling to follow the manual.",
                    "A strategy is impossible due to local constraints (60 students, bolted desks).",
                    "The coach wants to try a new experiment.",
                    "The Principal demands a change.",
                ],
                "B", 25,
            ),
            (
                "The 'Compliance Trap' occurs when:",
                [
                    "WRER is 0% but growth is high.",
                    "WRER is 100% (visits happening) but Growth Rate is 0% (no behavior change).",
                    "Teacher refuses to sign notes.",
                    "Principal takes over coaching.",
                ],
                "B", 26,
            ),
            (
                "'Closing the Loop' is only achieved when:",
                [
                    "The report is filed.",
                    "The coach gives a compliment.",
                    "Coach and teacher verify together (Reciprocity) that the new skill is a mastered habit.",
                    "Training is completed.",
                ],
                "C", 27,
            ),
            (
                "Case Study: A veteran teacher is skeptical of a new strategy. The most Reciprocal move is to:",
                [
                    "Remind them this is the new 'Gold Standard.'",
                    "Acknowledge their expertise and ask which part of the strategy will work for their community.",
                    "Suggest they observe a younger teacher.",
                    "Perform modeling without asking permission.",
                ],
                "B", 28,
            ),
            (
                "Case Study: You model a strategy and it fails (chaotic classroom). To maintain Shared Reality, you:",
                [
                    "Blame previous student behavior.",
                    "Use the 'Shared Mirror' to admit failure and ask: 'What did you notice that I missed?'",
                    "Pretend it went well to maintain your 'Expert' status.",
                    "Delete the failure recording from the app.",
                ],
                "B", 29,
            ),
            (
                "Case Study: Why is Praxis (action-based learning) prioritized over 'Abstract Theory'?",
                [
                    "Theory is too difficult to read.",
                    "It allows the 'Human Filter' to adapt the intent of a strategy to fit local high-constraint reality.",
                    "It is easier for the coach to grade.",
                    "The manual is only a suggestion and not important.",
                ],
                "B", 30,
            ),
        ],
    },
]

OPTION_LABELS = ["A", "B", "C", "D"]


def seed():
    print("Creating baseline assessment...")
    assessment = post("assessments", {
        "type": "baseline",
        "title": "Baseline Assessment — Coaching Competencies",
    })
    assessment_id = assessment[0]["id"]
    print(f"  Assessment ID: {assessment_id}")

    total_questions = 0
    for mod in MODULES:
        print(f"\n  Module: {mod['module']}")
        for (q_text, options, correct_letter, order) in mod["questions"]:
            correct_index = OPTION_LABELS.index(correct_letter)

            q = post("questions", {
                "assessment_id": assessment_id,
                "question_type": "mcq",
                "question_text": q_text,
                "correct_answer": options[correct_index],
                "max_score": 1,
                "order_number": order,
            })
            q_id = q[0]["id"]

            for i, opt_text in enumerate(options):
                post("options", {
                    "question_id": q_id,
                    "option_text": opt_text,
                    "is_correct": (i == correct_index),
                })

            total_questions += 1
            print(f"    Q{order} inserted (correct: {correct_letter})")

    print(f"\nDone. {total_questions} questions inserted for assessment {assessment_id}")


if __name__ == "__main__":
    seed()
