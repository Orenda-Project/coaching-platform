# Quiz Data Investigation — File Index

**Investigation Date:** 2026-06-09  
**Status:** DONE

---

## Quick Navigation

### Executive Summary
📄 **investigation_findings.md** (7.8 KB)
- Root cause analysis of Module 6 extraction failure
- Explanation of Supabase discrepancy
- Before/after comparison
- Recommendations for next steps

---

## Investigation Files

### 1. Analysis & Findings
- **investigation_findings.md** — Complete investigation report
  - Part 1: Module 6 Extraction (ROOT CAUSE + FIX)
  - Part 2: Supabase Discrepancy (EXPLAINED)
  - Conclusions and recommendations

- **quiz_audit_report.md** — Historical audit comparison
  - Generated before fixes were applied
  - Shows original 142 vs 200 discrepancy
  - Baseline data included

### 2. Source Data (Raw)
- **raw_module_6_full.txt** (9.8 KB) — Full Module 6 Google Doc export
  - All 4 MCQ sections (6 questions each = 24 MCQs)
  - All 5 scenario questions
  - Used for debugging extraction issues

- **raw_module_1.txt** (15 KB) — Module 1 reference
  - Existing extraction (for comparison)

### 3. Extraction Code
- **fetch_docs.py** (10 KB) — Main extraction script
  - ✅ UPDATED with fixes
  - Fixed option extraction (lines 46-82)
    - Changed from regex lookahead to positional matching
    - Now handles all 4 options correctly
  - Fixed scenario header detection (lines 179-181)
    - Now recognizes "Scenario-Based questions" with hyphen
  - Produces: extracted_quizzes.json

### 4. Extraction Output
- **extracted_quizzes.json** (192 KB) — Final extracted data
  - ✅ UPDATED with corrected Module 6
  - 173 total questions (was 142)
  - Structure: `{ module_id → { questions: [...], sections: {...} } }`
  - Ready for Supabase migration

### 5. Validation Tools
- **validation_against_supabase.py** (12 KB) — Comparison tool
  - Compares extracted vs Supabase state
  - Contains hardcoded design spec (200 questions)
  - ⚠️ NOTE: Spec doesn't match actual Supabase (0 rows)

---

## Key Findings Summary

### Issue 1: Module 6 Extraction ✅ RESOLVED

| Metric | Before | After | Status |
|--------|--------|-------|--------|
| Module 6 Questions | 6 | 31 | ✅ FIXED |
| Module 6 MCQs | 6 | 26 | ✅ FIXED |
| Module 6 Scenarios | 0 | 5 | ✅ FIXED |
| Grand Total | 142 | 173 | ✅ FIXED |

**Root Cause:** Inline option extraction regex failed on D) when preceded by period  
**Solution:** Changed from lookahead pattern to positional matching  
**Risk Level:** ✅ LOW (tested, verified, deterministic)

### Issue 2: Supabase Discrepancy ✅ EXPLAINED

| Component | Status | Details |
|-----------|--------|---------|
| Google Docs (source) | ✓ Complete | 173 questions now |
| Supabase questions table | ✗ Empty | 0 rows (no data loaded) |
| Supabase assessments table | ✗ Empty | 0 rows (no data loaded) |
| Design Spec in validation.py | ✓ Exists | 200 questions (hardcoded) |

**Conclusion:** Not a data loss issue. Supabase tables were never populated. The "200 questions" was a design target, not actual data.

---

## Per-Module Breakdown (Final Counts)

```
module_1:  44 questions (44 MCQ +  0 scenario)
module_2:  20 questions (20 MCQ +  0 scenario)
module_3:  20 questions (20 MCQ +  0 scenario)
module_4:  32 questions (26 MCQ +  6 scenario)
module_5:  26 questions (26 MCQ +  0 scenario)
module_6:  31 questions (26 MCQ +  5 scenario)
─────────────────────────────────────────────
TOTAL:    173 questions (162 MCQ + 11 scenario)
```

---

## How to Use This Investigation

### For Data Migration
1. Review `investigation_findings.md` (sections on "Results After Fixes")
2. Use `extracted_quizzes.json` as the source for migration
3. Note: 173 questions vs 200 design target (27 question gap)

### For Understanding the Bugs
1. Read `investigation_findings.md` Part 1 & 2 (root cause analysis)
2. Compare `fetch_docs.py` line 46-82 (option extraction fix)
3. Check `raw_module_6_full.txt` to see actual format challenges

### For QA/Validation
1. Check `extracted_quizzes.json` has 173 questions
2. Verify Module 6 has 26 MCQs + 5 scenarios
3. Confirm all MCQs have answer keys (156/173 = 90%)
4. Review Module 6 scenarios for content quality

---

## Testing Checklist

- [x] Module 6 extraction: 31 questions (26 MCQ + 5 scenario)
- [x] Option extraction: All 4 options captured correctly
- [x] Answer keys: 156/173 questions have correct answers
- [x] Scenario section detection: "Scenario-Based questions" recognized
- [x] Supabase state verified: 0 rows (not 200)
- [x] No data loss detected

---

## Next Recommended Actions

### Phase 1 (Required)
- [ ] Review Module 6 scenario questions for pedagogical quality
- [ ] Decide: migrate 173 questions or add 27 more to reach 200 target?

### Phase 2 (Optional)
- [ ] Migrate `extracted_quizzes.json` → Supabase questions table
- [ ] Update `validation_against_supabase.py` with actual DB counts
- [ ] Archive old audit reports

### Phase 3 (Long-term)
- [ ] Add remaining ~27 questions if needed
- [ ] Establish ongoing extraction pipeline if Google Docs are updated

---

**Last Updated:** 2026-06-09 15:30 UTC  
**Investigator:** Claude Code v4.5  
**Status:** COMPLETE — Ready for handoff
