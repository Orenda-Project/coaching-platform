# BDD System Quick Start

## What You Just Built

A two-command system for managing BDD test cases as single-source-of-truth artifacts:

- **`/bdd`** — Generates complete Gherkin feature files from natural language intent
- **`/add`** — Adds `@chunk` tags and creates `.scope` files for IDD validation
- **`bdd-generator` agent** — Turns intent into professional Gherkin with all scenario types

## Try It Now (5 minutes)

### 1. Generate a feature file

```bash
/bdd password-reset --description "User can reset a forgotten password via email"
```

This creates three files in `tests/features/password-reset/`:
- `password-reset.intent.md` — the intent definition
- `password-reset.feature` — complete Gherkin (all scenario types)
- `password-reset.scope` — IDD scope boundary (empty placeholder)

**Check the output:**
- Feature file should have @positive (happy paths), @negative (errors), @edge (boundaries), @error (system failures)
- Scenario count shown for each type
- NO `@chunk` tags yet (added in step 2)

### 2. Add @chunk tags and create scope file

```bash
/add tests/features/password-reset/password-reset.feature
```

This modifies the feature file and creates the scope:
- Adds `@chunk` above every scenario (idempotent)
- Creates `password-reset.scope` with placeholder paths
- Prints path to the `.scope` file

**Check the output:**
- Scenario count showing how many got `@chunk` tags
- Path to the newly created `.scope` file

### 3. Update the scope file (manual step)

Edit `tests/features/password-reset/password-reset.scope`:

```
# Password reset feature scope
src/pages/PasswordReset.tsx
src/hooks/usePasswordReset.ts
src/utils/email-validation.ts
```

Add the actual source files that implement the password reset feature.

### 4. Done

Commit all three files:
```bash
git add tests/features/password-reset/
git commit -m "feat: add password reset BDD scenarios"
```

The feature file is now the single source of truth for:
- What should be tested
- How the feature should behave
- Which source files implement it

## Key Concepts

### The Three Files

| File | Created By | Content | Purpose |
|------|-----------|---------|---------|
| `.intent.md` | `/bdd` | Feature description, behaviors, constraints | Permanent record of intent |
| `.feature` | `/bdd` | All Gherkin scenarios (@positive, @negative, @edge, @error) | Single source of truth for testing |
| `.scope` | `/add` | Source file paths | IDD validation boundary |

### No Regeneration

Unlike typical test generators, feature files are not regenerated. They are **written once and kept forever**.

- Use `/bdd <area> --force` only if intent changes significantly
- Feature files are source of truth, not derived artifacts
- All downstream tools (E2E, IDD) read from the same file

### @chunk Tags

The `@chunk` tag marks scenarios as "ready for execution":
- Added by `/add` to all scenarios
- Used by E2E tools to know which scenarios can run
- Used by IDD pipeline to know which scenarios to validate
- Safe to run multiple times without duplicating tags

### Idempotent Operations

Both commands are safe to run repeatedly:
- `/bdd <area> --force` overwrites with new generation
- `/add <feature-file>` detects existing `@chunk` tags and skips

No corruption, no duplicates, no broken state.

## Example: Login Feature

Already exists at `tests/features/login/`:

```bash
# Feature file is already there with complete scenarios
cat tests/features/login/login.feature

# View the intent
cat tests/features/login/login.intent.md

# Check the scope
cat tests/features/login/login.scope
```

The login feature has:
- 18 scenarios across all types
- @chunk tags on all scenarios (added by `/add`)
- Placeholder source file paths in `.scope`

## Next Steps

1. **Try generating a new feature:**
   ```bash
   /bdd user-profile --description "User can view and edit their profile information"
   ```

2. **Add @chunk tags:**
   ```bash
   /add tests/features/user-profile/user-profile.feature
   ```

3. **Edit the scope file:**
   ```bash
   # Update tests/features/user-profile/user-profile.scope with actual source paths
   ```

4. **Use the feature file:**
   - Run IDD validation (when you're ready)
   - Run E2E tests (when `/bdd-verify` is implemented)
   - Reference in code reviews
   - Track in git history

## Common Questions

**Q: Can I edit the .feature file manually?**
A: Yes. Feature files are text — edit them directly if needed. Just don't duplicate or remove `@chunk` tags accidentally.

**Q: What if I need to change the intent?**
A: Edit the `.intent.md` file, then run `/bdd <area> --force` to regenerate the `.feature` file. This creates a clear commit showing intent changes.

**Q: Do I have to use all four scenario types?**
A: The generator creates all four (@positive, @negative, @edge, @error). In practice, some features may not have edge cases or error scenarios — that's fine. Existing scenarios stay, just with fewer of one type.

**Q: Where do I run `/bdd` and `/add` commands?**
A: In Claude Code, using the /bdd and /add slash commands directly in the chat. They're registered as project-level commands.

**Q: What happens if the generator creates duplicate scenarios?**
A: The generator is designed to produce clean, non-redundant scenarios. If you run `/bdd <area> --force` and get duplicates, you've changed the intent significantly enough to warrant manual cleanup. Edit the `.feature` file to remove true duplicates.

**Q: Can I use these commands in CI/CD?**
A: Not directly. These are authoring commands for developers. Run them locally, commit results. IDD validation and E2E execution (downstream) can be in CI.

## Files You Now Have

- **`/.claude/agents/bdd-generator.md`** — Sub-agent for Gherkin generation
- **`/.claude/commands/bdd.md`** — `/bdd` command
- **`/.claude/commands/add.md`** — `/add` command
- **`/BDD_SYSTEM_OVERVIEW.md`** — Complete system documentation (you're reading the quick version)

## Production Checklist

Before using in production:
- [ ] Review one generated feature file (e.g., login.feature)
- [ ] Run `/add` on it and verify @chunk tags were added
- [ ] Edit the .scope file and add real source paths
- [ ] Commit and push
- [ ] Verify files appear in GitHub

## Support

For detailed documentation, see:
- **`BDD_SYSTEM_OVERVIEW.md`** — Full system design and architecture
- **`/.claude/agents/bdd-generator.md`** — How the generator works
- **`/.claude/commands/bdd.md`** — `/bdd` command reference
- **`/.claude/commands/add.md`** — `/add` command reference
