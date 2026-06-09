"""Observation service for managing coaching observations and reflections."""

from sqlalchemy import select
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError
from datetime import datetime
from typing import Optional, Dict, Any, List
import uuid
from app.models.observation import Observation, COTObservation, ObservationNotes


class ObservationService:
    """Service for observation and COT reflection operations."""

    def __init__(self, db: Session):
        self.db = db

    def create_observation(
        self,
        user_id: str,
        date: datetime,
        notes: Optional[str] = None
    ) -> Optional[Observation]:
        """
        Create a new observation record.

        Args:
            user_id: User ID of the person being observed
            date: Date/time of the observation
            notes: General observation notes

        Returns:
            Created Observation object or None if error
        """
        try:
            observation = Observation(
                id=str(uuid.uuid4()),
                user_id=user_id,
                date=date,
                notes=notes,
            )
            self.db.add(observation)
            self.db.commit()
            self.db.refresh(observation)
            return observation
        except Exception:
            self.db.rollback()
            return None

    def get_observation(self, observation_id: str) -> Optional[Observation]:
        """Get observation by ID."""
        return self.db.execute(
            select(Observation).filter(Observation.id == observation_id)
        ).scalar_one_or_none()

    def get_user_observations(
        self,
        user_id: str,
        limit: int = 100,
        offset: int = 0
    ) -> List[Observation]:
        """
        Get all observations for a user with pagination.

        Args:
            user_id: User ID
            limit: Number of results
            offset: Results offset

        Returns:
            List of observations
        """
        return self.db.execute(
            select(Observation)
            .filter(Observation.user_id == user_id)
            .order_by(Observation.date.desc())
            .limit(limit)
            .offset(offset)
        ).scalars().all()

    def update_observation(
        self,
        observation_id: str,
        data: Dict[str, Any]
    ) -> Optional[Observation]:
        """
        Update an observation.

        Args:
            observation_id: Observation ID
            data: Fields to update (notes)

        Returns:
            Updated Observation or None if not found
        """
        observation = self.get_observation(observation_id)
        if not observation:
            return None

        # Allowed fields to update
        allowed_fields = {"notes"}
        for key, value in data.items():
            if key in allowed_fields:
                setattr(observation, key, value)

        try:
            self.db.commit()
            self.db.refresh(observation)
            return observation
        except Exception:
            self.db.rollback()
            return None

    def delete_observation(self, observation_id: str) -> bool:
        """
        Delete an observation and all related records.

        Args:
            observation_id: Observation ID

        Returns:
            True if deleted, False if not found
        """
        observation = self.get_observation(observation_id)
        if not observation:
            return False

        try:
            self.db.delete(observation)
            self.db.commit()
            return True
        except Exception:
            self.db.rollback()
            return False

    def create_cot_observation(
        self,
        observation_id: str,
        category: str,
        response: Optional[str] = None,
        rating: Optional[int] = None
    ) -> Optional[COTObservation]:
        """
        Create a COT (Coaching Over Time) reflection for an observation.

        Args:
            observation_id: Observation ID
            category: Reflection category (strengths, areas_for_growth, mindset, behaviors, etc.)
            response: Coach's reflection
            rating: 1-5 rating

        Returns:
            Created COTObservation or None if error
        """
        # Verify observation exists
        observation = self.get_observation(observation_id)
        if not observation:
            return None

        try:
            cot_obs = COTObservation(
                id=str(uuid.uuid4()),
                observation_id=observation_id,
                category=category,
                response=response,
                rating=rating,
            )
            self.db.add(cot_obs)
            self.db.commit()
            self.db.refresh(cot_obs)
            return cot_obs
        except Exception:
            self.db.rollback()
            return None

    def get_cot_responses(self, observation_id: str) -> List[COTObservation]:
        """
        Get all COT responses for an observation.

        Args:
            observation_id: Observation ID

        Returns:
            List of COT observations
        """
        return self.db.execute(
            select(COTObservation)
            .filter(COTObservation.observation_id == observation_id)
            .order_by(COTObservation.created_at)
        ).scalars().all()

    def create_observation_note(
        self,
        observation_id: str,
        note_text: str,
        created_by: str
    ) -> Optional[ObservationNotes]:
        """
        Add a note to an observation.

        Args:
            observation_id: Observation ID
            note_text: The note content
            created_by: User ID of who created the note

        Returns:
            Created ObservationNotes or None if error
        """
        # Verify observation exists
        observation = self.get_observation(observation_id)
        if not observation:
            return None

        try:
            note = ObservationNotes(
                id=str(uuid.uuid4()),
                observation_id=observation_id,
                note_text=note_text,
                created_by=created_by,
            )
            self.db.add(note)
            self.db.commit()
            self.db.refresh(note)
            return note
        except Exception:
            self.db.rollback()
            return None

    def get_observation_notes(self, observation_id: str) -> List[ObservationNotes]:
        """
        Get all notes for an observation.

        Args:
            observation_id: Observation ID

        Returns:
            List of observation notes
        """
        return self.db.execute(
            select(ObservationNotes)
            .filter(ObservationNotes.observation_id == observation_id)
            .order_by(ObservationNotes.created_at.desc())
        ).scalars().all()

    def bulk_save_observations(
        self,
        observations_data: List[Dict[str, Any]]
    ) -> List[Observation]:
        """
        Bulk create observations.

        Args:
            observations_data: List of observation dicts with user_id, date, notes

        Returns:
            List of created observations
        """
        created_observations = []

        try:
            for obs_data in observations_data:
                observation = Observation(
                    id=str(uuid.uuid4()),
                    user_id=obs_data.get("user_id"),
                    date=obs_data.get("date"),
                    notes=obs_data.get("notes"),
                )
                self.db.add(observation)
                created_observations.append(observation)

            self.db.commit()
            for obs in created_observations:
                self.db.refresh(obs)
            return created_observations
        except Exception:
            self.db.rollback()
            return []
