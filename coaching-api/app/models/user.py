"""User and Profile models for authentication."""

from sqlalchemy import Column, String, DateTime, Boolean, Text, ForeignKey
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
            "created_at": self.created_at.isoformat(),
            "updated_at": self.updated_at.isoformat(),
            "profile": self.profile.to_dict() if self.profile else None,
        }


class UserProfile(Base):
    """User profile and metadata."""

    __tablename__ = "user_profiles"

    id = Column(String, primary_key=True)  # Same as user.id
    user_id = Column(String, ForeignKey("users.id"), nullable=False, unique=True, index=True)
    full_name = Column(String, nullable=True)
    phone = Column(String, nullable=True, unique=True, index=True)
    avatar_url = Column(String, nullable=True)
    bio = Column(Text, nullable=True)
    role = Column(String, default="learner")  # learner, coach, admin
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    user = relationship("User", back_populates="profile")

    def to_dict(self):
        return {
            "id": self.id,
            "user_id": self.user_id,
            "full_name": self.full_name,
            "phone": self.phone,
            "avatar_url": self.avatar_url,
            "bio": self.bio,
            "role": self.role,
            "is_active": self.is_active,
            "created_at": self.created_at.isoformat(),
            "updated_at": self.updated_at.isoformat(),
        }
