# E2E Test Run Report — Feedback Chatbot (2026-04-28)

**Environment:** Local dev (http://localhost:5173)  
**Tester:** [Your Name]  
**Date:** 2026-04-28  
**Status:** In Progress

---

## Test Setup

### Prerequisites Verification

- [ ] Supabase local running: `supabase status` shows healthy
- [ ] Dev server running: `npm run dev` on port 5173
- [ ] Build succeeds: `npm run build` (no errors)
- [ ] App loads: http://localhost:5173 displays landing page

### Test Accounts

Create or identify these accounts in local Supabase:

1. **Coach A** (Non-admin)
   - Email: `coach.a@test.local`
   - Password: `Test1234!`
   - Persona: B or C (take baseline, should pass with reasonable score)

2. **Admin**
   - Email: `admin@test.local`
   - Password: `Test1234!`
   - Role: admin (via `user_roles` table)

**Setup commands (if needed):**
```sql
-- In Supabase SQL editor, create test users and assign roles
INSERT INTO auth.users (email, encrypted_password, email_confirmed_at, created_at, updated_at)
VALUES 
  ('coach.a@test.local', crypt('Test1234!', gen_salt('bf')), now(), now(), now()),
  ('admin@test.local', crypt('Test1234!', gen_salt('bf')), now(), now(), now());

-- Assign admin role
INSERT INTO user_roles (user_id, role)
SELECT id, 'admin'::app_role FROM auth.users WHERE email = 'admin@test.local';
```

---

## Test Cases

### T1: Feedback Button Visibility

**Purpose:** Verify button appears on correct routes only

**Steps:**

1. Log in as Coach A
2. Visit `/dashboard` → feedback button visible (bottom-right, MessageCircle icon)
   - [ ] Button is visible
   - [ ] Icon is MessageCircle
   - [ ] Position is bottom-right (z-50)
   - [ ] Title shows "Share feedback"

3. Visit `/profile` → feedback button visible
   - [ ] Button is visible
   - [ ] Title shows "Share feedback"

4. Visit `/training/{moduleId}` → feedback button visible
   - [ ] Button is visible
   - [ ] Can click and open flow

5. Visit `/assessment/baseline` → feedback button NOT visible
   - [ ] Button is not present

6. Visit `/module-quiz/{moduleId}` → feedback button NOT visible
   - [ ] Button is not present

7. (If admin) Visit `/admin/feedback` → feedback button NOT visible
   - [ ] Button is not present on admin panel

**Result:** PASS / FAIL

**Notes:**
```
[space for observations]
```

---

### T2: Phase Flow - Happy Path

**Purpose:** Verify complete feedback submission flow

**Location:** `/dashboard`

**Steps:**

1. Click feedback button
   - [ ] Sheet opens
   - [ ] Message: "Hi 👋 Want to share feedback?"
   - [ ] Buttons: "Yes" and "Not now"

2. Click "Yes"
   - [ ] Greet message still visible
   - [ ] "Yes" echoed as user bubble
   - [ ] New message: "What would you like to share feedback about?"
   - [ ] 4 category buttons visible (This module, Platform experience, Something not working, Other)

3. Click "This module"
   - [ ] "This module" echoed as user bubble
   - [ ] New message: "How would you rate your experience?"
   - [ ] 5 stars visible (outlined, clickable)

4. Click 4th star
   - [ ] Stars fill up: ★★★★☆ (first 4 filled, last empty)
   - [ ] Rating echoed as: "★★★★☆"
   - [ ] New message: "What worked well?" (optional)
   - [ ] New message: "What could we improve?" (optional)
   - [ ] Two textareas visible

5. Type in positive textarea: "Great content"
   - [ ] Text appears in first textarea
   - [ ] Character counter shows (if maxLength visible)

6. Type in improvement textarea: "More examples"
   - [ ] Text appears in second textarea

7. Click "Submit feedback" button
   - [ ] Button text changes to "Sending..."
   - [ ] Button becomes disabled (grayed out)

8. Wait for success (5-10 seconds)
   - [ ] Done message appears: "Thanks! Your feedback helps us improve 🙌"
   - [ ] Positive feedback echoed: "Great content"
   - [ ] Improvement feedback echoed: "More examples"
   - [ ] Submit button replaced with "Close" button

9. Click "Close" button
   - [ ] Sheet closes
   - [ ] Feedback button is now disabled
   - [ ] Tooltip shows: "Thanks — you can share more feedback in 59s" (or similar countdown)

10. Wait 60 seconds
    - [ ] Countdown ticks down (watch it at 30s, 10s, 5s)
    - [ ] After 60s, button re-enables
    - [ ] Tooltip changes back to "Share feedback"

**Result:** PASS / FAIL

**Total Time:** ~65 seconds (including 60s cooldown)

**Notes:**
```
[space for observations]
```

---

### T3: Phase Flow - Minimal Input (No Text)

**Purpose:** Verify rating-only submission (text fields optional)

**Location:** `/training/{trainingId}`

**Steps:**

1. Click feedback button → "Yes"
   - [ ] Flow advances

2. Select "Platform experience"
   - [ ] Category echoed

3. Rate 3 stars
   - [ ] Rating echoed as: "★★★☆☆"

4. Leave both text fields empty
   - [ ] Do not type anything

5. Click "Submit feedback"
   - [ ] Success (no error about empty text)
   - [ ] Done message: "Thanks! Your feedback helps us improve 🙌"
   - [ ] No echo bubbles for positive/improvement (because they're empty)

6. Click "Close"
   - [ ] Cooldown active

**Result:** PASS / FAIL

**Notes:**
```
[space for observations]
```

---

### T4: Mobile Responsiveness

**Purpose:** Verify layout works at mobile breakpoints

**Steps:**

1. Open DevTools → Toggle device toolbar (375px width)
   - [ ] Device emulation active

2. Click feedback button on `/dashboard`
   - [ ] Sheet appears at bottom of screen
   - [ ] Sheet takes ~80vh of height
   - [ ] Full width on mobile

3. Scroll through phases (greet → category → rating → text)
   - [ ] All content visible without horizontal scroll
   - [ ] Text inputs are readable
   - [ ] Buttons are tappable (touch targets adequate, ~44px min)

4. Submit button
   - [ ] Spans full width
   - [ ] Easy to tap on touch device

**Result:** PASS / FAIL

**Notes:**
```
[space for observations]
```

---

### T5: Cooldown Enforcement

**Purpose:** Verify 60-second cooldown countdown works

**Location:** `/dashboard`

**Steps:**

1. Submit feedback (use T2 or T3 flow)
   - [ ] Cooldown activates after "Close"

2. Immediately check feedback button
   - [ ] Button is disabled (grayed out)
   - [ ] Tooltip shows countdown: "Thanks — you can share more feedback in 59s"

3. Wait 10 seconds, check again
   - [ ] Tooltip shows: "...in 49s" (or thereabouts)

4. Wait 50 more seconds
   - [ ] Tooltip continues counting down
   - [ ] After total 60s from close, button re-enables

5. Button re-enabled
   - [ ] Tooltip changes back to "Share feedback"
   - [ ] Button is clickable again

**Result:** PASS / FAIL

**Time Requirement:** 65 seconds real-time

**Notes:**
```
[space for observations]
```

---

### T6: Error Handling

**Purpose:** Verify graceful error handling and retry

**Location:** `/dashboard`

**Steps:**

1. Start feedback flow (go through category → rating → text phases)
   - [ ] Flow advances normally

2. Simulate network error:
   - Option A: Disconnect network (WiFi off, unplug ethernet)
   - Option B: Open DevTools → Network tab → Throttle to "Offline"
   - [ ] Network is offline

3. Click "Submit feedback"
   - [ ] Button shows "Sending..."
   - [ ] After ~5 seconds, error toast appears: "Couldn't send feedback. Try again."
   - [ ] Sheet returns to text phase (not stuck on "Sending...")
   - [ ] User input is preserved (ratings, text still in textareas)

4. Reconnect network
   - [ ] WiFi back on / DevTools offline disabled

5. Click "Submit feedback" again
   - [ ] Submits successfully
   - [ ] Done message appears

**Result:** PASS / FAIL

**Notes:**
```
[space for observations]
```

---

### T7: Re-entry Prevention (Double-Submit Protection)

**Purpose:** Verify only one feedback entry is created on rapid submit clicks

**Location:** `/dashboard`

**Steps:**

1. Start feedback flow (category → rating → text)
   - [ ] Complete through text phase

2. Click "Submit feedback"
   - [ ] Button shows "Sending..."

3. Rapidly click "Submit feedback" button 3-4 times while "Sending..." is displayed
   - [ ] Click multiple times in quick succession

4. Wait for completion
   - [ ] Done message appears
   - [ ] Only one request was sent (check DevTools Network tab)

5. Verify in database
   - [ ] Open Supabase console
   - [ ] Check `feedback` table
   - [ ] Only 1 new row exists (not duplicated)

**Result:** PASS / FAIL

**Notes:**
```
[space for observations]
```

---

### T8: Navigation During Feedback (State Cleanup)

**Purpose:** Verify sheet close clears state and doesn't break page

**Location:** `/dashboard`

**Steps:**

1. Click feedback button
   - [ ] Sheet opens

2. Select category (e.g., "Bug")
   - [ ] Category echoed

3. Rate 3 stars
   - [ ] Rating echoed

4. Close sheet WITHOUT submitting
   - [ ] Click "Not now" button, OR
   - [ ] Click X button on sheet header, OR
   - [ ] Click outside sheet

5. Check main dashboard page
   - [ ] Page is still functional
   - [ ] Can navigate (click links, buttons)
   - [ ] No errors in console

6. Click feedback button again
   - [ ] Sheet reopens fresh
   - [ ] Back to "Hi 👋 Want to share feedback?" (greet phase)
   - [ ] Previous category/rating NOT remembered

**Result:** PASS / FAIL

**Notes:**
```
[space for observations]
```

---

### T9: Admin Feedback View - Display

**Purpose:** Verify KPI cards and table display correctly

**Location:** `/admin/feedback`

**Prerequisites:** At least 5 feedback entries in database (submit them using T2/T3 with Coach A)

**Steps:**

1. Log in as Admin
   - [ ] Admin account authenticated

2. Navigate to `/admin/feedback`
   - [ ] Page loads
   - [ ] "Feedback" nav entry is highlighted in admin sidebar
   - [ ] Heading: "Feedback"
   - [ ] Subheading: "Coach feedback and ratings (30 days)"

3. **KPI Cards:**

   **Card 1: Total Feedback**
   - [ ] Shows number (e.g., "5")
   - [ ] Label: "Total Feedback"
   - [ ] Subtitle: "Last 30 days"

   **Card 2: Avg Rating**
   - [ ] Shows average (e.g., "3.2")
   - [ ] Label: "Avg Rating"
   - [ ] Subtitle: "Out of 5"
   - [ ] Rounded to 1 decimal place

   **Card 3: Low Ratings**
   - [ ] Shows count (e.g., "1")
   - [ ] Label: "Low Ratings" (in red/destructive color)
   - [ ] Subtitle: "Rating ≤ 2"

4. **Feedback Table:**

   **Headers visible:**
   - [ ] Coach
   - [ ] Category
   - [ ] Rating
   - [ ] Feedback
   - [ ] Date

   **Rows (for each feedback entry):**
   - [ ] Coach column: Full name (from profiles)
   - [ ] Category column: Badge (e.g., "module", styled)
   - [ ] Rating column: Stars (e.g., "★★★★☆")
   - [ ] Feedback column: Preview of positive text (first 50 chars, "..." if longer)
   - [ ] Date column: Formatted date (e.g., "2026-04-28")

5. **Pagination:**
   - [ ] Shows "Page 1 of 1 • 5 total" (if 5 entries)
   - [ ] Pagination buttons at bottom (if >20 entries)

**Result:** PASS / FAIL

**Notes:**
```
[space for observations]
```

---

### T10: Admin Filters

**Purpose:** Verify category, rating, persona, and date range filters work

**Location:** `/admin/feedback`

**Prerequisites:** Multiple feedback entries with different:
- Categories (module, platform, bug, other)
- Ratings (1-5 stars)
- Personas (A, B, C, D, E)
- Dates (spread across multiple days)

**Steps:**

1. **Filter by Category:**
   - [ ] Filters card visible above table
   - [ ] "Category" dropdown visible
   - [ ] Select "Bug" from dropdown
   - [ ] Table updates to show only bug reports
   - [ ] Count in description updates (e.g., "Page 1 of 1 • 2 total")

2. **Filter by Rating:**
   - [ ] "Rating" dropdown visible
   - [ ] Keep "Bug" category filter active
   - [ ] Select "2 stars" from rating dropdown
   - [ ] Table shows intersection: bugs with 2-star rating only
   - [ ] Count updates

3. **Filter by Persona:**
   - [ ] Clear previous filters (see below)
   - [ ] Select "C" from persona dropdown
   - [ ] Table shows only Persona C feedback
   - [ ] Count updates

4. **Filter by Date Range:**
   - [ ] Start Date input visible
   - [ ] End Date input visible
   - [ ] Set Start Date to 7 days ago
   - [ ] Set End Date to today
   - [ ] Table shows only feedback from that range
   - [ ] Count updates

5. **Combined Filters:**
   - [ ] Select Category = "Module"
   - [ ] Select Rating = "5 stars"
   - [ ] Table shows only 5-star module feedback
   - [ ] Count reflects intersection

6. **Clear Filters:**
   - [ ] Click "Clear filters" button
   - [ ] All dropdowns reset to empty/default
   - [ ] Table shows all feedback again
   - [ ] Count shows total (e.g., "Page 1 of 1 • 5 total")

**Result:** PASS / FAIL

**Notes:**
```
[space for observations]
```

---

### T11: RLS Verification

**Purpose:** Verify non-admins cannot query all feedback

**Location:** Browser DevTools

**Account:** Coach A (non-admin)

**Steps:**

1. Log in as Coach A
   - [ ] Non-admin account

2. Open DevTools → Console
   - [ ] F12 or right-click → Inspect

3. Try direct API call to fetch all feedback:
   ```javascript
   const { data, error } = await supabase.from('feedback').select('*');
   console.log('Data:', data, 'Error:', error);
   ```
   - [ ] Copy/paste and run in console

4. Check result:
   - [ ] Option A: Error appears (e.g., "permission denied", "relation not visible")
   - [ ] Option B: Data is empty or filtered to user's own feedback only
   - [ ] Non-admin should NOT see all feedback

5. Verify admin can see all:
   - [ ] Log out as Coach A
   - [ ] Log in as Admin
   - [ ] Try same API call
   - [ ] Data returns all feedback (multiple entries visible)

**Result:** PASS / FAIL

**Notes:**
```
[space for observations]
```

---

### T12: Data Persistence

**Purpose:** Verify feedback is stored correctly in database

**Steps:**

1. Submit feedback as Coach A
   - [ ] Use T2 happy path
   - [ ] Submit with:
     - Category: "Platform experience"
     - Rating: 4 stars
     - Positive: "Good UX"
     - Improvement: "Needs dark mode"

2. Switch to Admin account
   - [ ] Log out as Coach A
   - [ ] Log in as Admin

3. Visit `/admin/feedback`
   - [ ] Page loads
   - [ ] Feedback table visible

4. Find Coach A's entry
   - [ ] Look in "Coach" column for Coach A's name
   - [ ] Identify the row

5. Verify all fields:
   - [ ] **Category:** "Platform experience" (displayed as badge)
   - [ ] **Rating:** ★★★★☆ (4 stars)
   - [ ] **Positive Feedback:** "Good UX" (visible in preview or full text)
   - [ ] **Improvement Feedback:** "Needs dark mode" (visible in preview or full text)
   - [ ] **Timestamp:** Created today
   - [ ] **Persona:** Should show Coach A's persona (if set in profile)

6. (Optional) Open Supabase console and inspect raw row
   - [ ] Check all columns are populated correctly
   - [ ] Verify data types (text, int, UUID, etc.)

**Result:** PASS / FAIL

**Notes:**
```
[space for observations]
```

---

## Summary

### Results Checklist

- [ ] T1: Button visibility on correct routes
- [ ] T2: Happy path phase flow
- [ ] T3: Minimal input (category + rating, no text)
- [ ] T4: Mobile responsiveness
- [ ] T5: Cooldown countdown and re-enable
- [ ] T6: Error handling and retry
- [ ] T7: Re-entry prevention (no duplicates)
- [ ] T8: Navigation doesn't break during feedback
- [ ] T9: Admin view displays KPIs and table
- [ ] T10: Filters work correctly
- [ ] T11: RLS enforced for non-admins
- [ ] T12: Data persists to database

### Overall Result

**PASS / FAIL**

### Issues Found

```
[List any failures or bugs discovered]

Example:
- T5: Cooldown countdown not updating in real-time (stuck at 59s)
- T4: Text inputs overflow on 375px width
- T9: KPI cards don't calculate correctly (shows 0 for low ratings)
```

### Recommendations

```
[Any recommendations for fixes or improvements]

Example:
- Fix cooldown timer to update every second
- Add responsive padding to text inputs for mobile
- Verify KPI calculation logic in AdminFeedback.tsx
```

### Sign-Off

**Tester Name:** ________________  
**Date:** ________________  
**Signature:** ________________

---

**Next Steps:**
- If PASS: Ready for staging deployment
- If FAIL: Create GitHub issues for each failure, fix, and re-test

