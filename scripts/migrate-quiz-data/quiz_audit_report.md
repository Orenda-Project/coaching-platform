# Quiz Data Audit Report

**Generated:** 2026-06-09 14:41:18

## Summary

- **Extracted MCQ Questions:** 142
- **Extracted with Answer Keys:** 136
- **Extracted without Answer Keys:** 6

- **Supabase Module Quiz Questions:** 200
- **Supabase Baseline Questions:** 30

## Count Analysis

### Extracted vs Supabase Module Quizzes

⚠️ **MISMATCH:** Extracted has -58 questions
   - Extracted: 142
   - Supabase module quizzes: 200

## Per-Module Breakdown

| Module | Extracted | Extracted w/ Keys | Supabase Module Quizzes | Status |

|--------|-----------|-------------------|------------------------|--------|

| module_1 | 44 | 44 | 56 | ⚠️ |

| module_2 | 20 | 20 | 24 | ⚠️ |

| module_3 | 20 | 14 | 24 | ⚠️ |

| module_4 | 26 | 26 | 32 | ⚠️ |

| module_5 | 26 | 26 | 32 | ⚠️ |

| module_6 | 6 | 6 | 32 | ⚠️ |


## Unit-Level Breakdown (Supabase)

| Unit | Questions | Status |

|------|-----------|--------|

| Unit 1.0 | 8 | ✓ |

| Unit 1.1 | 8 | ✓ |

| Unit 1.2 | 8 | ✓ |

| Unit 1.3 | 8 | ✓ |

| Unit 1.4 | 8 | ✓ |

| Unit 1.5 | 8 | ✓ |

| Unit 1.6 | 8 | ✓ |

| Unit 2.1 | 8 | ✓ |

| Unit 2.2 | 8 | ✓ |

| Unit 2.3 | 8 | ✓ |

| Unit 3.1 | 8 | ✓ |

| Unit 3.2 | 8 | ✓ |

| Unit 3.3 | 8 | ✓ |

| Unit 4.1 | 8 | ✓ |

| Unit 4.2 | 8 | ✓ |

| Unit 4.3 | 8 | ✓ |

| Unit 4.4 | 8 | ✓ |

| Unit 5.1 | 8 | ✓ |

| Unit 5.2 | 8 | ✓ |

| Unit 5.3 | 8 | ✓ |

| Unit 5.4 | 8 | ✓ |

| Unit 6.1 | 8 | ✓ |

| Unit 6.2 | 8 | ✓ |

| Unit 6.3 | 8 | ✓ |

| Unit 6.4 | 8 | ✓ |


## Module Details (Extracted Data)


### module_1

- Total: 44

- With Answer Keys: 44

- Without Answer Keys: 0


### module_2

- Total: 20

- With Answer Keys: 20

- Without Answer Keys: 0


### module_3

- Total: 20

- With Answer Keys: 14

- Without Answer Keys: 6


### module_4

- Total: 26

- With Answer Keys: 26

- Without Answer Keys: 0


### module_5

- Total: 26

- With Answer Keys: 26

- Without Answer Keys: 0


### module_6

- Total: 6

- With Answer Keys: 6

- Without Answer Keys: 0


## Context

- **Baseline Assessment:** 30 questions (currently in Supabase, separate from module quizzes)

- **Extraction Source:** Google Docs (extracted_quizzes.json)

- **Target:** Migrate extracted MCQ data to replace/supplement existing module quizzes


## Recommendation

⚠️ **INVESTIGATE MISMATCH BEFORE MIGRATION**


Question counts don't match. Possible explanations:

1. Extracted data is newer/different version than what's in Supabase

2. Some questions were removed or added to Supabase

3. Baseline assessment questions are separate (not in module quizzes)


**Action:** Review the per-module breakdown to identify which modules differ.
