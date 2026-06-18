"""User feedback model for storing coach feedback and ratings."""

from sqlalchemy import Column, String, Integer, Text, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.database import Base


class UserFeedback(Base):
    """User-submitted feedback (ratings, comments, suggestions)."""

    __tablename__ = "user_feedback"

    id = Column(String, primary_key=True)
    user_id = Column(String, ForeignKey("users.id"), nullable=False, index=True)
    category = Column(String(50), nullable=False, default="other")
    rating = Column(Integer, nullable=False)
    positive_feedback = Column(Text, nullable=True)
    improvement_feedback = Column(Text, nullable=True)
    context_page = Column(String(255), nullable=True)
    module_id = Column(String, nullable=True)
    training_id = Column(String, nullable=True)
    persona = Column(String(10), nullable=True)
    user_agent = Column(String(500), nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    user = relationship("User", foreign_keys=[user_id])

    def to_dict(self):
        return {
            "id": self.id,
            "user_id": self.user_id,
            "category": self.category,
            "rating": self.rating,
            "positive_feedback": self.positive_feedback,
            "improvement_feedback": self.improvement_feedback,
            "context_page": self.context_page,
            "module_id": self.module_id,
            "training_id": self.training_id,
            "persona": self.persona,
            "created_at": self.created_at.isoformat() if self.created_at else None,
        }
