"""
Unit tests for ObservationService - Tests service logic without API endpoints.

This file tests the core ObservationService methods independently from the FastAPI app.
"""

import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, Session
from sqlalchemy.pool import StaticPool
from datetime import datetime
from app.models.observation import Observation, COTObservation, ObservationNotes
from app.models.user import User, UserProfile
from app.database import Base
from app.services.observation_service import ObservationService


@pytest.fixture
def test_db():
    """Create an in-memory SQLite database for testing."""
    from sqlalchemy import Column, String, DateTime, Boolean, Text, ForeignKey, Integer, MetaData, Table, JSON
    from sqlalchemy.sql import func

    engine = create_engine(
        "sqlite:///:memory:",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )

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

    observations_table = Table(
        'observations',
        metadata,
        Column('id', String, primary_key=True),
        Column('user_id', String, nullable=False, index=True),
        Column('date', DateTime, nullable=False),
        Column('notes', Text, nullable=True),
        Column('created_at', DateTime, server_default=func.now()),
        Column('updated_at', DateTime, server_default=func.now()),
    )

    cot_observations_table = Table(
        'cot_observations',
        metadata,
        Column('id', String, primary_key=True),
        Column('observation_id', String, nullable=False, index=True),
        Column('category', String, nullable=False),
        Column('response', Text, nullable=True),
        Column('rating', Integer, nullable=True),
        Column('created_at', DateTime, server_default=func.now()),
        Column('updated_at', DateTime, server_default=func.now()),
    )

    observation_notes_table = Table(
        'observation_notes',
        metadata,
        Column('id', String, primary_key=True),
        Column('observation_id', String, nullable=False, index=True),
        Column('note_text', Text, nullable=False),
        Column('created_by', String, nullable=False),
        Column('created_at', DateTime, server_default=func.now()),
        Column('updated_at', DateTime, server_default=func.now()),
    )

    metadata.create_all(bind=engine)

    SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
    return SessionLocal()


@pytest.fixture
def setup_users(test_db: Session):
    """Create test users."""
    # Create users table and users
    from sqlalchemy import text
    test_db.execute(text("""
        INSERT INTO users (id, email, created_at, updated_at)
        VALUES ('coach-1', 'coach@example.com', datetime('now'), datetime('now'))
    """))
    test_db.execute(text("""
        INSERT INTO user_profiles (id, user_id, full_name, role, created_at, updated_at)
        VALUES ('coach-1', 'coach-1', 'Coach One', 'coach', datetime('now'), datetime('now'))
    """))
    test_db.execute(text("""
        INSERT INTO users (id, email, created_at, updated_at)
        VALUES ('learner-1', 'learner@example.com', datetime('now'), datetime('now'))
    """))
    test_db.execute(text("""
        INSERT INTO user_profiles (id, user_id, full_name, role, created_at, updated_at)
        VALUES ('learner-1', 'learner-1', 'Learner One', 'learner', datetime('now'), datetime('now'))
    """))
    test_db.commit()
    return test_db


class TestObservationServiceUnitTests:
    """Unit tests for ObservationService methods."""

    def test_create_observation_success(self, setup_users: Session):
        """Test successful observation creation."""
        service = ObservationService(setup_users)
        obs = service.create_observation(
            user_id="learner-1",
            date=datetime.utcnow(),
            notes="First observation"
        )

        assert obs is not None
        assert obs.user_id == "learner-1"
        assert obs.notes == "First observation"
        print("✓ test_create_observation_success")

    def test_get_observation_success(self, setup_users: Session):
        """Test fetching observation by ID."""
        service = ObservationService(setup_users)
        created = service.create_observation(
            user_id="learner-1",
            date=datetime.utcnow(),
            notes="Test observation"
        )

        fetched = service.get_observation(created.id)

        assert fetched is not None
        assert fetched.id == created.id
        assert fetched.notes == "Test observation"
        print("✓ test_get_observation_success")

    def test_get_observation_not_found(self, setup_users: Session):
        """Test fetching non-existent observation."""
        service = ObservationService(setup_users)
        obs = service.get_observation("nonexistent-id")

        assert obs is None
        print("✓ test_get_observation_not_found")

    def test_get_user_observations(self, setup_users: Session):
        """Test fetching all observations for a user."""
        service = ObservationService(setup_users)

        # Create multiple observations
        obs1 = service.create_observation(
            user_id="learner-1",
            date=datetime.utcnow(),
            notes="Observation 1"
        )
        obs2 = service.create_observation(
            user_id="learner-1",
            date=datetime.utcnow(),
            notes="Observation 2"
        )
        obs3 = service.create_observation(
            user_id="coach-1",
            date=datetime.utcnow(),
            notes="Coach observation"
        )

        user_obs = service.get_user_observations("learner-1")

        assert len(user_obs) == 2
        assert all(o.user_id == "learner-1" for o in user_obs)
        print("✓ test_get_user_observations")

    def test_update_observation_success(self, setup_users: Session):
        """Test successful observation update."""
        service = ObservationService(setup_users)
        obs = service.create_observation(
            user_id="learner-1",
            date=datetime.utcnow(),
            notes="Original notes"
        )

        updated = service.update_observation(
            obs.id,
            {"notes": "Updated notes"}
        )

        assert updated is not None
        assert updated.notes == "Updated notes"
        print("✓ test_update_observation_success")

    def test_update_observation_not_found(self, setup_users: Session):
        """Test updating non-existent observation."""
        service = ObservationService(setup_users)
        updated = service.update_observation(
            "nonexistent-id",
            {"notes": "Updated"}
        )

        assert updated is None
        print("✓ test_update_observation_not_found")

    def test_delete_observation_success(self, setup_users: Session):
        """Test successful observation deletion."""
        service = ObservationService(setup_users)
        obs = service.create_observation(
            user_id="learner-1",
            date=datetime.utcnow(),
            notes="To delete"
        )

        success = service.delete_observation(obs.id)

        assert success is True
        assert service.get_observation(obs.id) is None
        print("✓ test_delete_observation_success")

    def test_delete_observation_not_found(self, setup_users: Session):
        """Test deleting non-existent observation."""
        service = ObservationService(setup_users)
        success = service.delete_observation("nonexistent-id")

        assert success is False
        print("✓ test_delete_observation_not_found")

    def test_create_cot_observation_success(self, setup_users: Session):
        """Test successful COT observation creation."""
        service = ObservationService(setup_users)
        obs = service.create_observation(
            user_id="learner-1",
            date=datetime.utcnow(),
            notes="Test observation"
        )

        cot = service.create_cot_observation(
            observation_id=obs.id,
            category="strengths",
            response="Demonstrates resilience",
            rating=4
        )

        assert cot is not None
        assert cot.observation_id == obs.id
        assert cot.category == "strengths"
        assert cot.rating == 4
        print("✓ test_create_cot_observation_success")

    def test_get_cot_responses_success(self, setup_users: Session):
        """Test fetching COT responses for an observation."""
        service = ObservationService(setup_users)
        obs = service.create_observation(
            user_id="learner-1",
            date=datetime.utcnow(),
            notes="Test"
        )

        cot1 = service.create_cot_observation(
            observation_id=obs.id,
            category="strengths",
            response="Strong",
            rating=5
        )
        cot2 = service.create_cot_observation(
            observation_id=obs.id,
            category="areas_for_growth",
            response="Time management",
            rating=2
        )

        responses = service.get_cot_responses(obs.id)

        assert len(responses) == 2
        assert all(r.observation_id == obs.id for r in responses)
        print("✓ test_get_cot_responses_success")

    def test_bulk_save_observations_success(self, setup_users: Session):
        """Test bulk saving observations."""
        service = ObservationService(setup_users)

        observations_data = [
            {
                "user_id": "learner-1",
                "date": datetime.utcnow(),
                "notes": "Bulk obs 1"
            },
            {
                "user_id": "learner-1",
                "date": datetime.utcnow(),
                "notes": "Bulk obs 2"
            },
        ]

        saved = service.bulk_save_observations(observations_data)

        assert len(saved) == 2
        assert all(o.user_id == "learner-1" for o in saved)
        print("✓ test_bulk_save_observations_success")


if __name__ == "__main__":
    pytest.main([__file__, "-v", "-s"])
