"""
Unit tests for CoachingService - Tests service logic without API endpoints.

This file tests the core CoachingService methods independently from the FastAPI app.
"""

import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, Session
from sqlalchemy.pool import StaticPool
from datetime import datetime
from app.models.coaching import CoachingSession, Feedback, SessionNote
from app.models.user import User, UserProfile
from app.database import Base
from app.services.coaching_service import CoachingService


@pytest.fixture
def test_db():
    """Create an in-memory SQLite database for testing."""
    from sqlalchemy import Column, String, DateTime, Boolean, Text, ForeignKey, Integer, MetaData, Table
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

    coaching_sessions_table = Table(
        'coaching_sessions',
        metadata,
        Column('id', String, primary_key=True),
        Column('coach_id', String, nullable=False, index=True),
        Column('coachee_id', String, nullable=False, index=True),
        Column('date', DateTime, nullable=False),
        Column('status', String, default='scheduled'),
        Column('notes', Text, nullable=True),
        Column('created_at', DateTime, server_default=func.now()),
        Column('updated_at', DateTime, server_default=func.now()),
    )

    feedback_table = Table(
        'feedback',
        metadata,
        Column('id', String, primary_key=True),
        Column('session_id', String, nullable=False, index=True),
        Column('category', String, nullable=False),
        Column('rating', Integer, nullable=True),
        Column('comments', Text, nullable=True),
        Column('created_at', DateTime, server_default=func.now()),
        Column('updated_at', DateTime, server_default=func.now()),
    )

    session_notes_table = Table(
        'session_notes',
        metadata,
        Column('id', String, primary_key=True),
        Column('session_id', String, nullable=False, index=True),
        Column('content', Text, nullable=False),
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


class TestCoachingServiceUnitTests:
    """Unit tests for CoachingService methods."""

    def test_schedule_coaching_session_success(self, setup_users: Session):
        """Test successful coaching session scheduling."""
        service = CoachingService(setup_users)
        session_date = datetime.utcnow()

        session = service.schedule_coaching_session(
            coach_id="coach-1",
            coachee_id="learner-1",
            date=session_date
        )

        assert session is not None
        assert session.coach_id == "coach-1"
        assert session.coachee_id == "learner-1"
        assert session.status == "scheduled"
        print("✓ test_schedule_coaching_session_success")

    def test_get_sessions_by_coach(self, setup_users: Session):
        """Test fetching coaching sessions for a coach."""
        service = CoachingService(setup_users)
        session_date = datetime.utcnow()

        session1 = service.schedule_coaching_session(
            coach_id="coach-1",
            coachee_id="learner-1",
            date=session_date
        )

        sessions = service.get_sessions("coach-1", role="coach")

        assert len(sessions) >= 1
        assert any(s.id == session1.id for s in sessions)
        print("✓ test_get_sessions_by_coach")

    def test_get_sessions_by_learner(self, setup_users: Session):
        """Test fetching coaching sessions for a learner."""
        service = CoachingService(setup_users)
        session_date = datetime.utcnow()

        session1 = service.schedule_coaching_session(
            coach_id="coach-1",
            coachee_id="learner-1",
            date=session_date
        )

        sessions = service.get_sessions("learner-1", role="learner")

        assert len(sessions) >= 1
        assert any(s.id == session1.id for s in sessions)
        print("✓ test_get_sessions_by_learner")

    def test_complete_session_success(self, setup_users: Session):
        """Test successful session completion."""
        service = CoachingService(setup_users)
        session_date = datetime.utcnow()

        session = service.schedule_coaching_session(
            coach_id="coach-1",
            coachee_id="learner-1",
            date=session_date
        )

        completed = service.complete_session(session.id)

        assert completed is not None
        assert completed.status == "completed"
        print("✓ test_complete_session_success")

    def test_complete_session_not_found(self, setup_users: Session):
        """Test completing non-existent session."""
        service = CoachingService(setup_users)
        completed = service.complete_session("nonexistent-id")

        assert completed is None
        print("✓ test_complete_session_not_found")

    def test_add_feedback_success(self, setup_users: Session):
        """Test adding feedback to a session."""
        service = CoachingService(setup_users)
        session_date = datetime.utcnow()

        session = service.schedule_coaching_session(
            coach_id="coach-1",
            coachee_id="learner-1",
            date=session_date
        )

        feedback_data = {
            "category": "communication",
            "rating": 4,
            "comments": "Good communication skills"
        }

        feedback = service.add_feedback(session.id, feedback_data)

        assert feedback is not None
        assert feedback.session_id == session.id
        assert feedback.category == "communication"
        assert feedback.rating == 4
        print("✓ test_add_feedback_success")

    def test_add_feedback_multiple_categories(self, setup_users: Session):
        """Test adding feedback for multiple categories."""
        service = CoachingService(setup_users)
        session_date = datetime.utcnow()

        session = service.schedule_coaching_session(
            coach_id="coach-1",
            coachee_id="learner-1",
            date=session_date
        )

        feedback1 = service.add_feedback(
            session.id,
            {"category": "communication", "rating": 4}
        )
        feedback2 = service.add_feedback(
            session.id,
            {"category": "engagement", "rating": 5}
        )

        session_feedback = service.get_session_feedback(session.id)

        assert len(session_feedback) == 2
        assert all(f.session_id == session.id for f in session_feedback)
        print("✓ test_add_feedback_multiple_categories")

    def test_get_session_feedback_success(self, setup_users: Session):
        """Test fetching feedback for a session."""
        service = CoachingService(setup_users)
        session_date = datetime.utcnow()

        session = service.schedule_coaching_session(
            coach_id="coach-1",
            coachee_id="learner-1",
            date=session_date
        )

        feedback1 = service.add_feedback(
            session.id,
            {"category": "communication", "rating": 4}
        )
        feedback2 = service.add_feedback(
            session.id,
            {"category": "engagement", "rating": 5}
        )

        feedback_list = service.get_session_feedback(session.id)

        assert len(feedback_list) == 2
        assert all(f.session_id == session.id for f in feedback_list)
        print("✓ test_get_session_feedback_success")

    def test_get_session_feedback_empty(self, setup_users: Session):
        """Test getting feedback for session with no feedback."""
        service = CoachingService(setup_users)
        session_date = datetime.utcnow()

        session = service.schedule_coaching_session(
            coach_id="coach-1",
            coachee_id="learner-1",
            date=session_date
        )

        feedback_list = service.get_session_feedback(session.id)

        assert len(feedback_list) == 0
        print("✓ test_get_session_feedback_empty")


if __name__ == "__main__":
    pytest.main([__file__, "-v", "-s"])
