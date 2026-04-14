# CoachCert Platform — Product Architecture & Implementation Plan

**Version:** 1.0
**Date:** April 2026
**Status:** Design Phase

---

## TABLE OF CONTENTS
1. [Executive Summary](#executive-summary)
2. [Product Design](#product-design)
3. [System Architecture](#system-architecture)
4. [Database Design](#database-design)
5. [API Specifications](#api-specifications)
6. [Implementation Plan](#implementation-plan)
7. [Analytics & Measurement](#analytics--measurement)
8. [A/B Testing Strategy](#ab-testing-strategy)
9. [Migration & Rollout](#migration--rollout)

---

## EXECUTIVE SUMMARY

### Problem Statement
Current CoachCert flow (Slides → Scenario) shows:
- 60–70% of users skip slides to reach scenarios
- Experienced coaches feel over-trained
- Passive content has low completion rates
- Engagement drops at content-heavy units

### Solution
Flip the learning model to **Scenario-First**:
1. **Scenario** — Real-world situation, immediate decision
2. **Reveal** — Feedback + 2–3 slides explaining WHY
3. **Optional Depth** — Expandable "Read more" for full content

### Expected Outcomes
- ↑ 40–50% increase in engagement
- ↓ 30% reduction in drop-off rate
- ↑ 25% faster completion time
- ↑ Higher effectiveness for experienced users (reduced cognitive load)

### New Capabilities
- **Analytics Dashboard** — User engagement, performance, heatmaps
- **Region-wise Tracking** — Interactive maps, drill-downs, comparisons
- **RBAC System** — Super Admin, Regional Admin, Coach roles

---

## PRODUCT DESIGN

### 1. New Learning Flow

#### Phase 1: Scenario First
```
┌─────────────────────────────────────────┐
│  SCENARIO-FIRST EXPERIENCE              │
├─────────────────────────────────────────┤
│                                         │
│  [Unit 2.3 — Building Trust]            │
│                                         │
│  SITUATION:                             │
│  A veteran teacher tells you: "Go       │
│  observe Mr. Kamran and give me a       │
│  report for his annual evaluation."     │
│                                         │
│  Question: How do you respond?          │
│                                         │
│  [A] Agree to observe and report       │
│  [B] Explain your coaching role        │
│  [C] Ask for permission first          │
│  [D] Decline to get involved           │
│                                         │
│  [SUBMIT ANSWER]                        │
│                                         │
└─────────────────────────────────────────┘
```

**Key Principles:**
- No intro slides
- No context-setting videos
- Direct immersion in decision point
- Minimal cognitive load upfront
- 30–45 seconds to first decision

---

#### Phase 2: Reveal & Feedback
```
┌─────────────────────────────────────────┐
│  YOUR ANSWER: [B] Explain your role     │
│                                         │
│  ✅ CORRECT                             │
│                                         │
│  Rationale:                             │
│  This maintains your coaching role,     │
│  sets a professional boundary, and      │
│  protects the coaching relationship.    │
│                                         │
│  [REVEAL VIDEO/SLIDES]                  │
│                                         │
│  Slide 1 (15s):                         │
│  Why Confidentiality Matters            │
│  ├─ Confidentiality = Safe space        │
│  ├─ Broken trust → relationship dies    │
│  └─ Your role is coach, not evaluator   │
│                                         │
│  Slide 2 (20s):                         │
│  The Right Language                     │
│  ├─ "I keep coaching confidential"      │
│  ├─ "I can share school-wide trends"    │
│  └─ "This builds trust over time"       │
│                                         │
│  Slide 3 (10s):                         │
│  Key Principle: Integrity               │
│  └─ Acting on principles even under     │
│     pressure = professional growth      │
│                                         │
│  [CONTINUE]        [← READ MORE]        │
│                                         │
└─────────────────────────────────────────┘
```

**Characteristics:**
- Immediate binary feedback (correct/incorrect)
- 2–3 focused slides explaining WHY
- Video or animated slides (no walls of text)
- Total time: 45–90 seconds
- "Read more" toggle for full content

---

#### Phase 3: Optional Depth
```
┌─────────────────────────────────────────┐
│  [← READ MORE] (collapsed)              │
│                                         │
│  ┌─────────────────────────────────────┐
│  │ Expand: Full Unit Content            │
│  └─────────────────────────────────────┘
│                                         │
│  EXPANDED VIEW:                         │
│  ────────────────────────────────────   │
│                                         │
│  The 4-Pillar Ethical Framework         │
│  ───────────────────────────────────    │
│  1. TRUST                               │
│     Does this action build trust?       │
│     Red flag: teacher feels judged      │
│                                         │
│  2. CONFIDENTIALITY                     │
│     Am I protecting coaching data?      │
│     Red flag: sharing notes, staffroom  │
│                                         │
│  3. ACCOUNTABILITY                      │
│     Clear about role boundaries?        │
│     Red flag: becoming principal's      │
│     informant                           │
│                                         │
│  4. INTEGRITY                           │
│     Does this align with Partnership    │
│     Principles?                         │
│     Red flag: imposing solutions        │
│                                         │
│  [BACK TO SCENARIO]  [NEXT SCENARIO]    │
│                                         │
└─────────────────────────────────────────┘
```

**Behavior:**
- Hidden by default (compact experience)
- Expandable for users who want depth
- Full contextual content when expanded
- Non-blocking progression

---

### 2. Analytics Dashboard — Design

#### Dashboard Layout

```
┌─────────────────────────────────────────────────────────┐
│  COACHCERT ANALYTICS — SUPER ADMIN VIEW                 │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  [Filter] Region: [ All ▼ ]  Period: [ Last 7 Days ▼ ] │
│                                                         │
│  ┌─────────────┬─────────────┬─────────────────────────┤
│  │ Total Users │ Active Users│ Avg. Completion Rate    │
│  │    2,450    │    1,850    │        74%              │
│  │             │             │                         │
│  │ +12% ↑      │ +8% ↑       │ +5% ↑                   │
│  └─────────────┴─────────────┴─────────────────────────┘
│                                                         │
│  ┌───────────────────────┬───────────────────────────┐ │
│  │ ENGAGEMENT METRICS    │ PERFORMANCE METRICS      │ │
│  ├───────────────────────┼───────────────────────────┤ │
│  │                       │                           │ │
│  │ Scenario Completion:  │ Correct Decisions:       │ │
│  │ ████████████░ 85%     │ ███████░ 72%             │ │
│  │                       │                           │ │
│  │ Slide Engagement:     │ Incorrect Decisions:     │ │
│  │ ████░ 42%             │ ░░░░ 28%                 │ │
│  │ (↓ from 68%)          │ (mostly on hard          │ │
│  │                       │ scenarios)               │ │
│  │ Read More Clicks:     │                          │ │
│  │ ██░ 28%               │ Time per Scenario:       │ │
│  │ (experienced users)   │ ⌛ 2m 30s (avg)          │ │
│  │                       │                          │ │
│  └───────────────────────┴───────────────────────────┘ │
│                                                         │
│  ┌─────────────────────────────────────────────────────┤
│  │ HEATMAP: Scenario Difficulty (% Incorrect)         │ │
│  ├─────────────────────────────────────────────────────┤ │
│  │                                                     │ │
│  │  Unit 1.0  Unit 1.1  Unit 1.2  Unit 1.3  Unit 1.4 │ │
│  │  ██░       ███░      ██░       ████░      ██░      │ │
│  │  18%       34%       22%       40%        12%      │ │
│  │  (Easy)    (HARD)    (Med)     (HARD)     (Easy)   │ │
│  │                                                     │ │
│  │  [Show Unit 1.1 Scenarios] [Show Unit 1.3 Data]   │ │
│  │                                                     │ │
│  └─────────────────────────────────────────────────────┘ │
│                                                         │
│  ┌─────────────────────────────────────────────────────┤
│  │ REGIONAL PERFORMANCE MAP                           │ │
│  ├─────────────────────────────────────────────────────┤ │
│  │                                                     │ │
│  │  [Interactive Map of Pakistan]                     │ │
│  │                                                     │ │
│  │  Islamabad: 85% completion                         │ │
│  │  (Click to drill down)                             │ │
│  │                                                     │ │
│  │  Punjab: 72% completion                            │ │
│  │  (1,200 users, avg time 3m 20s)                    │ │
│  │                                                     │ │
│  │  Sindh: 68% completion                             │ │
│  │  (850 users, 22% drop-off rate)                    │ │
│  │                                                     │ │
│  └─────────────────────────────────────────────────────┘ │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

#### Dashboard Sections

**Section 1: KPI Summary**
- Total users (with growth %)
- Active users (last 7/30 days)
- Completion rate (avg across platform)
- Average time per unit
- Correct decision rate

**Section 2: Engagement Metrics**
- Scenario completion rate (%)
- Slides viewed after decision
- "Read more" expansion rate (%)
- Drop-off points (where users exit)
- Repeat attempts per scenario

**Section 3: Performance Metrics**
- Correct vs incorrect decision split
- Per-scenario performance (which scenarios are hardest)
- Per-user performance (breakdown by role/region)
- Learning curve (performance over time)

**Section 4: Heatmap/Trends**
- Color-coded grid: Units × Scenarios
  - Green = high success rate (>80%)
  - Yellow = medium (60–80%)
  - Red = low (<60%)
- Trend lines: Engagement over time
- Cohort analysis (new users vs experienced)

**Section 5: Regional Performance Map**
- Interactive clickable map
- Color intensity = performance level
- Drill-down: Region → Users → Units → Scenarios
- Comparison tool: Region A vs Region B

**Section 6: Drop-off Analysis**
- Funnel view: Scenario → Decision → Feedback → Depth
- Where users abandon content
- Identify problematic scenarios

---

### 3. UI/UX Components

#### Scenario Card (Scenario-First)
```jsx
<ScenarioCard>
  <Header>
    <Badge>Unit 2.3</Badge>
    <Title>Building Trust</Title>
  </Header>

  <Body>
    <Situation>A veteran teacher says...</Situation>
    <Question>How do you respond?</Question>
  </Body>

  <Options>
    <Option A>Agree to observe and report</Option>
    <Option B>Explain your coaching role</Option>
    <Option C>Ask for permission first</Option>
    <Option D>Decline to get involved</Option>
  </Options>

  <SubmitButton>SUBMIT ANSWER</SubmitButton>
</ScenarioCard>
```

#### Feedback + Reveal Card
```jsx
<FeedbackCard verdict="correct">
  <Verdict>
    <Icon>✅</Icon>
    <Title>Correct</Title>
    <Rationale>This maintains your coaching role...</Rationale>
  </Verdict>

  <RevealSlides>
    <Slide duration="15s">Why Confidentiality Matters</Slide>
    <Slide duration="20s">The Right Language</Slide>
    <Slide duration="10s">Key Principle: Integrity</Slide>
  </RevealSlides>

  <ExpandableDepth>
    <Toggle>← Read more</Toggle>
    {expanded && <FullContent>...</FullContent>}
  </ExpandableDepth>

  <Actions>
    <Button>Continue</Button>
    <Button variant="secondary">Back</Button>
  </Actions>
</FeedbackCard>
```

#### Regional Filter Component
```jsx
<RegionalAnalytics>
  <MapContainer>
    <InteractiveMap>
      <Region name="Islamabad" completion={85} onClick={handleDrill} />
      <Region name="Punjab" completion={72} onClick={handleDrill} />
      <Region name="Sindh" completion={68} onClick={handleDrill} />
    </InteractiveMap>
  </MapContainer>

  <DrilldownPanel>
    <Level1>Region</Level1>
    <Level2>Users ({userCount})</Level2>
    <Level3>Units</Level3>
    <Level4>Scenarios</Level4>
  </DrilldownPanel>

  <ComparisonTool>
    <Select>Compare: Region A ▼</Select>
    <Select>vs Region B ▼</Select>
  </ComparisonTool>
</RegionalAnalytics>
```

---

## SYSTEM ARCHITECTURE

### 1. Tech Stack (Recommended)

#### Frontend
- **Framework:** React 18+ (or Vue 3 for team preference)
- **State Management:** Redux Toolkit + RTK Query OR TanStack Query + Zustand
- **UI Component Library:** shadcn/ui or Ant Design (for complex dashboards)
- **Charts/Visualization:** Recharts (lightweight) or ECharts (advanced)
- **Maps:** Leaflet + OpenStreetMap or Mapbox (interactive regions)
- **Build Tool:** Vite
- **Styling:** Tailwind CSS

#### Backend
- **Runtime:** Node.js 18+ (Express.js) OR Python (FastAPI/Django)
  - Recommended: **Node.js + Express** for real-time features
- **API Standard:** REST + WebSockets (for real-time analytics)
- **Database:** PostgreSQL 14+ (relational, scalable)
  - Optional: Redis for caching, session management
- **Authentication:** JWT + OAuth2 (for single sign-on)
- **Deployment:** Docker + Kubernetes (or Railway, Render for simpler scaling)

#### Analytics & Monitoring
- **Event Tracking:** PostHog (self-hosted) or Segment
- **Analytics DB:** ClickHouse (time-series analytics) or just PostgreSQL with materialized views
- **Logging:** ELK Stack (Elasticsearch + Logstash + Kibana) or Datadog
- **Monitoring:** Prometheus + Grafana

---

### 2. System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                       CLIENT LAYER                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────┐  ┌──────────────────┐                    │
│  │ Scenario Flow    │  │ Analytics        │                    │
│  │ (React)          │  │ Dashboard        │                    │
│  │                  │  │ (React)          │                    │
│  │ - ScenarioCard   │  │                  │                    │
│  │ - FeedbackCard   │  │ - KPI Cards      │                    │
│  │ - ReadMore       │  │ - Heatmaps       │                    │
│  │                  │  │ - Regional Maps  │                    │
│  └────────┬─────────┘  └────────┬─────────┘                    │
│           │                     │                              │
│           └──────────┬──────────┘                              │
│                      │ HTTP/WS                                │
│           ┌──────────▼──────────┐                             │
│           │ API Gateway         │                             │
│           │ (Rate limit, Auth)  │                             │
│           └──────────┬──────────┘                             │
│                      │                                        │
└──────────────────────┼────────────────────────────────────────┘
                       │
┌──────────────────────┼────────────────────────────────────────┐
│                  API LAYER (Express.js)                       │
├──────────────────────┼────────────────────────────────────────┤
│                      │                                        │
│  ┌─────────────────────────┐  ┌─────────────────────────────┐│
│  │ REST API Endpoints      │  │ WebSocket Events            ││
│  │                         │  │                             ││
│  │ POST /scenarios         │  │ analytics:update-metrics    ││
│  │ POST /responses/:id     │  │ dashboard:heatmap-change    ││
│  │ GET /analytics/users    │  │ users:region-filter-change  ││
│  │ GET /analytics/regions  │  │                             ││
│  │ POST /roles/assign      │  │ (Real-time dashboard push)  ││
│  │ PUT /users/:id/region   │  │                             ││
│  │ GET /rbac/permissions   │  │ (Metrics updated every 30s) ││
│  │ ...                     │  │                             ││
│  └────────────┬────────────┘  └────────────┬────────────────┘│
│               │                            │                │
│  ┌────────────┴────────────────────────────┴────────────────┐│
│  │            Authentication & Authorization                ││
│  │  (JWT validation, RBAC middleware)                       ││
│  └─────────────────────┬──────────────────────────────────── │
│                        │                                    │
└────────────────────────┼────────────────────────────────────┘
                         │
┌────────────────────────┼────────────────────────────────────┐
│               BUSINESS LOGIC LAYER                          │
├────────────────────────┼────────────────────────────────────┤
│                        │                                   │
│  ┌────────────────────▼─────────────────────────────────┐ │
│  │ Services                                            │ │
│  │ - ScenarioService                                   │ │
│  │ - ResponseService (track user decisions)            │ │
│  │ - AnalyticsService (calculate metrics)              │ │
│  │ - UserService (RBAC, region assignment)             │ │
│  │ - RegionService                                     │ │
│  └────────────────┬────────────────────────────────────┘ │
│                   │                                      │
│  ┌────────────────▼──────────────────────────────────┐   │
│  │ Event Bus (Node Event Emitter or Bull Queue)      │   │
│  │ - Scenario.completed                              │   │
│  │ - Response.recorded                               │   │
│  │ - Metrics.calculated                              │   │
│  │ (Triggers analytics calculations)                 │   │
│  └────────────────┬──────────────────────────────────┘   │
│                   │                                      │
│  ┌────────────────▼──────────────────────────────────┐   │
│  │ Analytics Engine (Background Job)                 │   │
│  │ - Aggregates metrics every 30s                    │   │
│  │ - Calculates heatmaps                             │   │
│  │ - Updates materialized views                      │   │
│  │ - Publishes via WebSocket                         │   │
│  └──────────────────────────────────────────────────┘   │
│                                                         │
└────────────────────────────────────────────────────────┘
                         │
┌────────────────────────┼────────────────────────────────┐
│                 DATA LAYER                             │
├────────────────────────┼────────────────────────────────┤
│                        │                               │
│  ┌────────────────────▼──────────────────────────────┐ │
│  │ Primary Database (PostgreSQL)                    │ │
│  │                                                   │ │
│  │ Tables:                                          │ │
│  │ - users (id, email, role, region_id)            │ │
│  │ - roles (id, name, permissions)                  │ │
│  │ - regions (id, name, coordinates)                │ │
│  │ - scenarios (id, unit_id, situation, options)    │ │
│  │ - responses (id, user_id, scenario_id, choice)   │ │
│  │ - analytics_events (user_id, event, timestamp)   │ │
│  │ - materialized_views (pre-calc metrics)          │ │
│  └────────────────────┬──────────────────────────────┘ │
│                       │                               │
│  ┌────────────────────▼──────────────────────────────┐ │
│  │ Cache Layer (Redis)                              │ │
│  │ - Session tokens                                 │ │
│  │ - User region lookups                            │ │
│  │ - Dashboard metrics (30s TTL)                     │ │
│  │ - Rate limit counters                            │ │
│  └──────────────────────────────────────────────────┘ │
│                                                       │
└───────────────────────────────────────────────────────┘
```

---

### 3. API Architecture Overview

#### Core Endpoints

**Scenario Endpoints**
```
GET    /api/v1/scenarios              → List all scenarios
GET    /api/v1/scenarios/:id          → Get scenario details
GET    /api/v1/units/:unitId/scenarios → Scenarios in a unit
POST   /api/v1/scenarios              → Create scenario (admin)
PUT    /api/v1/scenarios/:id          → Update scenario
DELETE /api/v1/scenarios/:id          → Archive scenario
```

**Response Endpoints**
```
POST   /api/v1/responses              → Submit user decision
GET    /api/v1/responses?userId=X     → Get user's responses
GET    /api/v1/responses/stats        → Aggregate response stats
```

**Analytics Endpoints**
```
GET    /api/v1/analytics/dashboard    → High-level metrics
GET    /api/v1/analytics/scenarios    → Per-scenario stats
GET    /api/v1/analytics/users        → Per-user performance
GET    /api/v1/analytics/regions      → Regional breakdown
GET    /api/v1/analytics/heatmap      → Heatmap data
GET    /api/v1/analytics/funnel       → Drop-off funnel
POST   /api/v1/analytics/export       → Export report (CSV/PDF)
```

**RBAC Endpoints**
```
GET    /api/v1/roles                  → List all roles
POST   /api/v1/roles/:id/assign       → Assign role to user
GET    /api/v1/permissions            → List permissions
PUT    /api/v1/users/:id/permissions  → Update user permissions
```

**Region Endpoints**
```
GET    /api/v1/regions                → List all regions
GET    /api/v1/regions/:id/users      → Users in region
PUT    /api/v1/users/:id/region       → Assign user to region
GET    /api/v1/regions/:id/analytics  → Region-specific metrics
```

**User Management**
```
GET    /api/v1/users                  → List users (with filters)
GET    /api/v1/users/:id              → User profile
PUT    /api/v1/users/:id              → Update user
POST   /api/v1/users/bulk-assign      → Bulk assign users to region/role
```

---

## DATABASE DESIGN

### 1. Entity-Relationship Diagram

```
┌──────────────────┐      ┌─────────────────┐
│    users         │      │    roles        │
├──────────────────┤      ├─────────────────┤
│ id (PK)          │◄─────│ id (PK)         │
│ email (UNIQUE)   │ N:1  │ name            │
│ first_name       │      │ description     │
│ last_name        │      │ created_at      │
│ role_id (FK)     │      └─────────────────┘
│ region_id (FK)   │
│ created_at       │      ┌──────────────────┐
│ updated_at       │      │    regions       │
│ last_login       │      ├──────────────────┤
│ is_active        │◄─────│ id (PK)          │
└──────────────────┘ N:1  │ name             │
        │                 │ code             │
        │                 │ coordinates      │
        │                 │ (lat, lng)       │
        │                 │ parent_id (FK)   │
        │                 │ created_at       │
        │                 └──────────────────┘
        │
        │         ┌──────────────────────┐
        └────────►│   permissions        │
                  ├──────────────────────┤
                  │ id (PK)              │
                  │ role_id (FK)         │
                  │ resource             │
                  │ action               │
                  │ (e.g., role=admin,   │
                  │  resource=analytics, │
                  │  action=view)        │
                  └──────────────────────┘

┌──────────────────┐       ┌──────────────────┐
│    units         │       │    scenarios     │
├──────────────────┤       ├──────────────────┤
│ id (PK)          │───────│ id (PK)          │
│ title            │ 1:N   │ unit_id (FK)     │
│ description      │       │ order_number     │
│ module_id (FK)   │       │ situation        │
│ order_number     │       │ question         │
│ created_at       │       │ correct_choice   │
│ updated_at       │       │ difficulty       │
└──────────────────┘       │ (easy/med/hard)  │
                           │ created_at       │
                           │ is_active        │
                           └──────┬───────────┘
                                  │ 1:N
                           ┌──────▼───────────┐
                           │  scenario_options│
                           ├──────────────────┤
                           │ id (PK)          │
                           │ scenario_id (FK) │
                           │ option_letter    │
                           │ (A, B, C, D)     │
                           │ option_text      │
                           │ is_correct       │
                           │ rationale        │
                           │ principle_tag    │
                           └──────────────────┘

┌──────────────────────┐
│      responses       │
├──────────────────────┤
│ id (PK)              │
│ user_id (FK)         │
│ scenario_id (FK)     │
│ chosen_option        │ ──────┐ Indices:
│ is_correct           │       │ (user_id, created_at)
│ time_spent_seconds   │       │ (scenario_id, created_at)
│ attempt_number       │       │ (user_id, is_correct)
│ created_at           │       │ (created_at) ← for analytics
│ updated_at           │──────┘
└──────────────────────┘

┌──────────────────────────┐
│   analytics_events       │ ← High-volume, append-only
├──────────────────────────┤
│ id (PK)                  │
│ user_id (FK)             │
│ event_type               │
│ (scenario_viewed,        │ Partitioned by date
│  decision_made,          │ for performance
│  read_more_clicked)      │
│ scenario_id (FK)         │
│ metadata (JSON)          │
│ timestamp (INDEXED)      │
│ region_id (Denorm.)      │ ← Denormalized for query speed
└──────────────────────────┘

┌─────────────────────────────┐
│  materialized_views         │ ← Pre-calculated metrics
├─────────────────────────────┤
│ id (PK)                     │
│ metric_name                 │
│ (user_engagement,           │
│  scenario_performance,      │
│  regional_summary)          │
│ time_period                 │
│ (today, last_7_days,       │
│  last_30_days)              │
│ data (JSONB)                │
│ calculated_at               │
│ ttl (refresh every 30s)     │
└─────────────────────────────┘
```

---

### 2. Core Tables (SQL Schema)

```sql
-- Users Table
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  first_name VARCHAR(100),
  last_name VARCHAR(100),
  role_id UUID NOT NULL REFERENCES roles(id),
  region_id UUID REFERENCES regions(id),
  password_hash VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  last_login TIMESTAMP,
  is_active BOOLEAN DEFAULT true,
  INDEX idx_email (email),
  INDEX idx_role_id (role_id),
  INDEX idx_region_id (region_id),
  INDEX idx_is_active (is_active)
);

-- Roles Table (RBAC)
CREATE TABLE roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) UNIQUE NOT NULL,
  description TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_name (name)
);

-- Permissions Table
CREATE TABLE permissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  role_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
  resource VARCHAR(100),  -- 'analytics', 'users', 'scenarios', 'regions'
  action VARCHAR(100),    -- 'view', 'create', 'update', 'delete'
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE (role_id, resource, action),
  INDEX idx_role_id (role_id)
);

-- Regions Table
CREATE TABLE regions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) NOT NULL,
  code VARCHAR(10) UNIQUE,
  latitude DECIMAL(10, 8),
  longitude DECIMAL(11, 8),
  parent_id UUID REFERENCES regions(id),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_code (code),
  INDEX idx_parent_id (parent_id)
);

-- Units Table
CREATE TABLE units (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title VARCHAR(255) NOT NULL,
  description TEXT,
  module_id UUID NOT NULL REFERENCES modules(id),
  order_number INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_module_id (module_id),
  INDEX idx_order (order_number)
);

-- Scenarios Table (Core learning content)
CREATE TABLE scenarios (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  unit_id UUID NOT NULL REFERENCES units(id),
  order_number INT NOT NULL,
  situation TEXT NOT NULL,
  question TEXT NOT NULL,
  difficulty VARCHAR(20),  -- 'easy', 'medium', 'hard'
  feedback_slides JSONB,   -- [{slide_title, duration_seconds, content_md}]
  reveal_content TEXT,     -- Short 2-3 line explanation
  deep_content TEXT,       -- Full optional content (markdown)
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  is_active BOOLEAN DEFAULT true,
  INDEX idx_unit_id (unit_id),
  INDEX idx_difficulty (difficulty)
);

-- Scenario Options Table
CREATE TABLE scenario_options (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  scenario_id UUID NOT NULL REFERENCES scenarios(id) ON DELETE CASCADE,
  option_letter VARCHAR(1),  -- A, B, C, D
  option_text TEXT NOT NULL,
  is_correct BOOLEAN NOT NULL,
  rationale TEXT,            -- Why this is correct/incorrect
  principle_tag VARCHAR(100), -- e.g., 'Confidentiality', 'Integrity'
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE (scenario_id, option_letter),
  INDEX idx_scenario_id (scenario_id)
);

-- Responses Table (User decisions)
CREATE TABLE responses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id),
  scenario_id UUID NOT NULL REFERENCES scenarios(id),
  chosen_option VARCHAR(1) NOT NULL,
  is_correct BOOLEAN NOT NULL,
  time_spent_seconds INT,
  attempt_number INT DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_user_id (user_id),
  INDEX idx_scenario_id (scenario_id),
  INDEX idx_created_at (created_at),  -- For analytics
  INDEX idx_user_created (user_id, created_at)
);

-- Analytics Events Table (Append-only, partitioned)
CREATE TABLE analytics_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id),
  region_id UUID REFERENCES regions(id),  -- Denormalized
  event_type VARCHAR(100),  -- 'scenario_viewed', 'decision_made', 'read_more_clicked'
  scenario_id UUID REFERENCES scenarios(id),
  unit_id UUID REFERENCES units(id),
  metadata JSONB,  -- Custom event data
  timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_user_timestamp (user_id, timestamp),
  INDEX idx_timestamp (timestamp),
  INDEX idx_event_type (event_type)
) PARTITION BY RANGE (timestamp);

-- Create partitions by date
CREATE TABLE analytics_events_2026_04 PARTITION OF analytics_events
  FOR VALUES FROM ('2026-04-01') TO ('2026-05-01');

-- Materialized Views Table (Pre-calculated metrics)
CREATE TABLE metrics_cache (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  metric_type VARCHAR(100),  -- 'user_engagement', 'scenario_performance', 'region_summary'
  time_period VARCHAR(50),   -- 'today', 'last_7_days', 'last_30_days'
  region_id UUID REFERENCES regions(id),
  data JSONB,  -- {completion_rate, correct_rate, avg_time, etc}
  calculated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  expires_at TIMESTAMP,  -- Refresh every 30s
  INDEX idx_metric_expires (metric_type, expires_at)
);
```

---

### 3. Query Optimization Strategy

**Materialized Views** (refreshed every 30 seconds):

```sql
-- User Engagement Summary
CREATE MATERIALIZED VIEW user_engagement_daily AS
SELECT
  user_id,
  DATE(created_at) as date,
  COUNT(*) as total_responses,
  SUM(CASE WHEN is_correct THEN 1 ELSE 0 END) as correct_count,
  ROUND(100.0 * SUM(CASE WHEN is_correct THEN 1 ELSE 0 END) / COUNT(*), 2) as success_rate,
  AVG(time_spent_seconds) as avg_time
FROM responses
GROUP BY user_id, DATE(created_at);

CREATE INDEX idx_user_engagement_user_date ON user_engagement_daily(user_id, date);

-- Scenario Performance
CREATE MATERIALIZED VIEW scenario_performance AS
SELECT
  scenario_id,
  unit_id,
  COUNT(*) as total_attempts,
  SUM(CASE WHEN is_correct THEN 1 ELSE 0 END) as correct_attempts,
  ROUND(100.0 * SUM(CASE WHEN is_correct THEN 1 ELSE 0 END) / COUNT(*), 2) as success_rate,
  AVG(time_spent_seconds) as avg_time
FROM responses
GROUP BY scenario_id, unit_id;

CREATE INDEX idx_scenario_perf_unit ON scenario_performance(unit_id);

-- Regional Summary
CREATE MATERIALIZED VIEW regional_summary AS
SELECT
  u.region_id,
  r.name as region_name,
  COUNT(DISTINCT u.id) as total_users,
  COUNT(DISTINCT CASE WHEN resp.created_at > NOW() - INTERVAL '7 days' THEN u.id END) as active_users_7d,
  ROUND(100.0 * SUM(CASE WHEN resp.is_correct THEN 1 ELSE 0 END) / NULLIF(COUNT(*), 0), 2) as completion_rate
FROM users u
LEFT JOIN regions r ON u.region_id = r.id
LEFT JOIN responses resp ON u.id = resp.user_id
GROUP BY u.region_id, r.name;

CREATE INDEX idx_regional_summary_region ON regional_summary(region_id);
```

---

## API SPECIFICATIONS

### 1. Scenario Endpoints

#### Get Scenario (User Flow)
```
GET /api/v1/scenarios/:scenarioId
Authorization: Bearer {token}

Response 200:
{
  "id": "uuid",
  "unit": { "id": "uuid", "title": "Unit 2.3" },
  "situation": "A veteran teacher tells you...",
  "question": "How do you respond?",
  "options": [
    { "letter": "A", "text": "Agree to observe..." },
    { "letter": "B", "text": "Explain your coaching role..." },
    { "letter": "C", "text": "Ask for permission..." },
    { "letter": "D", "text": "Decline to get involved..." }
  ],
  "difficulty": "medium"
}
```

#### Submit Response
```
POST /api/v1/responses
Authorization: Bearer {token}
Content-Type: application/json

Request:
{
  "scenarioId": "uuid",
  "chosenOption": "B",
  "timeSpentSeconds": 45
}

Response 201:
{
  "responseId": "uuid",
  "isCorrect": true,
  "feedback": {
    "verdict": "correct",
    "rationale": "This maintains your coaching role...",
    "revealSlides": [
      {
        "title": "Why Confidentiality Matters",
        "durationSeconds": 15,
        "content": "Markdown content"
      },
      { ... }
    ],
    "deepContent": {
      "title": "Optional: Full Context",
      "content": "Markdown with full detail"
    }
  }
}
```

---

### 2. Analytics Endpoints

#### Dashboard Overview
```
GET /api/v1/analytics/dashboard?period=last_7_days&regionId=uuid
Authorization: Bearer {token}

Response 200:
{
  "period": "last_7_days",
  "kpis": {
    "totalUsers": 2450,
    "activeUsers": 1850,
    "completionRate": 74,
    "avgTimePerUnit": "3m 20s"
  },
  "engagement": {
    "scenarioCompletionRate": 85,
    "slideEngagementRate": 42,
    "readMoreClickRate": 28
  },
  "performance": {
    "correctDecisionRate": 72,
    "incorrectDecisionRate": 28
  },
  "trends": {
    "completionRateTrend": [
      { "date": "2026-04-06", "rate": 68 },
      { "date": "2026-04-07", "rate": 70 },
      ...
    ]
  }
}
```

#### Scenario Performance (Heatmap Data)
```
GET /api/v1/analytics/scenarios?unitId=uuid&regionId=uuid
Authorization: Bearer {token}

Response 200:
{
  "unit": "Unit 1.3",
  "scenarios": [
    {
      "scenarioId": "uuid",
      "title": "Scenario 1: Building Trust",
      "correctRate": 82,
      "totalAttempts": 450,
      "avgTimeSeconds": 120,
      "difficulty": "medium"
    },
    ...
  ]
}
```

#### Regional Performance Map Data
```
GET /api/v1/analytics/regions?includeStats=true
Authorization: Bearer {token}

Response 200:
{
  "regions": [
    {
      "id": "uuid",
      "name": "Islamabad",
      "coordinates": { "lat": 33.6844, "lng": 73.0479 },
      "stats": {
        "totalUsers": 450,
        "activeUsers": 380,
        "completionRate": 85,
        "correctDecisionRate": 78,
        "avgTimePerUnit": 200
      },
      "subRegions": [ ... ]
    },
    ...
  ]
}
```

#### User Performance
```
GET /api/v1/analytics/users/:userId
Authorization: Bearer {token}

Response 200:
{
  "userId": "uuid",
  "name": "Fatima Khan",
  "region": "Punjab",
  "totalScenarios": 42,
  "completedScenarios": 38,
  "completionRate": 90,
  "correctDecisions": 28,
  "correctRate": 74,
  "totalTimeHours": 2.5,
  "avgTimePerScenario": 220,
  "progressByUnit": [
    { "unitId": "uuid", "unitName": "Unit 1.0", "completed": 6, "total": 6 },
    ...
  ]
}
```

---

### 3. RBAC Endpoints

#### Assign Role
```
POST /api/v1/roles/:roleId/assign
Authorization: Bearer {token} (Super Admin only)

Request:
{
  "userId": "uuid",
  "roleId": "uuid"
}

Response 200:
{
  "userId": "uuid",
  "roleId": "uuid",
  "role": "Regional Admin",
  "assignedAt": "2026-04-13T10:30:00Z"
}
```

#### Get User Permissions
```
GET /api/v1/users/:userId/permissions
Authorization: Bearer {token}

Response 200:
{
  "userId": "uuid",
  "role": "Regional Admin",
  "permissions": [
    { "resource": "analytics", "action": "view", "regionScoped": true },
    { "resource": "users", "action": "update", "regionScoped": true },
    { "resource": "scenarios", "action": "view", "regionScoped": false }
  ]
}
```

---

### 4. WebSocket Events (Real-time Dashboard)

```javascript
// Client connects to WebSocket
const ws = new WebSocket('wss://api.coachcert.io/live');

// Subscribe to metrics updates
ws.send(JSON.stringify({
  type: 'subscribe',
  channel: 'metrics',
  filter: { regionId: 'uuid' }
}));

// Receive metrics every 30s
ws.onmessage = (event) => {
  const update = JSON.parse(event.data);
  // {
  //   type: 'metrics:update',
  //   data: { completionRate: 75, activeUsers: 1850, ... },
  //   timestamp: 'ISO8601'
  // }
};

// Subscribe to heatmap changes
ws.send(JSON.stringify({
  type: 'subscribe',
  channel: 'heatmap',
  filter: { unitId: 'uuid' }
}));

ws.onmessage = (event) => {
  const update = JSON.parse(event.data);
  // {
  //   type: 'heatmap:update',
  //   data: [
  //     { scenarioId: 'uuid', successRate: 82, updated: true },
  //     ...
  //   ]
  // }
};
```

---

## IMPLEMENTATION PLAN

### Phase 1: Foundation (Weeks 1–2)

**Goal:** Set up infrastructure and data model

#### Tasks
1. **Database Schema**
   - [ ] Create PostgreSQL schema (users, roles, regions, scenarios, responses)
   - [ ] Add indexes for query performance
   - [ ] Set up materialized views for metrics
   - [ ] Create partitioned analytics_events table

2. **Backend Infrastructure**
   - [ ] Set up Express.js API with middleware (auth, RBAC, logging)
   - [ ] Implement JWT authentication
   - [ ] Create RBAC middleware
   - [ ] Set up environment configuration

3. **Core Services**
   - [ ] ScenarioService (CRUD)
   - [ ] ResponseService (record user decisions)
   - [ ] UserService (manage users, roles, regions)
   - [ ] AuthService (JWT, refresh tokens)

4. **Testing**
   - [ ] Unit tests for services
   - [ ] Integration tests for API endpoints
   - [ ] Database seed data (test scenarios)

**Deliverables:**
- [ ] PostgreSQL schema deployed to dev/staging
- [ ] Express API with 10+ core endpoints
- [ ] RBAC middleware working
- [ ] Test suite (80%+ coverage)

---

### Phase 2: Scenario-First UI (Weeks 3–4)

**Goal:** Build the new learning experience

#### Tasks
1. **Frontend Components**
   - [ ] ScenarioCard component
   - [ ] OptionsSelector (A/B/C/D radio buttons)
   - [ ] FeedbackCard with verdict (correct/incorrect)
   - [ ] RevealSlides carousel
   - [ ] ExpandableDepth ("Read more" toggle)

2. **User Flow**
   - [ ] Dashboard landing → unit selection
   - [ ] Unit → scenario list
   - [ ] Scenario detail view
   - [ ] Response submission + feedback display
   - [ ] Progress tracking

3. **State Management**
   - [ ] Redux/RTK setup for user state
   - [ ] Scenario state (current, responses, progress)
   - [ ] Sync responses to backend via API

4. **Testing**
   - [ ] Component tests (Jest + React Testing Library)
   - [ ] E2E tests (Cypress/Playwright)

**Deliverables:**
- [ ] Complete scenario flow in React
- [ ] Connected to backend API
- [ ] Mobile-responsive design
- [ ] E2E tests for user flow

---

### Phase 3: Analytics Dashboard (Weeks 5–6)

**Goal:** Build admin analytics dashboard

#### Tasks
1. **KPI Components**
   - [ ] KPI cards (total users, active users, completion rate)
   - [ ] Trend charts (engagement over time)
   - [ ] Performance gauges

2. **Heatmap Visualization**
   - [ ] Grid: Units × Scenarios
   - [ ] Color coding (green/yellow/red)
   - [ ] Click to drill down (scenario details)

3. **Regional Map**
   - [ ] Interactive map (Leaflet or Mapbox)
   - [ ] Clickable regions with stats
   - [ ] Drill-down: Region → Users → Units → Scenarios
   - [ ] Comparison tool (Region A vs B)

4. **Drop-off Funnel**
   - [ ] Visualize: Start → Decision → Feedback → Depth
   - [ ] Identify abandonment points
   - [ ] Filter by unit/region/user cohort

5. **Data Export**
   - [ ] Generate CSV reports
   - [ ] Generate PDF summary
   - [ ] Schedule reports (email delivery)

**Deliverables:**
- [ ] Full analytics dashboard (responsive)
- [ ] Regional performance map
- [ ] Drill-down functionality
- [ ] Export capabilities

---

### Phase 4: RBAC System (Week 7)

**Goal:** Implement role-based access control

#### Tasks
1. **Role Management UI**
   - [ ] Admin page to assign roles
   - [ ] Bulk user import with roles
   - [ ] Permission matrix editor

2. **Regional Admin Features**
   - [ ] Dashboard filtered by region
   - [ ] Manage users within region
   - [ ] View analytics (region only)

3. **Access Control Enforcement**
   - [ ] API middleware validates permissions
   - [ ] Frontend hides/disables unauthorized features
   - [ ] Audit log (track permission changes)

**Deliverables:**
- [ ] Role assignment UI
- [ ] Regional scoping working
- [ ] Audit logs

---

### Phase 5: Real-time Updates (Week 8)

**Goal:** Add WebSocket support for live dashboard

#### Tasks
1. **WebSocket Server**
   - [ ] Set up Socket.io or ws library
   - [ ] Implement connection management
   - [ ] Subscribe to channels (metrics, heatmap, regional)

2. **Analytics Engine**
   - [ ] Background job refreshes materialized views every 30s
   - [ ] Pushes updates via WebSocket
   - [ ] Handles reconnection/fallback

3. **Frontend Integration**
   - [ ] Connect dashboard to WebSocket
   - [ ] Update metrics in real-time
   - [ ] Graceful degradation (polling fallback)

**Deliverables:**
- [ ] Live dashboard updates
- [ ] WebSocket server
- [ ] Background analytics job

---

### Phase 6: Testing & QA (Week 9)

**Goal:** Comprehensive testing before launch

#### Tasks
1. **Load Testing**
   - [ ] Simulate 1000+ concurrent users
   - [ ] Analytics queries under load
   - [ ] WebSocket scalability

2. **User Acceptance Testing**
   - [ ] Regional admins test their features
   - [ ] Coaches test scenario flow
   - [ ] Gather feedback

3. **Security Audit**
   - [ ] OWASP Top 10 review
   - [ ] SQL injection/XSS prevention
   - [ ] Token expiration/refresh

**Deliverables:**
- [ ] Load testing report
- [ ] Security audit sign-off
- [ ] UAT feedback document

---

### Phase 7: Migration & Rollout (Week 10)

**Goal:** Migrate from old flow to new flow

#### Tasks
1. **Data Migration**
   - [ ] Migrate existing scenarios to new format
   - [ ] Convert old responses to new schema
   - [ ] Validate data integrity

2. **Gradual Rollout**
   - [ ] Enable new flow for 10% of users (canary)
   - [ ] Monitor metrics (engagement, errors)
   - [ ] Expand to 25%, 50%, 100%

3. **Training & Docs**
   - [ ] Write admin guide (dashboard, RBAC)
   - [ ] Write coach guide (new learning flow)
   - [ ] Video tutorials

**Deliverables:**
- [ ] Migration scripts
- [ ] Deployment plan
- [ ] Documentation

---

## ANALYTICS & MEASUREMENT

### 1. Key Metrics to Track

#### Engagement Metrics
```
Scenario Completion Rate = (Scenarios Completed / Scenarios Attempted) × 100
  Target: > 85%

Slide Engagement Rate = (Users who view reveal slides / Users who submit decision) × 100
  Target: > 60%
  (Expected ↓ from 68% in old flow — users have choice)

Read More Click Rate = (Users who expand optional content / Total users) × 100
  Target: 25–35%
  (Metric didn't exist in old flow — new capability)

Drop-off Rate = (Users who abandon mid-unit / Users who start unit) × 100
  Target: < 15%
  (Expected ↓ from 30% in old flow)

Time to First Decision = Average seconds before user submits answer
  Target: < 60s
  (Expected ↓ from 120s — less context needed)
```

#### Performance Metrics
```
Correct Decision Rate = (Correct decisions / Total decisions) × 100
  Target: > 70%
  (Indicate learning effectiveness)

Learning Curve = Correct rate in unit 1 vs unit 6
  Target: 15–20% improvement
  (Show progression through difficulty)

Per-Scenario Difficulty = Correct rate per scenario
  Classify: Easy (>80%), Medium (60–80%), Hard (<60%)
  (Identify problematic scenarios for redesign)
```

#### Efficiency Metrics
```
Time per Scenario = Average seconds spent per scenario
  Target: 2–3 minutes
  (Less than old flow due to optional content)

Units Completed per User = Average units completed per active user
  Target: > 4 units per month
  (Show engagement intensity)

Repeat Attempt Rate = (Users with >1 attempt per scenario / Total) × 100
  Target: 10–15%
  (Show learning persistence)
```

#### Effectiveness Metrics
```
Assessment Performance = Baseline & Endline quiz scores
  Compare: Pre-scenario-first vs Post-scenario-first
  (Primary measure of learning impact)

Behavior Change = (In production) do coaches apply learning?
  Measure: Track coaching session outcomes, teacher feedback
  (Delayed metric, measured via separate coaching platform)
```

---

### 2. Analytics Implementation

#### Event Tracking Schema
```javascript
// Track every user interaction
{
  userId: "uuid",
  timestamp: "ISO8601",
  eventType: "scenario_viewed" | "decision_submitted" | "feedback_viewed" | "read_more_clicked",

  // Scenario context
  scenarioId: "uuid",
  unitId: "uuid",
  regionId: "uuid",

  // Decision data (for decision_submitted)
  chosenOption: "A" | "B" | "C" | "D",
  isCorrect: boolean,
  timeSpentSeconds: 45,
  attemptNumber: 1,

  // Engagement data
  slideEngagementDuration: 45,  // seconds viewing reveal slides
  readMoreClicked: false,
  readMoreTimeSeconds: 0,

  // Device/session
  deviceType: "mobile" | "tablet" | "desktop",
  sessionId: "uuid",
  userAgent: "Mozilla/5.0..."
}
```

#### Real-time Aggregation
```javascript
// Every 30 seconds, materialized view updates:

metrics_cache = {
  metric_type: "user_engagement",
  time_period: "today",
  data: {
    total_responses: 4250,
    correct_responses: 3060,  // 72%
    total_users_active: 1850,
    avg_response_time: 125,
    avg_time_viewing_slides: 42,
    read_more_clicks: 480,     // 28%
    dropoff_count: 320,
    scenarios_with_difficulty: {
      easy: 150,
      medium: 280,
      hard: 45
    }
  },
  calculated_at: "2026-04-13T10:30:00Z",
  expires_at: "2026-04-13T10:30:30Z"
}
```

---

## A/B TESTING STRATEGY

### 1. Test Design: Old vs Scenario-First

#### Hypothesis
**Null Hypothesis (H0):** Scenario-First flow has no statistically significant impact on engagement
**Alternative Hypothesis (H1):** Scenario-First flow increases engagement by ≥ 25%

#### Test Setup
```
Population: 2000 coaches
Experiment Duration: 4 weeks
Sample Groups:
  - Control (50%): 1000 users → Old flow (Slides → Scenario)
  - Treatment (50%): 1000 users → New flow (Scenario → Reveal → Optional Depth)

Randomization: By user_id % 2 (deterministic, no cookie-based state)
```

#### Primary Metrics
```
1. Scenario Completion Rate
   Control avg: 68%
   Treatment target: 85%
   Statistical test: Two-proportion Z-test
   Significance level: α = 0.05

2. Average Time to Decision
   Control avg: 120s
   Treatment target: < 60s
   Statistical test: Two-sample t-test

3. Drop-off Rate at End of Unit
   Control avg: 30%
   Treatment target: < 15%
   Statistical test: Chi-square test
```

#### Secondary Metrics
```
- Assessment score (baseline/endline quiz)
- Slide engagement (% viewing reveal slides)
- Time per unit (excluding optional depth)
- Repeat attempt rate
```

#### Sample Size Calculation
```
Metric: Scenario Completion Rate
Control: p1 = 0.68
Treatment: p2 = 0.85
Effect size: p2 - p1 = 0.17

Using Cochran's formula:
n = (z_α + z_β)² × [p1(1-p1) + p2(1-p2)] / (p2 - p1)²

With α = 0.05 (two-tailed), power = 0.80:
n ≈ 320 per group

→ Total sample: 640 (use 1000 per group for larger effect detection)
```

---

### 2. Experiment Tracking

#### Implement Feature Flag
```javascript
// Database: feature_flags table
{
  flag: "scenario_first_flow",
  enabled: true,
  rollout_percentage: 50,  // 50% of users
  variant_groups: {
    control: "old_flow",
    treatment: "scenario_first"
  },
  started_at: "2026-04-20T00:00:00Z",
  ended_at: "2026-05-18T23:59:59Z"
}

// API endpoint
GET /api/v1/users/me/feature-flags
Response:
{
  userId: "uuid",
  flags: {
    scenario_first_flow: {
      enabled: true,
      variant: "treatment"  // or "control"
    }
  }
}

// Frontend usage
if (userFlags.scenario_first_flow.variant === 'treatment') {
  return <ScenarioFirstFlow />;
} else {
  return <OldSlideFirstFlow />;
}
```

#### Tracking & Analysis
```javascript
// Log experiment enrollment
POST /api/v1/analytics/experiments
{
  experimentId: "scenario_first_v1",
  userId: "uuid",
  variant: "treatment",
  enrolledAt: "ISO8601",
  regionId: "uuid"
}

// Weekly analysis query
SELECT
  variant,
  COUNT(*) as user_count,
  SUM(CASE WHEN completed THEN 1 ELSE 0 END) as completions,
  ROUND(100.0 * SUM(CASE WHEN completed THEN 1 ELSE 0 END) / COUNT(*), 2) as completion_rate,
  AVG(time_to_decision_seconds) as avg_time,
  STDDEV(time_to_decision_seconds) as stddev_time
FROM responses r
JOIN users u ON r.user_id = u.id
JOIN experiment_enrollments e ON u.id = e.user_id
WHERE e.experiment_id = 'scenario_first_v1'
  AND r.created_at > NOW() - INTERVAL '1 week'
GROUP BY variant;
```

---

### 3. Statistical Analysis

#### T-Test for Time-to-Decision
```python
# Python (scipy)
from scipy import stats

control_times = [120, 115, 125, ...]  # n=1000
treatment_times = [55, 60, 50, ...]   # n=1000

t_stat, p_value = stats.ttest_ind(control_times, treatment_times)

if p_value < 0.05:
    print(f"✓ Significant difference (p={p_value:.4f})")
    print(f"Treatment is faster: Δ = {np.mean(treatment_times) - np.mean(control_times):.1f}s")
else:
    print(f"✗ No significant difference (p={p_value:.4f})")
```

#### Confidence Intervals
```python
import numpy as np
from scipy import stats

control_completion = 0.68
control_n = 1000

treatment_completion = 0.85
treatment_n = 1000

# 95% CI for treatment
ci = stats.binom.interval(0.95, treatment_n, treatment_completion)
print(f"Treatment completion rate: {treatment_completion:.1%} (CI: {ci[0]/treatment_n:.1%} - {ci[1]/treatment_n:.1%})")

# Effect size (Cohen's h)
h = 2 * (np.arcsin(np.sqrt(treatment_completion)) - np.arcsin(np.sqrt(control_completion)))
print(f"Effect size (Cohen's h): {h:.3f}")  # > 0.2 is meaningful
```

---

### 4. Rollout Strategy

#### Canary Deployment
```
Week 1: 10% → Monitor for 3 days
  → Check: Errors, API latency, user feedback
  → Decision: Proceed if no major issues

Week 2: 25% → Monitor for 3 days
  → Check: All metrics moving in right direction
  → Decision: Proceed if completion rate > 75%

Week 3: 50% → Monitor for 3 days
  → Full statistical analysis
  → Decision: Proceed if p-value < 0.05

Week 4: 100% → Full rollout
  → Disable feature flag
  → Archive old flow code (after 2-week safety window)
```

---

## MIGRATION & ROLLOUT

### 1. Data Migration Strategy

#### Scenario Migration (Old → New Format)
```sql
-- Old format: questions table with options as separate table
SELECT
  q.id,
  q.question_text,
  q.assessment_id,
  ARRAY_AGG(json_build_object(
    'letter', o.option_letter,
    'text', o.option_text,
    'is_correct', o.is_correct
  ) ORDER BY o.option_letter) as options
FROM questions q
LEFT JOIN options o ON q.id = o.question_id
GROUP BY q.id;

-- New format: Create scenarios with embedded structure
INSERT INTO scenarios (
  unit_id, situation, question, difficulty,
  feedback_slides, reveal_content, deep_content
)
SELECT
  u.id,
  q.situation,  -- May need to extract/edit from old question
  q.question_text,
  CASE
    WHEN q.assessment_id IN (SELECT id FROM hard_assessment_mapping) THEN 'hard'
    WHEN q.assessment_id IN (SELECT id FROM easy_assessment_mapping) THEN 'easy'
    ELSE 'medium'
  END,
  jsonb_build_array(  -- Create reveal slides from rationale
    jsonb_build_object(
      'title', 'Why this matters',
      'duration_seconds', 15,
      'content', q.rationale
    )
  ),
  q.rationale,
  q.deep_content
FROM questions q
JOIN units u ON q.unit_id = u.id;

-- Migrate options
INSERT INTO scenario_options (scenario_id, option_letter, option_text, is_correct, rationale)
SELECT
  s.id,
  o.option_letter,
  o.option_text,
  o.is_correct,
  o.rationale
FROM scenario_options_old o
JOIN scenarios s ON o.question_id = s.old_question_id;
```

#### Response Migration (Old → New Format)
```sql
-- Minimal migration: responses already track user decision
-- Just map old question_id to new scenario_id
INSERT INTO responses (user_id, scenario_id, chosen_option, is_correct, time_spent_seconds)
SELECT
  r.user_id,
  s.id,  -- New scenario ID
  r.chosen_option,
  r.is_correct,
  COALESCE(r.time_spent_seconds, 120)  -- Default to avg if missing
FROM responses_old r
JOIN scenario_migration_map m ON r.question_id = m.old_question_id
JOIN scenarios s ON m.new_scenario_id = s.id;
```

---

### 2. Backward Compatibility (Transition Period)

#### Maintain Old Flow for 2 Weeks
```
Week 1: New flow enabled for 50%
  - Old flow still works for other 50%
  - Both write to same analytics tables (tag with flow_type)
  - Monitor both flows in parallel

Week 2: Decide on continuation
  - If metrics look good: Increase new flow to 100%
  - If issues: Revert; iterate, retest

Week 3: Archive old flow (keep code in git, disabled)
  - Remove from UI entirely
  - Disable in database (soft delete)
```

---

### 3. Deployment Checklist

- [ ] Database schema deployed to staging
- [ ] Migration scripts tested (rollback verified)
- [ ] All analytics views working
- [ ] RBAC enforced in API
- [ ] WebSocket server running
- [ ] Frontend feature flags deployed
- [ ] Load testing passed (1000+ concurrent)
- [ ] Security audit passed
- [ ] UAT sign-off from stakeholders
- [ ] Documentation complete
- [ ] Support team trained
- [ ] Monitoring/alerting configured
- [ ] Incident response plan ready

---

## SUMMARY & NEXT STEPS

### What We've Designed
1. **New Learning Model:** Scenario-First → Reveal → Optional Depth
2. **Analytics Dashboard:** KPIs, heatmaps, regional tracking, drill-downs
3. **RBAC System:** Super Admin, Regional Admin, Coach roles
4. **Tech Stack:** React, Express.js, PostgreSQL, Redis
5. **Implementation Plan:** 10-week phased rollout
6. **Measurement & Testing:** A/B testing framework, statistical rigor
7. **Migration:** Backward-compatible, canary-based rollout

### Immediate Next Steps
1. **Week 1 Approval:**
   - [ ] Confirm tech stack choice
   - [ ] Approve database schema
   - [ ] Assign team (Backend, Frontend, Analytics, QA)

2. **Week 2–3 Execution:**
   - [ ] Set up repositories with initial structure
   - [ ] Create database and initial migrations
   - [ ] Build API foundation

3. **Throughout:**
   - [ ] Weekly stakeholder syncs
   - [ ] Regular demos
   - [ ] Gather feedback early & often

---

**Document Version:** 1.0
**Last Updated:** April 13, 2026
**Status:** Ready for Development Phase
