# E2E Testing: Feedback Chatbot

**Prerequisite:** The `20260506000000_feedback_chatbot` migration must be applied to staging Supabase.

## Setup
1. Build the app: `npm run build`
2. Deploy to staging via Railway
3. Access staging app URL
4. Have two test accounts ready:
   - Coach A (with module access)
   - Admin account (to view feedback)

## Test Cases

### T1: Feedback Button Visibility
**Location:** All protected pages except `/assessment/*`, `/module-quiz/*`, `/admin/*`, `/training/:id/scenario`

**Steps:**
1. Log in as Coach A
2. Visit `/dashboard` → feedback button visible (bottom-right, MessageCircle icon)
3. Visit `/profile` → feedback button visible
4. Visit `/training/{moduleId}` → feedback button visible
5. Visit `/assessment/baseline` → feedback button NOT visible
6. Visit `/module-quiz/{moduleId}` → feedback button NOT visible
7. Visit `/admin/feedback` (if admin) → feedback button NOT visible

**Expected:** Button appears only on non-excluded routes

### T2: Phase Flow - Happy Path
**Location:** `/dashboard`

**Steps:**
1. Click feedback button → "Hi 👋 Want to share feedback?" with Yes/Not now
2. Click "Yes" → "What would you like to share feedback about?" with 4 category buttons
3. Click "This module" → echoes back as user bubble, shows "How would you rate your experience?" with 5 stars
4. Click 4 stars → echoes back as ★★★☆☆, shows text inputs for "What worked well?" and "What could we improve?"
5. Type positive feedback: "Great content" → text appears in textarea
6. Type improvement feedback: "More examples" → text appears in textarea
7. Click "Submit feedback" → button changes to "Sending...", disabled
8. After submit succeeds → "Thanks! Your feedback helps us improve 🙌" with user echoes
9. Click "Close" → cooldown active (disabled button, "Thanks — you can share more feedback in 60s")
10. Wait 60 seconds → button re-enables

**Expected:** All phases flow correctly, messages accumulate, echoes appear, cooldown works

### T3: Phase Flow - Minimal Input
**Location:** `/training/{trainingId}`

**Steps:**
1. Click feedback button → "Yes"
2. Select "Platform experience"
3. Rate 3 stars
4. Leave both text fields empty
5. Click "Submit feedback"

**Expected:** Submits successfully (text fields are optional), "Thanks!" message appears, no echo bubbles for empty text

### T4: Mobile Responsiveness
**Device:** Mobile (375px width) or resize browser

**Steps:**
1. Click feedback button → Sheet appears at bottom of screen (full width, ~80vh)
2. Scroll through all phases
3. Text inputs are readable and tappable
4. Submit button spans full width

**Expected:** Layout works at mobile breakpoint, no overflow, touch targets adequate

### T5: Cooldown Enforcement
**Location:** `/dashboard`

**Steps:**
1. Complete and submit feedback → cooldown starts
2. Immediately try clicking feedback button → disabled, shows countdown "59s"
3. Wait 10 seconds → countdown updates to "49s"
4. Wait 50 more seconds → button re-enables, "Share feedback" title restored

**Expected:** Cooldown counts down in real time, button re-enables after 60s

### T6: Error Handling
**Location:** `/dashboard`, with network disconnect or DB access issue

**Steps:**
1. Start feedback flow (greet → category → rating → text)
2. Disconnect network or block Supabase access
3. Click "Submit feedback" → "Sending..." appears then fails
4. After error → returns to text phase, preserves user input (ratings, text)
5. Reconnect network
6. Click "Submit feedback" again → succeeds, proceeds to done

**Expected:** Error toast appears, flow doesn't break, retries work

### T7: Re-entry Prevention
**Location:** `/dashboard`

**Steps:**
1. Click feedback button, start flow
2. While "Sending..." is displayed, rapidly click "Submit feedback" multiple times
3. Check Supabase feedback table → entry appears only once (no duplicates)

**Expected:** Double-click protection prevents duplicate submissions

### T8: Navigation During Feedback
**Location:** `/dashboard`, in middle of feedback flow

**Steps:**
1. Click feedback button, select category, rate 3 stars
2. Without submitting, click "Not now" or close the Sheet
3. Return to `/dashboard` content (main page functional)
4. Click feedback button again → flow resets to "Hi 👋" phase

**Expected:** Sheet closes, page remains functional, feedback state clears

### T9: Admin Feedback View - Display
**Location:** `/admin/feedback` (admin account only)

**Prerequisite:** At least 5 feedback entries in DB

**Steps:**
1. Visit `/admin/feedback` → page loads with nav entry highlighted
2. **KPI Cards visible:**
   - "Total Feedback" shows count of entries from last 30 days
   - "Avg Rating" shows mean (rounded to 1 decimal)
   - "Low Ratings" shows count where rating ≤ 2
3. **Feedback Table visible:**
   - Headers: Coach, Category, Rating, Feedback, Date
   - Rows show feedback entries with coach name (from profiles), category badge, star display, text preview (first 50 chars + "..."), date formatted
   - Pagination controls at bottom (20 items per page)

**Expected:** All KPI cards calculate correctly, table displays feedback with proper formatting

### T10: Admin Filters
**Location:** `/admin/feedback`

**Steps:**
1. Visit `/admin/feedback` with multiple feedback entries (different categories, ratings, personas, dates)
2. **Filter by Category:** Select "Bug" → table shows only bug reports
3. **Filter by Rating:** Select "2 stars" → table shows only 2-star ratings
4. **Filter by Persona:** Select "C" → table shows only Persona C feedback
5. **Filter by Date Range:** 
   - Set start date to 7 days ago
   - Set end date to today
   - Table shows only feedback from that range
6. **Clear Filters:** Click "Clear filters" button → all filters reset, table shows all 20 items
7. **Combined Filters:** Select Category=Module AND Rating=5 Stars → table shows intersection

**Expected:** Filters apply correctly, pagination resets to page 1, clear button restores default view

### T11: RLS Verification
**Account:** Non-admin coach

**Steps:**
1. Log in as non-admin coach
2. Open browser DevTools → Network tab
3. Try direct API call: `SELECT * FROM feedback;` via Supabase JS client
4. Result: Error (permission denied) OR empty result set (RLS filters user's own feedback only)

**Expected:** Non-admin cannot query all feedback, only admins can via `/admin/feedback`

### T12: Data Persistence
**Steps:**
1. Submit feedback from `/dashboard`
2. Switch to admin account
3. Visit `/admin/feedback`
4. Search for the feedback entry by coach name/email
5. Verify all fields (category, rating, positive text, improvement text, timestamp, persona snapshot) are stored

**Expected:** All feedback data persists correctly to database

## Checklist

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

## Notes

- Migration must be applied before testing: `/supabase/migrations/20260506000000_feedback_chatbot.sql`
- Test with at least 5 feedback entries (use admin panel or direct DB insert for seeding)
- Cooldown test requires 60 seconds of real time
- Mobile test best done with actual device or Chrome DevTools mobile emulation
