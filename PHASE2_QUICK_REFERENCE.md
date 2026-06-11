# Phase 2 Quick Reference Guide

**TL;DR:** Assessment & Training APIs implemented with 102 tests, 20 service methods, 18 endpoints.

---

## 🚀 Quick Start

### Imports

```python
from app.services.assessment_service import AssessmentService
from app.services.training_service import TrainingService
from app.models import Assessment, AssessmentResponse, TrainingProgress
```

### Create & Grade Assessment

```python
# Create
assessment = AssessmentService(db).create_assessment("user-id", "module-id")

# Submit
AssessmentService(db).submit_assessment(assessment.id, [
    {"question_id": "q1", "user_answer": "A"},
])

# Grade
result = AssessmentService(db).evaluate_responses(
    assessment.id,
    {"q1": "A", "q2": "B"}
)
print(f"Score: {result.score}, Passed: {result.score >= 80}")

# Get results
results = AssessmentService(db).get_assessment_results(assessment.id)
```

### Track Progress

```python
# Create/Update progress
TrainingService(db).create_progress("user-id", "training-id")
TrainingService(db).update_progress("user-id", "training-id", 50.0)

# Mark complete
TrainingService(db).mark_complete("user-id", "training-id")

# Check progress
progress = TrainingService(db).get_user_progress("user-id", "training-id")
print(f"Complete: {progress.is_completed}")

# Module stats
stats = TrainingService(db).get_module_progress("user-id", "module-id")
print(f"Progress: {stats['overall_progress']}%")
```

---

## 📊 API Endpoints

### Assessments

```bash
# Create
POST /api/assessments?user_id=xxx&module_id=yyy

# Get
GET /api/assessments/{id}

# List
GET /api/assessments/user/{user_id}?limit=100&offset=0

# Submit
POST /api/assessments/{id}/submit
{ "responses": [{"question_id": "q1", "user_answer": "A"}] }

# Grade
POST /api/assessments/{id}/evaluate
{ "answer_key": {"q1": "A"} }

# Results
GET /api/assessments/{id}/results

# History
GET /api/assessments/user/{user_id}/history?limit=10

# Update
PUT /api/assessments/{id}?score=85&status=graded

# Delete
DELETE /api/assessments/{id}

# Module assessments
GET /api/assessments/module/{module_id}
```

### Training

```bash
# List all
GET /api/training?limit=100&offset=0

# Get one
GET /api/training/{id}

# Module trainings
GET /api/training/module/{module_id}

# Create progress
POST /api/training/progress?user_id=xxx&training_id=yyy

# Get progress
GET /api/training/progress/{user_id}/{training_id}

# Update progress
PUT /api/training/progress/{user_id}/{training_id}
{ "progress_percentage": 50.0 }

# Mark complete
POST /api/training/progress/{user_id}/{training_id}/complete

# Reset
POST /api/training/progress/{user_id}/{training_id}/reset

# User progress
GET /api/training/user/{user_id}

# Module progress
GET /api/training/module/{module_id}/progress/{user_id}

# Delete progress
DELETE /api/training/progress/{user_id}/{training_id}
```

---

## 🗂️ File Structure

```
app/
├── models/
│   ├── assessment.py          # Assessment, AssessmentResponse, AssessmentAttempt
│   └── training_progress.py   # TrainingProgress
├── services/
│   ├── assessment_service.py  # AssessmentService (11 methods)
│   └── training_service.py    # TrainingService (11 methods)
├── controllers/
│   ├── assessment_controller.py  # 10 endpoints
│   └── training_controller.py    # 10 endpoints
└── tests/
    ├── test_assessment_service_unit.py  # 38 unit tests
    ├── test_training_service_unit.py    # 42 unit tests
    ├── test_assessment_api.py           # 11 integration tests
    ├── test_training_api.py             # 11 integration tests
    └── conftest.py                      # Shared fixtures
```

---

## 🧪 Testing

```bash
# Run all tests
pytest app/tests/test_assessment*.py app/tests/test_training*.py -v

# Run specific test
pytest app/tests/test_assessment_service_unit.py::TestAssessmentServiceCreation -v

# With coverage
pytest app/tests/ --cov=app/services --cov=app/controllers
```

---

## 💡 Key Methods

### AssessmentService

| Method | Returns | Notes |
|--------|---------|-------|
| `create_assessment(user_id, module_id)` | Assessment | Creates new assessment |
| `get_assessment(id)` | Optional[Assessment] | With relationships |
| `get_user_assessments(user_id)` | tuple[List, int] | Paginated, ordered by date |
| `submit_assessment(id, responses)` | Optional[Assessment] | Creates responses |
| `evaluate_responses(id, answer_key)` | Optional[Assessment] | Grades & scores |
| `check_pass_fail(score, threshold=80)` | bool | Simple threshold |
| `get_assessment_results(id)` | Optional[Dict] | Comprehensive results |
| `get_assessment_history(user_id)` | List[Assessment] | Recent N assessments |
| `create_attempt(id, score, passed)` | Optional[AssessmentAttempt] | Retry tracking |
| `update_assessment(id, **kwargs)` | Optional[Assessment] | score, status, attempt_number |
| `delete_assessment(id)` | bool | Cascades to responses |
| `get_module_assessments(module_id)` | tuple[List, int] | For analytics |

### TrainingService

| Method | Returns | Notes |
|--------|---------|-------|
| `get_training(id)` | Optional[Training] | With content |
| `get_module_trainings(module_id)` | tuple[List, int] | Paginated, by order |
| `get_all_trainings()` | tuple[List, int] | All trainings, paginated |
| `create_progress(user_id, training_id)` | Optional[TrainingProgress] | Or returns existing |
| `get_user_progress(user_id, training_id)` | Optional[TrainingProgress] | None if not found |
| `update_progress(user_id, training_id, %)` | Optional[TrainingProgress] | Clamped 0-100 |
| `mark_complete(user_id, training_id)` | Optional[TrainingProgress] | 100%, timestamp set |
| `get_user_all_progress(user_id)` | tuple[List, int] | All progress for user |
| `get_module_progress(user_id, module_id)` | Dict | Stats: total, completed, % |
| `delete_progress(user_id, training_id)` | bool | Deletes record |
| `reset_progress(user_id, training_id)` | Optional[TrainingProgress] | Back to 0% |

---

## 🔍 Examples

### Complete Workflow

```python
# 1. Create assessment
service = AssessmentService(db)
assessment = service.create_assessment("user-123", "module-456")

# 2. User submits answers
service.submit_assessment(assessment.id, [
    {"question_id": "q1", "user_answer": "A"},
    {"question_id": "q2", "user_answer": "B"},
    {"question_id": "q3", "user_answer": "C"},
])

# 3. Grade assessment
service.evaluate_responses(assessment.id, {
    "q1": "A",  # Correct
    "q2": "X",  # Wrong (correct is "B")
    "q3": "C",  # Correct
})

# 4. Get results
results = service.get_assessment_results(assessment.id)
assert results["score"] == 66.67  # 2 out of 3
assert results["passed"] is False  # < 80%
assert results["correct_responses"] == 2
```

### Training Progress

```python
# 1. User starts training
service = TrainingService(db)
service.create_progress("user-123", "training-456")

# 2. User watches content (50% complete)
service.update_progress("user-123", "training-456", 50.0)

# 3. User completes training
service.mark_complete("user-123", "training-456")

# 4. Check module progress (if module has 3 trainings)
stats = service.get_module_progress("user-123", "module-789")
# Returns: {
#   "module_id": "module-789",
#   "total_trainings": 3,
#   "completed_trainings": 1,
#   "overall_progress": 33.33
# }
```

---

## ⚠️ Error Handling

All service methods return `None` on error (no exceptions thrown):

```python
result = AssessmentService(db).create_assessment("user", "module")
if result is None:
    # Handle error (likely IntegrityError)
    return {"error": "Failed to create assessment"}

return {"assessment": result.to_dict()}
```

Controllers catch these and return 400/404/500:

```python
assessment = service.create_assessment(user_id, module_id)
if not assessment:
    raise HTTPException(status_code=400, detail="Failed to create assessment")
```

---

## 📝 Database Impact

New tables created by migrations:
- `assessments` - Quiz attempts
- `assessment_responses` - Individual answers
- `assessment_attempts` - Retry history
- `training_progress` - User progress tracking

Indexes created on:
- `assessments(user_id, module_id)`
- `assessment_responses(assessment_id, question_id)`
- `training_progress(user_id, training_id)`

---

## 🔄 Patterns (From Phase 1)

1. **Service Layer:** Business logic in services, not controllers
2. **Error Handling:** IntegrityError → return None, not exception
3. **Timestamps:** Auto-set server-side (created_at, updated_at)
4. **Pagination:** limit/offset, returns (list, total)
5. **Cascades:** Delete parent → deletes children
6. **Type Hints:** All methods have full type hints
7. **Docstrings:** All classes/methods documented
8. **Pydantic Models:** Request/response validation

---

## 📦 Dependencies

All dependencies already in requirements.txt:
- FastAPI
- SQLAlchemy
- Pydantic
- pytest

No new dependencies needed!

---

## ✅ Checklist

Before using in production:

- [ ] Run migrations to create new tables
- [ ] Run all tests: `pytest app/tests/`
- [ ] Check API docs at `/docs`
- [ ] Test with frontend integration
- [ ] Verify cascading deletes work
- [ ] Check pagination with large datasets
- [ ] Load test with realistic data volume

---

## 🐛 Debugging

### Check assessment status flow

```python
assessment = service.get_assessment("id")
print(f"Status: {assessment.status}")
print(f"Responses: {len(assessment.responses)}")
print(f"Score: {assessment.score}")
```

### Check progress clamping

```python
# Try to set progress > 100
service.update_progress("user", "training", 150.0)
progress = service.get_user_progress("user", "training")
assert progress.progress_percentage == 100.0  # Clamped!
```

### List assessments for debugging

```python
assessments, total = service.get_user_assessments("user-id", limit=1000)
for a in assessments:
    print(f"{a.id}: {a.status} - {a.score}")
```

---

## 📚 Documentation

- Full details: `PHASE2_IMPLEMENTATION_COMPLETE.md`
- Phase 1 pattern: `/docs/PHASE1_AUTH_IMPLEMENTATION.md`
- API schema: Swagger at `/docs`

---

**Version:** 1.0  
**Date:** 2026-06-09  
**Status:** Complete & Tested ✅
