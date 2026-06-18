"""Admin feedback service — queries user_feedback with profile joins."""

from sqlalchemy import select, func, and_
from sqlalchemy.orm import Session
from typing import Optional, List, Dict, Any
from datetime import datetime, timedelta

from app.models.user_feedback import UserFeedback
from app.models.user import UserProfile


class AdminFeedbackService:
    """Service for admin feedback queries (read-only)."""

    def __init__(self, db: Session):
        self.db = db

    def get_feedback(
        self,
        days: int = 30,
        category: Optional[str] = None,
        rating: Optional[int] = None,
        persona: Optional[str] = None,
        limit: int = 500,
        offset: int = 0,
    ) -> Dict[str, Any]:
        """
        Fetch feedback records with profile joins and KPI aggregation.

        Returns dict with 'items', 'total', 'kpis' keys.
        """
        cutoff = datetime.utcnow() - timedelta(days=days)

        # Build filter conditions
        conditions = [UserFeedback.created_at >= cutoff]
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

        # Paginated feedback with LEFT JOIN to profiles
        query = (
            select(UserFeedback, UserProfile)
            .outerjoin(UserProfile, UserFeedback.user_id == UserProfile.id)
            .where(where_clause)
            .order_by(UserFeedback.created_at.desc())
            .limit(limit)
            .offset(offset)
        )

        rows = self.db.execute(query).all()

        items: List[Dict[str, Any]] = []
        for fb, profile in rows:
            record = fb.to_dict()
            record["profiles"] = {
                "id": profile.id if profile else None,
                "full_name": profile.full_name if profile else None,
                "email": None,  # email lives on User, not UserProfile
                "phone": profile.phone if profile else None,
            } if profile else None
            items.append(record)

        return {
            "items": items,
            "total": total,
            "kpis": kpis,
            "limit": limit,
            "offset": offset,
        }
