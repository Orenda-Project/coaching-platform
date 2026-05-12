---
name: mapping-code-to-scenarios
description: Use when validating IDD scenarios - map each scenario's steps to specific implementation locations in scope-bounded source files
---

# Mapping Code to Scenarios

## Overview

For each scenario extracted by gherkin-parser, find the implementing code within scope-bounded files. Every mapping must cite exact file, function, and line number — or explicitly declare no evidence.

## When to Use

- Third step in IDD validation pipeline
- After scope-resolver has established the boundary
- Before scenario-validator classifies coverage

## Core Process

### For Each Scenario

**Step 1: Find Entry Point**

Scan the scenario's "When" steps to identify the action being tested.

Match to:
- API route handler (views.py, urls.py)
- React component event handler
- Service function
- Celery task

**Step 2: Trace Execution Path**

Within scope only:
- Identify entry function/handler
- Trace called functions (within scope)
- Map each Given/When/Then step to a code location
- Stop at scope boundary (mark path as "UNRESOLVABLE — requires external code")

**Step 3: Record Mapping**

```json
{
  "scenario": "Scenario name",
  "entry_point": {
    "file": "apps/auth/views.py",
    "function": "login_view",
    "line": 45
  },
  "step_mappings": [
    {
      "step": "Given a registered user with phone '03001234567'",
      "file": "apps/users/models.py",
      "function": "User.objects.get",
      "line": 23,
      "evidence": "QuerySet filter by phone"
    }
  ],
  "unresolvable_paths": ["core/permissions.py → outside scope"]
}
```

## Hard Constraints

- No guessing — if code not found in scope, evidence = NONE
- No transitive analysis — stop at scope boundary
- No prior knowledge — only code in the indexed scope
- Every mapping must cite file + function + line OR explicitly state no evidence
- Scenario isolation — mapping one scenario cannot assume mappings from another

## Output

Per-scenario code mapping with exact evidence for each Given/When/Then step.
