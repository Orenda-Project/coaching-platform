"""Unit tests for ScenarioService."""

import pytest
from sqlalchemy.orm import Session
from app.models import User, Scenario, ScenarioOption, ScenarioResponse
from app.services.scenario_service import ScenarioService


@pytest.fixture
def service(test_db: Session) -> ScenarioService:
    """Create ScenarioService instance."""
    # Create test users
    user = User(id="test-user-1", email="test@example.com")
    user2 = User(id="test-user-2", email="user2@example.com")
    test_db.add_all([user, user2])
    test_db.commit()

    return ScenarioService(test_db)


@pytest.fixture
def test_scenario(test_db: Session):
    """Create test scenario with options."""
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

    option1 = ScenarioOption(
        id="option-1",
        scenario_id="scenario-1",
        option_text="Listen and apologize sincerely",
        feedback="Good approach - shows empathy",
        is_optimal=True,
        order_number=1,
    )
    option2 = ScenarioOption(
        id="option-2",
        scenario_id="scenario-1",
        option_text="Offer a discount to make up for it",
        feedback="Practical but doesn't address the root issue",
        is_optimal=False,
        order_number=2,
    )
    option3 = ScenarioOption(
        id="option-3",
        scenario_id="scenario-1",
        option_text="Blame the shipping company",
        feedback="Avoids responsibility - not recommended",
        is_optimal=False,
        order_number=3,
    )

    test_db.add_all([option1, option2, option3])
    test_db.commit()

    return scenario


class TestScenarioServiceRetrieval:
    """Tests for retrieving scenarios."""

    def test_get_scenario_by_id(self, service, test_db, test_scenario):
        """Test retrieving scenario by ID."""
        result = service.get_scenario("scenario-1")

        assert result is not None
        assert result.id == "scenario-1"
        assert result.title == "Customer Service Scenario"
        assert result.unit_id == "unit-1"

    def test_get_scenario_with_options(self, service, test_db, test_scenario):
        """Test that scenario includes options."""
        result = service.get_scenario("scenario-1")

        assert result.options is not None
        assert len(result.options) == 3
        assert all(opt.scenario_id == "scenario-1" for opt in result.options)

    def test_get_scenario_nonexistent(self, service, test_db):
        """Test retrieving non-existent scenario returns None."""
        result = service.get_scenario("non-existent-id")
        assert result is None

    def test_get_scenarios_by_unit(self, service, test_db):
        """Test retrieving all scenarios for a unit."""
        # Create multiple scenarios for same unit
        s1 = Scenario(
            id="s1", unit_id="unit-1", title="Scenario 1",
            description="Desc 1", situation="Sit 1", order_number=1
        )
        s2 = Scenario(
            id="s2", unit_id="unit-1", title="Scenario 2",
            description="Desc 2", situation="Sit 2", order_number=2
        )
        s3 = Scenario(
            id="s3", unit_id="unit-2", title="Scenario 3",
            description="Desc 3", situation="Sit 3", order_number=1
        )

        test_db.add_all([s1, s2, s3])
        test_db.commit()

        scenarios = service.get_scenarios("unit-1")

        assert len(scenarios) == 2
        assert all(s.unit_id == "unit-1" for s in scenarios)
        assert scenarios[0].order_number == 1
        assert scenarios[1].order_number == 2

    def test_get_scenarios_ordered(self, service, test_db):
        """Test that scenarios are returned in order."""
        for i in range(5):
            s = Scenario(
                id=f"s{i}", unit_id="unit-1", title=f"Scenario {i}",
                description=f"Desc {i}", situation=f"Sit {i}", order_number=i
            )
            test_db.add(s)
        test_db.commit()

        scenarios = service.get_scenarios("unit-1")

        for i, scenario in enumerate(scenarios):
            assert scenario.order_number == i

    def test_get_scenarios_empty_unit(self, service, test_db):
        """Test retrieving scenarios for unit with none."""
        scenarios = service.get_scenarios("non-existent-unit")
        assert len(scenarios) == 0


class TestScenarioServiceResponses:
    """Tests for scenario responses."""

    def test_save_response_success(self, service, test_db, test_scenario):
        """Test saving a user response to scenario."""
        response = service.save_response("test-user-1", "scenario-1", "option-1")

        assert response is not None
        assert response.user_id == "test-user-1"
        assert response.scenario_id == "scenario-1"
        assert response.selected_option_id == "option-1"
        assert response.timestamp is not None

    def test_save_response_generates_id(self, service, test_db, test_scenario):
        """Test that responses get unique IDs."""
        response1 = service.save_response("test-user-1", "scenario-1", "option-1")
        response2 = service.save_response("test-user-1", "scenario-1", "option-2")

        assert response1.id != response2.id
        assert len(response1.id) == 36  # UUID

    def test_save_response_multiple_users(self, service, test_db, test_scenario):
        """Test that different users can respond to same scenario."""
        response1 = service.save_response("test-user-1", "scenario-1", "option-1")
        response2 = service.save_response("test-user-2", "scenario-1", "option-2")

        assert response1.user_id != response2.user_id
        assert response1.selected_option_id != response2.selected_option_id

    def test_get_user_responses(self, service, test_db, test_scenario):
        """Test retrieving all responses by a user."""
        # Create multiple scenarios and responses
        for i in range(3):
            s = Scenario(
                id=f"s{i}", unit_id="unit-1", title=f"Scenario {i}",
                description=f"Desc {i}", situation=f"Sit {i}", order_number=i
            )
            test_db.add(s)
        test_db.commit()

        for i in range(3):
            service.save_response("test-user-1", f"s{i}", f"option-{i%3}")

        responses = service.get_user_responses("test-user-1")

        assert len(responses) == 3
        assert all(r.user_id == "test-user-1" for r in responses)

    def test_get_user_responses_empty(self, service, test_db):
        """Test retrieving responses for user with none."""
        responses = service.get_user_responses("non-existent-user")
        assert len(responses) == 0

    def test_get_user_responses_paginated(self, service, test_db, test_scenario):
        """Test pagination of user responses."""
        # Create multiple scenarios
        for i in range(5):
            s = Scenario(
                id=f"s{i}", unit_id="unit-1", title=f"Scenario {i}",
                description=f"Desc {i}", situation=f"Sit {i}", order_number=i
            )
            test_db.add(s)
        test_db.commit()

        for i in range(5):
            service.save_response("test-user-1", f"s{i}", "option-1")

        responses, total = service.get_user_responses_paginated("test-user-1", limit=2, offset=0)
        assert len(responses) == 2
        assert total == 5

        responses, total = service.get_user_responses_paginated("test-user-1", limit=2, offset=2)
        assert len(responses) == 2

    def test_get_scenario_responses(self, service, test_db, test_scenario):
        """Test retrieving all responses for a specific scenario."""
        service.save_response("test-user-1", "scenario-1", "option-1")
        service.save_response("test-user-2", "scenario-1", "option-2")

        user3 = User(id="test-user-3", email="user3@example.com")
        test_db.add(user3)
        test_db.commit()

        service.save_response("test-user-3", "scenario-1", "option-1")

        responses = service.get_scenario_responses("scenario-1")

        assert len(responses) == 3
        assert all(r.scenario_id == "scenario-1" for r in responses)

    def test_get_user_response_for_scenario(self, service, test_db, test_scenario):
        """Test retrieving a specific user's response to a scenario."""
        service.save_response("test-user-1", "scenario-1", "option-1")

        response = service.get_user_response_for_scenario("test-user-1", "scenario-1")

        assert response is not None
        assert response.user_id == "test-user-1"
        assert response.scenario_id == "scenario-1"
        assert response.selected_option_id == "option-1"

    def test_get_user_response_nonexistent(self, service, test_db, test_scenario):
        """Test retrieving non-existent response returns None."""
        response = service.get_user_response_for_scenario("test-user-1", "scenario-1")
        assert response is None


class TestScenarioServiceUpdates:
    """Tests for updating scenarios and options."""

    def test_update_response(self, service, test_db, test_scenario):
        """Test updating a user's response."""
        # Save initial response
        response = service.save_response("test-user-1", "scenario-1", "option-1")
        original_id = response.id

        # Update response
        updated = service.update_response(original_id, "option-2")

        assert updated is not None
        assert updated.id == original_id
        assert updated.selected_option_id == "option-2"

    def test_get_response_feedback(self, service, test_db, test_scenario):
        """Test getting feedback for a selected option."""
        feedback = service.get_response_feedback("scenario-1", "option-1")

        assert feedback is not None
        assert "empathy" in feedback.lower()

    def test_get_option_details(self, service, test_db, test_scenario):
        """Test retrieving option details."""
        option = service.get_option("option-1")

        assert option is not None
        assert option.scenario_id == "scenario-1"
        assert option.is_optimal is True

    def test_get_optimal_option_for_scenario(self, service, test_db, test_scenario):
        """Test finding optimal option for scenario."""
        optimal = service.get_optimal_option("scenario-1")

        assert optimal is not None
        assert optimal.is_optimal is True
        assert optimal.option_text == "Listen and apologize sincerely"


class TestScenarioServiceEdgeCases:
    """Tests for edge cases and error handling."""

    def test_save_response_invalid_scenario(self, service, test_db):
        """Test saving response to non-existent scenario."""
        response = service.save_response("test-user-1", "non-existent", "option-1")
        # Service may still create the response (no FK constraint)
        assert response is not None

    def test_save_response_invalid_option(self, service, test_db, test_scenario):
        """Test saving response with non-existent option."""
        response = service.save_response("test-user-1", "scenario-1", "non-existent-option")
        # Service may still create the response
        assert response is not None
        assert response.selected_option_id == "non-existent-option"

    def test_scenario_with_no_options(self, service, test_db):
        """Test scenario with no options."""
        scenario = Scenario(
            id="empty-scenario", unit_id="unit-1", title="Empty",
            description="No options", situation="Test", order_number=1
        )
        test_db.add(scenario)
        test_db.commit()

        retrieved = service.get_scenario("empty-scenario")
        assert retrieved.options == []

    def test_multiple_responses_same_scenario(self, service, test_db, test_scenario):
        """Test user can respond multiple times to same scenario."""
        response1 = service.save_response("test-user-1", "scenario-1", "option-1")
        response2 = service.save_response("test-user-1", "scenario-1", "option-2")

        assert response1.id != response2.id
        assert response1.scenario_id == response2.scenario_id
        assert response1.user_id == response2.user_id

    def test_scenario_ordering_with_gaps(self, service, test_db):
        """Test scenarios with non-sequential order_number values."""
        s1 = Scenario(
            id="s1", unit_id="unit-1", title="Scenario 1",
            description="Desc", situation="Sit", order_number=1
        )
        s2 = Scenario(
            id="s2", unit_id="unit-1", title="Scenario 5",
            description="Desc", situation="Sit", order_number=5
        )
        s3 = Scenario(
            id="s3", unit_id="unit-1", title="Scenario 3",
            description="Desc", situation="Sit", order_number=3
        )

        test_db.add_all([s1, s2, s3])
        test_db.commit()

        scenarios = service.get_scenarios("unit-1")

        assert scenarios[0].order_number == 1
        assert scenarios[1].order_number == 3
        assert scenarios[2].order_number == 5
