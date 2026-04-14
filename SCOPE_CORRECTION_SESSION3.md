# Scope Correction — Session 3 (2026-04-14)

## Summary

User's request was **misinterpreted in previous session**. The 20-question assessment format (16 MCQ + 4 open-ended) should apply to **MODULE QUIZ**, not ENDLINE assessment.

### What Was Wrong
- Created migration: `20260430000001_endline_assessment_20_questions.sql`
- This added 20 questions to ENDLINE assessment
- But user actually wanted 20 questions for MODULE QUIZ

### What Was Fixed
✅ **Deleted:** `20260430000001_endline_assessment_20_questions.sql`
✅ **Created:** `20260501000001_module_quiz_20_questions.sql`
- Applies 20-question format to MODULE QUIZ assessments
- Not to endline assessment

### Current State

#### Module Quiz (NOW 20 QUESTIONS)
- **16 MCQ Questions** (4 per module: Modules 2, 3, 4, 5)
  - Scored: counts toward 80% pass threshold
  - Questions 1-4: Module 2 (Partnership Foundation)
  - Questions 5-8: Module 3 (Mirror Specialist)
  - Questions 9-12: Module 4 (Digital & Data Intelligence)
  - Questions 13-16: Module 5 (Instructional Catalyst)

- **4 Open-Ended Questions** (1 per module)
  - Ungraded: for coach reflection/review only
  - Questions 17-20: One per module 2-5

#### Endline Assessment (NOT YET IMPLEMENTED)
- User stated: "for endline the questions are not added yet"
- Will be implemented in separate phase
- No changes needed to Assessment.tsx (already supports question_type discrimination)

### Files Changed
- `supabase/migrations/20260501000001_module_quiz_20_questions.sql` (NEW)
- Commit: `042c624`

### What Assessment.tsx Already Supports
The Assessment.tsx component already correctly:
- ✅ Detects question type (MCQ vs open-ended)
- ✅ Renders MCQ with radio buttons + 4 options
- ✅ Renders open-ended with textarea + "does not count toward your score" note
- ✅ Calculates MCQ-only score for endline (filtering out open-ended)
- ✅ Uses CSS variables for light theme consistency

**No code changes needed to Assessment.tsx** — it's already prepared for this.

### Next Steps
1. Run `supabase db reset` to apply the new migration
2. Verify module quiz now shows 20 questions instead of 5
3. Confirm MCQ and open-ended questions render correctly
4. Test complete flow: dashboard → select module → quiz → MCQ questions → open-ended → submit
5. Verify scoring only counts MCQ (not open-ended) toward 80% threshold

### Migration Details
**File:** `supabase/migrations/20260501000001_module_quiz_20_questions.sql`

Structure:
- Uses CTEs to find training units by module
- Inserts MCQ questions with equal distribution (4 per module)
- Inserts open-ended questions (1 per module, ungraded)
- Includes all 4 options (A/B/C/D) with rationales and principle tags
- Idempotent: uses `NOT EXISTS` to prevent duplicate inserts

### Important Notes
- Migration timestamp `20260501000001` comes after `20260425000001` (schema changes)
- Safe to apply multiple times (idempotent)
- No breaking changes to existing assessments
- Existing 5-question baseline/endline assessments unaffected

---

**Commit:** 042c624
**Date:** 2026-04-14
**Status:** ✅ READY FOR TESTING
