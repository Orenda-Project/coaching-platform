"""Analytics models for tracking user events and metrics."""

from sqlalchemy import Column, String, Integer, Float, DateTime, JSON, ForeignKey, Index
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.database import Base


class AnalyticsEvent(Base):
    """User activity events for analytics tracking."""

    __tablename__ = "analytics_events"

    id = Column(String, primary_key=True)  # UUID
    user_id = Column(String, ForeignKey("users.id"), nullable=False, index=True)
    event_type = Column(String, nullable=False, index=True)  # quiz_completed, module_viewed, scenario_responded, etc.
    event_data = Column(JSON, nullable=True)  # Flexible event metadata
    timestamp = Column(DateTime(timezone=True), server_default=func.now(), index=True)

    # Relationships
    user = relationship("User", foreign_keys=[user_id])

    # Composite index for efficient queries
    __table_args__ = (
        Index("idx_user_event_timestamp", "user_id", "event_type", "timestamp"),
    )

    def to_dict(self):
        return {
            "id": self.id,
            "user_id": self.user_id,
            "event_type": self.event_type,
            "event_data": self.event_data or {},
            "timestamp": self.timestamp.isoformat(),
        }


class UserMetrics(Base):
    """Aggregated metrics for users."""

    __tablename__ = "user_metrics"

    id = Column(String, primary_key=True)  # UUID (or same as user_id for uniqueness)
    user_id = Column(String, ForeignKey("users.id"), nullable=False, unique=True, index=True)
    quiz_attempts = Column(Integer, default=0)  # Total quiz submissions
    modules_passed = Column(Integer, default=0)  # Completed modules
    total_score = Column(Float, default=0)  # Aggregate score (sum or average)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    # Relationships
    user = relationship("User", foreign_keys=[user_id])

    def to_dict(self):
        return {
            "id": self.id,
            "user_id": self.user_id,
            "quiz_attempts": self.quiz_attempts,
            "modules_passed": self.modules_passed,
            "total_score": self.total_score,
            "created_at": self.created_at.isoformat(),
            "updated_at": self.updated_at.isoformat(),
        }
