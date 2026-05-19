# Coaching Platform — Product Roadmap 2026
**Focus:** Offline resilience + engagement + retention

---

## Q2 2026 — Completed

### ✅ Offline Audio Queue (Merged Staging)
**What:** Coach records debrief → offline → audio saves locally → auto-uploads when online
**Why:** Audio loss was killing retention in low-connectivity zones
**Data track:** Audio loss rate, debrief completion rate, Neo analysis lag time
**Retention impact:** +8-12% expected for sub-region coaches

**Shipped:** 2026-05-13 | **Jira:** COACH-089

---

## Q3 2026 — Next (Proposed)

### Priority 1: Offline Form Submission
**What:** Coaches can fill observation form, save as draft locally, auto-sync when online
**Why:** Currently coaches must have connectivity to create observations; offline drafts reduce friction
**Data track:** Form submission rate from field, draft-to-submitted conversion, time-to-completion
**Retention impact:** +5-8% (more observations completed = more coaching value)
**Effort:** 2 weeks | **Dependencies:** Existing audioQueue infrastructure

### Priority 2: Video Recording (Optional)
**What:** Optional video capture during school visits (same offline mechanism as audio)
**Why:** Video provides better coaching context (classroom dynamics, teacher body language)
**Data track:** Video recording adoption rate, Neo analysis quality (if applicable), coach engagement with video playback
**Retention impact:** Engagement driver (novelty + richer feedback)
**Effort:** 3 weeks | **Dependencies:** Storage cost analysis, Neo video support

### Priority 3: Engagement Dashboard
**What:** Coach sees coaching value metrics (schools visited, observations completed, Neo insights received, improvement trends)
**Why:** Coaches need to see their impact; otherwise platform feels like data collection, not coaching tool
**Data track:** Dashboard engagement, correlation with return rate, retention improvement
**Retention impact:** +12-15% (coaches who see their coaching impact retain 40% longer)
**Effort:** 2.5 weeks

---

## Q4 2026 — Medium Term (Needs Validation)

### Coaching Plan Builder
**What:** System generates personalized coaching plan for each teacher (based on classroom assessment data + Neo observations)
**Why:** Coaching is currently reactive (visit → observe → debrief); needs to be proactive (plan → visit → measure progress)
**Data track:** Plan completion rate, teacher improvement velocity, coach confidence score
**Retention impact:** +20%+ (structured coaching > ad-hoc coaching)
**Effort:** 4 weeks | **Blockers:** Needs baseline assessment engine + Neo curriculum mapping

---

## Roadmap by Engagement & Retention Driver

### Tier 1: Core Retention (Do This First)
| Feature | Problem | Solution | Timeline | Impact |
|---------|---------|----------|----------|--------|
| **Offline Audio** | Audio lost in field | Auto-save + sync | ✅ Done | +8-12% retention |
| **Offline Forms** | Coaches can't save observations offline | Local draft + sync | Q3 | +5-8% retention |
| **Coaching Dashboard** | Coaches don't see their impact | Metrics + insights display | Q3 | +12-15% retention |

### Tier 2: Engagement (Do This Second)
| Feature | Problem | Solution | Timeline | Impact |
|---------|---------|----------|----------|--------|
| **Video Recording** | Limited coaching context | Optional video capture | Q3 | Engagement driver |
| **Neo Insights UI** | Debrief insights buried in form | Standalone insights page | Q3 | Engagement driver |
| **Coach Notifications** | Coaches miss Neo feedback | Push notifications on debrief ready | Q3 | +3-5% engagement |

### Tier 3: Growth (Do This Third)
| Feature | Problem | Solution | Timeline | Impact |
|---------|---------|----------|----------|--------|
| **Coaching Plans** | Coaching is reactive | Structured plans + progress tracking | Q4 | +20%+ retention |
| **Teacher Improvement Tracking** | Hard to measure coaching ROI | Before/after observation comparison | Q4 | Manager engagement |

---

## Success Metrics (Monthly Dashboard)

### Engagement Metrics
- **Coaching visits per coach:** Target 4+ per month (currently 2.5)
- **Observations completed per visit:** Target 3+ per visit (currently 2.8)
- **Neo debrief recordings per observation:** Target 90%+ (currently 40%)

### Retention Metrics
- **30-day retention:** Target 70% (currently 55%)
- **Coach churn rate:** Target < 8% per month (currently 12%)
- **Sub-region retention lift:** Target 80%+ for coaches in low-connectivity zones

### Feature Adoption
- **Offline queue usage:** % of coaches who experience at least one offline save/sync per month
- **Target:** 50% by EOQ (high-connectivity zones won't trigger feature; target sub-regions only)

### Data Quality
- **Audio loss rate:** Track % of observations with audio recorded but NOT uploaded
- **Target:** < 5% (currently ~60% in low-connectivity zones)
- **Neo analysis lag:** Average time from record to analysis complete
- **Target:** < 10 min (was 30-60 min before feature)

---

## Known Blockers & Dependencies

### Staging Validation (Before Production)
- [ ] Mobile testing (iOS Safari, Android Chrome)
- [ ] Real-world offline test (extended airplane mode)
- [ ] Neo edge function load testing (expect 2x+ upload volume)

### Production Readiness
- [ ] Staging database seeding with real coach assignments
- [ ] Monitoring + alerting for failed uploads (Datadog/Grafana)
- [ ] Rollback plan if audio loss rate doesn't improve

---

## Non-Goals (Explicitly Out of Scope)

- ❌ Live streaming (too complex, connectivity-dependent)
- ❌ Peer coaching (requires social features, separate work)
- ❌ AI-generated coaching plans (until coach feedback on Neo insights is validated)
- ❌ Multi-language support (prioritize sub-region retention first)

---

## Why This Roadmap?

**Theory of change:**
1. Coaches lose audio in field → low confidence in platform
2. If we fix audio loss → more debrief recordings → more Neo insights
3. If coaches see coaching insights → they see platform value
4. If they see value → they return, complete more visits, coach more teachers
5. Result: 15-20% retention improvement by EOQ

**Validation points:**
- Audio loss rate improves to < 5% (metric #1)
- Debrief completion rate rises to > 70% (metric #2)
- 30-day retention moves from 55% → 65%+ (metric #3)

If any of these metrics don't improve after staging testing, we pivot.

---

**Last Updated:** 2026-05-13 | **Next Review:** 2026-05-27
