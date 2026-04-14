# CoachCert Implementation Roadmap — Sprint Planning

**Project Duration:** 10 weeks (70 working days)
**Team Size:** 6 people (2 Backend, 2 Frontend, 1 Analytics, 1 QA Lead)
**Start Date:** April 21, 2026 (after design approval)
**Soft Launch:** June 9, 2026 (Beta with 10% users)
**Full Launch:** June 23, 2026 (100% rollout)

---

## SPRINT BREAKDOWN

### SPRINT 1-2: Foundation (Apr 21 – May 5)

**Sprint Duration:** 2 weeks (10 working days)

#### Sprint Goals
- [ ] Database schema in staging
- [ ] Express API scaffolding
- [ ] Authentication working
- [ ] RBAC middleware functional
- [ ] 80%+ test coverage

#### Backend Tasks

**Task 1.1: PostgreSQL Schema (3 days)**
- [ ] Create all 10 core tables
- [ ] Add indexes for performance
- [ ] Create materialized views
- [ ] Set up partitioned analytics_events table
- [ ] Seed test data (100 scenarios, 500 test users)
- [ ] Verify query performance

**Task 1.2: Express.js API Setup (2 days)**
- [ ] Initialize project structure
- [ ] Install dependencies (express, pg, jwt, cors, etc)
- [ ] Configure middleware (logging, error handling, rate limiting)
- [ ] Set up environment configuration
- [ ] Create API versioning structure (/api/v1/)

**Task 1.3: Authentication Service (2 days)**
- [ ] JWT token generation/validation
- [ ] Refresh token logic
- [ ] Login/logout endpoints
- [ ] Password hashing (bcrypt)
- [ ] Session management

**Task 1.4: RBAC Middleware (2 days)**
- [ ] Implement role-based access control
- [ ] Permission checking middleware
- [ ] Role assignment endpoints
- [ ] Test RBAC across scenarios

**Task 1.5: Core Services (3 days)**
- [ ] UserService (CRUD, region assignment)
- [ ] ScenarioService (CRUD)
- [ ] ResponseService (record decisions)
- [ ] AuthService (tokens, refresh)

**Task 1.6: API Testing (2 days)**
- [ ] Unit tests for services
- [ ] Integration tests for endpoints
- [ ] Mock database for tests
- [ ] CI/CD pipeline (GitHub Actions)

#### Frontend Tasks

**Task 2.1: React Project Setup (1 day)**
- [ ] Create React app (Vite)
- [ ] Install UI library (shadcn/ui or Ant Design)
- [ ] Configure Tailwind CSS
- [ ] Set up project structure

**Task 2.2: Authentication UI (2 days)**
- [ ] Login page
- [ ] Signup page
- [ ] Token storage (localStorage/httpOnly)
- [ ] Redirect logic for unauthenticated users

**Task 2.3: Dashboard Layout (2 days)**
- [ ] Main navigation
- [ ] Sidebar (units, regions)
- [ ] Responsive grid layout
- [ ] Mobile-first design

**Task 2.4: Redux/State Management (2 days)**
- [ ] Redux store setup
- [ ] User slice (auth state)
- [ ] Scenario slice (current scenario, progress)
- [ ] Region slice (regional data)

**Task 2.5: API Integration (2 days)**
- [ ] Axios/fetch setup
- [ ] RTK Query for API calls
- [ ] Error handling (retry logic)
- [ ] Token refresh middleware

#### QA Tasks

**Task 3.1: Test Infrastructure (3 days)**
- [ ] Set up testing frameworks (Jest, React Testing Library, Cypress)
- [ ] Create test database
- [ ] Write test utilities
- [ ] Document testing standards

**Task 3.2: Initial Test Cases (2 days)**
- [ ] Authentication flow tests
- [ ] RBAC permission tests
- [ ] API endpoint tests

#### Deliverables
- [ ] PostgreSQL database live on staging
- [ ] 15+ working API endpoints
- [ ] Login/auth working end-to-end
- [ ] React app skeleton with routing
- [ ] All tests passing (80%+ coverage)
- [ ] GitHub Actions CI/CD configured

---

### SPRINT 3-4: Scenario-First Flow (May 6 – May 20)

**Sprint Duration:** 2 weeks (10 working days)

#### Sprint Goals
- [ ] Complete scenario viewing experience
- [ ] Decision submission + feedback
- [ ] Reveal slides working
- [ ] Optional depth (Read more) functional
- [ ] E2E tests passing

#### Backend Tasks

**Task 4.1: Scenario Endpoints (2 days)**
- [ ] GET /api/v1/scenarios/:id (with full details)
- [ ] GET /api/v1/units/:unitId/scenarios (list)
- [ ] POST /api/v1/scenarios (admin)
- [ ] PUT /api/v1/scenarios/:id (admin)
- [ ] Cache scenarios (Redis, 1-hour TTL)

**Task 4.2: Response Recording (2 days)**
- [ ] POST /api/v1/responses (submit decision)
- [ ] Validate choice against correct answer
- [ ] Calculate correctness
- [ ] Record time spent
- [ ] Emit analytics event

**Task 4.3: Analytics Event Pipeline (2 days)**
- [ ] Event logging system
- [ ] Write analytics events to partitioned table
- [ ] Clean up old events (retention policy)
- [ ] Implement event validation

**Task 4.4: Feedback Generation (1 day)**
- [ ] Build feedback object from scenario
- [ ] Include rationale + reveal slides
- [ ] Include optional deep content
- [ ] Test with various scenarios

**Task 4.5: API Testing (2 days)**
- [ ] Integration tests for all new endpoints
- [ ] Edge cases (invalid choices, timeout)
- [ ] Performance tests (response latency)

#### Frontend Tasks

**Task 5.1: ScenarioCard Component (2 days)**
- [ ] Display situation + question
- [ ] Option radio buttons (A/B/C/D)
- [ ] Submit button
- [ ] Loading state during submission
- [ ] Mobile-responsive design

**Task 5.2: FeedbackCard Component (2 days)**
- [ ] Show correct/incorrect verdict
- [ ] Display rationale
- [ ] Render reveal slides (carousel or steps)
- [ ] Conditional rendering based on correctness

**Task 5.3: RevealSlides Carousel (2 days)**
- [ ] Slide navigation (prev/next)
- [ ] Timer display (optional)
- [ ] Smooth transitions
- [ ] Accessible (keyboard navigation)

**Task 5.4: ExpandableDepth Component (1 day)**
- [ ] "Read more" toggle
- [ ] Lazy-load optional content
- [ ] Smooth expand/collapse animation
- [ ] Track expansion (analytics)

**Task 5.5: Scenario Flow Integration (2 days)**
- [ ] Wire all components together
- [ ] Manage scenario state (current, progress)
- [ ] Navigation between scenarios
- [ ] Progress indicator (X of 42 complete)

**Task 5.6: E2E Tests (2 days)**
- [ ] Full user flow: view scenario → decide → see feedback → read more
- [ ] Navigation backward/forward
- [ ] Timing accuracy
- [ ] Accessibility tests (axe)

#### Analytics Tasks

**Task 6.1: Event Tracking Setup (2 days)**
- [ ] Plan event structure
- [ ] Implement event logging in frontend
- [ ] Verify events reach backend
- [ ] Test data quality

#### Deliverables
- [ ] Complete scenario viewing UX
- [ ] Response submission working
- [ ] Feedback display with slides
- [ ] Optional depth functional
- [ ] E2E tests for full flow
- [ ] Analytics events flowing

---

### SPRINT 5-6: Analytics Dashboard (May 21 – Jun 4)

**Sprint Duration:** 2 weeks (10 working days)

#### Sprint Goals
- [ ] KPI summary cards
- [ ] Heatmap visualization
- [ ] Regional performance map
- [ ] Drill-down functionality
- [ ] Live updates (WebSocket)

#### Backend Tasks

**Task 7.1: Analytics Aggregation (3 days)**
- [ ] Create materialized views (user_engagement, scenario_performance, regional_summary)
- [ ] Implement refresh logic (every 30s)
- [ ] Optimize queries for large datasets
- [ ] Add caching layer (Redis)

**Task 7.2: Analytics API Endpoints (3 days)**
- [ ] GET /api/v1/analytics/dashboard
- [ ] GET /api/v1/analytics/scenarios
- [ ] GET /api/v1/analytics/regions
- [ ] GET /api/v1/analytics/users/:userId
- [ ] GET /api/v1/analytics/heatmap
- [ ] Implement filtering (region, time period, unit)

**Task 7.3: WebSocket Server (2 days)**
- [ ] Set up Socket.io or ws library
- [ ] Implement subscription/publish model
- [ ] Broadcast metrics updates
- [ ] Handle reconnections

**Task 7.4: Real-time Metrics (2 days)**
- [ ] Background job refreshes views every 30s
- [ ] Publishes updates to subscribed clients
- [ ] Implements fallback polling
- [ ] Monitor WebSocket performance

#### Frontend Tasks

**Task 8.1: KPI Components (2 days)**
- [ ] KPI card component
- [ ] Metric cards (total users, active, completion rate)
- [ ] Trend indicators (↑ ↓ →)
- [ ] Responsive grid layout

**Task 8.2: Charts & Visualizations (3 days)**
- [ ] Trend line chart (Recharts)
- [ ] Performance gauge (circular progress)
- [ ] Bar chart for performance breakdown
- [ ] Time series data

**Task 8.3: Heatmap Component (2 days)**
- [ ] Grid layout (Units × Scenarios)
- [ ] Color coding logic (green/yellow/red)
- [ ] Cell hover tooltip (details)
- [ ] Click to drill down

**Task 8.4: Regional Map (2 days)**
- [ ] Set up Leaflet or Mapbox
- [ ] Create interactive Pakistan map
- [ ] Add region markers with stats
- [ ] Implement click handlers

**Task 8.5: Drill-down Navigation (2 days)**
- [ ] Region → Users view
- [ ] Users → Units view
- [ ] Units → Scenarios view
- [ ] Breadcrumb navigation

**Task 8.6: Dashboard Integration (2 days)**
- [ ] Wire all components together
- [ ] Connect to WebSocket for live updates
- [ ] Implement filters (period, region)
- [ ] Responsive layout testing

#### QA Tasks

**Task 9.1: Dashboard Testing (2 days)**
- [ ] Visual regression tests (Percy or similar)
- [ ] Performance tests (dashboard load time)
- [ ] WebSocket stability tests
- [ ] Mobile responsiveness

#### Deliverables
- [ ] Full analytics dashboard
- [ ] Real-time KPI updates (WebSocket)
- [ ] Heatmap with drill-down
- [ ] Regional performance map
- [ ] Live metrics refreshing
- [ ] Export functionality (CSV)

---

### SPRINT 7: RBAC System (Jun 5 – Jun 11)

**Sprint Duration:** 1 week (5 working days)

#### Sprint Goals
- [ ] Role assignment UI
- [ ] Regional admin features
- [ ] Permission enforcement
- [ ] Audit logging

#### Backend Tasks

**Task 10.1: Role Management (2 days)**
- [ ] PUT /api/v1/users/:id/role (assign role)
- [ ] POST /api/v1/roles/:roleId/assign (bulk assign)
- [ ] GET /api/v1/users/:id/permissions
- [ ] Enforce RBAC in all endpoints

**Task 10.2: Regional Scoping (1 day)**
- [ ] Filter analytics by user's region
- [ ] Regional admin sees only their region data
- [ ] Implement in all queries

**Task 10.3: Audit Logging (1 day)**
- [ ] Create audit_log table
- [ ] Log role assignments
- [ ] Log permission changes
- [ ] API endpoint to view audit trail

**Task 10.4: Testing (1 day)**
- [ ] Test role-based access restrictions
- [ ] Verify regional scoping
- [ ] Audit log accuracy

#### Frontend Tasks

**Task 11.1: Role Management UI (2 days)**
- [ ] Admin page to assign roles
- [ ] Bulk import (CSV)
- [ ] User table with role selector
- [ ] Confirmation dialogs

**Task 11.2: Regional Admin Dashboard (1 day)**
- [ ] Filter all views by assigned region
- [ ] Limit user management to region
- [ ] Hide global analytics

**Task 11.3: Permission Gating (1 day)**
- [ ] Hide UI elements based on role
- [ ] Disable actions (buttons) for unauthorized users
- [ ] Show permission error messages

#### QA Tasks

**Task 12.1: RBAC Testing (1 day)**
- [ ] Permission matrix testing
- [ ] Regional scoping tests
- [ ] Audit trail accuracy

#### Deliverables
- [ ] Role assignment UI
- [ ] Regional admin features fully functional
- [ ] Audit logs working
- [ ] All RBAC tests passing

---

### SPRINT 8: Testing & QA (Jun 12 – Jun 18)

**Sprint Duration:** 1 week (5 working days)

#### Sprint Goals
- [ ] Load testing passed (1000+ concurrent)
- [ ] Security audit passed
- [ ] UAT feedback integrated
- [ ] Documentation complete

#### QA Tasks

**Task 13.1: Load Testing (2 days)**
- [ ] Simulate 1000 concurrent users
- [ ] Measure API response times
- [ ] Test analytics queries under load
- [ ] Test WebSocket under load
- [ ] Identify bottlenecks + optimize

**Task 13.2: Security Audit (2 days)**
- [ ] OWASP Top 10 review
- [ ] SQL injection tests
- [ ] XSS prevention verification
- [ ] Token security review
- [ ] Penetration testing (basic)

**Task 13.3: User Acceptance Testing (2 days)**
- [ ] Regional admins test dashboard
- [ ] Coaches test scenario flow
- [ ] Gather feedback + document issues
- [ ] Prioritize fixes

**Task 13.4: Bug Triage & Fixes (2 days)**
- [ ] Triage UAT findings
- [ ] Fix critical issues
- [ ] Retest fixes
- [ ] Create regression test cases

#### Backend/Frontend Tasks

**Task 14.1: Performance Optimization (2 days)**
- [ ] Optimize slow queries
- [ ] Implement Redis caching
- [ ] Code splitting (frontend)
- [ ] Image optimization
- [ ] Database indexing review

#### Deliverables
- [ ] Load testing report
- [ ] Security audit sign-off
- [ ] UAT feedback document
- [ ] All P0 & P1 bugs fixed
- [ ] Performance baselines established

---

### SPRINT 9: Migration & Documentation (Jun 19 – Jun 25)

**Sprint Duration:** 1 week (5 working days)

#### Sprint Goals
- [ ] Data migration verified
- [ ] Documentation complete
- [ ] Team trained
- [ ] Deployment plan finalized
- [ ] Go/No-go decision

#### Data Migration Tasks

**Task 15.1: Scenario Migration (1 day)**
- [ ] Extract scenarios from old format
- [ ] Transform to new schema
- [ ] Validate data integrity
- [ ] Rollback plan tested

**Task 15.2: Response Migration (1 day)**
- [ ] Migrate existing responses
- [ ] Verify counts match old system
- [ ] Backfill missing fields
- [ ] Test reporting accuracy

**Task 15.3: Feature Flag Setup (1 day)**
- [ ] Implement feature flag logic
- [ ] Set up rollout percentages
- [ ] Test canary deployment (10%)
- [ ] Monitoring/alerting configured

#### Documentation Tasks

**Task 16.1: Admin Guide (1 day)**
- [ ] Dashboard walkthrough
- [ ] RBAC setup guide
- [ ] Region management
- [ ] User import process

**Task 16.2: Coach Guide (1 day)**
- [ ] New learning flow explanation
- [ ] Screenshots & examples
- [ ] Accessibility features
- [ ] Troubleshooting

**Task 16.3: Technical Docs (1 day)**
- [ ] API documentation (Swagger/OpenAPI)
- [ ] Database schema documentation
- [ ] Deployment guide
- [ ] Monitoring/alerting setup

#### Training Tasks

**Task 17.1: Team Training (1 day)**
- [ ] Support team trained on new UI
- [ ] Customer success team learns RBAC
- [ ] Backend team reviews deployment checklist

#### Go/No-go Decision

**Criteria for Go:**
- [ ] All P0 bugs resolved
- [ ] Load testing passed (no errors at 1000 users)
- [ ] Security audit passed
- [ ] UAT sign-off
- [ ] Documentation complete
- [ ] Team trained

#### Deliverables
- [ ] Migration scripts tested
- [ ] Feature flags deployed
- [ ] Admin guide complete
- [ ] Coach guide complete
- [ ] Tech docs complete
- [ ] Team trained & ready
- [ ] Deployment checklist signed off

---

### SPRINT 10: Canary Rollout & Stabilization (Jun 26 – Jul 9)

**Sprint Duration:** 2 weeks (10 working days)

#### Week 1: Canary (10%)

**Day 1-3: Deploy & Monitor**
- [ ] Deploy to production (10% feature flag)
- [ ] Monitor error rates (target: <0.1%)
- [ ] Monitor performance (API latency, WebSocket)
- [ ] Check user feedback (support tickets)
- [ ] Daily standup to review metrics

**Day 4-5: Analyze & Decide**
- [ ] Analyze completion rate (target: >75%)
- [ ] Check for any critical issues
- [ ] Make go/no-go decision for 25% rollout

#### Week 2: Expansion & Full Rollout

**Day 6-8: Expand to 25%**
- [ ] Increase feature flag to 25%
- [ ] Monitor for 3 days
- [ ] Verify metrics improving
- [ ] Address any issues found

**Day 9-10: Expand to 100%**
- [ ] Full rollout to all users
- [ ] Monitor for 48 hours
- [ ] Disable old flow entirely
- [ ] Celebrate launch! 🎉

#### Monitoring & Support Tasks

**Task 18.1: Production Monitoring (10 days)**
- [ ] Real-time error rate monitoring
- [ ] API latency alerts
- [ ] WebSocket connection health
- [ ] Database query performance
- [ ] User engagement tracking

**Task 18.2: Incident Response (10 days)**
- [ ] On-call rotation
- [ ] Incident response playbook
- [ ] Quick fix deployment process
- [ ] Post-incident reviews

**Task 18.3: User Support (10 days)**
- [ ] Triage support tickets
- [ ] Escalate critical issues
- [ ] Communicate status updates
- [ ] Gather user feedback

#### Deliverables
- [ ] Live in production (10% → 25% → 100%)
- [ ] No critical issues during rollout
- [ ] All canary metrics green
- [ ] Old flow archived
- [ ] Users successfully transitioned
- [ ] Completion rate > 75%

---

## RESOURCE ALLOCATION

### Team Composition (6 people)

**Backend (2 people)**
- [ ] Senior Backend Engineer (APIs, database, architecture)
- [ ] Backend Engineer (services, analytics, DevOps)

**Frontend (2 people)**
- [ ] Senior Frontend Engineer (UX, components, state management)
- [ ] Frontend Engineer (UI components, testing, accessibility)

**Analytics (1 person)**
- [ ] Analytics Engineer (metrics design, dashboards, A/B testing)

**QA (1 person)**
- [ ] QA Lead (testing strategy, automation, load testing)

### Capacity Planning

```
Sprint 1-2 (Foundation):
  - Backend: 100% on API + Database
  - Frontend: 100% on setup + auth
  - Analytics: 50% on event planning
  - QA: 100% on test infrastructure

Sprint 3-4 (Scenario Flow):
  - Backend: 100% on scenario + response endpoints
  - Frontend: 100% on scenario UI
  - Analytics: 50% on event tracking
  - QA: 100% on E2E testing

Sprint 5-6 (Analytics Dashboard):
  - Backend: 50% on analytics API + WebSocket
  - Frontend: 100% on dashboard UI
  - Analytics: 100% on dashboard design
  - QA: 100% on dashboard testing

Sprint 7 (RBAC):
  - Backend: 100% on role management
  - Frontend: 100% on admin UI
  - QA: 100% on permission testing

Sprint 8 (Testing):
  - Backend: 50% on optimization
  - Frontend: 50% on optimization
  - Analytics: 50% on performance
  - QA: 100% on load/security testing

Sprint 9-10 (Migration & Rollout):
  - Backend: 50% on deployment
  - Frontend: 50% on monitoring
  - Analytics: 100% on A/B testing setup
  - QA: 100% on production support
```

---

## RISKS & MITIGATION

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|-----------|
| Analytics queries slow on large dataset | High | Medium | Pre-calculate metrics, use materialized views, test with 1M events |
| WebSocket connection instability | High | Low | Implement polling fallback, connection retry logic |
| RBAC implementation incomplete | Medium | Low | Use established RBAC library (keycloak or passport.js) |
| Data migration loses response data | Critical | Very Low | Backup old DB, run migration twice, validate counts |
| Old flow regression issues | Medium | Low | Keep old code in git, have rollback plan ready |
| Team knowledge gaps | Medium | Medium | Documentation, code reviews, pair programming |

---

## SUCCESS METRICS

### Launch Success
- ✅ 0 critical bugs during canary (10% rollout)
- ✅ Completion rate > 75% (vs 68% in old flow)
- ✅ Time to decision < 60s (vs 120s in old flow)
- ✅ Drop-off rate < 15% (vs 30% in old flow)

### 30-Day Post-Launch
- ✅ Engagement metrics sustained or improved
- ✅ Regional admins report positive experience
- ✅ Support ticket volume < 5 per day
- ✅ Zero critical production incidents

### 90-Day Post-Launch
- ✅ A/B test shows statistical significance (p < 0.05)
- ✅ Learning effectiveness improved (assessment scores ↑ 10%)
- ✅ User retention improved
- ✅ NPS score > 40 (coaches satisfaction)

---

## BUDGET & TIMELINE

**Total Duration:** 10 weeks
**Team Size:** 6 people
**Estimated Cost:** ~$450K - $600K (salaries, infrastructure, tools)

**Breakdown:**
- Salaries: ~$400K (6 people × 10 weeks)
- Infrastructure (AWS): ~$5K
- Tools (monitoring, analytics): ~$3K
- Contingency (15%): ~$65K

**ROI Expected:**
- Engagement ↑ 40–50%
- Time-to-effectiveness ↓ 30%
- Support cost ↓ 20%
- User satisfaction ↑ 25%

---

**Document Version:** 1.0
**Last Updated:** April 13, 2026
**Status:** Ready for Sprint Execution
