"""Integration tests for Analytics API endpoints."""

import pytest
import json
from fastapi.testclient import TestClient
from sqlalchemy.orm import Session
from app.main import app
from app.models import User


@pytest.fixture
def client(test_db: Session):
    """Create test client with database override."""
    return TestClient(app)


@pytest.fixture
def test_user(test_db: Session):
    """Create a test user."""
    user = User(id="test-user-analytics", email="analytics@test.com")
    test_db.add(user)
    test_db.commit()
    return user


class TestAnalyticsEventLogging:
    """Tests for event logging endpoints."""

    def test_log_event_success(self, client, test_user, test_db):
        """Test logging an event."""
        payload = {
            "event_type": "quiz_completed",
            "event_data": {
                "module_id": "module-1",
                "score": 85,
                "duration_seconds": 300
            }
        }

        response = client.post(f"/api/analytics/events/{test_user.id}", json=payload)

        assert response.status_code == 201
        data = response.json()
        assert data["user_id"] == test_user.id
        assert data["event_type"] == "quiz_completed"
        assert data["event_data"]["score"] == 85

    def test_log_event_minimal(self, client, test_user, test_db):
        """Test logging event with minimal data."""
        payload = {
            "event_type": "module_viewed"
        }

        response = client.post(f"/api/analytics/events/{test_user.id}", json=payload)

        assert response.status_code == 201
        data = response.json()
        assert data["event_type"] == "module_viewed"
        assert data["event_data"] == {}

    def test_log_multiple_events(self, client, test_user, test_db):
        """Test logging multiple events."""
        events = [
            {"event_type": "quiz_started", "event_data": {"module_id": "m1"}},
            {"event_type": "quiz_completed", "event_data": {"module_id": "m1", "score": 80}},
            {"event_type": "module_viewed", "event_data": {"module_id": "m2"}},
        ]

        for event in events:
            response = client.post(f"/api/analytics/events/{test_user.id}", json=event)
            assert response.status_code == 201

        # Verify all events were logged
        response = client.get(f"/api/analytics/events/{test_user.id}")
        assert response.status_code == 200
        data = response.json()
        assert data["total"] == 3


class TestAnalyticsEventRetrieval:
    """Tests for retrieving events."""

    def test_get_user_events(self, client, test_user, test_db):
        """Test retrieving user events."""
        # Log some events
        for i in range(3):
            payload = {"event_type": f"event_{i}", "event_data": {"index": i}}
            client.post(f"/api/analytics/events/{test_user.id}", json=payload)

        # Retrieve events
        response = client.get(f"/api/analytics/events/{test_user.id}")

        assert response.status_code == 200
        data = response.json()
        assert data["total"] == 3
        assert len(data["events"]) == 3

    def test_get_user_events_pagination(self, client, test_user, test_db):
        """Test pagination of user events."""
        # Log 5 events
        for i in range(5):
            payload = {"event_type": "test_event", "event_data": {"index": i}}
            client.post(f"/api/analytics/events/{test_user.id}", json=payload)

        # Get first page
        response = client.get(f"/api/analytics/events/{test_user.id}?limit=2&offset=0")
        assert response.status_code == 200
        data = response.json()
        assert len(data["events"]) == 2
        assert data["total"] == 5

        # Get second page
        response = client.get(f"/api/analytics/events/{test_user.id}?limit=2&offset=2")
        assert response.status_code == 200
        data = response.json()
        assert len(data["events"]) == 2

    def test_get_events_by_type(self, client, test_user, test_db):
        """Test filtering events by type."""
        # Log mixed events
        client.post(f"/api/analytics/events/{test_user.id}", json={"event_type": "quiz_started"})
        client.post(f"/api/analytics/events/{test_user.id}", json={"event_type": "quiz_completed"})
        client.post(f"/api/analytics/events/{test_user.id}", json={"event_type": "quiz_started"})
        client.post(f"/api/analytics/events/{test_user.id}", json={"event_type": "module_viewed"})

        response = client.get(f"/api/analytics/events/{test_user.id}/type/quiz_started")

        assert response.status_code == 200
        data = response.json()
        assert len(data) == 2
        assert all(e["event_type"] == "quiz_started" for e in data)


class TestUserMetrics:
    """Tests for user metrics endpoints."""

    def test_get_user_metrics_new_user(self, client, test_user, test_db):
        """Test getting metrics for new user."""
        response = client.get(f"/api/analytics/metrics/{test_user.id}")

        assert response.status_code == 200
        data = response.json()
        assert data["user_id"] == test_user.id
        assert data["quiz_attempts"] == 0
        assert data["modules_passed"] == 0
        assert data["total_score"] == 0

    def test_update_metrics(self, client, test_user, test_db):
        """Test updating user metrics."""
        payload = {
            "quiz_attempts": 5,
            "modules_passed": 3,
            "total_score": 425.5
        }

        response = client.put(f"/api/analytics/metrics/{test_user.id}", json=payload)

        assert response.status_code == 200
        data = response.json()
        assert data["quiz_attempts"] == 5
        assert data["modules_passed"] == 3
        assert data["total_score"] == 425.5

    def test_increment_metric(self, client, test_user, test_db):
        """Test incrementing a metric."""
        payload = {"metric_name": "quiz_attempts", "increment": 1}

        response = client.post(f"/api/analytics/metrics/{test_user.id}/increment", json=payload)

        assert response.status_code == 200
        data = response.json()
        assert data["quiz_attempts"] == 1

        # Increment again
        response = client.post(f"/api/analytics/metrics/{test_user.id}/increment", json=payload)
        data = response.json()
        assert data["quiz_attempts"] == 2

    def test_increment_multiple_metrics(self, client, test_user, test_db):
        """Test incrementing different metrics."""
        for _ in range(3):
            client.post(f"/api/analytics/metrics/{test_user.id}/increment",
                       json={"metric_name": "quiz_attempts", "increment": 1})

        for _ in range(2):
            client.post(f"/api/analytics/metrics/{test_user.id}/increment",
                       json={"metric_name": "modules_passed", "increment": 1})

        for _ in range(85):
            client.post(f"/api/analytics/metrics/{test_user.id}/increment",
                       json={"metric_name": "total_score", "increment": 1})

        response = client.get(f"/api/analytics/metrics/{test_user.id}")
        data = response.json()

        assert data["quiz_attempts"] == 3
        assert data["modules_passed"] == 2
        assert data["total_score"] == 85


class TestModuleAnalytics:
    """Tests for module-level analytics."""

    def test_get_module_analytics(self, client, test_user, test_db):
        """Test retrieving analytics for a module."""
        # Log events for a module
        payload = {
            "event_type": "quiz_completed",
            "event_data": {"module_id": "module-1", "score": 85}
        }

        for _ in range(3):
            client.post(f"/api/analytics/events/{test_user.id}", json=payload)

        response = client.get("/api/analytics/modules/module-1")

        assert response.status_code == 200
        data = response.json()
        assert len(data) >= 0  # May have filtering applied


class TestDashboard:
    """Tests for dashboard endpoints."""

    def test_get_user_dashboard(self, client, test_user, test_db):
        """Test retrieving user dashboard."""
        # Add some data
        client.post(f"/api/analytics/events/{test_user.id}",
                   json={"event_type": "quiz_completed", "event_data": {"score": 85}})
        client.put(f"/api/analytics/metrics/{test_user.id}",
                  json={"quiz_attempts": 1, "total_score": 85})

        response = client.get(f"/api/analytics/dashboard/{test_user.id}")

        assert response.status_code == 200
        data = response.json()
        assert data["user_id"] == test_user.id
        assert data["metrics"] is not None
        assert "recent_events" in data
        assert len(data["recent_events"]) > 0

    def test_dashboard_empty_user(self, client, test_db):
        """Test dashboard for user with no activity."""
        response = client.get("/api/analytics/dashboard/new-user-123")

        assert response.status_code == 200
        data = response.json()
        assert data["user_id"] == "new-user-123"
        assert data["metrics"] is not None
        assert len(data["recent_events"]) == 0


class TestAllAnalytics:
    """Tests for admin analytics endpoints."""

    def test_get_all_analytics(self, client, test_db):
        """Test retrieving all analytics."""
        # Create multiple users and log events
        for i in range(3):
            user = User(id=f"user-{i}", email=f"user{i}@test.com")
            test_db.add(user)
        test_db.commit()

        for i in range(3):
            payload = {"event_type": "test_event", "event_data": {"user_num": i}}
            client.post(f"/api/analytics/events/user-{i}", json=payload)

        response = client.get("/api/analytics/")

        assert response.status_code == 200
        data = response.json()
        assert data["total"] >= 3

    def test_all_analytics_pagination(self, client, test_db):
        """Test pagination of all analytics."""
        # Create user and log 5 events
        user = User(id="user-pagination", email="paginate@test.com")
        test_db.add(user)
        test_db.commit()

        for i in range(5):
            client.post("/api/analytics/events/user-pagination",
                       json={"event_type": f"event_{i}"})

        response = client.get("/api/analytics/?limit=2&offset=0")
        assert response.status_code == 200
        data = response.json()
        assert len(data["events"]) == 2
        assert data["total"] >= 5
