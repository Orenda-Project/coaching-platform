# PROJECT_MAP.md

> Senior Architect Reference — Coach-Cert Platform (Taleemabad)
> Generated: 2026-03-17

---

## 1. Executive Summary

**What it is:** A coaching certification web app for teachers. Users register, take a baseline MCQ assessment to get assigned a *persona* (A–D), complete persona-targeted training modules with quizzes, then take an endline assessment to earn a downloadable PDF certificate.

**Stack:** React 18 + TypeScript · Vite 5/SWC · Supabase (PostgreSQL + Auth + Storage) · Tailwind CSS · shadcn-ui (Radix) · React Router v6 · TanStack React Query · React Hook Form + Zod · Sonner toasts · Vitest

---

## 2. Module / Directory Overview

```
coach-cert/
├── public/                     Static assets
├── supabase/
│   ├── config.toml             Project config (project ID: rdvylrymblwcwnfpjkyw)
│   └── migrations/             Ordered SQL migrations (source of truth for schema)
│       ├── 20260211195115_*    Initial schema (all core tables + RLS + triggers)
│       ├── 20260218113125_*    user_roles table + has_role() function
│       ├── 20260219061142_*    Admin write RLS policies on assessments/questions/options/content
│       └── 20260220060108_*    modules table + trainings.module_id FK + training-videos storage bucket
├── src/
│   ├── main.tsx                React DOM entry point
│   ├── App.tsx                 Router tree + global providers
│   ├── index.css               Design tokens (CSS vars), fonts, persona badge classes
│   ├── App.css                 Minimal resets
│   ├── vite-env.d.ts           Vite env type shim
│   │
│   ├── contexts/
│   │   └── AuthContext.tsx     Auth state: session, user, profile. signUp/In/Out, refreshProfile.
│   │
│   ├── hooks/
│   │   ├── useAdminRole.ts     Queries user_roles for "admin" role; returns { isAdmin, loading }
│   │   ├── use-mobile.tsx      Responsive breakpoint detection
│   │   └── use-toast.ts        Shadcn toast hook (re-exported from components/ui)
│   │
│   ├── integrations/supabase/
│   │   ├── client.ts           Supabase client singleton (VITE_SUPABASE_URL + KEY)
│   │   └── types.ts            Auto-generated DB types — DO NOT EDIT MANUALLY
│   │
│   ├── lib/
│   │   └── utils.ts            cn() = clsx + tailwind-merge
│   │
│   ├── pages/
│   │   ├── Index.tsx           Landing page; redirects authenticated users to /dashboard
│   │   ├── Login.tsx           Email/password sign-in + forgot-password (same component, forgotMode state)
│   │   ├── Signup.tsx          Registration: full_name, email, phone, password
│   │   ├── ResetPassword.tsx   Handles PASSWORD_RECOVERY auth event; calls updateUser({ password })
│   │   ├── Dashboard.tsx       Main learner hub — modules, progress, CTAs (see §4)
│   │   ├── Assessment.tsx      Baseline & endline MCQ flow — scoring, persona assignment (see §5)
│   │   ├── TrainingModule.tsx  Two-phase: content viewer → quiz (see §6)
│   │   ├── Certificate.tsx     Shows certificate card; generates and prints PDF via window.print()
│   │   ├── NotFound.tsx        404 catch-all
│   │   └── admin/
│   │       ├── AdminLayout.tsx         Sidebar shell; guards with useAdminRole(); renders <Outlet />
│   │       ├── AdminModules.tsx        CRUD for modules table (ordered list)
│   │       ├── AdminModuleUnits.tsx    CRUD for trainings within a module
│   │       ├── AdminUnitContent.tsx    Upload video (Supabase storage) or add URL for training_content
│   │       ├── AdminBaselineQuestions.tsx  Editor for baseline assessment questions + options
│   │       ├── AdminQuizQuestions.tsx  Editor for training-type assessment questions + options
│   │       ├── AdminTrainings.tsx      ⚠️ LEGACY — not registered in App.tsx router
│   │       └── AdminTrainingContent.tsx ⚠️ LEGACY — not registered in App.tsx router
│   │
│   ├── components/
│   │   ├── ProtectedRoute.tsx  Redirects to /login if no session; shows spinner while loading
│   │   ├── ModuleCard.tsx      Unit card with status icon (not_started/in_progress/passed/failed) + lock state
│   │   ├── PersonaBadge.tsx    Colored badge for A/B/C/D personas; size variants sm/md/lg
│   │   ├── NavLink.tsx         Router-aware nav link with active styling
│   │   ├── training/
│   │   │   └── TrainingContentViewer.tsx  Renders video (<video>) or slides (<iframe>); gates completion
│   │   └── ui/                 shadcn-ui components — generated, do not hand-edit
│   │
│   └── test/
│       ├── setup.ts            Vitest setup
│       └── example.test.ts     Placeholder test
```

---

## 3. Database Schema

### Tables & Relationships

```
modules ──────────────────────────────────────────────────────┐
  id, title, description, desired_outcomes, competencies,      │
  is_mandatory, order_number                                   │
                                                               │ module_id FK
trainings ────────────────────────────────────────────────────┘
  id, title, description, main_concepts,
  is_common (bool), persona_required (A/B/C/D),
  order_number, module_id

training_content  (1 training → many content items)
  id, training_id FK, format_type (slide|audio|video), content_url

training_progress (1 per user+training, UNIQUE constraint)
  id, user_id FK, training_id FK, score, passed, completed_at

assessments  (baseline/endline are standalone; training type links to a training)
  id, type (baseline|endline|training), training_id FK (nullable), persona_target, title

questions  (1 assessment → many questions)
  id, assessment_id FK, question_type (mcq|open), question_text,
  correct_answer, max_score, order_number

options  (1 question → many options, usually 4)
  id, question_id FK, option_text, is_correct

profiles  (1 per auth.users — auto-created by trigger on_auth_user_created)
  id FK → auth.users, phone (UNIQUE), full_name, persona (A/B/C/D),
  baseline_score, baseline_completed, endline_score, endline_completed

certificates  (1 per user — UNIQUE on user_id)
  id, user_id FK, certificate_id (CC-{timestamp}-{random}), issued_at, persona

user_roles
  id, user_id, role (app_role enum: admin|user)
```

### Key DB Functions & Triggers

| Name | Purpose |
|---|---|
| `on_auth_user_created` | Auto-inserts `profiles` row on new user registration |
| `update_profiles_updated_at` | Keeps `profiles.updated_at` current |
| `update_modules_updated_at` | Keeps `modules.updated_at` current |
| `has_role(user_id, role)` | Security-definer fn used in RLS policies for admin writes |

### RLS Summary

| Table | Read | Write |
|---|---|---|
| `profiles` | Own row only | Own row only |
| `trainings` | Any authenticated | Admin only (insert/update/delete) |
| `training_content` | Any authenticated | Admin only |
| `training_progress` | Own rows only | Own rows only |
| `assessments` | Any authenticated | Admin only |
| `questions` | Any authenticated | Admin only |
| `options` | Any authenticated | Admin only |
| `certificates` | Own row only | Own row only |
| `user_roles` | Own row only | — (set manually in DB) |
| `modules` | Any authenticated | Admin only |

### Storage

| Bucket | Public | Max Size | MIME Types |
|---|---|---|---|
| `training-videos` | Yes | 500 MB | mp4, webm, ogg, quicktime, avi |

---

## 4. Data Flow

### 4a. Authentication Flow

```
Signup form
  → signUp(email, password, phone, fullName)
  → supabase.auth.signUp()                    [creates auth.users row]
  → trigger on_auth_user_created              [inserts profiles row, phone = email if no phone]
  → supabase.from("profiles").update(...)     [sets full_name, phone from form]
  → onAuthStateChange fires → fetchProfile()  [caches profile in AuthContext]
  → navigate("/dashboard")
```

### 4b. Baseline Assessment Flow

```
/assessment/baseline
  → load assessments WHERE type='baseline' LIMIT 1
  → load questions WHERE assessment_id=X ORDER BY order_number
  → load options WHERE question_id IN (question_ids)
  → user answers all questions (one per screen)
  → handleSubmit():
      score = correct_answers / total_questions * 100
      if score < 60% → show fail toast, reset, stay on page
      if score >= 60%:
          persona = A(≥75%) | B(≥70%) | C(≥65%) | D(else)
          supabase.profiles.update({ persona, baseline_score, baseline_completed: true })
          navigate("/dashboard")
```

### 4c. Training Module Flow

```
/training/:id
  → load training record
  → TrainingContentViewer: load training_content WHERE training_id=X
      Video: onEnded → contentCompleted=true
      Slides: onLoad → setTimeout(30s) → contentCompleted=true
  → "Attempt Quiz" enabled when contentCompleted=true
  → load assessments WHERE type='training' AND training_id=X
      if none → saveProgress(100, true) → navigate("/dashboard")  [auto-pass]
  → load questions + options for assessment
  → user completes quiz
  → handleSubmitQuiz():
      score = correct / total * 100
      saveProgress(score, score >= 80):
          existing record? keep max(score), pass if score>=80 OR was previously passed
          upsert training_progress
      navigate("/dashboard")
```

### 4d. Endline → Certificate Flow

```
/assessment/endline
  → same MCQ flow as baseline
  → handleSubmit():
      if score < 70% → fail
      if score >= 70%:
          supabase.profiles.update({ endline_score, endline_completed: true })
          certificate_id = "CC-" + Date.now() + "-" + random4
          supabase.certificates.insert({ user_id, certificate_id, persona })
          navigate("/certificate")

/certificate
  → load certificates WHERE user_id = auth.uid()
  → render styled card
  → "Download PDF" → window.open() + document.write(HTML) + window.print()
```

### 4e. Admin Write Flow

```
Admin user (user_roles.role = 'admin')
  → useAdminRole() confirms isAdmin (client-side guard)
  → AdminLayout renders sidebar + <Outlet />
  → All mutations go direct to Supabase:
      supabase.from(table).insert/update/delete
  → Server-side: has_role(auth.uid(), 'admin') RLS policy blocks non-admins
  → UI shows confirmation dialog before any delete
```

---

## 5. Coding Standards & Patterns

### Naming Conventions

| Context | Convention | Example |
|---|---|---|
| Components | PascalCase | `ModuleCard`, `AdminLayout` |
| Hooks | camelCase, `use` prefix | `useAdminRole`, `use-mobile` |
| Files (pages/components) | PascalCase `.tsx` | `Dashboard.tsx` |
| Files (hooks/utils) | kebab-case `.ts` | `use-toast.ts`, `utils.ts` |
| CSS classes | Tailwind utilities + BEM-ish custom | `.persona-badge-a`, `.glass-card` |
| DB columns | snake_case | `baseline_completed`, `order_number` |

### State Management Pattern

```
Global persistent state  → AuthContext (session, user, profile)
Global server state      → React Query (QueryClientProvider, no explicit hooks yet)
Local UI state           → useState (form inputs, loading flags, step index)
Admin role check         → useAdminRole() (per-component, not cached globally)
```

### Supabase Query Pattern

All DB access follows this pattern — no ORM, no abstraction layer:
```typescript
const { data, error } = await supabase
  .from("table_name")
  .select("*")           // or specific columns
  .eq("column", value)
  .single();             // or .maybeSingle() / no modifier for arrays

if (error) {
  toast.error("Human readable message");
  return;
}
```
Relationships are loaded in **separate sequential queries**, not via Supabase's relational select syntax (`.select("*, questions(*)")`).

### Component Structure Pattern

Pages follow this structure:
```
1. State declarations (useState, derived values)
2. useEffect for initial data load
3. Handler functions (handle*, save*, fetch*)
4. Return JSX (top-level: full-screen flex container)
```

### Error Handling

- All Supabase errors → `toast.error(message)` via Sonner
- No global error boundary
- Loading states: per-component boolean flags, render spinner or skeleton

### Form Pattern

Auth forms use controlled `useState`. Admin forms mix controlled state with direct Supabase upserts on a "Save All" action (not per-field auto-save).

---

## 6. Pass Thresholds & Business Logic

| Gate | Threshold | Action on Fail |
|---|---|---|
| Baseline assessment | 60% | Reset, stay on page; no persona assigned |
| Training unit quiz | 80% | Progress saved (score recorded); can retry |
| Endline assessment | 70% | Reset, stay on page; no certificate |

**Persona assignment (baseline only):**
- ≥75% → A (Advanced)
- ≥70% → B (Proficient)
- ≥65% → C (Intermediate)
- ≥60% → D (Foundational)

**Unit locking logic (Dashboard):**
- All units locked if `baseline_completed = false`
- Unit N locked if unit N-1 is not `passed`
- Locking is per-module (first unit in each module unlocks independently once baseline done)

**Content completion gates:**
- Video: must play to end (`onEnded` event)
- Slides: `<iframe>` load + 30-second timer

---

## 7. Validation Issues & Ambiguities Found

### Missing / Incomplete

| # | Issue | Location | Severity |
|---|---|---|---|
| 1 | No `.env.example` file | repo root | Medium — new devs must guess var names |
| 2 | Legacy files not removed | `AdminTrainings.tsx`, `AdminTrainingContent.tsx` | Low — dead code, not routed |
| 3 | No endline assessment seeded | DB | High — endline flow untestable without admin creating one |
| 4 | Certificate download uses `alert()` as toast fallback | `Certificate.tsx:169` | Low — inconsistent UX |
| 5 | Slides completion is time-based (30s), not interaction-based | `TrainingContentViewer.tsx` | Medium — gameable |
| 6 | `has_role` argument order mismatch between migration SQL `(_user_id, _role)` and `types.ts` `(_role, _user_id)` | `types.ts` vs migration | Medium — types.ts is auto-generated; SQL is authoritative |
| 7 | No test coverage beyond placeholder | `src/test/` | Medium — only `example.test.ts` exists |
| 8 | `modules` table has no RLS policy for admins to insert `user_roles` | migrations | Low — roles must be set manually in Supabase dashboard |
| 9 | `profiles.phone` is set to user's email as fallback in trigger | migration | Low — potential data quality issue if email ≠ phone |
| 10 | React Query `QueryClient` is configured with defaults only | `App.tsx` | Low — no staleTime, refetchOnWindowFocus still default-on |

### Ambiguous Logic

| # | Ambiguity | Location |
|---|---|---|
| A | `isUnitLocked` locks by sequential index within module — but `order_number` from DB is not used for sort order in Dashboard; relies on array index | `Dashboard.tsx` |
| B | Endline can be attempted even if not all modules are passed — Dashboard CTA checks "all units passed" but Assessment page itself has no server-side guard | `Assessment.tsx` |
| C | Multiple certificates: `certificates` has `UNIQUE(user_id)` — re-taking endline after passing will fail silently on insert (no upsert) | `Assessment.tsx` |
| D | `training_progress` upsert uses `score >= 80` for pass, but if a user had `passed=true` previously and scores 50%, the upsert logic preserves the pass — correct by design but not documented | `TrainingModule.tsx` |

---

## 8. Environment Variables

```
VITE_SUPABASE_URL             Supabase project URL
VITE_SUPABASE_PUBLISHABLE_KEY Supabase anon/publishable key
```

No `.env.example` exists. Both variables are required — app will silently fail if absent (no runtime guard in `client.ts`).

---

## 9. Key File Quick Reference

| Need to... | Go to |
|---|---|
| Change auth logic | `src/contexts/AuthContext.tsx` |
| Change routing | `src/App.tsx` |
| Change persona thresholds | `src/pages/Assessment.tsx` (~line 140) |
| Change quiz pass threshold | `src/pages/TrainingModule.tsx` (~line 160) |
| Change DB schema | `supabase/migrations/` (create new migration) |
| Add a new admin page | `src/pages/admin/` + register in `App.tsx` under `/admin` |
| Edit design tokens | `src/index.css` |
| Add shadcn component | `src/components/ui/` (via shadcn CLI) |
| Check DB types | `src/integrations/supabase/types.ts` (auto-generated — regenerate via Supabase CLI) |
