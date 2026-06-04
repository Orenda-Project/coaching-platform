# Claude Code Configuration

This folder contains Claude Code-specific configuration for the coaching platform.

## Structure

- **settings.json** — Claude Code harness settings (permissions, env vars, hooks)
- **settings.local.json** — User-specific local settings (git user, preferences)
- **agents/** — Agent definitions for routing (work-assistant, code-reviewer, etc.)
- **commands/** — Custom slash commands and shortcuts
- **rules/** — Validation rules (IDD, SDLC workflow rules, QA enforcement)
- **skills/** — Local skill definitions

## Key Files to Know

### Rules (required for IDD validation)
- `rules/idd/` — IDD validation rules (scope-boundary, behavior-analysis, qa-enforcement)
- `rules/sdlc-workflow.md` — Mandatory SDLC workflow

### Documentation in .claude/
Kept minimal. Most docs moved to `docs/` root folder (see `docs/INDEX.md`).

- `BDD_QUICK_START.md` — BDD feature file format
- `JIRA_QUICK_REFERENCE.md` — Jira integration quick reference

---

See `../docs/INDEX.md` for main documentation.
