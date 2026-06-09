# Supabase → PostgreSQL API Migration Strategy - Complete Index

**Project:** Coaching Platform REST API Migration  
**Status:** ✅ Strategy Complete, Ready for Implementation  
**Created:** 2026-06-09  
**Target Start:** Week of 2026-06-15  
**Target Completion:** Week of 2026-07-20  

---

## 📋 Quick Navigation

### Executive Summary
**Problem:** 50+ frontend files use direct Supabase queries; need to migrate to REST API for better separation of concerns.

**Solution:** 5-phase implementation plan using existing FastAPI backend (coaching-api), refactoring frontend to use API clients instead of Supabase directly.

**Scope:** 8 database tables, 7 API domains (Quiz already done)  
**Effort:** 40-50 engineer-days, 2-3 engineers  
**Timeline:** 5 weeks  

---

## 📁 Complete Document Set

### 1. **SUPABASE_MIGRATION_INVENTORY.md** (Root Directory)
**Purpose:** Data inventory and file catalog  
**Read This For:**
- Which files need refactoring (complete list of 50+ files)
- Which tables are affected (8 tables cataloged)
- File categorization by phase
- Database schema reference
- Current state analysis

**Key Sections:**
- Data Inventory by Table (detailed file-to-table mapping)
- File Categorization for Phased Migration (Phase 1-4)
- Database Schema Reference (all 8 tables)
- Risk Assessment
- Implementation Checklist

**Start Reading:** Yes, this is where you understand the scope

---

### 2. **docs/API_SPECIFICATION.md** (Docs Directory)
**Purpose:** Complete REST API specification  
**Read This For:**
- Exact endpoint definitions needed for each API domain
- Request/response formats with examples
- Error handling and status codes
- Rate limiting, pagination, authentication
- API versioning strategy

**Key Sections:**
- Global Requirements (auth, status codes, response envelope)
- Domain 1: Auth & Users
- Domain 2: Observations & Coaching
- Domain 3: Field Issues
- Domain 4: Smart Schedule
- Domain 5: Training & Content
- Domain 6: User Roles
- Domain 7: Analytics
- Domain 8: Quiz (✅ Already Implemented)
- Error Handling & Rate Limiting

**Start Reading:** After understanding scope, before coding

---

### 3. **API_MIGRATION_IMPLEMENTATION_PLAN.md** (Root Directory)
**Purpose:** Phase-by-phase implementation roadmap  
**Read This For:**
- How to execute the migration (detailed breakdown)
- What needs to happen in each phase (1-5)
- Task lists with code examples
- Time estimates per phase
- Resource allocation
- Risk mitigation strategies
- Success metrics

**Key Sections:**
- Phase Architecture & Dependency Graph
- Phase 1: Auth & Users (1 week) — Foundation
- Phase 2: Observations & Coaching (2 weeks) — Highest Impact
- Phase 3: Training & Content (1 week) — Can parallel
- Phase 4: Smart Schedule (1 week) — Can parallel
- Phase 5: Final Testing & Deployment (1 week)
- Per-phase task breakdowns with code examples
- Resource allocation and effort estimates
- File organization post-migration
- Go-live checklist

**Start Reading:** After API spec review, before Phase 1 kicks off

---

### 4. **TEST_STRATEGY.md** (Root Directory)
**Purpose:** Comprehensive testing approach  
**Read This For:**
- How to validate each phase as it ships
- Test patterns for backend (pytest) and frontend (Vitest)
- E2E testing with Cypress
- Test data management
- CI/CD integration
- Coverage targets

**Key Sections:**
- Testing Pyramid (Unit 60% → Integration 30% → E2E 10%)
- Unit Tests (Backend service + controller patterns)
- Integration Tests (API endpoint + database interactions)
- E2E Tests (Complete user workflows)
- Test Execution Strategy (per-phase)
- Test Data Management with Fixtures
- Coverage Goals (>85% overall, >95% critical paths)
- CI/CD GitHub Actions Workflow
- Debugging Failed Tests

**Start Reading:** Before Phase 1 testing begins

---

## 🎯 Quick Facts

### Discovery Results
- **Total Files Affected:** 50+ TypeScript/TSX components
- **Total Tables:** 8 (profiles, cot_observations, field_issues, coach_assignments, teacher_dc_scores, training_content, user_roles, analytics_events)
- **API Domains:** 7 (Auth, Observations, Field Issues, Smart Schedule, Training, User Roles, Analytics) + 1 done (Quiz)

### Highest Priority
**Phase 2: Observations & Coaching**
- 14 files
- cot_observations table heavily used
- Core coaching hub functionality
- High impact on user experience

### Existing Foundation
- ✅ FastAPI backend exists (coaching-api/)
- ✅ Quiz API complete (Phase 8 - reference implementation)
- ✅ SQLAlchemy models established
- ✅ JWT auth framework ready

### Effort Breakdown
| Phase | Timeline | Files | Effort | Notes |
|-------|----------|-------|--------|-------|
| 1: Auth | 1 week | 3 | 7 eng-days | Foundation for all phases |
| 2: Observations | 2 weeks | 14 | 14 eng-days | Highest impact |
| 3: Training | 1 week (parallel) | 2 | 5 eng-days | Can run with Phase 2 |
| 4: Schedule | 1 week (parallel) | 1 | 3 eng-days | Can run with Phase 2-3 |
| 5: Testing & Deploy | 1 week | — | 21 eng-days | Final validation |
| **TOTAL** | **5 weeks** | **50+** | **40-50 eng-days** | 2-3 engineers |

---

## 🚀 Implementation Flow

```
WEEK 1 (June 15-22)
  Phase 1: Auth & Users
    ├─ Backend: User models, services, controllers, middleware
    ├─ Frontend: userApiClient, useProfile, AuthContext refactor
    └─ Tests: Unit + Integration + E2E for auth flow

WEEK 2-3 (June 22 - July 6)
  Phase 2: Observations (PRIMARY)
    ├─ Backend: Observation models, CRUD, HOTS/FICO endpoints
    ├─ Frontend: 14 observation components refactored
    └─ Tests: Full observation workflow coverage

  Parallel: Phase 3 & 4
    ├─ Training API endpoints
    └─ Smart Schedule endpoints

WEEK 3-4 (June 29 - July 13)
  Parallel: Field Issues + User Roles + Analytics
    ├─ Field issue reporting API
    ├─ Role management endpoints
    └─ Analytics event tracking

WEEK 5 (July 13-20)
  Phase 5: Final Testing & Deployment
    ├─ Comprehensive E2E testing
    ├─ Performance validation
    ├─ Staging deployment
    └─ Production rollout
```

---

## 📊 Success Metrics

By end of Phase 5:
- ✅ 100% of Supabase queries migrated to REST API
- ✅ All unit tests passing (>80% coverage per file)
- ✅ All integration tests passing (API + DB)
- ✅ All E2E tests passing (complete workflows)
- ✅ Zero functionality regressions
- ✅ Performance same or better than Supabase
- ✅ API fully documented (OpenAPI auto-generated)
- ✅ Team can extend API for new features

---

## 🔄 Backward Compatibility Strategy

**During Migration:** Dual-read approach
- Supabase calls maintained in some components
- API calls gradually replace Supabase calls
- Frontend always works (no breaking changes)

**Rollback:** Simple
- Revert components to use Supabase directly
- No data loss or corruption risk
- Can rollback mid-phase if issues arise

---

## ⚠️ Key Risks & Mitigation

| Risk | Impact | Mitigation |
|------|--------|-----------|
| Auth breaks (Phase 1) | Critical | Extensive E2E, rollback ready |
| Performance regression | High | Load testing, API faster than Supabase |
| Data loss during migration | Critical | Backward compat, dual-read strategy |
| Incomplete test coverage | High | >85% coverage mandate |
| Breaking changes to frontend | Medium | API versioning (v1, v2) |

---

## 📌 Phase 1 Details (Next Step)

### Phase 1: Auth & Users (1 Week)

**Frontend Files to Refactor:**
1. src/contexts/AuthContext.tsx
2. src/hooks/useAdminRole.ts
3. src/hooks/useCoachRole.ts

**Backend Deliverables:**
- `GET /api/users/profile` — Fetch current user
- `PUT /api/users/profile` — Update profile
- `GET /api/users/me/role` — Get user role
- `GET /api/users/{id}` — Admin: fetch user by ID
- JWT middleware for authentication

**Tests Required:**
- Unit: UserService, UserController
- Integration: Full profile CRUD with DB
- E2E: Signup → login → profile loaded

**Success Criteria:**
- [ ] All AuthContext Supabase calls → API calls
- [ ] useAdminRole, useCoachRole → API calls
- [ ] All unit + integration + E2E tests pass
- [ ] No functionality broken
- [ ] JWT validation working

---

## 🎓 Phase 2 Preview (Highest Impact)

### Phase 2: Observations & Coaching (2 Weeks)

**Why Phase 2?**
- 14 files (biggest refactor)
- Core coaching hub feature
- Heavily used cot_observations table
- High user impact

**Backend Endpoints Needed:**
- `GET /api/observations` — List observations
- `POST /api/observations` — Create observation
- `GET /api/observations/{id}` — Get single observation
- `PATCH /api/observations/{id}/status` — Update status
- `PATCH /api/observations/{id}/rubric/hots` — Save HOTS scores
- `PATCH /api/observations/{id}/rubric/fico` — Save FICO scores
- `PATCH /api/observations/{id}/debrief` — Save debrief notes
- `DELETE /api/observations/{id}` — Delete observation

**Frontend Components to Refactor:**
CoachingHubTab, HotsRubricForm, FicoRubricForm, DebriefForm, SmartScheduleTab, DraftObservationsTab, NeoAnalysis, ScheduleDialog, QuickObservationPanel, ReportIssueButton, and 4 more...

---

## 📚 How to Use This Strategy

### For Project Managers
1. Read **SUPABASE_MIGRATION_INVENTORY.md** for scope
2. Review **API_MIGRATION_IMPLEMENTATION_PLAN.md** for timeline & resources
3. Use Phase breakdowns for sprint planning
4. Track success metrics from phase 5

### For Backend Engineers
1. Read **API_SPECIFICATION.md** for endpoint definitions
2. Follow code examples in **API_MIGRATION_IMPLEMENTATION_PLAN.md**
3. Implement per-phase according to detailed task breakdown
4. Use **TEST_STRATEGY.md** for unit + integration testing

### For Frontend Engineers
1. Review **API_SPECIFICATION.md** for request/response formats
2. Create API client classes (pattern in implementation plan)
3. Create custom hooks (useProfile, useObservations, etc.)
4. Refactor components to use hooks instead of Supabase directly
5. Follow E2E test patterns in **TEST_STRATEGY.md**

### For QA/Testers
1. Read **TEST_STRATEGY.md** for complete testing approach
2. Execute unit + integration + E2E tests per phase
3. Validate backward compatibility
4. Perform load testing (performance validation)

---

## 🔗 Related Documents

**In Root Directory:**
- `SUPABASE_MIGRATION_INVENTORY.md` — What & where
- `API_MIGRATION_IMPLEMENTATION_PLAN.md` — How & when
- `TEST_STRATEGY.md` — How to validate
- `MIGRATION_STRATEGY_INDEX.md` — This file (navigation)

**In Docs Directory:**
- `docs/API_SPECIFICATION.md` — Complete endpoint specs

**Quiz API Reference (Already Complete):**
- `QUIZ_API_IMPLEMENTATION_SUMMARY.md`
- `QUIZ_API_QUICKSTART.md`
- `QUIZ_API_VERIFICATION.md`
- `docs/QUIZ_API_INTEGRATION.md`
- `docs/QUIZ_API_USAGE_EXAMPLE.md`

---

## ✅ Checklist Before Starting Phase 1

- [ ] All 4 strategy documents reviewed and approved
- [ ] Team understands scope (50+ files, 8 tables)
- [ ] Project manager assigned timeline & resources
- [ ] Backend team lead assigned to Phase 1
- [ ] Frontend team lead assigned to Phase 1
- [ ] Test infrastructure ready (pytest, Vitest, Cypress)
- [ ] Feature branch created: `feature/api-migration-phase-1`
- [ ] Kick-off meeting scheduled
- [ ] Phase 1 start date set (Week of 2026-06-15)

---

## 🆘 Questions?

### High-Level Questions
→ Read **SUPABASE_MIGRATION_INVENTORY.md** (overview section)

### Technical Implementation
→ Read **API_MIGRATION_IMPLEMENTATION_PLAN.md** (detailed task breakdowns with code)

### API Design
→ Read **docs/API_SPECIFICATION.md** (endpoint definitions with examples)

### Testing Approach
→ Read **TEST_STRATEGY.md** (patterns and examples)

### Phase Status
→ Refer to **API_MIGRATION_IMPLEMENTATION_PLAN.md** (timeline section)

---

## 📝 Document History

| Date | Version | Changes |
|------|---------|---------|
| 2026-06-09 | 1.0 | Initial strategy complete (4 documents) |
| 2026-06-22 | 1.1 | Post-Phase 1 update (planned) |
| 2026-07-06 | 1.2 | Post-Phase 2 update (planned) |
| 2026-07-20 | 2.0 | Post-Phase 5, final (planned) |

---

## 🎯 Getting Started Now

**Immediate Actions (This Week):**
1. Read all 4 strategy documents (2-3 hours)
2. Schedule strategy review meeting with team
3. Answer clarifying questions
4. Approve scope and timeline
5. Create Phase 1 feature branch

**Next Week (Week of 2026-06-15):**
1. Phase 1 begins (Auth & Users)
2. Backend team: Create models, services, controllers
3. Frontend team: Create API client, hooks, refactor components
4. Both teams: Write unit + integration tests daily
5. Daily standup: 15 min sync on blockers

---

**Document Version:** 1.0  
**Last Updated:** 2026-06-09  
**Next Review:** Upon Phase 1 completion (2026-06-22)

---

**👉 Start with SUPABASE_MIGRATION_INVENTORY.md to understand scope**
