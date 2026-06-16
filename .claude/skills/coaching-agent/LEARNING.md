# Coaching Agent — Learning Log

This file is the persistent memory for the Coaching Agent (`/coaching-agent`).
Update it **after every execution**. Keep entries append-only; newest at the top.

---

## Execution History

| Date | Suite | Total | Passed | Failed | Skipped/NX | Notes |
|------|-------|-------|--------|--------|------------|-------|
| 2026-06-16 | Baseline | 22 | 1 | 0 | 21 | Verification-only re-run (completion-aware). Production, account: umar.kabaili@yopmail.com (Persona E, 3%). S18 ✅ COVERED; fresh evidence `runs/evidence/umar_kabaili-baseline-redirect.png`. Training NOT driven live this session (bundled driver is baseline-only); T10 module-gating VIOLATION from 2026-06-10 remains open. |
| 2026-06-16 | Baseline | 22 | 1 | 0 | 21 | Verification-only (completion-aware). Driver made **generic** — URL + account now sourced from SKILL.md, not hardcoded. Production, account: umar.kabaili@yopmail.com (Persona E, 37%). S18 ✅ COVERED. |
| 2026-06-10 | Baseline | 22 | 17 | 0 | 5 | First full run vs production. CDP port 9222. Account: umar.kabaili@yopmail.com. |
| 2026-06-10 | Training Flow | 15 | 5 | 1 | 9 | Staging (noor@yopmail.com). Completed Unit 1.1. **T10 module-gating VIOLATION found.** 2 partial, 7 not-executed (need destructive/logout setups). |

## Baseline Completion Registry

Machine-readable copy lives in [`baseline-completion.json`](baseline-completion.json) and is
**read at the start of every run**. If the logged-in user is marked completed here, the agent
runs **verification-only** (S18: confirm completed + confirm baseline is inaccessible/cannot be
retaken) and **skips the full baseline flow**, proceeding straight to the training section.
The driver updates both files automatically on submission (or when a live check reveals a
completed baseline that the cache had missed).

| User (email) | user_id | Baseline Completed | Persona | Score | Recorded | Source |
|--------------|---------|--------------------|---------|-------|----------|--------|
| umar.kabaili@yopmail.com | 66e67e8e-0ed9-4850-acb4-095a727a7f2e | ✅ YES | E | 37% | 2026-06-16 | production live run — dashboard Persona E / 37%; `/assessment/baseline` redirects to `/dashboard` (S18 ✅) |
| noor@yopmail.com | f1c8caeb-5f54-429d-96a1-edce436e46f7 | ✅ YES | E | 33% | 2026-06-12 | staging recon — dashboard Persona E / 33%; `/assessment/baseline` redirects to `/dashboard` |

> **Driver is now generic (2026-06-16):** the app URL and login account are read at runtime from
> SKILL.md (`## Application Under Test`) via `parseSkillConfig()` in [`runs/lib.mjs`](runs/lib.mjs).
> No account is hardcoded — change SKILL.md to retarget the agent to any app/account.

> **Completion-aware rule (baseline only):** never re-execute the full baseline flow for a user
> already in this registry. The cache is a fast path, not the source of truth — always perform the
> live S18 verification so a DB reset / stale cache is caught and corrected.

## Previously Executed Scenarios

| # | Scenario | Last Result | Last Run |
|---|----------|-------------|----------|
| 1 | View intro screen before starting assessment | PASS | 2026-06-10 |
| 2 | Start baseline assessment from intro screen | PASS | 2026-06-10 |
| 3 | Answer a question and navigate to next question | PASS | 2026-06-10 |
| 4 | Next button jumps to first unanswered question | PASS | 2026-06-10 |
| 5 | Navigate back to previous question and see saved answer | PASS | 2026-06-10 |
| 6 | Previous button is disabled on first question | PASS | 2026-06-10 |
| 7 | Progress bar and counter update as questions are answered | PASS | 2026-06-10 |
| 8 | Submit button appears only when all questions are answered | PASS | 2026-06-10 |
| 9 | Persona A (≥75%) | SKIPPED | 2026-06-10 |
| 10 | Persona B (≥70%, <75%) | SKIPPED | 2026-06-10 |
| 11 | Persona C (≥65%, <70%) | SKIPPED | 2026-06-10 |
| 12 | Persona D (≥60%, <65%) | SKIPPED | 2026-06-10 |
| 13 | Persona E (<60%) | PASS (3% → E) | 2026-06-10 |
| 14 | Auto-save progress to localStorage every 5 seconds | PASS | 2026-06-10 |
| 15 | Resume baseline from saved localStorage progress | PASS | 2026-06-10 |
| 16 | Tab switch detection triggers first warning | PASS | 2026-06-10 |
| 17 | Tab switch detection triggers second warning | PASS | 2026-06-10 |
| 18 | Cannot access baseline assessment if already completed | PASS | 2026-06-10 |
| 19 | Cannot submit baseline when questions are not all answered | PASS | 2026-06-10 |
| 20 | Submit button is disabled while submitting | PASS | 2026-06-10 |
| 21 | Cannot navigate to training modules without completing baseline | PASS | 2026-06-10 |
| 22 | Profile update fails during submission | SKIPPED | 2026-06-10 |

## Pass / Fail Trends

- 2026-06-10: First run — 0 failures across all 17 executable scenarios. Baseline flow healthy in production.

## Common Failures

- _(none observed yet)_

## Known Baseline Assessment Issues

- **Single-account / no-answer-key limitation:** Persona A–D (scenarios 9–12) cannot be verified end-to-end on one live account — only one baseline submission is allowed per user, and the correct-answer key is not exposed, so a specific target score/persona cannot be produced. Only the persona actually computed by a run is verifiable (this run: 3% → Persona E).
- **Irreversible completion:** Once submitted, baseline_completed=true permanently hides the assessment (scenario 18 confirmed). Re-running not-completed scenarios requires a fresh/unsubmitted account.
- **S22 not executable on prod:** "Profile update fails during submission" needs an induced DB write failure — cannot be simulated safely against production.

## Regression Summaries

- **2026-06-10:** Full @regression sweep of `baseline-assessment.feature` (22 scenarios) against production. 17 PASS, 0 FAIL, 5 SKIPPED. Intro, navigation, progress, save/resume, tab-switch anti-cheat, submit gating, completion lock, and the persona-E pipeline all behave per spec. Exact spec strings matched for tab-switch warnings and resume toast. Submission scored 3% → Persona E; dashboard correctly showed profile card, unlocked modules, and the "already completed → redirect to dashboard" guard. Skips were due to single-account/no-answer-key (personas A–D) and inability to induce a DB failure (S22).
- **2026-06-10 (Training Flow, staging, noor@yopmail.com):** First training-flow @regression run; completed **Unit 1.1** of Module 1 (7 slides → 2-situation practice, 2/2 100%). **5 PASS** (T2 slides→practice→complete chain, T4 sequential scenarios, T5 reload persistence, T7 practice-locked-while-slides-incomplete, T8 slides-alone ≠ complete) plus within-module sequential unlock (1.1 done → 1.2 unlocked, 1.3–1.6 stay locked; progress 2/25→3/25). **2 PARTIAL** (T6 no explicit message via stepper; T15 persistence observed but true disagreement not induced). **1 FAIL/VIOLATION** (T10: Module 2 Unit 2.1 accessible while Module 1 incomplete — module-level gating not enforced). **7 NOT EXECUTED** (need slides-only unit / mid-scenario abandon / logout-mid-unit / rapid-nav / out-of-order setups). Verdict: **FAIL** (per deterministic rule, ≥1 violation).

---

## Training Flow — Domain Knowledge

The teacher training journey begins **after** the baseline is completed (the baseline gate;
cross-checked by baseline S21). Key rules the agent validates:

- **Sequential modules:** training is organized into modules; modules must be completed in
  order. Module N+1 stays **locked** until module N is fully complete.
- **Sessions within a module:** each module has multiple training **sessions**. Per session,
  the order is fixed — **start → view all slides → (only then) practice test becomes available
  → attempt practice → session marked complete**. The next session unlocks only after the
  previous one is complete.
- **Module completion:** a module is complete only when **all** its sessions are complete; a
  **module-level practice test** must then be attempted **and passed**.
- **Access control:** locked trainings/modules are unreachable; slides gate the practice
  section; practice tests cannot be skipped; users cannot jump ahead.
- **Persistence & authority:** progress saves after every completed step; completion status
  updates correctly; on client/server disagreement the **server state is authoritative**.

## Training Flow — Scenario Status (`training-flow.feature`, 15 @regression)

| # | Scenario | Type | Last Result | Last Run |
|---|----------|------|-------------|----------|
| T1 | Complete training with only slides, no scenarios → can proceed | Positive | NOT EXECUTED (Unit 1.1 had practice; no slides-only unit this run) | 2026-06-10 |
| T2 | Complete slides → auto-navigate to practice → complete scenario → complete | Positive | PASS (Finish Slides→Practice 2 situations→2/2 100%→Unit 1.1 Passed) | 2026-06-10 |
| T3 | Complete slides, go to practice, return to slides → completion preserved | Positive | NOT EXECUTED (did not return to slides mid-flow) | 2026-06-10 |
| T4 | Complete training with three practice scenarios in sequence | Positive | PASS (analog: 2 situations completed in sequence; spec says 3, mechanism identical) | 2026-06-10 |
| T5 | Completion persists after closing browser & returning | Positive | PASS (fresh reload → Unit 1.1 still Passed; Progress 3/25 retained) | 2026-06-10 |
| T6 | Cannot access practice before completing slides (shows blocking message) | Negative | PARTIAL (practice tab greyed & non-clickable; explicit message string not surfaced via stepper) | 2026-06-10 |
| T7 | Practice section shown locked when slides incomplete | Negative | PASS ("Practice" step greyed/locked; click is a no-op until slides done) | 2026-06-10 |
| T8 | Cannot mark complete with only slides done when scenarios exist | Negative | PASS (Finish Slides moved to practice but did NOT complete unit; Passed only after practice) | 2026-06-10 |
| T9 | Navigate away mid-scenario & return → at practice, partial progress preserved | Negative | NOT EXECUTED (did not leave mid-scenario) | 2026-06-10 |
| T10 | Cannot access subsequent modules if current training incomplete | Negative | **FAIL / VIOLATION** (Module 2 Unit 2.1 opened to /training while Module 1 only 3/7 — module-level gating not enforced) | 2026-06-10 |
| T11 | After logout/session expiry, return → still in practice, slides still complete | Negative | NOT EXECUTED (no logout mid-unit) | 2026-06-10 |
| T12 | Only slides, zero scenarios → immediately complete | Edge | NOT EXECUTED (no slides-only unit this run) | 2026-06-10 |
| T13 | Rapid slide↔practice navigation → no state corruption | Edge | NOT EXECUTED (not stress-tested) | 2026-06-10 |
| T14 | Complete scenarios in different order than presented → all recorded | Edge | NOT EXECUTED (practice enforces fixed Situation 1→2 order; out-of-order not offered) | 2026-06-10 |
| T15 | Client/server completion disagreement → server state wins after refresh | Error | PARTIAL (fresh reload reflected persisted server state; true disagreement not induced) | 2026-06-10 |

**Core behavior (not a numbered T): Within-module sequential unlock — PASS.** Completing Unit 1.1
flipped Unit 1.2 from locked (`cursor:not-allowed`, opacity 0.6) to accessible (`cursor:pointer`);
Units 1.3–1.6 remained locked. Completion status (Not Started→Passed) and Progress (2/25→3/25) updated correctly.

> Excluded (not @regression — `@chunk` only, never run): "Revisit completed training to review
> content", "Server fails to save slide completion status", "Practice section unlocks
> inconsistently due to sync delay", "User encounters missing scenario content".

## Training Flow — Known Notes & Open Items

### UI selectors / facts mapped (2026-06-10, staging)
- **Dashboard:** training modules render as expandable cards (`div.cursor-pointer`, `onclick`),
  each with a `1/7`-style progress and a `›` chevron. Clicking a module **expands inline**
  (accordion) to reveal its **Units** + a **Module Quiz** ("Attempt Quiz" button). URL stays `/dashboard`.
- **Unit states (within an expanded module):** accessible unit row → `cursor:pointer`, opacity 1;
  **locked** unit row → `cursor:not-allowed`, opacity `0.6` (and contains a lock indicator).
  Status text per unit: `Passed` / `Not Started` / `In Progress`.
- **Unit (training session) page:** clicking an unlocked unit navigates to `/training/{uuid}`.
  Top shows a **"Slides → Practice"** stepper ("Practice" greyed until slides done).
- **Slides:** header "Slide X of 7"; `Previous` (disabled on slide 1) / `Next`; on the **last**
  slide the button becomes **"Finish Slides"** (NOT "Next").
- **Practice:** scenario MCQ, header "Situation X of N"; 4 answer options are `<button>`s
  (not radios); **"Check My Response"** is disabled until an option is selected; after checking,
  advance with **"Next Situation"**, then on the last situation **"See Results"**.
- **Results screen:** "Scenario Complete — You made the right call in N of N situations (XX%)"
  with per-situation feedback; buttons: `Dashboard`, `Try Again`, `Finish Training`.

### Open items
- **T6 exact message** ("Please complete all training slides before attempting the practice
  section.") was NOT surfaced by clicking the greyed Practice stepper — find the path/route that
  triggers it (e.g. direct URL to practice), or confirm the spec message exists in this build.
- **Module-quiz pass threshold** for module completion still unconfirmed (each module ends with
  a "Module Quiz" / "Attempt Quiz" — verify the pass requirement).
- **NOT-EXECUTED scenarios** (T1, T3, T9, T11, T12, T13, T14) need specific setups: a slides-only
  unit (T1/T12), mid-scenario abandon/return (T3/T9), logout mid-unit (T11), rapid nav (T13),
  out-of-order practice (T14 — UI currently enforces fixed order).

## Training Flow — Findings / Inconsistencies

- **[HIGH] T10 — Module-level sequential gating NOT enforced.** Spec (T10 + domain rule "Module
  N+1 stays locked until module N is fully complete") expects the next module to remain locked
  while the current is incomplete. Observed: with **Module 1 incomplete (3/7)**, **Module 2's
  Unit 2.1 opened to `/training/{uuid}`** (Slide 1 of 7) with no block or message. Only
  *within-module* unit sequencing is enforced (Unit 2.2/2.3 stayed locked). Module-to-module
  progression is open. *Reported as a discrepancy for the team — not a prescribed fix.*

---

### How to update

After each `/coaching-agent` run:
1. Add a row to **Execution History** with the run stats.
2. Update **Previously Executed Scenarios** with each scenario's latest result.
3. Update **Pass / Fail Trends** if the trajectory changed.
4. Add any new recurring failure to **Common Failures**.
5. Record any newly discovered defect in **Known Baseline Assessment Issues**.
6. Append a one-paragraph entry to **Regression Summaries**.
7. For **training-flow** runs, also update **Training Flow — Scenario Status** with each
   scenario's latest result, and record newly discovered selectors, messages, or pass
   thresholds under **Training Flow — Known Notes & Open Items**.
