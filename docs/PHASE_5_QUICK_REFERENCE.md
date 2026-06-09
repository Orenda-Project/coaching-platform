# Phase 5: Admin Management APIs — Quick Reference

## 3-Minute Overview

**What:** Admin management system for user administration, field issue tracking, and region hierarchy  
**Where:** `/api/admin/*` endpoints  
**When:** POST/GET/PUT/DELETE operations  
**Who:** System administrators  
**Why:** Manage coaches, track field issues, organize regions

## Files & Imports

```python
# Models
from app.models.admin import AdminUser, AdminRole, FieldIssue, FieldIssueStatus, Region

# Service
from app.services.admin_service import AdminService

# Controller
from app.controllers.admin_controller import router  # Already registered in main.py
```

## API Summary Table

### Admin Users (5 endpoints)
| Action | Endpoint | Method | Status |
|--------|----------|--------|--------|
| Create | /api/admin/users | POST | 201 |
| List | /api/admin/users | GET | 200 |
| Get | /api/admin/users/{id} | GET | 200 |
| Update role | /api/admin/users/{id}/role | PUT | 200 |
| Delete | /api/admin/users/{id} | DELETE | 204 |

### Field Issues (5 endpoints)
| Action | Endpoint | Method | Status |
|--------|----------|--------|--------|
| Create | /api/admin/issues | POST | 201 |
| List | /api/admin/issues | GET | 200 |
| Get | /api/admin/issues/{id} | GET | 200 |
| Update | /api/admin/issues/{id} | PUT | 200 |
| Delete | /api/admin/issues/{id} | DELETE | 204 |

**Filters:** `?status=open|in_progress|resolved|closed`

### Regions (5 endpoints)
| Action | Endpoint | Method | Status |
|--------|----------|--------|--------|
| Create | /api/admin/regions | POST | 201 |
| List | /api/admin/regions | GET | 200 |
| Get | /api/admin/regions/{id} | GET | 200 |
| Update | /api/admin/regions/{id} | PUT | 200 |
| Delete | /api/admin/regions/{id} | DELETE | 204 |

**Filters:** `?active_only=true`

## Curl Examples

### Create Admin
```bash
curl -X POST http://localhost:8000/api/admin/users \
  -H "Content-Type: application/json" \
  -d '{"user_id": "uuid", "role": "super_admin"}'
```

### Report Issue
```bash
curl -X POST http://localhost:8000/api/admin/issues \
  -H "Content-Type: application/json" \
  -d '{
    "description": "Teachers cannot access resources",
    "reported_by": "uuid"
  }'
```

### Create Region
```bash
curl -X POST http://localhost:8000/api/admin/regions \
  -H "Content-Type: application/json" \
  -d '{"name": "North Region"}'
```

### Update Issue Status
```bash
curl -X PUT http://localhost:8000/api/admin/issues/uuid \
  -H "Content-Type: application/json" \
  -d '{"status": "resolved"}'
```

## Database Models at a Glance

### AdminUser
```
┌─────────────────────┐
│   AdminUser         │
├─────────────────────┤
│ id: UUID (PK)       │
│ user_id: UUID (FK)  │
│ role: enum          │ ← super_admin, regional_admin
│ created_at          │
│ updated_at          │
└─────────────────────┘
```

### FieldIssue
```
┌──────────────────────────┐
│   FieldIssue             │
├──────────────────────────┤
│ id: UUID (PK)            │
│ description: text        │
│ status: enum             │ ← open, in_progress, resolved, closed
│ reported_by: UUID (FK)   │
│ assigned_to: UUID (FK?)  │
│ created_at               │
│ updated_at               │
│ resolved_at: (auto)      │ ← Set when status→resolved/closed
└──────────────────────────┘
```

### Region
```
┌──────────────────────────┐
│   Region                 │
├──────────────────────────┤
│ id: UUID (PK)            │
│ name: string (unique)    │
│ parent_id: UUID (FK?)    │ ← Self-referential for hierarchy
│ is_active: boolean       │
│ created_at               │
│ updated_at               │
└──────────────────────────┘
```

## Validation Rules

| Field | Rule | Error |
|-------|------|-------|
| role | super_admin OR regional_admin | 400 |
| description (issue) | min 10 chars | 422 |
| name (region) | min 2 chars, unique | 409 |
| status | open/in_progress/resolved/closed | 400 |
| limit (pagination) | 1-1000 | 422 |
| offset | ≥ 0 | 422 |

## Error Codes

| Code | Meaning |
|------|---------|
| 201 | Created ✓ |
| 204 | Deleted ✓ |
| 400 | Bad request (invalid role, status, etc.) |
| 404 | Not found |
| 409 | Conflict (duplicate admin, duplicate region name) |
| 422 | Validation error (Pydantic) |

## Testing

```bash
# Run all admin tests
pytest app/tests/test_admin_api.py -v

# Run specific test class
pytest app/tests/test_admin_api.py::TestAdminUserService -v
pytest app/tests/test_admin_api.py::TestFieldIssueAPI -v

# Run specific test
pytest app/tests/test_admin_api.py::TestAdminUserService::test_create_admin_user_super_admin -v
```

## Service Layer Usage

```python
from app.services.admin_service import AdminService
from sqlalchemy.orm import Session

def my_endpoint(db: Session):
    service = AdminService(db)
    
    # Create admin
    admin = service.create_admin_user("user-uuid", "super_admin")
    
    # List with pagination
    admins, total = service.get_all_admin_users(limit=100, offset=0)
    
    # Update
    updated = service.update_admin_user_role(admin.id, "regional_admin")
    
    # Delete
    success = service.delete_admin_user(admin.id)
```

## Pagination Pattern

```json
{
  "users": [...],
  "total": 42,
  "limit": 10,
  "offset": 0
}
```

**Usage:**
- Get page 1: `?limit=10&offset=0`
- Get page 2: `?limit=10&offset=10`
- Get page 3: `?limit=10&offset=20`

## Status Transitions for Issues

```
OPEN
  ↓
IN_PROGRESS (resolved_at: null)
  ↓
RESOLVED (resolved_at: auto-set to now)
  ↓
CLOSED (resolved_at: kept from RESOLVED)
```

**Note:** Any status → RESOLVED or CLOSED automatically sets `resolved_at` timestamp.

## Unique Constraints

| Field | Constraint |
|-------|-----------|
| admin_users.user_id | UNIQUE |
| regions.name | UNIQUE |
| (none for field_issues) | — |

## Foreign Keys

| Field | References | Behavior |
|-------|-----------|----------|
| admin_users.user_id | users.id | ON DELETE CASCADE |
| field_issues.reported_by | users.id | ON DELETE RESTRICT |
| field_issues.assigned_to | users.id | ON DELETE SET NULL |
| regions.parent_id | regions.id | ON DELETE SET NULL |

## Common Workflows

### Onboard a Regional Admin
```python
service = AdminService(db)

# 1. Create user (via auth_service)
user = auth_service.create_user("email@example.com")

# 2. Make them admin
admin = service.create_admin_user(user.id, "regional_admin")

# 3. Assign to region (manual link in app)
region = service.get_region_by_name("Punjab")
# ... store assignment in your own table or profile
```

### Track an On-Ground Issue
```python
# 1. Report issue
issue = service.create_field_issue(
    description="Teachers in X location need training",
    reported_by=reporter_id,
    assigned_to=admin_id
)

# 2. Update status as work progresses
service.update_field_issue(issue.id, status="in_progress")
service.update_field_issue(issue.id, status="resolved")
# resolved_at auto-set!

# 3. Query resolved issues
resolved, count = service.get_all_field_issues(status="resolved")
```

### Manage Region Hierarchy
```python
# Create country
pk = service.create_region("Pakistan")

# Create provinces (children)
punjab = service.create_region("Punjab", parent_id=pk.id)
sindh = service.create_region("Sindh", parent_id=pk.id)

# Create districts (sub-children)
lahore = service.create_region("Lahore", parent_id=punjab.id)
karachi = service.create_region("Karachi", parent_id=sindh.id)

# Query active regions
active, count = service.get_all_regions(active_only=True)
```

## Test Coverage

- **Service Tests:** 27 tests (create, read, update, delete, pagination, filtering)
- **API Tests:** 13 tests (endpoint validation, response format)
- **Error Tests:** 4 tests (404, 409, 422, 400)
- **Total:** 40+ test cases

## Integration Checklist

- [ ] Created models (AdminUser, FieldIssue, Region)
- [ ] Created service (AdminService with 12 methods)
- [ ] Created controller (12 endpoints)
- [ ] Updated __init__.py files
- [ ] Updated main.py router registration
- [ ] Written 40+ tests
- [ ] All tests passing ✓
- [ ] Created migration file (future)
- [ ] Deployed to staging (future)

## File Locations

```
/coaching-api/
├── app/models/admin.py
├── app/services/admin_service.py
├── app/controllers/admin_controller.py
└── app/tests/test_admin_api.py
```

## Related Documentation

- Full spec: `docs/PHASE_5_ADMIN_MANAGEMENT_API.md`
- Phase 1 pattern: `docs/PHASE_1_DOCUMENTATION_INDEX.md`
- Deployment: `docs/DEPLOYMENT.md`
