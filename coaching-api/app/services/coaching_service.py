"""Coaching service for managing coaching sessions and feedback."""

from sqlalchemy import select
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError
from datetime import datetime
from typing import Optional, Dict, Any, List
import uuid
from app.models.coaching import CoachingSession, Feedback, SessionNote


class CoachingService:
    """Service for coaching session and feedback operations."""

    def __init__(self, db: Session):
        self.db = db

    def schedule_coaching_session(
        self,
        coach_id: str,
        coachee_id: str,
        date: datetime,
        notes: Optional[str] = None
    ) -> Optional[CoachingSession]:
        """
        Schedule a new coaching session.

        Args:
            coach_id: User ID of the coach
            coachee_id: User ID of the learner
            date: Scheduled session date/time
            notes: Session notes

        Returns:
            Created CoachingSession or None if error
        """
        try:
            session = CoachingSession(
                id=str(uuid.uuid4()),
                coach_id=coach_id,
                coachee_id=coachee_id,
                date=date,
                status="scheduled",
                notes=notes,
            )
            self.db.add(session)
            self.db.commit()
            self.db.refresh(session)
            return session
        except Exception:
            self.db.rollback()
            return None

    def get_session(self, session_id: str) -> Optional[CoachingSession]:
        """Get coaching session by ID."""
        return self.db.execute(
            select(CoachingSession).filter(CoachingSession.id == session_id)
        ).scalar_one_or_none()

    def get_sessions(
        self,
        user_id: str,
        role: str = "coach",
        status: Optional[str] = None,
        limit: int = 100,
        offset: int = 0
    ) -> List[CoachingSession]:
        """
        Get coaching sessions for a user.

        Args:
            user_id: User ID
            role: "coach" or "learner" to determine which sessions to fetch
            status: Filter by status (optional)
            limit: Number of results
            offset: Results offset

        Returns:
            List of coaching sessions
        """
        query = select(CoachingSession)

        if role == "coach":
            query = query.filter(CoachingSession.coach_id == user_id)
        elif role == "learner":
            query = query.filter(CoachingSession.coachee_id == user_id)

        if status:
            query = query.filter(CoachingSession.status == status)

        return self.db.execute(
            query.order_by(CoachingSession.date.desc())
            .limit(limit)
            .offset(offset)
        ).scalars().all()

    def complete_session(self, session_id: str) -> Optional[CoachingSession]:
        """
        Mark a coaching session as completed.

        Args:
            session_id: Coaching session ID

        Returns:
            Updated CoachingSession or None if not found
        """
        session = self.get_session(session_id)
        if not session:
            return None

        session.status = "completed"

        try:
            self.db.commit()
            self.db.refresh(session)
            return session
        except Exception:
            self.db.rollback()
            return None

    def cancel_session(self, session_id: str) -> Optional[CoachingSession]:
        """
        Mark a coaching session as cancelled.

        Args:
            session_id: Coaching session ID

        Returns:
            Updated CoachingSession or None if not found
        """
        session = self.get_session(session_id)
        if not session:
            return None

        session.status = "cancelled"

        try:
            self.db.commit()
            self.db.refresh(session)
            return session
        except Exception:
            self.db.rollback()
            return None

    def update_session_notes(
        self,
        session_id: str,
        notes: str
    ) -> Optional[CoachingSession]:
        """
        Update session summary notes.

        Args:
            session_id: Coaching session ID
            notes: Session notes

        Returns:
            Updated CoachingSession or None if not found
        """
        session = self.get_session(session_id)
        if not session:
            return None

        session.notes = notes

        try:
            self.db.commit()
            self.db.refresh(session)
            return session
        except Exception:
            self.db.rollback()
            return None

    def add_feedback(
        self,
        session_id: str,
        feedback_data: Dict[str, Any]
    ) -> Optional[Feedback]:
        """
        Add feedback to a coaching session.

        Args:
            session_id: Coaching session ID
            feedback_data: Dict with category, rating, comments

        Returns:
            Created Feedback or None if error
        """
        # Verify session exists
        session = self.get_session(session_id)
        if not session:
            return None

        try:
            feedback = Feedback(
                id=str(uuid.uuid4()),
                session_id=session_id,
                category=feedback_data.get("category"),
                rating=feedback_data.get("rating"),
                comments=feedback_data.get("comments"),
            )
            self.db.add(feedback)
            self.db.commit()
            self.db.refresh(feedback)
            return feedback
        except Exception:
            self.db.rollback()
            return None

    def get_session_feedback(self, session_id: str) -> List[Feedback]:
        """
        Get all feedback for a coaching session.

        Args:
            session_id: Coaching session ID

        Returns:
            List of feedback records
        """
        return self.db.execute(
            select(Feedback)
            .filter(Feedback.session_id == session_id)
            .order_by(Feedback.created_at)
        ).scalars().all()

    def add_session_note(
        self,
        session_id: str,
        content: str,
        created_by: str
    ) -> Optional[SessionNote]:
        """
        Add a note to a coaching session.

        Args:
            session_id: Coaching session ID
            content: Note content
            created_by: User ID of who created the note

        Returns:
            Created SessionNote or None if error
        """
        # Verify session exists
        session = self.get_session(session_id)
        if not session:
            return None

        try:
            note = SessionNote(
                id=str(uuid.uuid4()),
                session_id=session_id,
                content=content,
                created_by=created_by,
            )
            self.db.add(note)
            self.db.commit()
            self.db.refresh(note)
            return note
        except Exception:
            self.db.rollback()
            return None

    def get_session_notes(self, session_id: str) -> List[SessionNote]:
        """
        Get all notes for a coaching session.

        Args:
            session_id: Coaching session ID

        Returns:
            List of session notes
        """
        return self.db.execute(
            select(SessionNote)
            .filter(SessionNote.session_id == session_id)
            .order_by(SessionNote.created_at.desc())
        ).scalars().all()
