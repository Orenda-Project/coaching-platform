"""
Comprehensive tests for Auth API endpoints and service.

Tests cover:
- User creation and profile creation
- Profile updates
- Email confirmation
- User deletion
- Error scenarios (duplicates, invalid data)
- Pagination
- Service layer logic
"""

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, Session
from sqlalchemy.pool import StaticPool
from app.main import app
from app.database import Base, get_db
from app.models import User, UserProfile
from app.services.auth_service import AuthService


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


# Tests for AuthService (Unit Tests)
class TestAuthService:
    """Unit tests for AuthService business logic."""

    def test_create_user_success(self, test_db: Session):
        """Test successful user creation."""
        service = AuthService(test_db)
        user = service.create_user("test-user-1", "test@example.com")

        assert user is not None
        assert user.id == "test-user-1"
        assert user.email == "test@example.com"
        assert user.email_confirmed_at is None

    def test_create_user_duplicate_email(self, test_db: Session):
        """Test that duplicate emails are rejected."""
        service = AuthService(test_db)
        service.create_user("user-1", "test@example.com")
        duplicate = service.create_user("user-2", "test@example.com")

        assert duplicate is None

    def test_create_profile_success(self, test_db: Session):
        """Test successful profile creation."""
        service = AuthService(test_db)
        service.create_user("user-1", "test@example.com")
        profile = service.create_profile(
            "user-1",
            full_name="John Doe",
            phone="+1234567890",
            role="coach"
        )

        assert profile is not None
        assert profile.user_id == "user-1"
        assert profile.full_name == "John Doe"
        assert profile.phone == "+1234567890"
        assert profile.role == "coach"
        assert profile.is_active is True

    def test_create_profile_duplicate_phone(self, test_db: Session):
        """Test that duplicate phone numbers are rejected."""
        service = AuthService(test_db)
        service.create_user("user-1", "test1@example.com")
        service.create_profile("user-1", phone="+1234567890")

        service.create_user("user-2", "test2@example.com")
        duplicate = service.create_profile("user-2", phone="+1234567890")

        assert duplicate is None

    def test_get_user_by_id(self, test_db: Session):
        """Test fetching user by ID."""
        service = AuthService(test_db)
        service.create_user("user-1", "test@example.com")
        user = service.get_user_by_id("user-1")

        assert user is not None
        assert user.email == "test@example.com"

    def test_get_user_by_id_not_found(self, test_db: Session):
        """Test fetching non-existent user."""
        service = AuthService(test_db)
        user = service.get_user_by_id("nonexistent")

        assert user is None

    def test_get_user_by_email(self, test_db: Session):
        """Test fetching user by email."""
        service = AuthService(test_db)
        service.create_user("user-1", "test@example.com")
        user = service.get_user_by_email("test@example.com")

        assert user is not None
        assert user.id == "user-1"

    def test_get_profile(self, test_db: Session):
        """Test fetching user profile."""
        service = AuthService(test_db)
        service.create_user("user-1", "test@example.com")
        service.create_profile("user-1", full_name="John Doe")
        profile = service.get_profile("user-1")

        assert profile is not None
        assert profile.full_name == "John Doe"

    def test_update_profile_success(self, test_db: Session):
        """Test successful profile update."""
        service = AuthService(test_db)
        service.create_user("user-1", "test@example.com")
        service.create_profile("user-1", full_name="John")

        updated = service.update_profile("user-1", full_name="John Doe", role="admin")

        assert updated is not None
        assert updated.full_name == "John Doe"
        assert updated.role == "admin"

    def test_update_profile_duplicate_phone(self, test_db: Session):
        """Test update with duplicate phone."""
        service = AuthService(test_db)
        service.create_user("user-1", "test1@example.com")
        service.create_profile("user-1", phone="+1234567890")

        service.create_user("user-2", "test2@example.com")
        service.create_profile("user-2", phone="+9876543210")

        # Try to update user-2's phone to same as user-1
        updated = service.update_profile("user-2", phone="+1234567890")

        assert updated is None

    def test_confirm_email(self, test_db: Session):
        """Test email confirmation."""
        service = AuthService(test_db)
        service.create_user("user-1", "test@example.com")

        confirmed = service.confirm_email("user-1")

        assert confirmed is not None
        assert confirmed.email_confirmed_at is not None

    def test_delete_user(self, test_db: Session):
        """Test user deletion."""
        service = AuthService(test_db)
        service.create_user("user-1", "test@example.com")
        service.create_profile("user-1")

        success = service.delete_user("user-1")

        assert success is True
        assert service.get_user_by_id("user-1") is None

    def test_delete_user_not_found(self, test_db: Session):
        """Test deleting non-existent user."""
        service = AuthService(test_db)
        success = service.delete_user("nonexistent")

        assert success is False

    def test_list_users(self, test_db: Session):
        """Test user pagination."""
        service = AuthService(test_db)
        for i in range(5):
            service.create_user(f"user-{i}", f"test{i}@example.com")

        users, total = service.list_users(limit=3, offset=0)

        assert len(users) == 3
        assert total == 5

    def test_list_users_pagination(self, test_db: Session):
        """Test pagination with offset."""
        service = AuthService(test_db)
        for i in range(5):
            service.create_user(f"user-{i}", f"test{i}@example.com")

        users1, _ = service.list_users(limit=2, offset=0)
        users2, _ = service.list_users(limit=2, offset=2)

        assert len(users1) == 2
        assert len(users2) == 2
        assert users1[0].id != users2[0].id

    def test_user_exists(self, test_db: Session):
        """Test user existence check."""
        service = AuthService(test_db)
        service.create_user("user-1", "test@example.com")

        exists = service.user_exists("test@example.com")
        not_exists = service.user_exists("nonexistent@example.com")

        assert exists is True
        assert not_exists is False


# Tests for Auth API Endpoints (Integration Tests)
class TestAuthAPI:
    """Integration tests for Auth API endpoints."""

    def test_signup_success(self, client: TestClient):
        """Test successful signup."""
        response = client.post(
            "/api/auth/signup",
            json={
                "email": "test@example.com",
                "full_name": "John Doe",
                "phone": "+1234567890"
            }
        )

        assert response.status_code == 201
        data = response.json()
        assert data["email"] == "test@example.com"
        assert data["full_name"] == "John Doe"
        assert data["phone"] == "+1234567890"
        assert data["role"] == "learner"

    def test_signup_duplicate_email(self, client: TestClient):
        """Test signup with duplicate email."""
        client.post(
            "/api/auth/signup",
            json={"email": "test@example.com"}
        )

        response = client.post(
            "/api/auth/signup",
            json={"email": "test@example.com"}
        )

        assert response.status_code == 409

    def test_signup_duplicate_phone(self, client: TestClient):
        """Test signup with duplicate phone."""
        client.post(
            "/api/auth/signup",
            json={
                "email": "test1@example.com",
                "phone": "+1234567890"
            }
        )

        response = client.post(
            "/api/auth/signup",
            json={
                "email": "test2@example.com",
                "phone": "+1234567890"
            }
        )

        assert response.status_code == 400
        assert "phone" in response.json()["detail"].lower()

    def test_get_user_success(self, client: TestClient):
        """Test fetching user."""
        signup = client.post(
            "/api/auth/signup",
            json={"email": "test@example.com"}
        )
        user_id = signup.json()["id"]

        response = client.get(f"/api/auth/users/{user_id}")

        assert response.status_code == 200
        data = response.json()
        assert data["email"] == "test@example.com"

    def test_get_user_not_found(self, client: TestClient):
        """Test fetching non-existent user."""
        response = client.get("/api/auth/users/nonexistent")

        assert response.status_code == 404

    def test_get_user_by_email(self, client: TestClient):
        """Test fetching user by email."""
        client.post(
            "/api/auth/signup",
            json={"email": "test@example.com"}
        )

        response = client.get("/api/auth/users/email/test@example.com")

        assert response.status_code == 200
        data = response.json()
        assert data["email"] == "test@example.com"

    def test_get_profile_success(self, client: TestClient):
        """Test fetching profile."""
        signup = client.post(
            "/api/auth/signup",
            json={
                "email": "test@example.com",
                "full_name": "John Doe"
            }
        )
        user_id = signup.json()["id"]

        response = client.get(f"/api/auth/profile/{user_id}")

        assert response.status_code == 200
        data = response.json()
        assert data["full_name"] == "John Doe"
        assert data["is_active"] is True

    def test_update_profile_success(self, client: TestClient):
        """Test updating profile."""
        signup = client.post(
            "/api/auth/signup",
            json={"email": "test@example.com"}
        )
        user_id = signup.json()["id"]

        response = client.put(
            f"/api/auth/profile/{user_id}",
            json={
                "full_name": "John Doe",
                "bio": "Test bio",
                "role": "coach"
            }
        )

        assert response.status_code == 200
        data = response.json()
        assert data["full_name"] == "John Doe"
        assert data["bio"] == "Test bio"
        assert data["role"] == "coach"

    def test_update_profile_partial(self, client: TestClient):
        """Test partial profile update."""
        signup = client.post(
            "/api/auth/signup",
            json={"email": "test@example.com", "full_name": "John"}
        )
        user_id = signup.json()["id"]

        response = client.put(
            f"/api/auth/profile/{user_id}",
            json={"full_name": "John Doe"}
        )

        assert response.status_code == 200
        data = response.json()
        assert data["full_name"] == "John Doe"

    def test_confirm_email(self, client: TestClient):
        """Test email confirmation."""
        signup = client.post(
            "/api/auth/signup",
            json={"email": "test@example.com"}
        )
        user_id = signup.json()["id"]

        response = client.post(f"/api/auth/email-confirm/{user_id}")

        assert response.status_code == 200
        data = response.json()
        assert data["email_confirmed_at"] is not None

    def test_delete_user_success(self, client: TestClient):
        """Test user deletion."""
        signup = client.post(
            "/api/auth/signup",
            json={"email": "test@example.com"}
        )
        user_id = signup.json()["id"]

        response = client.delete(f"/api/auth/users/{user_id}")

        assert response.status_code == 204

        # Verify user is deleted
        get_response = client.get(f"/api/auth/users/{user_id}")
        assert get_response.status_code == 404

    def test_list_users_success(self, client: TestClient):
        """Test listing users."""
        for i in range(5):
            client.post(
                "/api/auth/signup",
                json={"email": f"test{i}@example.com"}
            )

        response = client.get("/api/auth/users?limit=3&offset=0")

        assert response.status_code == 200
        data = response.json()
        assert len(data["users"]) == 3
        assert data["total"] == 5

    def test_list_users_pagination(self, client: TestClient):
        """Test pagination."""
        for i in range(5):
            client.post(
                "/api/auth/signup",
                json={"email": f"test{i}@example.com"}
            )

        response1 = client.get("/api/auth/users?limit=2&offset=0")
        response2 = client.get("/api/auth/users?limit=2&offset=2")

        assert len(response1.json()["users"]) == 2
        assert len(response2.json()["users"]) == 2

    def test_get_session_authenticated(self, client: TestClient):
        """Test session endpoint when authenticated."""
        signup = client.post(
            "/api/auth/signup",
            json={"email": "test@example.com"}
        )
        user_id = signup.json()["id"]

        response = client.post(
            "/api/auth/session",
            json={"user_id": user_id}
        )

        assert response.status_code == 200
        data = response.json()
        assert data["authenticated"] is True
        assert data["user"]["email"] == "test@example.com"

    def test_get_session_not_authenticated(self, client: TestClient):
        """Test session endpoint when not authenticated."""
        response = client.post("/api/auth/session")

        assert response.status_code == 200
        data = response.json()
        assert data["authenticated"] is False
        assert data["user"] is None

    def test_health_check(self, client: TestClient):
        """Test health check endpoint."""
        response = client.get("/api/auth/health")

        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "healthy"
        assert data["service"] == "auth"


# Edge case tests
class TestAuthEdgeCases:
    """Test edge cases and error handling."""

    def test_update_nonexistent_profile(self, client: TestClient):
        """Test updating profile for non-existent user."""
        response = client.put(
            "/api/auth/profile/nonexistent",
            json={"full_name": "John"}
        )

        assert response.status_code == 404

    def test_invalid_email_format(self, client: TestClient):
        """Test signup with invalid email."""
        response = client.post(
            "/api/auth/signup",
            json={"email": "invalid-email"}
        )

        assert response.status_code == 422

    def test_profile_without_user(self, client: TestClient):
        """Test fetching profile for non-existent user."""
        response = client.get("/api/auth/profile/nonexistent")

        assert response.status_code == 404

    def test_empty_full_name(self, client: TestClient):
        """Test signup with empty full name."""
        response = client.post(
            "/api/auth/signup",
            json={
                "email": "test@example.com",
                "full_name": ""
            }
        )

        # Empty string should be accepted (optional field)
        assert response.status_code == 201

    def test_list_users_invalid_limit(self, client: TestClient):
        """Test list users with invalid limit."""
        response = client.get("/api/auth/users?limit=0")

        assert response.status_code == 422

    def test_list_users_negative_offset(self, client: TestClient):
        """Test list users with negative offset."""
        response = client.get("/api/auth/users?offset=-1")

        assert response.status_code == 422


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
