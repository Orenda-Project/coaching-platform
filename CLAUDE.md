# Coaching Platform — Taleemabad MVP Prototype
# Built: 2026-04-08 | Stack: React + TypeScript + Supabase + Tailwind

## Slash Commands for This Project
- `/coaching-dev` — implementing features
- `/coaching-review` — code review
- `/coaching-bugfix` — bug fixing
- `/coaching-qa` — QA testing

## Key Business Rules (Never Break)
- Baseline: 60% to pass. <60% = fail, retry. Persona: A(≥75%) B(70%) C(65%) D(60%)
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

Local services: Studio at http://127.0.0.1:54323 · Mailpit at http://127.0.0.1:54324

**To make a user admin locally** — run in Studio SQL Editor:
```sql
INSERT INTO public.user_roles (user_id, role)
SELECT id, 'admin' FROM auth.users WHERE email = 'your@email.com'
ON CONFLICT DO NOTHING;
```

## Environments

| Env | Supabase URL | Config file |
|---|---|---|
| Local | `http://127.0.0.1:54321` | `.env.local` |
| Production | `https://rdvylrymblwcwnfpjkyw.supabase.co` | `.env` |

## Architecture

**Stack:** React 18 + TypeScript, Vite/SWC, Supabase (PostgreSQL + Auth), Tailwind CSS, shadcn-ui (Radix), React Router v6, React Query, React Hook Form + Zod, Sonner toasts.

**Purpose:** A coaching certification platform where teachers take baseline assessments, complete persona-targeted training modules with quizzes, then take endline assessments to earn certificates.

### Routing (`src/App.tsx`)

```
/                    → Landing
/login, /signup, /reset-password
/dashboard           → Module list + progress (protected)
/assessment/:type    → "baseline" or "endline" assessment (protected)
/training/:id        → Training module viewer + quiz (protected)
/certificate         → Certificate display (protected)
/admin               → Admin panel (protected + admin role required)
  /admin/modules
  /admin/modules/:moduleId/units
  /admin/units/:unitId/content
  /admin/baseline-questions
  /admin/quiz-questions
```

Protected routes use `<ProtectedRoute>` (checks `AuthContext`). Admin routes additionally call `useAdminRole()` which queries the `user_roles` table.

### State Management

- **AuthContext** (`src/contexts/AuthContext.tsx`) — holds `session`, `user`, `profile`, and auth methods. Syncs via Supabase `onAuthStateChange`.
- **React Query** — configured in `App.tsx`, used for async data fetching.
- Local `useState` for UI state (forms, loading, question index, answers).

### Supabase Integration (`src/integrations/supabase/`)

- `client.ts` — Supabase client using `VITE_SUPABASE_URL` and `VITE_SUPABASE_PUBLISHABLE_KEY`
- `types.ts` — Auto-generated database types (do not edit manually)

**Key tables:** `profiles`, `trainings`, `modules`, `training_content`, `training_progress`, `assessments`, `questions`, `options`, `certificates`, `user_roles`

**Pattern:** Queries are chained Supabase calls (`.from().select().eq()`). Options/relationships are loaded in separate queries, not via joins. Errors surface as Sonner toasts.

### Persona System

Users are assigned a persona (A/B/C/D) stored on `profiles.persona`. Trainings are targeted to specific personas — the dashboard filters visible modules accordingly.

### Admin Flow

Admin users (identified by `user_roles` table) can manage modules, units, unit content, and quiz/baseline questions via the `/admin` routes. All admin mutations use Supabase CRUD with confirmation dialogs before deletions.
