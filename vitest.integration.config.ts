import { defineConfig } from "vitest/config";
import react from "@vitejs/plugin-react-swc";
import path from "path";

// Integration tests run against LOCAL Supabase (`supabase start`).
// Each test wraps DB work in a transaction that rolls back at teardown.
//
// Prerequisite: Docker Desktop running, then `supabase start`.
// CI: requires the supabase CLI in the workflow (Phase 5 wires this up).
//
// Tests in this run MUST be named `*.integration.test.ts` and SHOULD live
// next to the data-access function they exercise (e.g. src/data/feedback.integration.test.ts).

export default defineConfig({
  plugins: [react()],
  test: {
    environment: "node", // integration tests don't need jsdom
    globals: true,
    setupFiles: ["./src/test/setup-integration.ts"],
    include: ["src/**/*.integration.test.{ts,tsx}"],
    // Integration tests are slower; bump the default 5s ceiling.
    testTimeout: 15_000,
    hookTimeout: 15_000,
  },
  resolve: {
    alias: { "@": path.resolve(__dirname, "./src") },
  },
});
