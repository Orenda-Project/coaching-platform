"""Observation models for tracking coaching observations and reflections."""

from sqlalchemy import Column, String, DateTime, Integer, Text, ForeignKey, Index, TIMESTAMP
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.database import Base


class Observation(Base):
    """Coaching observation record."""

    __tablename__ = "observations"

    id = Column(String, primary_key=True)  # UUID
    user_id = Column(String, nullable=False, index=True)  # Who the observation is about
    date = Column(DateTime(timezone=True), nullable=False)  # When the observation occurred
    notes = Column(Text, nullable=True)  # General observation notes
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    # Relationships
    cot_observations = relationship(
        "COTObservation",
        back_populates="observation",
        cascade="all, delete-orphan"
    )
    observation_notes = relationship(
        "ObservationNotes",
        back_populates="observation",
        cascade="all, delete-orphan"
    )

    __table_args__ = (
        Index('idx_observations_user_date', 'user_id', 'date'),
    )

    def to_dict(self):
        return {
            "id": self.id,
            "user_id": self.user_id,
            "date": self.date.isoformat(),
            "notes": self.notes,
            "created_at": self.created_at.isoformat(),
            "updated_at": self.updated_at.isoformat(),
            "cot_observations": [cot.to_dict() for cot in self.cot_observations] if self.cot_observations else [],
            "observation_notes": [note.to_dict() for note in self.observation_notes] if self.observation_notes else [],
        }


class COTObservation(Base):
    """Coaching Over Time (COT) observation - structured reflection framework."""

    __tablename__ = "cot_observations"

    id = Column(String, primary_key=True)  # UUID
    observation_id = Column(String, ForeignKey("observations.id"), nullable=False, index=True)
    category = Column(String, nullable=False)  # strengths, areas_for_growth, mindset, behaviors, etc.
    response = Column(Text, nullable=True)  # Coach's reflection on this category
    rating = Column(Integer, nullable=True)  # 1-5 rating for this category
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    # Relationships
    observation = relationship("Observation", back_populates="cot_observations")

    __table_args__ = (
        Index('idx_cot_observations_observation_category', 'observation_id', 'category'),
    )

    def to_dict(self):
        return {
            "id": self.id,
            "observation_id": self.observation_id,
            "category": self.category,
            "response": self.response,
            "rating": self.rating,
            "created_at": self.created_at.isoformat(),
            "updated_at": self.updated_at.isoformat(),
        }


class ObservationNotes(Base):
    """Additional notes and reflections on an observation."""

    __tablename__ = "observation_notes"

    id = Column(String, primary_key=True)  # UUID
    observation_id = Column(String, ForeignKey("observations.id"), nullable=False, index=True)
    note_text = Column(Text, nullable=False)
    created_by = Column(String, nullable=False)  # User ID of who created this note
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    # Relationships
    observation = relationship("Observation", back_populates="observation_notes")

    __table_args__ = (
        Index('idx_observation_notes_observation_creator', 'observation_id', 'created_by'),
    )

    def to_dict(self):
        return {
            "id": self.id,
            "observation_id": self.observation_id,
            "note_text": self.note_text,
            "created_by": self.created_by,
            "created_at": self.created_at.isoformat(),
            "updated_at": self.updated_at.isoformat(),
        }
