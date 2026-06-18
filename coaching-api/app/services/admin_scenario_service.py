"""Admin scenario CRUD service."""

from sqlalchemy import select
from sqlalchemy.orm import Session
from typing import Optional, List, Dict, Any
import uuid

from app.models.training import Scenario, ScenarioOption


class AdminScenarioService:
    """Service for admin scenario management (CRUD)."""

    def __init__(self, db: Session):
        self.db = db

    def list_scenarios(self, training_id: Optional[str] = None) -> List[Dict]:
        query = select(Scenario)
        if training_id:
            query = query.filter(Scenario.training_id == training_id)
        rows = self.db.execute(query).scalars().all()
        return [s.to_dict() for s in rows]

    def get_scenario(self, scenario_id: str) -> Optional[Dict]:
        scenario = self.db.get(Scenario, scenario_id)
        if not scenario:
            return None
        return scenario.to_dict()

    def create_scenario(self, data: Dict[str, Any]) -> Dict:
        scenario = Scenario(
            id=data.get("id") or str(uuid.uuid4()),
            training_id=data["training_id"],
            situation=data.get("situation"),
            question=data.get("question"),
            difficulty=data.get("difficulty", "medium"),
        )
        self.db.add(scenario)
        self.db.commit()
        self.db.refresh(scenario)
        return scenario.to_dict()

    def update_scenario(self, scenario_id: str, data: Dict[str, Any]) -> Optional[Dict]:
        scenario = self.db.get(Scenario, scenario_id)
        if not scenario:
            return None
        for key in ("training_id", "situation", "question", "difficulty"):
            if key in data:
                setattr(scenario, key, data[key])
        self.db.commit()
        self.db.refresh(scenario)
        return scenario.to_dict()

    def delete_scenario(self, scenario_id: str) -> bool:
        scenario = self.db.get(Scenario, scenario_id)
        if not scenario:
            return False
        self.db.delete(scenario)
        self.db.commit()
        return True

    def upsert_options(self, scenario_id: str, options_data: List[Dict]) -> List[Dict]:
        """Upsert all options for a scenario. Deletes options not in the incoming list."""
        scenario = self.db.get(Scenario, scenario_id)
        if not scenario:
            raise ValueError(f"Scenario {scenario_id} not found")

        incoming_ids = {o.get("id") for o in options_data if o.get("id")}

        # Delete options not in incoming list
        existing = self.db.execute(
            select(ScenarioOption).filter(ScenarioOption.scenario_id == scenario_id)
        ).scalars().all()
        for eo in existing:
            if eo.id not in incoming_ids:
                self.db.delete(eo)

        for odata in options_data:
            o_id = odata.get("id") or str(uuid.uuid4())
            option = self.db.get(ScenarioOption, o_id)
            if option:
                option.letter = odata.get("letter", option.letter)
                option.option_text = odata.get("text", option.option_text)
                option.is_correct = odata.get("is_correct", option.is_correct)
                option.rationale = odata.get("rationale", option.rationale)
            else:
                option = ScenarioOption(
                    id=o_id,
                    scenario_id=scenario_id,
                    letter=odata.get("letter"),
                    option_text=odata.get("text", ""),
                    is_correct=odata.get("is_correct", False),
                    rationale=odata.get("rationale"),
                )
                self.db.add(option)

        self.db.commit()

        # Return fresh data
        self.db.refresh(scenario)
        return scenario.to_dict().get("options", [])
