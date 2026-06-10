# Coaching Agent — Learning Log

This file is the persistent memory for the Coaching Agent (`/coaching-agent`).
Update it **after every execution**. Keep entries append-only; newest at the top.

---

## Execution History

| Date | Total | Passed | Failed | Skipped | Pass Rate (executed) | Notes |
|------|-------|--------|--------|---------|----------------------|-------|
| 2026-06-10 | 22 | 17 | 0 | 5 | 100% (17/17) | First full run vs production. Driven via puppeteer-core/CDP on port 9222 (chrome-devtools MCP not connected). Account: umar.kabaili@yopmail.com. |

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

---

### How to update

After each `/coaching-agent` run:
1. Add a row to **Execution History** with the run stats.
2. Update **Previously Executed Scenarios** with each scenario's latest result.
3. Update **Pass / Fail Trends** if the trajectory changed.
4. Add any new recurring failure to **Common Failures**.
5. Record any newly discovered defect in **Known Baseline Assessment Issues**.
6. Append a one-paragraph entry to **Regression Summaries**.
