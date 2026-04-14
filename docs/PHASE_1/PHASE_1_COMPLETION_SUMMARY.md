# Phase 1: Scenario-First Learning Foundation — Completion Summary

**Date:** 2026-04-14
**Branch:** `feature/coachcert-architecture-redesign`
**Commit:** `fb8c90a`
**Status:** ✅ **COMPLETE** — Ready for E2E Testing

---

## Overview

This phase implements the core **Scenario-First Learning Model** (Scenario → Reveal → Optional Depth) as designed in COACHING_PLATFORM_ARCHITECTURE.md. The learning flow is inverted from the baseline (60–70% skip slides) to prioritize decision-making scenarios with optional deepening content.

---

## Deliverables

### 1. Database Layer (`supabase/migrations/20260425000001_scenario_first_foundation.sql`)

**6 New Tables:**

| Table | Purpose | Key Fields |
|-------|---------|-----------|
| `scenarios` | Core learning scenarios | situation, question, difficulty, feedback_slides (JSONB), reveal_content, deep_content, is_active |
| `scenario_options` | A/B/C/D choices | option_letter (CHAR), option_text, is_correct, rationale, principle_tag |
| `scenario_responses` | User decisions | user_id, scenario_id, chosen_option, is_correct, time_spent_seconds, attempt_number |
| `analytics_events` | Event stream | event_type, user_id, scenario_id, unit_id, metadata (JSONB) |
| `regions` | Hierarchical regions | name, code, coordinates (JSONB), parent_id (self-ref FK) |
| `user_regions` | User-region mapping | user_id FK, region_id FK (UNIQUE) |

**Enum Extension:**
- `app_role` now includes `'regional_admin'` for future regional role support

**RLS Policies:**
- `regions`: Users SELECT all; admins ALL
- `scenarios`: Users SELECT active; admins ALL
- `scenario_options`: Users SELECT; admins ALL
- `scenario_responses`: Users INSERT+SELECT own; admins SELECT all
- `analytics_events`: Users INSERT+SELECT own; admins SELECT all
- `user_regions`: Users see own; admins ALL

**Indexes (Query Optimization):**
- `scenarios(unit_id, order_number)` — fast unit→scenario lookup
- `scenario_options(scenario_id)` — fast scenario→options lookup
- `scenario_responses(user_id, scenario_id)` — fast user decision tracking
- `analytics_events(user_id, created_at DESC)` — efficient analytics queries
- `user_regions(user_id)` — fast region lookup per user

---

### 2. React Components (`src/components/scenario/`)

**ScenarioCard.tsx**
```tsx
Props: situation, question, options[], selectedLetter, onSelect, locked
- Renders situation context in card
- 4 option buttons (A–D) with selection state
- Selected: border-primary bg-primary/10
- Locked: all buttons disabled
```

**FeedbackCard.tsx**
```tsx
Props: isCorrect, chosenOptionText, correctOptionText, rationale, principleTag?, onContinue, isLast
- Green border/bg for correct answer ✓
- Red border/bg for incorrect answer ✗
- Icons: CheckCircle2 (correct) / XCircle (incorrect) from lucide-react
- Displays rationale and principle tag badge
```

**RevealSlides.tsx**
```tsx
Props: slides[] ({title, body, image_url?}), onDone
- Carousel navigation (prev/next buttons)
- Progress indicator via <Progress> component
- Auto-calls onDone() if slides.length === 0
- Smooth transitions between slides
```

**ExpandableDepth.tsx**
```tsx
Props: content, scenarioId, unitId
- Collapsible "Read more" expandable
- On first expand: fires analytics event "read_more_clicked"
- ChevronDown/ChevronUp icons
- max-h-0 → max-h-[1000px] CSS transition
```

---

### 3. Main Pages

**ScenarioFlow.tsx** (`/training/:trainingId/scenario`)

State Machine with 5 phases:
```
"loading"
  ↓
"scenario" (render ScenarioCard, collect decision)
  ↓
"feedback" (render FeedbackCard with correct answer + rationale)
  ↓
"reveal" (render RevealSlides if feedback_slides.length > 0)
  ↓
"depth" (render ExpandableDepth if deep_content exists)
  ↓
"summary" (show correct count, scenario breakdown, back button)
```

**Features:**
- Fetches scenarios for unit, merges options separately
- Time tracking: `useRef<number>` records start time when scenario active
- Decision submission inserts `scenario_responses` record with `time_spent_seconds`, `is_correct`, `attempt_number`
- Analytics events: `"scenario_viewed"`, `"decision_submitted"`, `"feedback_viewed"`, `"read_more_clicked"`
- Smart phase progression: skips empty phases (reveal if no slides, depth if no content)
- Sticky header with training title and back button
- Summary screen: correct/total count, scenario-by-scenario breakdown

**Profile.tsx** (`/profile`)

User profile viewer and editor:
```
Personal Information (editable):
  - full_name, phone, school_id
  - Edit/Save/Cancel buttons

Account Information (read-only):
  - email, created_at, persona with badge

Learning Profile:
  - baseline_completed, baseline_score, baseline_attempts
  - endline_completed, endline_score, endline_attempts

Progress Metrics:
  - weak_modules array
  - achievement level with persona letter
```

Features:
- Toggle edit mode with button
- Form validation (required fields)
- Updates profiles table via Supabase
- Toast notifications for success/error

---

### 4. Admin Pages

**AdminScenarios.tsx** (`/admin/units/:unitId/scenarios`)

CRUD scenarios within a unit:
```
Form Fields (on add):
  - situation (Textarea)
  - question (Textarea)
  - difficulty (Select: easy/medium/hard)
  - feedback_slides (Textarea as raw JSON, validated on save)
  - reveal_content (Textarea)
  - deep_content (Textarea)
  - is_active (Switch)

List Actions:
  - Edit → navigate to AdminScenarioOptions
  - Delete → confirmation dialog
```

**AdminScenarioOptions.tsx** (`/admin/scenarios/:scenarioId/options`)

Edit A/B/C/D options for a scenario:
```
For each option (A, B, C, D):
  - Option letter badge
  - CheckCircle button to mark correct (only one can be correct)
  - Textarea for option_text
  - Textarea for rationale
  - Input for principle_tag

Validation:
  - Requires at least one option marked correct
  - Upserts all options with onConflict: "scenario_id,option_letter"
```

Shows scenario header (situation + question) as context for editing.

**AdminRegions.tsx** (`/admin/regions`)

CRUD regions with hierarchical support:
```
Form Fields (on add):
  - name (Input)
  - code (Input, e.g., "PKR-IS")
  - parent_id (Select from existing regions, optional)
  - coordinates (Textarea as raw JSON, optional)

List:
  - Shows parent region if set
  - Shows coordinates if present
  - Delete button with confirmation

Bug Fixed:
  - Select now conditionally renders regions only if they exist
  - Shows disabled "No other regions available" if empty list
  - Removed invalid empty value SelectItem
```

---

### 5. Hooks

**useAnalytics.ts**

Fire-and-forget event tracking:
```tsx
export function useAnalytics() {
  const { user } = useAuth();

  const track = useCallback(
    ({ event_type, scenario_id, unit_id, metadata }: TrackEventParams) => {
      if (!user) return;

      // Fire-and-forget: don't await, don't surface errors
      supabase
        .from("analytics_events")
        .insert({...})
        .then(({ error }) => {
          if (error) console.warn("[analytics]", error.message);
        });
    },
    [user]
  );

  return { track };
}
```

**Supported Event Types:**
- `"scenario_viewed"` — when scenario is displayed
- `"decision_submitted"` — when user submits a choice
- `"feedback_viewed"` — when feedback card is shown
- `"read_more_clicked"` — when ExpandableDepth is first expanded

---

### 6. Routing Updates

**src/App.tsx:**
- Added 4 imports: `ScenarioFlow`, `AdminScenarios`, `AdminScenarioOptions`, `AdminRegions`, `Profile`
- Added 5 new routes:

```tsx
// User routes
<Route path="/training/:trainingId/scenario" element={<ProtectedRoute><ScenarioFlow /></ProtectedRoute>} />
<Route path="/profile" element={<ProtectedRoute><Profile /></ProtectedRoute>} />

// Admin routes (nested under /admin)
<Route path="units/:unitId/scenarios" element={<AdminScenarios />} />
<Route path="scenarios/:scenarioId/options" element={<AdminScenarioOptions />} />
<Route path="regions" element={<AdminRegions />} />
```

**src/pages/admin/AdminLayout.tsx:**
- Removed duplicate "Scenarios" nav item (was pointing to `/admin/modules`, same as Modules)
- Kept "Regions" nav item with MapPin icon
- Updated imports to remove unused GitBranch icon

**src/pages/Dashboard.tsx:**
- Added User icon import from lucide-react
- Added Profile button in header before Admin button
- Navigates to `/profile` route

---

## Bugs Fixed This Session

1. **Duplicate Nav Key Error**
   - Issue: Two nav items both pointed to `/admin/modules` (Scenarios and Modules)
   - React warning: "Each child in a list should have a unique key prop"
   - Fix: Removed "Scenarios" nav item from AdminLayout.tsx navItems array
   - Result: Clean navigation, no duplicate routes

2. **Select.Item Empty Value Error**
   - Issue: AdminRegions had `<SelectItem value="">None</SelectItem>`
   - Error: "A <Select.Item /> must have a value prop that is not an empty string"
   - Fix: Conditionally render SelectItems only if regions exist
   - Changed: `regions.length > 0 ? map regions : <SelectItem value="no-regions" disabled>No regions</SelectItem>`
   - Result: Clean UX, no error on "Add Region" button

3. **TypeScript `any` Type Warnings**
   - Issue: Multiple files used `as any` for new table inserts
   - Fix: Replaced with `as Record<string, unknown>` for better type safety
   - Files affected: useAnalytics.ts, ScenarioFlow.tsx (3 locations), AdminScenarios.tsx, AdminScenarioOptions.tsx, AdminRegions.tsx
   - Result: Pass linting with no type safety warnings

---

## Build & Verification

✅ **npm run build:** Passes (0 errors)
- Minor warnings: CSS import order (pre-existing), chunk size >500KB (optimization opportunity)

✅ **npm run lint:** Passes (0 errors)

✅ **Git:** Committed and pushed to remote
- Commit: `fb8c90a` on `feature/coachcert-architecture-redesign`
- All 15+ files included (migrations, components, pages, hooks, updated routes)

---

## How to Test

### Admin Setup
1. Navigate to `/admin/regions` and create test regions
2. Go to `/admin/modules` → select a module → `/admin/modules/:moduleId/units` → select a unit
3. Click "Scenarios" button to go to `/admin/units/:unitId/scenarios`
4. Add a scenario with:
   - Situation: "A teacher needs to..."
   - Question: "What should they do?"
   - Difficulty: "medium"
   - Feedback slides: `[{"title":"Why this matters","body":"Because..."}]`
   - Reveal content: "The key insight is..."
   - Deep content: "Here's the full context..."
5. Click "Options" to navigate to `/admin/scenarios/:scenarioId/options`
6. Fill in 4 options (A, B, C, D) with text, rationale, principle_tag
7. Mark one as correct and save

### User Flow
1. Log in as regular user
2. Complete baseline assessment (if not already)
3. Go to Dashboard
4. Click "Profile" button in header to view/edit profile
5. Return to Dashboard
6. Select a training unit with scenarios
7. Complete scenario flow:
   - See scenario (situation + question + 4 options)
   - Submit decision
   - See feedback (correct/incorrect verdict + rationale)
   - Review reveal slides if available
   - Expand "Read more" to see deep content
   - See summary with timing and correct count

### Analytics Verification
1. In Supabase Studio, go to `analytics_events` table
2. Filter by user_id to see events:
   - `scenario_viewed`
   - `decision_submitted`
   - `feedback_viewed`
   - `read_more_clicked`
3. Verify metadata contains scenario_id, unit_id, chosen_option (if applicable)

---

## Architecture Notes

### State Management Pattern
- **AuthContext:** User, profile, auth methods
- **React Query:** Configured (used in existing code)
- **useState:** Local UI state (forms, phase, index, selection)
- **useRef:** Time tracking (scenario start time)

### Error Handling
- Toast notifications (sonner) for all user-facing errors
- Console warnings for silent failures (analytics)
- Confirmation dialogs for destructive actions (delete)

### Performance
- Queries batched with `Promise.all` where possible
- Options loaded separately from scenarios (not via JOIN)
- Analytics fire-and-forget (non-blocking)
- CSS transitions for smooth UI (ExpandableDepth)

### Type Safety
- TypeScript strict mode enabled
- Use `as Record<string, unknown>` for Supabase inserts to new tables (temporary)
- Types regenerated via CLI: `supabase gen types typescript --local`

---

## Files Changed

### New Files (10)
```
supabase/migrations/20260425000001_scenario_first_foundation.sql
src/hooks/useAnalytics.ts
src/components/scenario/ScenarioCard.tsx
src/components/scenario/FeedbackCard.tsx
src/components/scenario/RevealSlides.tsx
src/components/scenario/ExpandableDepth.tsx
src/pages/ScenarioFlow.tsx
src/pages/Profile.tsx
src/pages/admin/AdminScenarios.tsx
src/pages/admin/AdminScenarioOptions.tsx
src/pages/admin/AdminRegions.tsx
```

### Modified Files (3)
```
src/integrations/supabase/types.ts → regenerated
src/App.tsx → 4 imports + 5 routes added
src/pages/admin/AdminLayout.tsx → removed duplicate nav item
src/pages/Dashboard.tsx → added Profile button
```

### Renamed Files (3)
```
COACHCERT_ARCHITECTURE.md → COACHING_PLATFORM_ARCHITECTURE.md
COACHCERT_EXECUTIVE_SUMMARY.md → COACHING_PLATFORM_EXECUTIVE_SUMMARY.md
COACHCERT_ROADMAP.md → COACHING_PLATFORM_ROADMAP.md
```

---

## Next Steps (Phase 2 & Beyond)

As outlined in COACHING_PLATFORM_ROADMAP.md:

### Phase 2: Regional Admin & Content Personalization
- Regional admin dashboard (manage coaches, regions)
- Content assignment by region
- Coach onboarding workflow

### Phase 3: Advanced Analytics & Reporting
- Materialized views for aggregated metrics
- Coach dashboards (learner progress, engagement)
- Learner dashboards (learning paths, mastery levels)

### Performance Optimizations
- Code splitting with dynamic import()
- Chunk size optimization (currently >500KB)
- Caching strategies for scenarios/options

---

## Commit Details

```
Commit: fb8c90a
Author: Claude Haiku 4.5
Date: 2026-04-14

Implement Phase 1: Scenario-First Learning Foundation

20 files changed, 2939 insertions(+), 5 deletions(-)

Changes:
  - 6 new database tables with RLS policies
  - 4 scenario UI components (ScenarioCard, FeedbackCard, RevealSlides, ExpandableDepth)
  - 4 new pages (ScenarioFlow, Profile, AdminScenarios, AdminScenarioOptions, AdminRegions)
  - 1 analytics hook (useAnalytics)
  - 5 new routes in App.tsx
  - Navigation updates in AdminLayout and Dashboard
  - Database types regenerated
  - File renames (COACHCERT → COACHING_PLATFORM)
```

---

## Questions & Support

For implementation details, see:
- COACHING_PLATFORM_ARCHITECTURE.md — System design
- COACHING_PLATFORM_ROADMAP.md — Phase planning
- DEVELOPMENT_STANDARDS.md — Team standards
- /src — Inline comments on key logic

For bugs or issues, open an issue on GitHub with:
- Steps to reproduce
- Expected vs. actual behavior
- Screenshots if UI-related
- Error logs from console
