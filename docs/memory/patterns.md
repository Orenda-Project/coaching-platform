# Dev Patterns & Gotchas

Last updated: 2026-04-28

## Supabase
- Always destructure `{ data, error }` — never assume success without checking error
- Use upsert (not insert) for user progress rows to handle retakes safely
- No relational `.select()` chaining — use separate queries
- RLS failures appear as empty data or "permission denied" — always check both
- Schema cache mismatches appear as PGRST204 ("Could not find column") — run migration first, wait for cache refresh

## Business Rules (never break)
- 80% threshold for module quizzes (not 70%) — check threshold constants
- 70% threshold for endline assessment
- Certificate ID format: `CC-{timestamp}-{random4}` — validate on generation
- Sequential module unlock — order_number must be validated, Module 1 = order 1
- Module 1 is universal regardless of persona — don't filter by persona for Module 1

## DB Migrations
- Write SQL migration BEFORE writing code that uses new columns
- Run on staging first, then prod
- Pattern: `ALTER TABLE x ADD COLUMN IF NOT EXISTS y TYPE DEFAULT z;`
- Always test the migration on staging before deploying code

## Common Gotchas
- Baseline assessment scored 0–100, persona thresholds: A≥75%, B 70–74%, C 65–69%, D 60–64%, <60% = fail
- Content gates: video must reach 90%, slides must wait 30s, both must complete before quiz unlocks
- Quiz anti-cheat: fullscreen + tab-switch detection required

## Working with the user (2026-04-29)
- **"Use defaults" = explicit validation, not silent acceptance.** When the user accepts a recommended choice without pushback (e.g. answers "use defaults" to a multi-option proposal), treat that as a validated judgment for this codebase, not as a default fall-through. Capture WHY the choice was preferred (cost, blast radius, reversibility) so future agents reach the same conclusion without re-deliberating. Source: signal `s_user_validation` reached promotion threshold of 3 occurrences across PR #44 / #47 / #49 in `docs/memory/patterns-log.jsonl`.

## Feedback Chatbot Patterns (2026-04-28)
- **Native buttons for icon/interactive toggles:** Use native `<button>` (not `<Button>` component) for star ratings and simple toggles. Icon-only buttons with custom styling prefer vanilla HTML. `<Button>` adds extra spacing/padding that breaks compact UI.
- **A11y: Star rating keyboard nav gap:** Native button Star ratings lack keyboard focus indicator (FIX: add focus:outline-2 focus:outline-offset). Tab navigation works but visual feedback minimal.
- **Phase-machine string unions:** Use `phase: 'greet' | 'category' | 'rating' | 'text' | 'submitting' | 'done'` over enums for tight state control in UI conditionals (auto-narrowing reduces explicit guards).
- **Cooldown self-cleanup via useEffect:** Timer inside useEffect must check expiry on every tick AND clear interval before nulling state (prevents 1Hz re-render stalls). Sync `setNow` together with `setCooldownUntil` to avoid first-tick flicker.
- **Cumulative scrollback pattern:** Hide greet phase actions once user advances, but re-render greet greeting + "Yes" echo on later phases to preserve conversation thread (role="log" aria-live="polite" for a11y).
- **Fire-and-forget analytics vs. awaited submission:** Analytics (useAnalytics) ignores errors; user submissions (useFeedback) await and handle toast errors. Different contract, same pattern signature.

## Training Flow Improvements (2026-05-13)
- **Answer randomization with Fisher-Yates shuffle:** Create utility in `src/lib/shuffle.ts`, import via `useMemo` to randomize on every render. Use exact import pattern to avoid stale array references.
- **Practice section locking:** Domain logic in `src/domain/trainingRules.ts` with `canAccessPracticeSection(contentCompleted)` returns boolean. Lock message via `getPracticeLockMessage()`. Add "locked" phase to ScenarioFlow to prevent access until TrainingContentViewer's `contentCompleted = true`.
- **Renaming "Scenario" to "Practice Section":** Update CardTitle in ScenarioCard, all user-facing text labels (headers, progress counters, breakdown labels). Keep internal variable names unchanged for minimal diff.
- **Phase extension pattern:** Add new phases to component (e.g., "locked") and handle in renderContent switch. Each phase renders conditionally based on state checks (e.g., `!canAccessPracticeSection(contentCompleted)`).
- **Testing randomization:** Tests must render multiple times and collect orders, not test implementation details. Balance option text lengths at seed data level, not in component. Use `Array.from(document.querySelectorAll(...))` for DOM queries when testing-library selectors don't work.
