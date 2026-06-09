"""Integration tests for Assessment API endpoints."""

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, Session
from sqlalchemy.pool import StaticPool
from app.main import app
from app.database import Base, get_db
from app.models import User, Assessment, AssessmentResponse


# Setup test database
@pytest.fixture
def test_db():
    """Create a test database session."""
    engine = create_engine(
        "sqlite:///:memory:",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )

    # Create only assessment-related tables (skip problematic ARRAY columns)
    from sqlalchemy import Column, String, DateTime, Integer, Float, Boolean, ForeignKey, Text
    from sqlalchemy.orm import declarative_base

    MinimalBase = declarative_base()

    class TestUser(MinimalBase):
        __tablename__ = "users"
        id = Column(String, primary_key=True)
        email = Column(String, unique=True, nullable=False, index=True)
        email_confirmed_at = Column(DateTime(timezone=True), nullable=True)
        created_at = Column(DateTime(timezone=True))
        updated_at = Column(DateTime(timezone=True))

    MinimalBase.metadata.create_all(bind=engine)

    # Create assessment tables
    Assessment.__table__.create(bind=engine, checkfirst=True)
    AssessmentResponse.__table__.create(bind=engine, checkfirst=True)

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


# Tests
class TestAssessmentAPI:
    """Integration tests for Assessment API."""

    def test_create_assessment(self, client, test_db: Session):
        """Test creating a new assessment."""
        # First create a user
        user = User(id="test-user-1", email="test@example.com")
        test_db.add(user)
        test_db.commit()

        # Create assessment
        response = client.post(
            "/api/assessments?user_id=test-user-1&module_id=module-123"
        )

        assert response.status_code == 201
        data = response.json()
        assert data["user_id"] == "test-user-1"
        assert data["module_id"] == "module-123"
        assert data["status"] == "in_progress"

    def test_get_assessment(self, client, test_db: Session):
        """Test retrieving an assessment."""
        from app.services.assessment_service import AssessmentService

        # Create test data
        user = User(id="test-user-1", email="test@example.com")
        test_db.add(user)
        test_db.commit()

        service = AssessmentService(test_db)
        assessment = service.create_assessment("test-user-1", "module-123")

        # Get assessment
        response = client.get(f"/api/assessments/{assessment.id}")

        assert response.status_code == 200
        data = response.json()
        assert data["id"] == assessment.id
        assert data["user_id"] == "test-user-1"

    def test_get_user_assessments(self, client, test_db: Session):
        """Test retrieving all assessments for a user."""
        from app.services.assessment_service import AssessmentService

        # Create test data
        user = User(id="test-user-1", email="test@example.com")
        test_db.add(user)
        test_db.commit()

        service = AssessmentService(test_db)
        service.create_assessment("test-user-1", "module-1")
        service.create_assessment("test-user-1", "module-2")

        # Get user assessments
        response = client.get("/api/assessments/user/test-user-1")

        assert response.status_code == 200
        data = response.json()
        assert data["total"] == 2
        assert len(data["assessments"]) == 2

    def test_submit_assessment(self, client, test_db: Session):
        """Test submitting assessment with responses."""
        from app.services.assessment_service import AssessmentService

        # Create test data
        user = User(id="test-user-1", email="test@example.com")
        test_db.add(user)
        test_db.commit()

        service = AssessmentService(test_db)
        assessment = service.create_assessment("test-user-1", "module-123")

        # Submit assessment
        response = client.post(
            f"/api/assessments/{assessment.id}/submit",
            json={
                "responses": [
                    {"question_id": "q1", "user_answer": "A"},
                    {"question_id": "q2", "user_answer": "B"},
                ]
            }
        )

        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "submitted"
        assert len(data["responses"]) == 2

    def test_evaluate_assessment(self, client, test_db: Session):
        """Test evaluating and grading assessment."""
        from app.services.assessment_service import AssessmentService

        # Create and submit assessment
        user = User(id="test-user-1", email="test@example.com")
        test_db.add(user)
        test_db.commit()

        service = AssessmentService(test_db)
        assessment = service.create_assessment("test-user-1", "module-123")
        service.submit_assessment(assessment.id, [
            {"question_id": "q1", "user_answer": "A"},
            {"question_id": "q2", "user_answer": "B"},
        ])

        # Evaluate
        response = client.post(
            f"/api/assessments/{assessment.id}/evaluate",
            json={"answer_key": {"q1": "A", "q2": "B"}}
        )

        assert response.status_code == 200
        data = response.json()
        assert data["score"] == 100.0
        assert data["passed"] is True

    def test_get_assessment_results(self, client, test_db: Session):
        """Test getting assessment results."""
        from app.services.assessment_service import AssessmentService

        # Create and grade assessment
        user = User(id="test-user-1", email="test@example.com")
        test_db.add(user)
        test_db.commit()

        service = AssessmentService(test_db)
        assessment = service.create_assessment("test-user-1", "module-123")
        service.submit_assessment(assessment.id, [
            {"question_id": "q1", "user_answer": "A"},
        ])
        service.evaluate_responses(assessment.id, {"q1": "A"})

        # Get results
        response = client.get(f"/api/assessments/{assessment.id}/results")

        assert response.status_code == 200
        data = response.json()
        assert data["score"] == 100.0
        assert data["correct_responses"] == 1

    def test_delete_assessment(self, client, test_db: Session):
        """Test deleting an assessment."""
        from app.services.assessment_service import AssessmentService

        # Create test data
        user = User(id="test-user-1", email="test@example.com")
        test_db.add(user)
        test_db.commit()

        service = AssessmentService(test_db)
        assessment = service.create_assessment("test-user-1", "module-123")

        # Delete assessment
        response = client.delete(f"/api/assessments/{assessment.id}")

        assert response.status_code == 204

        # Verify deleted
        response = client.get(f"/api/assessments/{assessment.id}")
        assert response.status_code == 404
