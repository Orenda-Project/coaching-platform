# Coaching Platform — Complete Product Roadmap
**Organization:** Taleemabad | **Focus:** Teacher coaching for ICT/Islamabad | **Updated:** 2026-05-13

---

## Platform Vision

**Goal:** Help coaches improve teacher effectiveness through structured observation + AI coaching feedback.

**Theory of change:**
1. Coach visits school → observes lesson
2. Records debrief audio with Neo AI
3. Neo analyzes and gives coaching insights
4. Coach uses insights to guide teacher improvement
5. Teacher teaches better → students learn more

**Why it matters:** Most coaching is ad-hoc ("visit, chat, leave"). This platform makes it structured, measurable, and AI-assisted.

**Success = High coaching completion rates + coaches see teacher improvement + coaches retain**

---

## Current Platform State (Shipped)

### Core User Flows

#### Flow 1: Coach Signup & Training
**Users:** New coaches (target: ICT/Islamabad coaches)
**Steps:**
1. Sign up with email
2. Complete baseline assessment (10 Qs) → Persona (A/B/C/D)
3. Watch training modules (6 total) → Pass quiz (80%+ required)
4. Get certificate of completion
5. Access coaching dashboard

**Engagement metric:** % of signups who finish certificate (target: 70%)
**Data track:** Module completion rate, quiz attempt count, time-to-certificate
**Current state:** ✅ Live

#### Flow 2: School Visit Scheduling
**Users:** Coaches at dashboard
**Steps:**
1. Select sub-region (BK, Nilore, Urban-I, etc.)
2. See assigned teachers (56 total, seeded per sub-region)
3. Click "Schedule Visit"
4. Fill date + purpose + optional topic
5. Observation created (Draft status)

**Engagement metric:** Coaches who schedule 1+ visit per month
**Data track:** Visit scheduling rate, purpose distribution, topic relevance
**Current state:** ✅ Live | New: ScheduleVisitModal with proper accessibility

#### Flow 3: Debrief Recording & Neo Analysis
**Users:** Coaches during/after school visit
**Steps:**
1. At observation → NeoAnalysis panel
2. Record debrief conversation (30-120 seconds typical)
3. Submit for analysis
4. Neo processes (2-5 min typically)
5. Coach sees insights (framework breakdown, action items, score)

**Engagement metric:** % of observations with debrief recording (target: 90%)
**Data track:** Recording completion rate, analysis lag time, coach view rate
**Current state:** ✅ Live | New: Pause/resume + offline auto-sync (2026-05-13)

#### Flow 4: Observation Review & Submission
**Users:** Coaches in In Progress tab
**Steps:**
1. Review observation details (teacher, school, date, topic)
2. See Neo debrief insights
3. (Optional) Edit observation notes
4. Mark "Visit Complete" → submits observation
5. Observation moves to Submitted tab

**Engagement metric:** % of drafted observations that get submitted (target: 85%)
**Data track:** Submit rate, time-in-draft, retention correlation
**Current state:** ✅ Live

---

## Current Features by Engagement Driver

### Tier 1: Core Coaching Workflow (Retention Critical)

| Feature | Ship Date | Purpose | Engagement Hook | Data Track |
|---------|-----------|---------|-----------------|-----------|
| **Signup + Baseline** | 2026-04-08 | Onboard coaches, measure baseline knowledge | Certificate achievement | Completion rate, persona distribution |
| **Training Modules** | 2026-04-08 | Teach coaching methodology, content gate with video watch % | Module completion, quiz pass rate | Attempt count, time-to-pass, score distribution |
| **School Visit Scheduling** | 2026-05-12 | Plan visits, assign teachers | Visit creation, date selection | Scheduling frequency, sub-region distribution |
| **Debrief Recording** | 2026-04-15 | Capture coaching conversation, feed Neo AI | Recording completion, submission | Recording rate, audio quality, submit lag |
| **Neo Debrief Analysis** | 2026-04-15 | AI coaching feedback (framework breakdown, insights) | See insights delivered automatically | Analysis lag, insight relevance, coach view rate |
| **Observation Submission** | 2026-04-15 | Lock in coaching visit as complete | Mark visit done, move to submitted | Submit rate, time-in-draft, churn correlation |

### Tier 2: Data & Accountability (Manager Engagement)

| Feature | Ship Date | Purpose | Manager Hook | Data Track |
|---------|-----------|---------|--------------|-----------|
| **Dashboard Overview** | 2026-04-08 | Coach sees coaching progress (visits completed, modules done) | Progress visibility | Dashboard view rate, return frequency |
| **Submitted Observations Tab** | 2026-04-15 | Coaches see all completed visits | Historical reference | Tab view rate, observation review rate |
| **Neo Insights Display** | 2026-05-01 | Coaches can re-read debrief insights + scores | Review coaching feedback | Reread rate, time-on-insights |
| **Certificate PDF** | 2026-04-08 | Coaches download completion proof | Share with employer | Download rate, sharing behavior |

### Tier 3: Resilience (Field Reliability)

| Feature | Ship Date | Purpose | Reliability Hook | Data Track |
|---------|-----------|---------|-----------------|-----------|
| **Offline Form Storage** | 2026-04-15 | Save observations during connectivity loss | Complete visits even offline | Form save rate, offline duration |
| **Offline Audio Queue** | 2026-05-13 | Save debrief audio locally, auto-sync | Never lose debrief recordings | Audio loss rate, auto-sync lag, retry success |
| **Mobile Responsive UI** | 2026-04-08 | Full coaching workflow on mobile | Field work on phone | Mobile usage %, task completion rate |

---

## Engagement & Retention Mechanics

### What Drives Engagement (Coach Returns to App)

1. **Progress Visibility** → "I completed 8 visits this month, wow"
2. **Neo Insights** → "Neo said my observation was strong because of X"
3. **Teacher Improvement Signal** → "I observed same teacher twice, she improved"
4. **Reliability** → "My offline recording worked, platform is trustworthy"

**Metric:** Monthly active users (MAU), days-since-last-visit, visit frequency

### What Drives Retention (Coach Stays for 6+ Months)

1. **Perceived Coaching Value** → Coach sees teacher improving → believes coaching works
2. **Platform Reliability** → Offline features work → trust in platform
3. **Workload Fit** → Visit scheduling + debrief recording < 20 min total → feels manageable
4. **Manager Accountability** → Coach has visible record of visits → completes more

**Metric:** 30-day/90-day retention, churn rate, NPS (future)

### Current Retention Status
- **30-day retention:** 55% (target: 70%)
- **Churn drivers:** (1) Low connectivity → lost audio → no insights (2) No visibility into coaching impact (3) Signup drop-off on baseline assessment
- **Churn mitigation:** Offline audio feature (2026-05-13) + engagement dashboard (Q3)

---

## Q2 2026 — What's Shipped

### ✅ Core Platform (2026-04-08)
- Signup + onboarding
- Baseline assessment (10 questions, 4 personas)
- 6 training modules (video + slides) with content gating
- Quiz assessment (3 attempts max, 80% to pass)
- Certificate generation + PDF download
- Dashboard with progress tracking

### ✅ Observation Workflow (2026-04-15)
- Schedule school visits (date, purpose, optional topic)
- Teacher roster (56 teachers, 6 sub-regions)
- Create observations (Draft status)
- Record debrief audio (MediaRecorder, WebM codec)
- Neo edge function integration (neo-start, neo-status endpoints)
- View Neo debrief insights + framework breakdown
- Submit observations → Submitted tab

### ✅ Field Resilience (2026-05-13)
- Offline observation form storage (survives browser close)
- **Offline audio queue** (new): Auto-save on upload failure, auto-sync on connection restore
- Mobile-responsive UI (tested at 375px viewport)
- Pause/resume/stop recording controls

### ✅ Code Quality & Accessibility (2026-05-13)
- Data access layer extracted (src/data/observations.ts)
- Lock mechanism prevents concurrent uploads
- Form label accessibility (id + htmlFor associations)
- Unit tests for audioQueue lock semantics
- Type safety (SavedAudioRecord interface)

---

## Q3 2026 — What's Next

### Priority 1: Engagement Dashboard (2 weeks)
**Problem:** Coaches don't see their coaching impact → low perceived value → churn
**Solution:** New dashboard tab showing:
- Observations completed this month
- Teachers visited (with repeat visit count)
- Neo insights received (with sentiment: strong/good/needs work)
- Trend: Are coached teachers improving? (compare observation 1 vs 2 for same teacher)

**Data track:** Dashboard view rate, correlation with 30-day retention
**Expected retention lift:** +12-15%

### Priority 2: Offline Form Submission (2 weeks)
**Problem:** Coaches can't save observations in field → lose notes if connectivity drops
**Solution:** Use same IndexedDB mechanism as audio queue
- Fill observation form offline
- Save as draft locally
- Auto-sync when online
- No data loss

**Data track:** Form submission rate from field, draft-to-submitted conversion
**Expected engagement lift:** +5-8% (fewer incomplete visits)

### Priority 3: Neo Insights Notifications (1 week)
**Problem:** Coach submits debrief → walks away → doesn't see insights until next day
**Solution:** Push notification when Neo analysis completes
- "Your debrief analysis is ready: Strong observation, focus on X next time"
- Tap → view insights

**Data track:** Notification view rate, time-to-view after debrief
**Expected engagement lift:** +3-5% (immediate feedback loop)

### Priority 4: Teacher Improvement Tracking (2 weeks)
**Problem:** Coaches don't measure coaching ROI ("Did my coaching help?")
**Solution:** Compare same teacher across visits
- Observation 1 (first visit): Score 65
- Observation 2 (follow-up visit): Score 78
- Show improvement delta + Neo's specific feedback on what changed

**Data track:** Improvement tracking view rate, multi-visit completion rate
**Expected retention lift:** +8-10% (coaches see their work matters)

---

## Q4 2026 — Medium-Term Growth

### Coaching Plan Builder (4 weeks)
**Problem:** Coaching is reactive ("Visit school, see what happens")
**Solution:** Generate personalized 8-week coaching plan for each teacher
- Based on baseline assessment data + classroom observation patterns
- Weekly micro-goals (focus on 1 practice at a time)
- Coach tracks progress across visits

**Data track:** Plan completion rate, teacher improvement velocity, coach confidence
**Expected retention lift:** +20%+ (structured coaching >> ad-hoc coaching)
**Blockers:** Needs curriculum mapping + Neo improvement detection

### Offline Sync for All Forms (2 weeks)
**Problem:** Any form submission can fail if connectivity drops
**Solution:** Wrap all form submissions in local queue + auto-sync
- Applies to visit scheduling, observation edits, any future forms
- One-time infrastructure, then reusable

**Data track:** Form failure rate pre/post, recovery rate
**Expected resilience improvement:** 99.5% form delivery (was 90%)

---

## Metrics & Tracking Strategy

### Dashboard (Build in Q3)

#### Engagement Metrics (Weekly)
| Metric | Target | Current | Driver |
|--------|--------|---------|--------|
| **Visits/coach/month** | 4+ | 2.5 | Scheduling ease, time available |
| **Debrief recordings/visit** | 90%+ | 40% | Offline audio feature (2026-05-13) |
| **Time-to-submit** | < 24 hrs | 3+ days | Friction in observation form |
| **30-day retention** | 70% | 55% | Dashboard + offline features |
| **Monthly active coaches** | 85%+ signup | 60% | Onboarding experience |

#### Data Quality Metrics (Daily)
| Metric | Target | Current | Alert If |
|--------|--------|---------|----------|
| **Audio loss rate** | < 5% | 60% | > 10% (offline feature not working) |
| **Neo analysis lag** | < 10 min | 30-60 min | > 20 min (backend issue) |
| **Auto-sync success rate** | 99%+ | N/A | < 98% (upload failures) |
| **Form submission success** | 99%+ | 88% | < 95% (infrastructure issue) |

#### Business Metrics (Monthly)
| Metric | Target | Current | Owner |
|--------|--------|---------|-------|
| **Coach churn rate** | < 8% | 12% | Product |
| **Time-to-certificate** | < 14 days | 21 days | Onboarding |
| **Net retention** | 70% @ 30-day | 55% | Platform |
| **Teacher improvement (coaches who see it)** | 75%+ | N/A | Dashboard feature |

### Data Tracking Infrastructure
- **Frontend:** Segment/Amplitude for user actions (record, submit, view insights, etc.)
- **Backend:** Supabase analytics for API calls, errors, latency
- **Dashboard:** Grafana/Metabase pulling from both sources
- **Alerts:** Slack notifications if audio loss rate > 10%, form success < 95%

---

## Why This Roadmap?

### Q2 Problem Statement
- Coaches sign up but many don't finish modules (onboarding friction)
- Coaches who complete modules are strong users
- But 55% churn at 30 days: why?
  - **Root cause 1:** Audio lost in field → no Neo insights → feels useless
  - **Root cause 2:** Coaches don't see their coaching impact → low motivation
  - **Root cause 3:** Offline forms fail → lost observations → frustration

### Q3 Solution (3 Initiatives)
1. **Offline audio queue** (May 13) — fixes lost recordings
2. **Engagement dashboard** (June) — coaches see their impact
3. **Teacher improvement tracking** (June) — coaches measure ROI

**Expected result:** 30-day retention 55% → 70% (15-point lift)

### Q4 Outcome
- Engagement dashboard shows coaches are coaching, not just visiting
- Coaching plans make coaching proactive, not reactive
- Retention stabilizes at 70%+
- Ready to expand to other regions (Rawalpindi, etc.)

---

## Known Constraints & Assumptions

### Technical Constraints
- **Mobile:** iOS Safari + Android Chrome support required (geo-diverse coaches)
- **Connectivity:** Must work with 3G or worse (Islamabad sub-regions often < 2 Mbps)
- **Storage:** Audio persists locally + cloud (50MB+ per coach possible)
- **Load:** Neo edge function must handle 100+ concurrent upload attempts (spike on connectivity restore)

### Business Constraints
- **Localization:** English + Urdu support (Q4)
- **Manager Visibility:** Need to build manager dashboard separately (coaches-only for now)
- **Privacy:** Audio recordings are PII; must handle deletion + retention policies (Q4)
- **Cost:** Supabase storage ~$0.04/coach/month; audio processing TBD with Neo team

### Assumptions
- **Assumption 1:** Coaches with offline-resilient platform will complete more visits (validate Q3)
- **Assumption 2:** Seeing coaching impact (improved teachers) will drive 20% retention lift (validate Q3)
- **Assumption 3:** 70% of coaches have < 70% connectivity during field work (seeding data validates)

---

## Success Criteria (Q3 End)

**GO/NO-GO Decision Point: 2026-06-30**

### Must-Have (Deploy to Production)
- [ ] Audio loss rate < 5% (was 60%)
- [ ] Debrief recording rate 85%+ (was 40%)
- [ ] 30-day retention 65%+ (was 55%)
- [ ] Zero data loss in offline queue after 5+ hours offline

### Nice-to-Have (If we hit must-haves early)
- [ ] Teacher improvement tracking MVP (compare obs 1 vs 2)
- [ ] Localization to Urdu (UI only, not content)

### No-Go Triggers (Pause & Investigate)
- [ ] Audio loss rate still > 20%
- [ ] 30-day retention drops below 50%
- [ ] Auto-sync success rate < 95%

If any no-go triggers fire, hold production release and debug.

---

## Competitive Positioning

| Competitor | Strength | Our Advantage |
|-----------|----------|---------------|
| **Google Classroom** | Widely adopted | Purpose-built for coaching (not generic LMS) |
| **CoachMark (hypothetical)** | Structured coaching plans | Works offline, AI insights at point of feedback |
| **Manual observation (current state)** | Simple | We measure impact, coaches see teacher improve |

**Differentiation:** Offline + Neo AI coaching = coaches can work in field + get real-time insights = higher perceived value = higher retention

---

## What Success Looks Like (6 Months)

**Coach perspective:**
- "I visit 4+ teachers per month, debrief recording works reliably, Neo tells me what to focus on next"
- "I can see I'm improving teachers — observation scores went from 60 → 78 on repeat visits"
- "I trust the platform to save my work, even in bad connectivity zones"

**Manager perspective:**
- "My coaches are completing 2.5x more visits than last year"
- "I can see coaching impact (teachers improving) from the dashboard"
- "Coach retention improved from 55% to 70%, retention lift = +8 coaches retained"

**Business perspective:**
- 30-day retention: 55% → 70% (sustainable growth)
- Sub-region coaches (low connectivity) retain at 80%+ (offline features working)
- Platform generates valid coaching data (200+ observations/month, 80% with debrief)
- Ready to expand: other regions, manager dashboard, teacher mobile app

---

**Owner:** Coaching Platform Team | **Review Cadence:** Bi-weekly | **Next Review:** 2026-05-27
