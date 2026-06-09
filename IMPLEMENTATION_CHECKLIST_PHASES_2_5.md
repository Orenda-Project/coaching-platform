# Implementation Checklist: Phases 2-5

**Use this to track progress across all phases. Update daily.**

---

## Phase 2: Assessment & Training APIs (Team 1)

**Target:** 2 weeks (June 10-24, 2026)  
**Owner:** Team 1 (Backend Dev + Frontend Dev)  
**Tests:** 40+ tests  
**Status:** ⏳ Ready to start

### Week 1: Models + Services

- [ ] **Day 1-2: Assessment Models & Service**
  - [ ] Create `app/models/assessment.py` with Assessment, AssessmentResponse, AssessmentAttempt models
  - [ ] Create `app/services/assessment_service.py` with 8 business logic methods
  - [ ] Write unit tests (12+ tests)
  - [ ] All tests passing
  - [ ] Commit: `feat(backend): assessment models and service`

- [ ] **Day 3-4: Training Models & Service**
  - [ ] Create `app/models/training.py` with Training, TrainingProgress, TrainingContent models
  - [ ] Create `app/services/training_service.py` with 4 business logic methods
  - [ ] Write unit tests (8+ tests)
  - [ ] All tests passing
  - [ ] Commit: `feat(backend): training models and service`

- [ ] **Day 5: Integration Check**
  - [ ] Both services working independently
  - [ ] 20+ unit tests passing
  - [ ] Database migrations working locally
  - [ ] Post update in #coaching-api-migration
  - [ ] Ready for Week 2

### Week 2: Controllers + Frontend

- [ ] **Day 1-2: Assessment Controller & Frontend**
  - [ ] Create `app/controllers/assessment_controller.py` with 8 endpoints
  - [ ] Register routes in `main.py`
  - [ ] Manual endpoint testing (curl or Postman)
  - [ ] Create `src/lib/apiClients/assessmentApiClient.ts` (12 methods)
  - [ ] Create `src/lib/apiClients/__tests__/assessmentApiClient.test.ts` (15+ tests)
  - [ ] Create `src/hooks/useAssessment.ts` (React hook)
  - [ ] Create `src/hooks/__tests__/useAssessment.test.ts` (12+ tests)
  - [ ] Refactor `src/pages/Assessment.tsx` to use hook
  - [ ] All tests passing (25+ tests)
  - [ ] Commit: `feat(frontend): assessment API client and hook`

- [ ] **Day 3-4: Training Controller & Frontend**
  - [ ] Create `app/controllers/training_controller.py` with 4 endpoints
  - [ ] Register routes in `main.py`
  - [ ] Manual endpoint testing
  - [ ] Create `src/lib/apiClients/trainingApiClient.ts` (8 methods)
  - [ ] Create `src/hooks/useTraining.ts` (React hook)
  - [ ] Refactor `src/pages/TrainingModule.tsx` to use hook
  - [ ] Refactor `src/pages/admin/AdminModules.tsx`
  - [ ] Refactor `src/pages/admin/AdminTrainings.tsx`
  - [ ] All tests passing (12+ tests)
  - [ ] Commit: `feat(frontend): training API client and hook`

- [ ] **Day 5: Finalization**
  - [ ] All 12 endpoints working
  - [ ] All 40+ tests passing
  - [ ] Code reviewed by Team 2
  - [ ] Documentation complete
  - [ ] Ready for staging
  - [ ] Final commit: `docs: phase 2 complete and ready for staging`

### Definition of Done (Phase 2)
- [ ] 12 endpoints implemented and tested
- [ ] 40+ tests passing (>95% coverage)
- [ ] 4 frontend files refactored
- [ ] Documentation complete
- [ ] Code reviewed
- [ ] Zero blockers
- [ ] Ready for staging deployment

---

## Phase 3: Observations & Coaching APIs (Team 2)

**Target:** 2+ weeks (June 10-July 5, 2026)  
**Owner:** Team 2 (Backend Dev + Frontend Dev)  
**Tests:** 50+ tests  
**Complexity:** HIGHEST  
**Status:** ⏳ Ready to start

### Week 1: Models + Services

- [ ] **Day 1-2: Observation Models & Service**
  - [ ] Create `app/models/observation.py` with Observation, COTObservation, ObservationNotes models
  - [ ] Create `app/services/observation_service.py` with 8 business logic methods
  - [ ] Write unit tests (15+ tests)
  - [ ] All tests passing
  - [ ] Commit: `feat(backend): observation models and service`

- [ ] **Day 3-4: Coaching Models & Service**
  - [ ] Create `app/models/coaching.py` with CoachingSession, Feedback, SessionNote models
  - [ ] Create `app/services/coaching_service.py` with 4 business logic methods
  - [ ] Write unit tests (10+ tests)
  - [ ] All tests passing
  - [ ] Commit: `feat(backend): coaching models and service`

- [ ] **Day 5: Integration Check**
  - [ ] Both services working independently
  - [ ] 25+ unit tests passing
  - [ ] Database migrations working locally
  - [ ] Post update in #coaching-api-migration
  - [ ] Ready for Week 2

### Week 2: Controllers + Frontend

- [ ] **Day 1-2: Observation Controller & Frontend**
  - [ ] Create `app/controllers/observation_controller.py` with 8 endpoints
  - [ ] Register routes in `main.py`
  - [ ] Manual endpoint testing
  - [ ] Create `src/lib/apiClients/observationApiClient.ts` (12 methods)
  - [ ] Create `src/lib/apiClients/__tests__/observationApiClient.test.ts` (18+ tests)
  - [ ] Create `src/hooks/useObservation.ts` (React hook)
  - [ ] Create `src/hooks/__tests__/useObservation.test.ts` (15+ tests)
  - [ ] All tests passing (33+ tests)
  - [ ] Commit: `feat(frontend): observation API client and hook`

- [ ] **Day 3-4: Coaching Controller & Refactor**
  - [ ] Create `app/controllers/coaching_controller.py` with 4 endpoints
  - [ ] Register routes in `main.py`
  - [ ] Manual endpoint testing
  - [ ] Refactor `src/components/observation/CoachingHubTab.tsx` to use API
  - [ ] Refactor `src/components/observation/SmartScheduleTab.tsx`
  - [ ] Refactor `src/components/observation/FourWeekOverview.tsx`
  - [ ] Create integration tests (17+ tests)
  - [ ] All tests passing (17+ tests)
  - [ ] Commit: `feat(frontend): coaching workflows refactored to use API`

- [ ] **Day 5: Finalization**
  - [ ] All 12 endpoints working
  - [ ] All 50+ tests passing
  - [ ] 3 major files refactored
  - [ ] Code reviewed by Team 1
  - [ ] Documentation complete
  - [ ] Ready for staging
  - [ ] Final commit: `docs: phase 3 complete and ready for staging`

### Definition of Done (Phase 3)
- [ ] 12 endpoints implemented and tested
- [ ] 50+ tests passing (>95% coverage)
- [ ] 3 major frontend files refactored
- [ ] Documentation complete
- [ ] Code reviewed
- [ ] Zero blockers
- [ ] Ready for staging deployment

---

## Phase 4: Analytics & Scenarios APIs (Team 1)

**Target:** 1 week (June 24-July 1, 2026)  
**Owner:** Team 1 (after Phase 2)  
**Tests:** 35+ tests  
**Status:** ⏳ Pending Phase 2

### Implementation

- [ ] **Day 1-2: Models & Services**
  - [ ] Create `app/models/analytics.py` and `app/models/scenario.py`
  - [ ] Create `app/services/analytics_service.py` (5 methods)
  - [ ] Create `app/services/scenario_service.py` (5 methods)
  - [ ] Write unit tests (18+ tests)
  - [ ] All tests passing
  - [ ] Commit: `feat(backend): analytics and scenario models/services`

- [ ] **Day 3: Controllers & API**
  - [ ] Create `app/controllers/analytics_controller.py` with 5 endpoints
  - [ ] Create `app/controllers/scenario_controller.py` with 5 endpoints
  - [ ] Register routes in `main.py`
  - [ ] Manual endpoint testing
  - [ ] Commit: `feat(backend): analytics and scenario controllers`

- [ ] **Day 4: Frontend**
  - [ ] Create `src/lib/apiClients/analyticsApiClient.ts` (8 methods)
  - [ ] Create `src/lib/apiClients/scenarioApiClient.ts` (8 methods)
  - [ ] Create `src/hooks/useAnalytics.ts` and `useScenario.ts`
  - [ ] Write tests (17+ tests)
  - [ ] All tests passing
  - [ ] Commit: `feat(frontend): analytics and scenario API clients and hooks`

- [ ] **Day 5: Finalization**
  - [ ] All 10 endpoints working
  - [ ] All 35+ tests passing
  - [ ] Code reviewed
  - [ ] Documentation complete
  - [ ] Ready for staging

### Definition of Done (Phase 4)
- [ ] 10 endpoints implemented and tested
- [ ] 35+ tests passing (>95% coverage)
- [ ] 2 API clients + 2 hooks working
- [ ] Documentation complete
- [ ] Zero blockers
- [ ] Ready for staging deployment

---

## Phase 5: Admin Management APIs (Team 2)

**Target:** 1 week (July 1-8, 2026)  
**Owner:** Team 2 (after Phase 3)  
**Tests:** 30+ tests  
**Status:** ⏳ Pending Phase 3

### Implementation

- [ ] **Day 1-2: Models & Service**
  - [ ] Create `app/models/admin.py` with Admin-specific models
  - [ ] Create `app/services/admin_service.py` with 12 business logic methods
  - [ ] Write unit tests (15+ tests)
  - [ ] All tests passing
  - [ ] Commit: `feat(backend): admin service and models`

- [ ] **Day 3: Controller**
  - [ ] Create `app/controllers/admin_controller.py` with 12 endpoints
  - [ ] Register routes in `main.py`
  - [ ] Manual endpoint testing
  - [ ] Commit: `feat(backend): admin controller with 12 endpoints`

- [ ] **Day 4: Frontend**
  - [ ] Create `src/lib/apiClients/adminApiClient.ts` (12 methods)
  - [ ] Create `src/hooks/useAdmin.ts` (React hook)
  - [ ] Write tests (15+ tests)
  - [ ] All tests passing
  - [ ] Commit: `feat(frontend): admin API client and hook`

- [ ] **Day 5: Finalization**
  - [ ] All 12 endpoints working
  - [ ] All 30+ tests passing
  - [ ] Code reviewed
  - [ ] Documentation complete
  - [ ] Ready for staging

### Definition of Done (Phase 5)
- [ ] 12 endpoints implemented and tested
- [ ] 30+ tests passing (>95% coverage)
- [ ] Admin client + hook working
- [ ] Documentation complete
- [ ] Zero blockers
- [ ] Ready for staging deployment

---

## QA & Deployment (Team QA)

**Target:** Weeks 4-5 (July 1-12, 2026)

### Week 4: Integration & E2E Testing

- [ ] **Integration Test Suite**
  - [ ] Set up Cypress for E2E testing
  - [ ] Write E2E tests for complete user flow:
    - [ ] Auth flow (Phase 1)
    - [ ] Assessment flow (Phase 2)
    - [ ] Training flow (Phase 2)
    - [ ] Observation flow (Phase 3)
    - [ ] Coaching flow (Phase 3)
    - [ ] Analytics view (Phase 4)
    - [ ] Scenario flow (Phase 4)
    - [ ] Admin operations (Phase 5)
  - [ ] All E2E tests passing
  - [ ] Commit: `test: end-to-end test suite for all phases`

- [ ] **Performance Benchmarking**
  - [ ] Load test all endpoints
  - [ ] Measure response times
  - [ ] Measure database query performance
  - [ ] Document baseline metrics
  - [ ] Commit: `docs: performance benchmarks for all phases`

- [ ] **Staging Deployment**
  - [ ] Deploy all phases to staging
  - [ ] Run full E2E test suite on staging
  - [ ] Verify all endpoints working
  - [ ] Get product sign-off
  - [ ] Create deployment guide

### Week 5: Production Deployment

- [ ] **Pre-Production Checklist**
  - [ ] Back up Supabase
  - [ ] Back up PostgreSQL
  - [ ] Create rollback plan
  - [ ] Final E2E testing on staging

- [ ] **Production Deployment**
  - [ ] Deploy all phases to production
  - [ ] Monitor 100% traffic for 24 hours
  - [ ] Verify all endpoints responding
  - [ ] Check error rates & latency
  - [ ] Get sign-off from engineering lead

- [ ] **Supabase Decommission**
  - [ ] Confirm all traffic routing through APIs
  - [ ] Disable Supabase calls in frontend
  - [ ] Archive Supabase project
  - [ ] Final success report

### Definition of Done (QA)
- [ ] All E2E tests passing
- [ ] Performance benchmarks documented
- [ ] Staging deployment successful
- [ ] Production deployment successful
- [ ] Supabase decommissioned
- [ ] All teams sign off

---

## Cross-Phase Milestones

### End of Week 1 (June 14)
- [ ] Phase 2 models + services complete (Team 1)
- [ ] Phase 3 models + services complete (Team 2)
- [ ] 45+ unit tests passing
- [ ] No critical blockers
- [ ] Weekly sync completed

### End of Week 2 (June 21)
- [ ] Phase 2 complete + ready for staging (Team 1)
- [ ] Phase 3 controllers + frontend started (Team 2)
- [ ] 90+ tests passing (40 Phase 2 + 50 Phase 3)
- [ ] Code reviews all complete
- [ ] Weekly sync completed

### End of Week 3 (June 28)
- [ ] Phase 3 complete + ready for staging (Team 2)
- [ ] Phase 4 started (Team 1)
- [ ] 125+ tests passing (40 + 50 + 35)
- [ ] All phases have green CI/CD
- [ ] Weekly sync completed

### End of Week 4 (July 5)
- [ ] Phase 4 complete (Team 1)
- [ ] Phase 5 complete (Team 2)
- [ ] QA integration testing underway
- [ ] 155+ tests passing (all phases)
- [ ] Staging deployment in progress

### End of Week 5 (July 12)
- [ ] All phases deployed to staging ✅
- [ ] E2E tests passing ✅
- [ ] Production deployment complete ✅
- [ ] Supabase decommissioned ✅
- [ ] All teams sign off ✅

---

## Daily Standup Template

**Post in #coaching-api-migration at EOD (end of day):**

```
📊 Phase [2/3/4/5] Daily Update - [Date]

✅ Completed today:
- [Task 1]
- [Task 2]

📌 Working on tomorrow:
- [Task 1]
- [Task 2]

🚨 Blockers:
- [If any, describe and request help]

📈 Test status: X/Y passing
🔗 Latest commit: [commit hash]
```

---

## Weekly Sync Agenda (Every Friday 2 PM)

1. **Phase 2 Status** (5 min)
2. **Phase 3 Status** (5 min)
3. **Phase 4 Status** (5 min)
4. **Phase 5 Status** (5 min)
5. **Blockers & Risks** (10 min)
6. **Next Week Plan** (5 min)

---

## Success Criteria (Final)

- [ ] **Phase 2:** 12 endpoints, 40+ tests, 4 files refactored ✅
- [ ] **Phase 3:** 12 endpoints, 50+ tests, 3 files refactored ✅
- [ ] **Phase 4:** 10 endpoints, 35+ tests ✅
- [ ] **Phase 5:** 12 endpoints, 30+ tests ✅
- [ ] **Total:** 46 endpoints, 155+ tests, 45 files refactored ✅
- [ ] **Staging Deployment:** Successful ✅
- [ ] **Production Deployment:** Successful ✅
- [ ] **Supabase Decommissioned:** Complete ✅
- [ ] **All Teams Sign Off:** Yes ✅

---

**Print this and check off each item as you go. Update daily.**

**Questions?** See TEAM_HANDOFF_PHASES_2_5.md → "Getting Help" section
