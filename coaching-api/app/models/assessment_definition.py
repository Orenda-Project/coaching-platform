"""Assessment definition model - maps assessment types to training IDs."""

from sqlalchemy import Column, String, DateTime
from sqlalchemy.sql import func
from app.database import Base


class AssessmentDefinition(Base):
    """Maps assessment types (baseline, endline, module_quiz) to training IDs."""

    __tablename__ = "assessment_definitions"

    id = Column(String, primary_key=True)
    type = Column(String, nullable=False, index=True)  # baseline, endline, module_quiz
    training_id = Column(String, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    def to_dict(self):
        return {
            "id": self.id,
            "type": self.type,
            "training_id": self.training_id,
            "created_at": self.created_at.isoformat() if self.created_at else None,
        }