---
description: Assemble a production-ready pull request from the current branch. Generates summary, changes, test plan, run instructions, and uses the existing PR template. Pushes branch and opens PR via gh.
argument-hint: [optional PR title]
---

# /pr $ARGUMENTS

Convert the current branch's work into a production-ready PR.

## Steps (run in order)

1. **Verify clean state**
   - `git status` — show untracked + modified files
   - `git diff main...HEAD` — show what's about to ship
   - `git log main..HEAD --oneline` — show commits

2. **Run the gate locally**
   - `npm run lint` — must pass
   - `npm run typecheck` — must pass
   - `npm run test` — must pass
   - `npm run test:coverage` — note the percentage
   - If any of these fail, STOP and report — do not open the PR

3. **Run the pr-reviewer agent**
   - Same as `/review`
   - If verdict is REJECT, STOP and report
   - If REQUEST CHANGES, surface findings and ask the user whether to proceed

4. **Push the branch** (if not already pushed)
   - `git push -u origin <current-branch>`

5. **Open the PR via `gh pr create`**
   - Base branch: `staging` (per `DEVELOPMENT_STANDARDS.md` — staging → main, never skip)
   - Title: `$ARGUMENTS` if provided, else inferred from the most recent commit subject
   - Body: filled from `.github/pull_request_template.md` PLUS:
     - Summary (1–3 bullets)
     - Files touched (grouped by `src/domain/` / `src/data/` / `src/pages/` / `supabase/migrations/` / `src/test/`)
     - Hand-off note from feature-developer (if available)
     - Edge cases addressed (from test-engineer)
     - pr-reviewer verdict + checklist
     - Coverage delta
     - Run instructions (`npm install && npm run test && npm run dev`)
   - Reviewers: `@jalal.khan @hammad.sarfraz` (per existing template)

6. **Detect stacked PRs (post-create)**
   After the PR is opened, check whether any other open PRs use this branch as their base:
   ```bash
   gh pr list --base <current-branch> --state open --json number,title,headRefName
   ```
   If the result is non-empty, surface those PRs to the user with a note:
   > **Stacked PRs detected:** PR #N (`<title>`) has this branch as its base. When this PR merges to staging, that PR's base will need retargeting:
   > ```
   > gh pr edit N --base staging
   > ```
   This catches the `s_stacked_pr_base_drift` pattern (logged in `patterns-log.jsonl`) — would have prevented the PR #44 → PR #47 retargeting work after #44 merged.

## Hard rules

- Base branch is `staging`, NOT `main`. Per `DEVELOPMENT_STANDARDS.md`.
- Never push to `main` directly. Never force-push to `main` or `staging`.
- Never `--no-verify` to skip hooks.
- If the branch contains commits authored by someone else, do NOT include `Co-Authored-By: Claude` — preserve original authorship.
- If the PR body would include API keys, emails, or other secrets visible in the diff, STOP and warn.
- If `gh` is not authenticated, fall back to printing the assembled PR body for manual creation.

## What this is NOT

- Not a deploy trigger — Railway handles that on merge to staging/main.
- Not a release-notes generator — that's a separate concern.

## Output

A live PR URL. The user can hand it to `@jalal.khan` and `@hammad.sarfraz` for human review.
