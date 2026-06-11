"""Test definitions (baseline / midline / endline) for a role's learning track.

Introduced for the cluster_coordinator feature (MC20-18837). This is the test
*definition* entity. It is distinct from the attempt-focused `assessments`
table (per-user quiz attempts). Each test is scoped to a role via role_id and
owns its own questions (Question.test_id), so a role can have entirely separate
baseline/midline/endline tests without touching the existing training quizzes.
"""

from sqlalchemy import Column, String, Integer, Boolean, Text, DateTime, ForeignKey, CheckConstraint
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.database import Base

# Allowed test types — keep in sync with the DB CheckConstraint below.
TEST_TYPES = ("baseline", "midline", "endline")


class Test(Base):
    """A baseline/midline/endline test belonging to a role's track."""

    __tablename__ = "tests"
    __table_args__ = (
        CheckConstraint(
            "test_type IN ('baseline', 'midline', 'endline')",
            name="ck_tests_test_type",
        ),
    )

    id = Column(String, primary_key=True)  # UUID
    role_id = Column(String, ForeignKey("roles.id"), nullable=True, index=True)
    test_type = Column(String, nullable=False)  # baseline | midline | endline
    title = Column(String, nullable=False)
    description = Column(Text, nullable=True)
    order_number = Column(Integer, nullable=True)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    role = relationship("Role", back_populates="tests")
    questions = relationship("Question", back_populates="test", cascade="all, delete-orphan")

    def to_dict(self):
        return {
            "id": self.id,
            "role_id": self.role_id,
            "test_type": self.test_type,
            "title": self.title,
            "description": self.description,
            "order_number": self.order_number,
            "is_active": self.is_active,
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "updated_at": self.updated_at.isoformat() if self.updated_at else None,
            "questions": [q.to_dict() for q in self.questions] if self.questions else [],
        }
