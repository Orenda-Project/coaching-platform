# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

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
