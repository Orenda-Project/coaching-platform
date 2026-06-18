"""Authentication service for user management."""

from sqlalchemy import select
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError
from datetime import datetime
from typing import Optional, Dict, Any, List
from app.models import User, UserProfile, UserRole
from app.models.certificate import Certificate
import uuid


class AuthService:
    """Service for authentication and user management operations."""

    def __init__(self, db: Session):
        self.db = db

    def create_user(self, user_id: str, email: str) -> Optional[User]:
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
        except IntegrityError as e:
            self.db.rollback()
            import logging
            logging.getLogger(__name__).error(
                f"Profile creation failed for user_id={user_id}: {e.orig}"
            )
            return None

    def get_user_by_id(self, user_id: str) -> Optional[User]:
        return self.db.execute(
            select(User).filter(User.id == user_id)
        ).scalar_one_or_none()

    def get_user_by_email(self, email: str) -> Optional[User]:
        return self.db.execute(
            select(User).filter(User.email == email)
        ).scalar_one_or_none()

    def get_profile(self, user_id: str) -> Optional[UserProfile]:
        """Get profile by user_id, with fallback to id (PK) for pre-migration profiles."""
        profile = self.db.execute(
            select(UserProfile).filter(UserProfile.user_id == user_id)
        ).scalar_one_or_none()
        if not profile:
            # Fallback: old profiles have id=user_id but user_id column may be NULL
            profile = self.db.execute(
                select(UserProfile).filter(UserProfile.id == user_id)
            ).scalar_one_or_none()
        return profile

    def repair_profile_link(self, profile: UserProfile, user_id: str) -> bool:
        """Fix user_id on a profile found via id fallback. Returns True on success."""
        if profile.user_id == user_id:
            return True
        try:
            profile.user_id = user_id
            self.db.commit()
            self.db.refresh(profile)
            return True
        except (IntegrityError, Exception):
            self.db.rollback()
            return False

    def update_profile(self, user_id: str, **kwargs) -> Optional[UserProfile]:
        profile = self.get_profile(user_id)
        if not profile:
            return None

        allowed_fields = {
            "full_name", "phone", "avatar_url", "bio", "role", "is_active",
            "persona", "baseline_completed", "baseline_score",
            "endline_completed", "endline_score", "weak_modules",
            "baseline_attempt_count", "endline_attempt_count",
            "region", "sub_region", "school_id", "teacher_ids",
            "qualifications", "experiences",
        }
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
        from sqlalchemy import func
        total = self.db.execute(
            select(func.count(User.id))
        ).scalar() or 0
        users = self.db.execute(
            select(User).limit(limit).offset(offset)
        ).scalars().all()
        return list(users), total

    def user_exists(self, email: str) -> bool:
        return self.db.execute(
            select(User).filter(User.email == email)
        ).scalar_one_or_none() is not None

    # --- Roles ---
    def get_user_roles(self, user_id: str) -> List[str]:
        roles = self.db.execute(
            select(UserRole.role).filter(UserRole.user_id == user_id)
        ).scalars().all()
        # Also check profile.role for admin/coach
        profile = self.get_profile(user_id)
        role_set = set(roles)
        if profile and profile.role in ("admin", "coach"):
            role_set.add(profile.role)
        return list(role_set)

    # --- Certificates ---
    def get_certificate(self, user_id: str) -> Optional[Certificate]:
        return self.db.execute(
            select(Certificate).filter(Certificate.user_id == user_id)
        ).scalar_one_or_none()

    def upsert_certificate(self, user_id: str, certificate_id: str, persona: Optional[str] = None) -> Optional[Certificate]:
        existing = self.get_certificate(user_id)
        now = datetime.utcnow()
        if existing:
            existing.certificate_id = certificate_id
            existing.persona = persona
            existing.issued_at = now
        else:
            existing = Certificate(
                id=str(uuid.uuid4()),
                user_id=user_id,
                certificate_id=certificate_id,
                persona=persona,
                issued_at=now,
            )
            self.db.add(existing)
        try:
            self.db.commit()
            self.db.refresh(existing)
            return existing
        except Exception:
            self.db.rollback()
            return None
