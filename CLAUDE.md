# Coaching Platform — Taleemabad MVP Prototype
# Built: 2026-04-08 | Stack: React + TypeScript + Supabase + Tailwind

## Mandatory SDLC Behavior

For every feature, bug fix, refactor, architecture change, API change, database change, UI change, test change, or deployment-related change, follow the SDLC workflow defined in:

`.claude/rules/sdlc-workflow.md`

Before editing code:

1. Classify the task as FEATURE, BUG_FIX, REFACTOR, ARCHITECTURE, TESTING, or DEPLOYMENT.
2. Provide the required SDLC response format.
3. Explain affected files and risks.
4. Wait for user approval before making code changes unless the user explicitly says to implement directly.

## Branch Workflow (Hard Rule)

- All work must be done in feature branches (`feature/<descriptive-name>`)
- Create PRs to staging — never merge without user permission
- Never push directly to main or staging
- Never force-push to main or staging

## Workflow Commands

Use these commands when appropriate:

- `/feature` for new feature work
- `/fix` for bug fixes
- `/review` for code review
- `/pr` for pull request preparation
- `/postmortem` for issue analysis after a bug or incident
- `/sdlc-workflow` for explicit SDLC analysis on any task

---

## Autonomous Workflow System (Auto-runs every session)

This project uses a deterministic workflow routing system. See `AUTONOMOUS_WORKFLOW_SYSTEM.md` for full details.

**SESSION START (automatic):**
1. Read this file (CLAUDE.md)
2. Read `WORKFLOW_QUICK_REFERENCE.md` for trigger words
3. Read `docs/memory/` files (patterns, bugs, qa-risks, review-findings)
4. Greet with status snapshot
5. Ask what to focus on

**ROUTING TABLE (deterministic dispatch):**

| Trigger | Workflow | What to read |
|---------|----------|-------------|
| `/coaching-dev` OR "implement/build/add feature" | Feature Dev | `docs/memory/patterns.md` |
| `/coaching-bugfix` OR "fix bug/broken/not working" | Bug Fix | `docs/memory/bugs.md` |
| `/coaching-qa` OR "test this/QA/verify" | QA | `docs/memory/qa-risks.md` |
| `/coaching-review` OR "review this/code review" | Code Review | `docs/memory/review-findings.md` |

**WORKFLOW CHAINING:**
- Dev completes → "Run QA?" → if yes, QA runs → "Code review?" → if yes, review runs
- Bugfix completes → "Run QA to verify?" → if yes, QA runs → "Code review?" → if yes, review runs
- QA and Review: no chaining, end with memory update only

**MEMORY UPDATE PROTOCOL:**
After each workflow, check if anything NEW was learned. If yes, append ≤5 bullets to:
- Dev: `docs/memory/patterns.md`
- Bugfix: `docs/memory/bugs.md`
- QA: `docs/memory/qa-risks.md`
- Review: `docs/memory/review-findings.md`

Never write: code, transcripts, stacks. Save: pattern/rule only.

---

## 🚨 Team Development Standards (READ FIRST!)

**ALL work must follow these rules:**
1. ✅ Work in feature branches (never push to main directly)
2. ✅ Create PRs (no direct merges to staging/main)
3. ✅ Run E2E tests before merging (signup → baseline → modules → endline → certificate)
4. ✅ Use staging environment first (staging → main, never skip)

**See:** `DEVELOPMENT_STANDARDS.md` (complete standards)

## Key Business Rules (Never Break)
- **Baseline Assessment & Gating (CRITICAL):**
  - Scoring: 60% to pass. <60% = fail, retry. Persona: A(≥75%) B(70%) C(65%) D(60%)
  - **Gating Logic:** New users see ONLY baseline assessment (training modules hidden/disabled until completed)
  - **Access Control:** After baseline completion, baseline is hidden permanently (cannot re-access or re-attempt)
  - **Unlock:** Training modules unlock only after baseline_completed = true
- Module quiz: 80% to pass. Max 3 attempts. Fail = retry same module.
- Endline: 70% to pass. Gate: ALL modules must be passed first (server-verified).
- Content gate: Video 90% watched OR slides 30s before quiz unlocks.
- Sequential unlock: sorted by order_number, N-1 must be passed before N.
- Module 1 (is_common=true) = shown to all. Other modules = persona_required match.
- Certificate: upsert on conflict user_id. ID = CC-{timestamp}-{RAND4}
- Anti-cheat: tab-switch detection in quiz, 3+ = flagged for admin review.

## Architecture & Deployment Docs (Always Read Before Touching Code)
- `/Users/mac/Desktop/data/personal assistant/agents/coaching-platform-complete-plan.md` — Full system design
- `/Users/mac/Desktop/data/personal assistant/agents/coaching-platform-owner.md` — Domain expert agent
- `PROJECT_MAP.md` — Codebase map and known issues
- `DEPLOYMENT.md` — Staging → Production branching & deployment strategy
- `ENVIRONMENT_SUMMARY.md` — Quick reference: GitHub branches, Railway projects, Supabase DBs
- `SETUP_CHECKLIST.md` — Step-by-step staging/production infrastructure setup

## Autonomous Workflow System Files (NEW)
- `AUTONOMOUS_WORKFLOW_SYSTEM.md` — Full architecture & design decisions
- `WORKFLOW_QUICK_REFERENCE.md` — Daily quick reference (trigger words, what each workflow does)
- `docs/memory/patterns.md` — Dev patterns from prior sessions
- `docs/memory/bugs.md` — Bug learnings from prior sessions
- `docs/memory/qa-risks.md` — QA failure scenarios from prior sessions
- `docs/memory/review-findings.md` — Code review anti-patterns from prior sessions

## What Was Fixed in v2 (2026-04-08) vs coach-cert base
- Module locking uses order_number (not array index)
- Endline gate is server-verified (not just client CTA check)
- Certificate uses upsert (handles retakes without crash)
- Video: 90% watch gate + progress display (not just onEnded)
- Anti-cheat: tab-switch detection + flagging
- Attempt count tracking (max 3 per module)
- Baseline/endline attempt counts tracked
- Persona <60% = explicit fail + retry (was undefined)
- New migration: 20260408000001_coaching_platform_v2.sql

---

## Commands

```bash
npm run dev          # Start dev server (Vite) — uses .env.local if present
npm run build        # Production build
npm run build:dev    # Development build
npm run lint         # ESLint checks
npm run test         # Run Vitest
npm run test:watch   # Vitest in watch mode
npm run preview      # Preview production build
```

## Local Development

Requires Docker Desktop running.

```bash
supabase start       # Start local Supabase, applies all migrations automatically
supabase stop        # Stop containers (preserves data)
supabase db reset    # Wipe and re-apply all migrations
supabase status      # Show URLs and keys
```

Create `.env.local` to point at local Supabase (overrides `.env` automatically):
```
VITE_SUPABASE_URL=http://127.0.0.1:54321
VITE_SUPABASE_PUBLISHABLE_KEY=<key from supabase start output>
```

## Environment-Specific URLs

**Local development:**
- App: `http://localhost:5173`
- Supabase: `http://127.0.0.1:54321`

**Staging (Railway):**
- App: see ENVIRONMENT_SUMMARY.md
- DB: `agziuwqpkfmxtospfxns` (Supabase staging project)

**Production (Railway):**
- App: see ENVIRONMENT_SUMMARY.md
- DB: `agziuwqpkfmxtospfxns` (Supabase production project)

## Session End

1. Append summary to session log (created automatically in `docs/` if needed)
2. Update carry-overs in relevant domain
3. Memory files auto-update when workflows complete
