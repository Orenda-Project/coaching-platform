# Code Review Findings

Last updated: 2026-04-23

## Recurring Issues (catch these in every review)

**CRITICAL — Auth & Security**
- Missing auth check before DB write (must verify user owns the row)
- Supabase RLS not enforced or row-level policy too loose
- Admin routes not guarded server-side (can be bypassed)
- Sensitive data logged to console (email, auth tokens, user IDs)

**HIGH — Data Integrity**
- Insert instead of upsert on progress tables (causes duplicates on retake)
- Hardcoded thresholds (80, 70) instead of constants (brittle on requirement change)
- Quiz threshold logic — check both >= 80 AND == 80 inconsistency
- Baseline redirect happens before baseline_completed is written (timing bug)

**MEDIUM — Code Quality**
- No loading state on async operations (UX gap, feels stuck)
- TypeScript `any` used instead of proper type (lose type safety)
- N+1 queries inside loops (fetch once, reuse)
- No error toast on failed Supabase call (silent failure)
- Unhandled promise rejections (no catch on async calls)

**LOW — Style**
- Console.log left in production code
- Unused imports or dead code
- Inconsistent error message formatting

## Anti-patterns to flag
- Client-side validation used for business rules (should be server + client)
- Conditional redirects without loading state (user sees page blink)
- Relying on timing assumptions (race conditions between writes)
- Mixed upsert/insert patterns (use one approach consistently)

## Prop Memoization & Async State (2026-05-13)
- **useMemo with array dependency:** If a component uses `useMemo(() => shuffle(options), [options])` and the parent re-renders with a new array reference (even if items are the same), the shuffle re-runs. This can cause UI flashing or options jumping positions mid-interaction. Parent must memoize the options array, or component should key on stable data (e.g., option IDs).
- **Default prop with async data:** A boolean prop like `contentCompleted = false` should not be used when the parent has async-derived state. Renders before the parent loads the state will show the wrong UI (locked when it shouldn't be). Parent should show a loading state instead of rendering the child.

## Questions to ask
- "If this table was written by mistake, how would we detect & revert?"
- "What happens if the DB write succeeds but the response fails?"
- "Can this user see another user's data if auth is bypassed?"
- "Does the parent memoize array/object props that are used as dependencies?"
- "If a boolean prop is async-derived, is there a loading state before the child renders?"
