---
description: Add @chunk tags above every scenario in a .feature file and create the corresponding .scope file. Idempotent — safe to run multiple times without duplicating tags.
argument-hint: <path-to-feature-file>
---

# /add $ARGUMENTS

Process an existing `.feature` file to prepare it for E2E execution and IDD validation.

This command:
1. Adds `@chunk` tag above every scenario (if not already present)
2. Creates a `.scope` file alongside the `.feature` file
3. Returns the path to the `.scope` file

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

3. **Add @chunk tags:**
   - Insert `@chunk` above each scenario that doesn't have it
   - Leave existing `@chunk` tags unchanged (idempotent)
   - Write modified file back to same location

4. **Create .scope file:**
   - Derive path: same directory, same base name, `.scope` extension
   - Generate with header comment and placeholder source file list
   - Write to disk

5. **Output:**
   - Confirmation: how many scenarios got `@chunk` tags
   - `.scope` file path (the critical output)
   - Reminder to add source paths to `.scope` before IDD validation

## Examples

### Add @chunk to login feature
```bash
/add tests/features/login/login.feature
```

**Output:**
```
Added @chunk to 18 scenarios in tests/features/login/login.feature

Scope file created:
  tests/features/login/login.scope

Next step: Edit tests/features/login/login.scope to add actual source file paths (e.g., src/pages/Login.tsx, src/contexts/AuthContext.tsx) before running IDD validation.
```

### Running again on the same file (idempotent)
```bash
/add tests/features/login/login.feature
```

**Output:**
```
All scenarios already have @chunk tags. No changes made to tests/features/login/login.feature

Scope file location:
  tests/features/login/login.scope

Reminder: Update tests/features/login/login.scope with source file paths if needed.
```

### Add @chunk to baseline assessment
```bash
/add tests/features/baseline-assessment/baseline-assessment.feature
```

**Output:**
```
Added @chunk to 28 scenarios in tests/features/baseline-assessment/baseline-assessment.feature

Scope file created:
  tests/features/baseline-assessment/baseline-assessment.scope

Next step: Edit tests/features/baseline-assessment/baseline-assessment.scope to add actual source file paths before running IDD validation.
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

**Generated file:** `<same-directory>/<base-name>.scope`

**Content:**
```
# <Area> feature scope
# Generated: 2026-05-18
# Edit this file to add actual source file paths for IDD validation

src/pages/<Area>.tsx
src/contexts/<Context>.tsx
src/hooks/use<Feature>.ts
```

**Format rules:**
- One file path per line (absolute to project root)
- Comment lines start with `#`
- Includes a header with area name and generation date
- Includes placeholder paths as examples
- User must edit to add real source files before IDD validation

## Idempotency

The `/add` command is safe to run multiple times:

1. **First run:** Adds `@chunk` to all scenarios, creates `.scope` file
2. **Second run:** Detects existing `@chunk` tags, makes no changes, reports "already processed"
3. **Third run:** Same as second run

No tags are ever duplicated. No files are overwritten unnecessarily.

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

## Next Steps After /add

After running `/add`, you have:
- A `.feature` file with `@chunk` tags on all scenarios
- A `.scope` file ready for IDD validation

**To use for E2E execution:**
- `/bdd-verify` (when it exists) will run @chunk scenarios via Chrome MCP

**To use for IDD validation:**
- Edit `.scope` file to add real source file paths
- Run the IDD pipeline separately to validate code coverage

## Notes

- `@chunk` tags are used by E2E execution tools to know which scenarios are safe to run
- The `.scope` file is used by the IDD pipeline to know which files to analyze
- Both are created together by `/add` to keep feature and scope in sync
- Always commit both files to git together
