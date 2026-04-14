# Glossary

## Assessment & Evaluation

**Assessment** — A set of questions designed to evaluate user knowledge or competency.

**Baseline Assessment** — Initial assessment taken at platform signup (60% pass threshold). Assigns persona and identifies weak modules.

**Endline Assessment** — Final assessment taken after completing all assigned modules (70% pass threshold). Awards certificate on pass.

**Module Quiz** — Per-module checkpoint assessment (80% pass threshold). Must be passed to unlock next module. Max 3 attempts per module.

**Persona** — User's coaching skill level assigned after baseline: A (advanced), B (proficient), C (developing), D (beginning).

**Weak Module** — Module where user scored <70% on baseline assessment. Required for completion before endline.

**MCQ** — Multiple choice question with A/B/C/D options. Used in all assessments.

**Open-Ended Question** — Free-form text question (endline only). Ungraded but saved for review.

---

## Learning Content

**Training / Training Unit** — A coaching module containing learning content (slides, videos, scenarios).

**Module** — Top-level grouping of trainings (e.g., "Module 2: Partnership Foundation"). Can be mandatory or persona-specific.

**Training Content** — Individual pieces of content within a training: slides, videos, audio, scenarios.

**Scenario** — A situation-based learning prompt where user makes a decision, then receives feedback and optional deeper learning (Phase 1 feature).

**Feedback Slide** — Carousel slide shown after user decides in a scenario, explaining the reasoning.

**Content Gate** — Prerequisite that must be met before quiz unlocks: 90% video watch OR 30 seconds on slides.

**Persona-Targeted Module** — Module only shown to users with matching persona. Module 1 is mandatory (shown to all).

---

## User Progress & Status

**Progress** — User's completion status for a training: percentage watched, quiz score, passed/failed.

**Passed** — Training quiz score ≥80%, or scenario scenario flow completed with correct answer.

**Failed** — Training quiz score <80%, or scenario answered incorrectly.

**Attempt Count** — Number of times user has taken a quiz or assessment. Max 3 attempts for module quizzes.

**Certificate** — Digital certification issued on endline pass. ID format: `CC-{timestamp}-{RAND4}`.

**Dashboard** — Home screen showing user's assigned modules, progress, and next steps.

---

## System Components

**Profile** — User account data: email, name, school_id, persona, baseline/endline scores, weak modules, region.

**Region** — Geographic grouping of users (e.g., city, district). Hierarchical with parent_id self-reference (Phase 2).

**RLS / Row-Level Security** — Supabase feature that restricts data access by role (admin, user, regional_admin).

**Analytics Event** — Tracked user action (scenario viewed, decision submitted, slide read, etc.). Stored for reporting.

---

## Roles & Access

**Admin** — System administrator with full access to content management and user data.

**User** — Coach participating in training. Can take assessments, view modules, earn certificates.

**Regional Admin** — Regional manager (Phase 2). Can manage coaches within their region.

---

## Technical Terms

**Supabase** — Backend platform providing PostgreSQL database, authentication, real-time updates, RLS.

**Migration** — Database schema change file (SQL). Applied sequentially to evolve schema.

**Fire-and-Forget** — Asynchronous operation that doesn't wait for completion or error handling.

**State Machine** — Component logic using distinct phases that transition based on conditions (e.g., ScenarioFlow: loading → scenario → feedback → reveal → depth → summary).

**localStorage** — Browser storage for client-side data persistence (e.g., assessment progress auto-save).

**Tab-Switch Detection** — Monitoring for user switching browser tabs during quiz (anti-cheat).

---

## Performance & Optimization

**Code Splitting** — Breaking app bundle into smaller chunks loaded on-demand (future optimization).

**Materialized View** — Pre-computed query result in database for fast aggregations (used for analytics dashboards).

**Indexing** — Database optimization that speeds up queries on frequently-filtered columns (e.g., scenarios.unit_id).

---

## Processes

**PR / Pull Request** — Code change proposal on GitHub, reviewed before merge to main.

**CI/CD** — Continuous Integration/Deployment: automated tests and deployment on code changes.

**E2E Testing** — End-to-end test covering full user flow (signup → baseline → modules → endline → certificate).

**Staging** — Pre-production environment for QA testing before production release.

**Production** — Live environment where real users interact with the platform.

---

## Key Thresholds

| Item | Threshold |
|------|-----------|
| Baseline Pass | 60% |
| Module Quiz Pass | 80% |
| Endline Pass | 70% (MCQ only) |
| Weak Module Detection | <70% per module on baseline |
| Content Gate (Video) | 90% watched |
| Content Gate (Slides) | 30 seconds |
| Persona A | 75%+ baseline |
| Persona B | 70-74% baseline |
| Persona C | 65-69% baseline |
| Persona D | 60-64% baseline |
| Module Quiz Max Attempts | 3 |
| Tab Switches Flagged | 3+ during quiz |

---

**Last Updated:** 2026-04-14
