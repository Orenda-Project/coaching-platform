---
name: coaching-agent
description: Coaching Agent — validate and execute @regression scenarios for the Baseline Assessment (baseline-assessment.feature) and the Module-Based Training Journey (training-flow.feature) against the app. Logs in first, runs only @regression scenarios (ignoring @smoke/@sanity/@wip/untagged), captures evidence, and generates a regression report. Trigger with /coaching-agent.
---

# Coaching Agent

Trigger: `/coaching-agent`

## Purpose

Validate and execute the **Baseline Assessment** `@regression` scenarios against the
live coaching platform: log in, drive the baseline flow, run only the
`@regression`-tagged scenarios from `baseline-assessment.feature`, record pass/fail,
capture evidence for failures, produce a regression report, and update `LEARNING.md`.

## Application Under Test

- **URL:** https://coaching-platform-staging.up.railway.app/
- **Login email:** noor@yopmail.com
- **Login password:** Umar@123!@#$

> Log in **before** executing any tests.

## Scenario Source (Hard Boundary)

- **Baseline:** `tests/features/baseline-assessment/baseline-assessment.feature` — 22 `@regression` scenarios.
- **Training Flow:** `tests/features/training-flow/training-flow.feature` — 15 `@regression` scenarios.
- **Only** scenarios tagged `@regression` are run. Explicitly **ignore** `@smoke`, `@sanity`,
  `@wip`, any untagged scenarios, and any other feature files — not run, not counted.
- Tags in the feature files are the source of truth — discover `@regression` scenarios at run time.

## Rules

1. Baseline Assessment should appear **only once** for a new user.
2. **Existing users must complete** the Baseline Assessment before proceeding.
3. Execute scenarios **only** from `baseline-assessment.feature`.
4. Run **only** scenarios tagged `@regression`. Ignore all others.

## Validation Areas

**Baseline Assessment:**
- Baseline visibility for new users
- Baseline completion flow
- Existing user restrictions
- Navigation after completion
- Data persistence after completion

**Training Flow (post-baseline):**
- Training unlock logic (sequential modules & sessions)
- Slide completion requirements (slides before practice)
- Practice test / scenario requirements (cannot be skipped)
- Module completion rules (all sessions done + module practice test passed)
- Progression & access control (no jumping ahead; locked content unreachable)
- Progress persistence & completion-status correctness (across navigation, logout, client/server sync)

## How to execute (live, via the browser)

Drive a real browser session. The canonical, reusable driver lives in
[`runs/lib.mjs`](runs/lib.mjs) (browser + login + helpers + learning store) and
[`runs/baseline-agent.mjs`](runs/baseline-agent.mjs) (completion-aware orchestrator).
(A connected chrome-devtools MCP, if present, may be used instead — but the
bundled driver is the default and is self-contained via the project's `puppeteer`.)

**Run modes:**

| Command | What it does |
|---------|--------------|
| `node runs/baseline-agent.mjs` | Configured account (noor). Completion-aware: verification-only (S18) + skip, since noor's baseline is already done. **Non-destructive.** |
| `node runs/baseline-agent.mjs --fresh` | Signs up a **throwaway** account and runs the **full** new-user baseline flow (S1–S8, S13–S17, S19–S21). **Destructive:** creates a staging user and submits a baseline. Records the new account's completion into `baseline-completion.json`. |
| `HEADLESS=1 node runs/baseline-agent.mjs [...]` | Same as above but headless (for CI / no display). |

### Headed mode (always-on)

- The browser **always launches in headed mode** (a visible Chrome window) so the
  run can be watched at all times. The window opens **immediately** as the first step.
- **Do not run headless** unless explicitly requested. The only opt-in is the
  `HEADLESS=1` environment variable (`HEADLESS=1 node runs/baseline-agent.mjs`).

### Fast startup (optimized)

The driver is tuned to become usable as quickly as possible:

- Launch the browser **first**, before any feature parsing or setup.
- Navigate with `waitUntil: 'domcontentloaded'` — **never** `networkidle2`.
- **No blanket `sleep()`s** for readiness — wait on the exact element/condition
  (`waitForSelector` / `waitText`). Login waits on the URL leaving `/login`, not a timer.
- Lean Chrome launch flags (`--no-first-run`, `--disable-background-networking`,
  `--disable-extensions`, `--disable-sync`, `--disable-component-update`, …) and
  `defaultViewport: null` (native window, no emulation overhead). Typing uses no delay.

**Browser facts learned (use these to drive the UI):**

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

## Baseline completion-aware execution (do not re-run a completed baseline)

The agent remembers which users have completed the baseline and **must not**
re-run the full baseline flow for them. Completion is cached in the learning
store [`baseline-completion.json`](baseline-completion.json) — a list of
`{ email, userId, baselineCompleted, persona, score, recordedAt, source }`.

**Required behaviour (baseline only):**

- Once a user completes the baseline, persist `baselineCompleted: true` for that
  user in `baseline-completion.json` (the driver does this automatically on submit).
- On every future run, **check learning first** before executing baseline scenarios.
- If the baseline is already completed for the logged-in user:
  - **Do not** execute the full set of baseline scenarios again.
  - **Only verify** that the baseline is completed and **inaccessible**:
    - verify completion status on the dashboard (persona/score profile card shown),
    - verify the baseline **cannot be re-accessed or retaken** — navigating to
      `/assessment/baseline` immediately redirects to `/dashboard` with no questions
      (this is scenario **S18**).
  - Mark the remaining baseline-flow scenarios `⏭️ SKIPPED` ("already completed").
  - **Immediately proceed to the training section.**
- If the baseline is **not** completed, execute the normal full baseline flow,
  and record completion when it is submitted.

> The learning cache is a fast path, **not** the source of truth: if learning says
> "completed" the agent still performs the live verification (S18) so a reset/stale
> cache is caught. If learning is empty/stale but the live check shows the baseline
> redirects, the agent records the completion and switches to verification-only.

**Expected flow (baseline):**

1. Check learning/history (`baseline-completion.json`) for the logged-in user.
2. Determine whether that user has already completed the baseline.
3. **If completed:** verify completion status → verify baseline cannot be retaken
   (S18) → skip baseline execution → continue to the next training module.
4. **If not completed:** execute the normal baseline assessment flow → record
   completion on submission.

## Execution Flow

1. **Launch a headed browser immediately** (visible window; `HEADLESS=1` to override).
2. Log in with the provided credentials (fast — waits on URL leaving `/login`).
3. **Check `baseline-completion.json`** for the logged-in user (completion-aware step).
4. **If baseline already completed →** run verification-only (S18: dashboard profile +
   `/assessment/baseline` redirect), mark the rest `SKIPPED`, then proceed to training.
5. **If not completed →** parse `baseline-assessment.feature`, select only
   `@regression` scenarios, and execute the full baseline flow; record completion on submit.
6. Capture screenshots for failures (and key states).
7. Generate execution statistics + the report.
8. Append results to `LEARNING.md` and update `baseline-completion.json`.

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

## Training Flow — Module-Based Training Journey

After the baseline is completed, the training program unlocks. The agent must understand
and validate the full progression workflow below, then run only the `@regression`
scenarios in `training-flow.feature`.

### Domain model (progression rules to validate)

1. **Baseline gate** — the user first completes the baseline; only then does the training
   program become available. (Cross-checked by baseline scenario S21.)
2. **Module-based, sequential** — training is organized into modules; modules must be
   completed in order. Module N+1 stays locked until module N is fully complete.
3. **Within a module** — each module contains multiple training **sessions**. For every session:
   1. User starts the training.
   2. Scenario-based **slides** are displayed first.
   3. User must complete **all** slides.
   4. Only after slides are complete does the **practice test / scenario** become available.
   5. User must attempt the practice test.
   6. The session is marked complete **only after** the practice test is completed.
   7. The next session unlocks **only after** the previous session is completed.
4. **Module completion** — a module is complete only when **all** its sessions are complete.
   At the end of every module a **module-level practice test** is available; the user must
   attempt **and pass** it for the module to count as complete.
5. **Progression / access control** — the agent must confirm:
   - Locked trainings cannot be accessed.
   - Slides must be completed before practice becomes available.
   - Practice tests cannot be skipped.
   - Users cannot jump ahead to future trainings or modules.
   - Progress is saved correctly after every completed step.
   - Completion status updates correctly (and the **server state is authoritative** on client/server disagreement).

### Training-flow `@regression` scenario inventory (15)

*Positive:* (T1) Complete training with only slides, no scenarios → can proceed; (T2) Complete
slides → auto-navigate to practice → complete scenario → training complete; (T3) Complete slides,
go to practice, return to slides → slide completion preserved; (T4) Complete training with three
practice scenarios in sequence; (T5) Completion persists after closing browser & returning.
*Negative:* (T6) Cannot access practice before completing slides (message: "Please complete all
training slides before attempting the practice section."); (T7) Practice section shown locked when
slides incomplete; (T8) Cannot mark complete with only slides done when scenarios exist (module not
submittable); (T9) Navigate away mid-scenario & return → land at practice, partial progress preserved;
(T10) Cannot access subsequent modules if current training incomplete (next module locked + message);
(T11) After logout/session expiry, on return still in practice section with slides still complete.
*Edge:* (T12) Only slides, zero scenarios → immediately complete; (T13) Rapid slide↔practice
navigation → no state corruption, practice accessible after slide completion; (T14) Complete scenarios
in different order than presented → all recorded regardless of order.
*Error:* (T15) Client/server completion disagreement → after refresh, authoritative server state wins
(shows complete).

> **Excluded** (not `@regression`, do not run): "Revisit completed training to review content",
> "Server fails to save slide completion status", "Practice section unlocks inconsistently due to
> sync delay", "User encounters missing scenario content" — these are `@chunk`-only.

### Training-flow execution flow

1. Ensure logged in and baseline **completed** (training only unlocks post-baseline).
2. Open the dashboard; locate the first/active module and its training sessions.
3. Discover `@regression` scenarios in `training-flow.feature` at run time (filter by tag).
4. For each scenario, validate the matching rule: unlock logic → slide gating → practice
   requirement → module completion → access control → persistence.
5. Record pass/fail; capture screenshots for failures; report gaps/inconsistencies.
6. Append results to `LEARNING.md`.

> **UI selectors for the training module are not yet mapped** (only the baseline UI has been
> driven so far). On the first training run, discover and record the relevant selectors
> (module/session list, slide viewer, "mark complete"/next-slide control, practice unlock state,
> locked-item indicators, completion badges) into `LEARNING.md` for reuse.

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

- Do **not** execute scenarios outside the two in-scope feature files
  (`baseline-assessment.feature`, `training-flow.feature`).
- Do **not** execute scenarios without the `@regression` tag. Explicitly ignore
  `@smoke`, `@sanity`, `@wip`, and untagged scenarios.
- Always log in before testing.
- Always generate the report and update `LEARNING.md` after execution.
