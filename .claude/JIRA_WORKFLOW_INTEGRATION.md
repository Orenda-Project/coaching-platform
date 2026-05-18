# Coaching Platform: Jira-Integrated Development Workflow

**Adapted from taleemabad-core patterns for React + TypeScript + Supabase + Vitest**

This document integrates Jira ticket creation with the existing autonomous workflow system.

---

## Quick Start

### 1️⃣ Create Jira Ticket First

Every task begins with a Jira ticket in the **Coaching** project (key: `COACH-XXX`).

**Create via Composio:**
```bash
composio execute JIRA_CREATE_ISSUE -d '{
  "project_key": "COACH",
  "issue_type": "Task",
  "summary": "Your feature/fix description",
  "description": "Detailed context and acceptance criteria",
  "assignee": "jalal.khan@taleemabad.com"
}'
```

**Or use skills:**
```bash
/coaching-dev Build quiz retry UI component
/coaching-bugfix Fix quiz timer not resetting on retry
```

### 2️⃣ Create Feature Branch

```bash
git checkout -b COACH-XXXX-feature-slug
```

### 3️⃣ Follow the Development Pipeline

```
Jira Ticket (COACH-XXXX)
    ↓
[🔴 RED] Write Failing Tests (Vitest)
    ↓
[🟢 GREEN] Implement Code (React/TS)
    ↓
[🔵 REFACTOR] Test Hardening (edge cases, accessibility)
    ↓
Code Review (/coaching-review)
    ↓
E2E Tests (signup → baseline → modules → endline → certificate)
    ↓
QA Approval (/coaching-qa)
    ↓
Merge to staging → main
    ↓
Postmortem
```

---

## Workflow Integration with Autonomous System

The existing autonomous workflow system (`AUTONOMOUS_WORKFLOW_SYSTEM.md`) now includes Jira tracking:

| Trigger | Workflow | Jira Status | Output |
|---------|----------|-------------|--------|
| `/coaching-dev` | Feature Development | In Progress | Code + tests + PR |
| `/coaching-bugfix` | Bug Fix | In Progress | Repro test + fix + PR |
| `/coaching-qa` | QA Verification | In Review | E2E test results |
| `/coaching-review` | Code Review | In Review | Approval/changes |

---

## Stage 1: Create Jira Ticket

**Before writing any code**, create a Jira ticket with acceptance criteria.

**Ticket Template for Features:**

```markdown
**Title:** [Feature] Build quiz retry UI component

**Description:**

## Problem
Users cannot retry quizzes after failing. They must start over from scratch.

## Acceptance Criteria
- [ ] Display "Retry Quiz" button after quiz failure
- [ ] Clicking retry resets quiz state (scores, selections, timer)
- [ ] Attempt count increments (max 3 per module)
- [ ] Show attempt counter: "Attempt 2/3"
- [ ] Disable retry after max attempts (show "Max attempts reached")
- [ ] Preserve quiz history in database

## Technical Details
- UI Component: QuizRetry.tsx
- Database: Update quiz_attempts table
- API: PATCH /quizzes/{id}/retry endpoint
- Tests: Vitest + React Testing Library

## Testing Notes
- Edge cases: Max attempts, network failure during retry
- E2E: Baseline → module quiz → retry path
- Accessibility: WCAG A11y checklist

## Business Rules
- Max 3 quiz attempts per module (enforce server-side)
- Retry only available after failure (60% threshold not met)
- Previous attempt scores preserved
```

**Ticket Template for Bugs:**

```markdown
**Title:** [Bug] Quiz timer not resetting on retry

**Description:**

## Problem
When user retries a quiz after failure, the timer continues from the previous attempt instead of resetting to 0.

## Steps to Reproduce
1. Start a timed quiz (5 minutes)
2. After 2 minutes, submit answers (score < 60%)
3. Click "Retry Quiz"
4. Observe timer: starts at 3:00 instead of 5:00

## Expected Behavior
Timer resets to full duration (5 minutes)

## Actual Behavior
Timer shows remaining time from previous attempt

## Testing Notes
- Verify in both staging and production
- Test with different quiz durations (2min, 5min, 10min)
- Test timer persistence across page reload
```

---

## Stage 2: Write Test Cases (RED Phase)

**When:** Immediately after creating Jira ticket
**Owner:** You or Frontend Test Engineer
**Key Rule:** Tests FAIL first

**Example: Quiz Retry Feature**

```typescript
// src/features/quiz/__tests__/QuizRetry.spec.tsx
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { describe, it, expect, beforeEach, vi } from 'vitest';
import { QuizRetry } from '../QuizRetry';
import { useQuizStore } from '../store/quizStore';

describe('QuizRetry (COACH-1234)', () => {
  beforeEach(() => {
    // Reset store state
    useQuizStore.setState({
      quizState: 'failed',
      score: 45,
      attempts: 1,
      maxAttempts: 3,
    });
  });

  it('should display retry button when quiz fails', () => {
    render(<QuizRetry quizId="quiz-1" />);
    expect(screen.getByRole('button', { name: /retry quiz/i })).toBeInTheDocument();
  });

  it('should show attempt counter', () => {
    render(<QuizRetry quizId="quiz-1" />);
    expect(screen.getByText(/attempt 1\/3/i)).toBeInTheDocument();
  });

  it('should disable retry after max attempts', () => {
    useQuizStore.setState({ attempts: 3 });
    render(<QuizRetry quizId="quiz-1" />);
    expect(screen.getByText(/max attempts reached/i)).toBeInTheDocument();
    expect(screen.queryByRole('button', { name: /retry quiz/i })).not.toBeInTheDocument();
  });

  it('should reset quiz state on retry', async () => {
    render(<QuizRetry quizId="quiz-1" />);

    const retryBtn = screen.getByRole('button', { name: /retry quiz/i });
    fireEvent.click(retryBtn);

    await waitFor(() => {
      expect(useQuizStore.getState().quizState).toBe('active');
      expect(useQuizStore.getState().score).toBe(0);
      expect(useQuizStore.getState().attempts).toBe(2);
    });
  });

  it('should reset timer on retry', async () => {
    render(<QuizRetry quizId="quiz-1" duration={300} />);

    fireEvent.click(screen.getByRole('button', { name: /retry quiz/i }));

    await waitFor(() => {
      expect(screen.getByText(/05:00/)).toBeInTheDocument();
    });
  });

  it('should preserve quiz history in database', async () => {
    const mockSave = vi.fn();
    vi.mock('../api/quizApi', () => ({
      saveQuizAttempt: mockSave,
    }));

    render(<QuizRetry quizId="quiz-1" />);
    fireEvent.click(screen.getByRole('button', { name: /retry quiz/i }));

    await waitFor(() => {
      expect(mockSave).toHaveBeenCalledWith('quiz-1', {
        attempt: 2,
        previousScore: 45,
      });
    });
  });
});
```

**Example: Quiz Retry Business Logic Test**

```typescript
// src/features/quiz/__tests__/quizRetryLogic.spec.ts
import { describe, it, expect } from 'vitest';
import { validateRetryEligibility, resetQuizState } from '../quizRetryLogic';

describe('Quiz Retry Business Logic (COACH-1234)', () => {
  it('should allow retry when attempts < max', () => {
    const result = validateRetryEligibility({
      attempts: 1,
      maxAttempts: 3,
      score: 45,
    });
    expect(result.canRetry).toBe(true);
  });

  it('should deny retry when max attempts reached', () => {
    const result = validateRetryEligibility({
      attempts: 3,
      maxAttempts: 3,
      score: 45,
    });
    expect(result.canRetry).toBe(false);
    expect(result.reason).toBe('Max attempts reached');
  });

  it('should deny retry when passing score', () => {
    const result = validateRetryEligibility({
      attempts: 1,
      maxAttempts: 3,
      score: 75, // >= 60% = pass
    });
    expect(result.canRetry).toBe(false);
    expect(result.reason).toBe('Quiz already passed');
  });

  it('should reset quiz state properly', () => {
    const initialState = {
      score: 45,
      selectedAnswers: ['a', 'b', 'c'],
      timeRemaining: 60,
      attempts: 1,
    };

    const resetState = resetQuizState(initialState, 300);

    expect(resetState).toEqual({
      score: 0,
      selectedAnswers: [],
      timeRemaining: 300,
      attempts: 2,
    });
  });
});
```

**Run Tests (They Should FAIL):**

```bash
npm run test src/features/quiz/__tests__/QuizRetry.spec.tsx  # ❌ FAILS
```

---

## Stage 3: Feature Development (GREEN Phase)

**When:** After tests are written
**Owner:** Frontend Specialist (you or agent)
**Key Rule:** Minimum code to make tests pass

**Example: Quiz Retry Component**

```typescript
// src/features/quiz/QuizRetry.tsx
import { FC } from 'react';
import { useQuizStore } from './store/quizStore';
import { Button } from '../../shared/components/Button';
import { useQuizApi } from './api/useQuizApi';

interface QuizRetryProps {
  quizId: string;
  duration: number;
}

export const QuizRetry: FC<QuizRetryProps> = ({ quizId, duration }) => {
  const { quizState, score, attempts, maxAttempts } = useQuizStore();
  const { retryQuiz } = useQuizApi();

  const canRetry =
    quizState === 'failed' &&
    attempts < maxAttempts &&
    score < 60;

  const handleRetry = async () => {
    await retryQuiz(quizId, { attempt: attempts + 1 });
    useQuizStore.setState({
      quizState: 'active',
      score: 0,
      selectedAnswers: [],
      timeRemaining: duration,
      attempts: attempts + 1,
    });
  };

  if (quizState === 'passed') {
    return null;
  }

  if (attempts >= maxAttempts) {
    return <div className="text-center text-red-600">Max attempts reached</div>;
  }

  return (
    <div className="quiz-retry">
      <p>Attempt {attempts}/{maxAttempts}</p>
      <Button
        onClick={handleRetry}
        disabled={!canRetry}
      >
        Retry Quiz
      </Button>
    </div>
  );
};
```

**Example: Retry Logic**

```typescript
// src/features/quiz/quizRetryLogic.ts
export interface RetryEligibility {
  canRetry: boolean;
  reason?: string;
}

export function validateRetryEligibility(state: {
  attempts: number;
  maxAttempts: number;
  score: number;
}): RetryEligibility {
  if (state.attempts >= state.maxAttempts) {
    return { canRetry: false, reason: 'Max attempts reached' };
  }

  if (state.score >= 60) {
    return { canRetry: false, reason: 'Quiz already passed' };
  }

  return { canRetry: true };
}

export function resetQuizState(
  state: any,
  duration: number
) {
  return {
    ...state,
    score: 0,
    selectedAnswers: [],
    timeRemaining: duration,
    attempts: state.attempts + 1,
  };
}
```

**Commit with Jira Reference:**

```bash
git add src/features/quiz/QuizRetry.tsx src/features/quiz/quizRetryLogic.ts
git commit -m "COACH-1234: Implement quiz retry component

- Add QuizRetry component to show retry button after failure
- Reset quiz state (score, timer, selections) on retry
- Track attempt count (max 3 per module, server-verified)
- Show attempt counter and disable after max attempts
- Preserve quiz history in database via /api/quizzes/{id}/retry

Tests: src/features/quiz/__tests__/QuizRetry.spec.tsx
Related: business_rules.md (max 3 attempts, 60% pass threshold)"
```

**Run Tests (They Should PASS):**

```bash
npm run test src/features/quiz/__tests__/QuizRetry.spec.tsx  # ✅ PASSES
```

---

## Stage 4: Test Hardening (REFACTOR Phase)

**When:** Implementation passes basic tests
**Owner:** You or Frontend Test Engineer
**Key Activities:**
- Add edge case tests (boundary conditions, error states)
- Add accessibility tests (WCAG compliance)
- Add integration tests (with Supabase, authentication)
- Add E2E tests (full user flow)

**Example: Edge Cases**

```typescript
describe('QuizRetry - Edge Cases (COACH-1234)', () => {
  it('should handle network error on retry', async () => {
    const mockApi = vi.mock('../api/quizApi', () => ({
      retryQuiz: vi.fn().mockRejectedValue(new Error('Network error')),
    }));

    render(<QuizRetry quizId="quiz-1" duration={300} />);
    fireEvent.click(screen.getByRole('button', { name: /retry quiz/i }));

    await waitFor(() => {
      expect(screen.getByText(/failed to retry/i)).toBeInTheDocument();
    });
  });

  it('should handle rapid retry clicks (debounce)', async () => {
    const mockSave = vi.fn();

    render(<QuizRetry quizId="quiz-1" duration={300} />);
    const retryBtn = screen.getByRole('button', { name: /retry quiz/i });

    // Click multiple times rapidly
    fireEvent.click(retryBtn);
    fireEvent.click(retryBtn);
    fireEvent.click(retryBtn);

    await waitFor(() => {
      // Should only call API once due to debouncing
      expect(mockSave).toHaveBeenCalledTimes(1);
    });
  });

  it('should handle quiz deletion while retrying', async () => {
    vi.mock('../api/quizApi', () => ({
      retryQuiz: vi.fn().mockRejectedValue({
        status: 404,
        message: 'Quiz not found'
      }),
    }));

    render(<QuizRetry quizId="deleted-quiz" duration={300} />);
    fireEvent.click(screen.getByRole('button', { name: /retry quiz/i }));

    await waitFor(() => {
      expect(screen.getByText(/quiz not found/i)).toBeInTheDocument();
    });
  });
});
```

**Example: Accessibility Tests**

```typescript
describe('QuizRetry - Accessibility (COACH-1234)', () => {
  it('should have accessible button label', () => {
    render(<QuizRetry quizId="quiz-1" duration={300} />);
    const btn = screen.getByRole('button', { name: /retry quiz/i });
    expect(btn).toHaveAccessibleName();
  });

  it('should show aria-label for attempt counter', () => {
    render(<QuizRetry quizId="quiz-1" duration={300} />);
    expect(screen.getByText(/attempt 1\/3/i)).toHaveAttribute('aria-label');
  });

  it('should announce max attempts reached to screen readers', () => {
    useQuizStore.setState({ attempts: 3 });
    render(<QuizRetry quizId="quiz-1" duration={300} />);

    const msg = screen.getByText(/max attempts reached/i);
    expect(msg).toHaveAttribute('role', 'status');
    expect(msg).toHaveAttribute('aria-live', 'polite');
  });
});
```

**Example: Integration Test with Supabase**

```typescript
describe('QuizRetry - Integration with Supabase (COACH-1234)', () => {
  it('should save retry attempt to database', async () => {
    const { supabase } = useSupabaseClient();
    vi.spyOn(supabase, 'from').mockReturnValue({
      insert: vi.fn().mockResolvedValue({ data: { id: 'attempt-123' } }),
    } as any);

    render(<QuizRetry quizId="quiz-1" duration={300} />);
    fireEvent.click(screen.getByRole('button', { name: /retry quiz/i }));

    await waitFor(() => {
      expect(supabase.from).toHaveBeenCalledWith('quiz_attempts');
    });
  });

  it('should increment attempt count in Supabase', async () => {
    const { supabase } = useSupabaseClient();

    render(<QuizRetry quizId="quiz-1" duration={300} />);
    fireEvent.click(screen.getByRole('button', { name: /retry quiz/i }));

    await waitFor(() => {
      expect(supabase.from).toHaveBeenCalledWith('quiz_attempts');
      // Verify the insert payload
      const call = supabase.from.mock.calls[0];
      expect(call[1].attempt).toBe(2);
    });
  });
});
```

**Run Full Test Suite:**

```bash
npm run test src/features/quiz/  # ✅ All tests pass
npm run test -- --coverage        # Check coverage (target 80%+)
```

---

## Stage 5: Code Review

**When:** All tests pass
**Owner:** Code Reviewer (you or senior dev)
**Key Checks:**

**Checklist for Frontend Features:**

```markdown
## Code Review: COACH-1234 (Quiz Retry Feature)

### Component Quality
- [ ] Props interface documented (TypeScript)
- [ ] Component properly memoized if needed
- [ ] No unnecessary re-renders (checked via React DevTools)
- [ ] Event handlers properly debounced/throttled

### State Management
- [ ] Zustand store updates are immutable
- [ ] State transitions are correct (failed → retry → active)
- [ ] No unintended state mutations

### Accessibility
- [ ] Button has accessible label
- [ ] Error messages announced to screen readers
- [ ] Keyboard navigation works
- [ ] Color not the only visual indicator

### Testing
- [ ] Unit tests cover happy path
- [ ] Edge cases tested (max attempts, network errors)
- [ ] Accessibility tests present
- [ ] Mocks properly isolated
- [ ] Test coverage ≥ 80%

### Performance
- [ ] No unnecessary re-renders (React.memo if needed)
- [ ] API calls are debounced/throttled
- [ ] Large lists use virtualization if needed
- [ ] Images optimized (lazy load, proper sizes)

### UX & Design
- [ ] Follows DSM (design system) components
- [ ] Error states handled gracefully
- [ ] Loading states shown (skeleton, spinner)
- [ ] Disabled states visually distinct

### Supabase Integration
- [ ] Database schema matches expectations
- [ ] RLS policies enforced (if needed)
- [ ] Errors handled properly
- [ ] No N+1 queries

### Documentation
- [ ] Component docstring explains purpose
- [ ] Business rules referenced (COACH-1234)
- [ ] Database schema changes documented
```

---

## Stage 6: E2E Testing

**When:** Component review approved
**Owner:** QA or automated E2E tests
**Key Path:** signup → baseline → modules → endline → certificate

**Example: E2E Test for Quiz Retry**

```typescript
// e2e/quiz-retry.e2e.ts (Playwright or Cypress)
import { test, expect } from '@playwright/test';

test.describe('Quiz Retry E2E (COACH-1234)', () => {
  test('user can retry quiz after failure and pass', async ({ page }) => {
    // 1. Sign up
    await page.goto('/signup');
    await page.fill('input[name="email"]', 'user@example.com');
    await page.fill('input[name="password"]', 'TestPass123');
    await page.click('button:has-text("Sign Up")');

    // 2. Take baseline (45%) - fail
    await page.goto('/baseline');
    await page.fill('input[name="q1"]', 'wrong answer');
    await page.click('button:has-text("Submit Baseline")');
    await expect(page).toContainText('Score: 45%');

    // 3. Click retry
    await page.click('button:has-text("Retry Quiz")');
    await expect(page).toContainText('Attempt 2/3');

    // 4. Take quiz again (75%) - pass
    await page.fill('input[name="q1"]', 'correct answer');
    await page.click('button:has-text("Submit Baseline")');
    await expect(page).toContainText('Score: 75%');
    await expect(page).toContainText('✅ Passed');

    // 5. Verify history saved
    await page.goto('/quiz-history');
    await expect(page).toContainText('Attempt 1: 45%');
    await expect(page).toContainText('Attempt 2: 75%');
  });
});
```

---

## Stage 7: QA Approval

**When:** E2E tests pass
**Owner:** QA team
**Run:** `/coaching-qa`

```bash
/coaching-qa Verify COACH-1234 quiz retry works in staging
```

**QA Checklist:**

```
✅ Signup flow works
✅ Baseline quiz taken (first attempt)
✅ Failure message shown (< 60%)
✅ Retry button appears and clickable
✅ Quiz state reset (score, timer, selections)
✅ Attempt counter increments
✅ Max attempts enforced (no retry after 3 attempts)
✅ Quiz history visible
✅ Works on mobile (responsive)
✅ Works in different browsers (Chrome, Safari, Firefox)
```

---

## Stage 8: Code Review & Merge

**When:** QA approved
**Owner:** Code Reviewer
**Run:** `/coaching-review`

```bash
/coaching-review
```

**If approved:**

```bash
git push origin COACH-1234-quiz-retry
# Create PR on GitHub
# → PR linked to COACH-1234
# → Merge to staging
# → E2E tests run again
# → Merge to main (after staging validation)
```

---

## Stage 9: Postmortem & Learning

**When:** Task merged to main
**Owner:** You
**Run:** `/postmortem`

**Postmortem Entry:**

```markdown
# Postmortem: COACH-1234 (Quiz Retry Feature)

## Date Completed
2026-05-13

## What Went Well
✅ Vitest TDD approach caught state mutation bug early
✅ Zustand store simplifies component state management
✅ E2E tests verified full user flow (signup → retry → pass)
✅ React Testing Library queries more readable than Enzyme

## What Was Hard
⚠️ Timer reset logic: Had to coordinate between quiz component and Zupabase sync
⚠️ Debouncing retry click: Race condition on network delay
⚠️ Accessibility: Screen reader announcement for attempt counter needed aria-live

## Improvements Made to Harness
1. Created `src/test/factories/quizFactory.ts` for reusable quiz test fixtures
2. Created `src/test/mocks/supabaseMock.ts` for Supabase mocking
3. Updated `.claude/docs/frontend/patterns.md` with "State Reset Pattern"
4. Added rule: "Always debounce user actions in quiz flows" to docs

## Metrics
- Tests written: 14 (7 unit, 4 integration, 3 E2E)
- Coverage: 87%
- Edge cases caught: 3 (network error, rapid clicks, max attempts)
- Code review rounds: 1 (approved first time)
- E2E run time: 2.3 minutes
- Merge time: 45 minutes

## Lessons for Future Tasks
- Use factories instead of hardcoded test data
- Mock Supabase at integration test layer (not unit)
- Test accessibility early (not after review)
- Debounce/throttle user actions in forms + quiz flows
- Document timer reset behavior (tricky edge case)

## What's Next
- Feature: COACH-1235 (Recovery codes for locked users)
- Bug: COACH-1236 (Offline sync for quiz attempts)
```

---

## Integration with Autonomous Workflow

This Jira-integrated flow works seamlessly with existing workflows:

```
/coaching-dev "Add quiz retry feature"
    ↓ (auto-creates COACH-XXXX)
    ↓
[Write tests] → make test
    ↓
[Implement] → npm run dev (test changes)
    ↓
[Code review] → /coaching-review
    ↓
[QA] → /coaching-qa
    ↓
[Merge] → git push → PR → staging → main
    ↓
/postmortem "What we learned"
```

---

## Rules (Never Break)

1. ✅ **Every task has Jira ticket** (COACH-XXXX)
2. ✅ **Tests first** (TDD: RED → GREEN → REFACTOR)
3. ✅ **80%+ test coverage** for new code
4. ✅ **Accessibility verified** (WCAG A11y)
5. ✅ **E2E tests pass** before merge
6. ✅ **Code review approved** before merge
7. ✅ **Postmortem logged** after merge

---

## Troubleshooting

### Tests failing locally but passing in CI
→ Check node_modules: `rm -rf node_modules && npm install`
→ Check .env.local: Should match .env.example

### Supabase mock not working
→ Ensure `vi.mock()` call is at top of test file
→ Check mock return types match real Supabase client

### E2E test timing issues
→ Use `waitFor()` instead of hard waits
→ Check selector specificity (use role queries)

### Accessibility test failures
→ Run: `npm run test -- --reporter=verbose`
→ Check: All interactive elements have accessible names
→ Use: `screen.getByRole()` for better a11y testing

---

## Quick Commands

```bash
# Development
npm run dev                  # Start dev server
npm run test               # Run all tests
npm run test:watch        # Watch mode

# Testing
npm run test src/path     # Single file
npm run test -- --coverage # Coverage report
npm run test:ui           # Vitest UI

# Code Quality
npm run lint              # ESLint
npm run type-check        # TypeScript check

# Jira Integration
/coaching-dev "Feature description"   # Create ticket + start
/coaching-bugfix "Bug description"    # Create ticket + start
/coaching-review                      # Code review
/coaching-qa "Test this"              # QA verification
/postmortem                           # Log learnings
```

---

## See Also

- `AUTONOMOUS_WORKFLOW_SYSTEM.md` — Full workflow architecture
- `WORKFLOW_QUICK_REFERENCE.md` — Trigger words
- `docs/memory/patterns.md` — Frontend patterns
- `DEVELOPMENT_STANDARDS.md` — Team standards
- `.claude/docs/` — Architecture & conventions

---

**Last Updated:** 2026-05-13
**Stack:** React + TypeScript + Supabase + Vitest + React Testing Library
**Status:** ✅ Ready to use
