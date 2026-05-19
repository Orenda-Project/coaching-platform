---
description: Generate a complete BDD feature file from natural language intent. Creates canonical .feature file with @positive, @negative, @edge, @error scenarios, plus supporting intent and scope files.
argument-hint: <area> [--description "intent description"] [--force]
---

# /bdd $ARGUMENTS

Generate a comprehensive Gherkin feature file for **$ARGUMENTS**.

This command creates three files in `tests/features/<area>/`:
1. `<area>.intent.md` — the intent definition
2. `<area>.feature` — the canonical Gherkin file (no @chunk tags)
3. `<area>.scope` — the IDD scope boundary (source files to validate against)

## Usage

```bash
# Generate a feature for an area
/bdd login

# Generate with explicit intent description
/bdd password-reset --description "User can reset a forgotten password via email"

# Overwrite an existing feature (requires --force)
/bdd login --force --description "Updated login feature"
```

## Workflow

1. Normalize `<area>` to lowercase-hyphenated slug
2. Check if `tests/features/<area>/<area>.feature` already exists:
   - **YES, no `--force`:** Display existing intent and exit with guidance
   - **YES, `--force`:** Warn and overwrite
   - **NO:** Proceed
3. Dispatch the `bdd-generator` sub-agent with:
   - Area name
   - Intent description (from `--description` or area name alone)
   - Style reference: `tests/features/login/login.feature`
4. Write three files to `tests/features/<area>/`:
   - `<area>.intent.md`
   - `<area>.feature`
   - `<area>.scope`
5. Output summary with:
   - File paths created
   - Scenario count by tag type (@positive, @negative, @edge, @error)
   - Next step: "Run `/add tests/features/<area>/<area>.feature` to add @chunk tags and create scope file"

## Examples

### Generate login feature from area name alone
```
/bdd login
```

**Output:**
```
Generated feature files in tests/features/login/

Files created:
  ✓ tests/features/login/login.intent.md
  ✓ tests/features/login/login.feature
  ✓ tests/features/login/login.scope

Scenario count:
  @positive: 6
  @negative: 7
  @edge: 2
  @error: 3
  Total: 18 scenarios

Next step: Run `/add tests/features/login/login.feature` to add @chunk tags and create the IDD scope file.
```

### Generate password reset feature with explicit intent
```
/bdd password-reset --description "User can reset a forgotten password via email with a secure token"
```

**Output:**
```
Generated feature files in tests/features/password-reset/

Files created:
  ✓ tests/features/password-reset/password-reset.intent.md
  ✓ tests/features/password-reset/password-reset.feature
  ✓ tests/features/password-reset/password-reset.scope

Scenario count:
  @positive: 4
  @negative: 5
  @edge: 2
  @error: 2
  Total: 13 scenarios

Next step: Run `/add tests/features/password-reset/password-reset.feature` to add @chunk tags and create the IDD scope file.
```

### Regenerate with --force
```
/bdd login --force --description "Updated login with OAuth"
```

**Output:**
```
⚠️  Overwriting existing feature files at tests/features/login/

Generated feature files in tests/features/login/

Files created:
  ✓ tests/features/login/login.intent.md (overwritten)
  ✓ tests/features/login/login.feature (overwritten)
  ✓ tests/features/login/login.scope (overwritten)

Scenario count:
  @positive: 7
  @negative: 8
  @edge: 3
  @error: 4
  Total: 22 scenarios

Next step: Run `/add tests/features/login/login.feature` to add @chunk tags and create the IDD scope file.
```

## What the bdd-generator Sub-Agent Produces

### `<area>.intent.md`
A structured intent document with:
- Feature description
- Actors and preconditions
- Key behaviors (bullet list)
- Known constraints
- Out of scope items

### `<area>.feature`
A complete Gherkin file with:
- Organized by scenario type (positive → negative → edge → error)
- Every scenario tagged with exactly one of: @positive, @negative, @edge, @error
- NO @chunk tags (those are added by `/add`)
- Clear, behavior-level Given/When/Then steps
- Business-facing language (no implementation details)

### `<area>.scope`
A simple text file listing relevant source files:
```
# <Area> feature scope
src/pages/<Area>.tsx
src/contexts/<Context>.tsx
src/hooks/use<Feature>.ts
```

## Guard Conditions

- Empty or invalid `<area>` → print usage and exit
- Directory does not exist → create it
- Invalid `--description` → proceed with area name as fallback

## Notes

- The `/bdd` command ONLY creates feature files; it does NOT add `@chunk` tags
- Use `/add` to add `@chunk` tags and create the `.scope` file for MCP execution
- Use the IDD pipeline separately to validate code coverage
- Feature files are the single source of truth — never regenerate unless explicitly needed with `--force`
