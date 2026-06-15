"""Scenario models for coaching decision-based learning."""

from sqlalchemy import Column, String, Integer, Boolean, DateTime, ForeignKey, Text, Index
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.database import Base


class Scenario(Base):
    """Scenario for coaching practice and decision-making."""

    __tablename__ = "scenarios"

    id = Column(String, primary_key=True)  # UUID
    unit_id = Column(String, nullable=False, index=True)  # Links to training unit/module
    title = Column(String, nullable=False)
    description = Column(Text, nullable=True)  # Detailed scenario setup
    situation = Column(Text, nullable=False)  # The core scenario context
    order_number = Column(Integer, default=0, index=True)  # Display order within unit
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    # Relationships
    options = relationship("ScenarioOption", back_populates="scenario", cascade="all, delete-orphan")
    responses = relationship("ScenarioResponse", back_populates="scenario", cascade="all, delete-orphan")

    # Composite index for efficient queries
    __table_args__ = (
        Index("idx_unit_order", "unit_id", "order_number"),
    )

    def to_dict(self):
        return {
            "id": self.id,
            "unit_id": self.unit_id,
            "title": self.title,
            "description": self.description,
            "situation": self.situation,
            "order_number": self.order_number,
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "updated_at": self.updated_at.isoformat() if self.updated_at else None,
            "options": [o.to_dict() for o in self.options] if self.options else [],
        }


class ScenarioOption(Base):
    """Response options for a scenario."""

    __tablename__ = "scenario_options"

    id = Column(String, primary_key=True)  # UUID
    scenario_id = Column(String, ForeignKey("scenarios.id"), nullable=False, index=True)
    option_text = Column(Text, nullable=False)  # The user-selectable choice
    feedback = Column(Text, nullable=True)  # Feedback when selected
    is_optimal = Column(Boolean, default=False)  # Marks best/ideal response
    order_number = Column(Integer, default=0)  # Display order
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    # Relationships
    scenario = relationship("Scenario", back_populates="options", foreign_keys=[scenario_id])
    responses = relationship("ScenarioResponse", back_populates="option", cascade="all, delete-orphan")

    # Composite index for efficient queries
    __table_args__ = (
        Index("idx_scenario_order", "scenario_id", "order_number"),
    )

    def to_dict(self):
        return {
            "id": self.id,
            "scenario_id": self.scenario_id,
            "option_text": self.option_text,
            "feedback": self.feedback,
            "is_optimal": self.is_optimal,
            "order_number": self.order_number,
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "updated_at": self.updated_at.isoformat() if self.updated_at else None,
        }


class ScenarioResponse(Base):
    """User response to a scenario."""

    __tablename__ = "scenario_responses"

    id = Column(String, primary_key=True)  # UUID
    user_id = Column(String, ForeignKey("users.id"), nullable=False, index=True)
    scenario_id = Column(String, ForeignKey("scenarios.id"), nullable=False, index=True)
    selected_option_id = Column(String, ForeignKey("scenario_options.id"), nullable=False, index=True)
    timestamp = Column(DateTime(timezone=True), server_default=func.now(), index=True)

    # Relationships
    user = relationship("User", foreign_keys=[user_id])
    scenario = relationship("Scenario", back_populates="responses", foreign_keys=[scenario_id])
    option = relationship("ScenarioOption", back_populates="responses", foreign_keys=[selected_option_id])

    # Composite index for efficient queries
    __table_args__ = (
        Index("idx_user_scenario_time", "user_id", "scenario_id", "timestamp"),
    )

    def to_dict(self):
        return {
            "id": self.id,
            "user_id": self.user_id,
            "scenario_id": self.scenario_id,
            "selected_option_id": self.selected_option_id,
            "timestamp": self.timestamp.isoformat() if self.timestamp else None,
        }
