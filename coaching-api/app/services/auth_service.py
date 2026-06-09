"""Authentication service for user management."""

from sqlalchemy import select
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError
from datetime import datetime
from typing import Optional, Dict, Any
from app.models import User, UserProfile


class AuthService:
    """Service for authentication and user management operations."""

    def __init__(self, db: Session):
        self.db = db

    def create_user(self, user_id: str, email: str) -> Optional[User]:
        """
        Create a new user record.

        Args:
            user_id: UUID from Supabase auth
            email: User's email address

        Returns:
            Created User object or None if error
        """
        try:
            user = User(id=user_id, email=email)
            self.db.add(user)
            self.db.commit()
            self.db.refresh(user)
            return user
        except IntegrityError:
            self.db.rollback()
            return None

    def create_profile(
        self,
        user_id: str,
        full_name: Optional[str] = None,
        phone: Optional[str] = None,
        role: str = "learner"
    ) -> Optional[UserProfile]:
        """
        Create a user profile after signup.

        Args:
            user_id: UUID from user creation
            full_name: User's full name
            phone: User's phone number
            role: User role (learner, coach, admin)

        Returns:
            Created UserProfile object or None if error
        """
        try:
            profile = UserProfile(
                id=user_id,
                user_id=user_id,
                full_name=full_name,
                phone=phone,
                role=role,
            )
            self.db.add(profile)
            self.db.commit()
            self.db.refresh(profile)
            return profile
        except IntegrityError:
            self.db.rollback()
            return None

    def get_user_by_id(self, user_id: str) -> Optional[User]:
        """Get user by ID."""
        return self.db.execute(
            select(User).filter(User.id == user_id)
        ).scalar_one_or_none()

    def get_user_by_email(self, email: str) -> Optional[User]:
        """Get user by email address."""
        return self.db.execute(
            select(User).filter(User.email == email)
        ).scalar_one_or_none()

    def get_profile(self, user_id: str) -> Optional[UserProfile]:
        """Get user profile by user ID."""
        return self.db.execute(
            select(UserProfile).filter(UserProfile.user_id == user_id)
        ).scalar_one_or_none()

    def update_profile(
        self,
        user_id: str,
        **kwargs
    ) -> Optional[UserProfile]:
        """
        Update user profile.

        Args:
            user_id: User ID
            **kwargs: Fields to update (full_name, phone, avatar_url, bio, role, is_active)

        Returns:
            Updated UserProfile or None if not found
        """
        profile = self.get_profile(user_id)
        if not profile:
            return None

        # Allowed fields to update
        allowed_fields = {"full_name", "phone", "avatar_url", "bio", "role", "is_active"}
        for key, value in kwargs.items():
            if key in allowed_fields:
                setattr(profile, key, value)

        try:
            self.db.commit()
            self.db.refresh(profile)
            return profile
        except IntegrityError:
            self.db.rollback()
            return None

    def confirm_email(self, user_id: str) -> Optional[User]:
        """
        Mark email as confirmed.

        Args:
            user_id: User ID

        Returns:
            Updated User or None if not found
        """
        user = self.get_user_by_id(user_id)
        if not user:
            return None

        user.email_confirmed_at = datetime.utcnow()
        try:
            self.db.commit()
            self.db.refresh(user)
            return user
        except Exception:
            self.db.rollback()
            return None

    def delete_user(self, user_id: str) -> bool:
        """
        Delete user and profile.

        Args:
            user_id: User ID

        Returns:
            True if deleted, False if not found
        """
        user = self.get_user_by_id(user_id)
        if not user:
            return False

        try:
            self.db.delete(user)
            self.db.commit()
            return True
        except Exception:
            self.db.rollback()
            return False

    def list_users(self, limit: int = 100, offset: int = 0) -> tuple[list[User], int]:
        """
        List all users with pagination.

        Args:
            limit: Number of results
            offset: Results offset

        Returns:
            Tuple of (users list, total count)
        """
        from sqlalchemy import func

        # Get total count
        total = self.db.execute(
            select(func.count(User.id))
        ).scalar() or 0

        # Get paginated results
        users = self.db.execute(
            select(User).limit(limit).offset(offset)
        ).scalars().all()

        return list(users), total

    def user_exists(self, email: str) -> bool:
        """Check if user with email exists."""
        return self.db.execute(
            select(User).filter(User.email == email)
        ).scalar_one_or_none() is not None
