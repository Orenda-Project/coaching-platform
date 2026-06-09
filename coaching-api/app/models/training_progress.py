"""Training progress and completion tracking models."""

from sqlalchemy import Column, String, Float, DateTime, Boolean, ForeignKey
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.database import Base


class TrainingProgress(Base):
    """User progress tracking for training modules."""

    __tablename__ = "training_progress"

    id = Column(String, primary_key=True)  # UUID
    user_id = Column(String, ForeignKey("users.id"), nullable=False, index=True)
    training_id = Column(String, ForeignKey("export_trainings.id"), nullable=False, index=True)
    progress_percentage = Column(Float, default=0.0)  # 0-100
    is_completed = Column(Boolean, default=False)
    completed_at = Column(DateTime(timezone=True), nullable=True)
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
            "created_at": self.created_at.isoformat(),
            "updated_at": self.updated_at.isoformat(),
        }
