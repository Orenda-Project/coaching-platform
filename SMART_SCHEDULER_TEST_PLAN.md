# Smart Scheduler — End-to-End Testing Plan

**Goal:** Verify the complete Smart Scheduler workflow before DC dashboard integration  
**Duration:** ~30 minutes  
**Data:** Dummy test data, real user account  

---

## Phase 1: Setup (5 min)

### 1.1 Apply Migration to Remote Supabase
```bash
cd coaching-platform
npx supabase db push
```
✅ Expected: `teacher_dc_scores` table created with RLS policies

### 1.2 Seed Test Data
Go to Supabase Studio → SQL Editor → paste:
```sql
INSERT INTO public.teacher_dc_scores 
  (observer_id, teacher_name, school_name, region, subject, grade, framework, total_score, proficiency_level, scored_at)
VALUES
  ('<USER_UUID>', 'Ayesha Khan',    'Gov School F-10',  'ICT', 'Math',    'Grade 4', 'FICO', 28,  'Needs Improvement', NOW() - INTERVAL '5 days'),
  ('<USER_UUID>', 'Bilal Ahmed',    'Gov School G-9',   'ICT', 'English', 'Grade 5', 'FICO', 55,  'Developing',        NOW() - INTERVAL '3 days'),
  ('<USER_UUID>', 'Sara Malik',     'Gov School F-10',  'ICT', 'Science', 'Grade 6', 'FICO', 68,  'Proficient',        NOW() - INTERVAL '10 days'),
  ('<USER_UUID>', 'Usman Tariq',    'Gov School G-9',   'ICT', 'Urdu',    'Grade 3', 'FICO', 82,  'Advanced',          NOW() - INTERVAL '1 day'),
  ('<USER_UUID>', 'Fatima Noor',    'Gov School I-8',   'ICT', 'Math',    'Grade 5', 'FICO', 35,  'Needs Improvement', NOW() - INTERVAL '7 days');
```
Replace `<USER_UUID>` with your actual Supabase user UUID.

✅ Expected: 5 rows inserted into teacher_dc_scores

### 1.3 Start Dev Server
```bash
npm run dev
```
✅ Expected: App loads on http://localhost:5173

---

## Phase 2: Smart Scheduler Frontend (8 min)

### 2.1 Navigate to Smart Plan Tab
- Log in with your account
- Go to ObservationScheduler (sidebar or /observation-scheduler)
- Click the **Smart Plan** tab (5th tab, calendar icon)

### 2.2 Verify Priority List View
**Expected ranking (top to bottom):**
1. **Ayesha Khan** — CRITICAL (score 28, red badge) — "never visited" or "7d overdue"
2. **Fatima Noor** — CRITICAL (score 35, red badge) — "7d overdue"
3. **Bilal Ahmed** — HIGH (score 55, yellow badge) — "3d overdue"
4. **Sara Malik** — MEDIUM (score 68, blue badge) — "10d overdue"
5. **Usman Tariq** — LOW (score 82, green badge) — "1d since last visit"

**Check:**
- [ ] Teachers are ranked by tier (CRITICAL → HIGH → MEDIUM → LOW)
- [ ] Teachers in the same tier are sorted by days-overdue (descending)
- [ ] Score displayed correctly (28/100, 35/100, etc.)
- [ ] Proficiency level shown

### 2.3 Verify Weekly Plan View
Click **Weekly Plan** tab.

**Expected:**
- Shows 8 slots (up to 2/day, Mon–Fri)
- Schools are clustered (e.g., both F-10 teachers on same day if space)
- Visits show teacher → school → purpose (e.g., "Urgent support needed")
- Capacity footer shows "X visits scheduled out of 8 available slots"

**Check:**
- [ ] First 5 teachers fit into this week (up to 8 slots available)
- [ ] Days are Mon–Fri
- [ ] School clustering works (if 2 visits to F-10, they're same day)
- [ ] Capacity summary accurate

### 2.4 Verify 4-Week Overview
Click **4-Week Overview** tab.

**Expected:**
- Week 1 shows visits from weekly plan
- Week 2–4 show overflow teachers (any beyond 8 slots/week)
- Each visit colour-coded: CRITICAL (red), HIGH (yellow), MEDIUM (blue), LOW (green)
- Summary footer: "X total visits across 4 weeks · Y critical · Z schools"

**Check:**
- [ ] All 5 teachers appear somewhere in 4 weeks
- [ ] Colour coding matches tier
- [ ] Week boundaries are correct (Mon–Fri per week)
- [ ] Summary stats are accurate (should show 5 visits, 2 critical, 3 schools)

---

## Phase 3: Workflow — Visit Creation & Completion (10 min)

### 3.1 Schedule a Visit
- Go to **Schedule** tab (CoachingHubTab)
- Click "Schedule Observation"
- Fill form:
  - Teacher: "Ayesha Khan"
  - School: "Gov School F-10"
  - Subject: "Math"
  - Grade: "Grade 4"
  - Topic: (any)
  - Date: (today)
- Click "Schedule Observation"

✅ Expected: Dialog closes, observation appears in "In Progress" tab

### 3.2 Open Visit Panel
- Click on the observation in "In Progress" tab
- QuickObservationPanel opens (full-screen overlay)

**Verify:**
- [ ] Header shows "Ayesha Khan" + school + subject + grade + FICO badge
- [ ] "Visit Notes" textarea visible
- [ ] **NO DC Analysis component** (DC removed)
- [ ] NeoAnalysis component visible immediately

### 3.3 Record Neo Debrief
- In NeoAnalysis component, start recording audio (browser will prompt for mic access)
- Record ~5 seconds of dummy audio
- Click "Upload & Process"

✅ Expected:
- [ ] Upload shows progress
- [ ] Status changes to "Processing debrief..." (blue)
- [ ] After ~3–5 sec, changes to "Debrief analysed" (green) + "Done" badge
- [ ] neo_results appear in component (overall score, grade, section scores)

### 3.4 Mark Visit Complete
- Click "Mark Visit Complete" button (bottom-right)

✅ Expected:
- [ ] Saving spinner appears
- [ ] Button disabled until save completes
- [ ] Toast: "Visit marked complete!"
- [ ] Panel closes
- [ ] Observation moves from "In Progress" → "Submitted" tab

### 3.5 Verify Observation in Submitted Tab
- Click "Submitted" tab
- Find "Ayesha Khan" observation

**Verify:**
- [ ] Status badge shows "Submitted"
- [ ] Score, proficiency level displayed
- [ ] Neo results visible (grade A–F, section scores)

---

## Phase 4: Smart Scheduler Data Update (5 min)

### 4.1 Return to Smart Plan Tab
- Click "Smart Plan" tab again

**Expected:**
- Ayesha Khan's "lastVisitDate" updates to today
- Ayesha Khan's urgency decreases (days overdue = 0)
- Ranking may shuffle: Fatima might move up, Ayesha down (but still CRITICAL)

**Check:**
- [ ] Last visit date shows "today"
- [ ] Days overdue decreases or resets
- [ ] Ranking re-calculates automatically (no manual refresh needed)

### 4.2 Verify Weekly Plan Updates
- Click "Weekly Plan" tab
- Ayesha's slot may be replaced by another teacher (if she slipped down priority)

**Check:**
- [ ] Weekly plan regenerates with new ranking
- [ ] Capacity still shows "X/8 visits"

---

## Phase 5: Webhook Testing (2 min)

### 5.1 Test dc-scores-ingest Endpoint
Open a new terminal and run:

```bash
curl -X POST https://kddvxrlffafyjvvststh.supabase.co/functions/v1/dc-scores-ingest \
  -H "Content-Type: application/json" \
  -d '{
    "observer_id": "<USER_UUID>",
    "teacher_name": "New Teacher",
    "school_name": "New School",
    "region": "ICT",
    "subject": "Math",
    "grade": "Grade 5",
    "framework": "FICO",
    "total_score": 45,
    "proficiency_level": "Developing",
    "scored_at": "'$(date -u +'%Y-%m-%dT%H:%M:%SZ')'",
    "results": null
  }'
```

Replace `<USER_UUID>` with your UUID.

✅ Expected:
- [ ] HTTP 200 response: `{"ok": true}`
- [ ] New row appears in teacher_dc_scores table (check Supabase Studio)
- [ ] Smart Scheduler tab shows new teacher in ranking

---

## Phase 6: Edge Cases (5 min)

### 6.1 Tier Change Alert
Manually update one teacher's score in Supabase Studio:
- Find "Bilal Ahmed" (currently HIGH at 55)
- Change total_score to 30 (drops to CRITICAL)
- Return to Smart Plan tab

**Expected:**
- [ ] Alert banner appears: "Priority escalated — visit sooner"
- [ ] Bilal moved to CRITICAL, ranked above Usman
- [ ] Weekly plan regenerates with Bilal higher

### 6.2 Never-Visited Teacher
Manually insert a new teacher with no observation:
```sql
INSERT INTO public.teacher_dc_scores 
  (observer_id, teacher_name, school_name, region, subject, grade, framework, total_score, proficiency_level, scored_at)
VALUES
  ('<USER_UUID>', 'Hassan Ali', 'Gov School X', 'ICT', 'Urdu', 'Grade 2', 'FICO', 50, 'Developing', NOW());
```

**Expected:**
- [ ] Teacher appears as CRITICAL (even though score is 50 → normally HIGH)
- [ ] Urgency = 9999 (always top of list)
- [ ] No "last visit" date shown

### 6.3 Overdue Urgency Creep
Manually update "Usman Tariq"'s last visit to 30 days ago:
```sql
-- (This tests urgency accumulation)
```

**Expected:**
- [ ] Days overdue increases
- [ ] Urgency score increases
- [ ] Ranking may shift if overdue days exceed another teacher's

---

## Verification Checklist

**Smart Scheduler Frontend:**
- [ ] Priority List: correct tier ranking, no DC components
- [ ] Weekly Plan: 8 slots max, Mon–Fri, school clustering
- [ ] 4-Week Overview: full month, colour-coded, summary stats

**Workflow:**
- [ ] Schedule visit → panel opens instantly
- [ ] Neo debrief records, processes, updates status
- [ ] Mark Visit Complete → observation submitted
- [ ] Last visit date updates in DB

**Webhook:**
- [ ] dc-scores-ingest accepts POST, returns 200
- [ ] New scores appear in teacher_dc_scores table
- [ ] Smart Scheduler reflects new data automatically

**Edge Cases:**
- [ ] Tier escalation → alert fires, ranking updates
- [ ] Never-visited → forced CRITICAL
- [ ] Overdue → urgency increases with days

---

## Known Gaps (TBD with DC Owner)

1. **Coach Identification:** The dc-scores-ingest webhook currently requires `observer_id` (Supabase UUID). The DC dashboard likely identifies coaches by email or ID. Need mapping logic.
   - Solution TBD: API route that maps email → Supabase UUID, or DC dashboard learns UUIDs.

2. **Score Sync Frequency:** How often does DC dashboard push new scores? Real-time? Hourly? Daily?
   - Current: Webhook is always-on, responds to each POST.

3. **Historical Trend Data:** For score trend detection (falling/improving), we compare last 2 scores. If DC dashboard only sends latest, trend won't work initially.
   - Solution: Once integration live, monitor 2+ weeks of scores to enable trend.

---

## Success Criteria

✅ **All tests pass if:**
- Smart Plan tab shows correct ranking (tier + urgency)
- Visit workflow completes end-to-end (schedule → debrief → submit)
- Last visit date updates in DB and ranking recalculates
- Webhook accepts scores and reflects them in UI
- Tier change alerts fire correctly
- No TypeScript errors, all components render

**Ready to integrate DC dashboard when:**
- Coach ID mapping defined (email → UUID or equivalent)
- DC dashboard owner confirms webhook URL and payload format
- 2+ weeks of historical scores available for trend detection
