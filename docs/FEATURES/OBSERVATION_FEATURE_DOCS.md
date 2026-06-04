# Observation & Coaching Analysis — Technical Documentation

**Last updated:** May 2026
**Stack:** React 18 + TypeScript · Supabase (PostgreSQL, Auth, Edge Functions, Realtime) · AWS S3
**Route:** `/observation-scheduler`

---

## Table of Contents

1. [Feature Overview](#1-feature-overview)
2. [Database Schema](#2-database-schema)
3. [Observation Frameworks](#3-observation-frameworks)
4. [Coach Journey — End to End](#4-coach-journey--end-to-end)
5. [Frontend Components](#5-frontend-components)
6. [Utility Libraries](#6-utility-libraries)
7. [Edge Functions](#7-edge-functions)
8. [Digital Coach (DC) Integration](#8-digital-coach-dc-integration)
9. [Neo Integration](#9-neo-integration)
10. [Configuration & Secrets](#10-configuration--secrets)
11. [Deployment Checklist](#11-deployment-checklist)

---

## 1. Feature Overview

The Observation Scheduler allows coaches to:

1. **Schedule** a classroom observation (teacher, school, subject, grade, date)
2. **Start** the observation — moves it to Draft
3. **Record or upload** the classroom session audio — Digital Coach (DC) analyses it automatically
4. **Receive** DC's auto-scored FICO rubric + observation notes
5. **Record or upload** their post-observation debrief conversation with the teacher — Neo evaluates coaching communication quality
6. **Submit** the completed observation

### Design Principles

- Coaches only record audio. All scoring is done by DC. No manual rubric entry required.
- DC handles HOTS and FICO observations equally — there is no "ICT only" guard.
- Neo evaluates the debrief after DC completes.
- Framework (HOTS vs FICO) is auto-selected from the coach's region at scheduling time and cannot be changed.

---

## 2. Database Schema

### Migrations

| Migration File | Purpose |
|---|---|
| `20260425000001_observation_feature.sql` | Initial `cot_observations` table + HOTS structure |
| `20260425000002_add_fico_framework.sql` | `framework` + `fico_rubric` columns |
| `20260426000001_add_dc_analysis.sql` | DC columns on `cot_observations` + `dc_analyses` table + Realtime |
| `20260504000001_add_delete_policy.sql` | RLS DELETE policy for coaches |
| `20260504000002_add_neo_integration.sql` | Neo columns on `cot_observations` |

---

### `cot_observations`

One row per observation. All coach-facing data lives here.

| Column | Type | Notes |
|---|---|---|
| `id` | UUID | Primary key |
| `observer_id` | UUID | FK → `auth.users` (the coach) |
| `school_name` | TEXT | |
| `teacher_name` | TEXT | |
| `region` | TEXT | Determines HOTS vs FICO |
| `subject` | TEXT | |
| `grade` | TEXT | |
| `topic` | TEXT | Optional lesson topic — passed to DC as context |
| `date` | TIMESTAMPTZ | Scheduled visit datetime |
| `framework` | TEXT | `'HOTS'` or `'FICO'` |
| `total_score` | INTEGER | DC-calculated. HOTS: 0–80; FICO: 0–100 (%) |
| `proficiency_level` | TEXT | DC-calculated. Below Basic / Basic / Proficient / Advanced |
| `hots_rubric` | JSONB | HOTS 6-dimension scores |
| `fico_rubric` | JSONB | FICO sections B/C/D/E — DC auto-populates B/C/D |
| `hots_notes` | TEXT | DC section feedback (auto-populated) |
| `notes_for_teacher` | TEXT | Coach's manual feedback to teacher |
| `status` | TEXT | `Scheduled` → `Draft` → `Submitted` → `Approved` |
| `submitted_at` | TIMESTAMPTZ | |
| `approved_at` | TIMESTAMPTZ | |
| `dc_task_id` | TEXT | DC's task identifier |
| `dc_status` | TEXT | `processing` / `completed` / `failed` |
| `dc_requested_at` | TIMESTAMPTZ | |
| `dc_completed_at` | TIMESTAMPTZ | |
| `dc_results` | JSONB | Full raw DC response |
| `dc_error` | TEXT | |
| `dc_audio_s3_key` | TEXT | S3 object key for classroom audio |
| `neo_status` | TEXT | `processing` / `completed` / `failed` |
| `neo_task_id` | TEXT | Neo's task identifier |
| `neo_requested_at` | TIMESTAMPTZ | |
| `neo_completed_at` | TIMESTAMPTZ | |
| `neo_results` | JSONB | Full Neo analysis response |
| `neo_error` | TEXT | |
| `created_at` | TIMESTAMPTZ | |
| `updated_at` | TIMESTAMPTZ | |

**RLS:** Coaches can SELECT / INSERT / UPDATE / DELETE only their own rows (`auth.uid() = observer_id`). Edge functions use the service role key to bypass RLS.

---

### `dc_analyses`

Progress-tracking table for DC processing. Supabase Realtime is enabled on this table — the frontend subscribes to `UPDATE` events per observation to show a live progress bar.

| Column | Type | Notes |
|---|---|---|
| `id` | UUID | Primary key |
| `observation_id` | UUID | FK → `cot_observations.id` |
| `task_id` | TEXT | DC's task_id (UNIQUE) |
| `status` | TEXT | `processing` / `completed` / `failed` |
| `progress` | INTEGER | 0–100 |
| `current_step` | TEXT | DC's current step description |
| `results` | JSONB | Full DC results when completed |
| `error` | TEXT | |
| `created_at` | TIMESTAMPTZ | |
| `updated_at` | TIMESTAMPTZ | |

---

## 3. Observation Frameworks

### Region → Framework Mapping

| Region contains | Framework |
|---|---|
| `ict` or `islamabad` | FICO |
| anything else | HOTS |

Utility: `isRegionFico(region)` in `src/lib/fico-utils.ts`

---

### HOTS Framework

6 dimensions, each scored 0–10 (Assessment & Feedback: 0–20). Total: **0–80**.

| Score | Level |
|---|---|
| 0–40 | Below Basic |
| 41–60 | Basic |
| 61–75 | Proficient |
| 76–80 | Advanced |

---

### FICO Framework

Used in ICT / Islamabad. Score = earned / max × 100%.

**Section B — Structural & Pedagogical** (always scored):
SI4, SI5, SI6, PIC6, PIC7

**Section C — Subject Specific** (auto-filtered):
- Math Concrete: M3C, M4C
- Math Pictorial/Abstract: M3PA, M4PA
- Science: S3, S4
- Literacy/English: L4

**Section D** — Evidence markers (SE1–SE6), observed but not scored.

**Section E** — 5 students × 3 boolean questions. Coach fills manually.

| Score | Level |
|---|---|
| ≥ 85% | Advanced |
| 70–84% | Proficient |
| 50–69% | Basic |
| < 50% | Below Basic |

DC auto-populates Sections B, C, D from audio analysis. Section E is left blank for the coach.

---

## 4. Coach Journey — End to End

```
1. Schedule
   ScheduleDialog → region auto-detected → framework set → cot_observations row inserted
   status = 'Scheduled'

2. Start
   Coach taps "Start" on a Scheduled card
   → status = 'Draft'
   → Coach is directed to Draft Observations tab

3. DC Analysis (classroom recording)
   Coach opens draft card → sees DCAnalysis component
   → Taps "Record" or "Upload Audio"
   → Audio blob assembled
   → dc-presign edge function → S3 presigned PUT URL
   → Browser uploads audio directly to S3
   → dc-start edge function → DC API called with presigned GET URL
   → DC analyses async (minutes) → POSTs progress to dc-callback
   → Realtime updates progress bar in UI
   → On completion: dc-callback writes fico_rubric, total_score, hots_notes to cot_observations
   → UI refreshes: dc_status = 'completed'

4. Neo Analysis (debrief recording)
   After DC completes, NeoAnalysis component appears
   → Coach taps "Record" or "Upload Audio" for debrief conversation
   → Audio uploaded to Neo via neo-start edge function (Neo stores audio itself)
   → neo-start polls neo-status every 8s
   → On completion: neo_results written to cot_observations

5. Submit
   Coach taps "Submit Observation"
   → Validation: dc_status must be 'completed'
   → status = 'Submitted'
```

---

## 5. Frontend Components

All in `src/components/observation/`.

### `ScheduleDialog.tsx`
Creates a new observation. Reads `region` from auth profile → calls `isRegionFico(region)` to auto-set `framework`. Inserts a `Scheduled` row. Shows a framework badge in the dialog.

### `CoachingHubTab.tsx`
Lists `Scheduled` observations. Actions per card: **Start** (→ Draft) and **Delete** (two-click confirm). Has a "Schedule New Visit" button that opens ScheduleDialog.

### `DraftObservationsTab.tsx`
Lists `Draft` observations. Each card is collapsible and shows:

1. **DCAnalysis** — always shown
2. **NeoAnalysis** — shown only when `dc_status === 'completed'`
3. **Submit button** — enabled only when `dc_status === 'completed'`
4. **Delete** — two-click confirm

Local state (`localOverrides`) keeps score changes in memory so the UI reflects updates without a full refetch.

### `ObservationsOverviewTab.tsx`
Read-only dashboard showing stats (total visits, schools covered, teachers observed, completed count), avg HOTS score card, status breakdown, and a full chronological list of all observations.

### `DCAnalysis.tsx`
State machine: `idle → recording → uploading → dispatching → processing → completed / failed`

- **Idle:** Record button + Upload Audio button (file picker)
- **Recording:** Live waveform animation + elapsed timer + Stop button
- **Uploading:** Progress bar (calls dc-presign → S3 PUT)
- **Dispatching:** Spinner (calls dc-start)
- **Processing:** Realtime + polling fallback (8s interval). Shows DC's progress % and current step.
- **Completed:** Collapsible sections showing per-indicator score badges and DC feedback text.
- **Failed:** Error message + Retry button.

On mount: if `observation.dc_status === 'processing'`, skips to processing phase immediately.

### `NeoAnalysis.tsx`
State machine: `idle → recording → uploading → processing → completed / failed`

- **Idle:** Record + Upload Audio buttons
- **Recording:** Timer + Stop button
- **Uploading:** Calls `neo-start` edge function directly with FormData
- **Processing:** Polls `neo-status` every 8s (max ~120s)
- **Completed:** Overall score, grade badge (A–F), 5 section scores (A–E), observer feedback
- **Failed:** Error message + Retry button

On mount: syncs phase from `observation.neo_status`.

---

## 6. Utility Libraries

### `src/lib/fico-utils.ts`

| Function | Description |
|---|---|
| `isRegionFico(region)` | True if region contains 'ict' or 'islamabad' |
| `calculateFicoScore(rubric, subject)` | Returns earned/max/percentage from sections B+C |
| `getFicoProficiency(percentage)` | Returns level, color, bgColor, borderColor |
| `isFicoSectionBComplete(rubric)` | True when all 5 Section B indicators scored |
| `getSubjectCategory(subject)` | Maps subject string to 'math'/'science'/'literacy'/'other' |

### `src/lib/dc-utils.ts`

| Function | Description |
|---|---|
| `subjectToShortcode(subject)` | 'Mathematics' → 'Math', 'English' → 'Eng', etc. |
| `scoreBadgeClass(score)` | Tailwind classes for yes/partial/no/N/A/UNABLE_TO_DETECT |
| `scoreLabel(score)` | Human-readable label |
| `dcResultsSections(results)` | Filters DcResults → array of `{key, label, section}` |

### `src/lib/observation-utils.ts`

| Function | Description |
|---|---|
| `getProficiencyLevel(score)` | HOTS 0–80 → `{level, color, bgColor, borderColor}` |
| `formatObservationDate(date)` | Formats date string for display |
| `formatObservationTime(date)` | Formats time string for display |

---

## 7. Edge Functions

All in `supabase/functions/`. Run on Deno. Shared CORS headers in `supabase/functions/_shared/cors.ts`.

### `dc-presign`
**Auth:** User JWT required
**Purpose:** Generate S3 presigned PUT + GET URLs for classroom audio

Flow: verifies JWT → verifies observation ownership → reads AWS secrets → returns PUT URL (30 min expiry) + GET URL (2 hr expiry) + S3 key.

S3 key format: `dc-audio/{observation_id}/{timestamp}.{ext}`

---

### `dc-start`
**Auth:** User JWT required
**Purpose:** Submit audio URL to DC API and record the task

Flow: verifies JWT + ownership → POSTs FormData to `{DC_BASE_URL}/api/external/process-audio-from-s3` → receives `task_id` → inserts `dc_analyses` row → updates `cot_observations` with `dc_status='processing'`.

DC call timeout: 30 seconds.

---

### `dc-callback`
**Auth:** None — DC calls this directly
**Purpose:** Receive DC progress updates and final results

Flow: looks up `dc_analyses` by `task_id` → updates progress. On `completed`: maps DC scores → FICO rubric, calculates total_score + proficiency_level, builds hots_notes from section feedback, writes all to `cot_observations` in one UPDATE. Always returns HTTP 200 to prevent DC retries.

**Inline helpers (no shared module — Deno only):**
- `mapDcScore(s)` — `yes/partial/no` → same; `N/A` → `na`; `UNABLE_TO_DETECT` → undefined
- `mapDcResultsToFicoRubric(results)` — builds `{section_b, section_c, section_d, section_e}` JSONB
- `scoreFromRubric(fico_rubric)` — counts yes=1, partial=0.5, no=0 across B+C → percentage + level
- `buildDebriefNotes(results)` — concatenates section B/C/D feedback with labels

---

### `neo-start`
**Auth:** User JWT required
**Purpose:** Upload debrief audio to Neo and start processing

Flow:
1. Receives FormData with `file` (audio) + `observation_id`
2. Verifies JWT + observation ownership
3. Determines region API key (`NEO_API_KEY_ICT` / `NEO_API_KEY_PUNJAB` / `NEO_API_KEY_PINDI`)
4. POSTs audio to `{NEO_BASE_URL}/api/neo/upload-audio` (Header: `X-API-Key`) → gets `s3_url`
5. POSTs to `{NEO_BASE_URL}/api/neo/process-coaching-audio` with `audio_s3_url`, `observer_id`, `region` → gets `task_id`
6. Updates `cot_observations`: `neo_status='processing'`, `neo_task_id`, `neo_requested_at`

---

### `neo-status`
**Auth:** User JWT required
**Purpose:** Poll Neo for task completion and write results

Flow:
1. Receives `{ observation_id }` in JSON body
2. Verifies JWT + ownership → fetches `neo_task_id` + `region` from DB
3. GETs `{NEO_BASE_URL}/api/neo/status/{task_id}` (Header: `X-API-Key`)
4. On `completed`: writes `neo_results`, `neo_status='completed'`, `neo_completed_at` to `cot_observations`
5. On `failed`: writes `neo_status='failed'`, `neo_error`

The frontend calls this every 8 seconds during the processing phase (max ~120s / 15 polls).

---

## 8. Digital Coach (DC) Integration

| Property | Value |
|---|---|
| Base URL | Set as `DC_BASE_URL` Supabase secret |
| Endpoint | `POST /api/external/process-audio-from-s3` |
| Pattern | Async — returns `task_id` immediately, POSTs results to `callback_url` |

**Audio storage:** AWS S3 (`classroom-observations-audios`, region `ap-southeast-1`). The browser uploads directly to S3 via a presigned PUT URL — audio never passes through an edge function.

**S3 CORS:** Must be configured to allow `PUT` and `GET` from the app's domain.

**DC Score → FICO Rubric Mapping:**

| DC Value | FICO Value |
|---|---|
| `yes` | `yes` |
| `partial` | `partial` |
| `no` | `no` |
| `N/A` | `na` (excluded from denominator) |
| `UNABLE_TO_DETECT` | omitted (shown as unscored) |

---

## 9. Neo Integration

| Property | Value |
|---|---|
| Base URL | `https://digital-coach-production-5dff.up.railway.app` |
| Upload endpoint | `POST /api/neo/upload-audio` |
| Process endpoint | `POST /api/neo/process-coaching-audio` |
| Status endpoint | `GET /api/neo/status/{task_id}` |
| Pattern | Polling — frontend polls every 8s via `neo-status` edge function |

**Audio storage:** Neo manages its own audio storage. No S3 involvement for Neo.

**Region → API Key:**

| Region | Secret |
|---|---|
| ICT / Islamabad | `NEO_API_KEY_ICT` |
| Punjab | `NEO_API_KEY_PUNJAB` |
| Pindi / Rawalpindi | `NEO_API_KEY_PINDI` |

**Neo Results Shape:**
```ts
{
  overall_score: number;
  grade: 'A' | 'B' | 'C' | 'D' | 'F';
  readiness_level: string;
  section_scores: { A: number; B: number; C: number; D: number; E: number };
  observer_feedback?: Record<string, any>;
  conversation_metrics?: Record<string, any>;
}
```

Neo's 5 sections evaluate coaching communication quality (Seesaw / Bridge / Multiplier / Loop / Growth). Results are shown in the NeoAnalysis component after the debrief recording is processed.

---

## 10. Configuration & Secrets

### Frontend `.env`

```
VITE_SUPABASE_URL=https://kddvxrlffafyjvvststh.supabase.co
VITE_SUPABASE_PUBLISHABLE_KEY=<anon public key>
```

Never commit `.env`. Use `.env.local` to override for local development (points to `http://127.0.0.1:54321`).

### Supabase Edge Function Secrets

Set via: `npx supabase secrets set KEY=value`

| Secret | Used By | Description |
|---|---|---|
| `AWS_ACCESS_KEY_ID` | dc-presign | S3 IAM access key |
| `AWS_SECRET_ACCESS_KEY` | dc-presign | S3 IAM secret key |
| `AWS_REGION` | dc-presign | `ap-southeast-1` |
| `S3_BUCKET_NAME` | dc-presign | `classroom-observations-audios` |
| `DC_BASE_URL` | dc-start | DC API base URL |
| `NEO_BASE_URL` | neo-start, neo-status | Neo API base URL |
| `NEO_API_KEY_ICT` | neo-start, neo-status | Neo key for ICT region |
| `NEO_API_KEY_PUNJAB` | neo-start, neo-status | Neo key for Punjab region |
| `NEO_API_KEY_PINDI` | neo-start, neo-status | Neo key for Pindi region |

---

## 11. Deployment Checklist

Before going live, verify each item:

### Database
- [ ] All 5 migrations applied in Supabase SQL Editor (in order)
- [ ] `dc_analyses` table visible in Table Editor
- [ ] `cot_observations` has `neo_status`, `neo_task_id`, `neo_results`, `neo_error`, `neo_requested_at`, `neo_completed_at` columns
- [ ] RLS policies active — coaches can only see/edit their own rows

### S3
- [ ] Bucket `classroom-observations-audios` exists in `ap-southeast-1`
- [ ] CORS configured to allow `PUT` and `GET` from app domains
- [ ] IAM user has `s3:PutObject` + `s3:GetObject` on the bucket

### Edge Functions (deployed)
- [ ] `dc-presign` — `npx supabase functions deploy dc-presign`
- [ ] `dc-start` — `npx supabase functions deploy dc-start`
- [ ] `dc-callback` — `npx supabase functions deploy dc-callback`
- [ ] `neo-start` — `npx supabase functions deploy neo-start`
- [ ] `neo-status` — `npx supabase functions deploy neo-status`

### Secrets (all set in Supabase)
- [ ] `AWS_ACCESS_KEY_ID`
- [ ] `AWS_SECRET_ACCESS_KEY`
- [ ] `AWS_REGION`
- [ ] `S3_BUCKET_NAME`
- [ ] `DC_BASE_URL`
- [ ] `NEO_BASE_URL`
- [ ] `NEO_API_KEY_ICT`
- [ ] `NEO_API_KEY_PUNJAB`
- [ ] `NEO_API_KEY_PINDI`

### App Route
- [ ] `/observation-scheduler` route registered in `src/App.tsx` ✅

### End-to-End Test
- [ ] Schedule an observation → appears in "Scheduled Visits"
- [ ] Start observation → moves to "Draft Observations"
- [ ] Upload a short audio file for DC → progress bar shows → DC completes → results visible
- [ ] Debrief section appears after DC completes
- [ ] Upload debrief audio for Neo → Neo completes → grade + section scores visible
- [ ] Submit observation → status changes to Submitted
- [ ] Delete a Scheduled observation → row removed from DB
- [ ] Delete a Draft observation → row removed from DB
