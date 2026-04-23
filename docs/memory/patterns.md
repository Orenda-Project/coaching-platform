# Dev Patterns & Gotchas

Last updated: 2026-04-23

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
