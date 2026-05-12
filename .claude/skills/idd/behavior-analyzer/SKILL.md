---
name: analyzing-actual-behavior
description: Use when IDD scenario is not COVERED - trace code line-by-line to find what the code ACTUALLY does, not what it should do
---

# Analyzing Actual Behavior

## Overview

For every non-COVERED scenario (PARTIAL, MISSING, VIOLATION), trace execution to discover what the code actually does. Never infer, never guess — trace and document.

## When to Use

- Fourth step in IDD validation pipeline
- Only for scenarios where coverage is not ✅ COVERED
- Skip for ✅ COVERED scenarios (they have full evidence already)

## Core Process

### For MISSING Scenarios

```
Trace:
  • Does the endpoint/function exist? → 404 or stub?
  • If stub exists: what does it return? (null, empty, error?)
  • What actually happens when called?

Document:
  actual_behavior: "Endpoint GET /api/X returns 404 — not implemented"
  OR
  actual_behavior: "Function exists but returns None → caller crashes with TypeError"
```

### For PARTIAL Scenarios

```
Trace:
  • Which Given/When/Then steps ARE implemented? (cite lines)
  • At which step does execution fail or stop?
  • What is the last successful operation?
  • What happens at the gap?

Document:
  actual_behavior: "Input validated ✓ (line 23), request sent ✓ (line 31), response handler missing ✗ → button stuck in loading state"
```

### For VIOLATION Scenarios

```
Trace:
  • Where in the execution path can the forbidden behavior occur?
  • What specific condition triggers it?
  • Is there a guard? Can the guard be bypassed?
  • What is the exact line of the vulnerability?

Document:
  actual_behavior: "Line 63: `if expiry_time < now()` accepts OTP at exact expiry moment (off-by-one: < should be <=)"
```

### Recording Format

```json
{
  "scenario_name": "Exact name from feature file",
  "status": "❌ MISSING | ⚠️ PARTIAL | ❌ VIOLATION",
  "actual_behavior": "Specific description of what code does",
  "root_cause": "Exact line or missing code that causes the behavior",
  "code_location": "file: path/to/file.py | function: name | line: N",
  "impact": "What the user experiences (plain language)"
}
```

## Hard Constraints

- Trace actual code, never infer from structure or naming
- Missing code still has actual behavior — trace it (404? null? crash?)
- Prove violations with exact line numbers, not speculation
- Impact must be user-facing (what they experience, not technical jargon)

## Output

Actual-behavior records for all non-COVERED scenarios, ready for report-formatter.
