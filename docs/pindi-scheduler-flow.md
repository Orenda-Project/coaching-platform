# Pindi Scheduler — Coach User Flow

> **Region:** Rawalpindi | **Updated:** June 2026 | **Branch:** feature/pindi-scheduler-standards-alignment

---

## 1. Opening the App

The coach opens the app and lands on the Observation Scheduler. Their account is linked to a **Rawalpindi markaz** (cluster) — the scheduler reads the `rawalpindi_cluster` field on their profile. If they also cover an ICT sub-region or a Punjab cluster, a region toggle appears in the page header so they can switch between schedulers.

If `rawalpindi_cluster` is not set on their profile, the Smart Plan tab shows a message:
> *"Cluster not assigned — contact your administrator."*

### Offline Behaviour

The Pindi scheduler has a **24-hour cache**. On load, if cached teacher data exists it is shown immediately while a background network refresh runs. The top-right header shows either:
- A **Synced HH:MM** timestamp — data is fresh from the last successful sync
- A **WifiOff · Offline** indicator — the background refresh failed but cached data is being shown

If the very first load fails with no cache at all, an error card appears with a **Retry** button. Unlike ICT, there is no 10-second timeout message — the error shows as soon as the fetch fails.

---

## 2. The Smart Plan Tab

This is the default tab when the app opens. The header shows the cluster name, total teacher count, and how many teachers need an urgent visit. A **Refresh** button in the top-right lets the coach manually pull the latest data at any time.

### Visit Next Card

A prominently styled card surfaces **the single highest-priority unvisited teacher** in the cluster. The app picks the next teacher in this order:

1. Critical (below 60%) — first unvisited teacher
2. Needs Follow-up (60–74%) — if no critical teachers remain
3. On Track (75%+) — if all critical and watch teachers have been visited

The card shows the teacher's name, school, score bubble (colour-coded by tier), and a tier badge. One tap on **Schedule →** opens the scheduling form directly.

When all teachers in the cluster have been visited this cycle, the card changes to a green confirmation message prompting the coach to start a new cycle.

### Stat Cards

Three summary cards appear below the Visit Next card:

| Card | What it shows |
|---|---|
| **Total Teachers** | Full count of teachers in the cluster |
| **This Week** | Visits completed in the past 7 days vs. the weekly target of 3 (e.g. 2/3). Colour-coded: green = target met, amber = in progress, red = none yet |
| **Needs Urgent** | Count of teachers currently below 60% |

### Visit Progress Bar

A progress bar tracks overall cycle progress — *X / Y visited* — with the cycle start date shown on the left. A **Start New Cycle** link sits at the right edge. Tapping it opens a confirmation modal that shows the current cycle summary before resetting.

When a new cycle starts, the previous cycle's data (visited count, total count, start and end dates) is archived. The app keeps up to 10 past cycles.

### School Coverage (Collapsible)

A collapsible section below the progress bar shows visit coverage broken down by school. Schools are sorted from lowest to highest coverage:

- 🔴 **Urgent** — fewer than 60% of teachers at that school visited this cycle
- 🟡 **Partial** — 60–84% visited
- 🟢 **On Track** — 85% or more visited

Each row shows the school name and a *X/Y teachers visited* count.

### Teacher List — Tier Sections

The full teacher list is divided into three labelled sections, each with a coloured dot and teacher count. Only sections that have at least one teacher are shown:

- 🔴 **Needs Urgent Visit** — score below 60%
- 🟡 **Needs Follow-up** — score 60–74%
- 🟢 **On Track** — score 75% and above

---

## 3. Teacher Cards

Each teacher appears as a card within their tier section. Cards are designed **context-first**: who the teacher is and how urgent the visit is before showing scores.

### Card Layout (Always Visible)

**Top section:**
- Teacher name — with a green ✓ **Visited** badge if visited in the current cycle
- School name (with map-pin icon)
- Subject · Grade (with book icon) — only shown if either field has data
- **Urgency line** — based on days since the last HOTS observation:
  - *Never observed — visit needed* (red, bold) — no observation on record
  - *Overdue · 28d since last visit* (red, bold) — more than 21 days since last observation
  - *Due soon · 17d since last visit* (amber) — 14–21 days since last observation
  - *Seen 5d ago* (green) — observed within the last 14 days

> **Note:** The 21-day cadence is Taleemabad standard — each teacher should receive a coaching visit at least once every 3 weeks.

**Score verdict section:**
- A **tier badge** combining the tier label and percentage — e.g. *Needs Visit · 47%*. The percentage is only shown if the teacher has at least one observation recorded; unobserved teachers show the tier label only.
- A **stagnation badge** (*X obs · No improvement*) — shown if the teacher has 2 or more observations but remains below 60%.
- An **escalation badge** (*X obs · Escalate to RO*) — shown if the teacher has 3 or more observations and is still below 60%. A **Flag for RO** button appears alongside it.

**Card footer:**
- **View scores / Hide scores** toggle
- **Schedule Visit** button (disabled while a scheduling request is in-flight for this teacher)
- **🚩 Flag for RO** button — only for escalation-eligible teachers who have not been flagged yet

### Flagging for the Regional Office

If a teacher has 3 or more observations and remains below 60%, the coach can tap **Flag for RO**. The flag is saved locally and a toast confirms:
> *"[Name] flagged — raise with Regional Office at next sync."*

The card then shows a 🚩 **Flagged for RO** badge in place of the escalation prompt. Flags persist across sessions.

### Expanded HOTS Score Breakdown

Tapping **View scores** expands the card to show the full HOTS indicator breakdown. Six indicators are shown:

| Indicator | Max Score | Coaching Focus |
|---|---|---|
| Classroom Management | 9 | Environment fosters open discussion; students engage in complex tasks |
| Lesson Planning | 9 | Objectives link to critical thinking; real-world integration |
| Instructional Strategies | 12 | Open-ended questions; problem-solving modeled; scaffolding used |
| Student Engagement | 9 | Multiple perspectives explored; active discussion and debate |
| Assessment & Feedback | 9 | Self/peer-assessment used; feedback is specific and actionable |
| Multi-grade Setup | 3 | Separate tasks for each grade; non-targeted groups stay engaged |

Each indicator shows:
- Raw score out of max (e.g. 4/9)
- A **Low / Medium / High** label — thresholds: 75%+ = High, 60–74% = Medium, below 60% = Low
- A colour-coded bar (green / amber / red matching the label)
- One-line coaching hint in small text below

The card footer shows total score and observation count (e.g. *Total: 32/51 · 3 observations*).

---

## 4. Scheduling a Visit

The coach schedules a visit by tapping **Schedule →** on the Visit Next card, or **Schedule Visit** on any teacher card. Both open the same scheduling modal.

### The Schedule Visit Form

The form asks for:
- Visit date (must be today or in the future — past dates are blocked with an error message)
- Planned date
- Visit type
- Arrival and departure times
- Week number
- Multi-grade toggle

After the coach confirms, the app sends the visit to the server and shows a toast:
> *"Visit scheduled for [Teacher Name]."*

The teacher is immediately marked as visited in the cycle tracker — the ✓ Visited badge appears on their card without a page reload. The app then navigates automatically to the Visits tab.

### Offline Scheduling

**Pindi supports offline scheduling.** If the network request fails and the device is offline, the visit is saved to a local queue and the coach sees:
> *"Saved offline — will sync when you're back online."*

The teacher is still marked as visited locally so cycle progress reflects it immediately. When the device comes back online, the app detects the connection event and syncs queued visits automatically. A toast confirms:
> *"X offline visit(s) synced."*

The teacher list then refreshes with the latest data from the server.

> ⚠️ Queued visits are local only. If the coach clears the app's storage before syncing, queued visits will be lost. Coaches should sync as soon as connectivity is restored.

---

## 5. The Visits Tab

The Visits tab is shared across ICT, Punjab, and Pindi. It shows all observations for whichever region is currently selected in the region toggle. Three sub-tabs: **Scheduled**, **Draft**, and **Completed**.

### 48-Hour Nudge Banner

If any visit is more than 2 days old and still not marked complete, a yellow banner appears at the top of the Scheduled tab reminding the coach to submit within the 48-hour standard.

### Scheduled Visit Cards

Each card shows teacher name, school, subject, grade, visit type, date, and arrival/departure time. If the teacher has been observed before, it also shows a **Pre-Visit Brief** — last visit date, last score, score trend, and the two weakest areas from the previous observation (expandable).

Two primary buttons on every card:
- **Notify** — opens WhatsApp with a pre-written Urdu message for the teacher (date, time, school details)
- **Mark Done** — marks the visit complete in one tap

A secondary menu holds: mark teacher absent, save to draft, open debrief (Feedback), and delete.

### Teacher Absent Flow

If a teacher is absent, the coach selects **Absent** from the secondary menu. A modal shows the teacher's name, date, and school, then gives step-by-step next steps to find 1–3 overdue teachers from the same school or nearby. A **Go to Smart Plan** button navigates there directly.

### Debrief

From the secondary menu the coach opens the post-visit debrief panel to record coaching notes and trigger Neo's AI analysis. Observations cannot be marked complete without a completed debrief.

---

## 6. The Overview Tab

A data view of all coaching activity across the full history — not just today.

- Four stat cards: Total visits, Schools covered, Teachers observed, Completed
- Average HOTS score across all submitted observations, shown with a proficiency label
- Status breakdown — count of visits currently Scheduled, Draft, and Submitted
- All observations table — scrollable list of every observation recorded, showing teacher name, school, subject, grade, score, and status

---

## 7. ICT vs Pindi — Feature Comparison

| Feature | ICT | Pindi |
|---|---|---|
| Data source | FastAPI / Digital Coach backend | Supabase `rawalpindi_teacher_scores` |
| Region identifier | `sub_region` on profile | `rawalpindi_cluster` on profile |
| Offline scheduling | No — requires internet | Yes — queues and auto-syncs |
| Cache duration | 24 hours | 24 hours |
| Visit Next recommendation | No — full ranked list shown | Yes — top card surfaces one teacher |
| Weekly pace tracker | No | Yes — X/3 visits this week |
| School coverage view | No | Yes — collapsible, colour-coded per school |
| HOTS Low/Medium/High labels | No | Yes — per indicator with bar and hint |
| Stagnation / escalation flags | No | Yes — at 2 obs (stagnation) and 3 obs (RO escalation) |
| Flag for Regional Office | No | Yes — one-tap flagging |
| Urgency label (days since last obs) | No | Yes — Never / Overdue / Due soon / Recently seen |
| Multi-grade indicator | No | Yes — Multi-grade Setup in HOTS breakdown (max 3) |
| Observation count displayed | No | Yes — shown in expanded card footer |
| Score shown for unobserved teachers | Shows 0% | Shows tier label only — no % until first observation |
| 48-hour nudge banner | Yes (Visits tab) | Yes (Visits tab) |
| Teacher absent flow | Yes (Visits tab) | Yes (Visits tab) |
| Day End Summary with WhatsApp export | Yes | No |
| Neo debrief | Yes | No |
