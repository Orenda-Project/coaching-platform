"""Assessment user tracking models (renamed from 'assessments' to avoid conflict with content table)."""

from sqlalchemy import Column, String, Integer, Float, DateTime, Boolean, ForeignKey, Text, JSON
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.database import Base


class Assessment(Base):
    """Assessment record for module quizzes (user tracking)."""

    __tablename__ = "assessments_user_tracking"

    id = Column(String, primary_key=True)  # UUID
    user_id = Column(String, ForeignKey("users.id"), nullable=False, index=True)
    module_id = Column(String, nullable=False, index=True)
    score = Column(Float, nullable=True)  # 0-100
    status = Column(String, default="in_progress")  # in_progress, submitted, graded
    attempt_number = Column(Integer, default=1)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    submitted_at = Column(DateTime(timezone=True), nullable=True)

    # Relationships
    user = relationship("User", foreign_keys=[user_id])
    responses = relationship("AssessmentResponse", back_populates="assessment", cascade="all, delete-orphan")
    attempts = relationship("AssessmentAttempt", back_populates="assessment", cascade="all, delete-orphan")

    def to_dict(self):
        return {
            "id": self.id,
            "user_id": self.user_id,
            "module_id": self.module_id,
            "score": self.score,
            "status": self.status,
            "attempt_number": self.attempt_number,
            "created_at": self.created_at.isoformat(),
            "updated_at": self.updated_at.isoformat(),
            "submitted_at": self.submitted_at.isoformat() if self.submitted_at else None,
            "responses": [r.to_dict() for r in self.responses] if self.responses else [],
        }


class AssessmentResponse(Base):
    """Individual question responses within an assessment."""

    __tablename__ = "assessment_responses"

    id = Column(String, primary_key=True)  # UUID
    assessment_id = Column(String, ForeignKey("assessments_user_tracking.id"), nullable=False, index=True)
    question_id = Column(String, nullable=False, index=True)
    user_answer = Column(Text, nullable=True)
    is_correct = Column(Boolean, nullable=True)
    points_earned = Column(Float, default=0)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    # Relationships
    assessment = relationship("Assessment", back_populates="responses", foreign_keys=[assessment_id])

    def to_dict(self):
        return {
            "id": self.id,
            "assessment_id": self.assessment_id,
            "question_id": self.question_id,
            "user_answer": self.user_answer,
            "is_correct": self.is_correct,
            "points_earned": self.points_earned,
            "created_at": self.created_at.isoformat(),
            "updated_at": self.updated_at.isoformat(),
        }


class AssessmentAttempt(Base):
    """Tracks multiple attempts at an assessment (for retakes)."""

    __tablename__ = "assessment_attempts"

    id = Column(String, primary_key=True)  # UUID
    assessment_id = Column(String, ForeignKey("assessments_user_tracking.id"), nullable=False, index=True)
    attempt_number = Column(Integer, nullable=False)
    score = Column(Float, nullable=True)
    passed = Column(Boolean, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    submitted_at = Column(DateTime(timezone=True), nullable=True)

    # Relationships
    assessment = relationship("Assessment", back_populates="attempts", foreign_keys=[assessment_id])

    def to_dict(self):
        return {
            "id": self.id,
            "assessment_id": self.assessment_id,
            "attempt_number": self.attempt_number,
            "score": self.score,
            "passed": self.passed,
            "created_at": self.created_at.isoformat(),
            "submitted_at": self.submitted_at.isoformat() if self.submitted_at else None,
        }
