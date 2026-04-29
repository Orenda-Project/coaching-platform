// Integration test setup. Verifies local Supabase is reachable before any test runs.
//
// Local Supabase URL/key are written by `supabase start` (see CLAUDE.md "Local Development").
// If they are missing, fail fast with a clear message rather than letting tests hang.

import { beforeAll } from "vitest";

beforeAll(() => {
  const url = process.env.VITE_SUPABASE_URL ?? process.env.SUPABASE_URL;
  const key = process.env.VITE_SUPABASE_PUBLISHABLE_KEY ?? process.env.SUPABASE_ANON_KEY;
  if (!url || !key) {
    throw new Error(
      "[integration] Missing VITE_SUPABASE_URL / VITE_SUPABASE_PUBLISHABLE_KEY.\n" +
        "Run `supabase start` and copy the values into .env.local, " +
        "or export SUPABASE_URL and SUPABASE_ANON_KEY in your shell.",
    );
  }
  if (url.includes("supabase.co")) {
    // Hard guard: integration tests must NEVER point at remote Supabase.
    throw new Error(
      `[integration] Refusing to run against a remote Supabase URL: ${url}.\n` +
        "Integration tests must target the local instance from `supabase start`.",
    );
  }
});
