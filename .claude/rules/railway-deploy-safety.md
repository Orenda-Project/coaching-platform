# Railway Deployment Safety Rules

## Incident: 2026-06-16 Production Outage
The Python API code was deployed to the frontend service via `railway up` from the wrong directory. Production showed API JSON instead of the React app for ~20 hours.

## Hard Rules

### 1. Service-Directory Map (memorize)

| Service | Deploy From | Content |
|---|---|---|
| `coaching-platform` (prod frontend) | repo root `/` | React/Vite |
| `coaching-platform-stage` (staging frontend) | repo root `/` | React/Vite |
| `coaching-content-api` (prod API) | `coaching-api/` | Python FastAPI |
| `coaching-api-staging` (staging API) | `coaching-api/` | Python FastAPI |

### 2. Before ANY `railway up`

1. Run `pwd` — verify directory matches service type
2. Run `railway status` — verify linked service name is correct
3. If deploying API: `ls Dockerfile requirements.txt` must succeed
4. If deploying frontend: `ls package.json vite.config.ts` must succeed

### 3. After ANY `railway up`

Run post-deploy smoke test:
```bash
# Frontend: must return HTML
curl -s <frontend-url> | head -1
# Expected: <!doctype html>

# API: must return JSON
curl -s <api-url>/health
# Expected: {"status":"healthy","version":"1.0"}
```

If frontend returns JSON or API returns HTML → **WRONG CODE DEPLOYED. Fix immediately.**

### 4. Never deploy API from repo root

`railway up` from repo root will detect `package.json` and build as a Node app, overwriting the Python API service.

### 5. Supabase → Postgres Migration Rule

When migrating a table from Supabase to Railway Postgres:
- Migrate ALL CRUD operations in one PR (never half-Supabase, half-Postgres)
- Add missing columns to Railway Postgres BEFORE deploying frontend code
- Take pg_dump backup before ALTER TABLE on production
- Include rollback SQL script with every migration
- Keep on Supabase only: auth, Realtime subscriptions, Edge Functions
