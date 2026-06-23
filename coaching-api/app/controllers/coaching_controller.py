"""Coaching API endpoints — sessions, observations, and teacher DC scores."""

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session as DbSession
from sqlalchemy import desc
from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime, timezone
import uuid
from app.database import get_db
from app.services.coaching_service import CoachingService
from app.models.observation import CotObservation, TeacherDcScore

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
    db: DbSession = Depends(get_db)
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
    db: DbSession = Depends(get_db)
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
    db: DbSession = Depends(get_db)
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
    db: DbSession = Depends(get_db)
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
    db: DbSession = Depends(get_db)
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
    db: DbSession = Depends(get_db)
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
    db: DbSession = Depends(get_db)
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
    db: DbSession = Depends(get_db)
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
    db: DbSession = Depends(get_db)
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
    db: DbSession = Depends(get_db)
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


# ---------------------------------------------------------------------------
# Observation Scheduler Endpoints
# ---------------------------------------------------------------------------

class CreateObservationRequest(BaseModel):
    """Create observation request."""
    observer_id: str
    teacher_name: str
    school_name: str
    subject: Optional[str] = None
    grade: Optional[str] = None
    topic: Optional[str] = None
    framework: Optional[str] = None  # FICO, HOTS
    date: str
    visit_purpose: Optional[str] = None
    status: str = "Scheduled"
    region: str
    week: Optional[str] = None
    visit_type: Optional[str] = None
    planned_date: Optional[str] = None
    arrival_time: Optional[str] = None
    departure_time: Optional[str] = None
    is_multi_grade: Optional[bool] = None


class UpdateObservationStatusRequest(BaseModel):
    """Update observation status request."""
    status: str  # Scheduled, Draft, Submitted, Approved


class PatchObservationRequest(BaseModel):
    """Partial update for an observation. All fields optional."""
    status: Optional[str] = None
    notes_for_teacher: Optional[str] = None
    hots_notes: Optional[str] = None
    hots_rubric: Optional[dict] = None
    fico_rubric: Optional[dict] = None
    total_score: Optional[float] = None
    proficiency_level: Optional[str] = None
    submitted_at: Optional[str] = None


@router.get("/teachers/dc-scores")
async def get_teacher_dc_scores(
    region: Optional[str] = Query(None),
    db: DbSession = Depends(get_db),
):
    """Get teacher DC scores, optionally filtered by region."""
    query = db.query(TeacherDcScore)
    if region:
        query = query.filter(TeacherDcScore.region == region)
    query = query.order_by(desc(TeacherDcScore.scored_at))
    scores = query.all()

    return {
        "teachers": [s.to_dict() for s in scores],
        "total": len(scores),
        "region": region,
    }


@router.get("/observations")
async def list_observations(
    observer_id: Optional[str] = Query(None),
    region: Optional[str] = Query(None),
    db: DbSession = Depends(get_db),
):
    """List observations, filtered by observer_id and/or region."""
    query = db.query(CotObservation)
    if observer_id:
        query = query.filter(CotObservation.observer_id == observer_id)
    if region:
        query = query.filter(CotObservation.region == region)
    query = query.order_by(desc(CotObservation.created_at))
    observations = query.all()

    return {
        "observations": [o.to_dict() for o in observations],
        "total": len(observations),
    }


@router.post("/observations", status_code=201)
async def create_observation(
    request: CreateObservationRequest,
    db: DbSession = Depends(get_db),
):
    """Create a new observation."""
    observation = CotObservation(
        id=str(uuid.uuid4()),
        observer_id=request.observer_id,
        teacher_name=request.teacher_name,
        school_name=request.school_name,
        subject=request.subject,
        grade=request.grade,
        topic=request.topic,
        framework=request.framework,
        date=request.date,
        visit_purpose=request.visit_purpose,
        status=request.status,
        region=request.region,
        week=request.week,
        visit_type=request.visit_type,
        planned_date=request.planned_date,
        arrival_time=request.arrival_time,
        departure_time=request.departure_time,
    )
    db.add(observation)
    db.commit()
    db.refresh(observation)
    return observation.to_dict()


@router.delete("/observations/{observation_id}", status_code=200)
async def delete_observation(
    observation_id: str,
    db: DbSession = Depends(get_db),
):
    """Delete an observation by ID."""
    observation = db.query(CotObservation).filter(CotObservation.id == observation_id).first()
    if not observation:
        raise HTTPException(status_code=404, detail="Observation not found")

    db.delete(observation)
    db.commit()
    return {"message": "Observation deleted", "id": observation_id}


@router.get("/observations/{observation_id}")
async def get_observation(
    observation_id: str,
    db: DbSession = Depends(get_db),
):
    """Get a single observation by ID."""
    observation = db.query(CotObservation).filter(CotObservation.id == observation_id).first()
    if not observation:
        raise HTTPException(status_code=404, detail="Observation not found")
    return observation.to_dict()


@router.patch("/observations/{observation_id}")
async def patch_observation(
    observation_id: str,
    request: PatchObservationRequest,
    db: DbSession = Depends(get_db),
):
    """Partially update an observation. Only provided fields are changed."""
    observation = db.query(CotObservation).filter(CotObservation.id == observation_id).first()
    if not observation:
        raise HTTPException(status_code=404, detail="Observation not found")

    update_data = request.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(observation, field, value)

    # If status changed to Submitted and submitted_at wasn't explicitly provided,
    # set it automatically
    if request.status == "Submitted" and "submitted_at" not in update_data:
        observation.submitted_at = datetime.now(timezone.utc)

    observation.updated_at = datetime.now(timezone.utc)
    db.commit()
    db.refresh(observation)
    return observation.to_dict()


@router.put("/observations/{observation_id}/status")
async def update_observation_status(
    observation_id: str,
    request: UpdateObservationStatusRequest,
    db: DbSession = Depends(get_db),
):
    """Update an observation's status."""
    observation = db.query(CotObservation).filter(CotObservation.id == observation_id).first()
    if not observation:
        raise HTTPException(status_code=404, detail="Observation not found")

    observation.status = request.status
    if request.status == "Submitted":
        observation.submitted_at = datetime.utcnow()

    db.commit()
    db.refresh(observation)
    return observation.to_dict()
