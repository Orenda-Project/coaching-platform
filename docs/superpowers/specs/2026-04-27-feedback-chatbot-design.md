# Feedback Chatbot — Design Spec

**Project:** RABT / CoachCert (Taleemabad coaching platform)
**Date:** 2026-04-27
**Branch (at spec time):** feature/rabt-rename-and-profile-fix
**Author:** Jalal (with Claude as collaborator)
**Status:** Approved design — ready for implementation plan

---

## 1. Objective

Add a persistent, chat-style feedback widget that lets authenticated coaches submit contextual feedback (rating + optional text) at any point in their journey, plus a minimal admin view to read what comes in.

The system must be:
- **Non-intrusive but always accessible** — floating button, easy to ignore.
- **Contextual** — captures the page/module/persona automatically.
- **Conversational** — feels like chat, not a form.
- **Actionable for admins** — at-a-glance "is this thing working?" KPIs and a filterable feed.

## 2. Scope (locked)

### In scope (Phase 1 MVP)
- Floating button visible on most authenticated pages.
- Sheet-based chat-style flow: greet → category → rating → optional text → confirmation.
- `feedback` table with RLS.
- `useFeedback` hook for submission.
- `/admin/feedback` page: 3 KPI cards + filterable table.

### Out of scope (deferred)
- Auto-prompts after module/quiz completion.
- Charts, time-series, per-module avg breakdown.
- AI sentiment analysis, auto-tagging, NLP.
- Screenshot attachment, voice feedback.
- Offline queue.
- CSV export.
- User-facing "my past feedback" view.
- Edit/delete of submitted feedback.

## 3. Decisions (locked during brainstorming)

| Topic | Decision | Why |
|---|---|---|
| Scope | Phase 1 MVP + minimal admin view | Admin view is required so feedback is visible; auto-prompts can wait until manual flow validates. |
| Flow shape | Greet → Category → Rating (req) → Optional text → Submit. Submit visible from rating phase. | Rating + category give structure; optional text removes friction; chat-not-survey feel. |
| Placement | All authenticated pages EXCEPT `/assessment/:type`, `/module-quiz/:moduleId`, scenario flow, `/admin/*` | Quiz/assessment have anti-cheat lockdown; admin pages are for reading feedback, not submitting. |
| Schema choices | `category` = TEXT + CHECK constraint; FKs `ON DELETE SET NULL` for module/unit; capture `user_agent`; write-once | Easier to evolve; preserves analytics history; helps triage bug reports. |
| Anti-spam | 60s client-side cooldown only | Authenticated internal users — DB-level limits add complexity without solving a real problem. |
| Admin view | List + 3 KPI cards. No charts. | KPI cards answer "is this working" at a glance; charts wait until real data justifies them. |
| Component shape | Single `FeedbackChatbot` with phase-based render (mirrors `ScenarioFlow.tsx` pattern) | Matches codebase convention; keeps diff tight. |
| Sheet vs Dialog | shadcn `Sheet` (slide-up panel) | Dialog feels heavyweight; Sheet reads as "chat." |
| Submission semantics | Awaited (not fire-and-forget like `useAnalytics`) | User-facing action; needs success/failure UI. |

## 4. Architecture

### 4.1 New files

```
supabase/migrations/20260427120000_feedback_chatbot.sql   -- table + RLS + indexes
src/hooks/useFeedback.ts                                   -- submit hook
src/components/feedback/FeedbackChatbot.tsx                -- floating button + Sheet shell + phase machine
src/components/feedback/FeedbackBubble.tsx                 -- chat bubble primitive (system/user variants)
src/pages/admin/AdminFeedback.tsx                          -- /admin/feedback page
```

### 4.2 Modified files

```
src/App.tsx                                                -- mount <FeedbackChatbot/> globally; add /admin/feedback route
src/pages/admin/<existing nav/dashboard>                   -- add "Feedback" link
```

### 4.3 Mounting strategy

`<FeedbackChatbot/>` mounts inside `<AuthProvider>`, **outside** `<Routes>`, so it renders on every page in the app shell. The component itself reads `useLocation()` and `useAuth()` and returns `null` when:

1. User not authenticated, OR
2. Pathname matches an excluded route prefix (`/assessment/`, `/module-quiz/`, `/admin/`, `/training/<id>/scenario`).

This centralizes "global mount + conditional visibility" in one place. No per-page wiring.

### 4.4 Naming collision flag

`src/components/scenario/FeedbackCard.tsx` already exists and displays scenario *outcome* feedback (a different concept — "you got the scenario right/wrong, here's why"). New components live under `src/components/feedback/` and are named `FeedbackChatbot` / `FeedbackBubble` to avoid confusion. Worth keeping in mind during code review.

## 5. Database

### 5.1 Migration: `20260427120000_feedback_chatbot.sql`

```sql
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

No UPDATE / DELETE policies → write-once enforced by absence.

### 5.2 Schema decisions

- **`user_id` ON DELETE CASCADE** — if a coach is hard-deleted, their feedback goes with them.
- **`module_id` / `training_id` ON DELETE SET NULL** — feedback survives module/unit deletion; analytics history preserved.
- **`persona` is TEXT, snapshot at submission** — not an FK. Personas are string codes ('A','B','C','D','E'); submission-time persona is what matters analytically even if user persona changes later.
- **Admin role check** uses the existing `public.has_role(uuid, app_role)` helper. The `app_role` ENUM has only `'admin'` and `'user'` (no `'super_admin'` in this project).
- **No `updated_at`** — write-once.
- **`user_agent`** — captured client-side, truncated to 500 chars, nullable.

## 6. Submission hook

### 6.1 `src/hooks/useFeedback.ts`

```ts
type SubmitFeedbackInput = {
  category: 'module' | 'platform' | 'bug' | 'other';
  rating: number;                  // 1-5
  positive_feedback?: string;
  improvement_feedback?: string;
  context_page: string;
  module_id?: string | null;
  training_id?: string | null;
};

export function useFeedback() {
  const { user, profile } = useAuth();

  const submit = async (
    input: SubmitFeedbackInput
  ): Promise<{ ok: true } | { ok: false; error: string }> => {
    if (!user) return { ok: false, error: 'Not authenticated' };

    const { error } = await supabase.from('feedback').insert({
      user_id: user.id,
      category: input.category,
      rating: input.rating,
      positive_feedback: input.positive_feedback?.trim() || null,
      improvement_feedback: input.improvement_feedback?.trim() || null,
      context_page: input.context_page,
      module_id: input.module_id ?? null,
      training_id: input.training_id ?? null,
      persona: profile?.persona ?? null,
      user_agent: navigator.userAgent.slice(0, 500),
    });

    if (error) {
      console.error('[feedback] insert failed', error);
      return { ok: false, error: error.message };
    }
    return { ok: true };
  };

  return { submit };
}
```

### 6.2 Why awaited (not fire-and-forget)

Unlike `useAnalytics`, this hook awaits the insert because:
- The user spent ~30s clicking through the flow; they need to see it landed.
- The Submit button needs a spinner state.
- Network failure should toast + let them retry, not silently drop their words.

## 7. Chatbot component & flow

### 7.1 Floating button

- Fixed `bottom-6 right-6`, `z-50`.
- Circular, primary color, shadow, `MessageCircle` icon (lucide).
- `aria-label="Share feedback"`.
- Tap target ≥48px (mobile-friendly).
- During cooldown: rendered with `disabled`, tooltip "Thanks — you can share more feedback in 60s".

### 7.2 Sheet panel

- shadcn `Sheet`.
- Desktop: `side="right"`, ~400px wide.
- Mobile: `side="bottom"`, full-width, ~80vh.
- Header: "Share feedback" + close X.
- Body: scrollable chat area (older bubbles stay visible).
- Footer: phase-specific controls (Submit button sticky from rating phase onward).

### 7.3 State (single `useState` block in `FeedbackChatbot.tsx`)

```ts
type Phase = 'greet' | 'category' | 'rating' | 'text' | 'submitting' | 'done';

const [phase, setPhase] = useState<Phase>('greet');
const [open, setOpen] = useState(false);
const [cooldownUntil, setCooldownUntil] = useState<number | null>(null);
const [form, setForm] = useState({
  category: '' as Category | '',
  rating: 0,
  positive: '',
  improvement: '',
});
```

Closing the Sheet at any phase resets state on next open (partial data discarded — matches SRD edge case).

### 7.4 Phase transitions

| Phase | System bubble | User input | Advances on |
|---|---|---|---|
| `greet` | "Hi 👋 Want to share feedback about your experience?" | Buttons: **Yes** / **Not now** | Yes → `category`. Not now → close. |
| `category` | "What would you like to share feedback about?" | RadioGroup styled as chips: This module / Platform experience / Something not working / Other | Selection → push user bubble showing choice → `rating` |
| `rating` | "How would you rate your experience?" | 1–5 star row, clickable, hover highlights | Click → push user bubble (e.g. ★★★★) → `text`. **Submit button enables here.** |
| `text` | "What worked well? *(optional)*" + "What could we improve? *(optional)*" | Two textareas stacked, `maxLength={500}` each | User clicks **Submit** (visible since rating). Empty fields OK. |
| `submitting` | (spinner in submit button) | — | Hook resolves → `done`. On error: toast.error, stay in `text`. |
| `done` | "Thanks! Your feedback helps us improve 🙌" | Button: **Close** | Click → close Sheet, start 60s cooldown. |

### 7.5 Context derivation

Read from URL via `useLocation()` and `useParams()`:

| Pathname | `module_id` | `training_id` |
|---|---|---|
| `/training/:id` | NULL | derived from `:id` (the route param IS the training_id) |
| `/dashboard`, `/profile`, `/certificate`, etc. | NULL | NULL |

`module_id` is currently never auto-derivable on visible routes (module-quiz is excluded). Stays NULL on all visible pages. The `category='module'` value carries the user's *intent* even when no FK is captured.

### 7.6 Submit button visibility

Per the locked decision, the Submit button is visible from the `rating` phase onward (not only at the end). Empty positive/improvement → stored as NULL.

### 7.7 Cooldown UX

After `done`:
- Floating button rendered `disabled` for 60s.
- Tooltip: "Thanks — you can share more feedback in 60s".
- Cooldown is **per session, in component memory**. Page refresh resets it. Acceptable for MVP.

### 7.8 Accessibility

- Sheet traps focus while open.
- ESC closes.
- Focus returns to floating button on close.
- Each phase auto-focuses its primary control (first button / first textarea).
- All chat bubbles use semantic markup with appropriate ARIA roles.

## 8. Error handling

| Failure | UI | State |
|---|---|---|
| Not authenticated (shouldn't happen — widget hidden) | toast.error("Please sign in") | Stay in `text` phase |
| Network / Supabase error | toast.error("Couldn't send feedback. Try again.") | Stay in `text` phase, Submit button re-enabled |
| RLS rejection (`auth.uid() != user_id`) | Same as above | Same |
| Success | (no toast — `done` phase shows "Thanks!" bubble) | Advance to `done` |

### 8.1 Validation (client-side, pre-submit)

- `rating ∈ {1,2,3,4,5}` (Submit disabled until set).
- `category ∈ {'module','platform','bug','other'}` (RadioGroup enforces).
- Text fields trimmed; `maxLength={500}` on textareas.
- All other fields auto-populated.

### 8.2 No retry logic in MVP

User clicks Submit again → fresh insert attempt. The 60s cooldown only starts after `done`, not after a failed submit, so retries aren't blocked.

## 9. Admin view (`/admin/feedback`)

### 9.1 Layout

```
Feedback
─────────────────────────────────────────────────
[Total (30d): 142]   [Avg rating: 4.2 / 5]   [Red flags: 8 (rating ≤ 2)]

[Category ▾] [Rating ▾] [Persona ▾] [Date range ▾]

When  | User      | Persona | Cat  | ★ | Page    | Module | Positive   | Improvement
2h ago| Aslam K.  | A       | bug  | 2 | /train..| Mod 3  | (truncated)| (truncated)
...
```

### 9.2 KPI cards (top row)

| Card | Query |
|---|---|
| Total feedback (30d) | `count(*) WHERE created_at > now() - interval '30 days'` |
| Avg rating | `avg(rating)::numeric(2,1)` over all feedback |
| Red flags | `count(*) WHERE rating <= 2` (all-time) |

Three independent Supabase queries on mount. Cheap given the indexes.

### 9.3 Filter bar

- **Category** — Select: All / module / platform / bug / other
- **Rating** — Select: All / 1 / 2 / 3 / 4 / 5
- **Persona** — Select: All / A / B / C / D / E
- **Date range** — DateRangePicker presets: last 7 days / 30 days / all-time / custom

Filters compose into a single Supabase query with `.eq() / .gte() / .lte()`. Refetch on filter change.

### 9.4 Table columns

| Column | Source |
|---|---|
| When | `created_at`, relative format (`date-fns`), full timestamp on hover |
| User | `profiles.full_name` (separate query) |
| Persona | `persona` snapshot — colored badge |
| Category | `category` — chip styled by type (bug = red, module = blue, etc.) |
| Rating | `rating` — star row |
| Page | `context_page` — monospace, truncated |
| Module | resolved `modules.title` from `module_id` (separate query) |
| Positive | `positive_feedback` — truncated to 60 chars, hover for full |
| Improvement | `improvement_feedback` — truncated to 60 chars, hover for full |

Click row → expand inline to show full text + `user_agent`. No detail page.

### 9.5 Pagination

Offset-based, 25 rows per page. Sort default: `created_at DESC`.

### 9.6 Data fetching pattern (matches coding rules — no relational selects)

```ts
// 1. Fetch feedback rows (with filters + pagination)
const { data: rows } = await supabase
  .from('feedback')
  .select('*')
  .order('created_at', { ascending: false })
  .range(offset, offset + 24)
  // ...filters

// 2. Batch fetch profile names for unique user_ids
const userIds = [...new Set(rows.map(r => r.user_id))];
const { data: profiles } = await supabase
  .from('profiles')
  .select('id, full_name')
  .in('id', userIds);

// 3. Same for module_ids
const moduleIds = [...new Set(rows.map(r => r.module_id).filter(Boolean))];
const { data: modules } = await supabase
  .from('modules')
  .select('id, title')
  .in('id', moduleIds);

// 4. Stitch in component (Map<id, full_name>, Map<id, title>)
```

### 9.7 Nav entry

Add a "Feedback" link to the existing admin sidebar/nav. Implementation step: identify the existing admin nav file (likely under `src/pages/admin/` or a shared layout) and follow its pattern.

## 10. Acceptance criteria

A coach using the platform:
- [ ] Sees the floating feedback button on `/dashboard`, `/training/:id` (content view), `/profile`, `/certificate`.
- [ ] Does NOT see it on `/assessment/baseline`, `/assessment/endline`, `/module-quiz/:id`, scenario flow, or any `/admin/*` route.
- [ ] Clicks button → Sheet slides up with greeting bubble.
- [ ] Picks category → rating → optionally adds text → Submits.
- [ ] Sees "Thanks!" confirmation. Floating button is disabled for 60s.
- [ ] Closing Sheet mid-flow discards partial data.
- [ ] Network failure shows toast and stays in text phase.

An admin (`has_role(uid, 'admin')` returns true):
- [ ] Sees a "Feedback" link in admin nav.
- [ ] On `/admin/feedback`, sees 3 KPI cards with correct counts.
- [ ] Can filter table by category / rating / persona / date range.
- [ ] Can paginate (25 rows/page).
- [ ] Clicking a row expands to show full positive/improvement text + user_agent.

A coach who is NOT an admin:
- [ ] Cannot access `/admin/feedback` (existing admin route guard handles this).
- [ ] RLS prevents them from reading other users' feedback even via direct Supabase calls.

## 11. Open implementation questions (resolve during plan)

These are deliberate punts to the implementation plan, not blockers for spec sign-off:

1. ~~Exact name of admin role check column~~ — RESOLVED: project uses `public.has_role(auth.uid(), 'admin'::app_role)` helper. `app_role` ENUM has values `'admin'` and `'user'` only (no `super_admin`).
2. ~~Where the admin nav link goes~~ — RESOLVED: `src/pages/admin/AdminLayout.tsx` has a `navItems` array (lines 6–13). One-line addition.
3. ~~Verify `units` table name~~ — RESOLVED: project uses `trainings` (not `units`); FK is `training_id`.
4. ~~Toast helper import path~~ — RESOLVED: `import { toast } from "@/components/ui/sonner"` (re-export of sonner).

## 12. Future enhancements (explicitly out of MVP)

- Auto-prompt after module pass / module fail / endline completion.
- Per-module avg rating ranking (struggling modules first).
- Time-series charts (avg rating over time, volume per week).
- AI sentiment / auto-tagging.
- CSV / Excel export from admin view.
- "My past feedback" view for coaches.
- Screenshot attachment for bug reports.
- Offline submission queue.

## 13. References

- SRD provided in conversation: 14 sections covering objective, user stories, UX, functional req, data model, APIs, dashboard, analytics, NFRs, security, edge cases, future, phases.
- Existing `useAnalytics` hook: `src/hooks/useAnalytics.ts` (fire-and-forget pattern — feedback hook intentionally diverges).
- Existing `ScenarioFlow.tsx`: phase-machine pattern that `FeedbackChatbot` mirrors.
- Existing `FeedbackCard.tsx` (in `src/components/scenario/`): different concept — naming collision flagged in §4.4.
