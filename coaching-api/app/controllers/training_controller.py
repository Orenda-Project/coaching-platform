"""Training and progress API endpoints."""

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from pydantic import BaseModel
from typing import Optional, List
from app.database import get_db
from app.services.training_service import TrainingService

router = APIRouter(prefix="/api/training", tags=["training"])


# Request/Response Models
class TrainingContentResponse(BaseModel):
    """Training content item."""

    id: str
    format_type: str
    content_url: str
    metadata: dict

    class Config:
        from_attributes = True


class QuestionOptionResponse(BaseModel):
    """Question option."""

    id: str
    text: str
    is_correct: bool
    order: int

    class Config:
        from_attributes = True


class QuestionResponse(BaseModel):
    """Quiz question."""

    id: str
    question_text: str
    question_type: str
    order_number: int
    options: List[QuestionOptionResponse]

    class Config:
        from_attributes = True


class ScenarioOptionResponse(BaseModel):
    """Scenario option."""

    letter: str
    text: str
    is_correct: bool
    rationale: str

    class Config:
        from_attributes = True


class ScenarioResponse(BaseModel):
    """Scenario-based learning content."""

    id: str
    situation: str
    question: str
    difficulty: str
    options: List[ScenarioOptionResponse]

    class Config:
        from_attributes = True


class TrainingResponse(BaseModel):
    """Full training response."""

    id: str
    module_id: str
    title: str
    description: str
    order_number: int
    content: List[TrainingContentResponse]
    quiz: dict  # Contains questions
    scenarios: List[ScenarioResponse]

    class Config:
        from_attributes = True


class TrainingListResponse(BaseModel):
    """Paginated training list."""

    trainings: List[TrainingResponse]
    total: int
    limit: int
    offset: int


class TrainingProgressResponse(BaseModel):
    """User progress for a training."""

    id: str
    user_id: str
    training_id: str
    progress_percentage: float
    is_completed: bool
    completed_at: Optional[str]
    created_at: str
    updated_at: str

    class Config:
        from_attributes = True


class UpdateProgressRequest(BaseModel):
    """Request to update progress."""

    progress_percentage: float


class ModuleProgressResponse(BaseModel):
    """Aggregated progress for a module."""

    module_id: str
    total_trainings: int
    completed_trainings: int
    overall_progress: float


# Endpoints
@router.get("", response_model=TrainingListResponse)
async def get_all_trainings(
    limit: int = Query(100, ge=1, le=1000),
    offset: int = Query(0, ge=0),
    db: Session = Depends(get_db)
):
    """
    Get all trainings.

    Args:
        limit: Number of results
        offset: Results offset

    Returns:
        Paginated trainings list
    """
    service = TrainingService(db)
    trainings, total = service.get_all_trainings(limit=limit, offset=offset)

    return {
        "trainings": [t.to_dict() for t in trainings],
        "total": total,
        "limit": limit,
        "offset": offset,
    }


@router.get("/{training_id}", response_model=TrainingResponse)
async def get_training(
    training_id: str,
    db: Session = Depends(get_db)
):
    """Get specific training by ID."""
    service = TrainingService(db)
    training = service.get_training(training_id)

    if not training:
        raise HTTPException(status_code=404, detail="Training not found")

    return training.to_dict()


@router.get("/module/{module_id}", response_model=TrainingListResponse)
async def get_module_trainings(
    module_id: str,
    limit: int = Query(100, ge=1, le=1000),
    offset: int = Query(0, ge=0),
    db: Session = Depends(get_db)
):
    """
    Get all trainings for a module.

    Args:
        module_id: Module ID
        limit: Number of results
        offset: Results offset

    Returns:
        Paginated trainings list for module
    """
    service = TrainingService(db)
    trainings, total = service.get_module_trainings(module_id, limit=limit, offset=offset)

    return {
        "trainings": [t.to_dict() for t in trainings],
        "total": total,
        "limit": limit,
        "offset": offset,
    }


@router.post("/progress", response_model=TrainingProgressResponse)
async def create_progress(
    user_id: str = Query(..., description="User ID"),
    training_id: str = Query(..., description="Training ID"),
    db: Session = Depends(get_db)
):
    """
    Create or get progress record for user and training.

    Args:
        user_id: User ID
        training_id: Training ID

    Returns:
        TrainingProgress object
    """
    service = TrainingService(db)
    progress = service.create_progress(user_id, training_id)

    if not progress:
        raise HTTPException(
            status_code=400,
            detail="Failed to create progress"
        )

    return progress.to_dict()


@router.get("/progress/{user_id}/{training_id}", response_model=TrainingProgressResponse)
async def get_progress(
    user_id: str,
    training_id: str,
    db: Session = Depends(get_db)
):
    """
    Get user's progress for a training.

    Args:
        user_id: User ID
        training_id: Training ID

    Returns:
        TrainingProgress object
    """
    service = TrainingService(db)
    progress = service.get_user_progress(user_id, training_id)

    if not progress:
        raise HTTPException(
            status_code=404,
            detail="Progress not found"
        )

    return progress.to_dict()


@router.put("/progress/{user_id}/{training_id}", response_model=TrainingProgressResponse)
async def update_progress(
    user_id: str,
    training_id: str,
    request: UpdateProgressRequest,
    db: Session = Depends(get_db)
):
    """
    Update user's progress for a training.

    Args:
        user_id: User ID
        training_id: Training ID
        request: Progress update data

    Returns:
        Updated TrainingProgress
    """
    service = TrainingService(db)
    progress = service.update_progress(
        user_id,
        training_id,
        request.progress_percentage
    )

    if not progress:
        raise HTTPException(
            status_code=400,
            detail="Failed to update progress"
        )

    return progress.to_dict()


@router.post("/progress/{user_id}/{training_id}/complete", response_model=TrainingProgressResponse)
async def mark_complete(
    user_id: str,
    training_id: str,
    db: Session = Depends(get_db)
):
    """
    Mark training as completed for user.

    Args:
        user_id: User ID
        training_id: Training ID

    Returns:
        Updated TrainingProgress
    """
    service = TrainingService(db)
    progress = service.mark_complete(user_id, training_id)

    if not progress:
        raise HTTPException(
            status_code=400,
            detail="Failed to mark training as complete"
        )

    return progress.to_dict()


@router.get("/user/{user_id}", response_model=dict)
async def get_user_progress(
    user_id: str,
    limit: int = Query(100, ge=1, le=1000),
    offset: int = Query(0, ge=0),
    db: Session = Depends(get_db)
):
    """
    Get all progress for a user.

    Args:
        user_id: User ID
        limit: Number of results
        offset: Results offset

    Returns:
        Paginated progress list
    """
    service = TrainingService(db)
    progress_list, total = service.get_user_all_progress(user_id, limit=limit, offset=offset)

    return {
        "progress": [p.to_dict() for p in progress_list],
        "total": total,
        "limit": limit,
        "offset": offset,
    }


@router.get("/module/{module_id}/progress/{user_id}", response_model=ModuleProgressResponse)
async def get_module_progress(
    module_id: str,
    user_id: str,
    db: Session = Depends(get_db)
):
    """
    Get aggregated progress for all trainings in a module.

    Args:
        module_id: Module ID
        user_id: User ID

    Returns:
        Module progress statistics
    """
    service = TrainingService(db)
    progress = service.get_module_progress(user_id, module_id)

    return progress


@router.delete("/progress/{user_id}/{training_id}", status_code=204)
async def delete_progress(
    user_id: str,
    training_id: str,
    db: Session = Depends(get_db)
):
    """Delete progress record."""
    service = TrainingService(db)
    success = service.delete_progress(user_id, training_id)

    if not success:
        raise HTTPException(
            status_code=404,
            detail="Progress not found"
        )

    return None


@router.post("/progress/{user_id}/{training_id}/reset", response_model=TrainingProgressResponse)
async def reset_progress(
    user_id: str,
    training_id: str,
    db: Session = Depends(get_db)
):
    """Reset progress to 0% for a training."""
    service = TrainingService(db)
    progress = service.reset_progress(user_id, training_id)

    if not progress:
        raise HTTPException(
            status_code=404,
            detail="Progress not found"
        )

    return progress.to_dict()
