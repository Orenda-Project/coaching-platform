"""Coaching API endpoints."""

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime
import uuid
from app.database import get_db
from app.services.coaching_service import CoachingService

router = APIRouter(prefix="/api/coaching", tags=["coaching"])


# Request/Response Models
class ScheduleSessionRequest(BaseModel):
    """Schedule coaching session request."""

    coach_id: str
    coachee_id: str
    date: datetime
    notes: Optional[str] = None


class AddFeedbackRequest(BaseModel):
    """Add feedback request."""

    category: str
    rating: Optional[int] = Field(None, ge=1, le=5)
    comments: Optional[str] = None


class SessionNoteRequest(BaseModel):
    """Add session note request."""

    content: str
    created_by: str


class FeedbackResponse(BaseModel):
    """Feedback response."""

    id: str
    session_id: str
    category: str
    rating: Optional[int]
    comments: Optional[str]
    created_at: str
    updated_at: str

    class Config:
        from_attributes = True


class SessionNoteResponse(BaseModel):
    """Session note response."""

    id: str
    session_id: str
    content: str
    created_by: str
    created_at: str
    updated_at: str

    class Config:
        from_attributes = True


class CoachingSessionResponse(BaseModel):
    """Coaching session response."""

    id: str
    coach_id: str
    coachee_id: str
    date: str
    status: str
    notes: Optional[str]
    created_at: str
    updated_at: str
    feedback: List[FeedbackResponse] = []
    session_notes: List[SessionNoteResponse] = []

    class Config:
        from_attributes = True


# Endpoints
@router.post("/sessions", response_model=CoachingSessionResponse, status_code=201)
async def schedule_coaching_session(
    request: ScheduleSessionRequest,
    db: Session = Depends(get_db)
):
    """
    Schedule a new coaching session.

    Args:
        request: Session data (coach_id, coachee_id, date, notes)

    Returns:
        Created coaching session
    """
    service = CoachingService(db)
    session = service.schedule_coaching_session(
        coach_id=request.coach_id,
        coachee_id=request.coachee_id,
        date=request.date,
        notes=request.notes
    )

    if not session:
        raise HTTPException(
            status_code=400,
            detail="Failed to schedule coaching session"
        )

    return session.to_dict()


@router.get("/sessions/{session_id}", response_model=CoachingSessionResponse)
async def get_coaching_session(
    session_id: str,
    db: Session = Depends(get_db)
):
    """Get coaching session by ID."""
    service = CoachingService(db)
    session = service.get_session(session_id)

    if not session:
        raise HTTPException(status_code=404, detail="Coaching session not found")

    return session.to_dict()


@router.get("/sessions/user/{user_id}", response_model=dict)
async def get_user_coaching_sessions(
    user_id: str,
    role: str = Query("coach", pattern="^(coach|learner)$"),
    status: Optional[str] = Query(None),
    limit: int = Query(100, ge=1, le=1000),
    offset: int = Query(0, ge=0),
    db: Session = Depends(get_db)
):
    """
    Get coaching sessions for a user.

    Args:
        user_id: User ID
        role: "coach" or "learner"
        status: Filter by status (optional)
        limit: Number of results (max 1000)
        offset: Results offset

    Returns:
        Sessions list with total count
    """
    service = CoachingService(db)
    sessions = service.get_sessions(user_id, role=role, status=status, limit=limit, offset=offset)

    return {
        "sessions": [s.to_dict() for s in sessions],
        "count": len(sessions),
        "limit": limit,
        "offset": offset,
    }


@router.put("/sessions/{session_id}", response_model=CoachingSessionResponse)
async def update_session_notes(
    session_id: str,
    request: ScheduleSessionRequest,
    db: Session = Depends(get_db)
):
    """
    Update coaching session notes.

    Args:
        session_id: Session ID
        request: Update data (notes)

    Returns:
        Updated session
    """
    service = CoachingService(db)
    session = service.update_session_notes(session_id, request.notes or "")

    if not session:
        raise HTTPException(status_code=404, detail="Coaching session not found")

    return session.to_dict()


@router.post("/sessions/{session_id}/complete", response_model=CoachingSessionResponse)
async def complete_coaching_session(
    session_id: str,
    db: Session = Depends(get_db)
):
    """
    Mark a coaching session as completed.

    Args:
        session_id: Session ID

    Returns:
        Updated session with status=completed
    """
    service = CoachingService(db)
    session = service.complete_session(session_id)

    if not session:
        raise HTTPException(status_code=404, detail="Coaching session not found")

    return session.to_dict()


@router.post("/sessions/{session_id}/cancel", response_model=CoachingSessionResponse)
async def cancel_coaching_session(
    session_id: str,
    db: Session = Depends(get_db)
):
    """
    Cancel a coaching session.

    Args:
        session_id: Session ID

    Returns:
        Updated session with status=cancelled
    """
    service = CoachingService(db)
    session = service.cancel_session(session_id)

    if not session:
        raise HTTPException(status_code=404, detail="Coaching session not found")

    return session.to_dict()


@router.post("/sessions/{session_id}/feedback", response_model=FeedbackResponse, status_code=201)
async def add_session_feedback(
    session_id: str,
    request: AddFeedbackRequest,
    db: Session = Depends(get_db)
):
    """
    Add feedback to a coaching session.

    Args:
        session_id: Session ID
        request: Feedback data (category, rating, comments)

    Returns:
        Created feedback
    """
    service = CoachingService(db)
    feedback = service.add_feedback(
        session_id,
        {
            "category": request.category,
            "rating": request.rating,
            "comments": request.comments,
        }
    )

    if not feedback:
        raise HTTPException(
            status_code=400,
            detail="Failed to add feedback (session not found?)"
        )

    return feedback.to_dict()


@router.get("/sessions/{session_id}/feedback", response_model=dict)
async def get_session_feedback(
    session_id: str,
    db: Session = Depends(get_db)
):
    """Get all feedback for a coaching session."""
    service = CoachingService(db)

    # Verify session exists
    session = service.get_session(session_id)
    if not session:
        raise HTTPException(status_code=404, detail="Coaching session not found")

    feedback = service.get_session_feedback(session_id)

    return {
        "session_id": session_id,
        "feedback": [f.to_dict() for f in feedback],
        "count": len(feedback),
    }


@router.post("/sessions/{session_id}/notes", response_model=SessionNoteResponse, status_code=201)
async def add_session_note(
    session_id: str,
    request: SessionNoteRequest,
    db: Session = Depends(get_db)
):
    """
    Add a note to a coaching session.

    Args:
        session_id: Session ID
        request: Note data (content, created_by)

    Returns:
        Created session note
    """
    service = CoachingService(db)
    note = service.add_session_note(
        session_id,
        request.content,
        request.created_by
    )

    if not note:
        raise HTTPException(
            status_code=400,
            detail="Failed to add session note (session not found?)"
        )

    return note.to_dict()


@router.get("/sessions/{session_id}/notes", response_model=dict)
async def get_session_notes(
    session_id: str,
    db: Session = Depends(get_db)
):
    """Get all notes for a coaching session."""
    service = CoachingService(db)

    # Verify session exists
    session = service.get_session(session_id)
    if not session:
        raise HTTPException(status_code=404, detail="Coaching session not found")

    notes = service.get_session_notes(session_id)

    return {
        "session_id": session_id,
        "notes": [n.to_dict() for n in notes],
        "count": len(notes),
    }


@router.get("/health")
async def health_check():
    """Health check for coaching service."""
    return {
        "status": "healthy",
        "service": "coaching",
    }
