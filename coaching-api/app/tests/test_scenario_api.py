"""Integration tests for Scenario API endpoints."""

import pytest
from fastapi.testclient import TestClient
from sqlalchemy.orm import Session
from app.main import app
from app.models import User, Scenario, ScenarioOption


@pytest.fixture
def client(test_db: Session):
    """Create test client with database override."""
    return TestClient(app)


@pytest.fixture
def test_user(test_db: Session):
    """Create a test user."""
    user = User(id="test-user-scenario", email="scenario@test.com")
    test_db.add(user)
    test_db.commit()
    return user


@pytest.fixture
def test_scenario(test_db: Session):
    """Create a test scenario with options."""
    scenario = Scenario(
        id="scenario-1",
        unit_id="unit-1",
        title="Customer Service Scenario",
        description="Handle an angry customer",
        situation="A customer is upset about a late delivery",
        order_number=1,
    )
    test_db.add(scenario)
    test_db.flush()

    options = [
        ScenarioOption(
            id="option-1",
            scenario_id="scenario-1",
            option_text="Listen and apologize sincerely",
            feedback="Good approach - shows empathy",
            is_optimal=True,
            order_number=1,
        ),
        ScenarioOption(
            id="option-2",
            scenario_id="scenario-1",
            option_text="Offer a discount to make up for it",
            feedback="Practical but doesn't address the root issue",
            is_optimal=False,
            order_number=2,
        ),
        ScenarioOption(
            id="option-3",
            scenario_id="scenario-1",
            option_text="Blame the shipping company",
            feedback="Avoids responsibility - not recommended",
            is_optimal=False,
            order_number=3,
        ),
    ]

    test_db.add_all(options)
    test_db.commit()

    return scenario


class TestScenarioRetrieval:
    """Tests for retrieving scenarios."""

    def test_get_scenario(self, client, test_scenario):
        """Test retrieving a scenario."""
        response = client.get(f"/api/scenarios/{test_scenario.id}")

        assert response.status_code == 200
        data = response.json()
        assert data["id"] == test_scenario.id
        assert data["title"] == "Customer Service Scenario"
        assert len(data["options"]) == 3

    def test_get_scenario_not_found(self, client):
        """Test retrieving non-existent scenario."""
        response = client.get("/api/scenarios/non-existent-scenario")

        assert response.status_code == 404

    def test_get_unit_scenarios(self, client, test_db, test_scenario):
        """Test retrieving all scenarios for a unit."""
        # Create additional scenarios
        s2 = Scenario(
            id="scenario-2", unit_id="unit-1", title="Scenario 2",
            description="Desc", situation="Situation 2", order_number=2
        )
        s3 = Scenario(
            id="scenario-3", unit_id="unit-2", title="Scenario 3",
            description="Desc", situation="Situation 3", order_number=1
        )
        test_db.add_all([s2, s3])
        test_db.commit()

        response = client.get("/api/scenarios/unit/unit-1")

        assert response.status_code == 200
        data = response.json()
        assert len(data) == 2
        assert data[0]["order_number"] == 1
        assert data[1]["order_number"] == 2

    def test_get_unit_scenarios_ordered(self, client, test_db):
        """Test that scenarios are returned in order."""
        for i in range(3):
            s = Scenario(
                id=f"s{i}", unit_id="unit-order", title=f"Scenario {i}",
                description="Desc", situation="Sit", order_number=i
            )
            test_db.add(s)
        test_db.commit()

        response = client.get("/api/scenarios/unit/unit-order")

        assert response.status_code == 200
        data = response.json()
        assert len(data) == 3
        assert [s["order_number"] for s in data] == [0, 1, 2]

    def test_get_unit_scenarios_empty(self, client):
        """Test retrieving scenarios for unit with none."""
        response = client.get("/api/scenarios/unit/non-existent-unit")

        assert response.status_code == 200
        data = response.json()
        assert len(data) == 0


class TestScenarioResponses:
    """Tests for user responses to scenarios."""

    def test_respond_to_scenario(self, client, test_user, test_scenario):
        """Test responding to a scenario."""
        payload = {"selected_option_id": "option-1"}

        response = client.post(
            f"/api/scenarios/{test_scenario.id}/respond/{test_user.id}",
            json=payload
        )

        assert response.status_code == 201
        data = response.json()
        assert data["user_id"] == test_user.id
        assert data["scenario_id"] == test_scenario.id
        assert data["selected_option_id"] == "option-1"

    def test_multiple_responses_same_scenario(self, client, test_user, test_scenario):
        """Test user can respond multiple times to same scenario."""
        response1 = client.post(
            f"/api/scenarios/{test_scenario.id}/respond/{test_user.id}",
            json={"selected_option_id": "option-1"}
        )
        assert response1.status_code == 201

        response2 = client.post(
            f"/api/scenarios/{test_scenario.id}/respond/{test_user.id}",
            json={"selected_option_id": "option-2"}
        )
        assert response2.status_code == 201

        # IDs should be different
        data1 = response1.json()
        data2 = response2.json()
        assert data1["id"] != data2["id"]

    def test_get_user_response_for_scenario(self, client, test_user, test_scenario):
        """Test retrieving user's response to scenario."""
        # Save response
        client.post(
            f"/api/scenarios/{test_scenario.id}/respond/{test_user.id}",
            json={"selected_option_id": "option-2"}
        )

        # Retrieve response
        response = client.get(
            f"/api/scenarios/{test_scenario.id}/user/{test_user.id}"
        )

        assert response.status_code == 200
        data = response.json()
        assert data["user_id"] == test_user.id
        assert data["selected_option_id"] == "option-2"

    def test_get_nonexistent_response(self, client, test_user, test_scenario):
        """Test retrieving response when user hasn't responded."""
        response = client.get(
            f"/api/scenarios/{test_scenario.id}/user/{test_user.id}"
        )

        assert response.status_code == 404

    def test_update_response(self, client, test_user, test_scenario):
        """Test updating a response."""
        # Save initial response
        save_response = client.post(
            f"/api/scenarios/{test_scenario.id}/respond/{test_user.id}",
            json={"selected_option_id": "option-1"}
        )
        response_id = save_response.json()["id"]

        # Update response
        update_payload = {"selected_option_id": "option-3"}
        response = client.put(
            f"/api/scenarios/{test_scenario.id}/respond/{response_id}",
            json=update_payload
        )

        assert response.status_code == 200
        data = response.json()
        assert data["id"] == response_id
        assert data["selected_option_id"] == "option-3"

    def test_update_nonexistent_response(self, client):
        """Test updating non-existent response."""
        response = client.put(
            "/api/scenarios/scenario-1/respond/non-existent-response",
            json={"selected_option_id": "option-1"}
        )

        assert response.status_code == 404


class TestUserResponses:
    """Tests for retrieving user's responses."""

    def test_get_user_responses(self, client, test_db, test_user):
        """Test retrieving all responses by a user."""
        # Create multiple scenarios
        for i in range(3):
            s = Scenario(
                id=f"s{i}", unit_id="unit-user-responses", title=f"Scenario {i}",
                description="Desc", situation="Sit", order_number=i
            )
            test_db.add(s)
        test_db.commit()

        # Create responses
        for i in range(3):
            client.post(
                f"/api/scenarios/s{i}/respond/{test_user.id}",
                json={"selected_option_id": "option-1"}
            )

        response = client.get(f"/api/scenarios/user/{test_user.id}/responses")

        assert response.status_code == 200
        data = response.json()
        assert data["total"] == 3
        assert len(data["responses"]) == 3

    def test_get_user_responses_pagination(self, client, test_db, test_user):
        """Test pagination of user responses."""
        # Create 5 scenarios and respond to all
        for i in range(5):
            s = Scenario(
                id=f"s-page{i}", unit_id="unit-pagination", title=f"Scenario {i}",
                description="Desc", situation="Sit", order_number=i
            )
            test_db.add(s)
        test_db.commit()

        for i in range(5):
            client.post(
                f"/api/scenarios/s-page{i}/respond/{test_user.id}",
                json={"selected_option_id": "option-1"}
            )

        # Get first page
        response = client.get(f"/api/scenarios/user/{test_user.id}/responses?limit=2&offset=0")
        assert response.status_code == 200
        data = response.json()
        assert len(data["responses"]) == 2
        assert data["total"] == 5

        # Get second page
        response = client.get(f"/api/scenarios/user/{test_user.id}/responses?limit=2&offset=2")
        data = response.json()
        assert len(data["responses"]) == 2

    def test_get_user_responses_empty(self, client):
        """Test retrieving responses for user with none."""
        response = client.get("/api/scenarios/user/new-user-responses/responses")

        assert response.status_code == 200
        data = response.json()
        assert data["total"] == 0
        assert len(data["responses"]) == 0


class TestScenarioFeedback:
    """Tests for scenario feedback and optimal responses."""

    def test_get_option_feedback(self, client):
        """Test retrieving option feedback."""
        response = client.get("/api/scenarios/option/option-1/feedback")

        assert response.status_code == 200
        data = response.json()
        assert data["option_id"] == "option-1"
        assert "empathy" in data["feedback"].lower()
        assert data["is_optimal"] is True

    def test_get_option_feedback_not_optimal(self, client):
        """Test retrieving feedback for non-optimal option."""
        response = client.get("/api/scenarios/option/option-2/feedback")

        assert response.status_code == 200
        data = response.json()
        assert data["is_optimal"] is False

    def test_get_nonexistent_option_feedback(self, client):
        """Test retrieving feedback for non-existent option."""
        response = client.get("/api/scenarios/option/non-existent/feedback")

        assert response.status_code == 404

    def test_get_optimal_response(self, client, test_scenario):
        """Test retrieving optimal response for scenario."""
        response = client.get(f"/api/scenarios/{test_scenario.id}/optimal")

        assert response.status_code == 200
        data = response.json()
        assert data["is_optimal"] is True
        assert data["id"] == "option-1"

    def test_get_optimal_response_not_found(self, client, test_db):
        """Test when scenario has no optimal option."""
        # Create scenario without optimal option
        scenario = Scenario(
            id="no-optimal", unit_id="unit-1", title="No Optimal",
            description="Desc", situation="Sit", order_number=1
        )
        option = ScenarioOption(
            id="opt-1", scenario_id="no-optimal", option_text="Option",
            feedback="Feedback", is_optimal=False, order_number=1
        )
        test_db.add_all([scenario, option])
        test_db.commit()

        response = client.get("/api/scenarios/no-optimal/optimal")

        assert response.status_code == 404


class TestScenarioStats:
    """Tests for scenario statistics."""

    def test_get_user_scenario_stats(self, client, test_db, test_user):
        """Test retrieving user's scenario statistics."""
        # Create 3 scenarios with options
        for i in range(3):
            s = Scenario(
                id=f"stat-s{i}", unit_id="unit-stats", title=f"Scenario {i}",
                description="Desc", situation="Sit", order_number=i
            )
            test_db.add(s)
            test_db.flush()

            # Add one optimal option per scenario
            opt = ScenarioOption(
                id=f"stat-opt{i}", scenario_id=f"stat-s{i}",
                option_text="Optimal", feedback="Good", is_optimal=True, order_number=1
            )
            test_db.add(opt)

        test_db.commit()

        # Respond to all scenarios with optimal choice
        for i in range(3):
            client.post(
                f"/api/scenarios/stat-s{i}/respond/{test_user.id}",
                json={"selected_option_id": f"stat-opt{i}"}
            )

        response = client.get(f"/api/scenarios/unit/unit-stats/stats/{test_user.id}")

        assert response.status_code == 200
        data = response.json()
        assert data["total_scenarios"] == 3
        assert data["completed_scenarios"] == 3
        assert data["optimal_responses"] == 3
        assert data["percentage_optimal"] == 100.0


class TestScenarioAggregation:
    """Tests for scenario-level aggregation."""

    def test_get_scenario_responses(self, client, test_db, test_user, test_scenario):
        """Test retrieving all responses to a scenario."""
        # Create additional user
        user2 = User(id="user-2", email="user2@scenario.com")
        test_db.add(user2)
        test_db.commit()

        # Both users respond
        client.post(
            f"/api/scenarios/{test_scenario.id}/respond/{test_user.id}",
            json={"selected_option_id": "option-1"}
        )
        client.post(
            f"/api/scenarios/{test_scenario.id}/respond/{user2.id}",
            json={"selected_option_id": "option-2"}
        )

        response = client.get(f"/api/scenarios/{test_scenario.id}/responses")

        assert response.status_code == 200
        data = response.json()
        assert data["total"] == 2
        assert len(data["responses"]) == 2

    def test_get_scenario_responses_pagination(self, client, test_db, test_scenario):
        """Test pagination of scenario responses."""
        # Create multiple users and respond
        for i in range(5):
            user = User(id=f"user-{i}", email=f"user{i}@scenario.com")
            test_db.add(user)
        test_db.commit()

        for i in range(5):
            client.post(
                f"/api/scenarios/{test_scenario.id}/respond/user-{i}",
                json={"selected_option_id": "option-1"}
            )

        response = client.get(f"/api/scenarios/{test_scenario.id}/responses?limit=2&offset=0")

        assert response.status_code == 200
        data = response.json()
        assert len(data["responses"]) == 2
        assert data["total"] == 5
