# Universal Scheduler for Coaches — Complete Case Study

**Built for:** Coaching Platform MVP  
**Regions:** ICT (operational), Punjab (configured, awaiting data), Rawalpindi/Pindi (configured, awaiting data)  
**Status:** End-to-end operational in ICT. Coaches can schedule visits, track progress, and give optional Neo feedback.

---

## The Problem We Solved

### Before: Manual Chaos
Coaches managed school visits across disconnected systems:
- **Emails** — back-and-forth chains about visit times
- **Spreadsheets** — manually maintained lists of who to visit
- **WhatsApp** — ad-hoc messages about scheduling conflicts
- **Handwritten notes** — scattered dates and times

**Reality of coaching work:**
1. Deciding *when* to visit which teacher took time (no prioritization)
2. Manually tracking which visits were planned vs. actually completed
3. Searching through messages for arrival/departure times
4. Losing track of which observations were in progress vs. done
5. Duplicating effort across 3–4 different tools

**Impact:** Coaches spent 2–3 hours per week on scheduling admin instead of coaching. That's 100+ hours per year per coach that should have been spent with teachers.

---

## Design Philosophy: Scheduler First, Feedback Second

We intentionally built this as a **visit tracking system**, not a feedback collection system.

### Why This Matters
During discovery, coaches told us:
> "I just need to see all my visits organized in one place. Feedback tools are nice, but my real problem is I'm losing track of visits across email chains and spreadsheets."

This was the breakthrough moment. The scheduler **is the product**. Neo feedback is optional and secondary.

### What This Meant for Design
- **Primary use case:** See all scheduled and completed visits at a glance
- **Secondary feature:** Optional Neo audio feedback if coaches want coaching insights
- **No forced workflows:** Coaches choose how they work
- **Simple, not comprehensive:** Show only what matters for scheduling (teacher, date, time)
- **Flexible completion:** Coaches can complete a visit without feedback

---

## What Coaches Can Now Do

### 1. Smart Plan Tab
A prioritized list of teachers ranked by coaching need.
- Teachers sorted by who needs the most support
- One-click to schedule a visit with any teacher
- Shows progress badges (how many visits already done)
- Clear, focused list — no noise

### 2. Schedule a Visit in 30 Seconds
No complex forms. Just five fields:
- **Visit Type** — FICO, Head-Co Observation, M&H, General Visit, RM Visit
- **Planned Date** — when the coach is planning to go
- **Visit Date** — the actual school day of the visit
- **Arrival Time** — what time they'll arrive (09:00 format)
- **Departure Time** — what time they'll leave (14:00 format)
- **Week** (optional) — for the coach's own notes

Done. Visit created and tracked.

### 3. Visits Dashboard — The Central Hub
All visits in one organized place with three tabs:

**Scheduled Tab**
- Every upcoming visit the coach needs to do
- Clean summary: teacher name, school, subject/grade, visit type, planned date, actual date, arrival/departure times
- Quick answer: "What are my next 5 visits?"

**Draft Tab**
- Visits saved as draft (for planning but not committing yet)
- No lost work — coaches can come back and edit anytime
- Prevents "I forgot I was planning to visit this teacher"

**Completed Tab**
- All finished visits with dates
- If coach recorded Neo feedback: shows the coaching quality score & grade
- Historical record of coaching activity

### 4. Four Separate Action Buttons
On every visit card, coaches have:

| Button | Purpose | Why Separate |
|--------|---------|---|
| **Feedback (🎤)** | Record verbal coaching feedback via Neo AI | Coach can give feedback if they want insights; not mandatory |
| **Draft** | Save without completing | Plans change; coaches need flexibility |
| **Complete** | Mark done. No feedback required. | Coach visited, observed, done. Simple. |
| **Delete** | Remove visit | Plans change. Coach needs an escape hatch. |

**Critical design decision:** We made these separate buttons because coaches said:
> "I don't always want to record feedback. Sometimes I just need to track that I visited and moved on."

So **coaches control the process**. Feedback is optional, not the end of the workflow.

### 5. Optional Neo Debrief
A small mic icon appears on each visit card. Coaches can click it to:
- Record verbal feedback about their coaching
- Neo analyzes the audio
- Get instant feedback on coaching communication quality
- See a score and grade

The mic icon is deliberately **small and positioned as secondary** because:
- Not every coach wants to record feedback
- Not every visit needs analysis
- Coaches should choose, not be forced
- The real value is in the scheduler itself

---

## How Coaches Actually Use It

### The Flow
1. **Coach opens Smart Plan tab** → sees teachers ranked by who needs support most
2. **Clicks "Schedule Visit"** on a teacher → fills in visit details (30 seconds)
3. **Gets taken to Visits dashboard** → sees their new visit in the Scheduled tab
4. **Visit day arrives** → opens the Visits dashboard to see their plan
5. **At or after the visit** → can give feedback (optional mic button) or just mark complete
6. **All visits tracked** → no manual spreadsheets or searching through emails needed

### Why This Works
- **Unified view:** One place to see all visits (no scattered emails, notes, or messages)
- **No manual work:** Coach stops doing scheduling admin
- **Flexible:** Coach controls when/how to complete visits
- **Optional feedback:** Coach can give feedback if they want, skip if they don't
- **Regional focus:** Coach only sees their region's teachers and visits

---

## Key Design Decisions & Why We Made Them

| Decision | Why |
|----------|---|
| **Three separate tabs (Scheduled / Draft / Completed)** | Coaches need clear visibility: "What's coming up?" / "What am I still planning?" / "What have I already done?" |
| **Small mic icon, not dominant feedback button** | Neo is useful, but optional. Feedback shouldn't be the center of the screen because coaches said the scheduler itself was their problem. |
| **Separate "Save to Draft" button** | Real coaching schedules change. Coaches need to pause and plan without committing. |
| **Simple visit cards (teacher, school, times, dates only)** | Coaches skim in 2 seconds. Everything else is noise. |
| **Four separate buttons instead of one required flow** | Coaches are professionals. Let them decide: feedback, draft, complete, or delete. No forced path. |
| **Region-based filtering** | Each coach sees only their region's visits. Focused, relevant data. |
| **Time display as HH:MM** | Coaches think "I'll arrive at 09:00" — not "09:00:00". Match their mental model. |

---

## Implementation Details & Iterations

### What We Built
**Frontend (React + TypeScript)**
- `SmartScheduleTab.tsx` — Teacher list and scheduling form
- `VisitsDashboardTab.tsx` — Three tabs for visit status tracking
- `ScheduleVisitModal.tsx` — Five-field form for scheduling
- `NeoAnalysis.tsx` — Audio recording and Neo debrief

**Backend (Supabase Edge Functions)**
- `neo-start` function — Handles audio upload, Neo API calls, task management
- Region-based API key routing — Different Neo instances for ICT/Punjab/Pindi

**Database**
- `cot_observations` table extended with visit metadata
- New columns: `week`, `visit_type`, `planned_date`, `arrival_time`, `departure_time`
- RLS (Row-Level Security) ensures coaches only see their own region's visits

### Iterations & Changes Made

**Change 1: Removed Dominant "Start Debrief" Button**
- **What was:** Full-width primary button on every visit card
- **Why it was wrong:** Made feedback look like the core workflow when it's optional
- **What now:** Small ghost icon-only mic button positioned with Delete button
- **Impact:** Coaches now see scheduling as primary, feedback as optional add-on

**Change 2: Added Draft Tab**
- **What was:** Just Scheduled and Completed tabs
- **Why it was needed:** Coaches needed a way to save visits they're planning but not committing to yet
- **What now:** Three-tab interface with Draft in the middle
- **Impact:** No lost work; coaches can pause and come back

**Change 3: Fixed Time Display Format**
- **What was:** Showing "09:00:00" (raw database format)
- **Why it was wrong:** Looks like precision the coach didn't input
- **What now:** Trimmed to "09:00" (HH:MM format)
- **Impact:** Cleaner, matches how coaches think about time

**Change 4: Added Web-to-WAV Audio Conversion**
- **What was:** Browser records in WebM format
- **Why it was needed:** Neo API rejected WebM due to codec issues
- **What now:** Automatic conversion from WebM to WAV before upload
- **Implementation:** `audioBufferToWav()` function detects format, decodes, converts, uploads WAV
- **Impact:** Field recording works without codec errors

**Change 5: Unified Region Priority Logic**
- **What was:** Visits created with one region priority, loaded with another
- **Why it was wrong:** Newly scheduled visits didn't appear in the Scheduled tab
- **What now:** Consistent priority: `coachRegion || coachSubRegion || teacher.sector`
- **Impact:** Visits appear immediately after scheduling

**Change 6: Fixed Button Enable Logic**
- **What was:** Schedule Visit button stayed disabled even with all fields filled
- **Why it was wrong:** Default time values were empty strings
- **What now:** Default times are '09:00' and '14:00'
- **Impact:** Form is immediately usable

---

## Regional Status

### ICT (Islamabad Capital Territory)
✅ **Operational**
- Full feature set working
- Coaches can schedule, track, and complete visits
- Neo feedback available
- Data populating properly

### Punjab
🔧 **Configured, awaiting data**
- Region routing is in place in edge functions
- Neo API key configured
- Database schema supports region filtering
- **Waiting on:** Teacher data for Punjab region to enable coaches to schedule visits

### Rawalpindi/Pindi
🔧 **Configured, awaiting data**
- Region routing is in place in edge functions
- Neo API key configured
- Database schema supports region filtering
- **Waiting on:** Teacher data for Rawalpindi region to enable coaches to schedule visits

**Timeline:** Once teacher data is available for Punjab and Pindi, we can activate those regions without code changes — it's just data loading.

---

## Key Metrics & Success Definition

### What Success Looks Like
- ✅ **Coaches see all visits in one place** (no scattered emails/notes)
- ✅ **No manual spreadsheet work** (coaches stop doing admin)
- ✅ **Flexible completion** (coaches can draft, complete, or give feedback — their choice)
- ✅ **Optional feedback** (coaches only use Neo if they want insights)
- ✅ **Region-based isolation** (coaches only see their region's data)

### How We'll Know It's Working
1. Coaches report less time on scheduling admin
2. Coaches use the Draft tab for planning (indicates planning flexibility is valued)
3. Feedback button is used occasionally, not ignored (indicates it's optional and valued)
4. Completion rates increase (coaches finish visits on schedule)
5. Zero coaching workflows broken (scheduler doesn't interfere with actual coaching)

---

## What We Learned

### Discovery Insights
1. **Scheduling is the core problem, not feedback** — Coaches need to organize, not analyze
2. **Coaches need flexibility, not enforcement** — Let them draft, complete, or skip feedback
3. **Simple is better than comprehensive** — Coaches skim visit cards in 2 seconds; extra fields are ignored
4. **Region matters** — Coaches must see only their region's teachers and visits

### Technical Insights
1. **WebM audio codec issues are real** — Browser recording works, but codec compatibility requires conversion
2. **Time format matters** — "09:00" vs "09:00:00" changes how coaches perceive data
3. **Region routing belongs in edge functions** — Centralized logic for API key selection
4. **RLS is critical** — Ensures coaches only see their region, even if they have access to the database

### UX Insights
1. **Button visual weight matters** — A full-width primary button makes feedback look mandatory
2. **Labeling is important** — Icons alone aren't enough; coaches need text labels
3. **Draft state is valuable** — Coaches plan before committing; they need a way to save mid-thought
4. **Four buttons > one required flow** — Coaches are adults; let them choose their path

---

## Summary: What Coaches Get

A **single, unified place to manage school visits** that:
- Eliminates emails, spreadsheets, and manual notes
- Shows planned, drafted, and completed visits at a glance
- Lets coaches schedule visits in 30 seconds
- Gives coaches full control over completion (feedback optional)
- Provides optional Neo feedback if coaches want coaching insights
- Organizes visits by region so coaches see only what's relevant

**Result:** Coaches spend less time on scheduling admin and more time actually coaching.

---

## Current Status & Next Steps

### ✅ Complete
- Schedule visits
- View planned & completed visits
- Save drafts
- Mark visits complete
- Delete visits
- Neo feedback (audio recording, upload, processing)
- Region-based filtering (ICT operational)
- Web-to-WAV conversion for browser audio

### ⏳ In Progress
- Load Punjab teacher data
- Load Rawalpindi teacher data
- Coach user testing & feedback
- Production deployment

### 🚀 Future Enhancements (post-launch)
- Bulk scheduling (multiple visits at once)
- Visit templates (recurring visit patterns)
- Coaching insights dashboard (aggregate Neo scores by teacher)
- Mobile app (native iOS/Android)
- Offline mode (coaches in areas with poor connectivity)
