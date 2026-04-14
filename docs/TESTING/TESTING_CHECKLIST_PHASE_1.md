# Phase 1 Testing Checklist — Scenario-First Learning

**Ready for:** E2E Testing with multiple role accounts
**Test Accounts Needed:** Super Admin, Regional Admin, Coach A (persona A), Coach B (persona D)
**Duration:** ~30–45 minutes per account

---

## Pre-Test Setup

- [ ] **Database:** Fresh migration applied (`20260425000001_scenario_first_foundation.sql`)
- [ ] **Build:** `npm run build` passes
- [ ] **Dev Server:** `npm run dev` running at http://localhost:5173
- [ ] **Supabase Studio:** Access at http://127.0.0.1:54323
- [ ] **Test Accounts Created:** 4 accounts with proper roles in auth.users + user_roles table

---

## Test Path 1: Admin — Create Scenario Content

**Account:** Super Admin (role: admin)

### 1. Create Test Region
- [ ] Navigate to `/admin/regions`
- [ ] Click "Add Region"
- [ ] Fill form:
  - Name: "Test Region"
  - Code: "TEST-R1"
  - Parent Region: (leave empty)
  - Coordinates: `{"lat": 33.6844, "lng": 73.0479}`
- [ ] Click "Save Region"
- [ ] Verify region appears in list
- [ ] Verify can delete region with confirmation

### 2. Create Scenario in Unit
- [ ] Navigate to `/admin/modules`
- [ ] Select a module (e.g., "Module 1 - Ethics")
- [ ] Click "Units" or navigate to `/admin/modules/:moduleId/units`
- [ ] Select a unit (e.g., "Unit 1 - Introduction")
- [ ] Click "Scenarios" → navigates to `/admin/units/:unitId/scenarios`
- [ ] Click "Add Scenario"
- [ ] Fill form:
  - Situation: "You observe a colleague sharing student data with a vendor without consent."
  - Question: "What is your immediate action?"
  - Difficulty: "hard"
  - Feedback Slides: `[{"title":"Why This Matters","body":"Data protection is fundamental to trust..."}]`
  - Reveal Content: "The ethical principle here is confidentiality."
  - Deep Content: "GDPR and local regulations require explicit consent for data sharing."
  - Active: ON
- [ ] Validate JSON feedback_slides (should show error if invalid)
- [ ] Click "Save Scenario"
- [ ] Verify scenario appears in list with difficulty badge

### 3. Add Scenario Options (A/B/C/D)
- [ ] In scenario list, click "Options" button for newly created scenario
- [ ] Should navigate to `/admin/scenarios/:scenarioId/options`
- [ ] See scenario header displayed (situation + question)
- [ ] For Option A:
  - Option Text: "Immediately report to compliance officer"
  - Rationale: "This is the correct action per policy."
  - Principle Tag: "Confidentiality"
  - Mark as Correct: ✓ (click CheckCircle)
- [ ] For Option B:
  - Option Text: "Ask the colleague about their intent"
  - Rationale: "This delays escalation inappropriately."
  - Principle Tag: "Integrity"
  - Mark as Correct: ✗
- [ ] For Option C:
  - Option Text: "Do nothing; assume the vendor is approved"
  - Rationale: "Passive approach violates duty to protect data."
  - Principle Tag: "Accountability"
  - Mark as Correct: ✗
- [ ] For Option D:
  - Option Text: "Inform the student after data was shared"
  - Rationale: "Notification should be immediate, not post-facto."
  - Principle Tag: "Transparency"
  - Mark as Correct: ✗
- [ ] Click "Save Options"
- [ ] Verify redirect back to scenarios list
- [ ] Verify only one option marked correct (unmark others if you click them again)

---

## Test Path 2: User — Take Scenario Flow

**Account:** Coach A (persona: A, baseline completed, at least one unit assigned)

### 1. Profile Page Access
- [ ] Navigate to `/dashboard`
- [ ] In header, click "Profile" button
- [ ] See Profile page with sections:
  - Personal Information (editable)
  - Account Information (read-only)
  - Learning Profile (persona badge, baseline/endline status)
  - Progress Metrics (weak modules, achievement level)
- [ ] Click "Edit" button
- [ ] Modify `full_name` or `phone`
- [ ] Click "Save"
- [ ] Verify toast notification: "Profile updated successfully"
- [ ] Verify changes persist on page reload
- [ ] Click "Cancel" to exit edit mode without saving

### 2. Start Scenario Flow
- [ ] Navigate back to Dashboard
- [ ] In Training Modules section, select a unit you created scenarios for
- [ ] Should see unit card with "Attempt" button
- [ ] Click "Attempt"
- [ ] Should navigate to `/training/:trainingId/scenario`
- [ ] Verify scenario header shows training title + back button

### 3. Scenario Phase — Scenario Display & Decision
- [ ] See scenario card with:
  - [ ] Situation text displayed
  - [ ] Question displayed
  - [ ] 4 option buttons (A, B, C, D) with option text
- [ ] Click option A (correct answer)
- [ ] Verify button shows as selected (border-primary bg-primary/10)
- [ ] Button should not be immediately disabled
- [ ] Click another option (B)
- [ ] Verify selection updates to B
- [ ] Click back to A
- [ ] Click "Submit Decision" button
- [ ] Should transition to feedback phase

### 4. Feedback Phase — Verdict & Rationale
- [ ] See FeedbackCard with:
  - [ ] Green checkmark icon (✓ Correct)
  - [ ] Your chosen option displayed
  - [ ] Correct option displayed (same in this case)
  - [ ] Rationale shown: "This is the correct action per policy."
  - [ ] Principle tag badge: "Confidentiality"
- [ ] Click "Continue" button
- [ ] Should transition to reveal phase

### 5. Reveal Phase — Feedback Slides
- [ ] See RevealSlides component with:
  - [ ] Slide title: "Why This Matters"
  - [ ] Slide body: "Data protection is fundamental to trust..."
  - [ ] Slide counter: "1 / 1"
  - [ ] Previous/Next buttons (Previous disabled, Next disabled if only 1 slide)
- [ ] If multiple slides: navigate with prev/next buttons, verify counter updates
- [ ] Click "Next" or "Done" button
- [ ] Should transition to depth phase

### 6. Depth Phase — Expandable Deep Content
- [ ] See card with "Read More" toggle (collapsed)
- [ ] Click to expand
- [ ] Should see full deep content: "GDPR and local regulations require..."
- [ ] Verify smooth animation (max-h-0 → max-h-1000px)
- [ ] Check analytics: event "read_more_clicked" should be fired (see Supabase Studio)
- [ ] Click "Continue" button
- [ ] Should transition to summary phase

### 7. Summary Phase — Results
- [ ] See summary with:
  - [ ] Correct count: "1 / 1 correct"
  - [ ] Time spent: (calculated from decision submission)
  - [ ] Scenario breakdown: situation preview, correct/incorrect badge, time
  - [ ] "Back to Dashboard" button
- [ ] Click "Back to Dashboard"
- [ ] Should navigate to `/dashboard`

### 8. Verify Progress
- [ ] Unit status should now show "passed" or updated score
- [ ] Check training_progress table in Supabase: new row for this unit

---

## Test Path 3: Analytics Verification

**Account:** Super Admin (to view Supabase Studio)

### 1. Scenario Responses Table
- [ ] Open Supabase Studio
- [ ] Go to `scenario_responses` table
- [ ] Filter by user_id (Coach A's ID)
- [ ] Verify row exists with:
  - [ ] `scenario_id`: matches created scenario
  - [ ] `chosen_option`: "A"
  - [ ] `is_correct`: true
  - [ ] `time_spent_seconds`: (positive number)
  - [ ] `attempt_number`: 1

### 2. Analytics Events Table
- [ ] Go to `analytics_events` table
- [ ] Filter by user_id (Coach A's ID) and event_type
- [ ] Verify events exist:
  - [ ] `"scenario_viewed"`: (should have scenario_id, unit_id)
  - [ ] `"decision_submitted"`: (should have scenario_id, unit_id, metadata with chosen_option)
  - [ ] `"feedback_viewed"`: (should have scenario_id, unit_id)
  - [ ] `"read_more_clicked"`: (should have scenario_id, unit_id)
- [ ] Verify metadata JSONB contains expected fields

---

## Test Path 4: Error Handling

**Account:** Super Admin (admin) or Coach account

### 1. Invalid JSON Feedback Slides
- [ ] Navigate to `/admin/units/:unitId/scenarios`
- [ ] Add scenario with invalid feedback_slides JSON: `[{invalid json`
- [ ] Click "Save Scenario"
- [ ] Verify error toast: "Invalid JSON in feedback_slides field"
- [ ] Form should remain open for editing

### 2. No Correct Answer
- [ ] Navigate to `/admin/scenarios/:scenarioId/options`
- [ ] Unmark all options as correct (if previously set)
- [ ] Click "Save Options"
- [ ] Verify error toast: "Please mark one option as correct"
- [ ] Form should remain open

### 3. Missing Required Fields
- [ ] Navigate to `/admin/units/:unitId/scenarios`
- [ ] Click "Add Scenario"
- [ ] Leave situation and question empty
- [ ] Click "Save Scenario"
- [ ] Verify validation error (browser HTML5 validation or custom toast)

### 4. Region with No Parents
- [ ] Navigate to `/admin/regions`
- [ ] Click "Add Region"
- [ ] Leave all regions list empty (if first region)
- [ ] Should see disabled "No other regions available" message
- [ ] No "None" option with empty value

---

## Test Path 5: Role & Permission Checks

**Account 1:** Coach A (user role) → should NOT see admin panel
- [ ] Log in as Coach A
- [ ] Try to navigate to `/admin/modules`
- [ ] Should be redirected to `/dashboard` or see "Access Denied"

**Account 2:** Super Admin (admin role) → should see admin panel
- [ ] Log in as Super Admin
- [ ] Navigate to `/admin/modules`
- [ ] Should see full admin panel with all nav items

**Account 3:** Regional Admin (regional_admin role) — if test account available
- [ ] Log in as Regional Admin
- [ ] Should see admin-like interface (scope TBD in Phase 2)

---

## Performance Checks

- [ ] **Build Time:** `npm run build` completes in <15 seconds
- [ ] **Page Load:** ScenarioFlow loads in <2 seconds (including data fetch)
- [ ] **Transition Smoothness:** Phase transitions (scenario → feedback → reveal → depth) smooth, no jank
- [ ] **Analytics:** Async analytics calls don't block UI (fire-and-forget)
- [ ] **Memory:** Browser console shows no memory leaks (DevTools Performance tab)

---

## Browser Compatibility

- [ ] **Chrome/Chromium:** Full functionality
- [ ] **Firefox:** Full functionality
- [ ] **Safari:** Full functionality (if available)
- [ ] **Mobile (iOS/Android):** Responsive layout, buttons readable
  - [ ] Profile page responsive
  - [ ] ScenarioFlow readable on smaller screens
  - [ ] Admin forms wrap properly

---

## Smoke Tests (Quick Pass/Fail)

| Test | Expected | Status |
|------|----------|--------|
| Build succeeds | 0 errors, warnings only | [ ] |
| Dev server starts | http://localhost:5173 loads | [ ] |
| Login works | Can authenticate | [ ] |
| Dashboard loads | Module list renders | [ ] |
| Admin regions CRUD | Create, read, delete works | [ ] |
| Admin scenarios CRUD | Create scenario + options | [ ] |
| Profile page loads | All sections render | [ ] |
| Scenario flow E2E | Full 5-phase flow completes | [ ] |
| Analytics recorded | Events in analytics_events table | [ ] |
| No console errors | DevTools console clean | [ ] |

---

## Known Limitations & Caveats

1. **Type Assertions:** New tables use `as Record<string, unknown>` (temporary until full types.ts regeneration)
2. **Migration Ordering:** File name `20260425000001` must be chronologically after existing migrations
3. **RLS Policies:** Assume user is authenticated; offline mode not tested
4. **Analytics:** Fire-and-forget model means delivery is not guaranteed (but errors logged to console)
5. **Responsive Design:** ScenarioFlow not optimized for very small screens (<320px)

---

## Sign-Off

- [ ] All smoke tests pass
- [ ] No console errors
- [ ] Analytics data correct
- [ ] Build + lint pass
- [ ] Approved for PR/merge

**Tested by:** _______________
**Date:** _______________
**Notes:** _____________________________________________
