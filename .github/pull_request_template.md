# Pull Request: [Feature/Fix Description]

## 📝 Description
<!-- Describe what this PR does. Link to Jira ticket if applicable. -->

Closes: [JIRA-XXXX or GitHub Issue #XXX]

## 🎯 Type of Change
- [ ] New feature
- [ ] Bug fix
- [ ] Documentation update
- [ ] Performance improvement
- [ ] Refactoring
- [ ] Dependency update

## 🔍 Changes Made
<!-- List the main changes -->
- [ ] Change 1
- [ ] Change 2
- [ ] Change 3

## 🧪 E2E Testing Checklist

**Required before merging to staging:**

- [ ] Feature tested locally: `npm run dev`
- [ ] No console errors (DevTools → Console)
- [ ] Signup test: created test user `testcoach+staging+[random]@example.com`
- [ ] Baseline assessment: answered questions, received persona (A/B/C/D)
- [ ] Module viewing: clicked Module 1, video played
- [ ] Content gate: video 90% watched before quiz unlocks
- [ ] Quiz: answered questions, score calculated correctly
- [ ] Module completion: passed at 80%+ score
- [ ] Dashboard: shows completed modules and next module
- [ ] Endline: accessible only after all modules passed
- [ ] Certificate: generated and PDF downloads correctly
- [ ] Supabase: new user appears in `auth.users` table
- [ ] Supabase: new profiles/assessments created in correct tables
- [ ] Mobile responsive: tested at 375px viewport
- [ ] No sensitive data in code: no API keys, passwords, emails hardcoded
- [ ] Code follows project conventions and standards

## 📸 Screenshots (if UI change)
<!-- Add screenshots showing the change -->

## 🔄 Deployment Checklist
- [ ] Tested on staging environment (if auto-deployed)
- [ ] No breaking changes to database schema (or migrations included)
- [ ] Environment variables documented (if new ones added)
- [ ] Performance: page load time acceptable

## 🚨 Breaking Changes
- [ ] This PR introduces breaking changes (describe below)
- [ ] Requires data migration
- [ ] Requires configuration change

**If checked, describe the impact:**

## 📋 Checklist
- [ ] Code follows project standards (`DEVELOPMENT_STANDARDS.md`)
- [ ] No hardcoded secrets or sensitive data
- [ ] Tests added/updated (if applicable)
- [ ] Documentation updated (if needed)
- [ ] Commit messages are clear and descriptive
- [ ] No merge conflicts with `staging` branch

## 🔗 Related Issues
<!-- Link to related issues or PRs -->
- Related to: [Issue/PR]
- Depends on: [Issue/PR]
- Blocked by: [Issue/PR]

## 👀 Reviewers
<!-- Tag the reviewer(s) -->
@jalal.khan
@hammad.sarfraz

## ⚠️ Notes for Reviewers
<!-- Any specific areas to focus on or known issues -->

---

**DO NOT MERGE** until:
1. ✅ Code review approved
2. ✅ All E2E tests pass (checkbox above)
3. ✅ CI/CD (GitHub Actions) passes

**Remember:** This goes to staging first, then production after staging QA passes.

