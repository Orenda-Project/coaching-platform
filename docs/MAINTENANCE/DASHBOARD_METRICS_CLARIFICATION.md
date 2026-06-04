# Dashboard Metrics Clarification

**For:** Data Team  
**Date:** 2026-04-24  
**Reference:** AdminAnalytics.tsx (lines 74-354)

---

## 1. "Tab Sw" Column: What Data It Captures & Flagging Criteria

### What It Shows
- **Total count** of all tab switches detected across ALL modules a coach has attempted
- Example: If a coach switched tabs 2 times in Module 1 and 3 times in Module 2 = **5** in the Tab Sw column
- Source: `training_progress.tab_switch_count` (summed per coach)

### How Tab Switches Are Detected
- **Client-side detection** in quiz/assessment components using `window.addEventListener('visibilitychange')`
- Triggers when tab loses focus or browser loses focus
- Recorded in `training_progress.tab_switch_count` during quiz completion

### What Cases Get Flagged?
- A coach is flagged **if ANY module they attempted has `flagged_for_review = true`**
- Code: `const flagged = tp.some((r) => r.flagged_for_review)` (line 104)
- **Flagging triggers** (current logic):
  - `tab_switch_count >= 3` during a single quiz (flagged_for_review is set server-side)
  - Possible future triggers: fullscreen violations, multiple failed attempts, etc.

### Color Coding in Dashboard
- Tab Sw ≥ 5: **Amber/orange** text (warning, but not auto-flagged)
- Tab Sw 0-4: **Normal** text
- If **ANY row flagged**: entire row background turns **red/pink** and Flag column shows ⚠️

**Note:** A coach can have high tab switches without being flagged—flagging is separate logic that can include multiple factors.

---

## 2. Module Progress Display (Current Issue)

### Current Problem
- Shows `2/3` or `7/7` without context
- **Reader doesn't know:** Is this coach out of the total 7 modules in the platform? Or just their assigned modules?

### Root Cause
- `trainings_started` = count of modules where coach has attempted a quiz (has progress record)
- `trainings_passed` = count of modules where coach passed the quiz (passed = true)
- **NOT measured against:** total modules available to that persona

### Recommended Fix
**Option A: Show total available modules (Best for clarity)**
```
Progress:  2/7  (meaning: 2 passed out of 7 total available for this persona)
```

**Option B: Show started vs passed separately**
```
Modules:  2 passed | 4 started | 7 total
```

**Why it varies now:**
- Persona A coach might see 7 modules (all required)
- Persona B coach might see 5 modules (different curriculum)
- A coach with 0 progress shows nothing

### Data to Implement
Need to:
1. Count **total trainings by persona** (trainings table has `persona` requirement or null for "all")
2. For each coach, fetch their persona's total available modules
3. Display as: `{trainings_passed} / {persona_total_modules}`

---

## 3. Persona System: Definition & Hierarchy

### What "Persona" Means
Persona is a **skill/experience level** assigned to each coach. It determines:
- Which training modules they see
- Assessment difficulty/passing thresholds
- Certification requirements

### The A → B → C → D Scale

| Persona | Label | Meaning | Baseline Pass | Module Pass | Endline Pass |
|---------|-------|---------|--|--|--|
| **A** | Advanced | Experienced educator, strong foundation | ≥ 75% | 80% | 70% |
| **B** | Intermediate | 5-10 years teaching experience | ≥ 70% | 80% | 70% |
| **C** | Developing | 2-5 years teaching experience | ≥ 65% | 80% | 70% |
| **D** | Entry-level | New to teaching (0-2 years) | ≥ 60% | 80% | 70% |

### Is A Better Than D?
**Not "better" — different starting points:**
- **A personas** are expected to know more → need higher baseline score (75%)
- **D personas** are beginners → lower threshold (60%) is fair entry point
- **All personas** must achieve 80% on module quizzes (same standard)
- **All personas** must achieve 70% on endline assessment

### Color Coding (Dashboard)
- A = 🟢 Green
- B = 🔵 Blue
- C = 🟡 Yellow
- D = 🟠 Orange

**Use case:** Helps admin quickly identify which skill level each coach belongs to without reading text.

---

## 4. "Avg Quiz" Metric: Attempt Rate vs Score Percentage

### What It Actually Shows
- **Average quiz SCORE across all module quizzes that coach has attempted**
- NOT the attempt rate

### Calculation
```
Avg Quiz = (sum of all quiz scores) / (count of quizzes with scores)
```

**Example:**
- Module 1 quiz: 85% (passed)
- Module 2 quiz: 92% (passed)
- Module 3 quiz: 0% (failed, retaking, no score yet)

Avg Quiz = (85 + 92) / 2 = **88.5%** → shows as **89%** (rounded)

### What It's NOT
- ❌ NOT "completion rate" (% of assigned modules attempted)
- ❌ NOT "pass rate" (% of modules passed)
- ❌ NOT "attempt count" (how many tries it took)

### Color Coding
- **≥ 80%:** 🟢 Green (on track)
- **60-79%:** 🟡 Yellow (at risk)
- **< 60%:** 🔴 Red (failing trend)

### Alternative Metrics (Consider Adding)
If data team wants other quiz metrics:
- **Pass Rate:** `modules_passed / modules_attempted`
- **Avg Attempts:** `total_attempts / modules_attempted`
- **% Passed on 1st Try:** `first_attempt_passes / modules_attempted`

---

## Data Schema Reference

### Key Tables Used

**profiles** (coach metadata)
```
- id: coach ID
- persona: A|B|C|D (their skill level)
- baseline_completed, baseline_score
- endline_completed, endline_score
- weak_modules: JSON array of module names coach struggled with
```

**training_progress** (per-module attempt data)
```
- user_id, training_id
- passed: boolean (≥80% on quiz)
- score: quiz percentage (0-100)
- attempt_count: how many times they've retaken this module
- tab_switch_count: integrity check (how many times they switched tabs)
- flagged_for_review: boolean (admin review needed)
- content_completed: did they watch/complete video/slides
```

---

## Suggested Dashboard Improvements

### Priority 1: Fix Module Progress
- [ ] Display as `X / Y` where Y = total modules for coach's persona
- [ ] Prevents confusion about progress measurement

### Priority 2: Add Tooltip or Column Definition
- [ ] Add icon/hover tooltip explaining each column
- [ ] Clarifies "Avg Quiz = Average Score, not attempt rate"

### Priority 3: Consider Adding
- [ ] "Status" column: On Track | At Risk | Failed | Completed
- [ ] Weakness summary: If coach has weak_modules, show them
- [ ] Last activity date: When did coach last complete a module?

---

## Questions for Data Team?
If these clarifications don't answer your questions, please ask:
- Do you want to track "attempt rate" as a separate metric?
- Should flagged coaches be prevented from progressing, or just marked for review?
- What specific actions should admins take when they see a flagged coach?
