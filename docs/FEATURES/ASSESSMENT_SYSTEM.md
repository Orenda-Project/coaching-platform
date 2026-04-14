# Assessment System

## Overview

The coaching platform has three types of assessments, each serving a distinct purpose in the user's learning journey:

1. **Baseline Assessment** — Initial diagnostic evaluation
2. **Module Quiz** — Per-module checkpoint assessments
3. **Endline Assessment** — Final certification evaluation

---

## Baseline Assessment

**Route:** `/assessment/baseline`

### Purpose
Measures user's initial coaching competency level and identifies areas for growth.

### Structure
- **Questions:** 30 Likert-scale questions (Disagree/Agree on coaching competencies)
- **Question type:** MCQ (multiple choice)
- **Duration:** ~10 minutes
- **Pass threshold:** 60%
- **Grading:** MCQ questions only

### Persona Assignment

On passing (≥60%), the system assigns a persona based on the score:

| Score | Persona | Interpretation |
|-------|---------|-----------------|
| 75%+ | A | Advanced coach, exceeds expectations |
| 70-74% | B | Proficient coach, meets expectations |
| 65-69% | C | Developing coach, approaching expectations |
| 60-64% | D | Beginning coach, meets minimum threshold |
| <60% | Fail | Does not pass; must retake |

### Weak Module Detection

After baseline completion, the system identifies **weak modules** by analyzing performance on module-specific question bands:

```
Module 2: Questions 1-6
Module 3: Questions 7-12
Module 4: Questions 13-18
Module 5: Questions 19-24
Module 6: Questions 25-30
```

If a module band scores **<70%**, that module is flagged as "weak" and added to `profiles.weak_modules`.

### On Failure (<60%)

User is shown an error message with their score and required threshold. They can retry immediately with the same question set and answers cleared.

### User Updates on Success

```sql
UPDATE profiles SET
  persona = 'A|B|C|D',
  baseline_score = 65,
  baseline_completed = true,
  baseline_attempt_count = baseline_attempt_count + 1,
  weak_modules = ['Module 2', 'Module 3']
WHERE id = user_id;
```

---

## Module Quiz

**Route:** `/training/:trainingId` (quiz phase after content completion)

### Purpose
Validates understanding of each training module before allowing progression to the next module.

### Structure
- **Questions:** 5 per module
- **Question type:** MCQ
- **Duration:** ~5-10 minutes
- **Pass threshold:** 80%
- **Max attempts:** 3 per module
- **Prerequisite:** Content must be 90% watched OR slides viewed for 30+ seconds

### Question Organization

Questions are ordered by `order_number` in the questions table and filtered by `assessment_id` (training-specific assessment).

### On Failure (<80%)

- Attempt count incremented
- User shown error with score and threshold
- User can retry by clicking "Retry Quiz"
- After 3 failed attempts, module is marked as incomplete and user must wait/contact admin

### On Success (≥80%)

```sql
INSERT INTO training_progress (user_id, training_id, score, passed, attempt_count, ...)
VALUES (user_id, training_id, 82, true, 1, ...)
ON CONFLICT (user_id, training_id) DO UPDATE SET
  score = 82,
  passed = true,
  attempt_count = training_progress.attempt_count + 1,
  completed_at = now();
```

User is returned to dashboard and next module (if exists) becomes unlocked.

---

## Endline Assessment

**Route:** `/assessment/endline`

### Purpose
Final comprehensive evaluation showing learning progress and certifying coaching competency achievement.

### Structure
- **Questions:** 20 total
  - **16 MCQ questions:** 4 per module, counts toward score
  - **4 open-ended questions:** 1 per module, ungraded but saved for review
- **Duration:** ~15 minutes
- **Pass threshold:** 70% (MCQ only)
- **Grading:** MCQ questions only (16/16)

### Question Distribution

```
Questions 1-4:   Module 2 MCQ (4 questions)
Questions 5-8:   Module 3 MCQ (4 questions)
Questions 9-12:  Module 4 MCQ (4 questions)
Questions 13-16: Module 5 MCQ (4 questions)
Question 17:     Module 2 Open-Ended (ungraded)
Question 18:     Module 3 Open-Ended (ungraded)
Question 19:     Module 4 Open-Ended (ungraded)
Question 20:     Module 5 Open-Ended (ungraded)
```

### Question Types

**MCQ (Questions 1-16):**
- 4 answer options (A, B, C, D)
- Radio button selection in UI
- Only one correct answer per question
- Counts toward 70% pass threshold

**Open-Ended (Questions 17-20):**
- Textarea input (no structured options)
- Free-form text response
- Does NOT count toward pass threshold
- Saved to localStorage and submitted for admin review
- Ungraded but visible in user's assessment response history

### Prerequisites

User can only take endline if:
- Baseline is completed (`profiles.baseline_completed = true`)
- ALL assigned modules are passed

Assigned modules = `is_mandatory` modules + weak modules from baseline

If prerequisites not met, user sees:
```
⚠️ Complete All Modules First

You must pass all assigned training modules
before attempting the endline assessment.

Return to your dashboard to complete any remaining modules.
```

### On Failure (<70% on MCQ)

- Attempt count incremented
- Open-ended responses saved (but not submitted)
- User shown error with MCQ score only: `You scored 62% on the 16 multiple choice questions. You need at least 70% to earn your certificate. Please try again.`
- User can retry immediately; localStorage cleared

### On Success (≥70% on MCQ)

1. Certificate is created (upsert on conflict):
```sql
INSERT INTO certificates (user_id, certificate_id, persona, issued_at)
VALUES (user_id, 'CC-1234567890-ABCD', 'B', now())
ON CONFLICT (user_id) DO UPDATE SET
  certificate_id = EXCLUDED.certificate_id,
  issued_at = EXCLUDED.issued_at;
```

2. Profile is updated:
```sql
UPDATE profiles SET
  endline_score = 75,
  endline_completed = true,
  endline_attempt_count = endline_attempt_count + 1
WHERE id = user_id;
```

3. Success toast: `Congratulations! You scored 75% on the 16 multiple choice questions and earned your certificate!`

4. User navigated to `/certificate` to view/download certificate

5. Open-ended responses are submitted with the overall response (saved in answers JSON or separate table for admin review)

---

## Scoring & Grading

### Baseline & Endline

- **Calculation:** `(correct_mcq_count / total_mcq_count) * 100`
- **Correct answer:** Determined by `options.is_correct = true`
- **Unanswered questions:** Count as incorrect

### Module Quiz

- **Calculation:** `(correct_count / 5) * 100`
- **Pass = 80%, Fail = <80%`

### Open-Ended Questions

- **No automated scoring**
- **Responses saved to localStorage** during assessment
- **Submitted with assessment** but not graded automatically
- **Stored for manual admin review** (future feature: admin dashboard for review)

---

## Auto-Resume

Both baseline and endline support auto-resume via localStorage:

```javascript
const saved = localStorage.getItem(`assessment_${type}_${user.id}`);
if (saved) {
  const { answers, currentIndex } = JSON.parse(saved);
  setAnswers(answers);
  setCurrentIndex(currentIndex);
  toast.success("Resuming where you left off...");
}
```

Progress is auto-saved every 5 seconds while assessment is in progress.

When assessment is submitted, localStorage is cleared:
```javascript
localStorage.removeItem(`assessment_${type}_${user.id}`);
```

---

## Data Model

### assessments table
```
id UUID PRIMARY KEY
type TEXT ('baseline'|'endline'|'training'|'module_quiz')
title TEXT
training_id UUID FK (null for baseline/endline)
created_at TIMESTAMPTZ
```

### questions table
```
id UUID PRIMARY KEY
assessment_id UUID FK
question_type TEXT ('mcq'|'open')
question_text TEXT
correct_answer TEXT (for open-ended only)
order_number INT
module_id UUID FK (optional, for endline organization)
created_at TIMESTAMPTZ
```

### options table
```
id UUID PRIMARY KEY
question_id UUID FK
option_letter CHAR(1) ('A'|'B'|'C'|'D')
option_text TEXT
is_correct BOOLEAN
rationale TEXT
principle_tag TEXT
created_at TIMESTAMPTZ
```

### profiles table
```
...existing columns...
baseline_completed BOOLEAN
baseline_score INT
baseline_attempt_count INT
endline_completed BOOLEAN
endline_score INT
endline_attempt_count INT
weak_modules TEXT[] (array of module titles)
```

### training_progress table
```
...existing columns...
score FLOAT
passed BOOLEAN
attempt_count INT
completed_at TIMESTAMPTZ
```

### certificates table
```
id UUID PRIMARY KEY
user_id UUID FK UNIQUE
certificate_id TEXT (CC-{timestamp}-{RAND4})
persona TEXT ('A'|'B'|'C'|'D')
issued_at TIMESTAMPTZ
```

---

## Anti-Cheat & Monitoring

### Tab Switch Detection (Module Quiz)

In TrainingModule.tsx, visibilitychange events are monitored:

```javascript
const handleVisibilityChange = () => {
  if (document.hidden) {
    setTabSwitchCount((prev) => prev + 1);
    // Insert tab-switch event for analytics
  }
};
```

- Displays warning: `⚠️ X tab switch(es) detected`
- Stores in `training_progress.tab_switch_count`
- 3+ tab switches → flags for admin review

### Future Enhancement

Implement similar detection for endline assessment to ensure integrity of final evaluation.

---

## Related Features

- **Persona System:** Baseline assigns personas (A/B/C/D) that determine module visibility
- **Module Locking:** Modules unlock sequentially; endline only available after ALL modules passed
- **Weak Modules:** Identified by baseline; users must complete weak modules before endline
- **Certificates:** Issued on endline pass; ID format: `CC-{timestamp}-{RAND4}`
- **Analytics:** Assessment events tracked for reporting and insights

---

## Troubleshooting

**Issue:** User sees "Assessment not found"
- **Cause:** Assessment record doesn't exist in database
- **Fix:** Run migration `20260415_baseline_assessment_data.sql` or `20260430000001_endline_assessment_20_questions.sql`

**Issue:** Questions not loading
- **Cause:** Assessment exists but questions are not seeded
- **Fix:** Verify questions table has records matching assessment_id

**Issue:** Resume doesn't work
- **Cause:** localStorage is cleared or disabled
- **Fix:** Check browser settings; localStorage may be in private mode

**Issue:** Endline blocked but user completed all modules
- **Cause:** Module completion not recorded in training_progress
- **Fix:** Verify training_progress.passed = true for all assigned trainings

---

**Last Updated:** 2026-04-14
