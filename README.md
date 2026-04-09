# Coach-Cert — Taleemabad

A coaching certification platform for teachers. Teachers complete baseline assessments, persona-targeted training modules, and an endline assessment to earn a certificate.

**Stack:** React 18 + TypeScript · Vite · Supabase · Tailwind CSS · shadcn-ui

---

## Prerequisites

- [Node.js](https://nodejs.org/) (v18+) — install via [nvm](https://github.com/nvm-sh/nvm)
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) — required for local Supabase
- [Supabase CLI](https://supabase.com/docs/guides/cli) — `brew install supabase/tap/supabase`

---

## Local Development Setup

### 1. Clone and install

```sh
git clone <YOUR_GIT_URL>
cd coach-cert
npm install
```

### 2. Start local Supabase

Docker Desktop must be running first.

```sh
supabase start
```

This pulls Docker images (first run only), starts a local Postgres instance, and applies all migrations automatically. You'll see output like:

```
Studio  │ http://127.0.0.1:54323
API URL │ http://127.0.0.1:54321
DB URL  │ postgresql://postgres:postgres@127.0.0.1:54322/postgres
Publishable Key │ sb_publishable_...
```

### 3. Configure environment

Create a `.env.local` file (takes priority over `.env`):

```sh
VITE_SUPABASE_URL=http://127.0.0.1:54321
VITE_SUPABASE_PUBLISHABLE_KEY=<Publishable Key from supabase start output>
```

> `.env` points to the production Supabase project. `.env.local` overrides it for local dev. Never commit either file.

### 4. Create a local admin user

1. Start the app: `npm run dev`
2. Sign up at `http://localhost:5173/signup`
3. Open Supabase Studio at `http://127.0.0.1:54323` → SQL Editor and run:

```sql
INSERT INTO public.user_roles (user_id, role)
SELECT id, 'admin'
FROM auth.users
WHERE email = 'your-email@example.com'
ON CONFLICT DO NOTHING;
```

### 5. Run the app

```sh
npm run dev
```

App runs at `http://localhost:5173`.

---

## Environment Files

| File | Purpose | Committed? |
|---|---|---|
| `.env` | Production Supabase credentials | No |
| `.env.local` | Local Supabase credentials (overrides `.env`) | No |

Vite loads `.env.local` with higher priority than `.env` automatically — no config change needed.

Required variables:

```
VITE_SUPABASE_URL=
VITE_SUPABASE_PUBLISHABLE_KEY=
```

---

## Local Supabase Management

```sh
supabase start          # Start local DB + apply migrations
supabase stop           # Stop all containers (keeps data)
supabase stop --no-backup  # Stop and wipe all local data
supabase status         # Show running service URLs and keys
supabase db reset       # Wipe DB and re-apply all migrations from scratch
```

**Studio (local DB GUI):** http://127.0.0.1:54323
**Mailpit (local email):** http://127.0.0.1:54324 — catches all auth emails (confirmations, password resets)

### Adding a migration

```sh
supabase migration new <description>
# Edit the generated file in supabase/migrations/
supabase db reset   # Apply to local DB
```

---

## Available Commands

```sh
npm run dev          # Start dev server
npm run build        # Production build
npm run build:dev    # Development build
npm run lint         # ESLint
npm run test         # Run Vitest
npm run test:watch   # Vitest watch mode
npm run preview      # Preview production build
```

---

## Environments

| Environment | Supabase | How to connect |
|---|---|---|
| **Local** | `http://127.0.0.1:54321` | `.env.local` + `supabase start` |
| **Production** | `https://rdvylrymblwcwnfpjkyw.supabase.co` | `.env` (default) |

Production DB tools:
- **Dashboard:** https://supabase.com/dashboard/project/rdvylrymblwcwnfpjkyw
- **SQL Editor:** https://supabase.com/dashboard/project/rdvylrymblwcwnfpjkyw/sql/new
- **Table Editor:** https://supabase.com/dashboard/project/rdvylrymblwcwnfpjkyw/editor
