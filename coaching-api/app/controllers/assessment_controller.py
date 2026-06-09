"""Assessment API endpoints."""

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from pydantic import BaseModel, Field
from typing import Optional, List
from app.database import get_db
from app.services.assessment_service import AssessmentService

router = APIRouter(prefix="/api/assessments", tags=["assessments"])


# Request/Response Models
class AssessmentResponseRequest(BaseModel):
    """Single response to a question."""

    question_id: str
    user_answer: str


class SubmitAssessmentRequest(BaseModel):
    """Submit assessment with responses."""

    responses: List[AssessmentResponseRequest]


class EvaluateAssessmentRequest(BaseModel):
    """Request to evaluate and grade assessment."""

    answer_key: dict  # Maps question_id to correct_answer


class AssessmentResponseData(BaseModel):
    """Assessment response in response."""

    id: str
    assessment_id: str
    question_id: str
    user_answer: Optional[str]
    is_correct: Optional[bool]
    points_earned: float
    created_at: str
    updated_at: str

    class Config:
        from_attributes = True


class AssessmentResponse(BaseModel):
    """Assessment response model."""

    id: str
    user_id: str
    module_id: str
    score: Optional[float]
    status: str
    attempt_number: int
    created_at: str
    updated_at: str
    submitted_at: Optional[str]
    responses: List[AssessmentResponseData] = []

    class Config:
        from_attributes = True


class AssessmentResultsResponse(BaseModel):
    """Assessment results breakdown."""

    assessment_id: str
    user_id: str
    module_id: str
    score: Optional[float]
    passed: Optional[bool]
    attempt_number: int
    status: str
    submitted_at: Optional[str]
    response_count: int
    correct_responses: int
    responses: List[AssessmentResponseData]


class AssessmentListResponse(BaseModel):
    """Paginated assessment list."""

    assessments: List[AssessmentResponse]
    total: int
    limit: int
    offset: int


# Endpoints
@router.post("", response_model=AssessmentResponse, status_code=201)
async def create_assessment(
    user_id: str = Query(..., description="User ID"),
    module_id: str = Query(..., description="Module ID"),
    db: Session = Depends(get_db)
):
    """
    Create a new assessment for a user and module.

    Args:
        user_id: User ID
        module_id: Module ID

    Returns:
        Created Assessment
    """
    service = AssessmentService(db)
    assessment = service.create_assessment(user_id, module_id)

    if not assessment:
        raise HTTPException(
            status_code=400,
            detail="Failed to create assessment"
        )

    return assessment.to_dict()


@router.get("/{assessment_id}", response_model=AssessmentResponse)
async def get_assessment(
    assessment_id: str,
    db: Session = Depends(get_db)
):
    """Get assessment by ID."""
    service = AssessmentService(db)
    assessment = service.get_assessment(assessment_id)

    if not assessment:
        raise HTTPException(status_code=404, detail="Assessment not found")

    return assessment.to_dict()


@router.get("/user/{user_id}", response_model=AssessmentListResponse)
async def get_user_assessments(
    user_id: str,
    limit: int = Query(100, ge=1, le=1000),
    offset: int = Query(0, ge=0),
    db: Session = Depends(get_db)
):
    """
    Get all assessments for a user.

    Args:
        user_id: User ID
        limit: Number of results
        offset: Results offset

    Returns:
        Paginated assessments list
    """
    service = AssessmentService(db)
    assessments, total = service.get_user_assessments(user_id, limit=limit, offset=offset)

    return {
        "assessments": [a.to_dict() for a in assessments],
        "total": total,
        "limit": limit,
        "offset": offset,
    }


@router.post("/{assessment_id}/submit", response_model=AssessmentResponse)
async def submit_assessment(
    assessment_id: str,
    request: SubmitAssessmentRequest,
    db: Session = Depends(get_db)
):
    """
    Submit assessment with responses.

    Args:
        assessment_id: Assessment ID
        request: Responses data

    Returns:
        Updated assessment
    """
    service = AssessmentService(db)

    # Verify assessment exists
    assessment = service.get_assessment(assessment_id)
    if not assessment:
        raise HTTPException(status_code=404, detail="Assessment not found")

    # Submit with responses
    response_data = [r.dict() for r in request.responses]
    updated = service.submit_assessment(assessment_id, response_data)

    if not updated:
        raise HTTPException(
            status_code=400,
            detail="Failed to submit assessment"
        )

    return updated.to_dict()


@router.post("/{assessment_id}/evaluate")
async def evaluate_assessment(
    assessment_id: str,
    request: EvaluateAssessmentRequest,
    db: Session = Depends(get_db)
):
    """
    Evaluate and grade assessment.

    Args:
        assessment_id: Assessment ID
        request: Answer key mapping

    Returns:
        Graded assessment results
    """
    service = AssessmentService(db)

    # Verify assessment exists
    assessment = service.get_assessment(assessment_id)
    if not assessment:
        raise HTTPException(status_code=404, detail="Assessment not found")

    # Evaluate responses
    evaluated = service.evaluate_responses(assessment_id, request.answer_key)
    if not evaluated:
        raise HTTPException(
            status_code=400,
            detail="Failed to evaluate assessment"
        )

    # Get detailed results
    results = service.get_assessment_results(assessment_id)
    return results


@router.get("/{assessment_id}/results", response_model=AssessmentResultsResponse)
async def get_assessment_results(
    assessment_id: str,
    db: Session = Depends(get_db)
):
    """
    Get detailed results for an assessment.

    Args:
        assessment_id: Assessment ID

    Returns:
        Detailed results breakdown
    """
    service = AssessmentService(db)
    results = service.get_assessment_results(assessment_id)

    if not results:
        raise HTTPException(status_code=404, detail="Assessment not found")

    return results


@router.get("/user/{user_id}/history", response_model=List[AssessmentResponse])
async def get_assessment_history(
    user_id: str,
    limit: int = Query(10, ge=1, le=100),
    db: Session = Depends(get_db)
):
    """
    Get recent assessment history for a user.

    Args:
        user_id: User ID
        limit: Number of recent assessments

    Returns:
        List of recent assessments
    """
    service = AssessmentService(db)
    assessments = service.get_assessment_history(user_id, limit=limit)

    return [a.to_dict() for a in assessments]


@router.put("/{assessment_id}", response_model=AssessmentResponse)
async def update_assessment(
    assessment_id: str,
    score: Optional[float] = Query(None),
    status: Optional[str] = Query(None),
    db: Session = Depends(get_db)
):
    """
    Update assessment fields.

    Args:
        assessment_id: Assessment ID
        score: New score
        status: New status

    Returns:
        Updated assessment
    """
    service = AssessmentService(db)

    update_data = {}
    if score is not None:
        update_data["score"] = score
    if status is not None:
        update_data["status"] = status

    updated = service.update_assessment(assessment_id, **update_data)

    if not updated:
        raise HTTPException(status_code=404, detail="Assessment not found")

    return updated.to_dict()


@router.delete("/{assessment_id}", status_code=204)
async def delete_assessment(
    assessment_id: str,
    db: Session = Depends(get_db)
):
    """Delete assessment."""
    service = AssessmentService(db)
    success = service.delete_assessment(assessment_id)

    if not success:
        raise HTTPException(status_code=404, detail="Assessment not found")

    return None


@router.get("/module/{module_id}", response_model=AssessmentListResponse)
async def get_module_assessments(
    module_id: str,
    limit: int = Query(100, ge=1, le=1000),
    offset: int = Query(0, ge=0),
    db: Session = Depends(get_db)
):
    """
    Get all assessments for a module.

    Args:
        module_id: Module ID
        limit: Number of results
        offset: Results offset

    Returns:
        Paginated assessments list
    """
    service = AssessmentService(db)
    assessments, total = service.get_module_assessments(module_id, limit=limit, offset=offset)

    return {
        "assessments": [a.to_dict() for a in assessments],
        "total": total,
        "limit": limit,
        "offset": offset,
    }
