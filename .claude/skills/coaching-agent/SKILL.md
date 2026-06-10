---
name: coaching-agent
description: Coaching Agent — validate and execute Baseline Assessment @regression scenarios from baseline-assessment.feature against the production app. Logs in first, runs only @regression scenarios, captures evidence, and generates a regression report. Trigger with /coaching-agent.
---

# Coaching Agent

Trigger: `/coaching-agent`

## Purpose

Validate and execute the **Baseline Assessment** `@regression` scenarios against the
live coaching platform: log in, drive the baseline flow, run only the
`@regression`-tagged scenarios from `baseline-assessment.feature`, record pass/fail,
capture evidence for failures, produce a regression report, and update `LEARNING.md`.

## Application Under Test

- **URL:** https://coaching-platform-production-43ff.up.railway.app/
- **Login email:** umar.kabaili@yopmail.com
- **Login password:** Umar@123!@#

> Log in **before** executing any tests.

## Scenario Source (Hard Boundary)

- **Only** file: `tests/features/baseline-assessment/baseline-assessment.feature`
- **Only** scenarios tagged `@regression` (22 total). All others are ignored — not run, not counted.

## Rules

1. Baseline Assessment should appear **only once** for a new user.
2. **Existing users must complete** the Baseline Assessment before proceeding.
3. Execute scenarios **only** from `baseline-assessment.feature`.
4. Run **only** scenarios tagged `@regression`. Ignore all others.

## Validation Areas

- Baseline visibility for new users
- Baseline completion flow
- Existing user restrictions
- Navigation after completion
- Data persistence after completion

## How to execute (live, via the browser)

Drive a real browser session — through the connected **chrome-devtools MCP**
(`/mcp`), or a headed Chrome on remote-debugging port 9222. No bundled scripts;
the agent performs these steps live and records what it observes.

**Browser facts learned (use these to drive the UI):**
- Login: fields are `input[type=email]` and `input[type=password]`; submit button text `Sign In`.
- After login an existing-but-incomplete user lands on `/dashboard` with a
  "Baseline Assessment Required" card and an "Attempt Baseline Assessment" button.
- Baseline lives at `/assessment/baseline`. Intro card → "Start Assessment" button.
- Questions: 30. Header shows "Question X of 30". Options are `[role=radio]`
  elements (`aria-checked` flips to `true` when selected). Counter text: "X of 30 answered".
- Navigation buttons by text: `Previous` (disabled on Q1), `Next`, and `Submit`
  (replaces Next only once all 30 are answered).
- Auto-save key: `assessment_baseline_{user_id}` in localStorage with fields
  `{ answers, currentIndex, timestamp }`; resume shows a "Resuming where you left off..." toast.
- Tab-switch warnings (dispatch `visibilitychange`/`blur`): #1 "Switching tabs is
  recorded during assessment.", #2 "Tab switching detected (2). This is recorded."

After a run, write the report (format below) and update `LEARNING.md`
(history, trends, known issues, summary).

## Execution Flow

1. Open the application; ensure headed Chrome on port 9222.
2. Log in with the provided credentials.
3. Navigate to `/assessment/baseline`.
4. Parse `baseline-assessment.feature`; select only `@regression` scenarios.
5. Execute each; record pass/fail.
6. Capture screenshots for failures.
7. Generate execution statistics + the report.
8. Append results to `LEARNING.md`.

## @regression Scenario Inventory (22)

Positive: (1) View intro (2) Start from intro (3) Answer & next (4) Next jumps to first
unanswered (5) Previous shows saved answer (6) Previous disabled on Q1 (7) Progress
updates (8) Submit appears only when all answered (9) Persona A ≥75% (10) Persona B
70–75% (11) Persona C 65–70% (12) Persona D 60–65% (13) Persona E <60% (14) Auto-save
every 5s (15) Resume from localStorage (16) Tab-switch warning #1 (17) Tab-switch warning #2.
Negative: (18) Cannot access if already completed (19) Cannot submit when not all answered
(20) Submit disabled while submitting (21) Modules locked without baseline (22) Profile update fails.

> The `@regression` tags in the feature file are the source of truth — re-derive at run time if the file changes.

## Known execution limits (see LEARNING.md)

- **Personas A–D (9–12):** not executable on a single live account — only one submission
  is allowed and the answer key isn't exposed, so a specific score can't be targeted.
  Only the persona actually computed by a run is verified (a default first-option run → Persona E).
- **S22:** requires inducing a DB write failure — not safe against production; cover at the unit/integration tier.

## Reporting Format

```
# Baseline Assessment Regression Report
Execution Date: <timestamp>
Total Regression Scenarios: X
Passed: X
Failed: X
Skipped: X

## Passed Scenarios
* <Scenario Name>
## Failed Scenarios
* <Scenario Name>
  * Failure Reason: <reason>
## Evidence
* <Logs / screenshot paths>
## Summary
* Pass Rate: XX%
* Key Findings: <...>
* Recommended Actions: <...>
```

## Restrictions

- Do **not** execute scenarios outside `baseline-assessment.feature`.
- Do **not** execute scenarios without the `@regression` tag.
- Always log in before testing.
- Always generate the report and update `LEARNING.md` after execution.
