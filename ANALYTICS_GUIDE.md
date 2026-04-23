# Analytics Implementation Guide

**Status:** ✅ Implemented and Live

---

## 📊 Quick Access

### Admin Dashboard
**Route:** `/admin/analytics`  
**File:** `src/pages/admin/AdminAnalytics.tsx`

**What you can see:**
- Coach list with training progress
- Quiz scores and attempt counts
- Tab switch violations (anti-cheat)
- Fullscreen violations
- Baseline/Endline scores
- Flagged users for review
- Regional breakdown
- Persona-based filtering

---

## 🪝 How to Track Events

### Using the Hook
```typescript
import { useAnalytics } from "@/hooks/useAnalytics";

export function MyComponent() {
  const { track } = useAnalytics();

  const handleAction = () => {
    track({
      event_type: "decision_submitted",
      scenario_id: "scenario-123",
      unit_id: "unit-456",
      metadata: { choice: "A", timeSpent: 45 }
    });
  };

  return <button onClick={handleAction}>Submit</button>;
}
```

### Event Types Available
```typescript
"scenario_viewed"      // User opened a scenario
"decision_submitted"   // User submitted a choice
"feedback_viewed"      // User viewed feedback
"read_more_clicked"    // User clicked "read more"
```

### Metadata Examples
```javascript
// Any custom data can go in metadata
metadata: {
  choice: "A",
  timeSpent: 45,
  difficulty: "hard",
  feedbackHelped: true,
  customField: "any value"
}
```

---

## 🗄️ Database Table Structure

**Table:** `analytics_events` (in Supabase)

**Columns:**
| Column | Type | Purpose |
|--------|------|---------|
| id | UUID | Event ID |
| user_id | UUID | Coach/user who triggered event |
| event_type | TEXT | Type of event (scenario_viewed, etc.) |
| scenario_id | UUID | Related scenario (optional) |
| unit_id | UUID | Related unit (optional) |
| metadata | JSONB | Custom event data |
| created_at | TIMESTAMP | When event occurred |

**Example Query:**
```sql
-- Get all events for a user
SELECT * FROM analytics_events 
WHERE user_id = '...' 
ORDER BY created_at DESC;

-- Count events by type
SELECT event_type, COUNT(*) 
FROM analytics_events 
GROUP BY event_type;

-- Get scenario views
SELECT * FROM analytics_events 
WHERE event_type = 'scenario_viewed' 
AND created_at > now() - interval '7 days';
```

---

## 📈 Current Tracking Points

### Scenario Module
**File:** `src/components/scenario/ExpandableDepth.tsx`

**Events tracked:**
- `read_more_clicked` — User expands "Read More" sections
- Metadata: `{ section_type, depth_level }`

### Scenario Flow
**File:** `src/pages/ScenarioFlow.tsx`

**Events tracked:**
- `scenario_viewed` — User opens scenario
- `decision_submitted` — User submits choice
- `feedback_viewed` — User views feedback
- Metadata: includes scenario_id, unit_id, phase info

---

## 🔗 Integration Points

### In Components
1. Import hook: `import { useAnalytics } from "@/hooks/useAnalytics";`
2. Call hook: `const { track } = useAnalytics();`
3. Track events: `track({ event_type: "...", ... })`

### Fire-and-Forget Pattern
- Events are logged asynchronously (non-blocking)
- Failures are silently logged to console (won't crash app)
- No await needed — hook returns immediately

### Authentication
- Only authenticated users are tracked (`useAuth()` check)
- user_id is automatically captured from session

---

## 📱 Admin Analytics Page Features

### Filters
- **Search:** By coach name or phone
- **Region:** Islamabad, Balochistan, Punjab, Rawalpindi
- **Persona:** A, B, C, D
- **Flagged Only:** Show anti-cheat violations

### Metrics Displayed
- **Trainings Passed:** Count of completed modules
- **Trainings Started:** Total modules opened
- **Avg Quiz Score:** Average score across attempts
- **Tab Switches:** Detected cheating behavior
- **Baseline/Endline:** Assessment scores
- **Weak Modules:** Performance analysis
- **Flagged:** Anti-cheat flag status

---

## 🚀 How to Add More Events

### Step 1: Define Event Type
```typescript
// src/hooks/useAnalytics.ts
export type AnalyticsEventType =
  | "scenario_viewed"
  | "decision_submitted"
  | "feedback_viewed"
  | "read_more_clicked"
  | "my_new_event";  // ← Add here
```

### Step 2: Track in Component
```typescript
const { track } = useAnalytics();

track({
  event_type: "my_new_event",
  scenario_id: scenarioId,
  metadata: { customData: "value" }
});
```

### Step 3: View in Admin
The event will automatically appear in Supabase analytics_events table and can be queried/displayed in AdminAnalytics page.

---

## 📊 Common Queries

### Get Today's Events
```sql
SELECT * FROM analytics_events 
WHERE DATE(created_at) = CURRENT_DATE 
ORDER BY created_at DESC;
```

### Get Events by User
```sql
SELECT * FROM analytics_events 
WHERE user_id = 'uuid-here' 
ORDER BY created_at DESC;
```

### Get Event Summary
```sql
SELECT 
  event_type, 
  COUNT(*) as count,
  COUNT(DISTINCT user_id) as unique_users
FROM analytics_events 
WHERE created_at > now() - interval '7 days'
GROUP BY event_type;
```

### Get Metadata for Analysis
```sql
SELECT 
  event_type,
  metadata,
  created_at
FROM analytics_events 
WHERE event_type = 'decision_submitted'
LIMIT 10;
```

---

## 🔍 Debugging Analytics

### Check if Events are Being Logged
1. Go to Supabase Studio
2. SQL Editor
3. Run: `SELECT COUNT(*) FROM analytics_events WHERE DATE(created_at) = CURRENT_DATE;`
4. Should show events from today

### Check Specific User
1. Find user_id in profiles table
2. Run: `SELECT * FROM analytics_events WHERE user_id = 'user-uuid' LIMIT 10;`
3. Should show recent events

### Check Console for Errors
- Open browser DevTools (F12)
- Look for console.warn("[analytics]", ...) messages
- These indicate event logging failures

---

## 📝 Best Practices

✅ **DO:**
- Use meaningful event types
- Include scenario_id and unit_id when relevant
- Add rich metadata for analysis
- Fire events non-blockingly (no await)

❌ **DON'T:**
- Log sensitive personal data in metadata
- Await analytics calls (defeats fire-and-forget pattern)
- Throw errors from analytics (hook handles silently)
- Log every minor interaction (reduces noise)

---

## 📚 Related Files

- Hook: `src/hooks/useAnalytics.ts`
- Admin Page: `src/pages/admin/AdminAnalytics.tsx`
- Database Types: `src/integrations/supabase/types.ts`
- Scenario Component: `src/components/scenario/ExpandableDepth.tsx`
- Scenario Flow: `src/pages/ScenarioFlow.tsx`
- Migration: `supabase/migrations/20260425000001_scenario_first_foundation.sql` (creates analytics_events table)

---

## 🎯 Next Steps

1. **Add More Events** - Identify user actions you want to track
2. **Create Analytics Page** - Already at `/admin/analytics` but can be enhanced
3. **Build Reports** - Export analytics data for stakeholder reports
4. **Set Up Alerts** - Flag suspicious activity (already implemented for tab switches)
5. **A/B Testing** - Use metadata to track feature adoption

---

**Status:** Production-ready and actively tracking user interactions.
