# Baseline Assessment: 30 → 18 Questions Migration

**Status:** ✅ Ready for Testing  
**Branch:** `feature/baseline-18-questions-update`  
**Migration File:** `20260423_reduce_baseline_to_18_questions.sql`  
**Date:** 2026-04-23

---

## What Changed

### Before
- **30 total questions** across 6 modules (Module 2-6)
- Mix of concept-based MCQs and case studies per module
- Complex user flow for non-technical users (RMs/coaches)

### After
- **18 total questions** (3 per module)
- All questions from the "short with 18 questions" section of the baseline doc
- Simplified, focused on core coaching concepts and real-world scenarios
- Better UX for non-technical users per RM feedback

---

## Questions by Module

### Module 2: The Partnership Foundation (Trust & Status)
1. SCARF model - Status Threat
2. Opening Script with Equality and Voice (Freeze behavior)
3. Side-by-Side feedback approach (Defensive teacher)

### Module 3: The Mirror Specialist (Shared Reality)
4. Calibration Gap - Objective vs. Subjective
5. Third Partner approach (Perfect class, 0% exit ticket)
6. Voice principle in photo capture

### Module 4: Digital & Data Intelligence (Collaborative Analytics)
7. Human Override - Power outage + AI suggestion
8. Advocacy Script - Protecting coaching time
9. Shared Mirror - 100% task completion but copying
10. Administrative After-Burn prevention

### Module 5: The Instructional Catalyst (Co-Design)
11. Training Loop failure - Explanation vs. Execution
12. Belief Gap - Silence Myth
13. High-Leverage prioritization (8 gaps)
14. Co-Pilot approach in co-modeling

### Module 6: The Excellence Loop (Reciprocity & Praxis)
15. Responsive Contextualization (Local constraints)
16. Compliance Trap (High WRER, 0% growth)
17. Reciprocity with veteran teachers
18. Praxis (Action) vs. Theory

---

## Answer Key

| Q# | Answer | Q# | Answer |
|:---:|:---:|:---:|:---:|
| 1 | D | 10 | D |
| 2 | B | 11 | B |
| 3 | C | 12 | C |
| 4 | A | 13 | A |
| 5 | C | 14 | B |
| 6 | D | 15 | D |
| 7 | B | 16 | C |
| 8 | A | 17 | A |
| 9 | C | 18 | B |

---

## Grading Criteria

- **Pass Threshold:** >85% (≥16/18 correct)
- **Questions per module:** 3 questions minimum
- **Question type:** All MCQ with 4 options (A, B, C, D)
- **Time estimate:** 15-20 minutes for coaches to complete

---

## Migration Details

**File:** `supabase/migrations/20260423_reduce_baseline_to_18_questions.sql`

**Steps:**
1. Delete all existing baseline assessment options and questions
2. Delete existing baseline assessment record
3. Create new baseline assessment: "Coach Baseline Assessment"
4. Insert 18 questions with order_number 1-18
5. Insert all options (A, B, C, D) for each question with correct answers marked

**Schema:** 
- Uses existing `assessments` table (type='baseline')
- Uses existing `questions` table (question_type='mcq')
- Uses existing `options` table (is_correct boolean)
- No schema changes required

---

## Testing Checklist

- [ ] Run migration: `supabase db reset` (after Docker is running)
- [ ] Verify 18 questions are created in questions table
- [ ] Verify all 72 options (18 × 4) are created
- [ ] Check answer key correctness (is_correct=TRUE count should be 18)
- [ ] Test baseline assessment flow in UI
- [ ] Confirm UI displays questions 1-18 in order
- [ ] Verify passing score requires >85% (>15 correct)
- [ ] Check dashboard displays baseline result after completion

---

## Next Steps

1. **Code Review:** Create PR for `feature/baseline-18-questions-update`
2. **Testing:** Run E2E tests on staging
   - Signup → Baseline → Verify 18 questions load
   - Submit 16+ correct answers → Pass baseline
   - Submit <16 correct answers → Fail baseline
   - Check results on dashboard
3. **QA Sign-off:** RM testing on staging before production merge
4. **Deployment:** Merge to staging, then main

---

## Reference

**Baseline 18 Questions Doc:**  
https://docs.google.com/document/d/1x4XEaizZHPc5WKcKHZACo3gfIrwduYzr9zpDVFwJzoo/edit?tab=t.jve1gmp2osug

**All questions and answer keys sourced from:**  
- Section: "short with 18 questions" 
- Modules covered: 2-6 (Partnership, Mirror, Analytics, Catalyst, Excellence Loop)
