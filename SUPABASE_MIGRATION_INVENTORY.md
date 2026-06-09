# Supabase → PostgreSQL API Migration Inventory

**Current Date:** 2026-06-09  
**Status:** Inventory Phase  
**Total Files Affected:** 50+ TypeScript/TSX files  
**Total Supabase Tables:** 8 tables with active queries  

---

## Executive Summary

This document catalogs all 50+ frontend files that currently use direct Supabase queries and maps them to PostgreSQL tables. The goal is to migrate from Supabase client library calls (`.from()`, `.select()`, `.insert()`, etc.) to REST API calls via the coaching-api backend (FastAPI).

**Current State:**
- ✅ Quiz API implemented (FastAPI backend + apiClient frontend)
- ❌ All other domains still using Supabase directly
- 🔄 ~50 files need refactoring

**Key Discovery:** The coaching-api backend already exists with proper FastAPI structure, models, and services. We are building on top of this.

---

## I. Data Inventory by Table

### 1. Profiles (Auth Domain)

**Files:** 1  
**Operations:** SELECT (single), RPC calls  
**Refactoring Status:** ⚠️ NOT STARTED

| File | Operation | Query | Notes |
|------|-----------|-------|-------|
| src/contexts/AuthContext.tsx | SELECT | `.from("profiles").select("*").eq("id", userId)` | User profile fetch after login |
| src/contexts/AuthContext.tsx | RPC | `create_profile_after_signup` | SECURITY DEFINER function, creates profile immediately after signup |

**Migration Plan:**
- Create `/api/users/profile` endpoint (GET)
- Create `/api/users/profile` endpoint (PUT) for updates
- Replace RPC call with REST endpoint for signup

---

### 2. COT_Observations (Coaching Domain - LARGEST)

**Files:** 14  
**Operations:** SELECT, INSERT, UPDATE, DELETE  
**Refactoring Status:** ❌ NOT STARTED

| File | Operation | Query Details |
|------|-----------|---|
| src/components/observation/CoachingHubTab.tsx | UPDATE, DELETE | Status updates, deletion |
| src/components/observation/HotsRubricForm.tsx | UPDATE | Save HOTS rubric scores |
| src/components/observation/FicoRubricForm.tsx | UPDATE | Save FICO rubric |
| src/components/observation/DebriefForm.tsx | UPDATE | Save debrief notes |
| src/components/observation/SmartScheduleTab.tsx | SELECT | Fetch scheduled observations |
| src/components/observation/DraftObservationsTab.tsx | DELETE | Delete draft observations |
| src/components/observation/NeoAnalysis.tsx | SELECT, UPDATE | Fetch and update observations |
| src/components/observation/ScheduleDialog.tsx | INSERT | Create new observation |
| src/components/observation/QuickObservationPanel.tsx | UPDATE | Status: Draft/Submitted |
| src/data/observations.ts | SELECT | Data access layer |
| (9 more in observation folder) | VARIOUS | HOTS/FICO components, etc. |

**Refactoring Impact:** HIGH — This is the coaching hub, heavily used

**Migration Plan:**
- Create `/api/observations/*` endpoints (CRUD)
- Create `/api/observations/{id}/rubric` endpoints (HOTS/FICO updates)
- Create `/api/observations/{id}/debrief` endpoint
- Consolidate all observation logic into a single API domain

---

### 3. Field_Issues (Reporting Domain)

**Files:** 2  
**Operations:** INSERT, SELECT  
**Refactoring Status:** ❌ NOT STARTED

| File | Operation | Query |
|------|-----------|-------|
| src/components/observation/ReportIssueButton.tsx | INSERT | Create field issue report |
| src/components/observation/ReportIssueButton.tsx | SELECT | Fetch coach sub_region |

**Migration Plan:**
- Create `/api/field-issues/` endpoint (POST)
- Include coach context in request body

---

### 4. Coach_Assignments (Coaching Domain)

**Files:** 1  
**Operations:** SELECT  
**Refactoring Status:** ❌ NOT STARTED

| File | Operation | Query |
|------|-----------|-------|
| src/components/observation/ReportIssueButton.tsx | SELECT | `.from('coach_assignments').select('sub_region').eq('coach_id', user.id)` |

**Migration Plan:**
- Create `/api/coaches/me/assignment` endpoint (GET)
- Return coach assignment with sub_region

---

### 5. Teacher_DC_Scores (Smart Schedule Domain)

**Files:** 1  
**Operations:** SELECT  
**Refactoring Status:** ❌ NOT STARTED

| File | Operation | Query |
|------|-----------|-------|
| src/components/observation/SmartScheduleTab.tsx | SELECT | `.from('teacher_dc_scores').select('*')` |

**Migration Plan:**
- Create `/api/schedule/teacher-dc-scores` endpoint (GET)
- Return ranked teachers with scores

---

### 6. Training_Content (Training Domain)

**Files:** 2  
**Operations:** SELECT  
**Refactoring Status:** ❌ NOT STARTED

| File | Operation | Query |
|------|-----------|-------|
| src/components/training/TrainingContentViewer.tsx | SELECT | `.from("training_content").select("*").eq("training_id", trainingId)` |

**Migration Plan:**
- Already have models for training in coaching-api
- Create `/api/trainings/{trainingId}/content` endpoint (GET)

---

### 7. User_Roles (Auth/Admin Domain)

**Files:** 2  
**Operations:** SELECT  
**Refactoring Status:** ❌ NOT STARTED

| File | Operation | Query |
|------|-----------|-------|
| src/hooks/useAdminRole.ts | SELECT | `.from("user_roles").select("role").eq("user_id", user.id)` |
| src/hooks/useCoachRole.ts | SELECT | `.from("user_roles").select("role").eq("user_id", user.id)` |

**Migration Plan:**
- Create `/api/users/me/role` endpoint (GET)
- Use JWT from Supabase auth for authentication
- Return role type as enum

---

### 8. Analytics_Events (Analytics Domain)

**Files:** 1  
**Operations:** INSERT  
**Refactoring Status:** ❌ NOT STARTED

| File | Operation | Query |
|------|-----------|-------|
| src/hooks/useAnalytics.ts | INSERT | `.from("analytics_events").insert({ user_id, ... })` |

**Migration Plan:**
- Create `/api/analytics/event` endpoint (POST)
- Accept event payload and store in analytics_events table
- Maintain fire-and-forget pattern (no await)

---

## II. File Categorization for Phased Migration

### Phase 1: Auth & Admin (High Priority)

Files to refactor:
1. src/contexts/AuthContext.tsx
2. src/hooks/useAdminRole.ts
3. src/hooks/useCoachRole.ts

**Why Phase 1:** Auth is a dependency for everything else

---

### Phase 2: Observations & Coaching (Highest Impact)

Files to refactor (14 files):
1. src/components/observation/CoachingHubTab.tsx
2. src/components/observation/HotsRubricForm.tsx
3. src/components/observation/FicoRubricForm.tsx
4. src/components/observation/DebriefForm.tsx
5. src/components/observation/SmartScheduleTab.tsx
6. src/components/observation/DraftObservationsTab.tsx
7. src/components/observation/NeoAnalysis.tsx
8. src/components/observation/ScheduleDialog.tsx
9. src/components/observation/QuickObservationPanel.tsx
10. src/components/observation/ReportIssueButton.tsx
11. src/data/observations.ts
12. (3 more observation components)

**Why Phase 2:** These files represent the core coaching functionality and impact the most users

---

### Phase 3: Training & Content

Files to refactor:
1. src/components/training/TrainingContentViewer.tsx
2. src/lib/seedModule*.ts (migrate to seed API)

**Why Phase 3:** Sequential, after core observations work

---

### Phase 4: Analytics

Files to refactor:
1. src/hooks/useAnalytics.ts

**Why Phase 4:** Non-blocking, can be parallelized with other phases

---

## III. Database Schema Reference

All tables exist in PostgreSQL (Supabase backend). No schema changes needed, only API layer:

```
profiles (User profiles)
├── id (UUID, PK)
├── phone (String)
├── full_name (String)
└── role (Enum: super_admin, regional_admin, coach, teacher, etc.)

cot_observations (Classroom Observation Tracking)
├── id (UUID, PK)
├── observer_id (FK → profiles.id)
├── teacher_id (FK → profiles.id)
├── status (Enum: Draft, Submitted)
├── hots_rubric (JSONB)
├── fico_rubric (JSONB)
├── hots_notes (Text)
├── created_at (Timestamp)
└── updated_at (Timestamp)

field_issues (Field Issue Reports)
├── id (UUID, PK)
├── coach_id (FK → profiles.id)
├── issue_description (Text)
├── created_at (Timestamp)
└── sub_region (String)

coach_assignments (Coach to Region Assignments)
├── id (UUID, PK)
├── coach_id (FK → profiles.id)
└── sub_region (String)

teacher_dc_scores (Teacher DC Scores for Scheduling)
├── id (UUID, PK)
├── teacher_id (FK → profiles.id)
├── score (Decimal)
└── ranked_position (Integer)

training_content (Training Content)
├── id (UUID, PK)
├── training_id (FK → trainings.id)
├── content (Text/JSONB)
└── created_at (Timestamp)

user_roles (User Role Assignments)
├── user_id (UUID, PK, FK → profiles.id)
├── role (Enum)
└── assigned_at (Timestamp)

analytics_events (Analytics Events)
├── id (UUID, PK)
├── user_id (FK → profiles.id)
├── event_type (String)
├── event_data (JSONB)
└── created_at (Timestamp)
```

---

## IV. Migration Strategy Comparison

### Current: Supabase Direct
```typescript
// Frontend
const { data } = await supabase
  .from('observations')
  .select('*')
  .eq('user_id', userId);
```

**Problems:**
- RLS policies tight-coupled to frontend code
- Hard to version API changes
- No server-side validation beyond RLS
- Difficult to add caching, rate-limiting, logging

### Target: REST API via FastAPI
```typescript
// Frontend
const response = await fetch('/api/observations?user_id=' + userId, {
  headers: { 'Authorization': `Bearer ${jwtToken}` }
});
const data = await response.json();
```

**Benefits:**
- ✅ Clean separation of concerns
- ✅ Easy versioning (v1, v2, v3)
- ✅ Server-side logic centralized
- ✅ Caching, rate-limiting, logging at API layer
- ✅ Easy to add audit trails, notifications, etc.

---

## V. Implementation Checklist

### Per-Phase Checklist

**Phase 1: Auth**
- [ ] Create `/api/users/profile` (GET) endpoint
- [ ] Create `/api/users/profile` (PUT) endpoint
- [ ] Replace AuthContext Supabase calls with API calls
- [ ] Create useProfile hook (replaces fetch logic)
- [ ] Update AuthContext to use new hook
- [ ] Unit tests for apiClient
- [ ] Integration tests for auth flow
- [ ] E2E test: signup → login → profile loaded

**Phase 2: Observations** (same pattern for each component)
- [ ] Create `/api/observations/` CRUD endpoints
- [ ] Create useObservations hook
- [ ] Update 14 observation components
- [ ] Create apiClient for observations
- [ ] Unit tests
- [ ] Integration tests
- [ ] E2E tests: create → view → edit → delete observation

**Phase 3-4:** (similar checklist)

---

## VI. Risk Assessment

| Risk | Impact | Mitigation |
|------|--------|-----------|
| Auth breakage during migration | Critical | Test auth flow E2E before touching other phases |
| Observation data loss | Critical | Maintain backward compat, dual-read during transition |
| Performance regression | High | API should be faster than Supabase (closer to DB) |
| Incomplete test coverage | High | Mandate 100% coverage for new API endpoints |
| Breaking changes to frontend | Medium | Use API versioning (v1, v2, etc.) |

---

## VII. Next Steps

1. **Create API_SPECIFICATION.md** — Define all endpoints across 8 domains
2. **Create API_MIGRATION_IMPLEMENTATION_PLAN.md** — Detailed phase-by-phase timeline
3. **Create TEST_STRATEGY.md** — Unit, integration, E2E test plans
4. **Start Phase 1** — Auth domain (AuthContext, useAdminRole, useCoachRole)

---

## Appendix: File Discovery Commands

```bash
# Find all Supabase queries
grep -r "\.from(" src --include="*.ts" --include="*.tsx" | sed 's/:.*//' | sort -u

# Count by table
grep -roh "from('[^']*')" src --include="*.ts" --include="*.tsx" | sort | uniq -c | sort -rn

# Find all files in observation domain
find src/components/observation -name "*.tsx" -o -name "*.ts"

# Count total affected files
find src -type f \( -name "*.ts" -o -name "*.tsx" \) | xargs grep -l "\.from(" | wc -l
```

---

**Document Version:** 1.0  
**Last Updated:** 2026-06-09  
**Next Review:** After API_SPECIFICATION.md creation
