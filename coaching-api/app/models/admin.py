"""Admin management models for user administration and issue tracking."""

from sqlalchemy import Column, String, DateTime, ForeignKey, Text, Enum as SQLEnum, Boolean
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.database import Base
import enum


class AdminRole(str, enum.Enum):
    """Admin role enumeration."""

    SUPER_ADMIN = "super_admin"
    REGIONAL_ADMIN = "regional_admin"


class FieldIssueStatus(str, enum.Enum):
    """Status enumeration for field issues."""

    OPEN = "open"
    IN_PROGRESS = "in_progress"
    RESOLVED = "resolved"
    CLOSED = "closed"


class AdminUser(Base):
    """Admin user record for managing system administrators."""

    __tablename__ = "admin_users"

    id = Column(String, primary_key=True)  # UUID
    user_id = Column(String, ForeignKey("users.id"), nullable=False, unique=True, index=True)
    role = Column(SQLEnum(AdminRole), default=AdminRole.SUPER_ADMIN, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    user = relationship("User", foreign_keys=[user_id])

    def to_dict(self):
        return {
            "id": self.id,
            "user_id": self.user_id,
            "role": self.role.value if isinstance(self.role, AdminRole) else self.role,
            "created_at": self.created_at.isoformat(),
            "updated_at": self.updated_at.isoformat(),
        }


class FieldIssue(Base):
    """Field issue tracking for on-ground reporting and resolution."""

    __tablename__ = "field_issues"

    id = Column(String, primary_key=True)  # UUID
    description = Column(Text, nullable=False)
    status = Column(SQLEnum(FieldIssueStatus), default=FieldIssueStatus.OPEN, nullable=False, index=True)
    reported_by = Column(String, ForeignKey("users.id"), nullable=False, index=True)
    assigned_to = Column(String, ForeignKey("users.id"), nullable=True, index=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    resolved_at = Column(DateTime(timezone=True), nullable=True)

    reporter = relationship("User", foreign_keys=[reported_by])
    assignee = relationship("User", foreign_keys=[assigned_to])

    def to_dict(self):
        return {
            "id": self.id,
            "description": self.description,
            "status": self.status.value if isinstance(self.status, FieldIssueStatus) else self.status,
            "reported_by": self.reported_by,
            "assigned_to": self.assigned_to,
            "created_at": self.created_at.isoformat(),
            "updated_at": self.updated_at.isoformat(),
            "resolved_at": self.resolved_at.isoformat() if self.resolved_at else None,
        }


class Region(Base):
    """Geographic region hierarchy for organizational structure."""

    __tablename__ = "regions"

    id = Column(String, primary_key=True)  # UUID
    name = Column(String, nullable=False, unique=True, index=True)
    parent_id = Column(String, ForeignKey("regions.id"), nullable=True, index=True)
    is_active = Column(Boolean, default=True, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    parent = relationship("Region", remote_side=[id], foreign_keys=[parent_id])
    children = relationship("Region", remote_side=[parent_id], cascade="all, delete-orphan")

    def to_dict(self):
        return {
            "id": self.id,
            "name": self.name,
            "parent_id": self.parent_id,
            "is_active": self.is_active,
            "created_at": self.created_at.isoformat(),
            "updated_at": self.updated_at.isoformat(),
        }
