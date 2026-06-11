"""Scenario service for managing scenario-based learning."""

from sqlalchemy import select
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError
from datetime import datetime
from typing import Optional, List, Tuple
import uuid
from app.models import Scenario, ScenarioOption, ScenarioResponse, User


class ScenarioService:
    """Service for scenario management and responses."""

    def __init__(self, db: Session):
        self.db = db

    def get_scenario(self, scenario_id: str) -> Optional[Scenario]:
        """
        Get scenario by ID with all options.

        Args:
            scenario_id: Scenario ID

        Returns:
            Scenario object or None if not found
        """
        return self.db.execute(
            select(Scenario).filter(Scenario.id == scenario_id)
        ).scalar_one_or_none()

    def get_scenarios(self, unit_id: str) -> List[Scenario]:
        """
        Get all scenarios for a unit, ordered by order_number.

        Args:
            unit_id: Unit/Module ID

        Returns:
            List of scenarios
        """
        scenarios = self.db.execute(
            select(Scenario)
            .filter(Scenario.unit_id == unit_id)
            .order_by(Scenario.order_number)
        ).scalars().all()

        return list(scenarios)

    def get_option(self, option_id: str) -> Optional[ScenarioOption]:
        """
        Get scenario option by ID.

        Args:
            option_id: Option ID

        Returns:
            ScenarioOption or None
        """
        return self.db.execute(
            select(ScenarioOption).filter(ScenarioOption.id == option_id)
        ).scalar_one_or_none()

    def get_optimal_option(self, scenario_id: str) -> Optional[ScenarioOption]:
        """
        Get the optimal/best response option for a scenario.

        Args:
            scenario_id: Scenario ID

        Returns:
            Optimal ScenarioOption or None if not found
        """
        return self.db.execute(
            select(ScenarioOption)
            .filter(ScenarioOption.scenario_id == scenario_id, ScenarioOption.is_optimal == True)
            .order_by(ScenarioOption.order_number)
        ).scalar_one_or_none()

    def get_response_feedback(self, scenario_id: str, option_id: str) -> Optional[str]:
        """
        Get feedback for a selected option.

        Args:
            scenario_id: Scenario ID
            option_id: Selected option ID

        Returns:
            Feedback text or None
        """
        option = self.db.execute(
            select(ScenarioOption)
            .filter(ScenarioOption.scenario_id == scenario_id, ScenarioOption.id == option_id)
        ).scalar_one_or_none()

        return option.feedback if option else None

    def save_response(self, user_id: str, scenario_id: str, option_id: str) -> Optional[ScenarioResponse]:
        """
        Save a user's response to a scenario.

        Args:
            user_id: User ID
            scenario_id: Scenario ID
            option_id: Selected option ID

        Returns:
            Created ScenarioResponse or None if error
        """
        try:
            response = ScenarioResponse(
                id=str(uuid.uuid4()),
                user_id=user_id,
                scenario_id=scenario_id,
                selected_option_id=option_id,
            )
            self.db.add(response)
            self.db.commit()
            self.db.refresh(response)
            return response
        except IntegrityError:
            self.db.rollback()
            return None

    def update_response(self, response_id: str, option_id: str) -> Optional[ScenarioResponse]:
        """
        Update a user's response to a scenario.

        Args:
            response_id: Response ID
            option_id: New selected option ID

        Returns:
            Updated ScenarioResponse or None
        """
        response = self.db.execute(
            select(ScenarioResponse).filter(ScenarioResponse.id == response_id)
        ).scalar_one_or_none()

        if response is None:
            return None

        response.selected_option_id = option_id

        try:
            self.db.commit()
            self.db.refresh(response)
            return response
        except IntegrityError:
            self.db.rollback()
            return None

    def get_user_response_for_scenario(self, user_id: str, scenario_id: str) -> Optional[ScenarioResponse]:
        """
        Get a user's response to a specific scenario.

        Args:
            user_id: User ID
            scenario_id: Scenario ID

        Returns:
            ScenarioResponse or None if not found
        """
        return self.db.execute(
            select(ScenarioResponse)
            .filter(ScenarioResponse.user_id == user_id, ScenarioResponse.scenario_id == scenario_id)
            .order_by(ScenarioResponse.timestamp.desc())
        ).scalar_one_or_none()

    def get_user_responses(self, user_id: str) -> List[ScenarioResponse]:
        """
        Get all responses by a user.

        Args:
            user_id: User ID

        Returns:
            List of ScenarioResponse objects
        """
        responses = self.db.execute(
            select(ScenarioResponse)
            .filter(ScenarioResponse.user_id == user_id)
            .order_by(ScenarioResponse.timestamp.desc())
        ).scalars().all()

        return list(responses)

    def get_user_responses_paginated(self, user_id: str, limit: int = 100, offset: int = 0) -> Tuple[List[ScenarioResponse], int]:
        """
        Get user responses with pagination.

        Args:
            user_id: User ID
            limit: Results per page
            offset: Page offset

        Returns:
            Tuple of (responses list, total count)
        """
        from sqlalchemy import func

        total = self.db.execute(
            select(func.count(ScenarioResponse.id)).filter(ScenarioResponse.user_id == user_id)
        ).scalar() or 0

        responses = self.db.execute(
            select(ScenarioResponse)
            .filter(ScenarioResponse.user_id == user_id)
            .order_by(ScenarioResponse.timestamp.desc())
            .limit(limit)
            .offset(offset)
        ).scalars().all()

        return list(responses), total

    def get_scenario_responses(self, scenario_id: str) -> List[ScenarioResponse]:
        """
        Get all responses to a specific scenario (from all users).

        Args:
            scenario_id: Scenario ID

        Returns:
            List of ScenarioResponse objects
        """
        responses = self.db.execute(
            select(ScenarioResponse)
            .filter(ScenarioResponse.scenario_id == scenario_id)
            .order_by(ScenarioResponse.timestamp.desc())
        ).scalars().all()

        return list(responses)

    def get_user_scenario_stats(self, user_id: str, unit_id: str) -> dict:
        """
        Get statistics for user's responses in a unit.

        Args:
            user_id: User ID
            unit_id: Unit/Module ID

        Returns:
            Dictionary with completion stats
        """
        scenarios = self.get_scenarios(unit_id)
        responses = self.get_user_responses(user_id)

        responded_scenario_ids = {r.scenario_id for r in responses}
        completed = len(responded_scenario_ids)
        total = len(scenarios)

        # Count optimal responses
        optimal_count = 0
        for response in responses:
            if response.scenario_id in {s.id for s in scenarios}:
                option = self.get_option(response.selected_option_id)
                if option and option.is_optimal:
                    optimal_count += 1

        return {
            "unit_id": unit_id,
            "user_id": user_id,
            "total_scenarios": total,
            "completed_scenarios": completed,
            "optimal_responses": optimal_count,
            "percentage_optimal": round((optimal_count / len(responses) * 100) if responses else 0, 2),
        }
