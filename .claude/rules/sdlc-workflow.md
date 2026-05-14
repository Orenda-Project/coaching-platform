# Mandatory SDLC Workflow

This rule applies to every new feature, bug fix, refactor, architecture change, API change, database change, UI change, test change, or deployment-related change.

Claude must not jump directly into code.

Before writing or modifying code, Claude must complete the SDLC analysis below unless the user explicitly says: "implement directly" or "skip planning".

## Required Workflow

### 1. Requirements Analysis

Claude must first:

- Understand the problem clearly
- Identify the root cause when it is a bug
- List functional requirements
- List non-functional requirements
- Ask clarifying questions if the requirement is ambiguous

### 2. Planning

Before coding, Claude must explain:

- Implementation plan
- Affected files
- Risks and dependencies
- Database impact
- API impact
- Security considerations
- Rollback strategy if needed

### 3. Design

Claude must provide:

- Architecture decisions
- Schema changes if any
- Component interactions
- API contracts if any
- State management changes if any
- Authentication and authorization impact if any

### 4. Development

When coding, Claude must:

- Write production-grade code
- Follow clean architecture principles
- Keep code modular and maintainable
- Avoid duplication
- Preserve backward compatibility
- Add comments only where necessary

### 5. Testing

Claude must always include:

- Unit test strategy
- Integration test strategy
- Edge cases
- Failure cases
- Manual testing steps

### 6. Deployment

Before deployment, Claude must explain:

- Migration steps
- Environment variable changes
- CI/CD impact
- Rollback process
- Monitoring and logging considerations

### 7. Maintenance

After implementation, Claude must identify:

- Technical debt
- Future improvements
- Performance optimizations
- Security improvements

## Bug Fix Rules

For bug fixes, Claude must always cover:

1. How to reproduce the issue
2. Root cause
3. Why it happened
4. Fix approach
5. Prevention strategy

## Required Response Format

Claude must structure development responses using this format:

1. Problem Analysis
2. Root Cause
3. Requirements
4. Implementation Plan
5. Code Changes
6. Testing Plan
7. Deployment Notes
8. Future Improvements

## Hard Rule

Never start editing files before giving the SDLC analysis and implementation plan.

## Branch Workflow

All work must be done in feature branches:

- Create a feature branch from staging: `feature/<descriptive-name>`
- Create a PR to staging
- Never merge without user permission
- Never push directly to main or staging
