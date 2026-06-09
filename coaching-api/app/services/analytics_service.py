"""Analytics service for tracking user events and metrics."""

from sqlalchemy import select
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError
from datetime import datetime
from typing import Optional, List, Dict, Any, Tuple
import uuid
from app.models import AnalyticsEvent, UserMetrics, User


class AnalyticsService:
    """Service for analytics event logging and metrics aggregation."""

    def __init__(self, db: Session):
        self.db = db

    def log_event(self, user_id: str, event_type: str, event_data: Optional[Dict[str, Any]] = None) -> Optional[AnalyticsEvent]:
        """
        Log an analytics event for a user.

        Args:
            user_id: User ID
            event_type: Type of event (quiz_completed, module_viewed, scenario_responded, etc.)
            event_data: Event metadata (optional)

        Returns:
            Created AnalyticsEvent or None if error
        """
        try:
            event = AnalyticsEvent(
                id=str(uuid.uuid4()),
                user_id=user_id,
                event_type=event_type,
                event_data=event_data or {},
            )
            self.db.add(event)
            self.db.commit()
            self.db.refresh(event)
            return event
        except IntegrityError:
            self.db.rollback()
            return None

    def get_user_events(self, user_id: str, limit: int = 100, offset: int = 0) -> Tuple[List[AnalyticsEvent], int]:
        """
        Get all events for a user with pagination.

        Args:
            user_id: User ID
            limit: Number of results
            offset: Results offset

        Returns:
            Tuple of (events list, total count)
        """
        from sqlalchemy import func

        # Get total count
        total = self.db.execute(
            select(func.count(AnalyticsEvent.id)).filter(AnalyticsEvent.user_id == user_id)
        ).scalar() or 0

        # Get paginated results
        events = self.db.execute(
            select(AnalyticsEvent)
            .filter(AnalyticsEvent.user_id == user_id)
            .order_by(AnalyticsEvent.timestamp.desc())
            .limit(limit)
            .offset(offset)
        ).scalars().all()

        return list(events), total

    def get_events_by_type(self, user_id: str, event_type: str, limit: int = 100) -> List[AnalyticsEvent]:
        """
        Get events of a specific type for a user.

        Args:
            user_id: User ID
            event_type: Event type to filter
            limit: Maximum results

        Returns:
            List of events
        """
        events = self.db.execute(
            select(AnalyticsEvent)
            .filter(AnalyticsEvent.user_id == user_id, AnalyticsEvent.event_type == event_type)
            .order_by(AnalyticsEvent.timestamp.desc())
            .limit(limit)
        ).scalars().all()

        return list(events)

    def get_module_analytics(self, module_id: str, limit: int = 1000) -> List[AnalyticsEvent]:
        """
        Get all events related to a specific module.

        Args:
            module_id: Module ID to query
            limit: Maximum results

        Returns:
            List of events with module_id in event_data
        """
        # This query finds events where event_data contains module_id
        # Using filter with event_data JSON containment
        events = self.db.execute(
            select(AnalyticsEvent)
            .filter(AnalyticsEvent.event_type.in_(["quiz_completed", "module_viewed", "quiz_started"]))
            .limit(limit)
        ).scalars().all()

        # Filter in Python to find matching module_id
        matching = [e for e in events if e.event_data and e.event_data.get("module_id") == module_id]
        return matching

    def get_all_analytics(self, limit: int = 1000, offset: int = 0) -> Tuple[List[AnalyticsEvent], int]:
        """
        Get all analytics events with pagination.

        Args:
            limit: Number of results
            offset: Results offset

        Returns:
            Tuple of (events list, total count)
        """
        from sqlalchemy import func

        total = self.db.execute(
            select(func.count(AnalyticsEvent.id))
        ).scalar() or 0

        events = self.db.execute(
            select(AnalyticsEvent)
            .order_by(AnalyticsEvent.timestamp.desc())
            .limit(limit)
            .offset(offset)
        ).scalars().all()

        return list(events), total

    def get_user_metrics(self, user_id: str) -> Optional[UserMetrics]:
        """
        Get metrics for a user. Creates if not exists.

        Args:
            user_id: User ID

        Returns:
            UserMetrics object
        """
        metrics = self.db.execute(
            select(UserMetrics).filter(UserMetrics.user_id == user_id)
        ).scalar_one_or_none()

        if metrics is None:
            # Auto-create metrics for new user
            metrics = UserMetrics(
                id=str(uuid.uuid4()),
                user_id=user_id,
                quiz_attempts=0,
                modules_passed=0,
                total_score=0,
            )
            try:
                self.db.add(metrics)
                self.db.commit()
                self.db.refresh(metrics)
            except IntegrityError:
                self.db.rollback()
                # Try to fetch again in case created by another process
                metrics = self.db.execute(
                    select(UserMetrics).filter(UserMetrics.user_id == user_id)
                ).scalar_one_or_none()

        return metrics

    def update_metrics(self, user_id: str, updates: Dict[str, int]) -> Optional[UserMetrics]:
        """
        Update user metrics with provided values.

        Args:
            user_id: User ID
            updates: Dictionary of metric updates {quiz_attempts: 1, modules_passed: 1, total_score: 85}

        Returns:
            Updated UserMetrics or None
        """
        metrics = self.get_user_metrics(user_id)

        if metrics is None:
            return None

        for field, value in updates.items():
            if hasattr(metrics, field):
                setattr(metrics, field, value)

        try:
            self.db.commit()
            self.db.refresh(metrics)
            return metrics
        except IntegrityError:
            self.db.rollback()
            return None

    def increment_metric(self, user_id: str, metric_name: str, increment: int) -> Optional[UserMetrics]:
        """
        Increment a metric by a given amount.

        Args:
            user_id: User ID
            metric_name: Name of metric (quiz_attempts, modules_passed, total_score)
            increment: Amount to add

        Returns:
            Updated UserMetrics
        """
        metrics = self.get_user_metrics(user_id)

        if metrics is None:
            return None

        current_value = getattr(metrics, metric_name, 0) or 0
        setattr(metrics, metric_name, current_value + increment)

        try:
            self.db.commit()
            self.db.refresh(metrics)
            return metrics
        except IntegrityError:
            self.db.rollback()
            return None

    def get_dashboard_data(self, user_id: str) -> Dict[str, Any]:
        """
        Get aggregated dashboard data for a user.

        Args:
            user_id: User ID

        Returns:
            Dictionary with user metrics, recent events, etc.
        """
        metrics = self.get_user_metrics(user_id)
        recent_events, _ = self.get_user_events(user_id, limit=10)

        return {
            "user_id": user_id,
            "metrics": metrics.to_dict() if metrics else None,
            "recent_events": [e.to_dict() for e in recent_events],
            "quiz_events": self.get_events_by_type(user_id, "quiz_completed", limit=5),
            "module_events": self.get_events_by_type(user_id, "module_viewed", limit=5),
        }
