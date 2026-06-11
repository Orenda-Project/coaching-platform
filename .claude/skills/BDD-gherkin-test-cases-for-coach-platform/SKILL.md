---
name: BDD-gherkin-test-cases-for-coach-platform
description: Generate complete BDD/Gherkin test cases for the coaching platform from a scenario description or file.
allowed-tools: Read, Write, Bash
---

# /BDD-gherkin-test-cases-for-coach-platform

Generate comprehensive Gherkin feature files with all scenario types for the coaching platform.

---

## Step 1 — Choose Input Method

Ask the user to select how they want to provide the scenario:

> **How would you like to provide the scenario?**
>
> 1. **Type manually** — I'll describe the scenario here
> 2. **Provide a file** — I'll give you a path to an existing spec/requirements file
>
> Please choose 1 or 2:

Wait for their response.

---

## Step 2 — Get Scenario Description

**If they chose 1 (manual):**
- Ask: "Describe the feature/scenario you want to generate test cases for:"
- Wait for their input
- Use their description as the intent

**If they chose 2 (file):**
- Ask: "Please provide the file path to your scenario/spec file:"
- Wait for path
- Read the file using Bash: `cat "<file-path>"`
- Use the file content as the intent

---

## Step 3 — Get Feature Area Name

Ask the user:

> **What is the feature area name?** (e.g., password-reset, user-profile, login)
>
> Use lowercase letters and hyphens only:

Wait for their input and normalize to lowercase-hyphenated slug (convert spaces to hyphens, remove special chars).

---

## Step 4 — Generate Complete Gherkin

Using the intent description and feature area name, generate comprehensive BDD scenarios.

**Generate the `.feature` test cases file (plus the `.scope` file in Step 5).** Do NOT write an `<area>.intent.md` intent/feature definition file. Only the Gherkin test cases and the `.scope` file are produced.

### File: `<area>.feature`

Gherkin format with comprehensive scenarios covering:

**Structure:**
```gherkin
Feature: <Feature Name>
  As a <actor>
  I want to <action>
  So that <benefit>

  Background:
    [Shared setup steps]

  # ── POSITIVE SCENARIOS ───────────────────────────────────────────────────────
  
  [3-5 happy path scenarios, each tagged @positive]

  # ── NEGATIVE SCENARIOS ───────────────────────────────────────────────────────
  
  [4-6 error/invalid input scenarios, each tagged @negative]

  # ── EDGE SCENARIOS ──────────────────────────────────────────────────────────
  
  [2-4 boundary/race condition scenarios, each tagged @edge]

  # ── ERROR SCENARIOS ────────────────────────────────────────────────────────
  
  [2-4 system failure scenarios, each tagged @error]
```

**Critical Requirements:**
- Every scenario has exactly ONE of: @positive, @negative, @edge, @error
- NO @chunk tags (those are added by /add-chunk-on-bdd-scenarios)
- Use clear, behavior-level Given/When/Then steps
- Reference UI elements by visible labels/placeholders (not technical selectors)
- Style: match the login.feature format (use the style reference below)
- Minimum 12 total scenarios, maximum 25

**Style Reference (match this format exactly):**
```gherkin
Feature: User Login
  As a registered user
  I want to log in to my CoachCert account
  So that I can continue my training and track my progress

  Background:
    Given I am on the Login page

  # ── POSITIVE SCENARIOS ───────────────────────────────────────────────────────

  Scenario: Successful login with valid credentials
    Given I enter "ali@example.com" in the Email field
    And I enter "SecurePass1" in the Password field
    When I click the "Sign In" button
    Then I am logged in successfully
    And I am redirected to the dashboard

  Scenario: Login with correct email but wrong password
    Given I enter "ali@example.com" in the Email field
    And I enter "WrongPass1" in the Password field
    When I click the "Sign In" button
    Then I see an error message "Invalid login credentials"
    And I am not redirected away from the Login page

  # ── ERROR SCENARIOS ──────────────────────────────────────────────────────────

  Scenario: Server returns a network error during login
    Given I enter "user@test.com" in the Email field
    And I enter "ValidPass1" in the Password field
    And the server is unreachable
    When I click the "Sign In" button
    Then I see an error message "Unable to connect. Please check your internet connection."
    And I am not redirected away from the Login page
```

---

## Step 5 — Write Files to Disk

Create the directory and write two files (do NOT write an `<area>.intent.md` file):

1. Create directory: `/home/tbd/Desktop/Coaching platform/coaching-platform/tests/features/<area>/`
2. Write `<area>.feature` to that directory
3. Write `.scope` file (see below for format)

### Generating the .scope File

This is the **Coaching Platform** repo — a React + TypeScript + Supabase app. There is NO `taleemabad_core` Django backend and NO `frontend/apps/school-app/` monorepo here. All source lives under `src/`. Analyze the feature to identify the `src/` paths it touches.

**Format (match the existing `tests/features/<area>/.scope` files, e.g. login and signup):**
```
# <Area> feature scope
src/pages/<Page>.tsx
src/contexts/<Context>.tsx
src/hooks/<useHook>.ts
src/lib/apiClients/<client>.ts
src/components/<Component>.tsx
```

**Rules:**
- Each `.scope` file lists the `src/` modules/paths that this feature touches.
- Use real paths that exist in THIS repo (`src/pages/`, `src/hooks/`, `src/contexts/`, `src/components/`, `src/lib/`). Verify a path exists before listing it.
- Supabase DB changes (when relevant) live under `supabase/migrations/` — list that directory, not a Django path.
- Open with a single `# <Area> feature scope` comment line; optionally group related paths with extra `#` comments.
- List only the TOP-LEVEL paths that would be modified (don't list every file).
- File name is `.scope` (no prefix like `<area>.scope`).

Use the Write tool to write the `.scope` file to the feature directory.

---

## Step 6 — Print Summary

Display the output to the user:

```
✅ Generated BDD feature files for '<area>'

Files created:
  • /home/tbd/Desktop/Coaching platform/coaching-platform/tests/features/<area>/<area>.feature
  • /home/tbd/Desktop/Coaching platform/coaching-platform/tests/features/<area>/.scope

Scenario Summary:
  @positive: N scenarios (happy paths)
  @negative: N scenarios (error conditions)
  @edge: N scenarios (boundary cases)
  @error: N scenarios (system failures)
  ────────────────
  Total: N scenarios

Next step: Run /add-chunk-on-bdd-scenarios to add @chunk tags above all scenarios.
```

---

## Error Handling

- **File not found (step 2):** Ask user to verify the path and try again
- **Invalid area name (step 3):** Reject special characters and uppercase, ask for retry
- **Generation fails:** Report the error and ask user to provide more specific description
- **File write fails:** Confirm directory exists and has write permissions, ask user to verify project path

---

## Key Rules

- ✅ DO generate comprehensive scenarios across all 4 types
- ✅ DO embed the style reference in this SKILL.md (above) so it's always available
- ✅ DO use behavior-level language (what users see/do)
- ✅ DO NOT add @chunk tags (those are for /add-chunk-on-bdd-scenarios)
- ✅ DO NOT add implementation details to steps
- ✅ DO NOT duplicate scenarios or have near-duplicates
- ✅ DO create exactly 2 files per run (feature + .scope)
- ✅ DO NOT create an `<area>.intent.md` file — only the `.feature` test cases and `.scope`
- ✅ DO auto-generate .scope file listing backend and frontend paths affected
- ✅ DO follow the Community/.scope pattern (no feature name prefix, just `.scope`)
