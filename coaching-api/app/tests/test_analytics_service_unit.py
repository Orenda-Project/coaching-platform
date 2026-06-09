"""Unit tests for AnalyticsService."""

import pytest
from datetime import datetime
from sqlalchemy.orm import Session
from app.models import User, AnalyticsEvent, UserMetrics
from app.services.analytics_service import AnalyticsService


@pytest.fixture
def service(test_db: Session) -> AnalyticsService:
    """Create AnalyticsService instance."""
    # Create test user
    user = User(id="test-user-1", email="test@example.com")
    test_db.add(user)
    test_db.commit()

    return AnalyticsService(test_db)


class TestAnalyticsServiceLogging:
    """Tests for event logging."""

    def test_log_event_success(self, service, test_db):
        """Test logging an analytics event."""
        event_data = {"module_id": "module-1", "score": 85}
        result = service.log_event("test-user-1", "quiz_completed", event_data)

        assert result is not None
        assert result.user_id == "test-user-1"
        assert result.event_type == "quiz_completed"
        assert result.event_data == event_data
        assert result.timestamp is not None

    def test_log_event_generates_id(self, service, test_db):
        """Test that logged event has unique ID."""
        event1 = service.log_event("test-user-1", "quiz_started", {})
        event2 = service.log_event("test-user-1", "quiz_completed", {})

        assert event1.id != event2.id
        assert len(event1.id) == 36  # UUID string format

    def test_log_multiple_event_types(self, service, test_db):
        """Test logging different event types."""
        event_types = ["quiz_started", "quiz_completed", "module_viewed", "scenario_responded"]

        for event_type in event_types:
            result = service.log_event("test-user-1", event_type, {})
            assert result.event_type == event_type

    def test_log_event_with_complex_data(self, service, test_db):
        """Test logging event with nested data structure."""
        complex_data = {
            "module_id": "module-1",
            "responses": [
                {"question_id": "q1", "answer": "A", "correct": True},
                {"question_id": "q2", "answer": "B", "correct": False},
            ],
            "score": 85.5,
            "metadata": {
                "duration_seconds": 300,
                "attempts": 1,
            }
        }
        result = service.log_event("test-user-1", "quiz_completed", complex_data)

        assert result.event_data == complex_data
        assert result.event_data["responses"][0]["correct"] is True


class TestAnalyticsServiceMetrics:
    """Tests for user metrics."""

    def test_get_user_metrics_new_user(self, service, test_db):
        """Test getting metrics for user with no data."""
        metrics = service.get_user_metrics("test-user-1")

        assert metrics is not None
        assert metrics.user_id == "test-user-1"
        assert metrics.quiz_attempts == 0
        assert metrics.modules_passed == 0
        assert metrics.total_score == 0

    def test_update_metrics_success(self, service, test_db):
        """Test updating user metrics."""
        service.log_event("test-user-1", "quiz_completed", {"score": 85})
        result = service.update_metrics("test-user-1", {
            "quiz_attempts": 1,
            "modules_passed": 1,
            "total_score": 85,
        })

        assert result is not None
        assert result.quiz_attempts == 1
        assert result.modules_passed == 1
        assert result.total_score == 85

    def test_get_user_metrics_with_data(self, service, test_db):
        """Test retrieving metrics after updates."""
        service.update_metrics("test-user-1", {
            "quiz_attempts": 3,
            "modules_passed": 2,
            "total_score": 250,
        })

        metrics = service.get_user_metrics("test-user-1")

        assert metrics.quiz_attempts == 3
        assert metrics.modules_passed == 2
        assert metrics.total_score == 250

    def test_increment_metrics(self, service, test_db):
        """Test incrementing metric counters."""
        service.increment_metric("test-user-1", "quiz_attempts", 1)
        service.increment_metric("test-user-1", "modules_passed", 1)
        service.increment_metric("test-user-1", "total_score", 85)

        metrics = service.get_user_metrics("test-user-1")

        assert metrics.quiz_attempts == 1
        assert metrics.modules_passed == 1
        assert metrics.total_score == 85


class TestAnalyticsServiceRetrieval:
    """Tests for querying analytics."""

    def test_get_user_events(self, service, test_db):
        """Test retrieving events for a user."""
        service.log_event("test-user-1", "quiz_started", {"module_id": "m1"})
        service.log_event("test-user-1", "quiz_completed", {"score": 85})
        service.log_event("test-user-1", "module_viewed", {"module_id": "m2"})

        events, total = service.get_user_events("test-user-1")

        assert len(events) == 3
        assert total == 3
        assert all(e.user_id == "test-user-1" for e in events)

    def test_get_user_events_pagination(self, service, test_db):
        """Test pagination of user events."""
        for i in range(5):
            service.log_event("test-user-1", "event_type", {"index": i})

        events, total = service.get_user_events("test-user-1", limit=2, offset=0)
        assert len(events) == 2
        assert total == 5

        events, total = service.get_user_events("test-user-1", limit=2, offset=2)
        assert len(events) == 2

    def test_get_events_by_type(self, service, test_db):
        """Test filtering events by type."""
        service.log_event("test-user-1", "quiz_started", {})
        service.log_event("test-user-1", "quiz_completed", {})
        service.log_event("test-user-1", "quiz_started", {})
        service.log_event("test-user-1", "module_viewed", {})

        events = service.get_events_by_type("test-user-1", "quiz_started")

        assert len(events) == 2
        assert all(e.event_type == "quiz_started" for e in events)

    def test_get_module_analytics(self, service, test_db):
        """Test retrieving analytics for a module."""
        # Create events from multiple users
        service.log_event("test-user-1", "quiz_completed", {"module_id": "mod-1", "score": 85})
        service.log_event("test-user-1", "quiz_completed", {"module_id": "mod-1", "score": 90})

        user2 = User(id="test-user-2", email="user2@example.com")
        test_db.add(user2)
        test_db.commit()

        service.log_event("test-user-2", "quiz_completed", {"module_id": "mod-1", "score": 75})

        analytics = service.get_module_analytics("mod-1")

        assert len(analytics) == 3
        assert all("module_id" in e.event_data for e in analytics)

    def test_get_all_analytics_paginated(self, service, test_db):
        """Test retrieving all analytics with pagination."""
        for i in range(5):
            service.log_event("test-user-1", f"event_{i}", {})

        events, total = service.get_all_analytics(limit=2, offset=0)
        assert len(events) == 2
        assert total == 5


class TestAnalyticsServiceEdgeCases:
    """Tests for edge cases and error handling."""

    def test_log_event_empty_data(self, service, test_db):
        """Test logging event with empty data."""
        result = service.log_event("test-user-1", "test_event", {})
        assert result is not None
        assert result.event_data == {}

    def test_log_event_null_data(self, service, test_db):
        """Test logging event with None data (should convert to empty dict)."""
        result = service.log_event("test-user-1", "test_event", None)
        assert result is not None

    def test_get_events_nonexistent_user(self, service, test_db):
        """Test retrieving events for non-existent user returns empty list."""
        events, total = service.get_user_events("non-existent-user")
        assert len(events) == 0
        assert total == 0

    def test_get_metrics_nonexistent_user(self, service, test_db):
        """Test that metrics are auto-created for non-existent user."""
        metrics = service.get_user_metrics("non-existent-user")
        assert metrics is not None
        assert metrics.user_id == "non-existent-user"

    def test_concurrent_metric_updates(self, service, test_db):
        """Test that metric updates are applied correctly in sequence."""
        service.increment_metric("test-user-1", "quiz_attempts", 1)
        service.increment_metric("test-user-1", "quiz_attempts", 1)
        service.increment_metric("test-user-1", "quiz_attempts", 1)

        metrics = service.get_user_metrics("test-user-1")
        assert metrics.quiz_attempts == 3
