---
name: formatting-idd-validation-reports
description: Use when completing IDD validation - format findings into the standard markdown report consumed by CI/CD and PR comments
---

# Formatting IDD Validation Reports

## Overview

Produce the final markdown report. This format is a contract — downstream tools parse it. Deviations break CI/CD.

## When to Use

- Final step in IDD validation pipeline
- After scenario-validator has classified all scenarios and calculated verdict
- Output ONLY this report — nothing else

## Required Output Format

```markdown
## IDD Validation Report
**Feature:** `{feature_filename}`
**Mode:** `chunk` | `full`
**Scenarios Validated:** {N}

### Scenario Findings

| Scenario | Status | Evidence | Severity | Impact |
|----------|--------|----------|----------|--------|
| {name} | ✅ COVERED | file: path \| function: name \| line: N | — | — |
| {name} | ⚠️ PARTIAL | file: path \| function: name \| line: N | High | {impact description} |
| {name} | ❌ MISSING | no evidence | Medium | {impact description} |
| {name} | ❌ VIOLATION | file: path \| function: name \| line: N | Critical | {impact description} |

### Verdict

**PASS** | **PARTIAL** | **FAIL**
```

## Field Rules

**Feature:** filename including subdirectory (e.g. `authentication/sign-in.feature`)

**Mode:** exactly `chunk` or `full` — no other values

**Scenarios Validated:** integer count of scenarios in the table

**Status column:** ONLY these symbols — no variations:
- ✅ COVERED
- ⚠️ PARTIAL
- ❌ MISSING
- ❌ VIOLATION

**Evidence column:**
- COVERED/VIOLATION: `file: path/to/file.py | function: name | line: N`
- MISSING with no code found: `no evidence`
- PARTIAL: cite deepest confirmed step

**Severity column:**
- COVERED: `—` (em dash)
- Non-COVERED: exactly one of: `Critical`, `High`, `Medium`, `Low`

**Impact column:**
- COVERED: `—`
- Non-COVERED: one sentence, plain language, user-facing

**Verdict:**
- Exactly one of: `**PASS**`, `**PARTIAL**`, `**FAIL**`
- On its own line after the `### Verdict` header
- No other text after the verdict

## Hard Constraints

- No extra columns in the table
- No content after the Verdict section
- ALL retained scenarios must appear in the table
- No intermediate skill output in this report
- No code suggestions, no improvement recommendations
- This is the ONLY output Claude produces — all reasoning is internal
