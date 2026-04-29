import { defineConfig } from "vitest/config";
import react from "@vitejs/plugin-react-swc";
import path from "path";

export default defineConfig({
  plugins: [react()],
  test: {
    environment: "jsdom",
    globals: true,
    setupFiles: ["./src/test/setup.ts"],
    // Default `npm run test` runs unit + hook/component tests.
    // Integration tests (`*.integration.test.ts`) require local Supabase and
    // run via `npm run test:integration` — see package.json.
    include: ["src/**/*.{test,spec}.{ts,tsx}"],
    exclude: [
      "node_modules/**",
      "dist/**",
      "src/**/*.integration.test.{ts,tsx}",
    ],
    coverage: {
      // Coverage tooling installed but thresholds are intentionally OFF on
      // adoption day. Measure-then-floor: once a real number is recorded
      // post-merge, raise these to that number so coverage cannot regress.
      // See docs/ENGINEERING_WORKFLOW.md "Coverage ratchet".
      provider: "v8",
      reporter: ["text", "html", "lcov"],
      include: ["src/**/*.{ts,tsx}"],
      exclude: [
        "src/**/*.test.{ts,tsx}",
        "src/**/*.spec.{ts,tsx}",
        "src/test/**",
        "src/integrations/supabase/types.ts",
        "src/components/ui/**",
      ],
      // thresholds: { lines: 0, statements: 0, functions: 0, branches: 0 },
    },
  },
  resolve: {
    alias: { "@": path.resolve(__dirname, "./src") },
  },
});
