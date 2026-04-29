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
      // Coverage ratchet — floors set to the measured baseline minus 1%
      // (small slack). Each PR that raises coverage tightens these.
      // See docs/ENGINEERING_WORKFLOW.md "Coverage ratchet".
      // Last measured: 2026-04-29 — lines 1.12 / branches 28.75 / functions 5.17.
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
      thresholds: {
        lines: 0.12,
        statements: 0.12,
        functions: 4.17,
        branches: 27.75,
      },
    },
  },
  resolve: {
    alias: { "@": path.resolve(__dirname, "./src") },
  },
});
