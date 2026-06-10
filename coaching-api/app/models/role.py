"""Role lookup model — FK target for role-scoped content and tests.

Introduced for the cluster_coordinator feature (MC20-18837). Normalizes roles
into a table so content (modules, trainings) and tests can be scoped to an
audience without duplicating tables. Existing loose role strings on
user_profiles / admin_users are left untouched for backward compatibility.
"""

from sqlalchemy import Column, String, Text, DateTime
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.database import Base


class Role(Base):
    """A role/audience that owns its own learning track and tests."""

    __tablename__ = "roles"

    id = Column(String, primary_key=True)  # UUID
    name = Column(String, nullable=False, unique=True)  # e.g. coach, cluster_coordinator
    description = Column(Text, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    # Content scoped to this role
    modules = relationship("Module", back_populates="role")
    trainings = relationship("Training", back_populates="role")
    tests = relationship("Test", back_populates="role")

    def to_dict(self):
        return {
            "id": self.id,
            "name": self.name,
            "description": self.description,
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "updated_at": self.updated_at.isoformat() if self.updated_at else None,
        }
