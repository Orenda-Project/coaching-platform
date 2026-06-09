# Test Strategy for Supabase → API Migration

**Project:** Coaching Platform REST API Migration  
**Status:** Planning Phase  
**Test Lead:** TBD  
**Target Coverage:** >85% (critical paths >95%)  

---

## Overview

This document defines comprehensive testing strategy for migrating 50+ files from Supabase to REST API. Testing is organized in three layers:

1. **Unit Tests** — Individual functions/methods in isolation
2. **Integration Tests** — API endpoints + Database interactions
3. **E2E Tests** — Complete user workflows end-to-end

---

## Testing Pyramid

```
                    E2E Tests (10%)
                 /      |      \
              Auth    Obs.    Quiz
             /    Integration Tests (30%)
          /       /      |      \
      Unit Tests (60%)  API Endpoints + DB
         /  |  \
      API  Hooks  Service
     Client Methods Functions
```

---

## Part 1: Unit Tests

### 1.1 Backend Unit Tests (Python + pytest)

**Location:** `coaching-api/tests/unit/`

#### Pattern: Service Layer Testing

```python
# File: tests/unit/test_user_service.py
import pytest
from app.services.user_service import UserService
from app.models.user import User

@pytest.fixture
def user_service(db_session):
    return UserService(db_session)

@pytest.fixture
def sample_user(db_session):
    user = User(
        id="test-user-123",
        email="test@example.com",
        phone="+923001234567",
        full_name="Test User",
        role="coach"
    )
    db_session.add(user)
    db_session.commit()
    return user

class TestUserService:
    def test_get_profile_success(self, user_service, sample_user):
        """Test successful profile fetch"""
        user = user_service.get_profile(sample_user.id)
        assert user.id == sample_user.id
        assert user.email == "test@example.com"

    def test_get_profile_not_found(self, user_service):
        """Test profile not found returns None"""
        user = user_service.get_profile("nonexistent-id")
        assert user is None

    def test_update_profile_success(self, user_service, sample_user):
        """Test profile update"""
        updated = user_service.update_profile(sample_user.id, {
            "phone": "+923009999999",
            "full_name": "Updated Name"
        })
        assert updated.phone == "+923009999999"
        assert updated.full_name == "Updated Name"

    def test_update_profile_invalid_phone(self, user_service, sample_user):
        """Test invalid phone format rejected"""
        with pytest.raises(ValueError):
            user_service.update_profile(sample_user.id, {
                "phone": "invalid-phone"
            })

    def test_update_profile_duplicate_phone(self, user_service, sample_user, db_session):
        """Test duplicate phone rejected"""
        # Create another user with phone
        other_user = User(
            id="other-user",
            email="other@example.com",
            phone="+923008888888",
            role="coach"
        )
        db_session.add(other_user)
        db_session.commit()

        # Try to update first user to same phone
        with pytest.raises(IntegrityError):
            user_service.update_profile(sample_user.id, {
                "phone": "+923008888888"
            })

    def test_get_user_role_success(self, user_service, sample_user):
        """Test role retrieval"""
        role = user_service.get_user_role(sample_user.id)
        assert role == "coach"

    def test_get_user_role_not_found(self, user_service):
        """Test role for nonexistent user returns None"""
        role = user_service.get_user_role("nonexistent-id")
        assert role is None
```

#### Pattern: Controller/Router Testing

```python
# File: tests/unit/test_user_controller.py
from fastapi.testclient import TestClient
from app.main import app
import json

client = TestClient(app)

class TestUserController:
    def test_get_profile_success(self, auth_headers):
        """Test GET /api/users/profile"""
        response = client.get(
            "/api/users/profile",
            headers=auth_headers
        )
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "success"
        assert "data" in data
        assert data["data"]["email"] == "test@example.com"

    def test_get_profile_unauthorized(self):
        """Test GET /api/users/profile without auth"""
        response = client.get("/api/users/profile")
        assert response.status_code == 401
        assert response.json()["error"] == "unauthorized"

    def test_update_profile_success(self, auth_headers):
        """Test PUT /api/users/profile"""
        response = client.put(
            "/api/users/profile",
            headers=auth_headers,
            json={
                "phone": "+923009999999",
                "full_name": "Updated Name"
            }
        )
        assert response.status_code == 200
        data = response.json()["data"]
        assert data["phone"] == "+923009999999"
        assert data["full_name"] == "Updated Name"

    def test_update_profile_invalid_phone(self, auth_headers):
        """Test validation error"""
        response = client.put(
            "/api/users/profile",
            headers=auth_headers,
            json={"phone": "invalid"}
        )
        assert response.status_code == 400
        assert response.json()["error"] == "validation_error"
```

#### Pattern: Service Layer for Observations

```python
# File: tests/unit/test_observation_service.py
class TestObservationService:
    def test_list_observations_coach_view(self, obs_service, coach_user, sample_observations):
        """Coach sees only their observations"""
        obs_list = obs_service.list_observations(
            user_id=coach_user.id,
            role="coach",
            skip=0,
            limit=20
        )
        # Should only see observations where coach is observer
        assert all(o.observer_id == coach_user.id for o in obs_list)

    def test_list_observations_admin_view(self, obs_service, admin_user, sample_observations):
        """Admin sees all observations"""
        obs_list = obs_service.list_observations(
            user_id=admin_user.id,
            role="super_admin",
            skip=0,
            limit=20
        )
        # Should see all observations
        assert len(obs_list) == len(sample_observations)

    def test_create_observation(self, obs_service, coach_user, teacher_user):
        """Test creating new observation"""
        obs = obs_service.create_observation(
            user_id=coach_user.id,
            data={
                "teacher_id": teacher_user.id,
                "school": "Test School",
                "grade": "Grade 5"
            }
        )
        assert obs.id is not None
        assert obs.observer_id == coach_user.id
        assert obs.status == "Draft"

    def test_update_hots_rubric(self, obs_service, sample_observation):
        """Test HOTS rubric update"""
        rubric = {
            "domain_1": 3,
            "domain_2": 4,
            "domain_3": 3
        }
        updated = obs_service.update_hots_rubric(sample_observation.id, rubric)
        assert updated.hots_rubric == rubric

    def test_delete_observation_draft(self, obs_service, sample_draft_observation):
        """Test deleting draft observation"""
        obs_service.delete_observation(sample_draft_observation.id)
        obs = db.query(CotObservation).filter(
            CotObservation.id == sample_draft_observation.id
        ).first()
        assert obs is None

    def test_delete_observation_submitted_fails(self, obs_service, sample_submitted_observation):
        """Test cannot delete submitted observation"""
        with pytest.raises(HTTPException) as exc:
            obs_service.delete_observation(sample_submitted_observation.id)
        assert exc.value.status_code == 400
```

### 1.2 Frontend Unit Tests (Vitest + TypeScript)

**Location:** `src/tests/unit/`

#### Pattern: API Client Testing

```typescript
// File: tests/unit/userApiClient.test.ts
import { describe, it, expect, beforeEach, vi } from "vitest";
import { UserApiClient } from "@/lib/userApiClient";

describe("UserApiClient", () => {
  let client: UserApiClient;

  beforeEach(() => {
    client = new UserApiClient("http://localhost:8000");
    // Mock fetch
    global.fetch = vi.fn();
  });

  it("should fetch profile successfully", async () => {
    const mockProfile = {
      id: "user-123",
      email: "test@example.com",
      phone: "+923001234567",
      full_name: "Test User",
      role: "coach",
    };

    (global.fetch as any).mockResolvedValueOnce({
      ok: true,
      json: async () => ({
        status: "success",
        data: mockProfile,
      }),
    });

    const profile = await client.getProfile();
    expect(profile).toEqual(mockProfile);
  });

  it("should throw error on fetch failure", async () => {
    (global.fetch as any).mockResolvedValueOnce({
      ok: false,
      json: async () => ({
        error: "not_found",
        message: "Profile not found",
      }),
    });

    await expect(client.getProfile()).rejects.toThrow("Profile not found");
  });

  it("should include auth header", async () => {
    (global.fetch as any).mockResolvedValueOnce({
      ok: true,
      json: async () => ({ status: "success", data: {} }),
    });

    await client.getProfile();

    const call = (global.fetch as any).mock.calls[0];
    expect(call[1].headers).toHaveProperty("Authorization");
    expect(call[1].headers.Authorization).toMatch(/^Bearer /);
  });

  it("should retry on 5xx error", async () => {
    (global.fetch as any)
      .mockResolvedValueOnce({
        status: 500,
        ok: false,
        json: async () => ({ error: "server_error" }),
      })
      .mockResolvedValueOnce({
        status: 200,
        ok: true,
        json: async () => ({ status: "success", data: {} }),
      });

    const profile = await client.getProfile();

    expect((global.fetch as any).mock.calls.length).toBe(2);
    expect(profile).toBeDefined();
  });
});
```

#### Pattern: Hook Testing

```typescript
// File: tests/unit/useProfile.test.ts
import { describe, it, expect, beforeEach, vi } from "vitest";
import { renderHook, act } from "@testing-library/react";
import { useProfile } from "@/hooks/useProfile";

describe("useProfile", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("should fetch profile on mount", async () => {
    const { result } = renderHook(() => useProfile());

    expect(result.current.loading).toBe(true);

    // Wait for async operation
    await act(async () => {
      await new Promise((r) => setTimeout(r, 100));
    });

    expect(result.current.loading).toBe(false);
    expect(result.current.profile).toBeDefined();
  });

  it("should update profile", async () => {
    const { result } = renderHook(() => useProfile());

    await act(async () => {
      await result.current.updateProfile({ phone: "+923009999999" });
    });

    expect(result.current.profile.phone).toBe("+923009999999");
  });

  it("should handle error gracefully", async () => {
    // Mock API failure
    const { result } = renderHook(() => useProfile());

    await act(async () => {
      try {
        await result.current.updateProfile({ phone: "invalid" });
      } catch (e) {
        // Expected to fail
      }
    });

    expect(result.current.error).toBeDefined();
  });
});
```

---

## Part 2: Integration Tests

### 2.1 API Endpoint Testing

**Location:** `coaching-api/tests/integration/`

#### Pattern: Full Endpoint Test with DB

```python
# File: tests/integration/test_user_api.py
import pytest
from fastapi.testclient import TestClient
from app.main import app
from app.models.user import User

client = TestClient(app)

@pytest.fixture
def test_user(db_session):
    """Create test user in DB"""
    user = User(
        id="test-user-123",
        email="test@example.com",
        phone="+923001234567",
        full_name="Test User",
        role="coach",
        region="Karachi"
    )
    db_session.add(user)
    db_session.commit()
    return user

@pytest.fixture
def auth_token(test_user):
    """Generate JWT token for test user"""
    return create_jwt_token(test_user.id, test_user.role)

class TestUserAPI:
    def test_profile_workflow(self, auth_token, db_session):
        """Test complete profile workflow: fetch → update → verify"""
        
        # Step 1: Fetch profile
        response = client.get(
            "/api/users/profile",
            headers={"Authorization": f"Bearer {auth_token}"}
        )
        assert response.status_code == 200
        data = response.json()["data"]
        assert data["email"] == "test@example.com"

        # Step 2: Update profile
        response = client.put(
            "/api/users/profile",
            headers={"Authorization": f"Bearer {auth_token}"},
            json={
                "phone": "+923009999999",
                "full_name": "Updated Name",
                "region": "Islamabad"
            }
        )
        assert response.status_code == 200
        updated = response.json()["data"]
        assert updated["phone"] == "+923009999999"
        assert updated["region"] == "Islamabad"

        # Step 3: Verify in DB
        user = db_session.query(User).filter(User.id == "test-user-123").first()
        assert user.phone == "+923009999999"
        assert user.full_name == "Updated Name"

    def test_phone_uniqueness_constraint(self, auth_token, db_session):
        """Test duplicate phone is rejected"""
        
        # Create another user
        other_user = User(
            id="other-user",
            email="other@example.com",
            phone="+923008888888",
            role="teacher"
        )
        db_session.add(other_user)
        db_session.commit()

        # Try to update test user to same phone
        response = client.put(
            "/api/users/profile",
            headers={"Authorization": f"Bearer {auth_token}"},
            json={"phone": "+923008888888"}
        )
        assert response.status_code == 409
        assert response.json()["error"] == "duplicate_phone"
```

#### Pattern: Observation API Test

```python
# File: tests/integration/test_observation_api.py
class TestObservationAPI:
    def test_observation_complete_workflow(self, coach_token, teacher_user, db_session):
        """Test: create → view → edit rubric → submit → delete fails"""
        
        # Step 1: Create observation
        response = client.post(
            "/api/observations",
            headers={"Authorization": f"Bearer {coach_token}"},
            json={
                "teacher_id": teacher_user.id,
                "school": "Test School",
                "grade": "Grade 5"
            }
        )
        assert response.status_code == 201
        obs_id = response.json()["data"]["id"]

        # Step 2: View observation
        response = client.get(
            f"/api/observations/{obs_id}",
            headers={"Authorization": f"Bearer {coach_token}"}
        )
        assert response.status_code == 200
        obs = response.json()["data"]
        assert obs["status"] == "Draft"

        # Step 3: Update HOTS rubric
        response = client.patch(
            f"/api/observations/{obs_id}/rubric/hots",
            headers={"Authorization": f"Bearer {coach_token}"},
            json={
                "domain_1": 3,
                "domain_2": 4,
                "domain_3": 3
            }
        )
        assert response.status_code == 200
        assert response.json()["data"]["hots_rubric"]["domain_1"] == 3

        # Step 4: Update status to Submitted
        response = client.patch(
            f"/api/observations/{obs_id}/status",
            headers={"Authorization": f"Bearer {coach_token}"},
            json={"status": "Submitted"}
        )
        assert response.status_code == 200

        # Step 5: Try to delete (should fail)
        response = client.delete(
            f"/api/observations/{obs_id}",
            headers={"Authorization": f"Bearer {coach_token}"}
        )
        assert response.status_code == 400
        assert response.json()["error"] == "invalid_state"
```

### 2.2 Database Migration Testing

**Location:** `coaching-api/tests/integration/`

```python
# File: tests/integration/test_migrations.py
"""Verify migrations don't break existing data"""

def test_migration_user_table(db_session):
    """Verify profiles table schema after migration"""
    user = User(
        id="test",
        email="test@example.com",
        phone="+923001234567",
        full_name="Test",
        role="coach",
        region="Karachi"
    )
    db_session.add(user)
    db_session.commit()

    # Verify all columns exist and work
    fetched = db_session.query(User).filter(User.id == "test").first()
    assert fetched.email == "test@example.com"
    assert fetched.phone == "+923001234567"
    assert fetched.role == "coach"
    assert fetched.created_at is not None
    assert fetched.updated_at is not None
```

---

## Part 3: E2E Tests

### 3.1 Cypress E2E Tests

**Location:** `tests/e2e/`

#### Pattern: Auth Flow E2E

```typescript
// File: tests/e2e/auth.e2e.test.ts
describe("Auth E2E", () => {
  beforeEach(() => {
    cy.visit("/");
  });

  it("should complete signup → profile loaded flow", () => {
    // Navigate to signup
    cy.get("[data-testid=signup-link]").click();
    cy.url().should("include", "/signup");

    // Fill signup form
    cy.get("[data-testid=email-input]").type("newuser@example.com");
    cy.get("[data-testid=password-input]").type("SecurePassword123!");
    cy.get("[data-testid=phone-input]").type("+923001234567");
    cy.get("[data-testid=fullname-input]").type("New User");

    // Submit
    cy.get("[data-testid=signup-submit]").click();

    // Verify redirected to dashboard
    cy.url().should("include", "/dashboard");

    // Verify profile loaded
    cy.get("[data-testid=profile-name]").should("contain", "New User");
    cy.get("[data-testid=profile-email]").should("contain", "newuser@example.com");
  });

  it("should complete login flow", () => {
    // Navigate to login
    cy.get("[data-testid=login-link]").click();

    // Fill login form
    cy.get("[data-testid=email-input]").type("test@example.com");
    cy.get("[data-testid=password-input]").type("TestPassword123!");

    // Submit
    cy.get("[data-testid=login-submit]").click();

    // Verify redirected to dashboard
    cy.url().should("include", "/dashboard");

    // Verify profile visible
    cy.get("[data-testid=user-menu]").should("be.visible");
  });

  it("should update profile via API", () => {
    // Login first
    cy.login("test@example.com", "TestPassword123!");

    // Navigate to profile
    cy.get("[data-testid=user-menu]").click();
    cy.get("[data-testid=profile-link]").click();

    // Update profile
    cy.get("[data-testid=phone-input]").clear().type("+923009999999");
    cy.get("[data-testid=fullname-input]").clear().type("Updated Name");
    cy.get("[data-testid=save-button]").click();

    // Verify success message
    cy.get("[data-testid=success-toast]").should("contain", "Profile updated");

    // Refresh and verify persisted
    cy.reload();
    cy.get("[data-testid=profile-name]").should("contain", "Updated Name");
  });
});
```

#### Pattern: Observation Flow E2E

```typescript
// File: tests/e2e/observation.e2e.test.ts
describe("Observation E2E", () => {
  beforeEach(() => {
    cy.login("coach@example.com", "CoachPassword123!");
    cy.visit("/coaching");
  });

  it("should complete observation workflow", () => {
    // Step 1: Create observation
    cy.get("[data-testid=create-observation]").click();
    cy.get("[data-testid=teacher-select]").click();
    cy.get("[data-testid=teacher-option-1]").click();
    cy.get("[data-testid=school-input]").type("ABC School");
    cy.get("[data-testid=grade-select]").select("Grade 5");
    cy.get("[data-testid=create-button]").click();

    // Verify observation created
    cy.get("[data-testid=observation-form]").should("be.visible");

    // Step 2: Fill HOTS rubric
    cy.get("[data-testid=hots-domain1]").select("3");
    cy.get("[data-testid=hots-domain2]").select("4");
    cy.get("[data-testid=hots-domain3]").select("3");
    cy.get("[data-testid=save-hots]").click();
    cy.get("[data-testid=success-toast]").should("contain", "HOTS scores saved");

    // Step 3: Fill FICO rubric
    cy.get("[data-testid=fico-clarity]").select("4");
    cy.get("[data-testid=fico-engagement]").select("3");
    cy.get("[data-testid=fico-pacing]").select("4");
    cy.get("[data-testid=save-fico]").click();
    cy.get("[data-testid=success-toast]").should("contain", "FICO scores saved");

    // Step 4: Add debrief notes
    cy.get("[data-testid=hots-notes]").type("Excellent questioning technique. Consider more wait time.");
    cy.get("[data-testid=save-debrief]").click();
    cy.get("[data-testid=success-toast]").should("contain", "Debrief saved");

    // Step 5: Submit observation
    cy.get("[data-testid=submit-button]").click();
    cy.get("[data-testid=confirm-submit]").click();
    cy.get("[data-testid=success-toast]").should("contain", "Observation submitted");

    // Step 6: Verify in list
    cy.get("[data-testid=observation-list]").should("be.visible");
    cy.get("[data-testid=observation-item-submitted]").should("exist");
  });

  it("should prevent deletion of submitted observation", () => {
    // Find submitted observation
    cy.get("[data-testid=observation-submitted-row]").first().within(() => {
      cy.get("[data-testid=menu-button]").click();
      cy.get("[data-testid=delete-option]").click();
    });

    // Verify error
    cy.get("[data-testid=error-toast]").should(
      "contain",
      "Cannot delete submitted observation"
    );
  });

  it("should allow deletion of draft observation", () => {
    // Find draft observation
    cy.get("[data-testid=observation-draft-row]").first().within(() => {
      cy.get("[data-testid=menu-button]").click();
      cy.get("[data-testid=delete-option]").click();
    });

    // Confirm deletion
    cy.get("[data-testid=confirm-delete]").click();

    // Verify success
    cy.get("[data-testid=success-toast]").should("contain", "Observation deleted");

    // Verify removed from list
    cy.get("[data-testid=observation-draft-row]").should("not.exist");
  });
});
```

### 3.2 Performance E2E Tests

```typescript
// File: tests/e2e/performance.e2e.test.ts
describe("Performance E2E", () => {
  it("should load observations list in < 2 seconds", () => {
    cy.login("coach@example.com", "CoachPassword123!");

    const startTime = performance.now();
    cy.visit("/coaching/observations");
    cy.get("[data-testid=observation-list]").should("be.visible");
    const endTime = performance.now();

    expect(endTime - startTime).toBeLessThan(2000);
  });

  it("should save rubric scores in < 1 second", () => {
    cy.login("coach@example.com", "CoachPassword123!");
    cy.visit("/coaching/observations/obs-123");

    const startTime = performance.now();
    cy.get("[data-testid=hots-domain1]").select("3");
    cy.get("[data-testid=save-hots]").click();
    cy.get("[data-testid=success-toast]").should("be.visible");
    const endTime = performance.now();

    expect(endTime - startTime).toBeLessThan(1000);
  });
});
```

---

## Test Execution Strategy

### Phase 1: Auth Tests

```bash
# Backend unit tests
cd coaching-api
pytest tests/unit/test_user_service.py -v
pytest tests/unit/test_user_controller.py -v

# Backend integration tests
pytest tests/integration/test_user_api.py -v

# Frontend unit tests
npm run test -- useProfile.test.ts userApiClient.test.ts

# E2E tests
npm run test:e2e -- tests/e2e/auth.e2e.test.ts
```

### Phase 2: Observations Tests

```bash
# Backend tests
pytest tests/unit/test_observation_service.py -v
pytest tests/integration/test_observation_api.py -v

# Frontend tests
npm run test -- useObservations.test.ts observationApiClient.test.ts

# E2E tests
npm run test:e2e -- tests/e2e/observation.e2e.test.ts
```

### Full Test Suite

```bash
# Run all tests
npm run test:full

# With coverage
npm run test:full -- --coverage

# Per-domain
npm run test:auth
npm run test:observations
npm run test:quiz
npm run test:analytics
```

---

## Test Data Management

### Fixtures & Seeding

```python
# File: coaching-api/tests/conftest.py (shared fixtures)
@pytest.fixture
def coach_user(db_session):
    """Create coach user"""
    coach = User(
        id="coach-123",
        email="coach@example.com",
        phone="+923001111111",
        full_name="Coach Ali",
        role="coach"
    )
    db_session.add(coach)
    db_session.commit()
    return coach

@pytest.fixture
def teacher_user(db_session):
    """Create teacher user"""
    teacher = User(
        id="teacher-123",
        email="teacher@example.com",
        phone="+923002222222",
        full_name="Teacher Fatima",
        role="teacher"
    )
    db_session.add(teacher)
    db_session.commit()
    return teacher

@pytest.fixture
def sample_observation(db_session, coach_user, teacher_user):
    """Create sample observation"""
    obs = CotObservation(
        observer_id=coach_user.id,
        teacher_id=teacher_user.id,
        school="Test School",
        grade="Grade 5",
        status="Draft"
    )
    db_session.add(obs)
    db_session.commit()
    return obs

@pytest.fixture
def auth_token(coach_user):
    """Generate JWT token"""
    return create_jwt_token(coach_user.id, coach_user.role)
```

### Cleanup

```python
# Automatic cleanup in pytest
@pytest.fixture(autouse=True)
def cleanup(db_session):
    yield
    db_session.rollback()  # Rollback all changes after each test
```

---

## Coverage Goals

| Layer | Target | Tool |
|-------|--------|------|
| Backend Unit | >90% | pytest-cov |
| Frontend Unit | >85% | vitest --coverage |
| Integration | >80% | pytest + testclient |
| E2E | Critical paths | Cypress |

---

## Continuous Integration

### GitHub Actions Workflow

```yaml
# .github/workflows/test.yml
name: Test

on: [push, pull_request]

jobs:
  backend-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-python@v4
        with:
          python-version: 3.13
      - run: pip install -r coaching-api/requirements.txt
      - run: cd coaching-api && pytest --cov

  frontend-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: 18
      - run: npm install
      - run: npm run test -- --coverage
      - run: npm run test:e2e

  integration-tests:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_DB: test_db
    steps:
      - uses: actions/checkout@v3
      - run: cd coaching-api && pytest tests/integration
```

---

## Debugging Failed Tests

### Backend Debug

```bash
# Run single test with verbose output
pytest tests/unit/test_user_service.py::TestUserService::test_get_profile_success -vvs

# With pdb (Python debugger)
pytest tests/unit/test_user_service.py -vvs --pdb

# Print database state
@pytest.fixture
def debug_db(db_session):
    yield
    print("\n=== Final DB State ===")
    for user in db_session.query(User).all():
        print(user)
```

### Frontend Debug

```bash
# Run single test
npm run test -- useProfile.test.ts -t "should fetch profile"

# With watch mode
npm run test:watch -- useProfile.test.ts

# Debug in browser
npm run test:debug -- useProfile.test.ts
```

### E2E Debug

```bash
# Run single test with UI
npx cypress run --spec "tests/e2e/auth.e2e.test.ts"

# Open Cypress UI for debugging
npx cypress open

# Pause test execution
cy.pause();  // in test code
```

---

## Test Maintenance

### Test Review Checklist

Every PR should include tests. Reviewer checklist:

- [ ] New code has unit tests (>80% of added lines)
- [ ] Integration tests for API endpoints
- [ ] E2E tests for critical user workflows
- [ ] All tests passing in CI
- [ ] No flaky tests (tests that pass/fail randomly)
- [ ] Test data cleanup (no orphaned records)
- [ ] Error cases covered
- [ ] Performance reasonable (< 100ms per unit test)

---

**Document Version:** 1.0  
**Last Updated:** 2026-06-09  
**Next Review:** Before Phase 1 implementation starts
