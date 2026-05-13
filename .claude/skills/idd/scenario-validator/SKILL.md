---
name: validating-scenarios-against-code
description: Use when running IDD validation - classify each scenario as COVERED/PARTIAL/MISSING/VIOLATION, assign severity, calculate final verdict
---

# Validating Scenarios Against Code

## Overview

Using the code mappings from code-mapper and behavior analysis from behavior-analyzer, classify each scenario and calculate the feature verdict.

## When to Use

- Fifth step in IDD validation pipeline
- After code-mapper and behavior-analyzer have completed
- Before report-formatter

## Classification Rules

### Positive Scenarios (@positive)

| Code Evidence | Status |
|--------------|--------|
| ALL Given/When/Then steps confirmed in scope with file+line | ✅ COVERED |
| SOME steps confirmed, others missing | ⚠️ PARTIAL |
| Entry point not found in scope | ❌ MISSING |

### Negative Scenarios (@negative)

| Code Evidence | Status |
|--------------|--------|
| Forbidden behavior IMPOSSIBLE (guard present at all paths) | ✅ COVERED |
| Forbidden behavior CAN OCCUR (even once, even in rare case) | ❌ VIOLATION |
| Entry point not found in scope | ❌ MISSING |

**CRITICAL for @negative:** ONE instance of possible forbidden behavior = ❌ VIOLATION.
Guards elsewhere in the flow do NOT cancel a violation at any earlier point.

### Untagged Scenarios (no @positive or @negative)

Always → ❌ MISSING (tag is required for validation to proceed)

## Severity Assignment

Assign severity for every NON-COVERED finding:

| Severity | Examples |
|---------|---------|
| Critical | Auth bypass, OTP bypass, data loss, multi-tenancy broken, compliance violation |
| High | Core feature completely broken, users cannot complete workflow |
| Medium | Feature degraded, edge case missing, workaround exists |
| Low | Cosmetic issue, rare scenario, minor inconsistency |

Rules:
- COVERED findings: severity = — (dash)
- Non-COVERED: must pick one from table above

## Scenario Isolation

EACH scenario is validated independently:
- Reset all context between scenarios
- Do NOT carry forward conclusions from previous scenario
- "Scenario A was COVERED" cannot influence Scenario B

## Verdict Calculation

Apply exactly one:

| Verdict | Condition |
|---------|-----------|
| PASS | ALL scenarios ✅ COVERED |
| PARTIAL | ≥1 ⚠️ PARTIAL AND zero ❌ findings |
| FAIL | ≥1 ❌ MISSING OR ≥1 ❌ VIOLATION |

## Hard Constraints

- Use ONLY these four statuses: ✅ COVERED, ⚠️ PARTIAL, ❌ MISSING, ❌ VIOLATION
- Use ONLY these three verdicts: PASS, PARTIAL, FAIL
- No custom statuses, no variations, no combined verdicts
- No suggestions, no code improvement recommendations

## Output

Per-scenario classification with status, evidence, severity. Plus the single feature verdict.
