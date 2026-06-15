"""Training progress and completion tracking models."""

from sqlalchemy import Column, String, Float, Integer, DateTime, Boolean, ForeignKey
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
import uuid
from app.database import Base


class ModuleQuizAttempt(Base):
    """Tracks quiz attempts per user per module."""

    __tablename__ = "module_quiz_attempts"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String, ForeignKey("users.id"), nullable=False, index=True)
    module_id = Column(String, nullable=False, index=True)
    score = Column(Float, default=0)
    best_score = Column(Float, default=0)
    passed = Column(Boolean, default=False)
    attempt_count = Column(Integer, default=0)
    completed_at = Column(DateTime(timezone=True), nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    user = relationship("User", foreign_keys=[user_id])

    def to_dict(self):
        return {
            "id": self.id,
            "user_id": self.user_id,
            "module_id": self.module_id,
            "score": self.score or 0,
            "best_score": self.best_score or 0,
            "passed": self.passed or False,
            "attempt_count": self.attempt_count or 0,
            "completed_at": self.completed_at.isoformat() if self.completed_at else None,
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "updated_at": self.updated_at.isoformat() if self.updated_at else None,
        }


class TrainingProgress(Base):
    """User progress tracking for training modules."""

    __tablename__ = "training_progress"

    id = Column(String, primary_key=True)  # UUID
    user_id = Column(String, ForeignKey("users.id"), nullable=False, index=True)
    training_id = Column(String, ForeignKey("trainings.id"), nullable=False, index=True)
    progress_percentage = Column(Float, default=0.0)  # 0-100
    is_completed = Column(Boolean, default=False)
    completed_at = Column(DateTime(timezone=True), nullable=True)
    # Quiz/assessment fields
    passed = Column(Boolean, default=False)
    score = Column(Float, nullable=True)
    attempt_count = Column(Integer, default=0)
    tab_switch_count = Column(Integer, default=0)
    fullscreen_violations = Column(Integer, default=0)
    flagged_for_review = Column(Boolean, default=False)
    content_completed = Column(Boolean, default=False)
    content_completed_at = Column(DateTime(timezone=True), nullable=True)
    started_at = Column(DateTime(timezone=True), nullable=True)
    # Timestamps
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    # Relationships
    user = relationship("User", foreign_keys=[user_id])
    training = relationship("Training", foreign_keys=[training_id])

    def to_dict(self):
        return {
            "id": self.id,
            "user_id": self.user_id,
            "training_id": self.training_id,
            "progress_percentage": self.progress_percentage,
            "is_completed": self.is_completed,
            "completed_at": self.completed_at.isoformat() if self.completed_at else None,
            "passed": self.passed or False,
            "score": self.score,
            "attempt_count": self.attempt_count or 0,
            "tab_switch_count": self.tab_switch_count or 0,
            "fullscreen_violations": self.fullscreen_violations or 0,
            "flagged_for_review": self.flagged_for_review or False,
            "content_completed": self.content_completed or False,
            "content_completed_at": self.content_completed_at.isoformat() if self.content_completed_at else None,
            "started_at": self.started_at.isoformat() if self.started_at else None,
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "updated_at": self.updated_at.isoformat() if self.updated_at else None,
        }
