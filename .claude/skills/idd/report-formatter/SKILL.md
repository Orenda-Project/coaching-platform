---
name: formatting-idd-validation-reports
description: Use when producing final IDD validation output - create markdown table with scenario findings, assign PASS/PARTIAL/FAIL verdict, follow schema exactly
---

# Formatting IDD Validation Reports

## Overview

Transform scenario findings into a **final report** for CI/CD pipeline and QA review. Output ONLY the defined schema — no intermediate skill results.

**Core principle:** Schema is a contract. Violate it = tool breaks.

## When to Use

- Last step in IDD validation pipeline
- Consumers: CI/CD pipeline, GitHub PR comments, QA dashboards
- Only source of truth for pipeline consumers

## When NOT to Use

- For analysis (use validator before reaching this skill)
- For intermediate debugging (capture findings before here)

## Core Process

### Step 1: Verify Inputs

```
From scenario-validator:
  ✓ scenario_name (exact from .feature file)
  ✓ type (@positive / @negative / untagged)
  ✓ status (✅ / ⚠️ / ❌ only)
  ✓ evidence (file + line OR "no evidence")
  ✓ severity (description OR "—" for COVERED)
  ✓ impact (Safe / Critical / High / Medium / Low)
```

### Step 2: Build Report Metadata

```
Feature: {feature_filename}
Mode: chunk | full
Scenarios Validated: {N}
```

### Step 3: Create Scenario Table

One row per scenario (ALL scenarios, none omitted):

```markdown
| Scenario | Status | Evidence | Severity | Impact |
|----------|--------|----------|----------|--------|
| {scenario name} | ✅ | file:... | — | Safe |
| {scenario name} | ⚠️ | file:... | (plain-language explanation) | Medium |
| {scenario name} | ❌ | no evidence | (plain-language explanation) | High |
```

**Status column contains ONLY the emoji — no text after it.**

### Step 4: Assign Verdict

```
PASS    → all scenarios ✅ COVERED
PARTIAL → at least one ⚠️ PARTIAL, zero ❌
FAIL    → at least one ❌ MISSING or ❌ VIOLATION
```

### Step 5: Output (EXACTLY this schema — no variations)

```markdown
## IDD Validation Report

**Feature:** `{feature_filename}`
**Mode:** `chunk` | `full`
**Scenarios Validated:** {N}

### Scenario Findings

| Scenario | Status | Evidence | Severity | Impact |
|----------|--------|----------|----------|--------|
[one row per scenario]

### Verdict

**PASS** | **PARTIAL** | **FAIL**
```

## Quick Reference: Column Rules

### Scenario Column
- Exact name from `.feature` file
- No paraphrasing or abbreviation

### Status Column
- `✅` — scenario fully implemented (COVERED)
- `⚠️` — partially implemented, some steps missing (PARTIAL)
- `❌` — no implementation found (MISSING)
- `❌` — forbidden behavior exists, @negative only (VIOLATION)

**Use ONLY the emoji symbol alone. No text label after it. No variations.**

### Evidence Column

| Status | Format |
|--------|--------|
| ✅ COVERED | `file: path/to/file.py \| function: name \| line: N` |
| ⚠️ PARTIAL | `file: path/to/file.py \| function: name \| line: N — steps missing: [list]` |
| ❌ MISSING | `no evidence` |
| ❌ VIOLATION | `file: path/to/file.py \| function: name \| line: N — forbidden behavior occurs` |

### Severity Column

| Status | Fill With |
|--------|-----------|
| ✅ COVERED | `—` (dash only) |
| ⚠️ PARTIAL | Plain-language explanation of what's broken |
| ❌ MISSING | Plain-language explanation of missing feature |
| ❌ VIOLATION | Plain-language explanation of security/compliance risk |

**Examples:**
- "Form validates input but response handler missing → button stays in loading state"
- "QuerySet missing tenant filter → users see other tenants' data"
- "Off-by-one error: uses < instead of <= → OTP accepted for 1-second window"

### Impact Column

| Status | Fill With |
|--------|-----------|
| ✅ COVERED | `Safe` |
| ⚠️ PARTIAL | `Critical` / `High` / `Medium` / `Low` |
| ❌ MISSING | `Critical` / `High` / `Medium` / `Low` |
| ❌ VIOLATION | `Critical` / `High` / `Medium` / `Low` |

**Impact levels:**
- `Critical` → auth bypass, data loss, multi-tenancy broken, compliance violation
- `High` → core feature completely broken, workflow blocked
- `Medium` → feature degraded or partially works, edge cases missing
- `Low` → cosmetic issue, rare edge case, minor inconsistency

## Schema Validation Checklist

Before outputting report, verify:

- [ ] YAML metadata correct (Feature, Mode, Scenarios Validated)
- [ ] Markdown table headers match spec exactly
- [ ] ONE row per scenario (no omissions)
- [ ] Status uses ONLY ✅/⚠️/❌ symbols
- [ ] Evidence follows column rules (file:path | function:name | line:N)
- [ ] Severity: dash for COVERED, plain-language for others
- [ ] Impact: Safe for COVERED, severity level for others
- [ ] Verdict is PASS/PARTIAL/FAIL (exactly one)
- [ ] No content after Verdict line
- [ ] No intermediate skill results in output

## Common Mistakes

| Mistake | Fix |
|--------|-----|
| Extra columns in table | Use ONLY: Scenario, Status, Evidence, Severity, Impact |
| Status variants like "✅ FULLY COVERED" | Use ONLY: ✅ or ⚠️ or ❌ |
| Severity for COVERED scenarios | Write dash (`—`) not description |
| Mixed impact levels (e.g., "High-Critical") | Pick ONE: Critical / High / Medium / Low |
| Omitting scenarios | ALL scenarios appear in table |
| Content after Verdict | Stop at Verdict line. Nothing after. |

## Hard Constraints

✋ **NEVER:**
- Add columns beyond the 5 specified
- Use status variations (e.g., ✅ PARTIAL)
- Output intermediate results
- Summarize or editorialize

✅ **ALWAYS:**
- Follow schema exactly
- Include ALL scenarios
- Use defined symbols only
- Stop at Verdict

## Example Report

```markdown
## IDD Validation Report

**Feature:** `sign-in.feature`
**Mode:** `chunk`
**Scenarios Validated:** 2

### Scenario Findings

| Scenario | Status | Evidence | Severity | Impact |
|----------|--------|----------|----------|--------|
| Sign in with valid credentials and single profile | ✅ | file: apps/auth/views.py \| function: authenticate_user \| line: 42 | — | Safe |
| Sign in with invalid password is rejected | ❌ | file: apps/auth/views.py \| function: authenticate_user \| line: 55 — password compared as plaintext instead of hashed | Code accepts plaintext match, bypassing secure comparison | Critical |

### Verdict

**FAIL**
```

## Reference: Verdict Rules

```
✅ PASS    → 0 ⚠️, 0 ❌ (all scenarios COVERED)
⚠️ PARTIAL → ≥1 ⚠️, 0 ❌ (some partial, none missing/violation)
❌ FAIL    → ≥1 ❌ (at least one MISSING or VIOLATION)
```

## Important Notes

- **Pipeline Integration:** This report is read by CI/CD and PR automation. Schema violations break integration.
- **QA Clarity:** Severity column is for humans. Use plain language, not jargon.
- **No Fixes:** Report findings only. Do NOT suggest code improvements.
- **Final Output:** This is the ONLY thing consumers see. Accuracy critical.
