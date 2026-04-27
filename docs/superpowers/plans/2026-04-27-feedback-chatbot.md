# Feedback Chatbot Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a chat-style feedback widget that authenticated coaches can use from any non-quiz page, plus a minimal admin view at `/admin/feedback`.

**Architecture:** A single floating Sheet-based component (`FeedbackChatbot`) mounted globally, with phase-machine state (greet → category → rating → text → done). Submission goes through a `useFeedback` hook to a new `feedback` table protected by RLS. Admin view is a list page with 3 KPI cards and filters; no charts.

**Tech Stack:** React 18 + TypeScript + Vite, Supabase (Postgres + RLS), TailwindCSS, shadcn-ui (`Sheet`, `RadioGroup`, `Textarea`, `Card`, `Select`, `DateRangePicker`), `sonner` toast (via `@/components/ui/sonner`), `date-fns@3.6` for relative timestamps, `lucide-react` icons. Vitest for hook tests.

**Spec:** `docs/superpowers/specs/2026-04-27-feedback-chatbot-design.md`

---

## File map

**New files:**
| Path | Purpose |
|---|---|
| `supabase/migrations/20260427120000_feedback_chatbot.sql` | `feedback` table + indexes + RLS |
| `src/hooks/useFeedback.ts` | Submission hook (awaited, returns ok/error) |
| `src/components/feedback/FeedbackBubble.tsx` | Chat bubble primitive (system / user variants) |
| `src/components/feedback/FeedbackChatbot.tsx` | Floating button + Sheet + phase machine |
| `src/pages/admin/AdminFeedback.tsx` | `/admin/feedback` list page with KPI cards + filters |
| `src/hooks/useFeedback.test.ts` | Unit test for submission hook |

**Modified files:**
| Path | Change |
|---|---|
| `src/App.tsx` | Mount `<FeedbackChatbot/>` globally; add `/admin/feedback` route |
| `src/pages/admin/AdminLayout.tsx` | Add "Feedback" entry to `navItems` array |

**Reference files (read-only — these inform what we build):**
- `src/contexts/AuthContext.tsx` — `useAuth()` shape (`{ user, profile, ... }`)
- `src/hooks/useAnalytics.ts` — fire-and-forget pattern (we mirror but await)
- `src/components/ProtectedRoute.tsx` — existing auth gate
- `src/pages/admin/AdminLayout.tsx` lines 6–13 — `navItems` to extend
- Existing migration `20260218113125_*.sql` — defines `app_role` ENUM and `has_role()` helper

---

## Pre-task setup (do once before starting)

- [ ] **Verify environment**

Run: `cd /Users/mac/Desktop/data/Taleemabad/coaching-platform && git status`
Expected: clean tree on `feature/rabt-rename-and-profile-fix` (or whatever feature branch is active for this work).

- [ ] **Confirm local Supabase is reachable**

Run: `supabase status`
Expected: services running. If not running: `supabase start` (requires Docker Desktop).

- [ ] **Confirm dev server runs**

Run: `npm run dev`
Expected: Vite dev server starts on `http://localhost:5173` without errors. Stop with Ctrl+C after confirming.

---

## Task 1: Database migration

**Files:**
- Create: `supabase/migrations/20260427120000_feedback_chatbot.sql`

- [ ] **Step 1: Create the migration file**

Write the following content to `supabase/migrations/20260427120000_feedback_chatbot.sql`:

```sql
-- Feedback chatbot: stores user-submitted feedback with context.
-- Write-once (no UPDATE/DELETE policies). RLS-gated.

CREATE TABLE public.feedback (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  module_id    UUID REFERENCES public.modules(id) ON DELETE SET NULL,
  training_id  UUID REFERENCES public.trainings(id) ON DELETE SET NULL,
  context_page TEXT NOT NULL,
  category     TEXT NOT NULL CHECK (category IN ('module','platform','bug','other')),
  rating       INT  NOT NULL CHECK (rating BETWEEN 1 AND 5),
  positive_feedback     TEXT,
  improvement_feedback  TEXT,
  persona      TEXT,
  user_agent   TEXT,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_feedback_created_at ON public.feedback (created_at DESC);
CREATE INDEX idx_feedback_module_id  ON public.feedback (module_id) WHERE module_id IS NOT NULL;
CREATE INDEX idx_feedback_user_id    ON public.feedback (user_id);

ALTER TABLE public.feedback ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can insert own feedback"
  ON public.feedback FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can read own feedback"
  ON public.feedback FOR SELECT TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Admins can read all feedback"
  ON public.feedback FOR SELECT TO authenticated
  USING (public.has_role(auth.uid(), 'admin'::app_role));
```

- [ ] **Step 2: Apply the migration locally**

Run: `supabase db reset`
Expected: all migrations re-apply cleanly, including the new one. No errors. The CLI will print `Finished supabase db reset.` at the end.

If the reset fails because of a pre-existing data dependency, instead run:
`supabase migration up`
Expected: the new migration applies on top of current state without resetting.

- [ ] **Step 3: Verify table and policies exist**

Run:
```bash
supabase db diff --schema public 2>&1 | head -40
```
Then connect to the local DB and verify directly:
```bash
psql "$(supabase status -o env | grep DB_URL | cut -d= -f2- | tr -d '"')" -c "\d public.feedback"
psql "$(supabase status -o env | grep DB_URL | cut -d= -f2- | tr -d '"')" -c "SELECT polname FROM pg_policy WHERE polrelid = 'public.feedback'::regclass;"
```

Expected: `\d` shows the table with all 12 columns, and the policy query lists 3 policies (`Users can insert own feedback`, `Users can read own feedback`, `Admins can read all feedback`).

- [ ] **Step 4: Smoke-test an insert**

Use the Supabase Studio (printed URL from `supabase status`, usually `http://127.0.0.1:54323`) → SQL Editor:

```sql
-- Should fail (no auth context)
INSERT INTO public.feedback (user_id, context_page, category, rating)
VALUES (gen_random_uuid(), '/test', 'platform', 5);
```
Expected: row inserted in Studio's SQL editor (it bypasses RLS as service role). Then:

```sql
SELECT id, context_page, category, rating, created_at FROM public.feedback;
DELETE FROM public.feedback;
```
Expected: see the test row, then clean up.

- [ ] **Step 5: Commit**

```bash
git add supabase/migrations/20260427120000_feedback_chatbot.sql
git commit -m "feat(feedback): add feedback table with RLS for chatbot widget"
```

---

## Task 2: useFeedback hook (with test)

**Files:**
- Create: `src/hooks/useFeedback.ts`
- Create: `src/hooks/useFeedback.test.ts`

- [ ] **Step 1: Write the failing test**

Create `src/hooks/useFeedback.test.ts`:

```ts
import { renderHook, act } from '@testing-library/react';
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { useFeedback } from './useFeedback';

// Mocks
const insertMock = vi.fn();
vi.mock('@/integrations/supabase/client', () => ({
  supabase: {
    from: () => ({ insert: insertMock }),
  },
}));

const useAuthMock = vi.fn();
vi.mock('@/contexts/AuthContext', () => ({
  useAuth: () => useAuthMock(),
}));

describe('useFeedback', () => {
  beforeEach(() => {
    insertMock.mockReset();
    useAuthMock.mockReset();
  });

  it('returns ok:false when user is not authenticated', async () => {
    useAuthMock.mockReturnValue({ user: null, profile: null });
    const { result } = renderHook(() => useFeedback());

    let outcome: { ok: boolean; error?: string } = { ok: false };
    await act(async () => {
      outcome = await result.current.submit({
        category: 'platform',
        rating: 5,
        context_page: '/dashboard',
      });
    });

    expect(outcome.ok).toBe(false);
    expect(insertMock).not.toHaveBeenCalled();
  });

  it('inserts a feedback row with auth context and returns ok:true', async () => {
    useAuthMock.mockReturnValue({
      user: { id: 'user-123' },
      profile: { persona: 'B' },
    });
    insertMock.mockResolvedValue({ error: null });

    const { result } = renderHook(() => useFeedback());

    let outcome: { ok: boolean; error?: string } = { ok: false };
    await act(async () => {
      outcome = await result.current.submit({
        category: 'bug',
        rating: 2,
        positive_feedback: '  good thing  ',
        improvement_feedback: '',
        context_page: '/training/abc',
        training_id: 'train-1',
      });
    });

    expect(outcome.ok).toBe(true);
    expect(insertMock).toHaveBeenCalledTimes(1);
    const payload = insertMock.mock.calls[0][0];
    expect(payload.user_id).toBe('user-123');
    expect(payload.persona).toBe('B');
    expect(payload.category).toBe('bug');
    expect(payload.rating).toBe(2);
    expect(payload.positive_feedback).toBe('good thing'); // trimmed
    expect(payload.improvement_feedback).toBe(null); // empty → null
    expect(payload.training_id).toBe('train-1');
    expect(payload.module_id).toBe(null);
    expect(typeof payload.user_agent).toBe('string');
  });

  it('returns ok:false with error message on supabase failure', async () => {
    useAuthMock.mockReturnValue({
      user: { id: 'user-123' },
      profile: { persona: 'A' },
    });
    insertMock.mockResolvedValue({ error: { message: 'permission denied' } });

    const { result } = renderHook(() => useFeedback());

    let outcome: { ok: boolean; error?: string } = { ok: true };
    await act(async () => {
      outcome = await result.current.submit({
        category: 'other',
        rating: 4,
        context_page: '/profile',
      });
    });

    expect(outcome.ok).toBe(false);
    if (!outcome.ok) {
      expect(outcome.error).toBe('permission denied');
    }
  });
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `npm run test -- src/hooks/useFeedback.test.ts`
Expected: FAIL with module not found (`useFeedback` doesn't exist yet) or `Cannot find module './useFeedback'`.

- [ ] **Step 3: Write minimal implementation**

Create `src/hooks/useFeedback.ts`:

```ts
import { useAuth } from '@/contexts/AuthContext';
import { supabase } from '@/integrations/supabase/client';

export type FeedbackCategory = 'module' | 'platform' | 'bug' | 'other';

export type SubmitFeedbackInput = {
  category: FeedbackCategory;
  rating: number; // 1-5
  positive_feedback?: string;
  improvement_feedback?: string;
  context_page: string;
  module_id?: string | null;
  training_id?: string | null;
};

export type SubmitFeedbackResult =
  | { ok: true }
  | { ok: false; error: string };

export function useFeedback() {
  const { user, profile } = useAuth();

  const submit = async (
    input: SubmitFeedbackInput,
  ): Promise<SubmitFeedbackResult> => {
    if (!user) return { ok: false, error: 'Not authenticated' };

    const payload = {
      user_id: user.id,
      category: input.category,
      rating: input.rating,
      positive_feedback: input.positive_feedback?.trim() || null,
      improvement_feedback: input.improvement_feedback?.trim() || null,
      context_page: input.context_page,
      module_id: input.module_id ?? null,
      training_id: input.training_id ?? null,
      persona: profile?.persona ?? null,
      user_agent: (typeof navigator !== 'undefined' ? navigator.userAgent : '').slice(0, 500),
    };

    const { error } = await supabase.from('feedback').insert(payload as Record<string, unknown>);

    if (error) {
      console.error('[feedback] insert failed', error);
      return { ok: false, error: error.message };
    }
    return { ok: true };
  };

  return { submit };
}
```

Note: `as Record<string, unknown>` matches the existing project pattern for inserts into newly added tables before `types.ts` is regenerated (per `docs/memory/patterns.md`).

- [ ] **Step 4: Run test to verify it passes**

Run: `npm run test -- src/hooks/useFeedback.test.ts`
Expected: 3 tests pass.

If `@testing-library/react` is not installed, install it as a dev dependency:
```bash
npm install -D @testing-library/react
```
Then re-run the tests.

- [ ] **Step 5: Commit**

```bash
git add src/hooks/useFeedback.ts src/hooks/useFeedback.test.ts
git commit -m "feat(feedback): add useFeedback hook with insert + auth + persona snapshot"
```

---

## Task 3: FeedbackBubble primitive

**Files:**
- Create: `src/components/feedback/FeedbackBubble.tsx`

- [ ] **Step 1: Create the bubble component**

Create `src/components/feedback/FeedbackBubble.tsx`:

```tsx
import { ReactNode } from 'react';
import { cn } from '@/lib/utils';

type FeedbackBubbleProps = {
  variant: 'system' | 'user';
  children: ReactNode;
};

export function FeedbackBubble({ variant, children }: FeedbackBubbleProps) {
  return (
    <div
      className={cn(
        'flex w-full mb-3',
        variant === 'system' ? 'justify-start' : 'justify-end',
      )}
    >
      <div
        className={cn(
          'max-w-[85%] rounded-2xl px-4 py-2 text-sm',
          variant === 'system'
            ? 'bg-muted text-foreground rounded-bl-sm'
            : 'bg-primary text-primary-foreground rounded-br-sm',
        )}
      >
        {children}
      </div>
    </div>
  );
}
```

- [ ] **Step 2: Verify it compiles**

Run: `npm run build:dev`
Expected: build succeeds, no TypeScript errors.

- [ ] **Step 3: Commit**

```bash
git add src/components/feedback/FeedbackBubble.tsx
git commit -m "feat(feedback): add FeedbackBubble chat primitive"
```

---

## Task 4: FeedbackChatbot — shell + greet phase

This task builds the floating button + Sheet + state scaffold + the greet phase only. Subsequent tasks add category, rating, text, and done phases.

**Files:**
- Create: `src/components/feedback/FeedbackChatbot.tsx`

- [ ] **Step 1: Create the component with greet phase only**

Create `src/components/feedback/FeedbackChatbot.tsx`:

```tsx
import { useEffect, useState } from 'react';
import { useLocation } from 'react-router-dom';
import { MessageCircle } from 'lucide-react';
import { Button } from '@/components/ui/button';
import {
  Sheet,
  SheetContent,
  SheetHeader,
  SheetTitle,
} from '@/components/ui/sheet';
import { useAuth } from '@/contexts/AuthContext';
import { FeedbackBubble } from './FeedbackBubble';

type Phase = 'greet' | 'category' | 'rating' | 'text' | 'submitting' | 'done';
type Category = 'module' | 'platform' | 'bug' | 'other';

const EXCLUDED_PREFIXES = [
  '/assessment/',
  '/module-quiz/',
  '/admin/',
];

function isExcludedPath(pathname: string): boolean {
  if (EXCLUDED_PREFIXES.some((p) => pathname.startsWith(p))) return true;
  // Scenario flow: /training/:trainingId/scenario
  if (/^\/training\/[^/]+\/scenario$/.test(pathname)) return true;
  return false;
}

export function FeedbackChatbot() {
  const { user } = useAuth();
  const location = useLocation();

  const [open, setOpen] = useState(false);
  const [phase, setPhase] = useState<Phase>('greet');
  const [cooldownUntil, setCooldownUntil] = useState<number | null>(null);
  const [now, setNow] = useState(Date.now());

  // Form state — used in later tasks
  const [category, setCategory] = useState<Category | ''>('');
  const [rating, setRating] = useState(0);
  const [positive, setPositive] = useState('');
  const [improvement, setImprovement] = useState('');

  // Tick the cooldown countdown once per second when active
  useEffect(() => {
    if (cooldownUntil === null) return;
    const interval = setInterval(() => setNow(Date.now()), 1000);
    return () => clearInterval(interval);
  }, [cooldownUntil]);

  // Reset form when sheet closes
  useEffect(() => {
    if (!open) {
      setPhase('greet');
      setCategory('');
      setRating(0);
      setPositive('');
      setImprovement('');
    }
  }, [open]);

  if (!user) return null;
  if (isExcludedPath(location.pathname)) return null;

  const onCooldown = cooldownUntil !== null && now < cooldownUntil;
  const cooldownSecondsLeft = onCooldown
    ? Math.ceil((cooldownUntil! - now) / 1000)
    : 0;

  return (
    <>
      <Button
        type="button"
        size="icon"
        aria-label="Share feedback"
        title={
          onCooldown
            ? `Thanks — you can share more feedback in ${cooldownSecondsLeft}s`
            : 'Share feedback'
        }
        disabled={onCooldown}
        onClick={() => setOpen(true)}
        className="fixed bottom-6 right-6 z-50 h-14 w-14 rounded-full shadow-lg"
      >
        <MessageCircle className="h-6 w-6" />
      </Button>

      <Sheet open={open} onOpenChange={setOpen}>
        <SheetContent
          side="right"
          className="w-full sm:max-w-md flex flex-col"
        >
          <SheetHeader>
            <SheetTitle>Share feedback</SheetTitle>
          </SheetHeader>

          <div className="flex-1 overflow-y-auto py-4">
            {phase === 'greet' && (
              <>
                <FeedbackBubble variant="system">
                  Hi 👋 Want to share feedback about your experience?
                </FeedbackBubble>
                <div className="flex gap-2 mt-2">
                  <Button onClick={() => setPhase('category')}>Yes</Button>
                  <Button variant="outline" onClick={() => setOpen(false)}>
                    Not now
                  </Button>
                </div>
              </>
            )}
            {/* Other phases added in later tasks */}
          </div>
        </SheetContent>
      </Sheet>
    </>
  );
}
```

- [ ] **Step 2: Mount globally in App.tsx**

Open `src/App.tsx`. Find the section where `<BrowserRouter>` and `<Routes>` are set up inside `<AuthProvider>`. Add `<FeedbackChatbot />` as a sibling to `<Routes>` (so it renders on every page that has the router):

```tsx
// At top with other imports:
import { FeedbackChatbot } from '@/components/feedback/FeedbackChatbot';

// Inside the router tree, alongside <Routes>:
<BrowserRouter>
  <Routes>
    {/* ...existing routes */}
  </Routes>
  <FeedbackChatbot />
</BrowserRouter>
```

The exact location depends on the current `App.tsx` structure — read it first and place the component **inside** the `<BrowserRouter>` (so `useLocation` works) but **outside** `<Routes>`.

- [ ] **Step 3: Verify it renders**

Run: `npm run dev`
Open `http://localhost:5173`. Sign in. On `/dashboard`, the floating chat button should appear bottom-right. Click it: Sheet opens with greeting + Yes / Not now buttons. "Not now" closes the sheet. "Yes" advances to `category` phase (currently shows nothing — that's expected, we add category UI in Task 5).

Navigate to `/admin/...` (if you have admin access) — button should NOT appear. Navigate to `/assessment/baseline` — button should NOT appear.

If anything fails, fix before proceeding.

- [ ] **Step 4: Commit**

```bash
git add src/components/feedback/FeedbackChatbot.tsx src/App.tsx
git commit -m "feat(feedback): add FeedbackChatbot shell with greet phase + global mount"
```

---

## Task 5: Category phase

**Files:**
- Modify: `src/components/feedback/FeedbackChatbot.tsx`

- [ ] **Step 1: Add category options + handler**

In `FeedbackChatbot.tsx`, add this constant near the top of the file (after the existing type definitions):

```tsx
const CATEGORY_OPTIONS: { value: Category; label: string }[] = [
  { value: 'module',   label: 'This module' },
  { value: 'platform', label: 'Platform experience' },
  { value: 'bug',      label: 'Something not working' },
  { value: 'other',    label: 'Other' },
];

const CATEGORY_LABEL: Record<Category, string> = {
  module: 'This module',
  platform: 'Platform experience',
  bug: 'Something not working',
  other: 'Other',
};
```

- [ ] **Step 2: Render category phase**

Inside the chat scroll area, after the `phase === 'greet'` block, add:

```tsx
{phase !== 'greet' && (
  <FeedbackBubble variant="system">
    Hi 👋 Want to share feedback about your experience?
  </FeedbackBubble>
)}
{phase !== 'greet' && (
  <FeedbackBubble variant="user">Yes</FeedbackBubble>
)}

{(phase === 'category' || phase === 'rating' || phase === 'text' || phase === 'submitting' || phase === 'done') && (
  <FeedbackBubble variant="system">
    What would you like to share feedback about?
  </FeedbackBubble>
)}

{phase === 'category' && (
  <div className="flex flex-col gap-2 mt-2">
    {CATEGORY_OPTIONS.map((opt) => (
      <Button
        key={opt.value}
        variant="outline"
        className="justify-start"
        onClick={() => {
          setCategory(opt.value);
          setPhase('rating');
        }}
      >
        {opt.label}
      </Button>
    ))}
  </div>
)}

{category && phase !== 'category' && (
  <FeedbackBubble variant="user">{CATEGORY_LABEL[category]}</FeedbackBubble>
)}
```

- [ ] **Step 3: Verify**

Run: `npm run dev`. On dashboard, open feedback → Yes → see 4 category buttons. Click one → user bubble appears with selection, advances to rating phase (which shows nothing yet — fine).

- [ ] **Step 4: Commit**

```bash
git add src/components/feedback/FeedbackChatbot.tsx
git commit -m "feat(feedback): add category selection phase"
```

---

## Task 6: Rating phase + Submit button

**Files:**
- Modify: `src/components/feedback/FeedbackChatbot.tsx`

- [ ] **Step 1: Add rating UI**

Inside `FeedbackChatbot.tsx`, import the `Star` icon at the top:

```tsx
import { MessageCircle, Star } from 'lucide-react';
```

After the category block, add:

```tsx
{(phase === 'rating' || phase === 'text' || phase === 'submitting' || phase === 'done') && (
  <FeedbackBubble variant="system">
    How would you rate your experience?
  </FeedbackBubble>
)}

{phase === 'rating' && (
  <div className="flex gap-1 mt-2 justify-center">
    {[1, 2, 3, 4, 5].map((n) => (
      <button
        key={n}
        type="button"
        aria-label={`${n} star${n > 1 ? 's' : ''}`}
        onClick={() => {
          setRating(n);
          setPhase('text');
        }}
        className="p-1 hover:scale-110 transition-transform"
      >
        <Star
          className={
            n <= rating
              ? 'h-8 w-8 fill-yellow-400 text-yellow-400'
              : 'h-8 w-8 text-muted-foreground'
          }
        />
      </button>
    ))}
  </div>
)}

{rating > 0 && phase !== 'rating' && (
  <FeedbackBubble variant="user">
    {'★'.repeat(rating)}{'☆'.repeat(5 - rating)}
  </FeedbackBubble>
)}
```

- [ ] **Step 2: Verify**

Run: `npm run dev`. Walk through the flow: open → Yes → pick category → see 5 stars → click one → user bubble shows ★ count, advances to text phase (still empty UI for now).

- [ ] **Step 3: Commit**

```bash
git add src/components/feedback/FeedbackChatbot.tsx
git commit -m "feat(feedback): add 1-5 star rating phase"
```

---

## Task 7: Text phase + Submit + Done phase

**Files:**
- Modify: `src/components/feedback/FeedbackChatbot.tsx`

- [ ] **Step 1: Import Textarea + toast + useFeedback**

Add to the imports at the top of `FeedbackChatbot.tsx`:

```tsx
import { Textarea } from '@/components/ui/textarea';
import { toast } from '@/components/ui/sonner';
import { useFeedback } from '@/hooks/useFeedback';
import { useParams } from 'react-router-dom';
```

- [ ] **Step 2: Wire up the hook + submit handler**

Inside the component, after the existing state declarations, add:

```tsx
const { submit } = useFeedback();
const params = useParams();

const trainingIdFromRoute =
  /^\/training\/[^/]+(\/.*)?$/.test(location.pathname) ? params.id ?? null : null;

const handleSubmit = async () => {
  if (!category || rating === 0) {
    toast.error('Please pick a category and rating');
    return;
  }
  setPhase('submitting');
  const result = await submit({
    category,
    rating,
    positive_feedback: positive,
    improvement_feedback: improvement,
    context_page: location.pathname,
    training_id: trainingIdFromRoute,
  });
  if (result.ok) {
    setPhase('done');
  } else {
    toast.error("Couldn't send feedback. Try again.");
    setPhase('text');
  }
};
```

- [ ] **Step 3: Render text phase, submit footer, done phase**

After the rating block, add:

```tsx
{(phase === 'text' || phase === 'submitting' || phase === 'done') && (
  <>
    <FeedbackBubble variant="system">
      What worked well? <span className="opacity-60">(optional)</span>
    </FeedbackBubble>
    {phase === 'done' && positive && (
      <FeedbackBubble variant="user">{positive}</FeedbackBubble>
    )}
    {(phase === 'text' || phase === 'submitting') && (
      <Textarea
        value={positive}
        onChange={(e) => setPositive(e.target.value)}
        maxLength={500}
        placeholder="Share what helped..."
        className="mt-2"
        disabled={phase === 'submitting'}
      />
    )}

    <FeedbackBubble variant="system">
      What could we improve? <span className="opacity-60">(optional)</span>
    </FeedbackBubble>
    {phase === 'done' && improvement && (
      <FeedbackBubble variant="user">{improvement}</FeedbackBubble>
    )}
    {(phase === 'text' || phase === 'submitting') && (
      <Textarea
        value={improvement}
        onChange={(e) => setImprovement(e.target.value)}
        maxLength={500}
        placeholder="Share what could be better..."
        className="mt-2"
        disabled={phase === 'submitting'}
      />
    )}
  </>
)}

{phase === 'done' && (
  <FeedbackBubble variant="system">
    Thanks! Your feedback helps us improve 🙌
  </FeedbackBubble>
)}
```

Then, **outside** the `<div className="flex-1 overflow-y-auto py-4">` scroll container but inside `<SheetContent>`, add a sticky footer:

```tsx
{(phase === 'rating' || phase === 'text' || phase === 'submitting') && (
  <div className="border-t pt-3">
    <Button
      onClick={handleSubmit}
      disabled={rating === 0 || phase === 'submitting'}
      className="w-full"
    >
      {phase === 'submitting' ? 'Sending...' : 'Submit feedback'}
    </Button>
  </div>
)}

{phase === 'done' && (
  <div className="border-t pt-3">
    <Button
      onClick={() => {
        setOpen(false);
        setCooldownUntil(Date.now() + 60_000);
      }}
      className="w-full"
    >
      Close
    </Button>
  </div>
)}
```

- [ ] **Step 4: Verify the full flow end-to-end**

Run: `npm run dev`. Sign in → dashboard → click feedback button → walk through all 5 phases → submit → see "Thanks!" bubble → click Close. Floating button should be disabled with tooltip showing seconds remaining. Wait 60s and confirm it re-enables.

Open Supabase Studio → `feedback` table → confirm the row was inserted with correct fields (user_id, category, rating, persona, context_page, user_agent).

- [ ] **Step 5: Test the error path**

Temporarily break the insert: in `useFeedback.ts`, change `.from('feedback')` to `.from('feedback_does_not_exist')`. Walk through the flow → on Submit, expect a red toast "Couldn't send feedback. Try again." and the form returns to the text phase with values intact. Revert the change.

- [ ] **Step 6: Commit**

```bash
git add src/components/feedback/FeedbackChatbot.tsx
git commit -m "feat(feedback): complete chatbot flow with text phase + submit + done"
```

---

## Task 8: Admin nav entry

**Files:**
- Modify: `src/pages/admin/AdminLayout.tsx`

- [ ] **Step 1: Add Feedback to navItems**

Open `src/pages/admin/AdminLayout.tsx`. Find the `navItems` array (around lines 6–13). Add a new entry. The exact format depends on the existing array's shape — read it first. Example based on the Explore findings:

```tsx
const navItems = [
  // ...existing items
  { label: 'Feedback', path: '/admin/feedback' },
];
```

If the array uses a different prop shape (e.g. `name` instead of `label`, or includes an icon), match it exactly.

- [ ] **Step 2: Verify (after Task 9 page exists)**

Skip verification until Task 9 completes — the route doesn't resolve yet. Continue to Task 9.

- [ ] **Step 3: Commit (after Task 9 passes)**

Defer commit until end of Task 9 — bundle nav + page in one commit.

---

## Task 9: AdminFeedback page — KPI cards + table

**Files:**
- Create: `src/pages/admin/AdminFeedback.tsx`
- Modify: `src/App.tsx`

- [ ] **Step 1: Scaffold the page with KPI cards (no filters yet)**

Create `src/pages/admin/AdminFeedback.tsx`:

```tsx
import { useEffect, useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { supabase } from '@/integrations/supabase/client';
import { toast } from '@/components/ui/sonner';
import { formatDistanceToNow } from 'date-fns';

type FeedbackRow = {
  id: string;
  user_id: string;
  module_id: string | null;
  training_id: string | null;
  context_page: string;
  category: 'module' | 'platform' | 'bug' | 'other';
  rating: number;
  positive_feedback: string | null;
  improvement_feedback: string | null;
  persona: string | null;
  user_agent: string | null;
  created_at: string;
};

type Kpis = {
  total30d: number;
  avgRating: number | null;
  redFlags: number;
};

export default function AdminFeedback() {
  const [rows, setRows] = useState<FeedbackRow[]>([]);
  const [kpis, setKpis] = useState<Kpis | null>(null);
  const [loading, setLoading] = useState(true);
  const [profileMap, setProfileMap] = useState<Record<string, string>>({});
  const [moduleMap, setModuleMap] = useState<Record<string, string>>({});

  useEffect(() => {
    void loadAll();
  }, []);

  const loadAll = async () => {
    setLoading(true);
    try {
      // 1. Fetch latest 100 rows
      const { data: feedback, error } = await supabase
        .from('feedback')
        .select('*')
        .order('created_at', { ascending: false })
        .limit(100);
      if (error) throw error;
      const fbRows = (feedback ?? []) as FeedbackRow[];
      setRows(fbRows);

      // 2. Resolve profile names
      const userIds = [...new Set(fbRows.map((r) => r.user_id))];
      if (userIds.length > 0) {
        const { data: profiles } = await supabase
          .from('profiles')
          .select('id, full_name')
          .in('id', userIds);
        const map: Record<string, string> = {};
        (profiles ?? []).forEach((p: { id: string; full_name: string | null }) => {
          map[p.id] = p.full_name ?? '(no name)';
        });
        setProfileMap(map);
      }

      // 3. Resolve module names
      const moduleIds = [...new Set(fbRows.map((r) => r.module_id).filter((x): x is string => !!x))];
      if (moduleIds.length > 0) {
        const { data: modules } = await supabase
          .from('modules')
          .select('id, title')
          .in('id', moduleIds);
        const map: Record<string, string> = {};
        (modules ?? []).forEach((m: { id: string; title: string }) => {
          map[m.id] = m.title;
        });
        setModuleMap(map);
      }

      // 4. KPIs (3 separate queries)
      const since30 = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString();
      const [totalRes, avgRes, redRes] = await Promise.all([
        supabase
          .from('feedback')
          .select('id', { count: 'exact', head: true })
          .gte('created_at', since30),
        supabase.from('feedback').select('rating'),
        supabase
          .from('feedback')
          .select('id', { count: 'exact', head: true })
          .lte('rating', 2),
      ]);

      const total30d = totalRes.count ?? 0;
      const ratings = (avgRes.data ?? []) as { rating: number }[];
      const avgRating =
        ratings.length === 0
          ? null
          : Math.round((ratings.reduce((s, r) => s + r.rating, 0) / ratings.length) * 10) / 10;
      const redFlags = redRes.count ?? 0;

      setKpis({ total30d, avgRating, redFlags });
    } catch (err) {
      console.error('[admin/feedback] load failed', err);
      toast.error('Failed to load feedback');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="p-6 max-w-7xl mx-auto">
      <h1 className="text-2xl font-semibold mb-6">Feedback</h1>

      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-6">
        <Card>
          <CardHeader>
            <CardTitle className="text-sm text-muted-foreground">Total (30d)</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold">{kpis?.total30d ?? '-'}</div>
          </CardContent>
        </Card>
        <Card>
          <CardHeader>
            <CardTitle className="text-sm text-muted-foreground">Avg rating</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold">
              {kpis?.avgRating !== null && kpis?.avgRating !== undefined
                ? `${kpis.avgRating} / 5`
                : '-'}
            </div>
          </CardContent>
        </Card>
        <Card>
          <CardHeader>
            <CardTitle className="text-sm text-muted-foreground">Red flags (≤ 2)</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold">{kpis?.redFlags ?? '-'}</div>
          </CardContent>
        </Card>
      </div>

      {loading ? (
        <p className="text-muted-foreground">Loading...</p>
      ) : rows.length === 0 ? (
        <p className="text-muted-foreground">No feedback yet.</p>
      ) : (
        <div className="border rounded-lg overflow-x-auto">
          <table className="w-full text-sm">
            <thead className="bg-muted">
              <tr>
                <th className="text-left p-2">When</th>
                <th className="text-left p-2">User</th>
                <th className="text-left p-2">Persona</th>
                <th className="text-left p-2">Category</th>
                <th className="text-left p-2">★</th>
                <th className="text-left p-2">Page</th>
                <th className="text-left p-2">Module</th>
                <th className="text-left p-2">Positive</th>
                <th className="text-left p-2">Improvement</th>
              </tr>
            </thead>
            <tbody>
              {rows.map((r) => (
                <tr key={r.id} className="border-t">
                  <td
                    className="p-2 whitespace-nowrap"
                    title={new Date(r.created_at).toLocaleString()}
                  >
                    {formatDistanceToNow(new Date(r.created_at), { addSuffix: true })}
                  </td>
                  <td className="p-2">{profileMap[r.user_id] ?? '...'}</td>
                  <td className="p-2">{r.persona ?? '-'}</td>
                  <td className="p-2">{r.category}</td>
                  <td className="p-2">{r.rating}</td>
                  <td className="p-2 font-mono text-xs max-w-[160px] truncate" title={r.context_page}>
                    {r.context_page}
                  </td>
                  <td className="p-2">{r.module_id ? moduleMap[r.module_id] ?? '...' : '-'}</td>
                  <td className="p-2 max-w-[200px] truncate" title={r.positive_feedback ?? ''}>
                    {r.positive_feedback ?? '-'}
                  </td>
                  <td
                    className="p-2 max-w-[200px] truncate"
                    title={r.improvement_feedback ?? ''}
                  >
                    {r.improvement_feedback ?? '-'}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
```

- [ ] **Step 2: Add the route to App.tsx**

Open `src/App.tsx`. Find the admin routes block (look for existing `/admin/...` entries — they're nested inside the `AdminLayout` route per the Explore findings). Add a new child route:

```tsx
import AdminFeedback from '@/pages/admin/AdminFeedback';

// Inside the AdminLayout's child routes:
<Route path="feedback" element={<AdminFeedback />} />
```

Match the exact pattern of the surrounding routes (relative vs absolute path).

- [ ] **Step 3: Verify**

Run: `npm run dev`. Sign in as an admin user. The "Feedback" link should appear in the admin sidebar (from Task 8). Click it → page loads with 3 KPI cards and the table of recent feedback (or "No feedback yet" if Task 7's test row was deleted).

If you have no real feedback yet, submit one or two via the chatbot (sign in as a normal coach, submit, then re-login as admin). Confirm rows appear with correct user names, modules, and persona.

If RLS blocks reads (you see "0 feedback" but DB has rows), verify your admin user has a `user_roles` entry with `role = 'admin'`. If not:
```sql
-- Run in Supabase Studio SQL Editor:
INSERT INTO public.user_roles (user_id, role) VALUES ('<admin-user-uuid>', 'admin')
ON CONFLICT DO NOTHING;
```

- [ ] **Step 4: Commit**

```bash
git add src/pages/admin/AdminFeedback.tsx src/pages/admin/AdminLayout.tsx src/App.tsx
git commit -m "feat(feedback): add admin feedback page with KPI cards and recent list"
```

---

## Task 10: Filters on admin page

**Files:**
- Modify: `src/pages/admin/AdminFeedback.tsx`

- [ ] **Step 1: Add filter state and UI**

Inside `AdminFeedback.tsx`, add these imports if not already present:

```tsx
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
```

Add filter state after the existing useState declarations:

```tsx
const [filterCategory, setFilterCategory] = useState<string>('all');
const [filterRating, setFilterRating] = useState<string>('all');
const [filterPersona, setFilterPersona] = useState<string>('all');
const [filterDays, setFilterDays] = useState<string>('all'); // 'all' | '7' | '30' | '90'
```

- [ ] **Step 2: Apply filters in the query**

Replace the row-loading section in `loadAll()` (the part that fetches feedback rows) with a filtered query:

```tsx
let query = supabase
  .from('feedback')
  .select('*')
  .order('created_at', { ascending: false })
  .limit(100);

if (filterCategory !== 'all') query = query.eq('category', filterCategory);
if (filterRating !== 'all') query = query.eq('rating', Number(filterRating));
if (filterPersona !== 'all') query = query.eq('persona', filterPersona);
if (filterDays !== 'all') {
  const since = new Date(Date.now() - Number(filterDays) * 24 * 60 * 60 * 1000).toISOString();
  query = query.gte('created_at', since);
}

const { data: feedback, error } = await query;
```

Update the `useEffect` dependency array to refetch when filters change:

```tsx
useEffect(() => {
  void loadAll();
}, [filterCategory, filterRating, filterPersona, filterDays]);
```

- [ ] **Step 3: Render filter bar above the table**

Add this before the table (between KPI cards and the table):

```tsx
<div className="flex flex-wrap gap-3 mb-4">
  <Select value={filterCategory} onValueChange={setFilterCategory}>
    <SelectTrigger className="w-[180px]">
      <SelectValue placeholder="Category" />
    </SelectTrigger>
    <SelectContent>
      <SelectItem value="all">All categories</SelectItem>
      <SelectItem value="module">Module</SelectItem>
      <SelectItem value="platform">Platform</SelectItem>
      <SelectItem value="bug">Bug</SelectItem>
      <SelectItem value="other">Other</SelectItem>
    </SelectContent>
  </Select>

  <Select value={filterRating} onValueChange={setFilterRating}>
    <SelectTrigger className="w-[140px]">
      <SelectValue placeholder="Rating" />
    </SelectTrigger>
    <SelectContent>
      <SelectItem value="all">All ratings</SelectItem>
      <SelectItem value="1">1 ★</SelectItem>
      <SelectItem value="2">2 ★</SelectItem>
      <SelectItem value="3">3 ★</SelectItem>
      <SelectItem value="4">4 ★</SelectItem>
      <SelectItem value="5">5 ★</SelectItem>
    </SelectContent>
  </Select>

  <Select value={filterPersona} onValueChange={setFilterPersona}>
    <SelectTrigger className="w-[140px]">
      <SelectValue placeholder="Persona" />
    </SelectTrigger>
    <SelectContent>
      <SelectItem value="all">All personas</SelectItem>
      <SelectItem value="A">A</SelectItem>
      <SelectItem value="B">B</SelectItem>
      <SelectItem value="C">C</SelectItem>
      <SelectItem value="D">D</SelectItem>
      <SelectItem value="E">E</SelectItem>
    </SelectContent>
  </Select>

  <Select value={filterDays} onValueChange={setFilterDays}>
    <SelectTrigger className="w-[160px]">
      <SelectValue placeholder="Date range" />
    </SelectTrigger>
    <SelectContent>
      <SelectItem value="all">All time</SelectItem>
      <SelectItem value="7">Last 7 days</SelectItem>
      <SelectItem value="30">Last 30 days</SelectItem>
      <SelectItem value="90">Last 90 days</SelectItem>
    </SelectContent>
  </Select>
</div>
```

- [ ] **Step 4: Verify**

Run: `npm run dev`. Submit ~5 feedback entries with varying ratings/categories/personas. On `/admin/feedback`, change each filter dropdown and confirm the table updates accordingly. Combine filters (e.g. category=bug AND rating=2) to confirm composability.

- [ ] **Step 5: Commit**

```bash
git add src/pages/admin/AdminFeedback.tsx
git commit -m "feat(feedback): add filters (category, rating, persona, date range) to admin view"
```

---

## Task 11: End-to-end verification

**Files:** none (verification only)

- [ ] **Step 1: Full flow as coach**

1. Sign in as a non-admin user.
2. On `/dashboard`: feedback button visible. Click → walk through full flow → submit. See "Thanks!" bubble.
3. Click Close → button disabled with countdown tooltip.
4. Wait 60s → button re-enabled.
5. Navigate to `/profile`: button visible.
6. Navigate to `/training/<some-id>`: button visible (and confirm it captures `training_id`).
7. Navigate to `/assessment/baseline`: button HIDDEN.
8. Navigate to `/module-quiz/<id>`: button HIDDEN.
9. Navigate to scenario flow URL: button HIDDEN.

- [ ] **Step 2: Full flow as admin**

1. Sign in as an admin user.
2. Navigate to `/admin/...` — feedback button HIDDEN.
3. In admin nav, click "Feedback" → `/admin/feedback` loads.
4. Confirm 3 KPI cards show correct numbers (cross-check with `SELECT count(*), avg(rating), count(*) FILTER (WHERE rating <= 2) FROM feedback;` in Studio).
5. Confirm recent feedback table shows submissions from Step 1, with full_name resolved correctly.
6. Apply each filter independently → table updates.
7. Apply combined filters → table updates.
8. Hover truncated text → full text visible in tooltip.

- [ ] **Step 3: RLS verification**

1. Sign in as a non-admin user.
2. Open browser devtools console:
```js
const { data, error } = await supabase.from('feedback').select('*');
console.log({ count: data?.length, error });
```
Expected: only the user's own feedback appears (or empty if they haven't submitted any). They should NOT see other users' feedback.

3. Try to insert with a different `user_id`:
```js
await supabase.from('feedback').insert({
  user_id: '00000000-0000-0000-0000-000000000000',
  context_page: '/test',
  category: 'platform',
  rating: 5,
});
```
Expected: error (RLS rejection — `auth.uid() != user_id`).

- [ ] **Step 4: Run all tests**

```bash
npm run test
```
Expected: `useFeedback` tests pass. No regressions.

- [ ] **Step 5: Run lint and build**

```bash
npm run lint
npm run build
```
Expected: lint passes (or only pre-existing warnings; no new errors); build succeeds with no TypeScript errors.

- [ ] **Step 6: Commit if any small fixes were needed**

If verification surfaced a bug, fix it, commit with a descriptive message, then continue.

If all checks pass with no changes needed, no commit.

---

## Task 12: Update memory & docs

**Files:**
- Modify: `docs/memory/patterns.md` (only if new patterns learned)

- [ ] **Step 1: Append patterns learned**

Open `docs/memory/patterns.md`. If anything new and non-obvious was learned during implementation (e.g. a Supabase quirk, a TypeScript type workaround, a shadcn integration detail), append ≤5 bullets. Examples of what to include:

- "Globally-mounted floating UI: place inside `<BrowserRouter>` but outside `<Routes>` so `useLocation()` works."
- "Supabase `count: 'exact', head: true` for cheap COUNT queries in admin KPIs."

If nothing new was learned (all patterns were already documented), skip this step entirely. Do NOT write code or transcripts — only the rule.

- [ ] **Step 2: Commit (if patterns added)**

```bash
git add docs/memory/patterns.md
git commit -m "docs: capture feedback chatbot implementation patterns"
```

---

## Final acceptance check

Before declaring the feature done, every box from the spec's §10 Acceptance Criteria should be checked:

**Coach:**
- [ ] Feedback button visible on `/dashboard`, `/training/:id`, `/profile`, `/certificate`.
- [ ] Hidden on `/assessment/:type`, `/module-quiz/:id`, scenario flow, `/admin/*`.
- [ ] Sheet opens, all 5 phases work, submission inserts a row.
- [ ] "Thanks!" bubble + 60s cooldown.
- [ ] Closing mid-flow discards partial data (next open = fresh greet phase).
- [ ] Network failure → toast + stays in text phase with values intact.

**Admin (`has_role = 'admin'`):**
- [ ] "Feedback" link in admin nav.
- [ ] 3 KPI cards show correct counts.
- [ ] All 4 filters work independently and combined.
- [ ] 25-row default; truncated text shows on hover.

**Non-admin coach:**
- [ ] Cannot navigate to `/admin/feedback` (existing admin guard handles).
- [ ] RLS prevents reading other users' feedback in direct DB queries.

If any box is unchecked, return to the relevant task and fix.
