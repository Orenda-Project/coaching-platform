"""Observation API endpoints."""

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime
import uuid
from app.database import get_db
from app.services.observation_service import ObservationService

router = APIRouter(prefix="/api/observations", tags=["observations"])


# Request/Response Models
class CreateObservationRequest(BaseModel):
    """Create observation request."""

    user_id: str
    date: datetime
    notes: Optional[str] = None


class COTObservationRequest(BaseModel):
    """Create COT observation request."""

    category: str
    response: Optional[str] = None
    rating: Optional[int] = Field(None, ge=1, le=5)


class ObservationNoteRequest(BaseModel):
    """Add note to observation request."""

    note_text: str
    created_by: str


class COTObservationResponse(BaseModel):
    """COT observation response."""

    id: str
    observation_id: str
    category: str
    response: Optional[str]
    rating: Optional[int]
    created_at: str
    updated_at: str

    class Config:
        from_attributes = True


class ObservationNoteResponse(BaseModel):
    """Observation note response."""

    id: str
    observation_id: str
    note_text: str
    created_by: str
    created_at: str
    updated_at: str

    class Config:
        from_attributes = True


class ObservationResponse(BaseModel):
    """Observation response."""

    id: str
    user_id: str
    date: str
    notes: Optional[str]
    created_at: str
    updated_at: str
    cot_observations: List[COTObservationResponse] = []
    observation_notes: List[ObservationNoteResponse] = []

    class Config:
        from_attributes = True


class BulkObservationsRequest(BaseModel):
    """Bulk observations request."""

    observations: List[CreateObservationRequest]


# Endpoints
@router.post("", response_model=ObservationResponse, status_code=201)
async def create_observation(
    request: CreateObservationRequest,
    db: Session = Depends(get_db)
):
    """
    Create a new observation.

    Args:
        request: Observation data (user_id, date, notes)

    Returns:
        Created observation
    """
    service = ObservationService(db)
    observation = service.create_observation(
        user_id=request.user_id,
        date=request.date,
        notes=request.notes
    )

    if not observation:
        raise HTTPException(
            status_code=400,
            detail="Failed to create observation"
        )

    return observation.to_dict()


@router.get("/{observation_id}", response_model=ObservationResponse)
async def get_observation(
    observation_id: str,
    db: Session = Depends(get_db)
):
    """Get observation by ID."""
    service = ObservationService(db)
    observation = service.get_observation(observation_id)

    if not observation:
        raise HTTPException(status_code=404, detail="Observation not found")

    return observation.to_dict()


@router.get("/user/{user_id}", response_model=dict)
async def get_user_observations(
    user_id: str,
    limit: int = Query(100, ge=1, le=1000),
    offset: int = Query(0, ge=0),
    db: Session = Depends(get_db)
):
    """
    Get all observations for a user.

    Args:
        user_id: User ID
        limit: Number of results (max 1000)
        offset: Results offset

    Returns:
        Observations list with total count
    """
    service = ObservationService(db)
    observations = service.get_user_observations(user_id, limit=limit, offset=offset)

    return {
        "observations": [o.to_dict() for o in observations],
        "count": len(observations),
        "limit": limit,
        "offset": offset,
    }


@router.put("/{observation_id}", response_model=ObservationResponse)
async def update_observation(
    observation_id: str,
    request: CreateObservationRequest,
    db: Session = Depends(get_db)
):
    """
    Update an observation.

    Args:
        observation_id: Observation ID
        request: Update data (notes)

    Returns:
        Updated observation
    """
    service = ObservationService(db)

    # Only allow updating notes
    update_data = {"notes": request.notes}
    observation = service.update_observation(observation_id, update_data)

    if not observation:
        raise HTTPException(status_code=404, detail="Observation not found")

    return observation.to_dict()


@router.delete("/{observation_id}", status_code=204)
async def delete_observation(
    observation_id: str,
    db: Session = Depends(get_db)
):
    """Delete an observation."""
    service = ObservationService(db)
    success = service.delete_observation(observation_id)

    if not success:
        raise HTTPException(status_code=404, detail="Observation not found")

    return None


@router.post("/{observation_id}/cot", response_model=COTObservationResponse, status_code=201)
async def add_cot_observation(
    observation_id: str,
    request: COTObservationRequest,
    db: Session = Depends(get_db)
):
    """
    Add a COT (Coaching Over Time) reflection to an observation.

    Args:
        observation_id: Observation ID
        request: COT data (category, response, rating)

    Returns:
        Created COT observation
    """
    service = ObservationService(db)
    cot = service.create_cot_observation(
        observation_id=observation_id,
        category=request.category,
        response=request.response,
        rating=request.rating
    )

    if not cot:
        raise HTTPException(
            status_code=400,
            detail="Failed to create COT observation (observation not found?)"
        )

    return cot.to_dict()


@router.get("/{observation_id}/cot", response_model=dict)
async def get_cot_observations(
    observation_id: str,
    db: Session = Depends(get_db)
):
    """Get all COT observations for an observation."""
    service = ObservationService(db)

    # Verify observation exists
    observation = service.get_observation(observation_id)
    if not observation:
        raise HTTPException(status_code=404, detail="Observation not found")

    cot_responses = service.get_cot_responses(observation_id)

    return {
        "observation_id": observation_id,
        "cot_observations": [cot.to_dict() for cot in cot_responses],
        "count": len(cot_responses),
    }


@router.post("/{observation_id}/notes", response_model=ObservationNoteResponse, status_code=201)
async def add_observation_note(
    observation_id: str,
    request: ObservationNoteRequest,
    db: Session = Depends(get_db)
):
    """
    Add a note to an observation.

    Args:
        observation_id: Observation ID
        request: Note data (note_text, created_by)

    Returns:
        Created observation note
    """
    service = ObservationService(db)
    note = service.create_observation_note(
        observation_id=observation_id,
        note_text=request.note_text,
        created_by=request.created_by
    )

    if not note:
        raise HTTPException(
            status_code=400,
            detail="Failed to create observation note (observation not found?)"
        )

    return note.to_dict()


@router.get("/{observation_id}/notes", response_model=dict)
async def get_observation_notes(
    observation_id: str,
    db: Session = Depends(get_db)
):
    """Get all notes for an observation."""
    service = ObservationService(db)

    # Verify observation exists
    observation = service.get_observation(observation_id)
    if not observation:
        raise HTTPException(status_code=404, detail="Observation not found")

    notes = service.get_observation_notes(observation_id)

    return {
        "observation_id": observation_id,
        "notes": [n.to_dict() for n in notes],
        "count": len(notes),
    }


@router.post("/bulk", response_model=dict, status_code=201)
async def bulk_save_observations(
    request: BulkObservationsRequest,
    db: Session = Depends(get_db)
):
    """
    Bulk create observations.

    Args:
        request: List of observations to create

    Returns:
        List of created observations
    """
    service = ObservationService(db)

    observations_data = [
        {
            "user_id": obs.user_id,
            "date": obs.date,
            "notes": obs.notes,
        }
        for obs in request.observations
    ]

    observations = service.bulk_save_observations(observations_data)

    if not observations:
        raise HTTPException(
            status_code=400,
            detail="Failed to save observations"
        )

    return {
        "observations": [o.to_dict() for o in observations],
        "count": len(observations),
    }
