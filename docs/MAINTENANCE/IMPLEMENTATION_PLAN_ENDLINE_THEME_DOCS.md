# Implementation Plan: Endline Questions, Theme Consistency, & Documentation Organization

**Date:** 2026-04-14
**Status:** Planning Phase
**Scope:** 3 major changes to coaching platform

---

## 1. ENDLINE ASSESSMENT: 20 QUESTIONS (16 MCQ + 4 Open-Ended)

### Requirement
- **Total:** 20 questions for endline
- **16 MCQ:** Equal ratio from each module unit (e.g., 4 modules = 4 MCQ per module)
- **4 Open-Ended:** 1 from each module (ungraded, text entry only)
- **Pass threshold:** 70% (MCQ only, open-ended doesn't count toward score)

### Implementation Strategy

#### Step 1: Create Database Migration
**File:** `supabase/migrations/20260415000001_endline_questions_by_module.sql`

**Changes:**
- Add `module_id` FK column to `questions` table (nullable, for future filtering)
- Create `endline_assessment` record (if not exists) with type='endline'
- Seed 20 endline questions:
  - **16 MCQ questions:** 4 questions per module (order_number 1-16)
    - Each has `question_type='mcq'` with 4 options
    - Each has `module_id` set to corresponding module
  - **4 Open-ended questions:** 1 per module (order_number 17-20)
    - Each has `question_type='open'` with `correct_answer` field populated
    - Each has `module_id` set to corresponding module

**Example structure:**
```sql
-- Questions 1-4: Module 1 MCQ
INSERT INTO questions (id, assessment_id, question_type, question_text, module_id, order_number, ...)
VALUES (...), (...), (...), (...);

-- Questions 5-8: Module 2 MCQ
INSERT INTO questions (...) VALUES (...), (...), (...), (...);

-- Questions 9-12: Module 3 MCQ
-- Questions 13-16: Module 4 MCQ

-- Questions 17: Module 1 Open-ended
INSERT INTO questions (id, assessment_id, question_type, question_text, module_id, correct_answer, order_number, ...)
VALUES (...);

-- Question 18: Module 2 Open-ended
-- Question 19: Module 3 Open-ended
-- Question 20: Module 4 Open-ended
```

#### Step 2: Update Assessment.tsx
**File:** `src/pages/Assessment.tsx`

**Changes:**

A. **Update question loading for endline (lines 128-182):**
```typescript
// NEW: Separate MCQ from open-ended
const loadQuestions = async () => {
  // ... existing code ...

  // Instead of loading all questions, separate them:
  if (isEndline) {
    // Load 16 MCQ + 4 open-ended (already ordered in DB)
    // questionsData will have mixed types
  }

  setQuestions(questionsWithOptions);
};
```

B. **Update question rendering (lines 466-496):**
Add conditional rendering for question type:
```typescript
// If MCQ: render RadioGroup (existing code)
if (currentQuestion.question_type === 'mcq') {
  // Existing RadioGroup code
}

// If open-ended: render Textarea
if (currentQuestion.question_type === 'open') {
  return (
    <Card className="bg-card border-border">
      <CardHeader>
        <CardTitle className="text-foreground text-base leading-relaxed">
          {currentIndex + 1}. {currentQuestion.question_text}
        </CardTitle>
      </CardHeader>
      <CardContent>
        <textarea
          value={answers[currentQuestion.id] || ""}
          onChange={(e) => {
            setAnswers((prev) => ({ ...prev, [currentQuestion.id]: e.target.value }));
            setHasStarted(true);
          }}
          placeholder="Type your answer here..."
          className="w-full p-3 border border-input rounded-lg focus:outline-none focus:ring-2 focus:ring-primary min-h-[120px]"
        />
      </CardContent>
    </Card>
  );
}
```

C. **Update score calculation (lines 184-217):**
Only MCQ questions count toward 70% threshold:
```typescript
let correctCount = 0;
let mcqCount = 0;
for (const q of questions) {
  // Only count MCQ questions
  if (q.question_type !== 'mcq') continue;

  mcqCount++;
  const selectedOptionId = answers[q.id];
  if (!selectedOptionId) continue;
  const selectedOption = q.options.find((o) => o.id === selectedOptionId);
  if (selectedOption?.is_correct) correctCount++;
}

// pct based on MCQ only
const pct = mcqCount > 0 ? Math.round((correctCount / mcqCount) * 100) : 0;

// Open-ended answers are saved but don't affect the score
// (Can be reviewed manually by admin later)
```

D. **Update score display:**
Change message from "You scored X% (Y of Z)" to:
```typescript
// For endline
`You scored ${pct}% on 16 multiple choice questions (${correctCount}/${mcqCount} correct).
Your written responses have been submitted for review.`
```

### Data Flow Diagram
```
User takes endline → Questions load (16 MCQ + 4 open-ended, ordered by module)
                  ↓
           User answers all 20
                  ↓
          On submit: Calculate MCQ score only (16 MCQ / 16 = denominator)
                  ↓
          If pct ≥ 70%: Issue certificate + save endline_score + save open-ended text to answers
          If pct < 70%: Show error + allow retry + save open-ended text (but not to profile)
```

---

## 2. THEME CONSISTENCY: Light Theme Across All Pages

### Current State
- **Assessment.tsx:** Hard-coded Tailwind colors (blue-50, amber-200, green-600, amber-600)
- **Dashboard.tsx:** CSS variables (bg-background, text-foreground, bg-card)
- **TrainingModule.tsx:** Dark theme (bg-slate-900, text-teal-400)
- **Overall:** Inconsistent theming creates visual jarring

### Requirement
Apply consistent light theme across **all** pages using CSS variables

### Implementation Strategy

#### Step 1: Audit and Standardize CSS Variables
**File:** `src/index.css`

**Current variables (light theme):**
```css
--background: 210 20% 98%;      /* Light gray */
--foreground: 0 0% 0%;          /* Black */
--card: 0 0% 100%;              /* White */
--primary: 220 70% 25%;         /* Dark blue */
--secondary: 38 92% 55%;        /* Orange */
--success: 142 60% 40%;         /* Green */
--warning: 38 92% 55%;          /* Orange */
--destructive: 0 84% 60%;       /* Red */
--muted: 210 5% 40%;            /* Gray */
--border: 210 10% 90%;          /* Light gray border */
--input: 210 10% 85%;           /* Input background */
--ring: 220 70% 25%;            /* Focus ring (primary) */
```

**Ensure these cover:**
- Background colors (page, cards, inputs)
- Text colors (primary, muted, foreground)
- Border colors
- Icon colors (success, warning, destructive)

#### Step 2: Replace Hard-Coded Colors in Assessment.tsx
**File:** `src/pages/Assessment.tsx`

**Changes:**

| Line | Old | New | Reason |
|------|-----|-----|--------|
| 329 | `border-amber-200 bg-amber-50` | `border-warning/20 bg-warning/10` | Use CSS var for warning blocks |
| 331 | `text-amber-600` | `text-warning` | Icon color from CSS var |
| 332 | `text-amber-900` | `text-foreground` | Title from CSS var |
| 335 | `text-amber-800` | `text-muted-foreground` | Body text from CSS var |
| 338 | `text-amber-700` | `text-muted-foreground` | Hint text from CSS var |
| 407 | `bg-blue-50 border-blue-200` | `bg-primary/5 border-primary/20` | Info box from CSS var |
| 409, 413 | `text-blue-600` | `text-primary` | Icon colors from CSS var |
| 417 | `text-green-600` | `text-success` | Success icon from CSS var |
| 421 | `text-amber-600` | `text-warning` | Warning icon from CSS var |
| 535 | `text-amber-600` | `text-warning` | Remaining count from CSS var |

**Result:** All colors now theme-driven. Change one CSS variable → entire app updates.

#### Step 3: Fix TrainingModule.tsx Dark Theme
**File:** `src/pages/TrainingModule.tsx`

**Changes:**
- Replace all `bg-slate-900`, `bg-slate-800`, `text-teal-400`, `border-slate-700` with CSS variables
- Should match Assessment.tsx and Dashboard.tsx styling

**Example transformations:**
```
bg-slate-900        → bg-background
bg-slate-800/60     → bg-card/60
text-teal-400       → text-primary
border-slate-700    → border-border
text-slate-300      → text-foreground
text-slate-400      → text-muted-foreground
```

#### Step 4: Create Theme Documentation
**File:** `docs/THEME_SYSTEM.md`

Document:
- All CSS variables
- When to use each color
- Examples of proper theming
- How to extend colors
- Light/dark theme support (for future)

---

## 3. DOCUMENTATION ORGANIZATION: Centralize .md Files

### Current State
- **23 .md files** at root level `/Users/mac/Desktop/data/Taleemabad/coaching-platform/`
- Mix of: architecture, setup, deployment, testing, features, services
- No clear organization → hard to navigate

### Requirement
Move all documentation into a single folder `/docs` with standardized structure

### Folder Structure
```
/Users/mac/Desktop/data/Taleemabad/coaching-platform/docs/
├── README.md                          (Index & quick links)
├── ARCHITECTURE/
│   ├── COACHING_PLATFORM_ARCHITECTURE.md
│   ├── COACHING_PLATFORM_ROADMAP.md
│   ├── COACHING_PLATFORM_EXECUTIVE_SUMMARY.md
│   └── DATABASE_SCHEMA.md (new: extract DB info)
├── SETUP/
│   ├── QUICK_START.md (rename: QUICK_START_PHASE_1.md)
│   ├── ENVIRONMENT_SUMMARY.md
│   ├── SETUP_CHECKLIST.md
│   └── DEPLOYMENT.md
├── FEATURES/
│   ├── ASSESSMENT_SYSTEM.md (new: explain baseline/endline/module quiz)
│   ├── LEARNING_FLOW.md (new: explain scenario-first model)
│   ├── PROFILE_SYSTEM.md (new: explain user profile)
│   └── ANALYTICS.md (new: explain event tracking)
├── TESTING/
│   ├── TESTING_CHECKLIST_PHASE_1.md
│   ├── QUICK_VERIFY.md (rename)
│   └── STAGING_VERIFICATION.md
├── DEPLOYMENT/
│   ├── DEPLOYMENT.md (move from root)
│   ├── ENVIRONMENT_SUMMARY.md (move from root)
│   └── ROLLBACK_PROCEDURES.md (new: extract from DEPLOYMENT.md)
├── REFERENCE/
│   ├── PROJECT_MAP.md (move from root)
│   ├── DEVELOPMENT_STANDARDS.md
│   ├── THEME_SYSTEM.md (new: from step above)
│   └── GLOSSARY.md (new: term definitions)
└── PHASE_1/
    ├── PHASE_1_DOCUMENTATION_INDEX.md
    ├── PHASE_1_COMPLETION_SUMMARY.md
    ├── PHASE_1_TESTING_CHECKLIST.md
    └── SESSION_SUMMARY_2026_04_14.md
```

### Implementation Steps

#### Step 1: Create `/docs` folder
```bash
mkdir -p /Users/mac/Desktop/data/Taleemabad/coaching-platform/docs
mkdir -p /Users/mac/Desktop/data/Taleemabad/coaching-platform/docs/{ARCHITECTURE,SETUP,FEATURES,TESTING,DEPLOYMENT,REFERENCE,PHASE_1}
```

#### Step 2: Move existing .md files
**Mappings:**
```
COACHING_PLATFORM_ARCHITECTURE.md       → docs/ARCHITECTURE/
COACHING_PLATFORM_ROADMAP.md            → docs/ARCHITECTURE/
COACHING_PLATFORM_EXECUTIVE_SUMMARY.md  → docs/ARCHITECTURE/
PROJECT_MAP.md                          → docs/REFERENCE/
DEVELOPMENT_STANDARDS.md                → docs/REFERENCE/
ENVIRONMENT_SUMMARY.md                  → docs/DEPLOYMENT/
DEPLOYMENT.md                           → docs/DEPLOYMENT/
SETUP_CHECKLIST.md                      → docs/SETUP/
QUICK_START_PHASE_1.md                  → docs/SETUP/ (rename to QUICK_START.md)
QUICK_VERIFY.md                         → docs/TESTING/
TESTING_CHECKLIST_PHASE_1.md            → docs/TESTING/
STAGING_VERIFICATION.md                 → docs/TESTING/
PHASE_1_*.md                            → docs/PHASE_1/
```

#### Step 3: Create New Documentation Files

A. **docs/README.md** (navigation hub)
```markdown
# Coaching Platform Documentation

## Quick Start
- [Getting Started](SETUP/QUICK_START.md)
- [Environment Setup](SETUP/ENVIRONMENT_SUMMARY.md)

## Architecture
- [System Design](ARCHITECTURE/COACHING_PLATFORM_ARCHITECTURE.md)
- [Roadmap](ARCHITECTURE/COACHING_PLATFORM_ROADMAP.md)
- [Database Schema](ARCHITECTURE/DATABASE_SCHEMA.md)

## Features
- [Assessment System](FEATURES/ASSESSMENT_SYSTEM.md)
- [Learning Flow](FEATURES/LEARNING_FLOW.md)
- [User Profiles](FEATURES/PROFILE_SYSTEM.md)
- [Analytics](FEATURES/ANALYTICS.md)

## Testing
- [Testing Checklist](TESTING/TESTING_CHECKLIST_PHASE_1.md)
- [Verification](TESTING/QUICK_VERIFY.md)

## Deployment
- [Deployment Guide](DEPLOYMENT/DEPLOYMENT.md)
- [Environment Summary](DEPLOYMENT/ENVIRONMENT_SUMMARY.md)

## Reference
- [Development Standards](REFERENCE/DEVELOPMENT_STANDARDS.md)
- [Theme System](REFERENCE/THEME_SYSTEM.md)
- [Project Map](REFERENCE/PROJECT_MAP.md)
- [Glossary](REFERENCE/GLOSSARY.md)
```

B. **docs/FEATURES/ASSESSMENT_SYSTEM.md** (new)
```markdown
# Assessment System

## Overview
Three types of assessments in the coaching platform:
1. **Baseline:** 30 MCQ questions, 60% pass threshold, assigns persona
2. **Endline:** 20 questions (16 MCQ + 4 open-ended), 70% pass threshold, issues certificate
3. **Module Quiz:** 5 questions per module, 80% pass threshold, unlocks next module

## Baseline Assessment
- Route: `/assessment/baseline`
- Questions: 30 Likert-scale (Disagree/Agree) on coaching competencies
- Scoring: 6 questions per module → identifies weak modules
- On pass: Assigns persona (A/B/C/D) based on score
- On fail: User retries with same questions

## Endline Assessment
- Route: `/assessment/endline`
- Prerequisites: All assigned modules must be passed
- Questions: 16 MCQ (4 per module) + 4 open-ended (1 per module)
- Scoring: MCQ only counts toward 70% threshold
- Open-ended: Ungraded text entry (saved for manual review)
- On pass: Issues certificate with unique ID
- On fail: User retries with same questions

[More details...]
```

C. **docs/FEATURES/LEARNING_FLOW.md** (new)
```markdown
# Learning Flow: Scenario-First Model

## Overview
The Scenario-First learning model inverts the traditional (Slides-First) approach:

**Slides-First (old):** Watch slides (60% skip) → Quiz (70% fail)
**Scenario-First (new):** Make decision (100% engage) → See feedback → Optional depth

## Flow Diagram
[Scenario → Feedback → Reveal → Depth → Summary diagram]

## Components
- **ScenarioCard:** Display situation + question + 4 MCQ options
- **FeedbackCard:** Show correct/incorrect verdict + rationale
- **RevealSlides:** Carousel of feedback slides
- **ExpandableDepth:** Collapsible deep content

[More details...]
```

D. **docs/ARCHITECTURE/DATABASE_SCHEMA.md** (new)
```markdown
# Database Schema Reference

## Core Tables
[Extract from types.ts]

### assessments
```
id UUID PRIMARY KEY
type TEXT ('baseline'|'endline'|'training'|'module_quiz')
title TEXT
training_id UUID FK (null for baseline/endline)
created_at TIMESTAMPTZ
```

### questions
```
id UUID PRIMARY KEY
assessment_id UUID FK
question_type TEXT ('mcq'|'open')
question_text TEXT
correct_answer TEXT (for open-ended)
order_number INT
created_at TIMESTAMPTZ
```

[More tables...]
```

E. **docs/REFERENCE/GLOSSARY.md** (new)
```markdown
# Glossary

**Persona:** User's coaching skill level assigned after baseline (A/B/C/D)

**Weak Module:** Module where user scored <70% on baseline

**Module Quiz:** 5-question assessment to unlock next module

[More terms...]
```

#### Step 4: Update .gitignore (if needed)
Root README.md should now point to `/docs/README.md`:
```markdown
# Coaching Platform

See [DOCUMENTATION](docs/README.md) for complete guides.

[Minimal project info here]
```

#### Step 5: Update package.json scripts (if any reference docs)
If any build/deploy scripts reference specific .md files, update paths.

---

## Implementation Order

### Priority 1 (Endline Assessment): 1-2 hours
1. Create migration: `20260415000001_endline_questions_by_module.sql`
2. Update Assessment.tsx: handle MCQ vs open-ended rendering
3. Update score calculation: MCQ only toward 70%
4. Test: baseline still works, endline renders correctly, open-ended saves

### Priority 2 (Theme Consistency): 1-2 hours
1. Audit CSS variables in `src/index.css`
2. Replace hard-coded colors in Assessment.tsx
3. Fix TrainingModule.tsx dark theme
4. Create `docs/REFERENCE/THEME_SYSTEM.md`
5. Test: all pages look consistent, light theme throughout

### Priority 3 (Documentation Organization): 1-2 hours
1. Create `/docs` folder structure
2. Move 23 .md files into appropriate folders
3. Create new feature documentation (ASSESSMENT_SYSTEM.md, LEARNING_FLOW.md, etc.)
4. Create `docs/README.md` index
5. Update root README.md to point to `/docs/README.md`
6. Git commit all changes

---

## Files to Modify/Create

### New Files
- `supabase/migrations/20260415000001_endline_questions_by_module.sql`
- `docs/README.md`
- `docs/ARCHITECTURE/DATABASE_SCHEMA.md`
- `docs/FEATURES/ASSESSMENT_SYSTEM.md`
- `docs/FEATURES/LEARNING_FLOW.md`
- `docs/FEATURES/PROFILE_SYSTEM.md`
- `docs/FEATURES/ANALYTICS.md`
- `docs/REFERENCE/THEME_SYSTEM.md`
- `docs/REFERENCE/GLOSSARY.md`

### Modified Files
- `src/pages/Assessment.tsx` (add open-ended, MCQ-only scoring, CSS vars)
- `src/pages/TrainingModule.tsx` (replace dark theme colors)
- `src/index.css` (audit & document CSS variables)
- `README.md` (point to `/docs/README.md`)
- Moved files (all existing .md → `/docs/` subfolders)

### Database
- One migration: add module_id to questions, seed 20 endline questions

---

## Success Criteria

✅ **Endline Assessment:**
- [ ] 20 questions load (16 MCQ + 4 open-ended)
- [ ] MCQ renders as radio buttons
- [ ] Open-ended renders as textarea
- [ ] Score calculated on MCQ only (16 questions)
- [ ] Open-ended answers saved to localStorage
- [ ] Pass/fail based on 70% MCQ score only
- [ ] Endline flow tested end-to-end

✅ **Theme Consistency:**
- [ ] Assessment.tsx uses only CSS variables (no hard-coded colors)
- [ ] TrainingModule.tsx matches light theme
- [ ] All pages visually consistent
- [ ] No more dark theme jars
- [ ] Theme changes by CSS var only

✅ **Documentation Organization:**
- [ ] All 23 .md files moved to `/docs/`
- [ ] New feature docs created
- [ ] `/docs/README.md` provides clear navigation
- [ ] Glossary and reference complete
- [ ] Root README.md updated with `/docs/` links
