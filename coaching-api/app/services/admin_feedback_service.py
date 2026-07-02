"""Admin feedback service — queries user_feedback with profile joins."""

import uuid
import logging
from sqlalchemy import select, func, and_
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError
from typing import Optional, List, Dict, Any
from datetime import datetime, timedelta

from app.models.user_feedback import UserFeedback
from app.models.user import UserProfile, User

logger = logging.getLogger(__name__)


class AdminFeedbackService:
    """Service for admin feedback queries and creation."""

    def __init__(self, db: Session):
        self.db = db

    def _ensure_user_exists(self, user_id: str) -> None:
        """Ensure a User row exists for the given user_id (pre-migration Supabase users may be missing)."""
        existing = self.db.execute(
            select(User).filter(User.id == user_id)
        ).scalar_one_or_none()
        if existing:
            return
        # Auto-create a minimal user record so FK constraints pass.
        # Email is unknown here; use a placeholder that can be updated later.
        try:
            user = User(id=user_id, email=f"{user_id}@placeholder.local")
            self.db.add(user)
            self.db.flush()
            logger.info(f"Auto-created user record for pre-migration user_id={user_id}")
        except IntegrityError:
            # Race condition: another request created it between our check and insert
            self.db.rollback()

    def create_feedback(
        self,
        user_id: str,
        category: str,
        rating: int,
        positive_feedback: Optional[str] = None,
        improvement_feedback: Optional[str] = None,
        context_page: Optional[str] = None,
        module_id: Optional[str] = None,
        training_id: Optional[str] = None,
        persona: Optional[str] = None,
        user_agent: Optional[str] = None,
    ) -> Dict[str, Any]:
        """Create a new feedback record in user_feedback table."""
        self._ensure_user_exists(user_id)
        feedback = UserFeedback(
            id=str(uuid.uuid4()),
            user_id=user_id,
            category=category,
            rating=rating,
            positive_feedback=positive_feedback,
            improvement_feedback=improvement_feedback,
            context_page=context_page,
            module_id=module_id,
            training_id=training_id,
            persona=persona,
            user_agent=user_agent,
        )
        try:
            self.db.add(feedback)
            self.db.commit()
            self.db.refresh(feedback)
            return feedback.to_dict()
        except IntegrityError as e:
            self.db.rollback()
            logger.error(f"Feedback insert failed for user_id={user_id}: {e.orig}")
            raise ValueError(f"Failed to create feedback: {e.orig}")

    def get_feedback(
        self,
        days: int = 30,
        category: Optional[str] = None,
        rating: Optional[int] = None,
        persona: Optional[str] = None,
        start_date: Optional[str] = None,
        end_date: Optional[str] = None,
        limit: int = 500,
        offset: int = 0,
    ) -> Dict[str, Any]:
        """
        Fetch feedback records with profile joins and KPI aggregation.

        If start_date/end_date are provided, they override the `days` parameter.
        Returns dict with 'items', 'total', 'kpis' keys.
        """
        # Build time range
        conditions = []
        if start_date:
            conditions.append(UserFeedback.created_at >= datetime.fromisoformat(start_date))
        elif days:
            conditions.append(UserFeedback.created_at >= datetime.utcnow() - timedelta(days=days))

        if end_date:
            # End of the selected day (23:59:59)
            end_dt = datetime.fromisoformat(end_date) + timedelta(days=1)
            conditions.append(UserFeedback.created_at < end_dt)
        if category:
            conditions.append(UserFeedback.category == category)
        if rating is not None:
            conditions.append(UserFeedback.rating == rating)
        if persona:
            conditions.append(UserFeedback.persona == persona)

        where_clause = and_(*conditions)

        # Total count
        total = self.db.execute(
            select(func.count(UserFeedback.id))
            .where(where_clause)
        ).scalar() or 0

        # KPIs — computed on the full filtered set (not paginated)
        kpi_row = self.db.execute(
            select(
                func.count(UserFeedback.id).label("total_feedback"),
                func.coalesce(func.avg(UserFeedback.rating), 0).label("avg_rating"),
                func.count(UserFeedback.id).filter(UserFeedback.rating <= 2).label("low_rating_count"),
            ).where(where_clause)
        ).one()

        kpis = {
            "totalFeedback": kpi_row.total_feedback,
            "avgRating": round(float(kpi_row.avg_rating), 1),
            "lowRatingCount": kpi_row.low_rating_count,
        }

        # Paginated feedback with LEFT JOIN to profiles and users
        query = (
            select(UserFeedback, UserProfile, User)
            .outerjoin(UserProfile, UserFeedback.user_id == UserProfile.id)
            .outerjoin(User, UserFeedback.user_id == User.id)
            .where(where_clause)
            .order_by(UserFeedback.created_at.desc())
            .limit(limit)
            .offset(offset)
        )

        rows = self.db.execute(query).all()

        items: List[Dict[str, Any]] = []
        for fb, profile, user in rows:
            record = fb.to_dict()
            record["profiles"] = {
                "id": profile.id if profile else None,
                "full_name": profile.full_name if profile else None,
                "email": user.email if user else None,
                "phone": profile.phone if profile else None,
            } if profile or user else None
            items.append(record)

        return {
            "items": items,
            "total": total,
            "kpis": kpis,
            "limit": limit,
            "offset": offset,
        }
