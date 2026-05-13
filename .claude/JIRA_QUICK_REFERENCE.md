# Coaching Platform: Jira Workflow Quick Reference

**TL;DR:** Jira Ticket (COACH-XXXX) → Tests → Code → E2E → QA → Merge → Postmortem

---

## Every Feature Follows This

```
Create Jira (COACH-XXXX)
        ↓
Write Failing Test (npm run test)
        ↓
Implement Code (React/TS)
        ↓
Harden Tests (edge cases, A11y)
        ↓
Code Review (/coaching-review)
        ↓
E2E Tests
        ↓
QA Approval (/coaching-qa)
        ↓
Merge to staging → main
        ↓
Postmortem (/postmortem)
```

---

## Command Cheat Sheet

| Action | Command |
|--------|---------|
| **Start feature** | `/coaching-dev Add quiz retry feature` |
| **Start bugfix** | `/coaching-bugfix Fix timer reset bug` |
| **Run all tests** | `npm run test` |
| **Run single test** | `npm run test src/features/quiz/QuizRetry.spec.tsx` |
| **Watch mode** | `npm run test:watch` |
| **Coverage report** | `npm run test -- --coverage` |
| **Lint code** | `npm run lint` |
| **Dev server** | `npm run dev` |
| **Code review** | `/coaching-review` |
| **QA test** | `/coaching-qa Feature description` |
| **Log learnings** | `/postmortem` |

---

## Jira Ticket Template

```markdown
**Title:** [Feature] Quiz retry after failure

**Description:**

## Problem
Users cannot retry quizzes. They must start over.

## Acceptance Criteria
- [ ] Retry button shown after failure
- [ ] Quiz state resets (score, timer, selections)
- [ ] Attempt count increments (max 3)
- [ ] Show "Attempt 2/3" counter
- [ ] Disable retry after max attempts

## Technical
- Component: QuizRetry.tsx
- Store: useQuizStore (Zustand)
- Tests: Vitest + React Testing Library
- Database: quiz_attempts table
```

---

## TDD Cycle (Inside Every Task)

### 🔴 RED: Write Failing Test
```typescript
// src/features/quiz/__tests__/QuizRetry.spec.tsx
it('should display retry button when quiz fails', () => {
  render(<QuizRetry quizId="quiz-1" />);
  expect(screen.getByRole('button', { name: /retry quiz/i })).toBeInTheDocument();
});

npm run test src/features/quiz/__tests__/QuizRetry.spec.tsx  # ❌ FAILS
```

### 🟢 GREEN: Implement Code
```typescript
// src/features/quiz/QuizRetry.tsx
export const QuizRetry: FC = ({ quizId }) => {
  return <button>Retry Quiz</button>;
};

npm run test src/features/quiz/__tests__/QuizRetry.spec.tsx  # ✅ PASSES
```

### 🔵 REFACTOR: Clean & Harden
```typescript
// Add edge cases, accessibility, integration tests
// Verify coverage ≥ 80%
npm run test src/features/quiz/ -- --coverage  # ✅ All pass
```

---

## Test File Examples

**Unit Test:**
```typescript
describe('QuizRetry - Unit (COACH-1234)', () => {
  it('should show attempt counter', () => {
    render(<QuizRetry attempts={1} maxAttempts={3} />);
    expect(screen.getByText(/attempt 1\/3/i)).toBeInTheDocument();
  });
});
```

**Integration Test (with Supabase):**
```typescript
describe('QuizRetry - Integration (COACH-1234)', () => {
  it('should save attempt to database', async () => {
    vi.spyOn(supabase, 'from').mockReturnValue(...);
    render(<QuizRetry quizId="quiz-1" />);
    fireEvent.click(screen.getByRole('button'));
    await waitFor(() => expect(supabase.from).toHaveBeenCalled());
  });
});
```

**Accessibility Test:**
```typescript
it('should announce max attempts to screen readers', () => {
  render(<QuizRetry attempts={3} maxAttempts={3} />);
  const msg = screen.getByText(/max attempts/i);
  expect(msg).toHaveAttribute('role', 'status');
  expect(msg).toHaveAttribute('aria-live', 'polite');
});
```

---

## Commit Message Format

```
COACH-1234: Add quiz retry feature

- Implement QuizRetry component
- Reset quiz state on retry (score, timer, selections)
- Track attempt count (max 3, server-verified)
- Show attempt counter and disable after max

Tests: src/features/quiz/__tests__/QuizRetry.spec.tsx (14 tests, 87% coverage)
Refs: COACH-1234, business_rules.md
```

---

## Checklist Before PR

```
✅ All tests pass:        npm run test
✅ Coverage ≥ 80%:        npm run test -- --coverage
✅ No lint errors:        npm run lint
✅ TypeScript OK:         npm run type-check
✅ A11y tested:           Manual + automated tests in __tests__
✅ Branch correct:        git branch (should be COACH-XXXX-slug)
✅ Commits reference ticket: git log
✅ No secrets in code:    grep -r "password\|token\|secret"
✅ E2E tests pass:        Manual or CI validation
```

---

## Code Review Checklist

When you `/coaching-review`:

```
✅ Tests cover acceptance criteria
✅ Edge cases tested (network errors, max attempts, timing)
✅ Accessibility verified (WCAG A11y)
✅ No unnecessary re-renders (checked via DevTools)
✅ State updates are immutable (Zustand best practices)
✅ Supabase integration correct (RLS, error handling)
✅ DSM components used (design system compliance)
✅ No hard-coded values (config/constants)
✅ Documentation updated
```

---

## E2E Test Checklist

When you `/coaching-qa`:

```
✅ Signup flow works
✅ Feature works in staging environment
✅ Works on desktop + mobile (responsive)
✅ Works in Chrome, Safari, Firefox
✅ Error states handled gracefully
✅ Loading states show properly (spinners, skeletons)
✅ Accessibility: Tab navigation works
✅ Accessibility: Screen reader friendly
✅ No console errors
✅ Network errors handled
```

---

## Postmortem Template

After merge, run `/postmortem`:

```markdown
# COACH-1234 Postmortem

## Date
2026-05-13

## What Went Well
✅ Vitest caught state mutation early
✅ React Testing Library made tests readable
✅ E2E verified full user flow

## What Was Hard
⚠️ Timer reset logic complexity
⚠️ Debouncing race condition
⚠️ Accessibility announcements

## Harness Improvements
1. Created quizFactory for test data
2. Created supabaseMock helper
3. Updated patterns.md documentation
4. Added rule: Always debounce quiz actions

## Metrics
- Tests: 14 (unit/integration/E2E)
- Coverage: 87%
- Review rounds: 1
- E2E time: 2.3 min
```

---

## Common Issues & Fixes

### "Tests failing locally"
```bash
# Clean install
rm -rf node_modules package-lock.json
npm install
npm run test
```

### "Vitest not finding component"
```bash
# Check import path
import { QuizRetry } from '../QuizRetry'  // ✅ Correct
import QuizRetry from '../QuizRetry'      // ❌ Wrong (no named export)
```

### "Supabase mock not working"
```typescript
// ✅ Correct: at top of test file
vi.mock('../api/supabase', () => ({
  supabase: { from: vi.fn() }
}));

// ❌ Wrong: inside test
it('test', () => {
  vi.mock(...);  // Too late!
});
```

### "A11y test failing"
```typescript
// Use role queries (more accessible)
screen.getByRole('button', { name: /retry/i })    // ✅
screen.getByTestId('retry-button')               // ⚠️ Less ideal

// Add aria-label if needed
<button aria-label="Retry quiz attempt">Retry</button>
```

### "E2E test timing issues"
```typescript
// Use waitFor (not static waits)
await waitFor(() => {
  expect(screen.getByText(/attempt 2/)).toBeInTheDocument();
});

// Not:
await page.wait(1000);  // ❌ Brittle
```

---

## Rules (Enforce Always)

| ❌ Never | ✅ Always |
|---------|---------|
| Code without ticket | Create COACH-XXXX first |
| Skip tests | Write tests first (TDD) |
| Hardcode values | Use constants/config |
| Ignore a11y | Test accessibility |
| Skip E2E | Run E2E before merge |
| Skip code review | Run /coaching-review |
| Skip postmortem | Log learnings |

---

## Example: Full Feature (30 min)

```bash
# 1. Start
/coaching-dev Add quiz retry UI component
# → Creates COACH-1234 + branch COACH-1234-quiz-retry

# 2. Write test (should fail)
cat > src/features/quiz/__tests__/QuizRetry.spec.tsx << 'EOF'
it('should show retry button', () => {
  render(<QuizRetry />);
  expect(screen.getByRole('button', { name: /retry/i })).toBeInTheDocument();
});
EOF
npm run test src/features/quiz/__tests__/QuizRetry.spec.tsx  # ❌

# 3. Implement (test passes)
cat > src/features/quiz/QuizRetry.tsx << 'EOF'
export const QuizRetry = () => <button>Retry Quiz</button>;
EOF
npm run test src/features/quiz/__tests__/QuizRetry.spec.tsx  # ✅

# 4. Harden (add edge cases, a11y, integration)
npm run test src/features/quiz/ -- --coverage  # 87% ✅

# 5. Review
/coaching-review  # ✅ Approved

# 6. E2E test (manual or automated)
npm run e2e                                     # ✅ Pass

# 7. QA
/coaching-qa Quiz retry feature works in staging  # ✅ Pass

# 8. Merge
git push → PR → staging validation → main

# 9. Learn
/postmortem  # Log findings
```

---

## Quick Facts

- **Project Key:** COACH-XXXX
- **Jira:** https://orendatrust.atlassian.net
- **Stack:** React 18 + TypeScript + Supabase + Vitest
- **Test Framework:** Vitest + React Testing Library
- **State Management:** Zustand
- **E2E:** Playwright (or manual testing in QA)
- **CI/CD:** GitHub Actions + Railway

---

## Links

- Full guide: `.claude/JIRA_WORKFLOW_INTEGRATION.md`
- Autonomous workflow: `AUTONOMOUS_WORKFLOW_SYSTEM.md`
- Quick ref: `WORKFLOW_QUICK_REFERENCE.md`
- Patterns: `docs/memory/patterns.md`
- Standards: `DEVELOPMENT_STANDARDS.md`

---

**Remember:** Tests first. Always. Every feature starts with a failing test.

**RED → GREEN → REFACTOR → REPEAT**

---

**Created:** 2026-05-13 | **For:** Coaching Platform
