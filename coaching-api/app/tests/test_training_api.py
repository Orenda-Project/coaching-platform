"""Integration tests for Training API endpoints."""

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine, Column, String, DateTime, Integer, Text
from sqlalchemy.orm import sessionmaker, Session, declarative_base
from sqlalchemy.pool import StaticPool
from app.main import app
from app.database import Base, get_db
from app.models import User, Training, TrainingProgress


# Setup test database
@pytest.fixture
def test_db():
    """Create a test database session."""
    engine = create_engine(
        "sqlite:///:memory:",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )

    MinimalBase = declarative_base()

    class TestUser(MinimalBase):
        __tablename__ = "users"
        id = Column(String, primary_key=True)
        email = Column(String, unique=True, nullable=False, index=True)
        email_confirmed_at = Column(DateTime(timezone=True), nullable=True)
        created_at = Column(DateTime(timezone=True))
        updated_at = Column(DateTime(timezone=True))

    class TestModule(MinimalBase):
        __tablename__ = "export_modules"
        id = Column(String, primary_key=True)
        title = Column(String, nullable=False)
        description = Column(Text)
        order_number = Column(Integer)

    MinimalBase.metadata.create_all(bind=engine)

    # Create training tables
    Training.__table__.create(bind=engine, checkfirst=True)
    TrainingProgress.__table__.create(bind=engine, checkfirst=True)

    TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

    def override_get_db():
        db = TestingSessionLocal()
        try:
            yield db
        finally:
            db.close()

    app.dependency_overrides[get_db] = override_get_db

    db = TestingSessionLocal()

    # Create test data
    user = TestUser(id="test-user-1", email="test@example.com")
    db.add(user)

    module = TestModule(id="test-module-1", title="Test Module", order_number=1)
    db.add(module)

    for i in range(3):
        training = Training(
            id=f"test-training-{i+1}",
            module_id="test-module-1",
            title=f"Test Training {i+1}",
            order_number=i+1
        )
        db.add(training)

    db.commit()

    yield db
    db.close()

    app.dependency_overrides.clear()


@pytest.fixture
def client(test_db):
    """Create a test client."""
    return TestClient(app)


# Tests
class TestTrainingAPI:
    """Integration tests for Training API."""

    def test_get_all_trainings(self, client, test_db: Session):
        """Test retrieving all trainings."""
        response = client.get("/api/training")

        assert response.status_code == 200
        data = response.json()
        assert data["total"] == 3
        assert len(data["trainings"]) == 3

    def test_get_training_by_id(self, client, test_db: Session):
        """Test retrieving a specific training."""
        response = client.get("/api/training/test-training-1")

        assert response.status_code == 200
        data = response.json()
        assert data["id"] == "test-training-1"
        assert data["title"] == "Test Training 1"

    def test_get_module_trainings(self, client, test_db: Session):
        """Test retrieving trainings for a module."""
        response = client.get("/api/training/module/test-module-1")

        assert response.status_code == 200
        data = response.json()
        assert data["total"] == 3
        assert len(data["trainings"]) == 3

    def test_create_progress(self, client, test_db: Session):
        """Test creating progress record."""
        response = client.post(
            "/api/training/progress?user_id=test-user-1&training_id=test-training-1"
        )

        assert response.status_code == 201
        data = response.json()
        assert data["user_id"] == "test-user-1"
        assert data["training_id"] == "test-training-1"
        assert data["progress_percentage"] == 0.0
        assert data["is_completed"] is False

    def test_get_progress(self, client, test_db: Session):
        """Test retrieving progress."""
        from app.services.training_service import TrainingService

        service = TrainingService(test_db)
        service.create_progress("test-user-1", "test-training-1")

        response = client.get("/api/training/progress/test-user-1/test-training-1")

        assert response.status_code == 200
        data = response.json()
        assert data["user_id"] == "test-user-1"
        assert data["progress_percentage"] == 0.0

    def test_update_progress(self, client, test_db: Session):
        """Test updating progress."""
        from app.services.training_service import TrainingService

        service = TrainingService(test_db)
        service.create_progress("test-user-1", "test-training-1")

        response = client.put(
            "/api/training/progress/test-user-1/test-training-1",
            json={"progress_percentage": 50.0}
        )

        assert response.status_code == 200
        data = response.json()
        assert data["progress_percentage"] == 50.0

    def test_mark_complete(self, client, test_db: Session):
        """Test marking training as complete."""
        response = client.post(
            "/api/training/progress/test-user-1/test-training-1/complete"
        )

        assert response.status_code == 200
        data = response.json()
        assert data["is_completed"] is True
        assert data["progress_percentage"] == 100.0
        assert data["completed_at"] is not None

    def test_get_user_progress(self, client, test_db: Session):
        """Test getting all progress for a user."""
        from app.services.training_service import TrainingService

        service = TrainingService(test_db)
        service.create_progress("test-user-1", "test-training-1")
        service.create_progress("test-user-1", "test-training-2")

        response = client.get("/api/training/user/test-user-1")

        assert response.status_code == 200
        data = response.json()
        assert data["total"] == 2

    def test_get_module_progress(self, client, test_db: Session):
        """Test getting aggregated module progress."""
        from app.services.training_service import TrainingService

        service = TrainingService(test_db)
        service.create_progress("test-user-1", "test-training-1")
        service.create_progress("test-user-1", "test-training-2")
        service.mark_complete("test-user-1", "test-training-3")

        response = client.get("/api/training/module/test-module-1/progress/test-user-1")

        assert response.status_code == 200
        data = response.json()
        assert data["total_trainings"] == 3
        assert data["completed_trainings"] == 1

    def test_reset_progress(self, client, test_db: Session):
        """Test resetting progress."""
        from app.services.training_service import TrainingService

        service = TrainingService(test_db)
        service.mark_complete("test-user-1", "test-training-1")

        # Verify completed
        response = client.get("/api/training/progress/test-user-1/test-training-1")
        assert response.json()["is_completed"] is True

        # Reset
        response = client.post(
            "/api/training/progress/test-user-1/test-training-1/reset"
        )

        assert response.status_code == 200
        data = response.json()
        assert data["is_completed"] is False
        assert data["progress_percentage"] == 0.0

    def test_delete_progress(self, client, test_db: Session):
        """Test deleting progress."""
        from app.services.training_service import TrainingService

        service = TrainingService(test_db)
        service.create_progress("test-user-1", "test-training-1")

        response = client.delete("/api/training/progress/test-user-1/test-training-1")

        assert response.status_code == 204

        # Verify deleted
        response = client.get("/api/training/progress/test-user-1/test-training-1")
        assert response.status_code == 404
