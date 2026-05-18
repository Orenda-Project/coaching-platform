---
description: Add @chunk tags above every scenario in a .feature file and manage the corresponding .scope file. Creates .scope if missing, updates if existing. Detects and adds missing scopes automatically. Idempotent — safe to run multiple times.
argument-hint: <path-to-feature-file>
---

# /add $ARGUMENTS

Process an existing `.feature` file to prepare it for E2E execution and IDD validation.

This command:
1. Adds `@chunk` tag above every scenario (if not already present)
2. Creates a `.scope` file alongside the `.feature` file (if missing)
3. Updates existing `.scope` file with discovered scopes
4. Detects missing scopes referenced in the feature and adds them automatically
5. Returns the path to the `.scope` file

## Usage

```bash
# Add @chunk tags to a feature file
/add tests/features/login/login.feature

# Add @chunk tags to a different feature
/add tests/features/baseline-assessment/baseline-assessment.feature
```

## Workflow

1. **Validate input:**
   - Check that path exists and ends in `.feature`
   - Exit with error if not found or wrong extension

2. **Read the feature file:**
   - Parse all `Scenario:` and `Scenario Outline:` lines
   - Check if `@chunk` tag already exists above each
   - Extract scope hints from scenario steps (e.g., page names, component references)

3. **Add @chunk tags:**
   - Insert `@chunk` above each scenario that doesn't have it
   - Leave existing `@chunk` tags unchanged (idempotent)
   - Write modified file back to same location

4. **Manage .scope file:**
   - Derive path: same directory, same base name, `.scope` extension
   - **If .scope does NOT exist:**
     - Create new file with header comment and inferred scope paths from feature steps
   - **If .scope ALREADY EXISTS:**
     - Read existing file
     - Parse existing scope entries (comment lines start with `#`, ignore them)
     - Identify any missing scopes detected from the feature file
     - Append missing scopes to the file (without duplicating existing ones)
     - Preserve all existing entries and comments
   - **Scope detection:**
     - Extract page/component references from step definitions
     - Infer source paths using project conventions (e.g., "Login page" → `src/pages/Login.tsx`)
     - Add inferred paths as comments if uncertain, or as definite entries if confident

5. **Output:**
   - Confirmation: how many scenarios got `@chunk` tags
   - Notification: whether `.scope` file was created, updated, or unchanged
   - `.scope` file path (the critical output)
   - Summary of scopes added or detected

## Examples

### Add @chunk to login feature (first run — .scope does not exist)
```bash
/add tests/features/login/login.feature
```

**Output:**
```
Added @chunk to 11 scenarios in tests/features/login/login.feature

Scope file created (new):
  tests/features/login/login.scope

Detected scopes from feature steps:
  + src/pages/Login.tsx
  + src/contexts/AuthContext.tsx
  + src/hooks/useAuth.ts

Next step: Review and edit tests/features/login/login.scope to add or update source file paths before running IDD validation.
```

### Running again on the same file (idempotent — no changes)
```bash
/add tests/features/login/login.feature
```

**Output:**
```
All scenarios already have @chunk tags. No changes made to tests/features/login/login.feature

Scope file unchanged:
  tests/features/login/login.scope

Scopes in file (4 entries):
  • src/pages/Login.tsx
  • src/contexts/AuthContext.tsx
  • src/hooks/useAuth.ts
  • src/utils/validation.ts
```

### Add @chunk to login feature (second run — .scope exists, new scenarios added)
```bash
/add tests/features/login/login.feature
```

**Output:**
```
All scenarios already have @chunk tags. No changes made to tests/features/login/login.feature

Scope file updated (new scopes detected):
  tests/features/login/login.scope

Added to scope file:
  + src/components/PasswordReset.tsx
  + src/services/emailService.ts

Scopes in file (6 entries):
  • src/pages/Login.tsx
  • src/contexts/AuthContext.tsx
  • src/hooks/useAuth.ts
  • src/utils/validation.ts
  • src/components/PasswordReset.tsx
  • src/services/emailService.ts
```

### Add @chunk to baseline assessment
```bash
/add tests/features/baseline-assessment/baseline-assessment.feature
```

**Output:**
```
Added @chunk to 28 scenarios in tests/features/baseline-assessment/baseline-assessment.feature

Scope file created (new):
  tests/features/baseline-assessment/baseline-assessment.scope

Detected scopes from feature steps:
  + src/pages/BaselineAssessment.tsx
  + src/components/QuestionRenderer.tsx
  + src/hooks/useQuiz.ts
  + src/types/quiz.ts

Next step: Review and edit tests/features/baseline-assessment/baseline-assessment.scope before running IDD validation.
```

## What Gets Added

### @chunk Tag Placement

**Before (original .feature file):**
```gherkin
Scenario: Successful login with valid credentials
  Given I enter "user@example.com" in the Email field
  And I enter "Password123" in the Password field
  When I click the "Sign In" button
  Then I am logged in successfully
```

**After (with /add applied):**
```gherkin
@chunk
Scenario: Successful login with valid credentials
  Given I enter "user@example.com" in the Email field
  And I enter "Password123" in the Password field
  When I click the "Sign In" button
  Then I am logged in successfully
```

The `@chunk` tag is placed immediately above the `Scenario:` or `Scenario Outline:` line, on its own line.

### .scope File Format

**File location:** `<same-directory>/<base-name>.scope`

**Content (new file):**
```
# Login feature scope
# Generated: 2026-05-19
# Scopes detected from feature steps - verify and add any missing paths

src/pages/Login.tsx
src/contexts/AuthContext.tsx
src/hooks/useAuth.ts
```

**Content (existing file, after update):**
```
# Login feature scope
# Generated: 2026-05-18
# Last updated: 2026-05-19 (new scopes added)
# Scopes detected from feature steps

src/pages/Login.tsx
src/contexts/AuthContext.tsx
src/hooks/useAuth.ts
src/components/PasswordReset.tsx
src/services/emailService.ts
```

**Format rules:**
- One file path per line (absolute to project root)
- Comment lines start with `#`
- Header includes area name, generation date, and last update date
- Scopes are detected and inferred from feature step language
- When updating, new scopes are appended without duplicating existing ones
- Preserve all existing entries, comments, and formatting when updating
- User can manually edit to add/remove scopes as needed

## Idempotency

The `/add` command is safe to run multiple times:

1. **First run:**
   - Adds `@chunk` to all scenarios
   - Creates `.scope` file with detected scopes
   
2. **Second run (feature unchanged):**
   - Detects existing `@chunk` tags, makes no changes to feature file
   - Compares detected scopes with existing `.scope` file
   - If scopes match: reports "already processed, no changes"
   - If new scopes detected: appends them to `.scope` file (no duplicates)
   
3. **Subsequent runs:**
   - Same as second run — always checks for new scopes
   - Never overwrites existing file — only appends new entries
   - Preserves user-added comments and manual entries

**Key guarantees:**
- No `@chunk` tags are ever duplicated
- No scopes are ever duplicated in `.scope` file
- `.scope` file is never overwritten, only appended
- User manual edits to `.scope` are preserved

## Scope Detection

The `/add` command automatically infers source file paths from feature step language using these patterns:

### Detection Strategy

1. **Page references** (from "Given I am on X page" or "I see X page"):
   - "Login page" → `src/pages/Login.tsx`
   - "Baseline Assessment page" → `src/pages/BaselineAssessment.tsx`

2. **Component references** (from step text like "I click X component" or "X modal shows"):
   - "Question Renderer" → `src/components/QuestionRenderer.tsx`
   - "Password Reset" → `src/components/PasswordReset.tsx`

3. **Hook/service references** (from step text mentioning functionality):
   - "use Auth" → `src/hooks/useAuth.ts`
   - "email service" → `src/services/emailService.ts`

4. **Type/utility references** (explicit imports in steps):
   - "quiz types" → `src/types/quiz.ts`
   - "validation utilities" → `src/utils/validation.ts`

### Confidence Levels

- **High confidence:** Page references, explicit component names
- **Medium confidence:** Feature/domain inferred from scenario titles
- **Low confidence:** Utility/helper functions inferred from step language

All detected scopes are added to the `.scope` file. Users should review and remove low-confidence entries if they don't apply.

### Duplicate Detection Rules

When updating an existing `.scope` file, the command must prevent duplicate entries:

1. **Exact matching:**
   - Compare detected scope path WITH all existing non-comment lines in file
   - If detected path matches exactly (case-sensitive): **SKIP IT** — do not add
   - If detected path is new: **ADD IT** — append to file with newline

2. **Path normalization (before comparison):**
   - Strip leading/trailing whitespace from both detected and existing paths
   - Normalize path separators (all forward slashes, no backslashes)
   - Lowercase comparison: `src/pages/Login.tsx` === `SRC/PAGES/LOGIN.TSX` (SKIP if match)

3. **Comment lines:**
   - Lines starting with `#` are comments — ignore them during duplicate detection
   - Do NOT add duplicate comment lines either
   - Preserve all comments as-is

4. **Append order:**
   - New scopes are appended to the end of the file
   - If file has no trailing newline, add one before appending
   - Each new scope gets its own line with trailing newline

**Examples:**
- File has `src/pages/Login.tsx`, detected `src/pages/Login.tsx` → **SKIP** (exact match)
- File has `src/pages/Login.tsx`, detected `src/pages/Signup.tsx` → **ADD** (new path)
- File has `# src/pages/OldPage.tsx`, detected `src/pages/OldPage.tsx` → **ADD** (comment ≠ entry)
- File has `src/pages/login.tsx`, detected `src/pages/Login.tsx` → **SKIP** (case-insensitive match)

## Guard Conditions

- Path does not exist → print error and exit
- Path does not end in `.feature` → print error and exit
- Path is a directory → print error and exit
- Invalid Gherkin syntax → process as best as possible (add `@chunk` where identifiable)

## Error Cases

**File not found:**
```
Error: tests/features/login/login.feature not found
Please check the path and try again.
```

**Wrong file type:**
```
Error: tests/features/login/login.txt is not a .feature file
Usage: /add <path-to-feature-file>
```

## Rationalizations to Avoid

These are common edge-case arguments that should NOT be used to skip or modify command behavior:

| Rationalization | Why It's Wrong | What to Do |
|---|---|---|
| "Scope file is recent enough, skip update" | Command is deterministic. Same input → same output always. Run update logic every time. | Always run scope detection and deduplication, even if file is recent. |
| "User hasn't touched the file, don't update" | Irrelevant. Feature file may have changed. Re-check all scopes on every run. | Parse feature file fresh each run, compare with file, append missing scopes. |
| "This scope might be wrong, better skip it" | Uncertainty ≠ skip. If detected, add it; let user remove if wrong. | Add all detected scopes. Users can edit `.scope` to remove false positives. |
| "Comment lines look like scopes, add them" | Comments start with `#`. Non-comment lines only. Don't add comments as scopes. | Parse carefully: `#` = comment, skip. Alphanumeric start = scope entry, add if new. |
| "Duplicate looks slightly different (case, spacing)" | Path normalization is explicit. Apply it before comparison. | Normalize both detected and existing paths (trim, lowercase, forward slashes). |
| "File has manual edits I don't understand, skip update" | Doesn't matter. Append-only mode preserves everything. User's edits stay intact. | Always append new scopes. Never overwrite or reformat existing entries. |
| "Feature file is empty, don't create .scope" | Empty feature = no scopes. But file should still exist for consistency. | Create `.scope` even if empty. Add header comment only. Append scopes later. |

**All of these mean: Follow the workflow exactly. No shortcuts, no exceptions.**

## Next Steps After /add

After running `/add`, you have:
- A `.feature` file with `@chunk` tags on all scenarios
- A `.scope` file with auto-detected source file paths

**To verify scope detection:**
- Open `.scope` file and review the detected paths
- Add any manually identified paths that were missed
- Remove any false positives (paths that don't apply)

**To use for E2E execution:**
- `/bdd-verify` (when it exists) will run @chunk scenarios via Chrome MCP

**To use for IDD validation:**
- `.scope` file is ready with auto-detected paths
- Run the IDD pipeline separately to validate code coverage
- The command will automatically update `.scope` if new scopes are detected in future runs

## Notes

- `@chunk` tags are used by E2E execution tools to know which scenarios are safe to run
- The `.scope` file is used by the IDD pipeline to know which files to analyze
- Both are created together by `/add` to keep feature and scope in sync
- Always commit both files to git together
