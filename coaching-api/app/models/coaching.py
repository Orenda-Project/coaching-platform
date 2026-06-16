"""Coaching session and feedback models."""

from sqlalchemy import Column, String, DateTime, Integer, Text, ForeignKey, Index, TIMESTAMP
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.database import Base


class CoachingSession(Base):
    """Coaching session between a coach and coachee."""

    __tablename__ = "coaching_sessions"

    id = Column(String, primary_key=True)  # UUID
    coach_id = Column(String, nullable=False, index=True)  # User ID of the coach
    coachee_id = Column(String, nullable=False, index=True)  # User ID of the learner being coached
    date = Column(DateTime(timezone=True), nullable=False)  # Scheduled session date/time
    status = Column(String, default="scheduled")  # scheduled, in_progress, completed, cancelled
    notes = Column(Text, nullable=True)  # Session summary notes
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    # Relationships
    feedback = relationship(
        "Feedback",
        back_populates="session",
        cascade="all, delete-orphan"
    )
    session_notes = relationship(
        "SessionNote",
        back_populates="session",
        cascade="all, delete-orphan"
    )

    __table_args__ = (
        Index('idx_coaching_sessions_coach_date', 'coach_id', 'date'),
        Index('idx_coaching_sessions_coachee_date', 'coachee_id', 'date'),
    )

    def to_dict(self):
        return {
            "id": self.id,
            "coach_id": self.coach_id,
            "coachee_id": self.coachee_id,
            "date": self.date.isoformat() if self.date else None,
            "status": self.status,
            "notes": self.notes,
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "updated_at": self.updated_at.isoformat() if self.updated_at else None,
            "feedback": [f.to_dict() for f in self.feedback] if self.feedback else [],
            "session_notes": [note.to_dict() for note in self.session_notes] if self.session_notes else [],
        }


class Feedback(Base):
    """Feedback provided in a coaching session."""

    __tablename__ = "feedback"

    id = Column(String, primary_key=True)  # UUID
    session_id = Column(String, ForeignKey("coaching_sessions.id"), nullable=False, index=True)
    category = Column(String, nullable=False)  # communication, engagement, progress, areas_for_growth, etc.
    rating = Column(Integer, nullable=True)  # 1-5 rating
    comments = Column(Text, nullable=True)  # Detailed feedback comments
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    # Relationships
    session = relationship("CoachingSession", back_populates="feedback")

    __table_args__ = (
        Index('idx_feedback_session_category', 'session_id', 'category'),
    )

    def to_dict(self):
        return {
            "id": self.id,
            "session_id": self.session_id,
            "category": self.category,
            "rating": self.rating,
            "comments": self.comments,
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "updated_at": self.updated_at.isoformat() if self.updated_at else None,
        }


class SessionNote(Base):
    """Notes taken during or after a coaching session."""

    __tablename__ = "session_notes"

    id = Column(String, primary_key=True)  # UUID
    session_id = Column(String, ForeignKey("coaching_sessions.id"), nullable=False, index=True)
    content = Column(Text, nullable=False)  # The note content
    created_by = Column(String, nullable=False)  # User ID of who created this note (coach or observer)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    # Relationships
    session = relationship("CoachingSession", back_populates="session_notes")

    __table_args__ = (
        Index('idx_session_notes_session_creator', 'session_id', 'created_by'),
    )

    def to_dict(self):
        return {
            "id": self.id,
            "session_id": self.session_id,
            "content": self.content,
            "created_by": self.created_by,
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "updated_at": self.updated_at.isoformat() if self.updated_at else None,
        }
