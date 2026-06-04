# Coaching Platform — Complete Documentation
**Version:** 2.0 | **Updated:** 2026-05-13 | **Owner:** Coaching Platform Team

---

## Table of Contents
1. Platform Overview
2. User Flows & Engagement
3. Feature Inventory
4. Data Architecture & Tracking
5. Release Notes (All Releases)
6. Retention & Growth Strategy
7. Technical Stack

---

## 1. Platform Overview

### What It Is
Coaching Platform is an AI-assisted teacher coaching tool for ICT/Islamabad. Coaches visit schools, observe lessons, record debrief conversations with Neo AI, and receive actionable coaching insights in real-time.

### Why It Matters
- **For coaches:** Structured coaching feedback (instead of ad-hoc visits) + Neo AI insights (instead of manual note-taking) = higher confidence + measurable teacher improvement
- **For teachers:** Actionable coaching (specific practices to improve) + follow-up visits (coaches come back to check progress) = faster skill development
- **For organization:** Scalable coaching (one coach can reach 20+ teachers) + measurable impact (Neo scores show improvement) = ROI on coaching budget

### Core Metrics (Targets)
| Metric | Target | Current |
|--------|--------|---------|
| **Coaches trained to completion** | 85% | 70% |
| **Visits per coach per month** | 4+ | 2.5 |
| **Debrief recordings completed** | 90% | 40% |
| **30-day retention** | 70% | 55% |
| **Teacher improvement observed** | 75% | TBD (Q3) |

---

## 2. User Flows & Engagement

### User 1: Coach (Primary User)

#### Signup & Onboarding (Day 1)
**Goal:** Get coaches trained on coaching methodology + platform
**Steps:**
1. Email signup
2. Baseline assessment (10 Q, 5 min) → Persona (A/B/C/D tells coach their current coaching level)
3. Watch 6 modules (15-20 min each, video + slides)
4. Pass quiz for each module (80% minimum, 3 attempts allowed)
5. Get certificate (PDF download)

**Why this matters:**
- Baseline assessment → coaches understand their starting point, sets growth mindset
- Modules teach actual coaching methodology (not just "use the app")
- Certificate → coaches have proof of training, managers verify completion
- Staggered completion → coaches get quick wins (complete module 1 day 1, module 2 day 2)

**Engagement hooks:**
- Badge for each module completed (visible on dashboard)
- Certificate immediately available after last module (tangible achievement)
- Progress bar showing "2 of 6 modules done"

**Churn risk:** 30% drop-off on baseline assessment (too many Q?) or quiz (repeated failures)
**Mitigation:** Q3 - simplify baseline to 5 Q, offer quiz retake coaching tips

**Conversion:** 70% of signups reach certificate (target: 85%)

---

#### Monthly Coaching Workflow (Weeks 2+)

**Week 1: Plan**
1. Coach goes to dashboard
2. Selects sub-region (BK, Nilore, Urban-I, etc.)
3. Sees assigned teachers (per sub-region roster)
4. Picks teacher, clicks "Schedule Visit"
5. Fills: date + purpose + optional topic
6. Creates observation (Draft status)

**Engagement:** Scheduling takes 2 min, feels low-friction
**Data track:** Visit creation rate, topic distribution (what coaches focus on)

**Days 2-3: Visit**
1. Coach travels to school
2. Observes lesson (typically 30-45 min)
3. Records debrief conversation (30-120 sec typical)
4. Uploads debrief audio to platform
5. Neo processes (2-5 min wait)
6. Sees Neo insights instantly

**Engagement:** Recording + upload + insights = 5 min total time investment
**Data track:** Recording completion rate, upload success rate, insight view rate
**Friction point (solved 2026-05-13):** If offline → upload fails → coach loses audio → doesn't retry
**Solution:** Offline audio queue auto-saves + auto-syncs

**Days 4-5: Review**
1. Coach returns to observation in app
2. Re-reads Neo insights (framework breakdown, key action items)
3. Reviews observation (teacher name, school, date, Neo score)
4. Marks "Visit Complete" → submits

**Engagement:** Revisiting insights reinforces learning
**Data track:** Review rate, time-between-record-and-submit

**Month End: Track Impact**
1. Coach goes to dashboard
2. Sees "Coaching Summary" (new Q3 feature)
   - 4 visits completed
   - 3 repeat visits (visited same teacher twice)
   - Repeat visit scores: Teacher A went 65 → 78 (improvement!)
3. Feels: "My coaching is working"

**Engagement:** Seeing improvement = primary retention driver (validates all the work)
**Data track:** Repeat visit rate, improvement delta, coach retention at 30/60/90 days

---

### User 2: Teacher (Secondary User - Future)
**Status:** Not in current release | **Planned:** Q4 2026

**Flow (future):**
1. Teacher gets link from coach (QR code or SMS)
2. Can see their own observation history
3. Views coaching feedback (what to improve next)
4. Tracks progress across visits (score trend)

**Why it matters:** Teacher buy-in = better cooperation during coaching visits = coaching more effective

---

### User 3: Manager (Secondary User - Future)
**Status:** Not in current release | **Planned:** Q4 2026

**Flow (future):**
1. Manager logs in
2. Sees all coaches in their region
3. View per-coach: visits completed, teachers coached, improvement observed
4. Can see which teachers are struggling (recommend more visits)
5. Can export coaching summary for donor reporting

**Why it matters:** Manager accountability = coaches complete more visits (manager oversight drives behavior)

---

## 3. Feature Inventory

### Released Features (May 2026)

#### Feature 1: Signup & Baseline Assessment
- **Release:** 2026-04-08
- **Purpose:** Onboard coaches, measure baseline knowledge
- **What happens:** Coach creates account → answers 10 Q → gets persona score
- **Persona mapping:**
  - A: 75%+ baseline score → Already strong coach, quick to adopt Neo insights
  - B: 70% baseline → Solid coach, benefits from Neo structure
  - C: 65% baseline → Needs support, Neo feedback critical
  - D: 60% baseline → Struggling coach, recommend mentor pairing
- **Data collected:** Raw baseline score, persona, signup path (direct/link)
- **Data tracked:** Completion rate, persona distribution, correlation with module completion

---

#### Feature 2: Training Modules (6 Total)
- **Release:** 2026-04-08
- **Modules:**
  1. Coaching Fundamentals (what is coaching?)
  2. Observation Framework (what to look for in classroom)
  3. Question Techniques (how to ask good coaching questions)
  4. Feedback Delivery (how to give feedback coaches can use)
  5. Action Planning (how to set goals with teachers)
  6. Measuring Improvement (how to track teacher progress)

- **Format:** 15-20 min video + slides + quiz
- **Content gate:** Must watch 90% of video OR read 100% of slides before quiz unlocks
- **Quiz:** 5-8 questions, 80% to pass, 3 attempts max
- **Pass criteria:** 3/3 modules passed → certificate available
- **Data tracked:** Module view time, quiz attempt count, quiz scores, time-to-completion

---

#### Feature 3: School Visit Scheduling
- **Release:** 2026-05-12
- **What:** Coach plans a visit to observe a specific teacher
- **Input fields:**
  - Teacher (pre-selected based on sub-region assignment)
  - Visit date (must be today or future)
  - Purpose of visit (free text: "Classroom Observation", "Lesson Plan Review", etc.)
  - Lesson topic (optional: "Fractions", "Constitutional Rights", etc.)
- **Output:** Observation created in Draft status
- **Data tracked:** Visit creation rate, purpose distribution, topic trends, follow-up visit rate (same teacher, different date)

---

#### Feature 4: Debrief Recording (Audio)
- **Release:** 2026-04-15
- **Latest:** Pause/resume/stop controls (2026-05-13), offline auto-sync (2026-05-13)
- **What:** Coach records conversation with Neo AI after lesson
- **Tech:** MediaRecorder API (browser native), WebM codec, 15-30 MB per recording
- **UX:**
  - Red record button (big, easy to tap)
  - Pause/resume toggles during recording
  - Stop button (saves recording)
  - Audio player shows saved recording (can listen before submitting)
  - "Discard" option (delete and re-record)
  - "Upload" button (sends to Neo)
  
- **Offline Resilience (NEW 2026-05-13):**
  - If upload fails (navigator.onLine = false), audio saves to IndexedDB locally
  - Observation marked as Draft (not Lost)
  - Coach sees amber "Audio Queued" badge
  - When internet returns, auto-uploads silently
  - No manual action needed, no re-recording required
  
- **Data tracked:** Recording rate, recording duration, upload success rate, offline instances, auto-sync success rate

---

#### Feature 5: Neo Debrief Analysis
- **Release:** 2026-04-15
- **What:** AI analyzes debrief audio, returns coaching insights
- **Backend:** Supabase Edge Function (neo-start endpoint)
- **Processing:** 2-5 min typical (varies by audio length + Neo queue)
- **Output:**
  - Neo score (0-100)
  - Framework breakdown (if FICO framework: Facilitation 78%, Inquiry 82%, Coaching 70%, Observation 85%)
  - Key insights ("Strong use of open-ended questions", "Could probe more on student understanding")
  - Action items (3-5 specific next-step suggestions)
  
- **UX:** Coach sees insights in NeoAnalysis panel (embedded in observation card)
- **Data tracked:** Analysis lag time, insight quality (proxy: coach re-view rate), framework distribution

---

#### Feature 6: Observation Review & Submission
- **Release:** 2026-04-15
- **What:** Coach reviews observation, sees Neo insights, submits as complete
- **Flow:**
  1. Coach opens observation card (from In Progress tab)
  2. Sees: teacher name, school, date, topic, Neo score + insights
  3. (Optional) edits observation notes
  4. Clicks "Mark Visit Complete"
  5. Observation moves to Submitted tab (locked, read-only)
  
- **Data tracked:** Submission rate, time-in-draft (how long coach reviews before submitting), insight re-read rate

---

#### Feature 7: Dashboard (Coach Home)
- **Release:** 2026-04-08
- **What:** Coach sees their progress at a glance
- **Sections:**
  - **Welcome:** "Hi [Coach Name], you're [Persona]"
  - **Coaching Summary (new Q3):** Visits this month (4), Teachers coached (12), Repeat visits (2)
  - **Training Progress:** Modules completed (6/6), Certificate status (Earned!)
  - **Next Steps:** "Schedule a visit" or "Review pending debrief"
  - **Recent Activity:** Last 3 observations
  
- **Data tracked:** Dashboard view rate, section view rates, correlation with engagement

---

#### Feature 8: Submitted Observations Tab
- **Release:** 2026-04-15
- **What:** Historical archive of all completed coaching visits
- **Fields per observation:** Teacher name, school, date, purpose, topic, Neo score, framework scores
- **UX:** Expandable cards (click to see full insights)
- **Data tracked:** Tab view rate, observation re-read rate, historical comparison (did coach improve on repeat visits?)

---

#### Feature 9: Mobile-Responsive UI
- **Release:** 2026-04-08
- **Tested at:** 375px viewport (iPhone SE baseline)
- **What works on mobile:**
  - Signup flow
  - Module viewing (video plays responsively)
  - Quiz taking
  - Visit scheduling
  - Recording (MediaRecorder works on mobile browsers)
  - Observation review
  - Dashboard
  
- **Known limitations:** Large data tables (e.g., full teacher roster) truncate on mobile; use dropdown filter instead
- **Data tracked:** Mobile vs desktop session split, mobile task completion rate

---

#### Feature 10: Certificate (PDF Download)
- **Release:** 2026-04-08
- **What:** Coach downloads proof of training completion
- **Fields on certificate:**
  - Coach name
  - Date completed
  - Modules completed (6/6)
  - Baseline persona
  - QR code (links to verification endpoint - TBD)
  
- **Data tracked:** Download rate, sharing behavior (if we add share button later)

---

#### Feature 11: Offline Form Storage (Observations)
- **Release:** 2026-04-15
- **What:** If coach loses connectivity while scheduling visit, form auto-saves locally
- **Tech:** IndexedDB (local database on device)
- **UX:** No UI indication (silent save), coach can close browser, form still there on return
- **Data tracked:** Form save rate (proxy for offline instances), form loss rate (should be 0%)

---

#### Feature 12: Offline Audio Queue (NEW 2026-05-13)
- **Release:** 2026-05-13
- **What:** If debrief upload fails (offline), audio blob saves locally, auto-uploads when online
- **Tech:** IndexedDB (same store as forms), module-level lock mechanism (prevents duplicate uploads)
- **UX:**
  - Amber "Audio Queued" badge on observation card
  - Badge clears when upload succeeds
  - Coach can navigate away, audio syncs silently
  - Auto-sync happens on:
    - Same session (window.addEventListener('online'))
    - Next app open (ObservationScheduler.useEffect)
  
- **Why it matters:** Coaches never lose debrief audio → always get Neo insights → perceived value stays high
- **Data tracked:** Audio loss rate (target < 5%, was 60%), auto-sync success rate (target 99%+), offline instances

---

### Upcoming Features (Q3 2026)

#### Feature 13: Coaching Summary Dashboard (Q3)
**Problem:** Coach doesn't see coaching impact
**Solution:** New dashboard section showing:
- Visits this month + trend (4 this month vs 2 last month = +100%)
- Unique teachers coached
- Repeat visits (Coach A visited Teacher 1 twice, scores: 65 → 78)
- Average Neo score (across all visits)

**Retention impact:** +12-15% (coaches see their work matters)

---

#### Feature 14: Offline Form Submission (Q3)
**Problem:** Coach can't save observation form if offline
**Solution:** Use same IndexedDB mechanism as audio
- Coach fills visit form → no internet → form saves locally
- Coach goes home, internet returns
- Form auto-syncs to server
- No data loss, no manual re-entry

**Engagement impact:** +5-8% (fewer incomplete visits)

---

#### Feature 15: Teacher Improvement Tracking (Q3)
**Problem:** Coaches don't measure coaching ROI
**Solution:** Compare same teacher across visits
- "You visited Teacher A on May 5 (score 65) and May 20 (score 78)"
- Show: +13 point improvement
- Show: Which practices improved ("Student engagement went from Good to Strong")

**Retention impact:** +8-10% (validates coaching effectiveness)

---

## 4. Data Architecture & Tracking

### Data Model

#### Core Tables
```
observations (cot_observations)
  - id, observer_id, teacher_id, school_id
  - date, status (Draft/Submitted/Approved)
  - visit_purpose, lesson_topic
  - neo_status (pending/processing/completed)
  - neo_score, neo_framework_scores (JSON)
  - created_at, updated_at

teachers (dc_teachers)
  - id, name, school_id, subject, grade
  - level (primary/middle/secondary)

coaches (user_teacherprofile + users_user)
  - id, name, email, organization_id, sub_region
  - baseline_persona, baseline_score
  - certification_status, date_certified

schools (schools_school)
  - id, name, emis, sub_region
```

#### Offline Storage (IndexedDB - Device Local)
```
pending_uploads store:
  - observation_id (key)
  - blob (audio file)
  - mime_type, queued_at, observer_id

saved_audio store:
  - observation_id (key)
  - blob, mime_type, saved_at
```

### Metrics to Track

#### Engagement Metrics (Real-time Dashboard)
| Metric | Why | How |
|--------|-----|-----|
| **Recording completion rate** | If coaches don't record, no Neo insights | Observations with audio / Total observations |
| **Upload success rate** | If uploads fail, audio is lost | Successful uploads / Upload attempts |
| **Submission rate** | If coaches don't submit, visit is incomplete | Submitted obs / Drafted obs |
| **Visit frequency** | Core engagement signal | Visits/coach/month (target: 4+) |
| **Repeat visit rate** | Indicates coaching impact (coach follows up) | Observations with same teacher, different date / Total observations |

#### Data Quality Metrics (Automated Alerts)
| Metric | Alert If | Owner |
|--------|----------|-------|
| **Audio loss rate** | > 10% | Engineering (offline queue issue) |
| **Neo analysis lag** | > 20 min | Backend team (neo-status endpoint issue) |
| **Form submission success** | < 95% | Engineering (form validation issue) |
| **Auto-sync success rate** | < 98% | Engineering (network retry logic issue) |

#### Retention Metrics (Weekly)
| Metric | Target | Owner |
|--------|--------|-------|
| **30-day retention** | 70% | Product (feature design) |
| **Churn rate** | < 8%/month | Product |
| **Days since last visit** | < 10 (average) | Engagement (identify inactive coaches) |

#### Teacher Impact Metrics (Monthly - Q3+)
| Metric | Why | Proxy |
|--------|-----|-------|
| **Teacher improvement rate** | How many coaches see teacher scores improve? | Repeat visit delta score (obs2 - obs1) |
| **Coaching plan adherence** | How many coaches follow recommendations? | TBD (Q4) |
| **Teacher satisfaction** | Do teachers feel coached? | NPS (future survey) |

### Implementation
- **Frontend tracking:** Segment/Amplitude (user actions: record, submit, view insights)
- **Backend tracking:** Supabase logs + custom analytics table
- **Dashboard:** Grafana/Metabase pulling from analytics data warehouse
- **Alerts:** Slack integration for data quality issues

---

## 5. Release Notes (All Releases)

### Release 1.0 (2026-04-08)
**Title:** Coaching Platform MVP - Signup, Training, Baseline
**What's new:**
- Signup with email verification
- Baseline assessment (10 Q, 5 min)
- 6 training modules (video + slides + quiz)
- Certificate of completion (PDF download)
- Dashboard with progress tracking
- Mobile-responsive design (tested at 375px)

**Why it matters:**
- Coaches get trained on coaching methodology before using the platform
- Baseline assessment → personalized coaching (persona-based recommendations future)
- Certificate → proof of training for employers/managers

**Known limitations:**
- No live teacher data (seeded test data only)
- No Neo integration yet (coming next release)

---

### Release 1.1 (2026-04-15)
**Title:** Coaching Platform - Observation Workflow & Neo Integration
**What's new:**
- Schedule school visits (date, purpose, topic)
- Live teacher roster (56 teachers, 6 sub-regions)
- Record debrief audio (MediaRecorder, pause/resume)
- Neo AI debrief analysis (2-5 min processing)
- View Neo insights (framework breakdown, scores, action items)
- Submit observations (move from Draft to Submitted)
- Submitted observations archive (historical view)

**Why it matters:**
- Coaches can now do actual coaching (plan → visit → debrief → insights)
- Neo AI provides real-time feedback (instead of manual note-taking)
- Submitted archive lets coaches track their progress

**Breaking changes:** None (additive release)

**Migration:** None (new tables, no schema changes to existing data)

**Testing:** 
- Signup → Module completion → Schedule visit → Record audio → Submit observation
- Full coaching flow works end-to-end
- Audio files persist in Supabase Storage
- Neo analysis returns insights within 5 min

---

### Release 1.2 (2026-05-13)
**Title:** Offline Resilience & Accessibility Improvements
**What's new:**
- Offline audio queue: auto-saves debrief on upload failure, auto-syncs when online
  - Works on same session + next app open
  - Zero manual action needed, zero data loss
- Recording UI improvements: pause/resume, stop, player preview
- Form accessibility: proper label/input associations (id + htmlFor)
- Lock mechanism: prevents duplicate uploads (concurrent tabs/sessions)
- Unit tests for offline queue lock semantics

**Why it matters:**
- Coaches in low-connectivity zones (Islamabad sub-regions) never lose audio
- Audio loss rate expected to drop 60% → < 5%
- Debrief completion rate expected to rise 40% → 85%+
- Coaches in field feel platform is trustworthy

**Breaking changes:** None (additive release)

**Migration:** None (new IndexedDB structure, no server schema changes)

**Data implications:**
- Audio files may now arrive hours/days after recording (async)
- Neo analysis may lag; expected to smooth out after offline queue fills
- Track auto-sync lag time (metric: when does queued audio actually upload?)

**Testing:**
- DevTools Network → Offline
- Record debrief, click submit
- → "Audio saved, waiting for connection" (amber badge)
- DevTools Network → Online
- → Auto-upload triggers (visible in browser logs)
- → Neo analysis starts automatically

---

## 6. Retention & Growth Strategy

### Current Retention Crisis (Why 55%?)

**Fact:** 45% of coaches who complete training churn by day 30
**Root cause analysis:**

1. **Audio loss (60% of observations)** → Coaches record debrief → upload fails (offline) → audio lost → no Neo insights → feels useless → stops using
2. **No visible impact** → Coaches can't see they're making a difference → motivation drops → stops visiting
3. **Onboarding friction** → 30% drop-off on baseline assessment (too many Q?) or quiz (failed attempts)

**Solution roadmap:**

| Problem | Q2 Solution | Expected Lift |
|---------|-------------|---------------|
| Audio loss | Offline queue (2026-05-13) | -50% churn from audio loss |
| No visible impact | Coaching dashboard (Q3) | -40% churn from low motivation |
| Onboarding friction | Simplify baseline + quiz tips (Q3) | -30% churn from signup |

**Expected result:** 55% → 70% retention at 30 days

---

### Engagement Drivers (Month 2+)

Once coaches complete training, what keeps them coming back?

1. **Scheduled visits are easy** (2 min to book) → coaches schedule proactively
2. **Recording works (offline features)** → coaches trust the platform
3. **Neo insights are immediate** (5 min wait) → coaches see value fast
4. **Coaching impact is visible** (improvement delta, repeat visits) → coaches feel effective
5. **Low time investment** (30 min visit + 5 min upload + 5 min review = 40 min total) → manageable workload

**Proxy metrics:**
- Visit frequency (4+ per month = healthy)
- Repeat visit rate (coach visits same teacher twice = coaching effectiveness belief)
- Debrief completion rate (90%+ = trust in platform)

---

### Growth Strategy (Expansion Beyond ICT)

**Phase 1 (Current):** ICT/Islamabad only (56 teachers, ~20 coaches)
**Phase 2 (Q4):** Rawalpindi (50+ teachers, 15+ coaches)
**Phase 3 (Q1 2027):** Moawin/Akhuwat (70+ teachers, 20+ coaches)

**Success criteria before expansion:**
- 70% retention in ICT (validates product)
- 50%+ repeat visit rate (validates coaching effectiveness)
- < 5% audio loss rate (offline features working)
- Manager dashboard (Rawalpindi managers need visibility)

---

## 7. Technical Stack

### Frontend
- **Framework:** React 18 + TypeScript
- **UI:** Shadcn/ui (Tailwind CSS)
- **State:** React hooks (Context, useState, useCallback)
- **Storage:** IndexedDB (offline audio/forms), localStorage (user prefs)
- **Audio:** MediaRecorder API (browser native, WebM codec)

### Backend
- **Database:** Supabase PostgreSQL
- **Storage:** Supabase Storage (audio files)
- **Auth:** Supabase Auth (email/password)
- **Serverless:** Supabase Edge Functions (neo-start, neo-status)
- **Neo AI:** External Neo service (contract with Orenda)

### Deployment
- **Frontend:** Vite (build) + Railway (hosting)
- **Branches:**
  - `main` → Production (auto-deploy)
  - `staging` → Staging (auto-deploy)
  - `feature/*` → Local testing only
- **Database:** Supabase (staging project + production project)

### Monitoring & Analytics
- **Frontend analytics:** Segment/Amplitude (user actions)
- **Error tracking:** Sentry (frontend + backend errors)
- **Performance:** Grafana (request latency, error rates)
- **Data warehouse:** TBD (for metrics dashboard)

---

## Next Steps for Manager Review

**Questions to discuss:**
1. Does retention strategy (offline + dashboard + repeat visit tracking) align with org goals?
2. Are data tracking metrics sufficient for stakeholder reporting?
3. Timeline: Can we hit 70% retention target by end of Q3?
4. Resources: Do we have capacity for 3 concurrent features (offline forms + dashboard + teacher tracking) in Q3?
5. Manager dashboard: Can we deprioritize (or do we need it before Q3 launch)?

**Decisions needed:**
- Approve Q3 roadmap (3 features: offline forms, engagement dashboard, teacher tracking)?
- Approve data collection strategy (Segment + Grafana)?
- Approve expansion criteria (70% retention gate before Rawalpindi)?

---

**Document prepared for:** Manager review | **By:** Coaching Platform Team | **Date:** 2026-05-13
