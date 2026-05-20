# Baseline Assessment - Intent Definition

## Feature Description
The Baseline Assessment is the first major step in the coaching certification journey. It evaluates a user's current coaching knowledge and skills to assign them a coaching persona (A, B, C, D, or E) and identify areas for personalized growth.

## Actors and Preconditions
**Primary Actor:** Newly registered user who has completed onboarding

**Preconditions:**
- User must be logged in
- User must have completed the onboarding flow
- User must NOT have already completed the baseline assessment
- Questions must exist in the database for the baseline assessment

## Key Behaviors

### Assessment Flow
- Display an intro screen with assessment metadata before starting
- Allow user to start the assessment from the intro screen
- Present all questions sequentially with MCQ options (typically 18 questions, but dynamically loaded)
- Allow forward/backward navigation between questions
- Auto-save progress to localStorage every 5 seconds
- Allow resumption from saved progress if user navigates away

### Answer Collection
- Display one question at a time with 4 multiple-choice options (A, B, C, D)
- Save answers in client-side state as user progresses
- Show progress bar and "X of N answered" counter
- Allow user to change answers before submission
- Next button jumps to first unanswered question (not just sequential)
- Previous button navigates backward (disabled on question 1)
- Submit button only appears when all questions are answered

### Anti-Cheat / Integrity
- Track tab switches using browser visibility API
- Show warnings at 1st and 2nd tab switch
- Flag user for admin review when tab switches ≥ 3
- Store tab_switch_count and flagged_for_review in training_progress

### Persona Assignment (Business Rule)
Based on overall score percentage:
- **Persona A:** ≥ 75%
- **Persona B:** ≥ 70% and < 75%
- **Persona C:** ≥ 65% and < 70%
- **Persona D:** ≥ 60% and < 65%
- **Persona E:** < 60%

**No hard pass/fail:** Baseline completes successfully regardless of score.

### Weak Module Identification
- Questions are grouped by order_number into module bands:
  - Module 2: questions 1-6
  - Module 3: questions 7-12
  - Module 4: questions 13-18
  - Module 5: questions 19-24
  - Module 6: questions 25-30
- If a user scores < 70% in a module band, that module is added to `weak_modules`
- Weak modules determine which non-mandatory modules appear for personas A-D
- Persona E sees all modules regardless of weak_modules

### Submission and Persistence
On successful submission:
- Calculate score percentage (correct / total × 100)
- Assign persona based on score
- Identify weak modules based on per-module scores < 70%
- Update `profiles` table:
  - `persona`
  - `baseline_score`
  - `baseline_completed = true`
  - `baseline_attempt_count` (increment)
  - `weak_modules` (array of module titles)
- Create or update `training_progress` record for "Coach Baseline Assessment":
  - `passed = true`
  - `score` (percentage)
  - `tab_switch_count`
  - `flagged_for_review` (true if tab switches ≥ 3)
  - `content_completed = true`
- Clear localStorage progress
- Redirect to dashboard

### Dashboard Integration
- **Before completion:** Dashboard shows "Baseline Assessment Required" CTA with "Attempt Baseline Assessment" button
- **After completion:** Dashboard shows "Your Coaching Profile" card with:
  - Persona badge
  - Score percentage
  - Strengths (persona-specific)
  - Areas for growth (persona-specific)
  - Next steps guidance
- **Stats section:** Shows baseline score as "Baseline: X%"

## Known Constraints

1. **No pass/fail threshold for baseline:** Unlike module quizzes (80%) and endline (70%), the baseline has a 0% pass threshold. It always completes successfully.

2. **Dynamic question count:** The number of questions is not hardcoded to 18. It is loaded from the database and can vary.

3. **Client-side answer storage:** Answers are stored in React state and localStorage during the assessment. They are only sent to the server on final submission.

4. **Single submission only:** Once submitted, the user cannot retake or modify the baseline. Navigating to `/assessment/baseline` after completion redirects to dashboard.

5. **Auto-save interval:** Progress is auto-saved every 5 seconds (not on every answer change).

6. **Training "Coach Baseline Assessment":** The system ensures a `trainings` table record exists for "Coach Baseline Assessment" before creating a `training_progress` entry.

## Out of Scope

- **Real-time answer validation:** The UI does not validate individual answers or show correct/incorrect feedback during the assessment.
- **Time limits:** There is no countdown timer or maximum duration. The "~10 minutes" estimate is informational only.
- **Randomized question order:** Questions are always presented in the same order (by `order_number`).
- **Adaptive questioning:** The assessment does not adjust difficulty or skip questions based on user performance.
- **Detailed error messages per question:** The system does not highlight which specific questions are unanswered. It only disables the Submit button until all are answered.
- **Read-only review mode:** There is no feature to view submitted baseline answers in read-only mode after completion.
- **Multi-language support:** The assessment currently supports a single language.
- **Offline mode:** Although answers are saved to localStorage, the initial question fetch and final submission require network connectivity.
