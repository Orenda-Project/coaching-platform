# Phase 4 API Endpoints Quick Reference

## Analytics Endpoints

| Method | Endpoint | Purpose | Status |
|--------|----------|---------|--------|
| POST | `/api/analytics/events/{user_id}` | Log activity event | 201 Created |
| GET | `/api/analytics/events/{user_id}` | Get user events (paginated) | 200 OK |
| GET | `/api/analytics/events/{user_id}/type/{event_type}` | Filter events by type | 200 OK |
| GET | `/api/analytics/metrics/{user_id}` | Get user metrics | 200 OK |
| PUT | `/api/analytics/metrics/{user_id}` | Update user metrics | 200 OK |
| POST | `/api/analytics/metrics/{user_id}/increment` | Increment metric by N | 200 OK |
| GET | `/api/analytics/modules/{module_id}` | Get module analytics | 200 OK |
| GET | `/api/analytics/dashboard/{user_id}` | Get dashboard data | 200 OK |
| GET | `/api/analytics/` | Get all analytics (admin) | 200 OK |

## Scenario Endpoints

| Method | Endpoint | Purpose | Status |
|--------|----------|---------|--------|
| GET | `/api/scenarios/{scenario_id}` | Get scenario with options | 200 OK |
| GET | `/api/scenarios/unit/{unit_id}` | Get unit's scenarios | 200 OK |
| POST | `/api/scenarios/{scenario_id}/respond/{user_id}` | Save user response | 201 Created |
| GET | `/api/scenarios/{scenario_id}/user/{user_id}` | Get user's response | 200 OK |
| PUT | `/api/scenarios/{scenario_id}/respond/{response_id}` | Update user response | 200 OK |
| GET | `/api/scenarios/user/{user_id}/responses` | Get user's all responses | 200 OK |
| GET | `/api/scenarios/{scenario_id}/responses` | Get scenario's all responses | 200 OK |
| GET | `/api/scenarios/option/{option_id}/feedback` | Get option feedback | 200 OK |
| GET | `/api/scenarios/{scenario_id}/optimal` | Get optimal response | 200 OK |
| GET | `/api/scenarios/unit/{unit_id}/stats/{user_id}` | Get user stats in unit | 200 OK |

## Event Logging Examples

### Log Quiz Completion
```bash
curl -X POST "http://localhost:8000/api/analytics/events/user-123" \
  -H "Content-Type: application/json" \
  -d '{
    "event_type": "quiz_completed",
    "event_data": {
      "module_id": "module-1",
      "score": 85,
      "duration_seconds": 300,
      "attempt_number": 1
    }
  }'
```

### Log Module View
```bash
curl -X POST "http://localhost:8000/api/analytics/events/user-123" \
  -H "Content-Type: application/json" \
  -d '{
    "event_type": "module_viewed",
    "event_data": {
      "module_id": "module-2"
    }
  }'
```

### Log Scenario Response
```bash
curl -X POST "http://localhost:8000/api/analytics/events/user-123" \
  -H "Content-Type: application/json" \
  -d '{
    "event_type": "scenario_responded",
    "event_data": {
      "scenario_id": "scenario-1",
      "selected_option": "option-a",
      "is_optimal": true
    }
  }'
```

## Metrics Management Examples

### Get User Metrics
```bash
curl -X GET "http://localhost:8000/api/analytics/metrics/user-123"
```

### Update Metrics
```bash
curl -X PUT "http://localhost:8000/api/analytics/metrics/user-123" \
  -H "Content-Type: application/json" \
  -d '{
    "quiz_attempts": 5,
    "modules_passed": 3,
    "total_score": 425.5
  }'
```

### Increment Quiz Attempts
```bash
curl -X POST "http://localhost:8000/api/analytics/metrics/user-123/increment" \
  -H "Content-Type: application/json" \
  -d '{
    "metric_name": "quiz_attempts",
    "increment": 1
  }'
```

## Scenario Management Examples

### Get Scenario
```bash
curl -X GET "http://localhost:8000/api/scenarios/scenario-1"
```

### Get Unit Scenarios
```bash
curl -X GET "http://localhost:8000/api/scenarios/unit/unit-1"
```

### Respond to Scenario
```bash
curl -X POST "http://localhost:8000/api/scenarios/scenario-1/respond/user-123" \
  -H "Content-Type: application/json" \
  -d '{
    "selected_option_id": "option-1"
  }'
```

### Get User's Responses
```bash
curl -X GET "http://localhost:8000/api/scenarios/user/user-123/responses?limit=10&offset=0"
```

### Get Scenario Stats
```bash
curl -X GET "http://localhost:8000/api/scenarios/unit/unit-1/stats/user-123"
```

## Query Parameters Reference

### Pagination
- **limit:** Number of results (default varies by endpoint)
  - Event endpoints: 1-1000 (default 100)
  - Admin analytics: 1-10000 (default 1000)
  - Scenario endpoints: 1-1000 (default 100)

- **offset:** Results offset (default 0)

### Examples
```
# Get 20 events, skip first 40
/api/analytics/events/user-123?limit=20&offset=40

# Get 500 all analytics
/api/analytics/?limit=500&offset=0

# Get user's scenario responses, page 2
/api/scenarios/user/user-123/responses?limit=10&offset=10
```

## Response Models

### AnalyticsEvent
```json
{
  "id": "uuid-string",
  "user_id": "uuid-string",
  "event_type": "quiz_completed",
  "event_data": {...},
  "timestamp": "2025-01-15T10:30:45Z"
}
```

### UserMetrics
```json
{
  "id": "uuid-string",
  "user_id": "uuid-string",
  "quiz_attempts": 5,
  "modules_passed": 3,
  "total_score": 425.5,
  "created_at": "2025-01-10T08:00:00Z",
  "updated_at": "2025-01-15T15:30:00Z"
}
```

### Scenario
```json
{
  "id": "uuid-string",
  "unit_id": "unit-1",
  "title": "Customer Service Scenario",
  "description": "Handle an angry customer",
  "situation": "A customer is upset about late delivery",
  "order_number": 1,
  "created_at": "2025-01-10T08:00:00Z",
  "updated_at": "2025-01-10T08:00:00Z",
  "options": [
    {
      "id": "option-1",
      "scenario_id": "scenario-1",
      "option_text": "Listen and apologize sincerely",
      "feedback": "Good approach - shows empathy",
      "is_optimal": true,
      "order_number": 1,
      "created_at": "...",
      "updated_at": "..."
    }
  ]
}
```

### ScenarioResponse (User's answer)
```json
{
  "id": "uuid-string",
  "user_id": "user-123",
  "scenario_id": "scenario-1",
  "selected_option_id": "option-1",
  "timestamp": "2025-01-15T14:20:30Z"
}
```

### Dashboard
```json
{
  "user_id": "user-123",
  "metrics": {...},
  "recent_events": [...]
}
```

### Scenario Stats
```json
{
  "unit_id": "unit-1",
  "user_id": "user-123",
  "total_scenarios": 5,
  "completed_scenarios": 4,
  "optimal_responses": 3,
  "percentage_optimal": 75.0
}
```

## Common Error Responses

### 400 Bad Request
```json
{
  "detail": "Failed to save response"
}
```

### 404 Not Found
```json
{
  "detail": "Scenario not found"
}
```

### 201 Created
```json
{
  "id": "new-uuid",
  ...data...
}
```

---

## Integration Checklist

- [ ] Database migrations run successfully
- [ ] Models imported correctly in `__init__.py`
- [ ] Controllers registered in `main.py`
- [ ] Unit tests passing (110+ tests)
- [ ] Integration tests passing
- [ ] API documentation generated
- [ ] Sample event data created
- [ ] Dashboard tested with real user data
- [ ] Admin analytics endpoint accessible
- [ ] Pagination tested at scale (1000+ records)

---

## Performance Notes

### Indexes Created
- `analytics_events`: idx_user_event_timestamp (user_id, event_type, timestamp)
- `scenarios`: idx_unit_order (unit_id, order_number)
- `scenario_options`: idx_scenario_order (scenario_id, order_number)
- `scenario_responses`: idx_user_scenario_time (user_id, scenario_id, timestamp)

### Query Optimization
- User metrics: O(1) lookup via unique user_id
- Event retrieval: O(log n) with composite index
- Scenario ordering: O(1) with order_number index
- User responses: O(log n) with timestamp index

### Recommended Database Tuning
```sql
-- Analyze tables for query optimizer
ANALYZE analytics_events;
ANALYZE user_metrics;
ANALYZE scenarios;
ANALYZE scenario_options;
ANALYZE scenario_responses;

-- Verify index usage
EXPLAIN SELECT * FROM analytics_events WHERE user_id = $1 ORDER BY timestamp DESC LIMIT 100;
```

---

**Last Updated:** 2025-01-XX | **Version:** 1.0
