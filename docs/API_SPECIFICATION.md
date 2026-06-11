# Coaching Platform REST API Specification

**API Version:** 2.0  
**Base URL:** `http://localhost:8000` (dev) | `https://coaching-api.staging.railway.app` (staging) | `https://coaching-api.railway.app` (prod)  
**Framework:** FastAPI (Python)  
**Authentication:** JWT Bearer Token (from Supabase Auth)  
**Database:** PostgreSQL via SQLAlchemy ORM  

---

## Table of Contents

1. [Global Requirements](#global-requirements)
2. [Domain 1: Auth & Users](#domain-1-auth--users)
3. [Domain 2: Observations & Coaching](#domain-2-observations--coaching)
4. [Domain 3: Field Issues](#domain-3-field-issues)
5. [Domain 4: Smart Schedule](#domain-4-smart-schedule)
6. [Domain 5: Training & Content](#domain-5-training--content)
7. [Domain 6: User Roles](#domain-6-user-roles)
8. [Domain 7: Analytics](#domain-7-analytics)
9. [Domain 8: Quiz](#domain-8-quiz) ✅ Already Implemented
10. [Error Handling](#error-handling)
11. [Rate Limiting](#rate-limiting)
12. [Pagination](#pagination)

---

## Global Requirements

### Authentication
All endpoints require JWT Bearer token (except `/health` and OpenAPI docs):

```
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json
```

### Status Codes
- **200 OK** — Request succeeded
- **201 Created** — Resource created
- **204 No Content** — Success, no content to return
- **400 Bad Request** — Validation error
- **401 Unauthorized** — Missing/invalid token
- **403 Forbidden** — Insufficient permissions
- **404 Not Found** — Resource not found
- **409 Conflict** — Duplicate resource (e.g., email exists)
- **500 Internal Server Error** — Server error

### Error Response Format
```json
{
  "error": "error_code",
  "message": "Human-readable error message",
  "details": {
    "field": "validation error details"
  }
}
```

### Response Envelope (Standard)
```json
{
  "status": "success|error",
  "data": { /* payload */ },
  "meta": {
    "version": "2.0",
    "timestamp": "2026-06-09T10:30:00Z"
  }
}
```

### User Context
- User ID extracted from JWT token payload (`sub` claim)
- User role extracted from JWT token payload (`role` claim)
- All operations scoped to authenticated user (RLS equivalent)

---

## Domain 1: Auth & Users

### 1.1 Get Current User Profile

**Endpoint:** `GET /api/users/profile`  
**Authentication:** Required (Bearer Token)  
**Description:** Get current authenticated user's profile

**Response (200):**
```json
{
  "status": "success",
  "data": {
    "id": "uuid-user-id",
    "email": "user@example.com",
    "phone": "+923001234567",
    "full_name": "John Doe",
    "role": "coach",
    "region": "Karachi",
    "created_at": "2026-05-01T10:00:00Z",
    "updated_at": "2026-06-01T15:30:00Z"
  },
  "meta": { "version": "2.0", "timestamp": "2026-06-09T10:30:00Z" }
}
```

**Error (401):**
```json
{
  "error": "unauthorized",
  "message": "Token is invalid or expired"
}
```

---

### 1.2 Update User Profile

**Endpoint:** `PUT /api/users/profile`  
**Authentication:** Required  
**Description:** Update current user's profile

**Request Body:**
```json
{
  "phone": "+923001234567",
  "full_name": "John Doe",
  "region": "Islamabad"
}
```

**Response (200):**
```json
{
  "status": "success",
  "data": {
    "id": "uuid-user-id",
    "email": "user@example.com",
    "phone": "+923001234567",
    "full_name": "John Doe",
    "role": "coach",
    "region": "Islamabad",
    "updated_at": "2026-06-09T10:30:00Z"
  },
  "meta": { "version": "2.0", "timestamp": "2026-06-09T10:30:00Z" }
}
```

**Error (400):** Validation error
```json
{
  "error": "validation_error",
  "message": "Invalid input",
  "details": {
    "phone": "Invalid phone format"
  }
}
```

**Error (409):** Conflict (phone already exists)
```json
{
  "error": "duplicate_phone",
  "message": "This phone number is already registered"
}
```

---

### 1.3 Get User by ID

**Endpoint:** `GET /api/users/{user_id}`  
**Authentication:** Required  
**Description:** Get user profile by ID (admin only)  
**Role Required:** super_admin, regional_admin

**Response (200):**
```json
{
  "status": "success",
  "data": {
    "id": "uuid-user-id",
    "email": "user@example.com",
    "phone": "+923001234567",
    "full_name": "John Doe",
    "role": "coach",
    "created_at": "2026-05-01T10:00:00Z"
  },
  "meta": { "version": "2.0", "timestamp": "2026-06-09T10:30:00Z" }
}
```

---

## Domain 2: Observations & Coaching

### 2.1 List User's Observations

**Endpoint:** `GET /api/observations`  
**Authentication:** Required  
**Description:** Get all observations for current user (as observer or teacher)

**Query Parameters:**
- `role=observer|teacher` — Filter by observation role
- `status=Draft|Submitted` — Filter by status
- `page=1` — Pagination (default 1)
- `limit=20` — Items per page (default 20, max 100)

**Response (200):**
```json
{
  "status": "success",
  "data": {
    "observations": [
      {
        "id": "uuid-obs-id",
        "observer_id": "uuid-observer-id",
        "observer_name": "Coach Ali",
        "teacher_id": "uuid-teacher-id",
        "teacher_name": "Teacher Fatima",
        "school": "ABC School, Karachi",
        "status": "Draft",
        "hots_rubric": { "domain_1": 3, "domain_2": 4 },
        "fico_rubric": { "question_clarity": 4, "engagement": 3 },
        "hots_notes": "Excellent questioning technique",
        "created_at": "2026-06-05T10:00:00Z",
        "updated_at": "2026-06-05T14:00:00Z"
      }
    ],
    "total_count": 45,
    "page": 1,
    "limit": 20,
    "total_pages": 3
  },
  "meta": { "version": "2.0", "timestamp": "2026-06-09T10:30:00Z" }
}
```

---

### 2.2 Get Single Observation

**Endpoint:** `GET /api/observations/{observation_id}`  
**Authentication:** Required  
**Description:** Get detailed observation data

**Response (200):**
```json
{
  "status": "success",
  "data": {
    "id": "uuid-obs-id",
    "observer_id": "uuid-observer-id",
    "observer_name": "Coach Ali",
    "teacher_id": "uuid-teacher-id",
    "teacher_name": "Teacher Fatima",
    "school": "ABC School, Karachi",
    "grade": "Grade 5",
    "status": "Draft",
    "hots_rubric": {
      "domain_1_critical_thinking": 3,
      "domain_2_analysis": 4,
      "domain_3_synthesis": 3
    },
    "fico_rubric": {
      "question_clarity": 4,
      "engagement": 3,
      "pacing": 4
    },
    "hots_notes": "Excellent questioning technique. Consider more wait time.",
    "created_at": "2026-06-05T10:00:00Z",
    "updated_at": "2026-06-05T14:00:00Z"
  },
  "meta": { "version": "2.0", "timestamp": "2026-06-09T10:30:00Z" }
}
```

**Error (403):** User not authorized
```json
{
  "error": "forbidden",
  "message": "You do not have permission to view this observation"
}
```

---

### 2.3 Create Observation

**Endpoint:** `POST /api/observations`  
**Authentication:** Required  
**Role Required:** coach, super_admin, regional_admin  
**Description:** Create a new observation record

**Request Body:**
```json
{
  "teacher_id": "uuid-teacher-id",
  "school": "ABC School, Karachi",
  "grade": "Grade 5",
  "subject": "Urdu"
}
```

**Response (201):**
```json
{
  "status": "success",
  "data": {
    "id": "uuid-new-obs-id",
    "observer_id": "uuid-current-user-id",
    "teacher_id": "uuid-teacher-id",
    "status": "Draft",
    "created_at": "2026-06-09T10:30:00Z"
  },
  "meta": { "version": "2.0", "timestamp": "2026-06-09T10:30:00Z" }
}
```

---

### 2.4 Update Observation Status

**Endpoint:** `PATCH /api/observations/{observation_id}/status`  
**Authentication:** Required  
**Description:** Update observation status (Draft → Submitted)

**Request Body:**
```json
{
  "status": "Submitted"
}
```

**Response (200):**
```json
{
  "status": "success",
  "data": {
    "id": "uuid-obs-id",
    "status": "Submitted",
    "updated_at": "2026-06-09T10:30:00Z"
  },
  "meta": { "version": "2.0", "timestamp": "2026-06-09T10:30:00Z" }
}
```

---

### 2.5 Update Observation HOTS Rubric

**Endpoint:** `PATCH /api/observations/{observation_id}/rubric/hots`  
**Authentication:** Required  
**Description:** Save HOTS (Higher Order Thinking Skills) rubric scores

**Request Body:**
```json
{
  "domain_1_critical_thinking": 3,
  "domain_2_analysis": 4,
  "domain_3_synthesis": 3
}
```

**Response (200):**
```json
{
  "status": "success",
  "data": {
    "id": "uuid-obs-id",
    "hots_rubric": {
      "domain_1_critical_thinking": 3,
      "domain_2_analysis": 4,
      "domain_3_synthesis": 3
    },
    "updated_at": "2026-06-09T10:30:00Z"
  },
  "meta": { "version": "2.0", "timestamp": "2026-06-09T10:30:00Z" }
}
```

---

### 2.6 Update Observation FICO Rubric

**Endpoint:** `PATCH /api/observations/{observation_id}/rubric/fico`  
**Authentication:** Required  
**Description:** Save FICO rubric scores

**Request Body:**
```json
{
  "question_clarity": 4,
  "engagement": 3,
  "pacing": 4
}
```

**Response (200):**
```json
{
  "status": "success",
  "data": {
    "id": "uuid-obs-id",
    "fico_rubric": {
      "question_clarity": 4,
      "engagement": 3,
      "pacing": 4
    },
    "updated_at": "2026-06-09T10:30:00Z"
  },
  "meta": { "version": "2.0", "timestamp": "2026-06-09T10:30:00Z" }
}
```

---

### 2.7 Update Observation Debrief Notes

**Endpoint:** `PATCH /api/observations/{observation_id}/debrief`  
**Authentication:** Required  
**Description:** Save debrief notes for HOTS/FICO

**Request Body:**
```json
{
  "hots_notes": "Excellent questioning technique. Consider more wait time.",
  "fico_notes": "Clear instructions. Engage more students in discussion."
}
```

**Response (200):**
```json
{
  "status": "success",
  "data": {
    "id": "uuid-obs-id",
    "hots_notes": "Excellent questioning technique. Consider more wait time.",
    "fico_notes": "Clear instructions. Engage more students in discussion.",
    "updated_at": "2026-06-09T10:30:00Z"
  },
  "meta": { "version": "2.0", "timestamp": "2026-06-09T10:30:00Z" }
}
```

---

### 2.8 Delete Observation

**Endpoint:** `DELETE /api/observations/{observation_id}`  
**Authentication:** Required  
**Description:** Delete an observation (draft only)

**Response (204):** No Content

**Error (400):** Cannot delete submitted observation
```json
{
  "error": "invalid_state",
  "message": "Cannot delete submitted observation"
}
```

---

## Domain 3: Field Issues

### 3.1 Create Field Issue

**Endpoint:** `POST /api/field-issues`  
**Authentication:** Required  
**Role Required:** coach, super_admin, regional_admin  
**Description:** Report a field issue

**Request Body:**
```json
{
  "issue_description": "No water supply in school",
  "school": "ABC School, Karachi",
  "priority": "high"
}
```

**Response (201):**
```json
{
  "status": "success",
  "data": {
    "id": "uuid-issue-id",
    "coach_id": "uuid-current-user-id",
    "coach_name": "Coach Ali",
    "sub_region": "Karachi East",
    "issue_description": "No water supply in school",
    "school": "ABC School, Karachi",
    "priority": "high",
    "status": "open",
    "created_at": "2026-06-09T10:30:00Z"
  },
  "meta": { "version": "2.0", "timestamp": "2026-06-09T10:30:00Z" }
}
```

---

### 3.2 List Field Issues

**Endpoint:** `GET /api/field-issues`  
**Authentication:** Required  
**Role Required:** super_admin, regional_admin (or view own)  
**Description:** List field issues (scoped by role)

**Query Parameters:**
- `status=open|resolved` — Filter by status
- `priority=high|medium|low` — Filter by priority
- `region=Karachi` — Filter by region (admin only)

**Response (200):**
```json
{
  "status": "success",
  "data": {
    "issues": [
      {
        "id": "uuid-issue-id",
        "coach_id": "uuid-coach-id",
        "coach_name": "Coach Ali",
        "sub_region": "Karachi East",
        "issue_description": "No water supply",
        "school": "ABC School",
        "priority": "high",
        "status": "open",
        "created_at": "2026-06-09T10:30:00Z"
      }
    ],
    "total_count": 12,
    "page": 1,
    "limit": 20
  },
  "meta": { "version": "2.0", "timestamp": "2026-06-09T10:30:00Z" }
}
```

---

## Domain 4: Smart Schedule

### 4.1 Get Teacher DC Scores

**Endpoint:** `GET /api/schedule/teacher-dc-scores`  
**Authentication:** Required  
**Description:** Get teacher DC scores for smart scheduling

**Query Parameters:**
- `region=Karachi` — Filter by region
- `sort=score_desc` — Sort by score descending

**Response (200):**
```json
{
  "status": "success",
  "data": {
    "teachers": [
      {
        "id": "uuid-teacher-id",
        "name": "Teacher Fatima",
        "school": "ABC School",
        "region": "Karachi East",
        "score": 85.5,
        "rank": 1,
        "last_observation": "2026-05-20T10:00:00Z"
      }
    ],
    "total_count": 45,
    "average_score": 72.3
  },
  "meta": { "version": "2.0", "timestamp": "2026-06-09T10:30:00Z" }
}
```

---

## Domain 5: Training & Content

### 5.1 Get Training Content

**Endpoint:** `GET /api/trainings/{training_id}/content`  
**Authentication:** Required  
**Description:** Get training content

**Response (200):**
```json
{
  "status": "success",
  "data": {
    "training_id": "uuid-training-id",
    "title": "HOTS Training Module 1",
    "content": [
      {
        "id": "uuid-content-id",
        "type": "video",
        "title": "Introduction to HOTS",
        "url": "https://example.com/video.mp4",
        "duration_minutes": 12
      },
      {
        "id": "uuid-content-id-2",
        "type": "slides",
        "title": "HOTS Framework",
        "slides": [
          {
            "slide_number": 1,
            "content": "..."
          }
        ]
      }
    ]
  },
  "meta": { "version": "2.0", "timestamp": "2026-06-09T10:30:00Z" }
}
```

---

## Domain 6: User Roles

### 6.1 Get Current User Role

**Endpoint:** `GET /api/users/me/role`  
**Authentication:** Required  
**Description:** Get current user's role

**Response (200):**
```json
{
  "status": "success",
  "data": {
    "user_id": "uuid-user-id",
    "role": "coach",
    "permissions": [
      "create_observation",
      "view_observation",
      "edit_own_observation",
      "report_issue"
    ]
  },
  "meta": { "version": "2.0", "timestamp": "2026-06-09T10:30:00Z" }
}
```

---

### 6.2 Assign User Role (Admin)

**Endpoint:** `POST /api/admin/users/{user_id}/role`  
**Authentication:** Required  
**Role Required:** super_admin, regional_admin  
**Description:** Assign role to user (admin only)

**Request Body:**
```json
{
  "role": "coach",
  "region": "Karachi"
}
```

**Response (200):**
```json
{
  "status": "success",
  "data": {
    "user_id": "uuid-user-id",
    "role": "coach",
    "region": "Karachi",
    "assigned_at": "2026-06-09T10:30:00Z"
  },
  "meta": { "version": "2.0", "timestamp": "2026-06-09T10:30:00Z" }
}
```

---

## Domain 7: Analytics

### 7.1 Track Event

**Endpoint:** `POST /api/analytics/event`  
**Authentication:** Required  
**Description:** Track analytics event (fire-and-forget, no await)

**Request Body:**
```json
{
  "event_type": "observation_created",
  "event_data": {
    "observation_id": "uuid-obs-id",
    "teacher_id": "uuid-teacher-id"
  },
  "metadata": {
    "url": "/coaching/observations",
    "referrer": "/dashboard"
  }
}
```

**Response (201):** Fire-and-forget (async, returns immediately)
```json
{
  "status": "success",
  "data": {
    "event_id": "uuid-event-id",
    "queued_at": "2026-06-09T10:30:00Z"
  },
  "meta": { "version": "2.0", "timestamp": "2026-06-09T10:30:00Z" }
}
```

---

### 7.2 Get User Analytics

**Endpoint:** `GET /api/analytics/user/{user_id}`  
**Authentication:** Required  
**Role Required:** super_admin, regional_admin (or view own)  
**Description:** Get analytics for a user

**Query Parameters:**
- `date_from=2026-06-01` — Start date
- `date_to=2026-06-09` — End date

**Response (200):**
```json
{
  "status": "success",
  "data": {
    "user_id": "uuid-user-id",
    "total_events": 234,
    "events_by_type": {
      "observation_created": 12,
      "observation_submitted": 8,
      "rubric_scored": 20
    },
    "date_range": {
      "from": "2026-06-01",
      "to": "2026-06-09"
    }
  },
  "meta": { "version": "2.0", "timestamp": "2026-06-09T10:30:00Z" }
}
```

---

## Domain 8: Quiz ✅ Already Implemented

See `QUIZ_API_SPECIFICATION.md` for full quiz API specification.

**Endpoints:**
- `GET /api/quiz/modules` — List all quiz modules
- `GET /api/quiz/module/{module_id}/questions` — Get all questions for module
- `GET /api/quiz/module/{module_id}/random` — Get randomized quiz (16 MCQ + 4 scenarios)

---

## Error Handling

### Standard Error Format
```json
{
  "error": "error_code",
  "message": "Human-readable message",
  "details": {
    "field1": "Field-specific error"
  }
}
```

### Common Error Codes

| Code | Status | Meaning |
|------|--------|---------|
| `unauthorized` | 401 | Missing or invalid JWT token |
| `forbidden` | 403 | User lacks permission |
| `not_found` | 404 | Resource not found |
| `validation_error` | 400 | Request validation failed |
| `duplicate_resource` | 409 | Resource already exists (e.g., email) |
| `invalid_state` | 400 | Operation invalid for current resource state |
| `server_error` | 500 | Internal server error |

---

## Rate Limiting

All endpoints are rate-limited:
- **Default:** 100 requests per 15 minutes per user
- **Burst:** 20 requests per minute
- **Headers returned:**
  - `X-RateLimit-Limit: 100`
  - `X-RateLimit-Remaining: 95`
  - `X-RateLimit-Reset: 2026-06-09T10:45:00Z`

**Error (429):** Too Many Requests
```json
{
  "error": "rate_limit_exceeded",
  "message": "Too many requests. Please try again in 5 minutes.",
  "retry_after_seconds": 300
}
```

---

## Pagination

Endpoints returning lists support pagination:

**Query Parameters:**
- `page=1` — Page number (default 1)
- `limit=20` — Items per page (default 20, max 100)

**Response:**
```json
{
  "data": {
    "items": [ /* array of items */ ],
    "total_count": 456,
    "page": 1,
    "limit": 20,
    "total_pages": 23
  }
}
```

---

## Versioning Strategy

API is versioned in URL path:
- **Current:** `/api/v2/` (all endpoints above)
- **Legacy:** `/api/v1/` (for backward compatibility during transition)
- **Future:** `/api/v3/` when breaking changes needed

---

## Implementation Status

| Domain | Status | Files | Notes |
|--------|--------|-------|-------|
| Auth & Users | ⚠️ Planning | AuthContext.tsx | JWT parsing, profile CRUD |
| Observations | ❌ Not Started | 14 files | Highest priority |
| Field Issues | ❌ Not Started | 2 files | Medium priority |
| Smart Schedule | ❌ Not Started | 1 file | Lower priority |
| Training & Content | ❌ Not Started | 2 files | Lower priority |
| User Roles | ❌ Not Started | 2 files | Medium priority |
| Analytics | ❌ Not Started | 1 file | Lower priority |
| Quiz | ✅ Implemented | quiz_controller.py | Complete |

---

**Document Version:** 1.0  
**Last Updated:** 2026-06-09  
**Next Update:** After Phase 1 (Auth) implementation complete
