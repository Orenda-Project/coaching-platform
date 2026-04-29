// Data-access layer.
//
// All Supabase queries (`supabase.from(...).select/insert/update/upsert/delete`)
// belong in this folder, organised by domain area (e.g. `assessments.ts`,
// `modules.ts`, `feedback.ts`). Pages and hooks call these typed functions —
// they MUST NOT call `supabase.from(...)` directly.
//
// Why:
//   - Centralised place to test query shapes (integration tests)
//   - Centralised place to verify RLS denial paths
//   - Pages stay focused on orchestration + JSX
//   - Migration to a different backend (or edge functions) becomes feasible
//
// This file is intentionally empty. As features are touched, queries migrate
// here from page components — see .claude/agents/feature-developer.md.

export {};
