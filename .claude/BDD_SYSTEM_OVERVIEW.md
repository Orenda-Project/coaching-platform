# Intent-Driven BDD System Overview

This document explains the complete `/bdd` + `/add` command system for managing BDD test cases as single-source-of-truth artifacts.

## System Architecture

```
tests/features/
└── <area>/
    ├── <area>.intent.md       ← intent definition (created by /bdd)
    ├── <area>.feature         ← canonical Gherkin with all scenario types
    └── <area>.scope           ← IDD scope boundary (created by /add)
```

## Two-Command Workflow

### Step 1: `/bdd <area>` — Authoring

**What it does:**
- Takes a feature area name and optional natural language intent description
- Dispatches the `bdd-generator` sub-agent to create comprehensive Gherkin
- Generates three files: `.intent.md`, `.feature`, `.scope`
- The `.feature` file includes all scenario types: @positive, @negative, @edge, @error
- No `@chunk` tags are added yet

**Example:**
```bash
/bdd login --description "User authenticates with email and password"
```

**Output:**
- `tests/features/login/login.intent.md` — structured intent definition
- `tests/features/login/login.feature` — 18 scenarios covering all types
- `tests/features/login/login.scope` — placeholder scope file

**Scenario Coverage in Generated `.feature`:**
```
@positive scenarios (happy paths):
  • Successful login with valid credentials
  • Login page shows all required fields
  • Loading state is shown during login
  • Navigation to sign up page
  • ... (total: 6 scenarios)

@negative scenarios (error conditions):
  • Submit with both fields empty
  • Submit with email field missing
  • Submit with password field missing
  • Login with wrong password
  • Login with non-existent email
  • Whitespace-only fields treated as empty
  • Forgot password form submitted empty
  • Forgot password with unknown email
  • ... (total: 8 scenarios)

@edge scenarios (boundaries):
  • User retries after failed login
  • Multiple rapid login attempts
  • ... (total: 2 scenarios)

@error scenarios (system failures):
  • Server is unreachable
  • Server returns 5xx error
  • Request times out
  • Session expires mid-login
  • ... (total: 4 scenarios)
```

### Step 2: `/add <path-to-feature-file>` — Tagging

**What it does:**
- Reads an existing `.feature` file
- Adds `@chunk` tag above every scenario (if not already present)
- Creates a `.scope` file alongside it
- Idempotent — safe to run multiple times without duplicating tags

**Example:**
```bash
/add tests/features/login/login.feature
```

**Output:**
- `tests/features/login/login.feature` — modified with `@chunk` tags added
- `tests/features/login/login.scope` — ready for manual source path addition
- Console: path to the `.scope` file

**What the `.feature` looks like after `/add`:**
```gherkin
Feature: User Login
  ...

Background:
  Given I am on the Login page

# ── POSITIVE SCENARIOS ───────────────────────────────────────────────────────

@chunk
Scenario: Successful login with valid credentials
  Given I enter "user@example.com" in the Email field
  ...

@chunk
Scenario: Login page shows all required fields
  Then I can see the Email field
  ...

# ── NEGATIVE SCENARIOS ───────────────────────────────────────────────────────

@chunk
Scenario: Submit login form with both fields empty
  Given I have not entered any data in the form
  ...
```

## File Roles & Responsibilities

### `.intent.md` — Permanent Asset

**Purpose:** Captures the "why" behind the feature before implementation

**Content:**
```markdown
# Login Feature — Intent Definition

## Feature
User authentication with email and password

## Actors & Preconditions
- Actor: unregistered or returning user
- Precondition: account must exist with matching credentials

## Key Behaviors
- User can log in with valid email and password
- User receives clear error for invalid credentials
- User can reset forgotten password
- Loading state shows during authentication

## Known Constraints
- Password reset emails expire after 24 hours
- Max 3 failed login attempts before temporary lockout
- Session timeout after 30 minutes of inactivity

## Out of Scope
- Social login (OAuth)
- Multi-factor authentication
- Account lockout recovery flow
```

**Lifecycle:**
- Created once by `/bdd`
- Stored in version control
- Updated only when feature intent fundamentally changes (rare)
- Never deleted or regenerated

### `.feature` — Canonical Source of Truth

**Purpose:** Single authoritative specification for all test scenarios

**Content:**
- Feature description (As a... I want to... So that...)
- Background: shared preconditions
- All scenario types (@positive, @negative, @edge, @error) in one place
- Clear behavior-level Given/When/Then steps
- No implementation details
- No duplicates or near-duplicates

**Lifecycle:**
- Created once by `/bdd`
- Updated if test coverage gaps discovered (with `--force`)
- Used by `/add` for tagging
- Read by E2E execution tools
- Read by IDD validation pipeline
- Stored in version control as-is (never regenerated)

**Why it's the source of truth:**
- No duplication across qa-agent, E2E, tests/features, src/test
- Single location to understand all test scenarios
- All pipelines (E2E, IDD) read from the same file
- Changes to test intent happen here first, then propagate

### `.scope` — IDD Validation Boundary

**Purpose:** Declares which source files are relevant to this feature

**Content:**
```
# Login feature scope
src/pages/Login.tsx
src/contexts/AuthContext.tsx
src/hooks/useAuth.ts
```

**Lifecycle:**
- Created by `/add` with placeholder paths
- User edits to add real source file paths
- Used by IDD validation pipeline to know what to analyze
- Stored in version control

**How to populate `.scope`:**
1. Run `/add` to create the file with examples
2. Edit the file and replace placeholder paths with actual ones
3. Include only files that contain logic for this feature
4. Commit alongside the `.feature` file

## One-Time Generation → Repeated Verification

### The One-Time Part (Intention Phase)

```
User writes intent
         ↓
/bdd <area> [--description "..."]
         ↓
Sub-agent generates complete Gherkin + intent.md + scope
         ↓
Three files written to tests/features/<area>/
         ↓
Developer reviews and approves the intent
```

**Important:** Feature files are generated once and kept. If intent changes significantly, use `/bdd <area> --force` to regenerate. But for most projects, the initial generation is the canonical source.

### The Repeated Part (Verification Phase)

```
Code is written & pushed to git
         ↓
User runs IDD validation pipeline (separate manual step)
         ↓
IDD reads the .feature file (same one as E2E)
         ↓
IDD produces coverage report
         ↓
User reviews report and understands:
  - Which scenarios have code coverage
  - Which scenarios are missing implementation
  - Which scenarios are partial or violated
```

## Integration Points

### With E2E Testing (Future: `/bdd-verify`)

When E2E execution is needed:
1. `/add` ensures `@chunk` tags are on all scenarios
2. E2E tool reads the `.feature` file
3. E2E tool executes scenarios via Chrome MCP
4. E2E tool produces PASS/FAIL report

**Note:** `/bdd-verify` command is planned but not yet implemented. For now, E2E execution is a manual step using existing tools.

### With IDD Validation Pipeline

The IDD pipeline (skills already built) integrates as:
1. User populates `.scope` file with source paths
2. User runs IDD pipeline manually (separate from these commands)
3. IDD reads the `.feature` file (same one, never regenerated)
4. IDD reads the `.scope` file for scope boundary
5. IDD produces coverage verdict: COVERED / PARTIAL / MISSING / VIOLATION
6. User reviews report on Git before merging

**Why separation of concerns:**
- `/bdd` and `/add` are pure authoring tools
- IDD validation is triggered separately, giving developers control
- E2E execution is triggered separately, using pre-recorded scenarios
- No unexpected browser sessions, no regeneration, no wasted tokens

## File Status & Idempotency

### `/bdd` Command Behavior

| Situation | Behavior |
|-----------|----------|
| Feature doesn't exist | Creates all three files |
| Feature exists, no `--force` | Shows existing intent, exits gracefully |
| Feature exists, with `--force` | Overwrites all three files (with warning) |

### `/add` Command Behavior

| Situation | Behavior |
|-----------|----------|
| Feature has no `@chunk` tags | Adds them above every scenario |
| Feature already has `@chunk` tags | Skips, reports "already processed" |
| Run twice on same file | Idempotent — no duplicate tags |

## Production Best Practices

### Committing Feature Files

1. **Always commit all three files together:**
   ```bash
   git add tests/features/<area>/
   git commit -m "feat: add <area> BDD test scenarios"
   ```

2. **Never regenerate after code is written:**
   - Feature files are source of truth, not derived artifacts
   - If you need to change scenarios, update intent and re-run with `--force`
   - This creates a clear commit history of intent changes

3. **Keep `.scope` files up-to-date:**
   - After code changes, check if new files should be added to `.scope`
   - IDD validation accuracy depends on correct scope declaration
   - Include in same commit as code changes when relevant

### Code Review Workflow

1. Developer writes feature via `/bdd`
2. Team reviews `.feature` file (behavior), `.intent.md` (intent)
3. Developer writes code matching the feature
4. Run IDD pipeline to validate coverage
5. Review IDD report as part of code review
6. Merge with confidence

## Extensibility & Future Improvements

This system is designed for easy harness improvements:

**Without touching existing commands:**
- Add a new skill that reads `.feature` files and produces different reports
- Add a new skill that executes scenarios differently (API instead of browser, for example)
- Add performance assertions to scenario steps
- Add cross-scenario validation (e.g., "all negative scenarios should fail the same way")

**Clean integration points:**
- All features live in `tests/features/<area>/`
- All features follow the same three-file structure
- All features use the same Gherkin syntax and tag strategy
- IDD pipeline reads from `.feature` and `.scope` — no changes needed when new scenarios are added

## Files Created

- **`/.claude/agents/bdd-generator.md`** — Sub-agent that converts intent → Gherkin + supporting files
- **`/.claude/commands/bdd.md`** — `/bdd` command orchestrator
- **`/.claude/commands/add.md`** — `/add` command for tagging and scope creation

## Next Steps (User's Next Actions)

1. **Try `/bdd signup`** to generate a signup feature
   - Review the generated `.feature` file
   - Check if the scenarios match your understanding of the signup flow
   - If not, iterate with `/bdd signup --force --description "..."` to refine

2. **Run `/add tests/features/signup/signup.feature`** to add @chunk tags
   - Check that tags were added
   - Verify the `.scope` file was created

3. **Edit the `.scope` file** to add real source file paths
   - Include files that handle signup logic
   - Keep scope focused on signup-specific code

4. **When ready to validate:** Run IDD pipeline manually to check code coverage
   - IDD will read the `.feature` and `.scope` files
   - IDD will produce a coverage report
   - Review report to understand what's implemented vs. missing

## Troubleshooting

**Q: Feature file doesn't exist after running `/bdd`**
A: Check the area name is lowercase-hyphenated. Verify `tests/features/<area>/` directory was created. Check file permissions.

**Q: `@chunk` tags weren't added**
A: Check the `.feature` file has proper Gherkin syntax with `Scenario:` or `Scenario Outline:` lines. If syntax is malformed, `/add` may skip them. Try `/add` again after fixing syntax.

**Q: `.scope` file is empty or incomplete**
A: The `/add` command creates a placeholder. You must edit it to add your actual source file paths. This is intentional — only you know which files implement the feature.

**Q: Should I regenerate features regularly?**
A: No. Generate once, keep forever. Features are the source of truth. If they need to change, it's a business change, not a derived update.

## Summary

This system provides:
- ✅ **One-time authoring** — `/bdd` generates complete, comprehensive Gherkin
- ✅ **Single source of truth** — all test scenarios in one `.feature` file
- ✅ **Tagging & scope** — `/add` adds `@chunk` tags and creates `.scope` file
- ✅ **Reusability** — same scenarios used by E2E, IDD, and future tools
- ✅ **Maintainability** — clean separation of intent, specification, and validation
- ✅ **Token efficiency** — scenarios are written once, then reused
- ✅ **Extensibility** — new tools can read `.feature` and `.scope` without changes to these commands
