"""
Unit tests for AuthService - Tests service logic without API endpoints.

This file tests the core AuthService methods independently from the FastAPI app,
avoiding SQLAlchemy ARRAY type issues with SQLite test database.
"""

import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, Session
from sqlalchemy.pool import StaticPool
from datetime import datetime
from app.models.user import User, UserProfile
from app.database import Base
from app.services.auth_service import AuthService


@pytest.fixture
def test_db():
    """Create an in-memory SQLite database for testing."""
    from sqlalchemy import Column, String, DateTime, Boolean, Text, ForeignKey, MetaData, Table
    from sqlalchemy.sql import func

    engine = create_engine(
        "sqlite:///:memory:",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )

    # Create only our auth tables manually without Base.metadata
    metadata = MetaData()

    users_table = Table(
        'users',
        metadata,
        Column('id', String, primary_key=True),
        Column('email', String, unique=True, nullable=False, index=True),
        Column('email_confirmed_at', DateTime, nullable=True),
        Column('created_at', DateTime, server_default=func.now()),
        Column('updated_at', DateTime, server_default=func.now()),
    )

    user_profiles_table = Table(
        'user_profiles',
        metadata,
        Column('id', String, primary_key=True),
        Column('user_id', String, unique=True, nullable=False, index=True),
        Column('full_name', String, nullable=True),
        Column('phone', String, unique=True, nullable=True, index=True),
        Column('avatar_url', String, nullable=True),
        Column('bio', Text, nullable=True),
        Column('role', String, default='learner'),
        Column('is_active', Boolean, default=True),
        Column('created_at', DateTime, server_default=func.now()),
        Column('updated_at', DateTime, server_default=func.now()),
    )

    metadata.create_all(bind=engine)

    SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
    return SessionLocal()


class TestAuthServiceUnitTests:
    """Unit tests for AuthService methods."""

    def test_create_user_success(self, test_db: Session):
        """Test successful user creation."""
        service = AuthService(test_db)
        user = service.create_user("test-user-1", "test@example.com")

        assert user is not None
        assert user.id == "test-user-1"
        assert user.email == "test@example.com"
        assert user.email_confirmed_at is None
        print("✓ test_create_user_success")

    def test_create_user_duplicate_email(self, test_db: Session):
        """Test that duplicate emails are rejected."""
        service = AuthService(test_db)
        service.create_user("user-1", "test@example.com")
        duplicate = service.create_user("user-2", "test@example.com")

        assert duplicate is None
        print("✓ test_create_user_duplicate_email")

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
        print("✓ test_create_profile_success")

    def test_create_profile_duplicate_phone(self, test_db: Session):
        """Test that duplicate phone numbers are rejected."""
        service = AuthService(test_db)
        service.create_user("user-1", "test1@example.com")
        service.create_profile("user-1", phone="+1234567890")

        service.create_user("user-2", "test2@example.com")
        duplicate = service.create_profile("user-2", phone="+1234567890")

        assert duplicate is None
        print("✓ test_create_profile_duplicate_phone")

    def test_get_user_by_id(self, test_db: Session):
        """Test fetching user by ID."""
        service = AuthService(test_db)
        service.create_user("user-1", "test@example.com")
        user = service.get_user_by_id("user-1")

        assert user is not None
        assert user.email == "test@example.com"
        print("✓ test_get_user_by_id")

    def test_get_user_by_id_not_found(self, test_db: Session):
        """Test fetching non-existent user."""
        service = AuthService(test_db)
        user = service.get_user_by_id("nonexistent")

        assert user is None
        print("✓ test_get_user_by_id_not_found")

    def test_get_user_by_email(self, test_db: Session):
        """Test fetching user by email."""
        service = AuthService(test_db)
        service.create_user("user-1", "test@example.com")
        user = service.get_user_by_email("test@example.com")

        assert user is not None
        assert user.id == "user-1"
        print("✓ test_get_user_by_email")

    def test_get_profile(self, test_db: Session):
        """Test fetching user profile."""
        service = AuthService(test_db)
        service.create_user("user-1", "test@example.com")
        service.create_profile("user-1", full_name="John Doe")
        profile = service.get_profile("user-1")

        assert profile is not None
        assert profile.full_name == "John Doe"
        print("✓ test_get_profile")

    def test_update_profile_success(self, test_db: Session):
        """Test successful profile update."""
        service = AuthService(test_db)
        service.create_user("user-1", "test@example.com")
        service.create_profile("user-1", full_name="John")

        updated = service.update_profile("user-1", full_name="John Doe", role="admin")

        assert updated is not None
        assert updated.full_name == "John Doe"
        assert updated.role == "admin"
        print("✓ test_update_profile_success")

    def test_update_profile_duplicate_phone(self, test_db: Session):
        """Test update with duplicate phone."""
        service = AuthService(test_db)
        service.create_user("user-1", "test1@example.com")
        service.create_profile("user-1", phone="+1234567890")

        service.create_user("user-2", "test2@example.com")
        service.create_profile("user-2", phone="+9876543210")

        updated = service.update_profile("user-2", phone="+1234567890")

        assert updated is None
        print("✓ test_update_profile_duplicate_phone")

    def test_confirm_email(self, test_db: Session):
        """Test email confirmation."""
        service = AuthService(test_db)
        service.create_user("user-1", "test@example.com")

        confirmed = service.confirm_email("user-1")

        assert confirmed is not None
        assert confirmed.email_confirmed_at is not None
        print("✓ test_confirm_email")

    def test_delete_user(self, test_db: Session):
        """Test user deletion."""
        service = AuthService(test_db)
        service.create_user("user-1", "test@example.com")
        service.create_profile("user-1")

        success = service.delete_user("user-1")

        assert success is True
        assert service.get_user_by_id("user-1") is None
        print("✓ test_delete_user")

    def test_delete_user_not_found(self, test_db: Session):
        """Test deleting non-existent user."""
        service = AuthService(test_db)
        success = service.delete_user("nonexistent")

        assert success is False
        print("✓ test_delete_user_not_found")

    def test_list_users(self, test_db: Session):
        """Test user pagination."""
        service = AuthService(test_db)
        for i in range(5):
            service.create_user(f"user-{i}", f"test{i}@example.com")

        users, total = service.list_users(limit=3, offset=0)

        assert len(users) == 3
        assert total == 5
        print("✓ test_list_users")

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
        print("✓ test_list_users_pagination")

    def test_user_exists(self, test_db: Session):
        """Test user existence check."""
        service = AuthService(test_db)
        service.create_user("user-1", "test@example.com")

        exists = service.user_exists("test@example.com")
        not_exists = service.user_exists("nonexistent@example.com")

        assert exists is True
        assert not_exists is False
        print("✓ test_user_exists")


if __name__ == "__main__":
    pytest.main([__file__, "-v", "-s"])
