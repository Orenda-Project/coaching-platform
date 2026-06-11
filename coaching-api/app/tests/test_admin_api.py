"""
Comprehensive tests for Admin Management API endpoints and service.

Tests cover:
- Admin user creation, retrieval, update, deletion
- Field issue creation, retrieval, update, deletion, filtering
- Region creation, retrieval, update, deletion, filtering
- Error scenarios (duplicates, invalid data, not found)
- Pagination
- Service layer logic
- Status transitions and resolved_at handling

Total: 40+ test cases
"""

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, Session
from sqlalchemy.pool import StaticPool
from app.main import app
from app.database import Base, get_db
from app.models import User, UserProfile, AdminUser, FieldIssue, Region
from app.services.admin_service import AdminService
import uuid


# Setup test database
@pytest.fixture
def test_db():
    """Create a test database session."""
    engine = create_engine(
        "sqlite:///:memory:",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    Base.metadata.create_all(bind=engine)
    TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

    def override_get_db():
        db = TestingSessionLocal()
        try:
            yield db
        finally:
            db.close()

    app.dependency_overrides[get_db] = override_get_db
    yield TestingSessionLocal()
    app.dependency_overrides.clear()


@pytest.fixture
def client(test_db):
    """Create a test client."""
    return TestClient(app)


@pytest.fixture
def test_user(test_db: Session):
    """Create a test user."""
    user = User(id=str(uuid.uuid4()), email="testuser@example.com")
    profile = UserProfile(
        id=user.id,
        user_id=user.id,
        full_name="Test User",
        role="admin"
    )
    test_db.add(user)
    test_db.add(profile)
    test_db.commit()
    test_db.refresh(user)
    return user


@pytest.fixture
def test_users(test_db: Session):
    """Create multiple test users."""
    users = []
    for i in range(3):
        user = User(id=str(uuid.uuid4()), email=f"user{i}@example.com")
        profile = UserProfile(
            id=user.id,
            user_id=user.id,
            full_name=f"User {i}",
            role="coach"
        )
        test_db.add(user)
        test_db.add(profile)
        users.append(user)
    test_db.commit()
    return users


# ===== ADMIN USER SERVICE TESTS =====

class TestAdminUserService:
    """Unit tests for AdminUser service operations."""

    def test_create_admin_user_super_admin(self, test_db: Session, test_user: User):
        """Test creating a super admin."""
        service = AdminService(test_db)
        admin = service.create_admin_user(test_user.id, "super_admin")

        assert admin is not None
        assert admin.user_id == test_user.id
        assert admin.role == "super_admin"
        assert admin.id is not None

    def test_create_admin_user_regional_admin(self, test_db: Session, test_user: User):
        """Test creating a regional admin."""
        service = AdminService(test_db)
        admin = service.create_admin_user(test_user.id, "regional_admin")

        assert admin is not None
        assert admin.role == "regional_admin"

    def test_create_admin_user_duplicate(self, test_db: Session, test_user: User):
        """Test that duplicate admin users are rejected."""
        service = AdminService(test_db)
        service.create_admin_user(test_user.id, "super_admin")
        duplicate = service.create_admin_user(test_user.id, "regional_admin")

        assert duplicate is None

    def test_create_admin_user_invalid_role(self, test_db: Session, test_user: User):
        """Test that invalid roles are rejected."""
        service = AdminService(test_db)
        admin = service.create_admin_user(test_user.id, "invalid_role")

        assert admin is None

    def test_get_admin_user_by_id(self, test_db: Session, test_user: User):
        """Test retrieving admin user by ID."""
        service = AdminService(test_db)
        created = service.create_admin_user(test_user.id, "super_admin")
        retrieved = service.get_admin_user_by_id(created.id)

        assert retrieved is not None
        assert retrieved.id == created.id

    def test_get_admin_user_by_user_id(self, test_db: Session, test_user: User):
        """Test retrieving admin user by user ID."""
        service = AdminService(test_db)
        created = service.create_admin_user(test_user.id, "super_admin")
        retrieved = service.get_admin_user_by_user_id(test_user.id)

        assert retrieved is not None
        assert retrieved.user_id == test_user.id

    def test_get_admin_user_not_found(self, test_db: Session):
        """Test retrieving non-existent admin user."""
        service = AdminService(test_db)
        admin = service.get_admin_user_by_id("non-existent")

        assert admin is None

    def test_get_all_admin_users(self, test_db: Session, test_users: list):
        """Test listing all admin users."""
        service = AdminService(test_db)
        for user in test_users:
            service.create_admin_user(user.id, "super_admin")

        admins, total = service.get_all_admin_users(limit=10, offset=0)

        assert len(admins) == 3
        assert total == 3

    def test_get_all_admin_users_pagination(self, test_db: Session, test_users: list):
        """Test admin user pagination."""
        service = AdminService(test_db)
        for user in test_users:
            service.create_admin_user(user.id, "super_admin")

        page1, total1 = service.get_all_admin_users(limit=2, offset=0)
        page2, total2 = service.get_all_admin_users(limit=2, offset=2)

        assert len(page1) == 2
        assert len(page2) == 1
        assert total1 == 3
        assert total2 == 3

    def test_update_admin_user_role(self, test_db: Session, test_user: User):
        """Test updating admin user role."""
        service = AdminService(test_db)
        admin = service.create_admin_user(test_user.id, "super_admin")
        updated = service.update_admin_user_role(admin.id, "regional_admin")

        assert updated is not None
        assert updated.role == "regional_admin"

    def test_update_admin_user_role_invalid(self, test_db: Session, test_user: User):
        """Test updating with invalid role."""
        service = AdminService(test_db)
        admin = service.create_admin_user(test_user.id, "super_admin")
        updated = service.update_admin_user_role(admin.id, "invalid_role")

        assert updated is None

    def test_delete_admin_user(self, test_db: Session, test_user: User):
        """Test deleting admin user."""
        service = AdminService(test_db)
        admin = service.create_admin_user(test_user.id, "super_admin")
        success = service.delete_admin_user(admin.id)

        assert success is True
        assert service.get_admin_user_by_id(admin.id) is None

    def test_delete_admin_user_not_found(self, test_db: Session):
        """Test deleting non-existent admin user."""
        service = AdminService(test_db)
        success = service.delete_admin_user("non-existent")

        assert success is False


# ===== FIELD ISSUE SERVICE TESTS =====

class TestFieldIssueService:
    """Unit tests for FieldIssue service operations."""

    def test_create_field_issue(self, test_db: Session, test_user: User):
        """Test creating a field issue."""
        service = AdminService(test_db)
        issue = service.create_field_issue(
            description="Major infrastructure problem in region X",
            reported_by=test_user.id
        )

        assert issue is not None
        assert issue.description == "Major infrastructure problem in region X"
        assert issue.reported_by == test_user.id
        assert issue.status == "open"
        assert issue.resolved_at is None

    def test_create_field_issue_with_assignee(self, test_db: Session, test_users: list):
        """Test creating issue with assignee."""
        service = AdminService(test_db)
        issue = service.create_field_issue(
            description="Issue with assignee",
            reported_by=test_users[0].id,
            assigned_to=test_users[1].id
        )

        assert issue is not None
        assert issue.assigned_to == test_users[1].id

    def test_get_field_issue_by_id(self, test_db: Session, test_user: User):
        """Test retrieving field issue by ID."""
        service = AdminService(test_db)
        created = service.create_field_issue(
            description="Test issue",
            reported_by=test_user.id
        )
        retrieved = service.get_field_issue_by_id(created.id)

        assert retrieved is not None
        assert retrieved.id == created.id

    def test_get_field_issue_not_found(self, test_db: Session):
        """Test retrieving non-existent issue."""
        service = AdminService(test_db)
        issue = service.get_field_issue_by_id("non-existent")

        assert issue is None

    def test_get_all_field_issues(self, test_db: Session, test_user: User):
        """Test listing all field issues."""
        service = AdminService(test_db)
        for i in range(3):
            service.create_field_issue(
                description=f"Issue {i}",
                reported_by=test_user.id
            )

        issues, total = service.get_all_field_issues(limit=10, offset=0)

        assert len(issues) == 3
        assert total == 3

    def test_get_field_issues_filter_by_status(self, test_db: Session, test_user: User):
        """Test filtering issues by status."""
        service = AdminService(test_db)
        issue1 = service.create_field_issue("Issue 1", reported_by=test_user.id)
        issue2 = service.create_field_issue("Issue 2", reported_by=test_user.id)
        service.update_field_issue(issue2.id, status="resolved")

        open_issues, open_count = service.get_all_field_issues(status="open")
        resolved_issues, resolved_count = service.get_all_field_issues(status="resolved")

        assert open_count == 1
        assert resolved_count == 1

    def test_get_field_issues_pagination(self, test_db: Session, test_user: User):
        """Test field issue pagination."""
        service = AdminService(test_db)
        for i in range(3):
            service.create_field_issue(f"Issue {i}", reported_by=test_user.id)

        page1, total1 = service.get_all_field_issues(limit=2, offset=0)
        page2, total2 = service.get_all_field_issues(limit=2, offset=2)

        assert len(page1) == 2
        assert len(page2) == 1

    def test_update_field_issue_description(self, test_db: Session, test_user: User):
        """Test updating issue description."""
        service = AdminService(test_db)
        issue = service.create_field_issue("Original", reported_by=test_user.id)
        updated = service.update_field_issue(issue.id, description="Updated")

        assert updated is not None
        assert updated.description == "Updated"

    def test_update_field_issue_status(self, test_db: Session, test_user: User):
        """Test updating issue status."""
        service = AdminService(test_db)
        issue = service.create_field_issue("Issue", reported_by=test_user.id)
        updated = service.update_field_issue(issue.id, status="in_progress")

        assert updated is not None
        assert updated.status == "in_progress"

    def test_update_field_issue_to_resolved(self, test_db: Session, test_user: User):
        """Test marking issue as resolved sets resolved_at."""
        service = AdminService(test_db)
        issue = service.create_field_issue("Issue", reported_by=test_user.id)
        updated = service.update_field_issue(issue.id, status="resolved")

        assert updated is not None
        assert updated.status == "resolved"
        assert updated.resolved_at is not None

    def test_update_field_issue_to_closed(self, test_db: Session, test_user: User):
        """Test marking issue as closed sets resolved_at."""
        service = AdminService(test_db)
        issue = service.create_field_issue("Issue", reported_by=test_user.id)
        updated = service.update_field_issue(issue.id, status="closed")

        assert updated is not None
        assert updated.status == "closed"
        assert updated.resolved_at is not None

    def test_update_field_issue_invalid_status(self, test_db: Session, test_user: User):
        """Test updating with invalid status."""
        service = AdminService(test_db)
        issue = service.create_field_issue("Issue", reported_by=test_user.id)
        updated = service.update_field_issue(issue.id, status="invalid_status")

        assert updated is None

    def test_delete_field_issue(self, test_db: Session, test_user: User):
        """Test deleting field issue."""
        service = AdminService(test_db)
        issue = service.create_field_issue("Issue", reported_by=test_user.id)
        success = service.delete_field_issue(issue.id)

        assert success is True
        assert service.get_field_issue_by_id(issue.id) is None

    def test_delete_field_issue_not_found(self, test_db: Session):
        """Test deleting non-existent issue."""
        service = AdminService(test_db)
        success = service.delete_field_issue("non-existent")

        assert success is False


# ===== REGION SERVICE TESTS =====

class TestRegionService:
    """Unit tests for Region service operations."""

    def test_create_region(self, test_db: Session):
        """Test creating a region."""
        service = AdminService(test_db)
        region = service.create_region(name="North Region")

        assert region is not None
        assert region.name == "North Region"
        assert region.parent_id is None
        assert region.is_active is True

    def test_create_region_with_parent(self, test_db: Session):
        """Test creating region with parent."""
        service = AdminService(test_db)
        parent = service.create_region(name="Pakistan")
        child = service.create_region(name="Punjab", parent_id=parent.id)

        assert child is not None
        assert child.parent_id == parent.id

    def test_create_region_duplicate_name(self, test_db: Session):
        """Test that duplicate region names are rejected."""
        service = AdminService(test_db)
        service.create_region(name="North")
        duplicate = service.create_region(name="North")

        assert duplicate is None

    def test_get_region_by_id(self, test_db: Session):
        """Test retrieving region by ID."""
        service = AdminService(test_db)
        created = service.create_region(name="Region A")
        retrieved = service.get_region_by_id(created.id)

        assert retrieved is not None
        assert retrieved.id == created.id

    def test_get_region_by_name(self, test_db: Session):
        """Test retrieving region by name."""
        service = AdminService(test_db)
        created = service.create_region(name="Region B")
        retrieved = service.get_region_by_name("Region B")

        assert retrieved is not None
        assert retrieved.name == "Region B"

    def test_get_region_not_found(self, test_db: Session):
        """Test retrieving non-existent region."""
        service = AdminService(test_db)
        region = service.get_region_by_id("non-existent")

        assert region is None

    def test_get_all_regions(self, test_db: Session):
        """Test listing all regions."""
        service = AdminService(test_db)
        for i in range(3):
            service.create_region(name=f"Region {i}")

        regions, total = service.get_all_regions(limit=10, offset=0)

        assert len(regions) == 3
        assert total == 3

    def test_get_all_regions_active_only(self, test_db: Session):
        """Test filtering regions by active status."""
        service = AdminService(test_db)
        region1 = service.create_region(name="Active Region")
        region2 = service.create_region(name="Inactive Region")
        service.update_region(region2.id, is_active=False)

        active, active_count = service.get_all_regions(active_only=True)
        all_regions, all_count = service.get_all_regions(active_only=False)

        assert active_count == 1
        assert all_count == 2

    def test_get_regions_pagination(self, test_db: Session):
        """Test region pagination."""
        service = AdminService(test_db)
        for i in range(3):
            service.create_region(name=f"Region {i}")

        page1, total1 = service.get_all_regions(limit=2, offset=0)
        page2, total2 = service.get_all_regions(limit=2, offset=2)

        assert len(page1) == 2
        assert len(page2) == 1

    def test_update_region_name(self, test_db: Session):
        """Test updating region name."""
        service = AdminService(test_db)
        region = service.create_region(name="Old Name")
        updated = service.update_region(region.id, name="New Name")

        assert updated is not None
        assert updated.name == "New Name"

    def test_update_region_parent(self, test_db: Session):
        """Test updating region parent."""
        service = AdminService(test_db)
        parent = service.create_region(name="Parent")
        child = service.create_region(name="Child")
        updated = service.update_region(child.id, parent_id=parent.id)

        assert updated is not None
        assert updated.parent_id == parent.id

    def test_update_region_is_active(self, test_db: Session):
        """Test updating region active status."""
        service = AdminService(test_db)
        region = service.create_region(name="Region")
        updated = service.update_region(region.id, is_active=False)

        assert updated is not None
        assert updated.is_active is False

    def test_delete_region(self, test_db: Session):
        """Test deleting region."""
        service = AdminService(test_db)
        region = service.create_region(name="Region")
        success = service.delete_region(region.id)

        assert success is True
        assert service.get_region_by_id(region.id) is None

    def test_delete_region_not_found(self, test_db: Session):
        """Test deleting non-existent region."""
        service = AdminService(test_db)
        success = service.delete_region("non-existent")

        assert success is False


# ===== API ENDPOINT TESTS =====

class TestAdminUserAPI:
    """Integration tests for admin user API endpoints."""

    def test_create_admin_user_endpoint(self, client: TestClient, test_user: User):
        """Test POST /api/admin/users."""
        response = client.post(
            "/api/admin/users",
            json={"user_id": test_user.id, "role": "super_admin"}
        )

        assert response.status_code == 201
        data = response.json()
        assert data["user_id"] == test_user.id
        assert data["role"] == "super_admin"

    def test_get_admin_user_endpoint(self, client: TestClient, test_db: Session, test_user: User):
        """Test GET /api/admin/users/{admin_id}."""
        service = AdminService(test_db)
        admin = service.create_admin_user(test_user.id, "super_admin")

        response = client.get(f"/api/admin/users/{admin.id}")

        assert response.status_code == 200
        assert response.json()["id"] == admin.id

    def test_list_admin_users_endpoint(self, client: TestClient, test_db: Session, test_users: list):
        """Test GET /api/admin/users."""
        service = AdminService(test_db)
        for user in test_users:
            service.create_admin_user(user.id, "super_admin")

        response = client.get("/api/admin/users?limit=10&offset=0")

        assert response.status_code == 200
        assert response.json()["total"] == 3

    def test_update_admin_user_role_endpoint(self, client: TestClient, test_db: Session, test_user: User):
        """Test PUT /api/admin/users/{admin_id}/role."""
        service = AdminService(test_db)
        admin = service.create_admin_user(test_user.id, "super_admin")

        response = client.put(
            f"/api/admin/users/{admin.id}/role",
            json={"user_id": test_user.id, "role": "regional_admin"}
        )

        assert response.status_code == 200
        assert response.json()["role"] == "regional_admin"

    def test_delete_admin_user_endpoint(self, client: TestClient, test_db: Session, test_user: User):
        """Test DELETE /api/admin/users/{admin_id}."""
        service = AdminService(test_db)
        admin = service.create_admin_user(test_user.id, "super_admin")

        response = client.delete(f"/api/admin/users/{admin.id}")

        assert response.status_code == 204


class TestFieldIssueAPI:
    """Integration tests for field issue API endpoints."""

    def test_create_field_issue_endpoint(self, client: TestClient, test_user: User):
        """Test POST /api/admin/issues."""
        response = client.post(
            "/api/admin/issues",
            json={
                "description": "Critical infrastructure failure in the field",
                "reported_by": test_user.id
            }
        )

        assert response.status_code == 201
        data = response.json()
        assert "Critical" in data["description"]
        assert data["status"] == "open"

    def test_get_field_issue_endpoint(self, client: TestClient, test_db: Session, test_user: User):
        """Test GET /api/admin/issues/{issue_id}."""
        service = AdminService(test_db)
        issue = service.create_field_issue("Test", reported_by=test_user.id)

        response = client.get(f"/api/admin/issues/{issue.id}")

        assert response.status_code == 200
        assert response.json()["id"] == issue.id

    def test_list_field_issues_endpoint(self, client: TestClient, test_db: Session, test_user: User):
        """Test GET /api/admin/issues."""
        service = AdminService(test_db)
        for i in range(3):
            service.create_field_issue(f"Issue {i}", reported_by=test_user.id)

        response = client.get("/api/admin/issues?limit=10&offset=0")

        assert response.status_code == 200
        assert response.json()["total"] == 3

    def test_list_field_issues_filter_status(self, client: TestClient, test_db: Session, test_user: User):
        """Test GET /api/admin/issues with status filter."""
        service = AdminService(test_db)
        issue = service.create_field_issue("Issue", reported_by=test_user.id)
        service.update_field_issue(issue.id, status="resolved")

        response = client.get("/api/admin/issues?status=resolved")

        assert response.status_code == 200
        assert response.json()["total"] == 1

    def test_update_field_issue_endpoint(self, client: TestClient, test_db: Session, test_user: User):
        """Test PUT /api/admin/issues/{issue_id}."""
        service = AdminService(test_db)
        issue = service.create_field_issue("Original", reported_by=test_user.id)

        response = client.put(
            f"/api/admin/issues/{issue.id}",
            json={"description": "Updated description", "status": "in_progress"}
        )

        assert response.status_code == 200
        data = response.json()
        assert data["description"] == "Updated description"
        assert data["status"] == "in_progress"

    def test_delete_field_issue_endpoint(self, client: TestClient, test_db: Session, test_user: User):
        """Test DELETE /api/admin/issues/{issue_id}."""
        service = AdminService(test_db)
        issue = service.create_field_issue("Issue", reported_by=test_user.id)

        response = client.delete(f"/api/admin/issues/{issue.id}")

        assert response.status_code == 204


class TestRegionAPI:
    """Integration tests for region API endpoints."""

    def test_create_region_endpoint(self, client: TestClient):
        """Test POST /api/admin/regions."""
        response = client.post(
            "/api/admin/regions",
            json={"name": "North Region"}
        )

        assert response.status_code == 201
        assert response.json()["name"] == "North Region"

    def test_get_region_endpoint(self, client: TestClient, test_db: Session):
        """Test GET /api/admin/regions/{region_id}."""
        service = AdminService(test_db)
        region = service.create_region(name="Test Region")

        response = client.get(f"/api/admin/regions/{region.id}")

        assert response.status_code == 200
        assert response.json()["id"] == region.id

    def test_list_regions_endpoint(self, client: TestClient, test_db: Session):
        """Test GET /api/admin/regions."""
        service = AdminService(test_db)
        for i in range(3):
            service.create_region(name=f"Region {i}")

        response = client.get("/api/admin/regions?limit=10&offset=0")

        assert response.status_code == 200
        assert response.json()["total"] == 3

    def test_list_regions_active_only(self, client: TestClient, test_db: Session):
        """Test GET /api/admin/regions with active_only filter."""
        service = AdminService(test_db)
        region1 = service.create_region(name="Active")
        region2 = service.create_region(name="Inactive")
        service.update_region(region2.id, is_active=False)

        response = client.get("/api/admin/regions?active_only=true")

        assert response.status_code == 200
        assert response.json()["total"] == 1

    def test_update_region_endpoint(self, client: TestClient, test_db: Session):
        """Test PUT /api/admin/regions/{region_id}."""
        service = AdminService(test_db)
        region = service.create_region(name="Old Name")

        response = client.put(
            f"/api/admin/regions/{region.id}",
            json={"name": "New Name"}
        )

        assert response.status_code == 200
        assert response.json()["name"] == "New Name"

    def test_delete_region_endpoint(self, client: TestClient, test_db: Session):
        """Test DELETE /api/admin/regions/{region_id}."""
        service = AdminService(test_db)
        region = service.create_region(name="Region")

        response = client.delete(f"/api/admin/regions/{region.id}")

        assert response.status_code == 204


# ===== ERROR HANDLING TESTS =====

class TestErrorHandling:
    """Test error scenarios and validation."""

    def test_create_admin_user_duplicate(self, client: TestClient, test_db: Session, test_user: User):
        """Test creating duplicate admin user returns 409."""
        service = AdminService(test_db)
        service.create_admin_user(test_user.id, "super_admin")

        response = client.post(
            "/api/admin/users",
            json={"user_id": test_user.id, "role": "super_admin"}
        )

        assert response.status_code == 409

    def test_get_nonexistent_admin(self, client: TestClient):
        """Test getting non-existent admin returns 404."""
        response = client.get("/api/admin/users/nonexistent")

        assert response.status_code == 404

    def test_create_region_duplicate_name(self, client: TestClient):
        """Test duplicate region name returns 409."""
        client.post("/api/admin/regions", json={"name": "North"})
        response = client.post("/api/admin/regions", json={"name": "North"})

        assert response.status_code == 409

    def test_create_issue_short_description(self, client: TestClient, test_user: User):
        """Test short description is rejected."""
        response = client.post(
            "/api/admin/issues",
            json={
                "description": "Short",
                "reported_by": test_user.id
            }
        )

        assert response.status_code == 422  # Validation error

    def test_health_check(self, client: TestClient):
        """Test health check endpoint."""
        response = client.get("/api/admin/health")

        assert response.status_code == 200
        assert response.json()["service"] == "admin"
