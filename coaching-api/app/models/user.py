"""User and Profile models for authentication."""

from sqlalchemy import Column, String, DateTime, Boolean, Text, Float, Integer, ForeignKey, JSON
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.database import Base


class User(Base):
    """User authentication record (mirrors Supabase auth.users)."""

    __tablename__ = "users"

    id = Column(String, primary_key=True)  # UUID from Supabase auth
    email = Column(String, unique=True, nullable=False, index=True)
    email_confirmed_at = Column(DateTime(timezone=True), nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    profile = relationship("UserProfile", back_populates="user", uselist=False, cascade="all, delete-orphan")

    def to_dict(self):
        return {
            "id": self.id,
            "email": self.email,
            "email_confirmed_at": self.email_confirmed_at.isoformat() if self.email_confirmed_at else None,
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "updated_at": self.updated_at.isoformat() if self.updated_at else None,
            "profile": self.profile.to_dict() if self.profile else None,
        }


class UserProfile(Base):
    """User profile and metadata."""

    __tablename__ = "profiles"

    id = Column(String, primary_key=True)  # Same as user.id
    user_id = Column(String, ForeignKey("users.id"), nullable=False, unique=True, index=True)
    full_name = Column(String, nullable=True)
    phone = Column(String, nullable=True, unique=True, index=True)
    avatar_url = Column(String, nullable=True)
    bio = Column(Text, nullable=True)
    role = Column(String, default="learner")  # learner, coach, admin
    is_active = Column(Boolean, default=True)
    # Assessment fields
    persona = Column(String, nullable=True)
    baseline_completed = Column(Boolean, default=False)
    baseline_score = Column(Float, nullable=True)
    endline_completed = Column(Boolean, default=False)
    endline_score = Column(Float, nullable=True)
    weak_modules = Column(JSON, default=[])
    baseline_attempt_count = Column(Integer, default=0)
    endline_attempt_count = Column(Integer, default=0)
    # Onboarding fields
    region = Column(String, nullable=True)
    sub_region = Column(String, nullable=True)
    punjab_cluster = Column(String, nullable=True)
    rawalpindi_cluster = Column(String, nullable=True)
    school_id = Column(String, nullable=True)
    teacher_ids = Column(JSON, nullable=True)
    qualifications = Column(JSON, nullable=True)
    experiences = Column(JSON, nullable=True)
    # Timestamps
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    user = relationship("User", back_populates="profile")

    def to_dict(self):
        return {
            "id": self.id,
            "user_id": self.user_id,
            "full_name": self.full_name,
            "email": self.user.email if self.user else None,
            "phone": self.phone,
            "avatar_url": self.avatar_url,
            "bio": self.bio,
            "role": self.role,
            "is_active": self.is_active,
            "persona": self.persona,
            "baseline_completed": self.baseline_completed or False,
            "baseline_score": self.baseline_score,
            "endline_completed": self.endline_completed or False,
            "endline_score": self.endline_score,
            "weak_modules": self.weak_modules or [],
            "baseline_attempt_count": self.baseline_attempt_count or 0,
            "endline_attempt_count": self.endline_attempt_count or 0,
            "region": self.region,
            "sub_region": self.sub_region,
            "punjab_cluster": self.punjab_cluster,
            "rawalpindi_cluster": self.rawalpindi_cluster,
            "school_id": self.school_id,
            "teacher_ids": self.teacher_ids,
            "qualifications": self.qualifications,
            "experiences": self.experiences,
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "updated_at": self.updated_at.isoformat() if self.updated_at else None,
        }


class UserRole(Base):
    """User role assignments."""

    __tablename__ = "user_roles"

    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(String, ForeignKey("users.id"), nullable=False, index=True)
    role = Column(String, nullable=False)  # admin, coach
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    def to_dict(self):
        return {
            "user_id": self.user_id,
            "role": self.role,
        }
