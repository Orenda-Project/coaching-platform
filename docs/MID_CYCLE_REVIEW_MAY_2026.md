# Mid-Cycle Review: RABT Coaching Platform
**Review Date:** 19th May 2026
**Reporting Period:** April 1 - May 19, 2026
**Team Lead:** Jalal Khan (jalal.khan@taleemabad.com)
**Stakeholders:** Team Punjab, Training Team, Taleemabad Leadership

---

## Executive Summary

The RABT (Coaching Platform) is **on track** to meet Q2 goals. Core platform is fully functional with all 6 modules deployed, baseline/endline assessments working, and coach vacation engagement feature active. Platform is being prepared for handover to Team Punjab as a service offering. Key blockers are dashboard UX refinements, Railway-to-Taleemabad account migration, and Urdu translations.

**ROCK Goal Status:** By end of Q2, 60% of trained coaches improve at least one level on the coaching rubric.
- **Progress:** Coaching platform foundation complete. Vacation engagement period (May 15 - June 15) is data collection phase. Post-vacation analysis will determine rubric improvement.

---

## What's Working Well 🎯

### ✅ Core Platform Complete
- **All 6 Modules Deployed:** Foundation, Partnership, Mirror, Digital, Catalyst, Excellence
- **End-to-End Flow Operational:** Signup → Baseline → Modules → Endline → Certificate
- **Baseline/Endline Assessments:** Both working with persona assignment (Persona A-E based on baseline score)
- **Module Content:** All units, slides, scenarios, and quizzes populated
- **Quiz System:** 20 questions per module (16 MCQs + 4 scenario-based with options)
- **Analytics Tracking:** User engagement, module completion, quiz attempts, DAU/WAU metrics

### ✅ Coach Features Launched
- **Coach Vacation Engagement Active:** 33 coaches can access all 6 modules (May 15 - June 15)
- **Bulk Coach Enrollment:** SQL-based system to enroll/remove coaches without code changes
- **Data-Driven Coaching:** Full analytics capture on coach engagement during vacation period
- **Reversible Rollback:** Feature completely removable on June 15 with zero data loss

### ✅ Feedback Mechanism Implemented
- **In-App Feedback Collection:** Coaches can submit feedback from dashboard
- **Feedback Dashboard View:** Admins can review collected feedback
- **Data Preserved:** All feedback entries stored and analyzable

### ✅ Content & UX Improvements (Based on RM Feedback)
- **Baseline Reduced to 18 Questions:** From initial 30, based on RM usability testing
- **Slide Lock Feature:** 30-second read timer on slides before quiz button enables
- **Simple UI for Non-Technical Users:** No jargon, clear instructions, step-by-step flow
- **User-Friendly Flow:** Matches Google Sheets simplicity (row → column data display)

### ✅ Signup & Profile Management
- **Fixed Name Registration Bug:** Users can now set and view their name in profile
- **Profile Editing:** Coaches can update personal information
- **Role Management:** Coach role assignment working correctly

---

## Current Blockers 🚧

### 🔴 HIGH PRIORITY

1. **Dashboard UX Refinement — In Progress**
   - **What's Needed:** Restructure dashboard to show:
     - Coach Name, Region, Schools, Persona, Baseline Score, Endline Score, Tab Switch Count
     - Collapsible "Details" card showing: Module progress, units passed, module-wise quiz scores, tab switches per module
     - Separate tabs for Baseline (one-time) and Endline (one-time)
     - Module-by-module breakdown (units completed, quiz score, tab switches)
   - **Impact:** Coaches need clear visibility into their progress; admins need detailed reporting
   - **Timeline:** Needed before mass rollout to Team Punjab

2. **Railway to Taleemabad Account Migration — Pending**
   - **What's Needed:** Move all deployments from personal Railway account to Taleemabad corporate account
   - **Current Status:** Staging and production still on personal Railway account
   - **Impact:** Security, ownership, team access, billing
   - **Timeline:** Required before handover to Team Punjab
   - **Dependencies:** Need Taleemabad Railway account setup and permissions

3. **Urdu Translations — In Progress**
   - **What's Needed:** Translate all training content (slides, scenarios, quiz questions) to Urdu
   - **Scope:** All 6 modules, all units, all scenarios, feedback mechanism
   - **Impact:** Essential for reaching Urdu-speaking coaches in Team Punjab
   - **Timeline:** Required before Team Punjab rollout

### 🟡 MEDIUM PRIORITY

4. **E2E Testing with Chrome MCP — Pending**
   - **What's Needed:** Automated browser testing of complete flow (signup → baseline → modules → endline → certificate)
   - **Impact:** Ensure no regressions as features are added; catch bugs before production
   - **Timeline:** Should run before next major release

5. **Baseline Parameters Fine-Tuning — Pending**
   - **Current:** Pass threshold 0%, time needed ~10 minutes, 30 questions
   - **Requested:** Remove "Pass threshold 0%" messaging, increase time to 15 minutes
   - **Rationale:** Clearer expectations, coaches won't feel they "passed" if baseline is just assessment
   - **Impact:** Reduces confusion about baseline purpose
   - **Timeline:** Before Team Punjab rollout

6. **Scheduler Integration Discussion — Pending**
   - **What's Needed:** Clarify with Mashhood/Amena whether to integrate scheduler or offer as separate service
   - **Current Status:** Not yet discussed
   - **Impact:** Determines if coaches can schedule training sessions within RABT or use external tool
   - **Timeline:** Decision needed by end of May

---

## Completed Work (April - May 2026)

### Delivered Features

| Date | Feature | Status | Notes |
|------|---------|--------|-------|
| 04/07 | All 6 Modules Completed | ✅ Done | Foundation through Excellence fully built |
| 04/10 | End-to-End Flow (1 module) | ✅ Done | Signup → baseline → module → endline → cert working |
| 04/23 | Baseline Reduced to 18 Questions | ✅ Done | Based on RM feedback, faster assessment |
| 04/23 | Slide Lock (30s timer) | ✅ Done | Users must read slides before proceeding |
| 04/23 | Quiz System 20 Questions (16 MCQ + 4 Scenario) | ✅ Done | All modules updated with new question format |
| 04/27 | App Renamed to RABT | ✅ Done | Updated branding across platform |
| 04/27 | Baseline Persona Assignment | ✅ Done | Removed 60% pass threshold, all users assigned persona A-E |
| 04/27 | Feedback Mechanism | ✅ Done | In-app feedback collection + dashboard view |
| 05/06 | Full Module Data Population | ✅ Done | All units, slides, scenarios, quizzes loaded |
| 05/06 | Bug Fix: Signup Error | ✅ Done | Fixed "Database error saving new user" on signup |
| 05/15 | Coach Vacation Engagement Feature | ✅ Done | 33 coaches enrolled, all 6 modules visible until 06/15 |
| 05/15 | Bulk Coach Enrollment System | ✅ Done | SQL-based coach role assignment/removal |

### Code & Infrastructure Improvements

| Item | Status | Details |
|------|--------|---------|
| Database Schema | ✅ Complete | 6 new tables (scenarios, analytics, regions, etc.) with RLS policies |
| React Components | ✅ Complete | ScenarioCard, FeedbackCard, RevealSlides, ExpandableDepth, Profile |
| Admin Pages | ✅ Complete | Scenario management, region management, coach enrollment |
| Analytics Hook | ✅ Complete | Fire-and-forget event tracking (scenario_viewed, decision_submitted, etc.) |
| Type Safety | ✅ Complete | TypeScript strict mode, Supabase types regenerated |
| Testing | ✅ In Progress | Coach module access tests passing, signup tests passing |
| CI/CD | ✅ Complete | GitHub Actions auto-applies migrations on deploy |

---

## Next Steps & Action Items 📋

### Critical Path (Must Complete Before Team Punjab Handover)

| Action | Owner | Due Date | Priority | Status |
|--------|-------|----------|----------|--------|
| **Dashboard UX Overhaul** — Implement coach name, region, persona, module breakdown, expandable details | Jalal | May 31, 2026 | CRITICAL | In Progress |
| **Migrate Railway to Taleemabad Account** — Move staging & production deployments | Jalal | May 28, 2026 | CRITICAL | Pending |
| **Urdu Translation** — Translate all slides, scenarios, quizzes, UI text | Jalal + Team | May 31, 2026 | CRITICAL | In Progress |
| **Baseline Parameters** — Remove "pass threshold 0%" messaging, set time to 15 mins | Jalal | May 25, 2026 | HIGH | Pending |
| **Scheduler Integration Decision** — Meet with Mashhood/Amena to finalize approach | Jalal | May 26, 2026 | HIGH | Pending |
| **E2E Test Automation** — Set up Chrome MCP testing for full flow | Jalal | June 5, 2026 | HIGH | Pending |

### Coach Vacation Engagement Tracking

| Action | Owner | Due Date | Purpose |
|--------|-------|----------|---------|
| Monitor coach engagement metrics | Jalal | May 31, 2026 | Mid-vacation checkpoint — see if coaches are using all 6 modules |
| Prepare rollback notification | Jalal | June 10, 2026 | Alert coaches that vacation access ends June 15 |
| Execute rollback & verify | Jalal | June 15, 2026 | Remove coach roles, confirm persona-based filtering restored |
| Analyze vacation engagement data | Jalal | June 20, 2026 | Assess impact on coaching rubric improvement goal |

### Data Handover to Team Punjab

| Action | Owner | Due Date | Purpose |
|--------|-------|----------|---------|
| Prepare Team Punjab onboarding docs | Jalal | May 30, 2026 | Coach-friendly guides, admin guides, troubleshooting |
| Discuss "as a service" model | Jalal + Team Punjab | May 28, 2026 | Clarify SLAs, support, data ownership, tracking APIs |
| Set up Team Punjab deployment environment | Jalal | June 1, 2026 | Separate staging & prod for their coaches |
| Transition tracking API documentation | Jalal | June 5, 2026 | Provide APIs for DAU/WAU, module completion, usage queries |

---

## Adjustments to Plan ⚙️

### Scope Changes
- **Baseline Questions:** Reduced from 30 to 18 questions based on RM usability feedback (faster, clearer assessment)
- **Quiz Questions:** Standardized to 20 per module (16 MCQs + 4 scenario-based) across all modules
- **Coach Feature:** Kept minimal and reversible (database-level feature flag, no code changes)
- **App Branding:** Renamed from "Coaching Platform" to "RABT" per stakeholder request

### Timeline Adjustments
- **Original Plan:** Modules ready by April 10
- **Actual Delivery:** All modules fully functional by May 6 (slightly delayed for content quality)
- **Coach Feature:** Moved to May 15 start (aligned with vacation engagement window)
- **Handover:** Team Punjab transition moved to late May/early June (was end of Q2)

### Approach Changes
- **Coach Role Assignment:** Switched from user-type system to SQL-based role assignment (cleaner, reversible, no code deploys)
- **Feedback Mechanism:** Built in-app instead of external Google Form (better data ownership, simpler UX)
- **Infrastructure:** Planning shift from personal Railway to Taleemabad corporate account (security, ownership)

---

## Progress Against ROCK Goal

**Goal:** By end of Q2, 60% of trained coaches improve at least one level on the coaching rubric.

### Current Status: Data Collection Phase

| Phase | Timeline | Status | Details |
|-------|----------|--------|---------|
| **Phase 1: Platform Build** | April - May 15 | ✅ Complete | All 6 modules, full feature set, ready for coaches |
| **Phase 2: Vacation Engagement** | May 15 - June 15 | 🔄 In Progress | 33 coaches accessing all modules, engagement metrics collected |
| **Phase 3: Data Analysis** | June 16 - June 30 | ⏳ Pending | Analyze coaching rubric scores post-vacation, measure improvement % |
| **Phase 4: Iteration** | July+ | ⏳ Pending | Refine coaching curriculum based on Phase 3 learnings |

### Key Metrics We're Tracking

**During Vacation Engagement (May 15 - June 15):**
- Module completion rate by coach
- Time spent per module
- Quiz attempt count & scores
- Tab switch incidents (anti-cheat monitoring)
- Feedback comments from coaches

**Post-Vacation (June 20):**
- Baseline → current coaching rubric score change
- % of coaches improving by 1+ levels
- Correlation between module engagement and rubric improvement
- Content gaps (low-scoring scenarios/modules)

---

## Risk Assessment

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|-----------|
| **Team Punjab adoption delay** | Medium | High | Regular sync meetings, clear onboarding docs, dedicated support contact |
| **Urdu translation quality issues** | Medium | Medium | Native speaker review, QA testing with team, iterate quickly |
| **Baseline/Endline data loss on migration** | Low | Critical | Full data backup before Railway migration, test restore procedure |
| **Coach engagement below 50%** | Medium | High | Analyze barriers (time, content, accessibility), adjust Phase 2 in real-time |
| **Rollback on June 15 fails** | Low | High | Test rollback in staging first, have manual restore procedure, communicate timeline |

---

## Resources & Access

### Live Environments
- **Staging App:** https://coaching-platform-staging.railway.app/
- **Production App:** (URL in ENVIRONMENT_SUMMARY.md)
- **Database (Supabase):** Project `agziuwqpkfmxtospfxns`
  - Staging DB: agziuwqpkfmxtospfxns
  - Production DB: agziuwqpkfmxtospfxns (same project, different branch)

### Key Documentation
- **Coach Vacation Engagement:** `/docs/COACH_VACATION_ENGAGEMENT.md`
- **Bulk Coach Enrollment:** `/docs/BULK_COACH_ENROLLMENT.md`
- **Rollback Procedure:** `/docs/COACH_VACATION_ROLLBACK_PROCEDURE.md`
- **Architecture Overview:** `/docs/COACHING_PLATFORM_ARCHITECTURE.md`
- **Development Standards:** `/DEVELOPMENT_STANDARDS.md`
- **Platform Map:** `/PROJECT_MAP.md`

### Team Contacts
- **Primary Dev Lead:** Jalal Khan (jalal.khan@taleemabad.com)
- **Training Team Liaison:** (Contact TBD)
- **Team Punjab Lead:** (Contact TBD)
- **Scheduler Integration:** Mashhood/Amena (Contact TBD)

---

## Technical Debt & Opportunities

### Short-Term (Before Handover)
- [ ] Dashboard pagination for large coach lists
- [ ] Search/filter coaches by region, school, persona
- [ ] Bulk export analytics data for Team Punjab

### Medium-Term (Q3)
- [ ] Regional admin dashboard (manage coaches by region)
- [ ] Advanced analytics (materialized views for performance)
- [ ] Mobile-responsive design refinement
- [ ] Caching strategies for scenarios/options

### Long-Term (Q4+)
- [ ] AI-powered coaching suggestions (based on quiz patterns)
- [ ] Adaptive learning paths (personalized module sequencing)
- [ ] Integration with Taleemabad's other platforms (NEO, EG, Teacher Training)
- [ ] Multi-language support (Sindhi, Punjabi, English)

---

## What Success Looks Like (By End of Q2)

✅ **Platform Fully Deployed**
- RABT coaching platform live on Taleemabad infrastructure
- All 6 modules + assessments functional
- 50+ coaches onboarded and training

✅ **Data-Driven Insights**
- Vacation engagement analytics complete
- Coaching rubric improvement measured
- Content quality assessed (high/low performing modules identified)

✅ **Team Punjab Ready**
- Handoff documentation complete
- Support structure in place
- Tracking APIs documented & tested

✅ **Roadmap Clear**
- Phase 2 priorities set based on vacation data
- Regional admin features planned
- Multi-language support scoped

---

## Session Notes for Tomorrow

**Carry-Overs from Today:**
1. Dashboard UX redesign (in progress — show coach details, module breakdown)
2. Railway migration to Taleemabad account (blocked on account setup)
3. Urdu translations (in progress — need to prioritize by module)
4. E2E automation with Chrome MCP (needs design, not started)
5. Scheduler integration decision (needs meeting scheduled)

**Data Points to Review:**
- Coach engagement data (May 31) — are coaches using all 6 modules?
- Baseline analytics — which modules have low engagement?
- Feedback submissions — what are coaches saying?

**Next Big Goal:** Get Dashboard UX + Urdu translations done by May 31, then focus on handover prep.

---

**Document Version:** 1.0
**Last Updated:** May 19, 2026
**Next Review:** June 2, 2026
