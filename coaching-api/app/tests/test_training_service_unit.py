"""Unit tests for TrainingService."""

import pytest
from datetime import datetime
from sqlalchemy.orm import Session
from sqlalchemy import Column, String, Integer, Text
from sqlalchemy.orm import declarative_base
from app.database import Base
from app.models import Training, TrainingProgress, User
from app.services.training_service import TrainingService


# Create Module model for testing if not available
try:
    from app.models import Module
except ImportError:
    ModuleBase = declarative_base()

    class Module(ModuleBase):
        __tablename__ = "export_modules"
        id = Column(String, primary_key=True)
        title = Column(String, nullable=False)
        description = Column(Text)
        order_number = Column(Integer)


@pytest.fixture
def service_with_data(test_db: Session) -> TrainingService:
    """Create TrainingService instance with test data."""
    # Create test user
    user = User(id="test-user-1", email="test@example.com")
    test_db.add(user)

    # Create test module
    module = Module(
        id="test-module-1",
        title="Test Module",
        description="Test module description",
        order_number=1
    )
    test_db.add(module)

    # Create test trainings
    for i in range(3):
        training = Training(
            id=f"test-training-{i+1}",
            module_id="test-module-1",
            title=f"Test Training {i+1}",
            description=f"Test training {i+1} description",
            order_number=i+1
        )
        test_db.add(training)

    test_db.commit()

    return TrainingService(test_db)


class TestTrainingServiceRetrieval:
    """Tests for retrieving trainings."""

    def test_get_training_by_id(self, service_with_data, test_db):
        """Test retrieving training by ID."""
        training = service_with_data.get_training("test-training-1")

        assert training is not None
        assert training.id == "test-training-1"
        assert training.title == "Test Training 1"

    def test_get_nonexistent_training(self, service_with_data, test_db):
        """Test retrieving non-existent training."""
        result = service_with_data.get_training("non-existent")
        assert result is None

    def test_get_module_trainings(self, service_with_data, test_db):
        """Test getting all trainings for a module."""
        trainings, total = service_with_data.get_module_trainings("test-module-1")

        assert total == 3
        assert len(trainings) == 3
        assert all(t.module_id == "test-module-1" for t in trainings)

    def test_get_module_trainings_pagination(self, service_with_data, test_db):
        """Test module trainings pagination."""
        trainings, total = service_with_data.get_module_trainings("test-module-1", limit=2, offset=0)

        assert total == 3
        assert len(trainings) == 2

    def test_get_module_trainings_empty(self, service_with_data, test_db):
        """Test getting trainings for module with none."""
        trainings, total = service_with_data.get_module_trainings("non-existent-module")
        assert len(trainings) == 0
        assert total == 0

    def test_get_all_trainings(self, service_with_data, test_db):
        """Test getting all trainings."""
        trainings, total = service_with_data.get_all_trainings()

        assert total == 3
        assert len(trainings) == 3

    def test_get_all_trainings_pagination(self, service_with_data, test_db):
        """Test all trainings pagination."""
        trainings, total = service_with_data.get_all_trainings(limit=2, offset=0)

        assert total == 3
        assert len(trainings) == 2


class TestTrainingProgressCreation:
    """Tests for creating training progress."""

    def test_create_progress_new(self, service_with_data, test_db):
        """Test creating new progress record."""
        progress = service_with_data.create_progress("test-user-1", "test-training-1")

        assert progress is not None
        assert progress.user_id == "test-user-1"
        assert progress.training_id == "test-training-1"
        assert progress.progress_percentage == 0.0
        assert progress.is_completed is False

    def test_create_progress_duplicate_returns_existing(self, service_with_data, test_db):
        """Test that creating duplicate progress returns existing record."""
        progress1 = service_with_data.create_progress("test-user-1", "test-training-1")
        progress2 = service_with_data.create_progress("test-user-1", "test-training-1")

        assert progress1.id == progress2.id

    def test_create_progress_multiple_trainings(self, service_with_data, test_db):
        """Test creating progress for multiple trainings."""
        p1 = service_with_data.create_progress("test-user-1", "test-training-1")
        p2 = service_with_data.create_progress("test-user-1", "test-training-2")
        p3 = service_with_data.create_progress("test-user-1", "test-training-3")

        assert p1.id != p2.id != p3.id
        assert len({p1.id, p2.id, p3.id}) == 3


class TestTrainingProgressRetrieval:
    """Tests for retrieving progress."""

    def test_get_user_progress(self, service_with_data, test_db):
        """Test getting user's progress for a training."""
        service_with_data.create_progress("test-user-1", "test-training-1")
        progress = service_with_data.get_user_progress("test-user-1", "test-training-1")

        assert progress is not None
        assert progress.user_id == "test-user-1"
        assert progress.training_id == "test-training-1"

    def test_get_user_progress_nonexistent(self, service_with_data, test_db):
        """Test getting progress for non-existent user/training."""
        result = service_with_data.get_user_progress("non-existent", "test-training-1")
        assert result is None

    def test_get_user_all_progress(self, service_with_data, test_db):
        """Test getting all progress for a user."""
        service_with_data.create_progress("test-user-1", "test-training-1")
        service_with_data.create_progress("test-user-1", "test-training-2")
        service_with_data.create_progress("test-user-1", "test-training-3")

        progress_list, total = service_with_data.get_user_all_progress("test-user-1")

        assert total == 3
        assert len(progress_list) == 3

    def test_get_user_all_progress_pagination(self, service_with_data, test_db):
        """Test pagination of user's all progress."""
        for i in range(1, 4):
            service_with_data.create_progress("test-user-1", f"test-training-{i}")

        progress_list, total = service_with_data.get_user_all_progress("test-user-1", limit=2, offset=0)

        assert total == 3
        assert len(progress_list) == 2

    def test_get_user_all_progress_empty(self, service_with_data, test_db):
        """Test getting progress for user with none."""
        progress_list, total = service_with_data.get_user_all_progress("non-existent")
        assert len(progress_list) == 0
        assert total == 0


class TestTrainingProgressUpdates:
    """Tests for updating progress."""

    def test_update_progress_percentage(self, service_with_data, test_db):
        """Test updating progress percentage."""
        service_with_data.create_progress("test-user-1", "test-training-1")

        updated = service_with_data.update_progress("test-user-1", "test-training-1", 50.0)

        assert updated is not None
        assert updated.progress_percentage == 50.0

    def test_update_progress_clamps_to_range(self, service_with_data, test_db):
        """Test that progress percentage is clamped to 0-100."""
        service_with_data.create_progress("test-user-1", "test-training-1")

        # Test over 100
        updated = service_with_data.update_progress("test-user-1", "test-training-1", 150.0)
        assert updated.progress_percentage == 100.0

        # Test below 0
        updated = service_with_data.update_progress("test-user-1", "test-training-1", -10.0)
        assert updated.progress_percentage == 0.0

    def test_update_progress_creates_if_not_exists(self, service_with_data, test_db):
        """Test that updating progress creates record if not exists."""
        updated = service_with_data.update_progress("test-user-1", "test-training-1", 25.0)

        assert updated is not None
        assert updated.progress_percentage == 25.0


class TestTrainingProgressCompletion:
    """Tests for marking training as complete."""

    def test_mark_complete(self, service_with_data, test_db):
        """Test marking training as completed."""
        service_with_data.create_progress("test-user-1", "test-training-1")

        completed = service_with_data.mark_complete("test-user-1", "test-training-1")

        assert completed is not None
        assert completed.is_completed is True
        assert completed.progress_percentage == 100.0
        assert completed.completed_at is not None

    def test_mark_complete_creates_if_not_exists(self, service_with_data, test_db):
        """Test that mark_complete creates record if not exists."""
        completed = service_with_data.mark_complete("test-user-1", "test-training-1")

        assert completed is not None
        assert completed.is_completed is True

    def test_mark_complete_sets_timestamp(self, service_with_data, test_db):
        """Test that completion timestamp is set."""
        before = datetime.utcnow()
        service_with_data.mark_complete("test-user-1", "test-training-1")
        after = datetime.utcnow()

        progress = service_with_data.get_user_progress("test-user-1", "test-training-1")
        assert progress.completed_at is not None


class TestTrainingProgressAggregation:
    """Tests for aggregating module progress."""

    def test_get_module_progress_all_incomplete(self, service_with_data, test_db):
        """Test module progress when no trainings completed."""
        service_with_data.create_progress("test-user-1", "test-training-1")
        service_with_data.create_progress("test-user-1", "test-training-2")
        service_with_data.create_progress("test-user-1", "test-training-3")

        stats = service_with_data.get_module_progress("test-user-1", "test-module-1")

        assert stats["total_trainings"] == 3
        assert stats["completed_trainings"] == 0
        assert stats["overall_progress"] == 0.0

    def test_get_module_progress_partial_complete(self, service_with_data, test_db):
        """Test module progress with partial completion."""
        service_with_data.create_progress("test-user-1", "test-training-1")
        service_with_data.update_progress("test-user-1", "test-training-1", 50.0)

        service_with_data.create_progress("test-user-1", "test-training-2")
        service_with_data.mark_complete("test-user-1", "test-training-2")

        service_with_data.create_progress("test-user-1", "test-training-3")

        stats = service_with_data.get_module_progress("test-user-1", "test-module-1")

        assert stats["total_trainings"] == 3
        assert stats["completed_trainings"] == 1
        assert stats["overall_progress"] > 0

    def test_get_module_progress_all_complete(self, service_with_data, test_db):
        """Test module progress when all trainings completed."""
        service_with_data.mark_complete("test-user-1", "test-training-1")
        service_with_data.mark_complete("test-user-1", "test-training-2")
        service_with_data.mark_complete("test-user-1", "test-training-3")

        stats = service_with_data.get_module_progress("test-user-1", "test-module-1")

        assert stats["total_trainings"] == 3
        assert stats["completed_trainings"] == 3
        assert stats["overall_progress"] == 100.0

    def test_get_module_progress_nonexistent_module(self, service_with_data, test_db):
        """Test module progress for non-existent module."""
        stats = service_with_data.get_module_progress("test-user-1", "non-existent-module")

        assert stats["module_id"] == "non-existent-module"
        assert stats["total_trainings"] == 0
        assert stats["overall_progress"] == 0.0


class TestTrainingProgressDeletion:
    """Tests for deleting progress."""

    def test_delete_progress(self, service_with_data, test_db):
        """Test deleting progress record."""
        service_with_data.create_progress("test-user-1", "test-training-1")

        success = service_with_data.delete_progress("test-user-1", "test-training-1")

        assert success is True

        # Verify deleted
        retrieved = service_with_data.get_user_progress("test-user-1", "test-training-1")
        assert retrieved is None

    def test_delete_nonexistent_progress(self, service_with_data, test_db):
        """Test deleting non-existent progress."""
        success = service_with_data.delete_progress("test-user-1", "test-training-1")
        assert success is False


class TestTrainingProgressReset:
    """Tests for resetting progress."""

    def test_reset_progress(self, service_with_data, test_db):
        """Test resetting progress to 0%."""
        service_with_data.create_progress("test-user-1", "test-training-1")
        service_with_data.update_progress("test-user-1", "test-training-1", 50.0)
        service_with_data.mark_complete("test-user-1", "test-training-1")

        # Verify it's complete
        progress = service_with_data.get_user_progress("test-user-1", "test-training-1")
        assert progress.is_completed is True
        assert progress.progress_percentage == 100.0

        # Reset it
        reset = service_with_data.reset_progress("test-user-1", "test-training-1")

        assert reset is not None
        assert reset.progress_percentage == 0.0
        assert reset.is_completed is False
        assert reset.completed_at is None

    def test_reset_nonexistent_progress(self, service_with_data, test_db):
        """Test resetting non-existent progress."""
        result = service_with_data.reset_progress("test-user-1", "test-training-1")
        assert result is None


class TestTrainingProgressEdgeCases:
    """Tests for edge cases."""

    def test_multiple_users_same_training(self, service_with_data, test_db):
        """Test multiple users tracking same training."""
        p1 = service_with_data.create_progress("user-1", "test-training-1")
        p2 = service_with_data.create_progress("user-2", "test-training-1")

        assert p1.id != p2.id
        assert p1.training_id == p2.training_id
        assert p1.user_id != p2.user_id

    def test_same_user_multiple_trainings(self, service_with_data, test_db):
        """Test same user multiple trainings."""
        p1 = service_with_data.create_progress("test-user-1", "test-training-1")
        p2 = service_with_data.create_progress("test-user-1", "test-training-2")
        p3 = service_with_data.create_progress("test-user-1", "test-training-3")

        assert p1.user_id == p2.user_id == p3.user_id
        assert p1.training_id != p2.training_id != p3.training_id

    def test_progress_data_persistence(self, service_with_data, test_db):
        """Test that progress data is persisted correctly."""
        service_with_data.create_progress("test-user-1", "test-training-1")
        service_with_data.update_progress("test-user-1", "test-training-1", 75.0)

        # Retrieve and verify
        progress = service_with_data.get_user_progress("test-user-1", "test-training-1")
        assert progress.progress_percentage == 75.0

        # Update again
        service_with_data.update_progress("test-user-1", "test-training-1", 90.0)
        progress = service_with_data.get_user_progress("test-user-1", "test-training-1")
        assert progress.progress_percentage == 90.0
