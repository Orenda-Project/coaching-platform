# Analytics & Event Tracking

## Overview

The coaching platform tracks user behavior and learning progress through a **fire-and-forget analytics system**. Events are recorded in real-time without blocking user interactions, enabling insights into engagement patterns, learning effectiveness, and user behavior.

---

## Event Types

### Scenario Events (Phase 1)

| Event | When Fired | Metadata | Purpose |
|-------|-----------|----------|---------|
| `scenario_viewed` | Scenario phase becomes active | scenario_id, unit_id | Track scenario engagement |
| `decision_submitted` | User submits their choice | scenario_id, unit_id, chosen_option (A/B/C/D) | Track decision-making |
| `feedback_viewed` | Feedback card is displayed | scenario_id, unit_id | Track learning from feedback |
| `read_more_clicked` | First expand of depth content | scenario_id, unit_id | Track interest in deeper learning |

### Assessment Events

| Event | When Fired | Purpose |
|-------|-----------|---------|
| `assessment_started` | User clicks "Start Assessment" | Track assessment initiation |
| `assessment_submitted` | User submits final answers | Track completion |
| `quiz_started` | Module quiz begins | Track quiz engagement |
| `quiz_passed` | Quiz score ≥80% | Track learning progress |
| `quiz_failed` | Quiz score <80% | Track struggles/retries |

### Module Events

| Event | When Fired | Purpose |
|-------|-----------|---------|
| `content_completed` | Video 90% watched OR slides 30s viewed | Track content consumption |
| `module_passed` | Training unit quiz passed | Track module completion |
| `module_failed` | Training unit quiz failed (attempt 3) | Track blockers |

---

## Data Model

### analytics_events Table

```sql
CREATE TABLE public.analytics_events (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id),
  event_type TEXT NOT NULL,
  scenario_id UUID,
  unit_id UUID REFERENCES trainings(id),
  metadata JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

**Indexes:**
- `(user_id, created_at DESC)` — Fast user event timeline
- `(event_type)` — Aggregate by event type

### Sample Data

```json
{
  "user_id": "abc123",
  "event_type": "decision_submitted",
  "scenario_id": "scenario-001",
  "unit_id": "unit-001",
  "metadata": {
    "chosen_option": "B",
    "is_correct": true,
    "time_spent_seconds": 42
  },
  "created_at": "2026-04-14T15:30:00Z"
}
```

---

## Fire-and-Forget Pattern

Analytics events are tracked **asynchronously without blocking user interactions**:

```typescript
// In src/hooks/useAnalytics.ts
const track = useCallback(
  ({ event_type, scenario_id, unit_id, metadata }: TrackEventParams) => {
    if (!user) return;

    // Fire-and-forget: don't await, don't surface errors
    supabase
      .from("analytics_events")
      .insert({
        user_id: user.id,
        event_type,
        scenario_id,
        unit_id,
        metadata,
      })
      .then(({ error }) => {
        // Silently log errors to console (don't show to user)
        if (error) console.warn("[analytics]", error.message);
      });
  },
  [user]
);
```

**Benefits:**
- Non-blocking UI — events don't delay user experience
- Resilient — network failures don't break the app
- Simple — no error handling needed
- Production-ready — proven pattern in analytics systems

---

## Usage Example

```typescript
import { useAnalytics } from "@/hooks/useAnalytics";

export function ScenarioFlow() {
  const { track } = useAnalytics();

  const handleDecisionSubmit = async (choice: string) => {
    // Fire analytics event (non-blocking)
    track({
      event_type: "decision_submitted",
      scenario_id: currentScenario.id,
      unit_id: trainingId,
      metadata: {
        chosen_option: choice,
        is_correct: isChoiceCorrect,
        time_spent_seconds: elapsedSeconds,
      },
    });

    // Continue with business logic (doesn't wait for analytics)
    submitScenarioResponse(choice);
  };
}
```

---

## Dashboards & Reporting (Future)

Once events accumulate, analytics dashboards can be built:

### Coach Dashboard
- **Engagement:** Total scenarios completed, average time per scenario
- **Learning:** Scenarios with high/low correctness rates
- **Patterns:** Most clicked "read more" topics, topic-specific weak areas

### Admin Dashboard
- **Cohort insights:** Overall module difficulty, persona distribution
- **Outliers:** Unusually fast/slow completion times (possible cheating)
- **Trends:** Seasonal patterns, feature adoption rates

### Learner Dashboard
- **Progress:** Scenarios completed, weak topics identified
- **Recommendations:** "You're strong in Feedback; try Mirror Specialist module"
- **Milestones:** Badges for achievements (all scenarios completed, expert on topic X)

---

## Materialized Views (Performance Optimization)

For expensive aggregations, PostgreSQL materialized views can be used:

```sql
-- Aggregate correct rate per scenario
CREATE MATERIALIZED VIEW scenario_stats AS
SELECT
  scenario_id,
  COUNT(*) as total_attempts,
  SUM(CASE WHEN is_correct THEN 1 ELSE 0 END) as correct_count,
  ROUND(100.0 * SUM(CASE WHEN is_correct THEN 1 ELSE 0 END) / COUNT(*)) as correct_percentage
FROM scenario_responses
GROUP BY scenario_id;

-- Refresh periodically (e.g., hourly)
REFRESH MATERIALIZED VIEW scenario_stats;
```

---

## Privacy & Security

- **No PII in metadata** — Only IDs and behavioral events, never email or sensitive personal data
- **RLS enforced** — Users can only see their own events via RLS policy
- **Data retention** — Define retention policy (e.g., delete after 1 year for GDPR)
- **Export for research** — Analytics can be anonymized and exported for insights

**RLS Policy:**
```sql
CREATE POLICY "Users can read own analytics" ON analytics_events
  FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Admins can read all analytics" ON analytics_events
  FOR SELECT
  USING (has_role(auth.uid(), 'admin'));
```

---

## Queries for Analysis

### Event frequency by type
```sql
SELECT event_type, COUNT(*) as count
FROM analytics_events
WHERE created_at > now() - interval '7 days'
GROUP BY event_type
ORDER BY count DESC;
```

### User engagement score
```sql
SELECT
  user_id,
  COUNT(*) as total_events,
  COUNT(DISTINCT scenario_id) as scenarios_engaged,
  AVG(CASE WHEN event_type = 'decision_submitted' THEN (metadata->>'time_spent_seconds')::int END) as avg_time_per_decision
FROM analytics_events
WHERE event_type IN ('scenario_viewed', 'decision_submitted', 'read_more_clicked')
GROUP BY user_id
ORDER BY total_events DESC;
```

### Scenario effectiveness
```sql
SELECT
  scenario_id,
  COUNT(*) as total_attempts,
  SUM(CASE WHEN metadata->>'is_correct' = 'true' THEN 1 ELSE 0 END)::float / COUNT(*) as correct_rate,
  AVG((metadata->>'time_spent_seconds')::int) as avg_time_seconds
FROM analytics_events
WHERE event_type = 'decision_submitted'
GROUP BY scenario_id
HAVING COUNT(*) > 10
ORDER BY correct_rate ASC;
```

---

## Future Enhancements

- **Real-time dashboards** — Live engagement metrics
- **ML-powered recommendations** — "Based on your pattern, try this module"
- **Cohort analysis** — Compare persona groups, identify outliers
- **Retention tracking** — Weekly/monthly active user metrics
- **A/B testing** — Test scenario wording, feedback phrasing
- **Funnel analysis** — Drop-off rates (baseline → modules → endline)
- **Behavioral analytics** — Heatmaps showing time spent per question type

---

**Last Updated:** 2026-04-14
