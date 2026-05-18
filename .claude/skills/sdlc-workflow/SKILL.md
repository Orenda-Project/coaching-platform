---
name: sdlc-workflow
description: Mandatory SDLC workflow for new features, bug fixes, refactors, architecture changes, API changes, database changes, UI changes, tests, and deployment-related work. Use before implementation.
---

Follow the mandatory SDLC workflow for this task:

$ARGUMENTS

Before writing or modifying code, produce this structure:

1. Problem Analysis
2. Root Cause
3. Requirements
4. Implementation Plan
5. Code Changes
6. Testing Plan
7. Deployment Notes
8. Future Improvements

Rules:

- Do not jump directly into code.
- Identify affected files before editing.
- Ask clarifying questions if requirements are unclear.
- For bugs, include reproduction steps, root cause, why it happened, fix approach, and prevention strategy.
- Include unit, integration, edge case, failure case, and manual testing plans.
- Include deployment, rollback, monitoring, logging, and future improvement notes.
- All work must be done in feature branches. Create PRs to staging. Never merge without user permission.
